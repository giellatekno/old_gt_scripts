#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-

# HfstTester.py 1.0 - Copyright (c) 2011 
# Brendan Molloy <brendan@bbqsrc.net>
# Licensed under Creative Commons Zero (CC0)

# Taken from:
# http://apertium.svn.sourceforge.net/svnroot/apertium/incubator/apertium-tgl-ceb/dev/verbs/HfstTester.py@28665
# Copied into the GT svn instead of just referenced, since file externals don't work for
# foreign repositories.

# TODO:
# - create Rules: {} for JSON, to make parsing more dynamic 
# - make WHY it failed much more clear.

import sys
if sys.hexversion < 0x02070000:
	print "You must use Python 2.7 or greater."
	sys.exit(255)

from subprocess import *
import os, argparse, json, yaml

def s2l(thing):
	if type(thing) in (str, unicode):
		return [thing]
	elif type(thing) in (list, tuple):
		return thing
	return None

def l2s(thing):
	if type(thing) in (str, unicode):
		return thing
	elif type(thing) in (list, tuple):
		if len(thing) > 1:
			return thing #bail out!
		else:
			return thing[0]
	return None

def colourise(string, opt=None):
	def red(s="", r="\033[m"):
		return "\033[1;31m%s%s" % (s, r) 
	def green(s="", r="\033[m"):
		return "\033[0;32m%s%s" % (s, r) 
	def orange(s="", r="\033[m"):
		return "\033[0;33m%s%s" % (s, r) 
	def yellow(s="", r="\033[m"):
		return "\033[1;33m%s%s" % (s, r) 
	def blue(s="", r="\033[m"):
		return "\033[0;34m%s%s" % (s, r) 
	def light_blue(s="", r="\033[m"):
		return "\033[0;36m%s%s" % (s, r) 
	def reset(s=""):
		return "\033[m%s" % s

	if not opt:
		x = string.replace('+', '+')
		x = x.replace("=>", blue("=>"))
		x = x.replace("<=", blue("<="))
		x = x.replace(":", blue(":"))
		x = x.replace("[PASS]", green("[PASS]"))
		x = x.replace("[FAIL]", red("[FAIL]"))
		return x
	
	elif opt == 1:
		return yellow(string)

	elif opt == 2:
		x = string.replace('Passes: ', 'Passes: %s' % green(r=""))
		x = x.replace('Fails: ', 'Fails: %s' % red(r=""))
		x = x.replace(', ', reset(', '))
		x = x.replace('Total: ', 'Total: %s' % yellow(r=""))
		return "%s%s" % (x, reset())

def whereis(program):
    for path in os.environ.get('PATH', '').split(':'):
        if os.path.exists(os.path.join(path, program)) and \
           not os.path.isdir(os.path.join(path, program)):
            return os.path.join(path, program)
    return None

class HfstTester:
	def __init__(self):
		self.fails = 0
		self.count = []

		argparser = argparse.ArgumentParser(
			description="Test morphological transducers for consistency. `hfst-lookup` (or Xerox' `lookup` with argument -x) must be available on the PATH.",
			epilog="Will run all tests in the test_file by default."
			)
		argparser.add_argument("-c", "--colour",
			dest="colour", action="store_true",
			help="Colours the output")
		argparser.add_argument("-i", "--ignore_extra_analyses",
			dest="ignore_extra_analyses", action="store_true",
			help="Ignore extra analyses when there are more than one, will FAIL only if all are wrong.")
		argparser.add_argument("-s", "--surface",
			dest="surface", action="store_true",
			help="Surface input/analysis tests only")
		argparser.add_argument("-l", "--lexical",
			dest="lexical", action="store_true",
			help="Lexical input/generation tests only")
		argparser.add_argument("-f", "--no-pass",
			dest="hide_pass", action="store_true",
			help="Suppresses passes to make finding failures easier")
		argparser.add_argument("-p", "--no-fail",
			dest="hide_fail", action="store_true",
			help="Suppresses failures to make finding passes easier")
		argparser.add_argument("-x", "--xerox",
			dest="xerox", action="store_true",
			required=False, help="Use the Xerox `lookup` tool (default is `hfst_lookup`)")
		argparser.add_argument("-t", "--test",
			dest="test", nargs=1, required=False,
			help="Which test to run (Default: all). TEST = test ID, e.g. 'Noun - gåetie'")
		argparser.add_argument("test_file", nargs=1,
			help="YAML/JSON file with test rules")
		self.args = argparser.parse_args()
		

		try:
			f = yaml.load(open(self.args.test_file[0]))
		except:
			try:
				f = json.load(open(self.args.test_file[0]))
			except Exception, e:
				print "File not valid YAML or JSON. Bailing out."
				print "Check your YAML for spurious hidden tabs."
				sys.exit(1)

		if self.args.xerox:
			print "Testing Xerox FST dictionaries"
			configkey = "xerox"
			self.program = "lookup"
		else:
			print "Testing Helsinki FST dictionaries"
			configkey = "hfst"
			self.program = "hfst-lookup"
			
		if not whereis(self.program):
			print "Cannot find %s. Check $PATH." % self.program
			sys.exit(1)

		self.gen = f["Config"][configkey]["Gen"]
		self.morph = f["Config"][configkey]["Morph"]
		for i in (self.gen, self.morph):
			if not os.path.isfile(i):
				print "File %s does not exist." % i
				sys.exit(2)
		self.tests = f["Tests"]
		self.run_tests(self.args.test)
		print "Total fails", self.fails
	
	def c(self, s, o=None):
		if self.args.colour:
			return colourise(s, o)
		return s

	def run_tests(self, input=None):
		if self.args.surface == self.args.lexical == False:
			self.args.surface = self.args.lexical = True
		
		if(input != None):
			if self.args.lexical: self.run_lexical_test(input[0])
			if self.args.surface: self.run_surface_test(input[0])
		
		else:
			for t in self.tests.keys():
				if self.args.lexical: self.run_lexical_test(t)
				if self.args.surface: self.run_surface_test(t)

	def run_surface_test(self, input):
		c = len(self.count)
		self.count.append([0, 0])

		title = "Test %d: %s (Surface/Analysis)" % (c, input)
		print self.c("-"*len(title), 1).encode('utf-8')
		print self.c(title, 1).encode('utf-8')
		print self.c("-"*len(title), 1).encode('utf-8')

		for l in self.tests[input].keys():
			sforms = s2l(self.tests[input][l])
			lexors = []
			for s in sforms:
				for i in self.tests[input].keys():
					if s in s2l(self.tests[input][i]):
						lexors.append(i)

			for sform in sforms:
				#print 
				p1 = Popen(['echo', sform], stdout=PIPE)
				p2 = Popen([self.program, self.morph], stdin=p1.stdout, stdout=PIPE, stderr=PIPE)
				p1.stdout.close()
				(res, err) = p2.communicate()
				lexes = self.parse_fst_output(res.decode('utf-8'))
				#print lexes
				#print "\nl", l, "sform", sform, "res", res
				if self.args.ignore_extra_analyses:
					if l in lexes:
						print self.c("[PASS] %s => %s" % (sform, l)).encode('utf-8')
						self.count[c][0] += 1
					else:
						for lex in lexes:
							if not lex in lexors:
								if not self.args.hide_fail:
									print self.c("[FAIL] %s => Expected: %s, Got: %s" % (sform, l, lex)).encode('utf-8')
								self.count[c][1] += 1
				else:
					for lex in lexes:
						if lex in lexors:
							if not self.args.hide_pass:
								print self.c("[PASS] %s => %s" % (sform, lex)).encode('utf-8')
							self.count[c][0] += 1
						else:
							if not self.args.hide_fail:
								print self.c("[FAIL] %s => Expected: %s, Got: %s" % (sform, l, lex)).encode('utf-8')
							self.count[c][1] += 1
		print self.c("Test %d - Passes: %d, Fails: %d, Total: %d\n" % (c, self.count[c][0],
			self.count[c][1], self.count[c][0] + self.count[c][1]), 2).encode('utf-8')
		
		self.fails = self.fails + self.count[c][1]

	def run_lexical_test(self, input):
		c = len(self.count)
		self.count.append([0, 0])

		title = "Test %d: %s (Lexical/Generation)" % (c, input)
		print self.c("-"*len(title), 1).encode('utf-8')
		print self.c(title, 1).encode('utf-8')
		print self.c("-"*len(title), 1).encode('utf-8')

		for l in self.tests[input].keys():
			sforms = s2l(self.tests[input][l])
			p1 = Popen(['echo', l], stdout=PIPE)
			p2 = Popen([self.program, self.gen], stdin=p1.stdout, stdout=PIPE, stderr=PIPE)
			p1.stdout.close()
			(res, err) = p2.communicate()
			lexes = self.parse_fst_output(res.decode('utf-8'))
			for r in lexes:
				if (r in sforms):
					if not self.args.hide_pass:
						print self.c("[PASS] %s => %s" % (l, r) ).encode('utf-8')
					self.count[c][0] += 1
				else:
					if not self.args.hide_fail:
						print self.c("[FAIL] %s => Expected: %s, Got: %s" % (l, l2s(sforms), r)).encode('utf-8')
					self.count[c][1] += 1
		print self.c("Test %d - Passes: %d, Fails: %d, Total: %d\n" % (c, self.count[c][0], 
			self.count[c][1], self.count[c][0] + self.count[c][1]), 2).encode('utf-8')
		self.fails = self.fails + self.count[c][1]

	def parse_fst_output(self, result):
		"Receive a unicode string"
		return_lex = []
		if type(result) == unicode:
			for i in result.split('\n'):
				if i.strip() != '':
					lexes = i.split('\t')
					#print "lexes", lexes
					if len(lexes) > 2 and lexes[2][0] == '+':
						lex = lexes[1].strip() + lexes[2].strip()
					else:
						lex = lexes[1].strip()
					return_lex.append(lex)
		return return_lex

hfst = HfstTester()
sys.exit(hfst.fails)