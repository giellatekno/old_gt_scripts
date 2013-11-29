#!/usr/bin/env python3

import unittest

class TestLines(unittest.TestCase):

	def testLongest(self):
		input = ''' +N+Sg:             N_ODD_SG       ;
 +N+Pl:             N_ODD_PL       ;
 +N:             N_ODD_ESS      ;
 +N+SgNomCmp:e%^DISIMP    R              ;
 +N+SgGenCmp:e%>%^DISIMPn R              ;
 +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
'''

		l = Lines()
		l.parseLines(input.split('\n'))

		longest = {}
		longest['upper'] = 19
		longest['lower'] = 12
		longest['contlex'] = 14

		self.assertEqual(longest, l.longest)

	def testOutput(self):
		input = '''
LEXICON DAKTERE
 +N+Sg:             N_ODD_SG       ;
 +N+Pl:             N_ODD_PL       ;
 +N:             N_ODD_ESS      ;
 +N+SgNomCmp:e%^DISIMP    R              ;
 +N+SgGenCmp:e%>%^DISIMPn R              ;
 +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
  ! Test data:
!!€gt-norm: daktere # Odd-syllable test
'''
		l = Lines()
		l.parseLines(input.split('\n'))

		expectedResult = '''
LEXICON DAKTERE
               +N+Sg:             N_ODD_SG       ;
               +N+Pl:             N_ODD_PL       ;
                  +N:             N_ODD_ESS      ;
         +N+SgNomCmp:e%^DISIMP    R              ;
         +N+SgGenCmp:e%>%^DISIMPn R              ;
         +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
! Test data:
!!€gt-norm: daktere # Odd-syllable test

'''
		self.maxDiff = None
		self.assertEqual(expectedResult, l.printLines())

class TestLine(unittest.TestCase):

	def testLineParserUpperLower(self):
		input = '''        +N+SgNomCmp:e%^DISIMP    R              ;'''
		expectedResult = {'upper': '+N+SgNomCmp', 'lower': 'e%^DISIMP', 'contlex': 'R', 'comment': ''}

		aligner = Line()
		aligner.parseLine(input)
		self.assertEqual(aligner.line, expectedResult)

	def testLineParserNoLower(self):
		input = '''               +N+Sg:             N_ODD_SG       ;'''
		expectedResult = {'upper': '+N+Sg', 'lower': '', 'contlex': 'N_ODD_SG', 'comment': ''}

		aligner = Line()
		aligner.parseLine(input)
		self.assertEqual(aligner.line, expectedResult)

	def testLineParserNoUpperNoLower(self):
		input = ''' N_ODD_ESS;''';
		expectedResult = {'upper': '', 'lower': '', 'contlex': 'N_ODD_ESS', 'comment': ''}

		aligner = Line()
		aligner.parseLine(input)
		self.assertEqual(aligner.line, expectedResult)

	def testLineParserEmptyUpperLower(self):
		input = ''' : N_ODD_E;''';
		expectedResult = {'upper': '', 'lower': '', 'contlex': 'N_ODD_E', 'comment': ''}

		aligner = Line()
		aligner.parseLine(input)
		self.assertEqual(aligner.line, expectedResult)

import re
import io
import argparse

class Lines:
	def __init__(self):
		self.longest = {}
		self.longest['upper'] = 0
		self.longest['lower'] = 0
		self.longest['contlex'] = 0
		self.lines = []

	def parseLines(self, lines):
		commentre = re.compile(r'^\s*!')
		for line in lines:

			commentmatch = commentre.match(line)
			if commentmatch:
				self.lines.append(commentre.sub('!', line))
				continue

			contlexre = re.compile(r'(?P<contlex>\S+)\s*;')
			contlexmatch = contlexre.search(line)
			if contlexmatch:
				l = Line()
				l.parseLine(line)
				self.lines.append(l)
				self.findLongest(l)
			else:
				self.lines.append(line)

	def findLongest(self, l):
		for name in ['upper', 'lower', 'contlex']:
			if self.longest[name] < len(l.line[name]):
				self.longest[name] = len(l.line[name])

	def printLines(self):
		s = io.StringIO()

		for l in self.lines:
			if isinstance(l, Line):
				pre = self.longest['upper'] - len(l.line['upper']) + 1
				for i in range(0, pre):
					s.write(' ')
				s.write(l.line['upper'])

				s.write(':')

				s.write(l.line['lower'])
				post = self.longest['lower'] - len(l.line['lower']) + 1
				for i in range(0, post):
					s.write(' ')

				s.write(l.line['contlex'])

				post = self.longest['contlex'] - len(l.line['contlex']) + 1

				for i in range(0, post):
					s.write(' ')
				s.write (';\n')
			else:
				s.write(l)
				s.write('\n')

		return s.getvalue()

class Line:
	def __init__(self, upper = '', lower = '', contlex = '', therest = ''):
		self.line = {}
		self.line['upper'] = upper
		self.line['lower'] = lower
		self.line['contlex'] = contlex
		self.line['comment'] = therest

	def parseLine(self, line):
		contlexre = re.compile(r'(?P<contlex>\S+)\s*;')
		self.line['contlex'] = contlexre.search(line).group('contlex')
		line = contlexre.sub('', line)

		m = line.find(":")

		if m != -1:
			self.line['upper'] = line[:m].strip()
			self.line['lower'] = line[m + 1:].strip()

		else:
			print('no m', line)

def parse_options():
	parser = argparse.ArgumentParser(description = 'Align rules given in lexc files')
	parser.add_argument('lexcfile', help = 'lexc file where rules should be aligned')

	args = parser.parse_args()
	return args

if __name__ == '__main__':
	args = parse_options()
	f = open(args.lexcfile)

	lines = Lines()
	lines.parseLines(f.read().split('\n'))
	f.close()

	f = open(args.lexcfile, 'w')
	f.write(lines.printLines())
	f.close()
