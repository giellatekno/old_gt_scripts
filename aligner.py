#!/usr/bin/env python3

import unittest

class TestAligner(unittest.TestCase):
	def testAligner(self):
		input = '''
 +N+Sg:             N_ODD_SG       ;
 +N+Pl:             N_ODD_PL       ;
 +N:             N_ODD_ESS      ;
 +N+SgNomCmp:e%^DISIMP    R              ;
 +N+SgGenCmp:e%>%^DISIMPn R              ;
 +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
'''
		expectedResult = '''
               +N+Sg:             N_ODD_SG       ;
               +N+Pl:             N_ODD_PL       ;
                  +N:             N_ODD_ESS      ;
         +N+SgNomCmp:e%^DISIMP    R              ;
         +N+SgGenCmp:e%>%^DISIMPn R              ;
         +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
'''

	def testLineParserUpperLower(self):
		input = '''        +N+SgNomCmp:e%^DISIMP    R              ;'''
		expectedResult = {'upper': '+N+SgNomCmp', 'lower': 'e%^DISIMP', 'contlex': 'R'}

		aligner = Aligner()
		aligner.parseLine(input)
		self.assertEqual(aligner.line, expectedResult)

	def testLineParserNoLower(self):
		input = '''               +N+Sg:             N_ODD_SG       ;'''
		expectedResult = {'upper': '+N+Sg', 'lower': '', 'contlex': 'N_ODD_SG'}

		aligner = Aligner()
		aligner.parseLine(input)
		self.assertEqual(aligner.line, expectedResult)

	def testLineParserNoUpperNoLower(self):
		input = ''' N_ODD_ESS;''';
		expectedResult = {'upper': '', 'lower': '', 'contlex': 'N_ODD_ESS'}

		aligner = Aligner()
		aligner.parseLine(input)
		self.assertEqual(aligner.line, expectedResult)

import re

class Aligner:
	def __init__(self):
		self.line = {}
		self.line['upper'] = ''
		self.line['lower'] = ''
		self.line['contlex'] = ''

	def parseLine(self, line):
		p = re.compile(r'((?P<upper>\S+)*:(?P<lower>\S+))*\s+(?P<contlex>\S+)\s*;')
		m = p.search(line)

		if m:
			#if m.group('upper'):
				#self.line['upper'] = m.group('upper')

			if m.group('lower'):
				self.line['lower'] = m.group('lower')

			if m.group('contlex'):
				self.line['contlex'] = m.group('contlex')
		else:
			print('no m', line)
