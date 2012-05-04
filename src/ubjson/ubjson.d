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
    HugeSmall = 'h',
    HugeLarge = 'H',
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
    immutable(ubyte)[] data;
    
    @property T value(T)()
    {
        //Dont know!
    }
    
    @property ubyte[] bytes()
    {
        ubyte[] t;
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
        e.data = nativeToBigEndian(cast(byte)value).idup;
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
    
    if(value)
        e.type = Type.True;
    else
        e.type = Type.False;
        
    return e;
}

Element encode(string value)
{
    if(value.length > uint.max)
        throw new Exception("string cannot be larger than " ~ to!string(uint.max));
        
    Element e = Element();
    
    if(value.length < ubyte.max)
        e.type = Type.StringSmall;
    else
        e.type = Type.StringLarge;

    e.length = cast(uint)value.length;
    e.data = cast(immutable(ubyte)[])(value.idup);
    
    return e;
}

Element encode(typeof(null))
{
    return Element(Type.Null);
}

Element[] elements(T...)(T args)
{
    Element[] e;
    foreach(arg; args)
        e ~= encode(arg);
        
    return e;
}

immutable(ubyte)[] toUBJSON(T...)(T args)
{
    immutable(ubyte)[] bytes;
    foreach(arg; args)
        bytes ~= encode(arg).bytes;
        
    return bytes;
}

Element[] fromUBJSON(immutable(ubyte)[] bytes)
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
                e = Element(Type.Null);
                break;
            case Type.True:
                e = Element(Type.True);
                break;
            case Type.False:
                e = Element(Type.False);
                break;
            case Type.Byte:
                e = Element(Type.Byte, 0, bytes[pointer .. pointer+1].idup);
                pointer += 1;
                break;
            case Type.Int16:
                e = Element(Type.Int16, 0, bytes[pointer .. pointer+2].idup);
                pointer += 2;
                break;
            case Type.Int32:
                e = Element(Type.Int32, 0, bytes[pointer .. pointer+4].idup);
                pointer += 4;
                break;
            case Type.Int64:
                e = Element(Type.Int64, 0, bytes[pointer .. pointer+8].idup);
                pointer += 8;
                break;
            case Type.Float:
                e = Element(Type.Float, 0, bytes[pointer .. pointer+4].idup);
                pointer += 4;
                break;
            case Type.Double:
                e = Element(Type.Double, 0, bytes[pointer .. pointer+8].idup);
                pointer += 8;
                break;
            case Type.StringSmall:
                ubyte[1] l = bytes[pointer .. pointer + 1];
                ubyte dl = bigEndianToNative!ubyte(l);
                pointer++; //Increment by size of dl
                e = Element(Type.StringSmall, dl, bytes[pointer .. pointer + dl].idup);
                pointer += dl;
                break;
            case Type.StringLarge:
                ubyte size = 4;
                ubyte[4] l = bytes[pointer .. pointer + size];
                uint dl = bigEndianToNative!uint(l);
                pointer += size; //Increment by size of dl
                e = Element(Type.StringLarge, dl, bytes[pointer .. pointer + dl].idup);
                pointer += dl;
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