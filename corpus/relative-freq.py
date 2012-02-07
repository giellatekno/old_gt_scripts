#!/usr/bin/python
# coding=utf-8
# -*- encoding: utf-8 -*-

import sys, codecs, copy, math;

sys.stdin  = codecs.getreader('utf-8')(sys.stdin);
sys.stdout = codecs.getwriter('utf-8')(sys.stdout);
sys.stderr = codecs.getwriter('utf-8')(sys.stderr);


freq = sys.argv[1];
ffreq = file(freq);
wc = 0.0;
for line in ffreq.read().split('\n'): #{
	row = line.strip().split(' ');
	rfreq = float(row[0] + '.0');
	wc = wc + rfreq;	
#}
ffreq.close();
ffreq = file(freq);

for line in ffreq.read().split('\n'): #{
	if len(line) < 2: #{
		continue;
	#}
	row = line.strip().split(' ');
	freq = float(row[0] + '.0');
	word = row[1];	
	print str(math.log(freq/wc*100.0))[:6] , '\t' , line;
#}
