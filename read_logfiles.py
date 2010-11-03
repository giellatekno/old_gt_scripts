#!/usr/bin/env python
# -*- coding: utf-8 -*
"""
This script parses apache log files found in a given directory.
It outputs a .jspwiki file, readable by forrest
Run it like this: ./read_logfiles.py <directory where apache log files are found> <outputfile>
"""
import sys, getopt, glob, os, gzip, iptocountry

class divvunApacheLogParser:
	def __init__(self, args):
		"""
		Initialize the variables the class needs to handle:
		self.logDirectory: Where the log files are
		self.outfile: the output of the program
		self.ourTargets: a dict between the downloadable targets and the human readable names
		self.bots: List over known bots
		self.foundLists: List of lines that fill the criteria lined out further down
		self.ipToCountry: instance of the class that maps ip numbers to countries
		"""
		self.logDirectory, self.outfile = args
		self.ourTargets = {'DivvunInstaller.exe':'MSOffice/Windows', 'sami-proofing-tools.dmg':'MSOffice/Mac', 'indesign-divvuntools.dmg':'InDesign/Mac', 'smi-pack.zip':'OpenOffice.org, pre 3.0', 'smi.oxt':'OpenOffice.org 3.0', 'hunspell-se.tar.gz':'Hunspell/Unix, Northern Sami', 'hunspell-smj.tar.gz':'Hunspell/Unix, Lule Sami', 'smi.zip':'Hunspell/Generic'}
		self.bots = ['Yanga WorldSearch', 'Yahoo! Slurp', 'msnbot', 'setooz', 'Baiduspider', 'Googlebot', 'Java/', 'Charlotte', 'Fetch API Request', 'Creative ZENcast', 'iRc Search', 'Webbot', 'thorseek', 'Jakarta Commons-HttpClient', 'mlbot', 'ia_archiver', 'HTTrack', '"Mozilla/5.0"', 'Gigabot', 'Yandex', 'Jeeves', 'rdfbot', 'Mail.Ru', 'ichiro', 'larbin', 'Eniro NO', 'Gaisbot', 'localhost:8888', 'Twiceler', 'Nutch', 'T-Rank', 'webalta', 'Microsoft URL Control', 'favicon.ico', 'DigExt', 'Indy Library', 'ScoutJet', 'DBLBot', 'msrbot', 'MSIECrawler']
		self.foundLists = []
		for i in range(0, len(self.ourTargets.keys())):
			self.foundLists.append([])
		self.reportFile = open(self.outfile, 'w')
		self.ipToCountry = iptocountry.ipToCountry()

	def writeHeader(self):
		self.reportFile.write('!!!Download log for the Divvun tools\n\n')

	def writeSummary(self):
		"""
		Return how many lines we have
		"""
		totalFound = 0
		for foundList in self.foundLists:
			totalFound = totalFound + len(foundList)
		self.reportFile.write('!!Summary of downloads\n\n')
		self.reportFile.write('All of the Divvun tools have been downloaded ' + str(totalFound) + ' times\n\n')
		for x, target in enumerate(self.ourTargets.keys()):
			self.reportFile.write('* ' + self.ourTargets[target] + ' has been downloaded ' +  str(len(self.foundLists[x])) + ' times\n')
		return totalFound
		
	def writeByYear(self):
		self.reportFile.write('\n!!Downloads sorted by year\n')
		for x, target in enumerate(self.ourTargets.keys()):
			yearDict = {}
			for foundLine in self.foundLists[x]:
				year = self.getYear(foundLine)
				sys.stderr.write('Year found: ' + year + ' ' + foundLine +  '\n')
				if year in yearDict:
					yearDict[year] = yearDict[year] + 1
				else:
					yearDict[year] = 1
			self.reportFile.write('\n!' + self.ourTargets[target] + '\n')
			self.reportFile.write('|| Year || Count\n')
			for year, count in yearDict.items():
				self.reportFile.write('|' + year + ' | ' + str(count) + '\n')
			
	def writeByCountry(self):
		self.reportFile.write('\n!!Downloads sorted by country\n')
		for x, target in enumerate(self.ourTargets.keys()):
			countedCountries = {}
			for foundLine in self.foundLists[x]:
				country = self.ipToCountry.getCountrycode(foundLine.split()[0]).upper()
				if country in countedCountries:
					countedCountries[country] = countedCountries[country] + 1
				else:
					countedCountries[country] = 1
			self.reportFile.write('\n!' + self.ourTargets[target] + '\n')
			self.reportFile.write('|| Country || Count\n')
			for country, count in countedCountries.items():
				self.reportFile.write('|' + country + ' | ' + str(count) + '\n')

	def getYear(self, line):
		"""
		The date is inside a [] pair and has the format:[day/month/year:hours:minutes:seconds timezone]
		"""
		timeStart = line.find('[') + 1
		timeEnd = line.find(']') - 1
		timeString = line[timeStart:timeEnd].split()[0]
		calDate = timeString.split(':')[0]
		return calDate.split('/')[2]

	def findLines(self):
		"""
		Go through all the access log files in a given directory. Pick out
		the lines that has one our download goals, which has been fully fetched
		and which hasn't been downloaded by a bot.
		"""
		for accessFile in glob.glob(os.path.join(self.logDirectory, 'access*')):
			sys.stderr.write('Now handling  ' + accessFile + '\n')
			if accessFile[-3:] == '.gz':
				infile = gzip.open(accessFile)
			else:
				infile = open(accessFile)
			for line in infile:
				botFlag = False
				for bot in self.bots:
					if line.find(bot) > 0:
						botFlag = True
						pass
				if botFlag == False:
					for x, target in enumerate(self.ourTargets.keys()):
						if (line.find(target) != -1 and line.find(' 200 ') != -1):
							self.foundLists[x].append(line)
							pass
				else:
					pass

	def generateReport(self):
		self.writeHeader()
		totalLines = self.writeSummary()
		self.writeByYear()
		self.writeByCountry()
		self.debugInput(totalLines)

	def debugInput(self, totalFound):
		debugfile = open('debugfile','w')
		numLines = 0
		for foundList in self.foundLists:
			for line in foundList:
				debugfile.write(line)
				numLines = numLines + 1
		debugfile.write('Number of lines' + str(numLines) + '\n')
		debugfile.write('TotalFound reported: ' + str(totalFound) + '\n')
		debugfile.close()
		
def main():
	if len(sys.argv) != 3:
		print __doc__
		sys.exit(0)
    # parse command line options
	try:
		opts, args = getopt.getopt(sys.argv[1:], "h", ["help"])
	except getopt.error, msg:
		print msg
		print "for help use --help"
		sys.exit(2)
	# process options
	for o, a in opts:
		if o in ("-h", "--help"):
			print __doc__
			sys.exit(0)

	args = sys.argv[1:]
	
	divvunParser = divvunApacheLogParser(args)
	divvunParser.findLines()
	divvunParser.generateReport()
	

if __name__ == "__main__":
    main()