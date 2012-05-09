
import std.stdio,
    ubjson.ubjson
    ;

void main(string[] args)
{
    string longstring = std.array.replicate("A", ubyte.max);
    Element ie = encode(int.max);
    Element ar = encode("مرحبا");
    Element ls = encode(longstring);
        
    writeln(toUBJSON(int.max, "مرحبا") == (ie.bytes ~ ar.bytes));
    writeln(toElements(toUBJSON(true, false, null)));
    
    writeln(ls, ar);
    writeln(toElements(toUBJSON("مرحبا", longstring, true, "Adil")));
    
    auto e = Element(Type.ArraySmall, 3, toUBJSON("Adil", 29, 29.786));
    writeln(e);
    
    e = Element(Type.ObjectSmall, 2, toUBJSON("User", "Adil123", "Vitals") ~ e.bytes());
    writeln(e);
}