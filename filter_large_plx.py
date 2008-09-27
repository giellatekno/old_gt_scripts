#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import sys

aff_file = open("sme.aff","w")
dic_file = open("sme.dic","w")

def print_intro():
    aff_file.write("""SET UTF-8

FLAG num

Allow hyphens in words
BREAK 1
BREAK -

WORDCHARS -

#compound flags

COMPOUNDBEGIN 63004
COMPOUNDMIDDLE 63010
COMPOUNDEND 63001
COMPOUNDPERMITFLAG 64500
COMPOUNDFORBIDFLAG 63000

COMPOUNDRULE 2
COMPOUNDRULE 64500*63002,63008
COMPOUNDRULE 64500*63003,63009

#PFX 65000 Y 1
#PFX 65000 Y -/64500

SFX 64000 Y 14
SFX 64000 0 naigo . +Clt
SFX 64000 0 goson . +Clt
SFX 64000 0 go . +Clt
SFX 64000 0 ge . +Clt
SFX 64000 0 gen . +Clt
SFX 64000 0 ges . +Clt
SFX 64000 0 gis . +Clt
SFX 64000 0 nai . +Clt
SFX 64000 0 ba . +Clt
SFX 64000 0 be . +Clt
SFX 64000 0 hal . +Clt
SFX 64000 0 han . +Clt
SFX 64000 0 bat . +Clt
SFX 64000 0 son . +Clt

""")


print_intro()

fname = sys.argv[1]
if (fname == '-'):
    infile = sys.stdin
else:
    infile = open(fname)


dic = {}
affdic = {}
afflist = []

for line in infile:
    line = line.split('\t')[0]
    line = unicode(line, 'utf8')
    line = line.replace('#', '')
    line = line.replace(u'»', '')
    line = line.replace('-', '')
    
    parts = line.split('>')
    
    while('' in parts):
	parts.remove('')

    if (parts[0] not in dic):
	dic[parts[0]] = []
    
    partslen = len(parts)

    if partslen > 3:
	parts[2] = "".join(parts[2:])
	parts = parts[0:3]
	
    if partslen > 1:
	for part in parts[1:3]:
	    if (part not in afflist):
		afflist.append(part)
	
	if partslen > 2:
	    if parts[1] not in affdic:
	        affdic[parts[1]] = []
	
	    tmpindex = afflist.index(parts[2])
	    if tmpindex not in affdic[parts[1]]:
		affdic[parts[1]].append(tmpindex)
		    
		
	i = afflist.index(parts[1])
	diclist = dic[parts[0]]
	if (i not in diclist):
	    diclist.append(i)
	    dic[parts[0]] = diclist
	    
dic_file.write(str(len(dic)) + "\n")
for stem, tmplist in dic.iteritems():
    dic_file.write(stem.encode('utf8'))
    if tmplist:
	dic_file.write("/" + ",".join(str(i+1) for i in sorted(tmplist)))
    dic_file.write("\n")

for x, stem in enumerate(afflist):
    aff_file.write("SFX " + str(x+1) + " Y 1\n")
    if stem in affdic:
	aff_file.write("SFX " + str(x+1) + " 0 " + stem.encode('utf8'))
	tmplist = affdic[stem]
	if tmplist:
	      aff_file.write("/" + ",".join(str(i+1) for i in sorted(tmplist)))
	aff_file.write(" .\n\n")
    else:
	aff_file.write("SFX " + str(x+1) + " 0 " + stem.encode('utf8') + " .\n\n")

