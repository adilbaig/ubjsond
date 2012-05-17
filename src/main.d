
import std.stdio,
    ubjson.ubjson
    ;

void main(string[] args)
{
    auto e = array("PHP", "Javascript");
    auto c = array("Adil", 29, 29.786, e);
    auto o = objectElement("Name", "Adil", "Age", 29, "Score", 289.123);
    
    writeln(c);
    writeln(decode(c.bytes)[0]);
    writeln(o);
}