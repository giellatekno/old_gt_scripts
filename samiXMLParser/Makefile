CXX=g++
CXXSOURCES = tinymain.cpp tinystr.cpp tinyxml.cpp tinyxmlerror.cpp tinyxmlparser.cpp
CXXOBJECTS = $(CXXSOURCES:.cpp=.o)
PREFIX = /usr/local

all: ccat

clean:
	-rm *.o *~ ccat

ccat: $(CXXOBJECTS)
	$(CXX) -g -o $@ $(LDFLAGS) $(CXXOBJECTS)

install: ccat
	install -m 0755 ccat $(PREFIX)/bin