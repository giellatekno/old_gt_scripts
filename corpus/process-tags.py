#!/usr/bin/python
# coding=utf-8
# -*- encoding: utf-8 -*-

import sys, codecs, copy;

sys.stdin  = codecs.getreader('utf-8')(sys.stdin);
sys.stdout = codecs.getwriter('utf-8')(sys.stdout);
sys.stderr = codecs.getwriter('utf-8')(sys.stderr);

GENLIST = 0;
lemma_stoplist = ['(', ')', ',', '[', ']', ':', '.', ';', '&', '..', '...'];
tag_table = {};

if len(sys.argv) > 1: #{
	for line in file(sys.argv[1]).read().split('\n'): #{
		if line.count('\t') < 1: #{
			continue;
		#}
		row = line.split('\t');
	
		tag_table[row[0]] = row[1];
	#}
else: #{
	GENLIST = 1;
#}

def processWord(c): #{
	lemma = '';
	tags = '';
	state = 0;

	c = sys.stdin.read(1);
	while c != '$': #{
		if state == 0: #{
			lemma = lemma + c;
		elif state == 1: #{
			tags = tags + c;
		#}

		c = sys.stdin.read(1);

		if c == '+': #{
			tags = '';
			state = 0;
		elif c == '<': #{
			state = 1;
		#}
	#}
	
	if GENLIST == 1: #{
		sys.stderr.write(lemma + "\t" + tags + "\n");
	else: #{
		if lemma not in lemma_stoplist: #{
			if tags in tag_table: #{
				sys.stdout.write(lemma.replace(' ', '_') + tag_table[tags] + ' ');
			else: #{
				sys.stdout.write(lemma.replace(' ', '_') + tags + ' ');
			#}
		#}
	#}
#}


c = sys.stdin.read(1);
while c: #{
	# Beginning of a lexical unit
	if c == '^': #{
		processWord(c);
		sys.stdout.flush();
	#}

	# Newline is newline
	if c == '\n': #{
		sys.stdout.write('\n');
	#}

	c = sys.stdin.read(1);
#}


