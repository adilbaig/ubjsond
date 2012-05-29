# Universal Binary JSON (UBJSON) for D
A high-level library to read and write to the [Universal Binary JSON](http://ubjson.org/ "ubjson.org") format using native D data types.

##Examples
To encode and decode, is simple :

	immutable(ubyte)[] ubjson = encode(int.max);
	ubjson = encode(int.max, "Hello World!", byte.max, true, null); // This template supports multiple arguments
	Element[] elements = decode(ubjson); // And decode 
	
A more flexible way to create and manipulate ubjson objects is to use the elements template function

	Element[] elements = elements("Hello, "World!"); //2 string elements 
	
	//Here's an array
	Element tags = arrayElement("D", "Python", "PHP", "Javascript", "C");
	
	assert(tags.length == 5);
	writeln(tags); //["D", "Python", "PHP", "Javascript", "C"]
	tags.remove(2); //Remove "PHP"
	writeln(tags); //["D", "Python", "Javascript", "C"]
	
	//And an Object
	Element person = objectElement("Name", "Adil", "Age", 29, "Score", 99.15, "Skills", tags);
	//What's my name?
	Element name = candidates["Name"];
    writeln("Name : ", name); // "Name : Adil"
	candidates["Name"] = element("Batman");
	writeln("Name : ", candidates["Name"]); // "Name : Batman"
	
See [example.d](https://github.com/adilbaig/ubjsond/blob/master/src/example.d) for more detailed samples

##Run Unittests
	rdmd --main -unittest src/ubjson.d

All's well that prints nothing

##DMD
Tested with dmd 2.059. Does not have any other dependencies 

##Contributions
I'd be happy to accomodate any patches, documentation or plain better code. To contribute simply fork this repository and send a pull request to me. Thanks!

Adil Baig
Benevolent Dictator
[adilbaig.posterous.com](http://adilbaig.posterous.com)