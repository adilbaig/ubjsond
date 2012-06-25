# Universal Binary JSON (UBJSON) for D
A high-level library to read and write to the [Universal Binary JSON](http://ubjson.org/ "ubjson.org") (Draft 8) format using native D data types. 

## About UBJSON
JSON has become a ubiquitous text-based file format for data interchange. Its simplicity, ease of processing and (relatively) rich data typing made it a natural choice for many developers needing to store or shuffle data between systems quickly and easy.

In high-performance applications, avoiding the text-processing step of JSON can net big wins in both processing time and size reduction of stored information, which is where a binary JSON format becomes helpful. The existing binary JSON specifications all define incompatibilities or complexities that undo the singular tenant that made JSON so successful: simplicity.

UBJSON for D provides absolute compatibility with the JSON spec itself as well as only utilizing data types that are natively supported by D.

## Salient Features
- Read-optimized format for high performance parsing
- 30% lossless size reduction vs JSON, on average
- 100% compatible with JSON
- Binary data is readable (no compression)
- Simple

## Suggested use cases
- An inter/intra process data exchange protocol
- Binary RPC
- Base level format for CouchDB ;)
- Serialized JSON to files
- Anywhere you would have used JSON!

## Usage
To encode and decode is dead simple :

	immutable(ubyte)[] ubjson = encode(int.max);
	Element[] elements = decode(ubjson); 

'encode' is variable-arguments template that can be called with multiple types.

	immutable(ubyte)[] ubjson = encode(int.max, "Hello World!", byte.max, true, null);  

Encoding to bytes is simple but not enough for idiomatic data manipulation. A better way to create and manipulate ubjson values is to use the 'elements' template

	Element[] elms = elements("Hello, "World!", int.max); //2 string and an 'int' element 

### An Element
An 'Element' struct represents a value. This could be a static value type (ex: int, bool, string) or a container (array, object). The struct allows you to conveniently introspect, manipulate and output the value in its container. With 'Element' you can :
- Get and compare types
- Get the value in its native type (for static types)
- Iterate over values (arrays)
- Use ranges to access and append a subset of child elements (arrays)
- Append, manipulate and remove key-value pairs as associative arrays (objects)
- Print any value as a string
- Output arbitrarily large objects in JSON format 
- Easily convert arbitrarily large containers to ubjson individually.

Here's how you can convert your Element to ubjson 
	
	immutable(ubyte)[] ubjson = person.bytes(); //And finally, convert it to ubjson format 

### Arrays
An array is a sequence of items. Here are some array operations. 
	
	Element tags = arrayElement("D", "Python", "PHP", "Javascript", "C"); //Create an array of strings
	
	assert(tags.length == 5);
	writeln(tags); //["D", "Python", "PHP", "Javascript", "C"]
	
	tags.remove(2); //Remove "PHP"
	writeln(tags); //["D", "Python", "Javascript", "C"]
	
	tags ~= elements("MySQL", "PostgreSql"); // Append tags
	writeln(tags); //["D", "Python", "Javascript", "C", "MySQL", "PostgreSql"]

The arrayElement template supports all the data types used by JSON, including nested containers.

	 Element data = arrayElement("A string", 123, 456.0, true, null, arrayElement("D", "Python", "PHP", "Javascript", "C"));
	
### Objects	
Objects are key-value pairs. The below code creates and queries an object.
	
	Element person = objectElement("Name", "Adil", "Age", 29, "Score", 99.15, "Skills", tags); 
	writeln(person); //{Name:"Adil", "Age":29, Score:99.15, Skills:["D", "Python", "Javascript", "C"]}
	
	//What's my name?
	Element name = person["Name"];
    writeln("Name : ", name); // "Name : Adil"
	
Modify an object's attribute

	person["Name"] = "Batman"; // Assign any value that can be converted to an Element. Doesn't have to be a string
	writeln("Name : ", person["Name"]); // "Name : Batman"

### More examples	
See [example.d](https://github.com/adilbaig/ubjsond/blob/master/src/example.d) for more detailed samples. To run the examples :

	make main

## Running Unit Tests
	make test
	
All's well that prints nothing!
	
## UBJSON Dump Utility
This simple utility will dump a file containing ubjson. Some sample files are located in src/resources. To print a dump :  

	make dump
	./dump src/resources/CouchDB4k.ubj

## D Compiler
Tested only with dmd 2.059. Does not have any other dependencies. 

## What's missing
Streaming support. However, Draft 9 introduces changes that make streaming a natural part of the protocol. Hence streaming will not be supported until Draft 9 is out.

## Contribute to this project
Please download and play with this project. Open tickets for bugs. To contribute code simply fork this repository and send a pull request.
Any thoughts on how to improve the code, documentation, performance and anything else is very welcome.

Adil Baig
<br />Blog : [adilbaig.posterous.com](http://adilbaig.posterous.com)
<br />Twitter : [@aidezigns](http://twitter.com/aidezigns)
