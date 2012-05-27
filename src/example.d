/*
 Universal Binary JSON for D
 http://www.ubjson.org

 This high-level library allows you to read and write in UBJSON format using native D static data types.
*/

import 
	std.stdio,
	std.bitmanip,
    ubjson
    ;

void main(string[] args)
{
    /*
    The Element struct represents a single ubjson entity. 
    An entity can be a static value type (int, float, bool etc.) or a container type (array or object)
    The struct stores the type, length and payload where applicable.
    Notice in element 'ei' i am manually bigEndianning the data. When you create an 'Element' manually, you must bigEndian it yourself 
    */
    Element et  = Element(Type.True);
    Element ei  = {type: Type.Int32, data : nativeToBigEndian(int.max).idup}; 
    Element arr = Element(Type.ArraySmall, 2);
    arr.array 	= [et, ei]; //An Array with 2 elements
    
    /*
    And now encode it to ubjson!
    */
    immutable(ubyte)[] ubjson = arr.bytes(); 
    
    //And, get the value back
    int val = ei.value!int();
    bool isTrue = cast(bool)et; //Same as et.value!bool();
    
    /*
    An easier way, is to use the 'elements' template. It will create an Element for each argument,
    with the right type, length and with bigEndianned data where applicable.
    */
    Element[] many = elements("Hello World!");
    many 		  ~= elements(short.max, int.max, double.max, true, null);
    assert(many.length == 6);
    
    //Get the bytes for each element  
    ubjson = [];
    foreach(e ; many)
    	ubjson ~= e.bytes();
    	
	/*
	Here's a simpler way to create an array and an object
	*/
    Element tags 		= arrayElement("D", "Python", "PHP", "Javascript", "C");
    Element person1  	= objectElement("Name", "Adil", "Age", 29, "Score", 99.15, "Distinction", true, "Skills", tags);
    Element person2  	= objectElement("Name", "Andrei", "Age", 43, "Score", 99.16, "Distinction", true, "Skills", arrayElement("C++", "C", "D"));
    Element candidates  = objectElement("Awesome", arrayElement(person1, person2));
    
    //And here's how to append/replace a value in an object
    candidates["Done"] = element(true); 
    candidates.remove("Done");
    
    //See the JSON
    writeln("JSON : ", candidates);
    
    //As expected, calling bytes gets UBJSON for the entire object
    ubjson = candidates.bytes();
    
    //What's my name?
    Element name = candidates["Awesome"][0]["Name"]; //Deeply nested works!
    writeln("Name : ", name);
    
    //What's the first tag?
    auto firstTag = tags[0].value!string();
    writeln("Tag : ", firstTag);
    
    //This will display "ERROR!";
    auto err = candidates["Non existent property!"];
    writeln(err);
    
    //To get a full UBJSON of multiple items, use encode()
    immutable(ubyte)[] ubj = encode("Hello World!", tags);
    writeln(ubj);
}
