LIB = source/ubjson.d

main:
	dmd examples/example.d $(LIB) -ofexample
	./example

#Run unittests
test:
	rdmd --main -unittest $(LIB)

#Compile this utility to print ubj files
dump:
	dmd examples/dump.d $(LIB) -ofdump
