# Makefile for converting corpus documents
# *****************************************************************
#
# Search documents with changed original- or xsl-file.
# Specify LANGUAGE and GENRE as command line variables.
# GENRE is optional but if LANGUAGE is not given, uses "sme" as
# default.

BOUNDDIR=bound
ORIGDIR=orig
CONVERT2XML=/usr/local/share/corp/bin/convert2xml.pl
LANGUAGE=sme
GENRE=
ifneq ($(GENRE),)
boundfiles=$(shell find $(BOUNDDIR)/$(LANGUAGE)/$(GENRE) -type f)
origdirs=$(shell find $(BOUNDDIR)/$(LANGUAGE)/$(GENRE) -type d)
endif

nullstring :=
space := $(nullstring) # variable now contains a space

.SUFFIXES:

vpath %.xsl,v $(subst $(space),:,$(origdirs))
vpath %.doc $(subst $(space),:,$(origdirs))
vpath %.pdf $(subst $(space),:,$(origdirs))
vpath %.txt $(subst $(space),:,$(origdirs))
vpath %.html $(subst $(space),:,$(origdirs))

all: $(boundfiles)

$(BOUNDDIR)/%.xml: $(ORIGDIR)/% $(ORIGDIR)/%.xsl,v
	$(CONVERT2XML) --lang=$(LANGUAGE) --nolog $<

