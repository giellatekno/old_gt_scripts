#!/usr/bin/env python3.2
# -*- encoding: utf-8 -*-
import sys ;
 
wordpairs = [
    "áibat,V,áibbašit,V",
    "áitit,V,áiti,N",
    "bassat,V,bassit,V",
    "beassat,V,besset,V",
    "čielgat,V,čilget,V",
    "dassat,V,dat,Pron",
    "doaibmat,V,doaibma,N",
    "dustet,V,duostat,V",
    "eavttuhit,V,eaktu,N",
    "gierdat,V,girdit,V",
    "gullat,V,gullet,V",
    "justit,V,juste,Adv",
    "lihkkat,V,lihkku,N",
    "lihkkat,V,lihkká,Adv",
    "loaktit,V,loktit,V",
    "loaktit,V,loktet,V",
    "mánnat,V,mánná,N",
    "mannet,V,mannat,V",
    "miehtat,V,miehtá,Adv",
    "nuorrat,V,nuorra,A",
    "ollit,V,ollu,Adv",
    "ollásit,V,ollásit,Adv",
    "salastit,V,salla,N",
    "soahpat,V,sohpat,V",
    "vuhttot,V,vuohttut,V",
    "vuhttot,V,vuohttit,V"
]
 
counter = {}
analysisCounter = {}
 
# "<čilget>"         "čielgat" V IV Ind Prs Pl3 @+FMAINV          "čilget" V TV Ind Prs Sg2 @+FMAINV  
 
 
# First we read through every line in the standard input.
 
for line in sys.stdin.readlines(): #{
 
        # For each of the wordpairs in the wordpair list
        for wordpair in wordpairs: #{
                row = wordpair.split(',');     
 
                # Form the two analyses we are looking for.
                analysis1 = row[0] + '+' + row[1]; # e.g. vuhttot+V
                analysis2 = row[2] + '+' + row[3]; # e.g. vuohttit+V
 
                # If we find both analyses in the same line
                if line.count(analysis1) > 0 and line.count(analysis2) > 0: #{
 
                        # If we haven't already seen this wordpair, then initialise the counter
                        if wordpair not in counter: #{
                                counter[wordpair] = 0;
                        #}
                       
                        # Increment the counter by 1
                        counter[wordpair] = counter[wordpair] + 1;
                #}
                
                if analysis1 not in analysisCounter:
                    analysisCounter[analysis1] = 0
                
                if line.count(analysis1) > 0:    
                	analysisCounter[analysis1] = analysisCounter[analysis1] + 1
       
                if analysis2 not in analysisCounter:
                    analysisCounter[analysis2] = 0
                    
                if line.count(analysis2) > 0:
                	analysisCounter[analysis2] = analysisCounter[analysis2] + 1
       
        #}
#}
 
# For all the wordpairs we have seen, print out their values
for wordpair in counter:
	print(wordpair, counter[wordpair]);

print

for analysis in analysisCounter: #{
	if analysisCounter[analysis] > 0:
		print(analysis, analysisCounter[analysis]);
