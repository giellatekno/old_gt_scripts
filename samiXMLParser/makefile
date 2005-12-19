all: ccat

clean:
	-rm *.o *.gch

ccat: main.o tagfile.o basic.o
	g++ -g -o ccat main.o tagfile.o basic.o tmplcoll.h

main.o: main.cpp
	g++ -c -g main.cpp
	
#tagparser: tagfile.o
#	g++ -g -o tagparser tagfile.o basic.o tmplcoll.h

tagfile.o: basic.o tagfile.cpp
	g++ -c -g tagfile.cpp tmplcoll.h stdafx.h

basic.o: basic.cpp
	g++ -c -g basic.cpp

#tmplcoll.o:
#	g++ -c -g tmplcoll.h