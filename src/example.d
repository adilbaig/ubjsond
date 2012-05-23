
import std.stdio,
    ubjson
    ;

void main(string[] args)
{
    //Create a decent example showing encoding of static values, and creation of arrays/objects
    //Decode sample values, print them and do type checks
    //Append, delete array values
    //Append, delete object properties
    
    auto e = arrayElement("PHP", "Javascript");
    auto c = arrayElement("Adil", 29, 29.786, e);
    auto o = objectElement("Name", "Adil", "Age", 29, "Score", 289.123);
    
    writeln(c);
    writeln(decode(c.bytes)[0]);
    writeln(o);
    
    auto b = elements(true, int.max, null);
    writeln(b, b[1].value!int, ',', cast(int)b[1]);
}
