LIB = src/ubjson.d

main:
	rdmd src/example.d $(LIB) -ofexample

#Run unittests
test:
	rdmd --main -unittest $(LIB)

#Compile this utility to print ubj files	
dump:
	dmd src/dump.d $(LIB) -ofdump