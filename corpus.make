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

#excluded=eps,jpg,pmb,xls,rtf,indd,psd
boundfiles=$(shell find $(BOUNDDIR)/$(LANGUAGE)/$(GENRE) -type f)
origdirs=$(shell find $(BOUNDDIR)/$(LANGUAGE)/$(GENRE) -type d)
origfiles=$(shell find $(ORIGDIR)/$(LANGUAGE)/$(GENRE) -type f ! -name "*.xsl*" ! -name "*.eps" ! -name "*.bmp" ! -name "*.jpg" ! -name "*.xls" ! -name "*.rtf" ! -name "*.indd" ! -name "*.psd")
missing_bound=$(subst orig,bound,$(patsubst %,%.xml,$(origfiles)))

nullstring :=
space := $(nullstring) # variable now contains a space

.SUFFIXES:

vpath %.xsl,v $(subst $(space),:,$(origdirs))
vpath %.doc $(subst $(space),:,$(origdirs))
vpath %.pdf $(subst $(space),:,$(origdirs))
vpath %.txt $(subst $(space),:,$(origdirs))
vpath %.html $(subst $(space),:,$(origdirs))

all: $(boundfiles) $(missing_bound)

missing: $(missing_bound)

$(BOUNDDIR)/%.xml: $(ORIGDIR)/% $(ORIGDIR)/%.xsl,v
	$(CONVERT2XML) --lang=$(LANGUAGE) --nolog $<

.PRECIOUS: $(ORIGDIR)/%.xsl,v
$(ORIGDIR)/%.xsl,v: $(ORIGDIR)/%
	$(CONVERT2XML) --lang=$(LANGUAGE) --nolog $<
