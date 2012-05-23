
import std.stdio,
    ubjson.ubjson
    ;

void main(string[] args)
{
    auto e = arrayElement("PHP", "Javascript");
    auto c = arrayElement("Adil", 29, 29.786, e);
    auto o = objectElement("Name", "Adil", "Age", 29, "Score", 289.123);
    
    writeln(c);
    writeln(decode(c.bytes)[0]);
    writeln(o);
    
    auto b = elements(true, int.max, null);
    writeln(b, b[1].value!int, ',', cast(int)b[1]);
}