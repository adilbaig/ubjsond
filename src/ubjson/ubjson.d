module ubjson.ubjson;

private import
    std.stdio,
    std.bitmanip,
    std.conv;

enum Type : char {
    Empty = 'e',
    Null  = 'Z',
    True  = 'T',
    False = 'F',
    Byte  = 'B',
    Int16 = 'i',
    Int32 = 'I',
    Int64 = 'L',
    Float = 'd',
    Double = 'D',
    HugeSmall = 'h', //Not supported
    HugeLarge = 'H', //Not supported
    StringSmall = 's',
    StringLarge = 'S',
    ObjectSmall = 'o',
    ObjectLarge = 'O',
    ArraySmall = 'a',
    ArrayLarge = 'A',
}

struct Element {
    Type type;
    uint length; //For value types it means the byte length. For container types it is the no. of items 
    immutable(ubyte)[] data; //If you store data manually, you are responsible for bigEndianning it
    
    @property string toString()
    {
        string ret;
        
        final switch(type)
        {
            case Type.Null:
                return "null";
            case Type.True:
                return "true";
            case Type.False:
                return "false";
            case Type.Byte:
                ubyte[1] temp = data[0 .. 1];
                return to!string(bigEndianToNative!(byte)(temp));
            case Type.Int16:
                ubyte[2] temp = data[0 .. $];
                return to!string(bigEndianToNative!(short)(temp));
            case Type.Int32:
                ubyte[4] temp = data[0 .. $];
                return to!string(bigEndianToNative!(int)(temp));
            case Type.Int64:
                ubyte[8] temp = data[0 .. $];
                return to!string(bigEndianToNative!(long)(temp));
            case Type.Float:
                ubyte[4] temp = data[0 .. $];
                return to!string(bigEndianToNative!(float)(temp));
            case Type.Double:
                ubyte[8] temp = data[0 .. $];
                return to!string(bigEndianToNative!(double)(temp));
            
            case Type.StringSmall:
            case Type.StringLarge:
                return "\"" ~ cast(string)data ~ "\"";
                
            case Type.ArraySmall:
            case Type.ArrayLarge:
                return to!string(toElements(data));
                
            case Type.ObjectSmall:    
            case Type.ObjectLarge:
                auto elements = toElements(data);
                return "Object(" ~ to!string(length) ~ ")(" ~ to!string(elements.length) ~ ")";
                
//                string str = "{ ";
//                for(uint i = 0 ; i < length*2; i += 2)
//                {
//                    str ~= elements[i].toString() ~ ":" ~ elements[i + 1].toString(); 
//                }
//                    
//                return str ~ " }";
        }
        
        return "ERROR!";
    }
    
    @property immutable(ubyte)[] bytes()
    {
        immutable(ubyte)[] t;
        t ~= type;
        
        if(data.length > 0)
        {
            if (length > 0)
                if(length < ubyte.max)
                {
                    ubyte[1] l = nativeToBigEndian(cast(ubyte)length);
                    t ~= l[0];
                }
                else
                    t ~= nativeToBigEndian(length).idup;
            
            t ~= data;
        }
        
        return t;
    }
}

Element encode(long value)
{
    Element e = Element();
    
    if (value <= byte.max && value >= byte.min)
    {
        e.type = Type.Byte;
        e.data ~= cast(immutable(byte))value;
    }
    else if(value <= short.max && value >= short.min)
    {
        e.type = Type.Int16;
        e.data = nativeToBigEndian(cast(short)value).idup;
    }
    else if(value <= int.max && value >= int.min)
    {
        e.type = Type.Int32;
        e.data = nativeToBigEndian(cast(int)value).idup;
    }
    else
    {
        e.type = Type.Int64;
        e.data = nativeToBigEndian(value).idup;
    }
    
    return e;
}

Element encode(double value)
{
    Element e = Element();
    
    if(value > float.max)
    {
        e.type = Type.Double;
        e.data = nativeToBigEndian(value).idup;
    }
    else
    {
        e.type = Type.Float;
        e.data = nativeToBigEndian(cast(float)value).idup;
    }   
    
    return e;
}

Element encode(bool value)
{
    Element e = Element();
    e.type = (value) ? Type.True : Type.False;
        
    return e;
}

Element encode(string value)
{
    if(value.length > uint.max)
        throw new Exception("string cannot be larger than " ~ to!string(uint.max));
        
    Element e = Element();
    e.type = (value.length < ubyte.max) ? Type.StringSmall : Type.StringLarge;
    e.length = cast(uint)value.length;
    e.data = cast(immutable(ubyte)[])value;
    
    return e;
}

Element encode(typeof(null))
{
    return Element(Type.Null);
}


/**
 * Given a set of static values, creates an Element type for each
 */
Element[] elements(T...)(T args)
{
    Element[] e;
    foreach(arg; args)
        e ~= encode(arg);
        
    return e;
}


/**
 * Given a set of static values, converts them to bytes in UBJSON format
 */
immutable(ubyte)[] toUBJSON(T...)(T args)
{
    immutable(ubyte)[] bytes;
    foreach(arg; args)
        bytes ~= encode(arg).bytes;
        
    return bytes;
}

Element[] toElements(in immutable(ubyte)[] bytes)
{
    Element[] results;
    
    uint pointer = 0;
    while(pointer < bytes.length)
    {
        char c = bytes[pointer++];
        Element e;
        
        switch(c)
        {
            case Type.Null:
            case Type.True:
            case Type.False:
                e = Element(cast(Type)c);
                break;
                
            case Type.Byte:
                e = Element(cast(Type)c, 0, bytes[pointer .. pointer+1].idup);
                pointer += 1;
                break;
                
            case Type.Int16:
                e = Element(cast(Type)c, 0, bytes[pointer .. pointer+2].idup);
                pointer += 2;
                break;
                
            case Type.Int32:
            case Type.Float:
                e = Element(cast(Type)c, 0, bytes[pointer .. pointer+4].idup);
                pointer += 4;
                break;
                
            case Type.Int64:
            case Type.Double:
                e = Element(cast(Type)c, 0, bytes[pointer .. pointer+8].idup);
                pointer += 8;
                break;
                
            case Type.StringSmall:
                ubyte[1] l = bytes[pointer .. pointer + 1];
                ubyte dl = bigEndianToNative!ubyte(l);
                pointer++; //Increment by size of dl
                e = Element(cast(Type)c, dl, bytes[pointer .. pointer + dl].idup);
                pointer += dl;
                break;
            case Type.StringLarge:
                ubyte size = 4;
                ubyte[4] l = bytes[pointer .. pointer + size];
                uint dl = bigEndianToNative!uint(l);
                pointer += size; //Increment by size of dl
                e = Element(cast(Type)c, dl, bytes[pointer .. pointer + dl].idup);
                pointer += dl;
                break;
                
            //Container types
            case Type.ArraySmall:
            case Type.ObjectSmall:
                ubyte size = 1;
                ubyte[1] l = bytes[pointer .. pointer + size];
                ubyte count = bigEndianToNative!ubyte(l);
                pointer += size;
                e = Element(cast(Type)c,count);
                break;
                
           case Type.ArrayLarge:
           case Type.ObjectLarge:
                ubyte size = 4;
                ubyte[1] l = bytes[pointer .. pointer + size];
                ubyte count = bigEndianToNative!ubyte(l);
                pointer += size;
                e = Element(cast(Type)c,count);
                break;
                
            default:
                throw new Exception("Unsupported type '" ~ c ~ "'");
        }
        
        results ~= e;
    }
    
    return results;
}

unittest
{
    Element ie = encode(int.max);
    ubyte[] encoding = [73, 255, 255, 255, 127];
    assert(ie.bytes == encoding);
    
    Element ar = encode("مرحبا");
    ubyte[] ae = [115, 10, 217, 133, 216, 177, 216, 173, 216, 168, 216, 167];
    assert(ar.bytes == encoding);
    
    Element[] elements = elements(int.max, "مرحبا");
        
    assert(bytes(int.max, "مرحبا") == (ie.bytes ~ ar.bytes));
    assert(bytes(int.max, "مرحبا") == elements.bytes);
    assert(elements.bytes == (ie.bytes ~ ar.bytes));
}