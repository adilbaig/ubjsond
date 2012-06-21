# Universal Binary JSON (UBJSON) for D
A high-level library to read and write to the [Universal Binary JSON](http://ubjson.org/ "ubjson.org") (Draft 8) format using native D data types.

##Examples
To encode and decode, is simple :

	immutable(ubyte)[] ubjson = encode(int.max);
	ubjson = encode(int.max, "Hello World!", byte.max, true, null); // This template supports multiple arguments
	Element[] elements = decode(ubjson); // And decode 
	
A more flexible way to create and manipulate ubjson objects is to use the 'elements' template

	Element[] elms = elements("Hello, "World!", int.max); //2 string and an 'int' element 

Create an array of strings
	
	Element tags = arrayElement("D", "Python", "PHP", "Javascript", "C");
	
	assert(tags.length == 5);
	writeln(tags); //["D", "Python", "PHP", "Javascript", "C"]
	tags.remove(2); //Remove "PHP"
	writeln(tags); //["D", "Python", "Javascript", "C"]
	
Create objects	
	
	Element person = objectElement("Name", "Adil", "Age", 29, "Score", 99.15, "Skills", tags); 
	writeln(person); //{Name:"Adil", "Age":29, Score:99.15, Skills:["D", "Python", "Javascript", "C"]}
	
	//What's my name?
	Element name = person["Name"];
    writeln("Name : ", name); // "Name : Adil"
	
Modify an object's attribute	

	person["Name"] = "Batman"; // Assign any value that can be converted to an Element. Doesn't have to be a string
	writeln("Name : ", person["Name"]); // "Name : Batman"

And convert your Element to ubjson 
	
	immutable(ubyte)[] ubjson = person.bytes(); //And finally, convert it to ubjson format 
	
See [example.d](https://github.com/adilbaig/ubjsond/blob/master/src/example.d) for more detailed samples. To run the examples :

	make main

##Run Unittests
	make test
	
All's well that prints nothing!
	
##UBJSON Dumper
This simple utility will dump a file containing ubjson. Some sample files are located in src/resources. To print a dump :  

	make dump
	./dump src/resources/CouchDB4k.ubj

##DMD
Tested with dmd 2.059. Does not have any other dependencies 

##Contributions
I'd be happy to accomodate any patches, documentation or plain better code. To contribute simply fork this repository and send a pull request. Thanks!

Adil Baig<br />[adilbaig.posterous.com](http://adilbaig.posterous.com)
