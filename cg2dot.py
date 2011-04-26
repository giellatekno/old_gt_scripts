#!/usr/bin/python
# coding=utf-8
# -*- encoding: utf-8 -*-

import sys, codecs, copy;

sys.stdin  = codecs.getreader('utf-8')(sys.stdin);
sys.stdout = codecs.getwriter('utf-8')(sys.stdout);
sys.stderr = codecs.getwriter('utf-8')(sys.stderr);

header = """
digraph G {
        graph [ratio=fill];
        graph [center=\"1\"];
        ratio = 0.66;
        edge [arrowsize = 0.8];
        splines = true;
        rankdir = \"BT\";
        node [shape=circle,fixedsize=true,width=0.75];
""";

if len(sys.argv) > 1:
	if sys.argv[1] == '-h':
		print "cat <file> | cg2dot.py";
		sys.exit(-1);


print header;

labels = '';
edges = '';

for line in sys.stdin.read().split('\n'): #{

	if len(line) > 1 and line[0] == '\t': #{
		#print line;

		num = line.split('#')[1].split('->')[0];
		lema = line.split('"')[1] + '\\n' + num;
		labels = labels + '\t' + line.split('->')[0].split('#')[1] + ' [label="' + lema + '"];\n';
		
		func =  '';
		if line.count('@') > 0: #{
			func = '@' + line.split('@')[1].split(' ')[0];
		#}
		if func != '': #{
			edges = edges + '\t' + line.split('#')[1] + ' [label="' + func + '"];\n';
		else: #{
			edges = edges + '\t' + line.split('#')[1] + ';\n';
		#}
	else: #{
		continue;
	#}
#}

print labels;
print edges;
print '}';
