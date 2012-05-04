
import std.stdio,
    ubjson.ubjson
    ;

void main(string[] args)
{
    string longstring = std.array.replicate("A", ubyte.max);
    Element ie = encode(int.max);
    Element ar = encode("مرحبا");
    Element ls = encode(longstring);
        
    writeln(bytes(int.max, "مرحبا") == (ie.bytes ~ ar.bytes));
    writeln(fromUBJSON(toUBJSON(true, false, null)));
    
    writeln(ls, ar);
    writeln(fromUBJSON(toUBJSON("مرحبا", longstring, true, "Adil")));
    
}