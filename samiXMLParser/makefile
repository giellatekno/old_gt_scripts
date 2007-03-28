
LDFLAGS=-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -arch i386
CC=g++

all: ccat

clean:
	-rm *.o *.gch

ccat: main.o tagfile.o basic.o
	$(CC) -g $(LDFLAGS) -o ccat main.o tagfile.o basic.o tmplcoll.h

main.o: main.cpp
	$(CC) -c -g main.cpp
	
#tagparser: tagfile.o
#	$(CC) -g -o tagparser tagfile.o basic.o tmplcoll.h

tagfile.o: basic.o tagfile.cpp
	$(CC) -c -g tagfile.cpp tmplcoll.h stdafx.h

basic.o: basic.cpp
	$(CC) -c -g basic.cpp

#tmplcoll.o:
#	$(CC) -c -g tmplcoll.h