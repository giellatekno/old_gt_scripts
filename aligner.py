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

		expectedResult = '''               +N+Sg:             N_ODD_SG       ;
               +N+Pl:             N_ODD_PL       ;
                  +N:             N_ODD_ESS      ;
         +N+SgNomCmp:e%^DISIMP    R              ;
         +N+SgGenCmp:e%>%^DISIMPn R              ;
         +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
'''
		self.maxDiff = None
	
		self.assertEqual(expectedResult, l.printLines())

class TestLine(unittest.TestCase):

	def testLineParserUpperLower(self):
		input = '''        +N+SgNomCmp:e%^DISIMP    R              ;'''
		expectedResult = {'upper': '+N+SgNomCmp', 'lower': 'e%^DISIMP', 'contlex': 'R'}

		aligner = Line()
		aligner.parseLine(input)
		self.assertEqual(aligner.line, expectedResult)

	def testLineParserNoLower(self):
		input = '''               +N+Sg:             N_ODD_SG       ;'''
		expectedResult = {'upper': '+N+Sg', 'lower': '', 'contlex': 'N_ODD_SG'}

		aligner = Line()
		aligner.parseLine(input)
		self.assertEqual(aligner.line, expectedResult)

	def testLineParserNoUpperNoLower(self):
		input = ''' N_ODD_ESS;''';
		expectedResult = {'upper': '', 'lower': '', 'contlex': 'N_ODD_ESS'}

		aligner = Line()
		aligner.parseLine(input)
		self.assertEqual(aligner.line, expectedResult)

	def testLineParserEmptyUpperLower(self):
		input = ''' : N_ODD_E;''';
		expectedResult = {'upper': '', 'lower': '', 'contlex': 'N_ODD_E'}

		aligner = Line()
		aligner.parseLine(input)
		self.assertEqual(aligner.line, expectedResult)

import re
import io

class Lines:
	def __init__(self):
		self.longest = {}
		self.longest['upper'] = 0
		self.longest['lower'] = 0
		self.longest['contlex'] = 0
		self.lines = []

	def parseLines(self, lines):
		for line in lines:
			if len(line) > 0:
				l = Line()
				l.parseLine(line)
				self.lines.append(l)
				self.findLongest(l)

	def findLongest(self, l):
		for name in ['upper', 'lower', 'contlex']:
			if self.longest[name] < len(l.line[name]):
				self.longest[name] = len(l.line[name])

	def printLines(self):
		s = io.StringIO()

		for l in self.lines:
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

		return s.getvalue()

class Line:
	def __init__(self, upper = '', lower = '', contlex = ''):
		self.line = {}
		self.line['upper'] = upper
		self.line['lower'] = lower
		self.line['contlex'] = contlex

	def parseLine(self, line):
		contlexre = re.compile(r'(?P<contlex>\S+)\s*;')
		self.line['contlex'] = contlexre.search(line).group('contlex')
		line = line.replace(self.line['contlex'], '')

		upperlower = re.compile(r'((?P<upper>\S+)*:(?P<lower>\S+)*)')

		m = upperlower.search(line)

		if m:
			if m.group('upper'):
				self.line['upper'] = m.group('upper')

			if m.group('lower'):
				self.line['lower'] = m.group('lower')

		else:
			print('no m', line)
