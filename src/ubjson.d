module ubjson;

private import std.bitmanip;
//private import std.stdio : writeln;
private import std.conv : to;
private import std.array : join;


enum Type : char {
    Error = 'e',
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
    
    /**
     * For value types it means the byte length. 
     * For arrays it means the no. of elements in the array.
     * For objects it means the number of key-value pairs.
    */
    uint length;  
    
    union {
        immutable(ubyte)[] data; //If this data if filled manually, you are responsible for bigEndianning it
        Element[] array;
        Element[string] object; //Use this for objects
    }
    
    /**
     * Get the value stored in this Element. 
     */
    T value(T)()
    {
        static if(is(T == bool))
        {
            if(!(type == Type.True || type == Type.False))
                throw new IncompatibleCastException("Cannot convert " ~ type ~ " to a boolean");
                
            return (type == Type.True);
        }
        else static if(is(T == byte)){
            if(type != Type.Byte)
                throw new IncompatibleCastException("Cannot convert " ~ type ~ " to a byte");
            
            ubyte[1] temp = data;
            return bigEndianToNative!(byte)(temp);
        }
        else static if(is(T == short)){
            if(type != Type.Int16)
                throw new IncompatibleCastException("Cannot convert " ~ type ~ " to a short");
            
            ubyte[2] temp = data;
            return bigEndianToNative!(short)(temp);
        }
        else static if(is(T == int)){
            if(type != Type.Int32)
                throw new IncompatibleCastException("Cannot convert " ~ type ~ " to an int");
            
            ubyte[4] temp = data;
            return bigEndianToNative!(int)(temp);
        }
        else static if(is(T == long))
        {
            if(type != Type.Int64)
                throw new IncompatibleCastException("Cannot convert " ~ type ~ " to a long");

            ubyte[8] temp = data;
            return bigEndianToNative!(long)(temp);
        }
        else static if(is(T == float))
        {
            if(type != Type.Float)
                throw new IncompatibleCastException("Cannot convert " ~ type ~ " to a float");

            ubyte[4] temp = data;
            return bigEndianToNative!(float)(temp);
        }
        else static if(is(T == double))
        {
            if(type != Type.Double)
                throw new IncompatibleCastException("Cannot convert " ~ type ~ " to a double");

            ubyte[8] temp = data;
            return bigEndianToNative!(double)(temp);
        }
        else static if(is(T == string))
        {
            return toString();
        }
    }
    
    @property string toString()
    {
        string ret;
        
        switch(type)
        {
        	case Type.Null:
                return "null";
            case Type.True:
                return "true";
            case Type.False:
                return "false";
            case Type.Byte:
                ubyte[1] temp = data;
                return to!string(bigEndianToNative!(byte)(temp));
            case Type.Int16:
                ubyte[2] temp = data;
                return to!string(bigEndianToNative!(short)(temp));
            case Type.Int32:
                ubyte[4] temp = data;
                return to!string(bigEndianToNative!(int)(temp));
            case Type.Int64:
                ubyte[8] temp = data;
                return to!string(bigEndianToNative!(long)(temp));
            case Type.Float:
                ubyte[4] temp = data;
                return to!string(bigEndianToNative!(float)(temp));
            case Type.Double:
                ubyte[8] temp = data;
                return to!string(bigEndianToNative!(double)(temp));
            
            case Type.HugeSmall:
            case Type.HugeLarge:
                return cast(string)data;
            
            case Type.StringSmall:
            case Type.StringLarge:
                return cast(string)data;
                
            case Type.ArraySmall:
            case Type.ArrayLarge:
                
                string[] arr;
                foreach(val; array)
                    if(val.type == Type.StringSmall 
                    	|| val.type == Type.StringLarge
                    	)
                    	arr ~= "\"" ~ val.toString() ~ "\"";
                	else
                    	arr ~= val.toString();
                
                return "[" ~ join(arr, ", ") ~ "]";
                
            case Type.ObjectSmall:    
            case Type.ObjectLarge:
            
                string[] pairs;
                for(uint i = 0; i < data.length; i += 2)
                {
                    auto key   = array[i].toString();
                    Element val = array[i + 1];
                    string value;
                     
                    if(val.type == Type.StringSmall 
                    	|| val.type == Type.StringLarge
                    	)
                    	value = "\"" ~ val.toString() ~ "\"";
                	else
                    	value = val.toString();
                    	
                    pairs ~= (key ~ ":" ~ value);
                }
                
                return "{" ~ join(pairs, ", ") ~ "}";
                
            default :
            	return "ERROR!";
        }
    }
    
    @property immutable(ubyte)[] bytes() 
    {
        immutable(ubyte)[] t;
        t ~= type;
        
        if (length > 0)
            if(length < ubyte.max)
            {
                ubyte[1] l = nativeToBigEndian(cast(ubyte)length);
                t ~= l[0];
            }
            else
                t ~= nativeToBigEndian(length).idup;

        if(type == Type.ArraySmall 
            || type == Type.ArrayLarge
            || type == Type.ObjectSmall 
            || type == Type.ObjectLarge
            )
            foreach(a; array)
                t ~= a.bytes();
        else if(data.length > 0)
            t ~= data;
        
        return t;
    }
    
    @property bool isNull()
    {
        return (type == Type.Null);
    }
    
    @property bool isArray()
    {
        return (type == Type.ArraySmall || type == Type.ArrayLarge);
    } 
    
    @property bool isObject()
    {
        return (type == Type.ObjectSmall || type == Type.ObjectLarge);
    }
    
    @property bool isContainer()
    {
        return (isObject() || isArray());
    } 
    
    int opEquals(ref Element e) 
    {
        return (e.bytes() == bytes());
    }
    
    T opCast(T)() { return value!T; }

    //For arrays
//    ulong opDollar() //Not implemented by D compiler yet
//    {
//        assert(isArray(),"Not an array");
//            
//        return array.length;
//    }
    
    //For arrays
    Element opIndex(uint index)
    {
    	assert(isArray(),"Not an array");
    		
		return array[index];
    }
    
    //For arrays
    void opIndexAssign(Element e, int index)
    {
        assert(isArray(),"Not an array");
            
        array[index] = e;
        length = cast(uint)array.length;
    }
    
    //For arrays
    Element[] opSlice(int start, int end)
    {
    	assert(isArray(),"Not an array");
    	
        return array[start .. end];
    }
    
    //For objects
    Element opIndex(string key)
    {
    	assert(isObject(),"Not an object");
    		
		foreach(i, val; array)
			if(val.toString == key)
				return array[i + 1];
				
		return Element(Type.Error);
    }

    //For objects
    void opIndexAssign(Element e, string key)
    {
        assert(isObject(),"Not an object");
            
        foreach(i, val; array)
            if(val.toString == key)
            {
                array[i + 1] = e;
                return;
            }   
            
        array ~= elements(key, e);
        length = cast(uint)array.length / 2;
    }
    
    bool remove(int index)
    {
        assert(isArray(),"Not an array");

        if(array.length < index)
            return false;
            
        array = std.algorithm.remove(array, index);
        length--;
        return true;
    }
    
    bool remove(string key)
    {
        assert(isObject(),"Not an object");

        int pos = -1;
        foreach(i, element; array)
            if(element.toString() == key && i % 2 == 0)
                pos = cast(int)i;
                
        if(pos < 0)
            return false;
        
        std.algorithm.remove(array, pos, pos+1);
        length--;
        return true;
    }
}

class IncompatibleCastException : Exception
{
    this(string message){ super(message); }
}

/**
 * Given a variable set of parameters encodes the data to Element[].
 * Args can be : strings, integers, floats, bools, nulls or Elements
 */
Element[] elements(T...)(T args)
{
    Element[] e;
    foreach(a; args)
        e ~= toElement(a);
       
    return e;
}

/**
 * @see elements
 */
Element element(T)(T arg)
{
    return toElement(arg);
}

/**
 * Given a variable set of parameters encodes the data to UBJSON format.
 * Args can be anything that can be decoded by elements()
 */
immutable(ubyte)[] encode(T...)(T args)
{
    immutable(ubyte)[] bytes;
    
    Element[] elements = elements(args);
    foreach(e; elements)
        bytes ~= e.bytes;
        
    return bytes;
}

/**
 * Decodes UBJSON ubytes[] into Element[]
 */ 
Element[] decode(in immutable(ubyte)[] bytes)
{
    Element[] results;
    
    uint pointer = 0;
    while(pointer < bytes.length)
    {
        Element e = toElement(bytes[pointer .. $]);
        pointer += e.length.sizeof + e.bytes().length + 1; //e.bytes is expensive. All we need is a pointer to the next item
        results ~= e;
    }
    
    return results;
}

/**
 * Creates a UBJSON array (Element) from the given args.
 * Args can be anything that can be decoded by elements
 */
Element arrayElement(T...)(T args)
{
    Element[] elements = elements(args);
        
    auto e = Element((elements.length <= ubyte.max) ? Type.ArraySmall : Type.ArrayLarge, cast(uint)elements.length);
    e.array = elements;
    
    return e; 
}

/**
 * Creates a UBJSON Object (Element) from the given args.
 * Args can be anything that can be decoded by elements
 */
Element objectElement(T...)(T args)
{
    if(args.length % 2 > 0)
        throw new Exception("Object is incomplete");
    
    Element[] elements = elements(args);
        
    auto l =  cast(uint)elements.length/2;
    auto e = Element((l <= ubyte.max) ? Type.ObjectSmall : Type.ObjectLarge, l);
    e.array = elements;
    
    return e;
}

private :
    
    /**
     * Decodes a ubyte[] to an Element
     */
    Element toElement(in immutable(ubyte)[] bytes)
    {
        if(!bytes.length)
            return Element(Type.Error);
            
        int pointer = 0;
        char c = bytes[pointer++];
        
        switch(c)
        {
            case Type.Null:
            case Type.True:
            case Type.False:
                return Element(cast(Type)c);
                
            case Type.Byte:
                return Element(cast(Type)c, 0, bytes[pointer .. pointer+1].idup);

            case Type.Int16:
                return Element(cast(Type)c, 0, bytes[pointer .. pointer+2].idup);
                
            case Type.Int32:
            case Type.Float:
                return Element(cast(Type)c, 0, bytes[pointer .. pointer+4].idup);
                
            case Type.Int64:
            case Type.Double:
                return Element(cast(Type)c, 0, bytes[pointer .. pointer+8].idup);
            
            case Type.HugeSmall:    
            case Type.StringSmall:
                ubyte l = bytes[pointer .. pointer + 1][0];
                pointer++;
                return Element(cast(Type)c, l, bytes[pointer .. pointer + l].idup);
                
            case Type.HugeLarge:
            case Type.StringLarge:
                ubyte size = 4;
                ubyte[4] l = bytes[ pointer .. pointer + size];
                uint dl = bigEndianToNative!uint(l);
                pointer += size; //Increment by size of dl
                return Element(cast(Type)c, dl, bytes[pointer .. pointer + dl].idup);
                
                //Container types
            case Type.ArraySmall:
            case Type.ArrayLarge:
                
                ubyte size = 1;
                uint count = bytes[pointer .. pointer + size][0];
                
                if(c == Type.ArrayLarge)
                {
                    size = 4;
                    ubyte[4] l = bytes[pointer .. pointer + size];
                    count = bigEndianToNative!uint(l);
                }
                
                pointer += size;
                auto e = Element(cast(Type)c, count);
            
                for(uint i = 0; i < count; i++)
                {
                    auto te = toElement(bytes[pointer .. $]);
                    pointer += te.bytes.length;
                    e.array ~= te;
                }
                   
                return e;
            
            case Type.ObjectSmall:
            case Type.ObjectLarge:
            
                ubyte size = 1;
                uint count = bytes[pointer .. pointer + size][0];
                
                if(c == Type.ObjectLarge)
                {
                    size = 4;
                    ubyte[4] l = bytes[pointer .. pointer + size];
                    count = bigEndianToNative!uint(l);
                }
                
                pointer += size;
                auto e = Element(cast(Type)c, count);
                
                for(uint i = 0; i < count*2; i++)
                {
                    auto te = toElement(bytes[pointer .. $]);
                    pointer += te.bytes.length;
                    e.array ~= te;
                }
                   
                return e;
                
            default:
                throw new Exception("Unsupported type '" ~ c ~ "'");
        }
    }
    
    Element toElement(long value)
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
    
    Element toElement(double value)
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
    
    Element toElement(bool value)
    {
        Element e = Element();
        e.type = (value) ? Type.True : Type.False;
            
        return e;
    }
    
    Element toElement(string value)
    {
        if(value.length > uint.max)
            throw new Exception("string cannot be larger than " ~ to!string(uint.max));
            
        Element e = Element();
        e.type    = (value.length < ubyte.max) ? Type.StringSmall : Type.StringLarge;
        e.length  = cast(uint)value.length;
        e.data    = cast(immutable(ubyte)[])value;
        
        return e;
    }
    
    Element toElement(typeof(null))
    {
        return Element(Type.Null);
    }

    Element toElement(Element e)
    {
        return e;
    }

unittest
{
    auto e = Element(Type.Null);
    assert(e.bytes == [cast(byte)'Z']);
    assert(e.bytes == encode(null));
    
    e = Element(Type.True);
    assert(e.bytes == [cast(byte)'T']);
    assert(e.bytes == encode(true));
    
    e = Element(Type.False);
    assert(e.bytes == [cast(byte)'F']);
    assert(e.bytes == encode(false));
    
    e = Element(Type.Byte, byte.max);
    assert(e.bytes == [cast(byte)'B', byte.max]);
    assert(e.bytes == encode(byte.max));
    
    e = Element(Type.Int16);
    e.data = nativeToBigEndian(short.max);
    assert(e.bytes == [cast(byte)'i', 127, 255]);
    assert(e.bytes == encode(short.max));
    
    e = Element(Type.Int32);
    e.data = nativeToBigEndian(int.max);
    assert(e.bytes == [cast(byte)'I', 127, 255, 255, 255]);
    assert(e.bytes == encode(int.max));
    
    e = Element(Type.Int64);
    e.data = nativeToBigEndian(long.max);
    assert(e.bytes == [cast(byte)'L', 127, 255, 255, 255, 255, 255, 255, 255]);
    assert(e.bytes == encode(long.max));
    
    e = Element(Type.Float);
    e.data = nativeToBigEndian(float.max);
    assert(e.bytes == [cast(byte)'d', 127, 127, 255, 255]);
    assert(e.bytes == encode(float.max));
    
    e = Element(Type.Double);
    e.data = nativeToBigEndian(double.max);
    assert(e.bytes == [cast(byte)'D', 127, 239, 255, 255, 255, 255, 255, 255]);
    assert(e.bytes == encode(double.max));
    
    e = Element(Type.StringSmall, 10);
    e.data = cast(immutable(ubyte)[])"مرحبا";
    ubyte[] ae = [cast(byte)'s', 10, 217, 133, 216, 177, 216, 173, 216, 168, 216, 167];
    assert(e.bytes == ae);
    assert(e.bytes == encode("مرحبا"));
    
    e = Element(Type.ArraySmall, 2);
    e.array ~= elements(byte.max);
    e.array ~= elements(int.max);
    assert(e.bytes == arrayElement(byte.max, int.max).bytes);
    assert(e.bytes.length == 2 + 2 + 5); //2 for array, 2 for byte and 5 for int
    assert(e[0 .. 2] == elements(byte.max,int.max)); //Comparing arrays of Elements

    e.remove(5); //Remove an element that doesn't exist and ..
    assert(e.length == 2); //.. the length doesn't change
    e.remove(0); //Remove an element that does exist and ..
    assert(e.length == 1); // .. it's updated

    e = Element(Type.ObjectSmall, 1);
    e.array ~= elements("Name");
    e.array ~= elements("Adil Baig");
    assert(e.bytes == objectElement("Name", "Adil Baig").bytes);
    e.remove("Name");
    assert(e.length == 0); 
    
    e = Element(Type.ObjectLarge, 256);
    for(uint i = 0; i < 256; i++)
        e.array ~= elements("Inc", 1);
    assert(e.bytes.length == 1 + 4 + (elements("Inc")[0].bytes.length * 256) + (elements(1)[0].bytes.length * 256));
    
    //Type checking
    e = Element(Type.Int32);
    e.data = nativeToBigEndian(int.max);
    assert(is(typeof(e.value!int()) == int));

}
