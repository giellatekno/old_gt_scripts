# Makefile for converting corpus documents
# *****************************************************************


#BOUNDDIR=/home/saara/samipdf/bound
#ORIGDIR=/home/saara/samipdf/orig
BOUNDDIR=bound
ORIGDIR=orig
CONVERT2XML=/home/saara/gt/script/convert2xml.pl
LANGUAGE=sme
GENRE=facta
boundfiles=$(shell find $(BOUNDDIR)/$(LANGUAGE)/$(GENRE) -type f)
origdirs=$(shell find $(BOUNDDIR)/$(LANGUAGE)/$(GENRE) -type d)

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
