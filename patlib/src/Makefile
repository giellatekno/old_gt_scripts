# This is Makefile to create patlib, pattern manipulating library
# CVS Id:
# $Id: Makefile,v 1.15 2001/12/02 14:30:01 antos Exp $

# The `all' taget builds all in debugging mode. The `ox' targets for x =
# 1,2,3 build all with optimizations.
# The printed source is always generated in dvi and PostScript.

CPP=g++
CFLAGS=-ansi -Wall

### COMPILING ###
# By default we compile for debugging
.PHONY:		all
all:		CFLAGS += -g
all:		build

# With o<x> we optimize a lot, note this _does_ make compilation slow
.PHONY:		o1 o2 o3
o1:		CFLAGS += -O1
o1:		build
o2:		CFLAGS += -O2
o2:		build
o3:		CFLAGS += -O3
o3:		build

# By default we use only the ``plain'' cweb printing
.PHONY:		build
build:		opatgen opatgen.ps patlib.ps

DOT_H_FILES =   ptl_exc.h  ptl_gen.h   ptl_mopm.h  ptl_tpm.h \
                ptl_ga.h   ptl_hwrd.h  ptl_sts.h   ptl_vers.h

opatgen:	$(DOT_H_FILES) opatgen.c
		$(CPP) $(CFLAGS) -o opatgen opatgen.c

opatgen.c:	opatgen.w
		$(CTANGLE) $<

$(DOT_H_FILES):	patlib.w
		$(CTANGLE) $<

### PRINTING ####
# Ordinary printing
patlib.ps:	patlib.dvi
		dvips patlib.dvi -o patlib.ps

patlib.dvi:	patlib.tex
		tex patlib

patlib.tex:	patlib.w
		cweave patlib

opatgen.ps:	opatgen.dvi
		dvips opatgen.dvi -o opatgen.ps

opatgen.dvi:	opatgen.tex
		tex opatgen

opatgen.tex:	opatgen.w
		cweave opatgen

### MISC ########
.PHONY:		clean_h
clean_h:
		-rm $(DOT_H_FILES)

### WORK ########
.PHONY:		session
session:	patlib.dvi opatgen.dvi
		xdvi patlib&
		xdvi opatgen&
		#ddd opatgen&

