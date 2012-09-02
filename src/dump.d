import 
    std.stdio,
    std.file,
    ubjson
    ;

void usage()
{
    writeln("./dump <path to ubj file>\n
This utility dumps a ubj file");
}

void main(string[] args)
{
    if(args.length < 1)
        return usage();
        
    /**
     Read and print one of the UBJ files. Ex:
    
     ./dump resources/CouchDB4k.ubj
    */

    auto bytes = cast(immutable(ubyte)[]) read(args[1]);
    writeln(bytes);
    writeln(decode(bytes));
}