CXX=g++
CXXHEADERS = globalstate.h divvunparser.h
CXXSOURCES = tinymain.cpp tinystr.cpp tinyxml.cpp tinyxmlerror.cpp tinyxmlparser.cpp divvunparser.cpp globalstate.cpp
CXXOBJECTS = $(CXXSOURCES:.cpp=.o)
PREFIX = /usr/local

all: ccat

clean:
	-rm -f *.o *~ ccat

ccat: $(CXXOBJECTS) $(CXXHEADERS)
	$(CXX) -g -o $@ $(LDFLAGS) $(CXXOBJECTS)

install: ccat
	install -m 0755 -d $(PREFIX)/bin
	install -m 0755 ccat $(PREFIX)/bin
