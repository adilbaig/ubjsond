
import std.stdio,
    ubjson.ubjson
    ;

void main(string[] args)
{
    auto e = array("PHP", "Javascript");
    auto c = array("Adil", 29, 29.786, e);
    
    writeln(c, decode(c.bytes)[0]);
//    writeln(objectElement("Name", "Adil"));
    
//    e = Element(Type.ObjectSmall, 2, encode("User", "Adil123", "Vitals") ~ e.bytes());
//    writeln(e);
}