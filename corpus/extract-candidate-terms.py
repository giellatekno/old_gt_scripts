#!/usr/bin/python
# coding=utf-8
# -*- encoding: utf-8 -*-

import sys, codecs, copy;

sys.stdin  = codecs.getreader('utf-8')(sys.stdin);
sys.stdout = codecs.getwriter('utf-8')(sys.stdout);
sys.stderr = codecs.getwriter('utf-8')(sys.stderr);

threshold = 1.0 ;

if len(sys.argv) < 6: #{
	print 'python extract-candidate-terms.py <lex.e2f> <rfreq in> <rfreq out> <freq in> <freq out>';
	sys.exit(-1);
#}

terms = {};
ut_afreq = {};
in_afreq = {};
ut_relfreq = {};
in_relfreq = {};

f_lex = sys.argv[1];
f_in_relfreq = sys.argv[2];
f_ut_relfreq = sys.argv[3];
f_in_freq = sys.argv[4];
f_ut_freq = sys.argv[5];

for line in file(f_in_freq).read().split('\n'): #{
	if len(line) < 1: #{
		continue;
	#}
	afreq = line.strip().split(' ')[0];
	word = line.strip().split(' ')[1];

	in_afreq[word] = float(afreq);
#}

for line in file(f_ut_freq).read().split('\n'): #{
	if len(line) < 1: #{
		continue;
	#}
	afreq = line.strip().split(' ')[0];
	word = line.strip().split(' ')[1];

	ut_afreq[word] = float(afreq);
#}

for line in file(f_in_relfreq).read().split('\n'): #{
	if len(line) < 1: #{
		continue;
	#}
	rfreq = line.split('\t')[0];
	word = line.split('\t')[1].strip().split(' ')[1];

	in_relfreq[word] = float(rfreq);
#}

for line in file(f_ut_relfreq).read().split('\n'): #{
	if len(line) < 1: #{
		continue;
	#}
	rfreq = line.split('\t')[0];
	word = line.split('\t')[1].strip().split(' ')[1];

	ut_relfreq[word] = float(rfreq);
#}

for line in file(f_lex).read().split('\n'): #{
	if len(line) < 1: #{
		continue;
	#}
	# reindrift<n><m> guohtun<N> 0.0120482
	row = line.split(' ');

	prob = float(row[2]);
	sme_word = row[1];
	nob_word = row[0];

	if sme_word.count('<Prop>') < 1: #{
		sme_word = sme_word.lower();
	#}
	if nob_word.count('<np>') < 1: #{
		nob_word = nob_word.lower();
	#}


	in_freq = 0;
	ut_freq = 0;
	in_rfreq = 0.0;
	ut_rfreq = 0.0;
	
	if nob_word in in_relfreq: #{
		in_rfreq = in_relfreq[nob_word];
	#}
	if nob_word in ut_relfreq: #{
		ut_rfreq = ut_relfreq[nob_word];
	#}
	if nob_word in in_afreq: #{
		in_freq = int(in_afreq[nob_word]);
	#}
	if nob_word in ut_afreq: #{
		ut_freq = int(ut_afreq[nob_word]);
	#}

	valid = 0;
	if line.count('<n>') > 0 and line.count('<N>') > 0: #{
		valid = 1;
	elif line.count('<vblex>') > 0 and line.count('<V>') > 0: #{
		valid = 1;
	elif line.count('<adj>') > 0 and line.count('<A>') > 0: #{
		valid = 1;
	#}

	if valid == 1: #{
		if nob_word not in terms: #{
			terms[nob_word] = [];
		#}
		terms[nob_word].append((in_freq, ut_freq, in_rfreq , ut_rfreq , prob , nob_word , sme_word)); 
	#}
#}

l = terms.keys();
l.sort();

for word in l: #{

	for translation in terms[word]: #{

		print translation[0] , translation[1] , translation[2] , translation[3] , translation[4] , translation[5] , translation[6] ;

	#}

#}
