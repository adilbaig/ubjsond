import 
    std.stdio,
    std.file,
    ubjson
    ;

void main(string[] args)
{
    /**
     Read and print one of the UBJ files. Ex:
    
     ./test resources/CouchDB4k.ubj
    */

    auto bytes = cast(immutable(ubyte)[]) read(args[1]);
    writeln(decode(bytes));
}