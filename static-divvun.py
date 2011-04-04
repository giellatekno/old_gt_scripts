#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""This script builds a multilingual forrest site.
--destination (-d) an ssh destination
--vcd (-c) the version control system
--sitehome (-s) where sd and techdoc lives
--langs (-l) comma separated list of languages"""

import subprocess
import os
import sys
import shutil
import time
import re
import getopt
from lxml import etree

def revert_files(vcs, files):
	if vcs == "svn":
		subp = subprocess.Popen(["svn", "revert"] + files, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		(output, error) = subp.communicate()
		if subp.returncode != 0:
			print >>sys.stderr, "Could not revert files"
			self.logfile.writelines(output)
			self.logfile.writelines(error)
	if vcs == "git":
		subp = subprocess.call(["git", "checkout"] + files)

class Translate_XML:
	"""Load site.xml and tabs.xml and their translation files.
	Translate the tags 
	"""

	def __init__(self, sitehome, lang, vcs):
		self.lang = lang
		self.sitehome = sitehome
		self.vcs = vcs
		
		os.chdir(self.sitehome)
		revert_files(self.vcs, ["src/documentation/content/xdocs/site.xml", "src/documentation/content/xdocs/tabs.xml", "src/documentation/skins/common/xslt/html/document-to-html.xsl", "src/documentation/skins/sdpelt/xslt/html/site-to-xhtml.xsl"])

		self.site = etree.parse(os.path.join(self.sitehome, "src/documentation/content/xdocs/site.xml"))
		try:
			self.site.xinclude()
		except etree.XIncludeError:
			print "xinclude in site.xml failed for site", sitehome
		self.tabs = etree.parse(os.path.join(self.sitehome, "src/documentation/content/xdocs/tabs.xml"))
		try:
			self.tabs.xinclude()
		except etree.XIncludeError:
			print "xinclude in tabs.xml failed for site", sitehome

		self.dth = etree.parse(os.path.join(self.sitehome, "src/documentation/skins/common/xslt/html/document-to-html.xsl"))

	def __del__(self):
		revert_files(self.vcs, ["src/documentation/content/xdocs/site.xml", "src/documentation/content/xdocs/tabs.xml", "src/documentation/skins/common/xslt/html/document-to-html.xsl", "src/documentation/skins/sdpelt/xslt/html/site-to-xhtml.xsl"])

	def parse_translations(self):
		tabs_translation = etree.parse(os.path.join(self.sitehome, "src/documentation/translations/tabs_" + self.lang + ".xml"))
		self.tabst = {}
		for child in tabs_translation.getroot():
			self.tabst[child.get("key")] = child.text

		menu_translation = etree.parse(os.path.join(self.sitehome, "src/documentation/translations/menu_" + self.lang + ".xml"))
		self.menut = {}
		for child in menu_translation.getroot():
			self.menut[child.get("key")] = child.text

		if self.lang != "en":
			self.commont = {}
			common_translation = etree.parse(os.path.join(self.sitehome, "src/documentation/translations/ContractsMessages_" + self.lang + ".xml"))
			for child in common_translation.getroot():
				self.commont[child.get("key")] = child.text

	def translate(self):
		"""Translate site.xml and tabs.xml to self.lang
		"""
		print 'Translating', self.lang, '...'
		for el in self.site.getroot().iter():
			try:
				el.attrib["label"]
			except KeyError:
				continue
			else:
				try:
					self.menut[el.attrib["label"]]
				except KeyError:
					pass
				else:
					el.attrib["label"] = self.menut[el.attrib["label"]]

		outfile = open(os.path.join(self.sitehome, "src/documentation/content/xdocs/site.xml"), "w")
		outfile.write(etree.tostring(self.site.getroot()))
		outfile.close()
		
		for el in self.tabs.getroot().iter():
			try:
				el.attrib["label"]
			except KeyError:
				continue
			else:
				try:
					self.tabst[el.attrib["label"]]
				except KeyError:
					pass
				else:
					el.attrib["label"] = self.tabst[el.attrib["label"]]

		outfile = open(os.path.join(self.sitehome, "src/documentation/content/xdocs/tabs.xml"), "w")
		outfile.write(etree.tostring(self.tabs.getroot()))
		outfile.close()

		if self.lang != "en":
			for el in self.dth.getroot().iter():
				#print "dth", el.tag
				if el.tag == "{http://apache.org/cocoon/i18n/2.1}text":
					#print "Old", el.text
					el.text = self.commont[el.text]
					#print "New", el.text
			outfile = open(os.path.join(self.sitehome,"src/documentation/skins/common/xslt/html/document-to-html.xsl"), "w")
			outfile.write(etree.tostring(self.dth.getroot()))
			outfile.close()

class StaticSiteBuilder:
	"""This class is used to build a static version of the divvun site.
	"""

	def __init__(self, builddir, destination, vcs):
		"""
			site: The directory where the forrest site is
			destination: where the built site is copied (using ssh)
			
			builddir: tells where the forrest should begin its crawl
			make a directory, built, where generated sites are stored
			logfile: print all errors into this one
			take a backup of the original forrest.properties file
			lang_specific_file: keeps trace of which files are localized
		"""
		print "Setting up..."
		self.builddir = builddir
		self.destination = destination
		self.vcs = vcs
		

		os.chdir(self.builddir)
		revert_files(self.vcs, ["forrest.properties", "src/documentation/resources/schema/symbols-project-v10.ent"])
		subp = subprocess.Popen(["forrest", "clean"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		(output, error) = subp.communicate()
		if subp.returncode != 0:
				print >>sys.stderr, "forrest clean failed"
				self.logfile.writelines(output)
				self.logfile.writelines(error)

		self.set_font_path()

		if os.path.isdir(os.path.join(self.builddir, "built")):
		   shutil.rmtree(os.path.join(self.builddir, "built"))

		os.mkdir(os.path.join(self.builddir, "built"))
		self.logfile = open(os.path.join(self.builddir, "buildlog" + time.strftime("%Y-%m-%d-%H-%M", time.localtime())), 'w')
		os.environ['LC_ALL'] = "C"
		self.lang_specific_files = []

	def __del__(self):
		"""Move the backup to the original file_type
		Close the logfile
		"""
		os.chdir(self.builddir)
		revert_files(self.vcs, ["forrest.properties", "src/documentation/resources/schema/symbols-project-v10.ent"])
		self.logfile.close()

	def set_font_path(self):
		import fileinput
		for line in fileinput.FileInput(os.path.join(self.builddir, "src/documentation/resources/schema/symbols-project-v10.ent"), inplace=1):
			line = line.replace("/Users/sd/trunk/xtdoc/sd", self.builddir).strip()
			print line

	def validate(self):
		print "Validating..."
		os.chdir(self.builddir)
		subp = subprocess.Popen(["forrest", "validate"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		(output, error) = subp.communicate()

		if subp.returncode != 1:
			if "Could not validate document" in error:
				print >>sys.stderr, "\n\nCould not validate doc\n\n"
				self.logfile.writelines(output)
				self.logfile.writelines(error)
	
				raise SystemExit(subp.returncode)
	
	def buildsite(self, lang):
		"""Builds a site in the specified language
		Clean up the build files
		Validate files. If they don't validate, exit program
		Build site. stdout and stderr are stored in output and error,
		respectively.
		If we aren't able to rename the built site, exit program
		"""
		os.chdir(self.builddir)
		subp = subprocess.Popen(["forrest", "clean"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		(output, error) = subp.communicate()
		if subp.returncode != 0:
				print >>sys.stderr, "forrest clean failed"
				self.logfile.writelines(output)
				self.logfile.writelines(error)

		trans = Translate_XML( self.builddir, lang, self.vcs)
		trans.parse_translations()
		trans.translate()

		print "Building", lang, "..."
		subp = subprocess.Popen(["forrest", "site"], stdout=self.logfile, stderr=self.logfile)
		subp.wait()
		if subp.returncode != 0:
			print >>sys.stderr, "Linking errors detected\n"

		commands = [u"find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Atilde;&cedil;/ø/g'", u"find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Atilde;&iexcl;/á/g'", u"find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Auml;Œ/Č/g'", u"find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Auml;&lsquo;/đ/g'", u"find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Auml;/č/g'", u"find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Aring;&iexcl;/š/g'", u"find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Atilde;&yen;/å/g'", u"find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Atilde;&hellip;/Å/g'", u"find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Atilde;&curren;/ä/g'", u"find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/ with google//g'"]

		if lang != "en":
			commands.append("find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/Search/" + trans.commont["Search"] + "/g'")
			for key, value in trans.commont.items():
				try:
					if key != "Search":
						commands.append("find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/" + key + "/" + value + "/g'")
				except TypeError:
					continue
		for command in commands:
			os.system(command.encode('utf-8'))
		print "Done building "

	def setlang(self, lang):
		"""Set the language in the file forrest.properties
		Forrest uses this to build language specific sites
		Exit if an IOError occurs
		"""
		try:
			inproperties = open(os.path.join(self.builddir, "forrest.properties"), 'r')
		except IOError:
			print >>sys.stderr, e
			self.logfile.write("Problems when reading content in forrest.properties")
			self.logfile.write("IOError\n")
			self.logfile.write(str(e) + "\n")
			raise SystemExit(2)
		incontent = inproperties.readlines()
		inproperties.close()
		
		try:
			outproperties = open(os.path.join(self.builddir, "forrest.properties"), 'w')
		except IOError:
			print >>sys.stderr, e
			self.logfile.write("Problems when writing content to forrest.properties")
			self.logfile.write("IOError\n")
			self.logfile.write(str(e) + "\n")
			raise SystemExit(2)


		for line in incontent:
			if "jvmargs" in line:
				line = line[:-1] + " -Duser.language=" + lang + "\n"
				if line[0] == "#":
					line = line[1:]

			outproperties.write(line)

		outproperties.close()
	
	def rename_site_files(self, lang = ""):
		"""Search for files ending with html and pdf in the build site. Give all
		these files the ending '.lang'. Move them to the 'built' dir
		"""

		builddir = os.path.join(self.builddir, "build/site")
		builtdir = os.path.join(self.builddir, "built")
		
		# Copy the site to builtdir/lang
		if lang != "":
			langdir = os.path.join(builtdir, lang) 
			os.mkdir(langdir)
			
			tree = os.walk(os.path.join(builddir))
			
			for leafs in tree:
				for directory in leafs[1]:
					os.mkdir(langdir + leafs[0][len(builddir):] + "/" + directory)
					try:
						os.mkdir(builtdir + leafs[0][len(builddir):] + "/" + directory)
					except OSError:
						continue
				files = leafs[2]
				for htmlpdf_file in files:
					if htmlpdf_file.endswith(".html"):
						#print leafs[0], htmlpdf_file
						self.add_lang_info(os.path.join(leafs[0], htmlpdf_file), lang)
						#shutil.copy(os.path.join(leafs[0], htmlpdf_file), os.path.join(leafs[0], htmlpdf_file + "." + lang))
						os.unlink(os.path.join(leafs[0], htmlpdf_file))
					elif htmlpdf_file.endswith(".pdf"):
						shutil.copy(os.path.join(leafs[0], htmlpdf_file), os.path.join(leafs[0].replace(builddir, builtdir),htmlpdf_file + "." + lang))
						shutil.move(os.path.join(leafs[0], htmlpdf_file), os.path.join(leafs[0].replace(builddir, langdir),htmlpdf_file + "." + lang))
					else:
						shutil.copy(os.path.join(leafs[0], htmlpdf_file), os.path.join(leafs[0].replace(builddir, builtdir),htmlpdf_file))
						shutil.move(os.path.join(leafs[0], htmlpdf_file), os.path.join(leafs[0].replace(builddir, langdir),htmlpdf_file))
		else:
			os.chdir(builddir)
			os.system("mv * " + builtdir)

		# Copy the site with renamed files to builtdir
		#shutil.copy(builddir, builtdir)

	def add_lang_info(self, filename, lang):
		trlangs = {"fi": "Suomeksi", "nb": "På norsk", "sma": "Åarjelsaemien", "se": "Davvisámegillii", "smj": "Julevsábmáj", "sv": "På svenska" , "en": "In english"}
		#print 'filename', filename
		#print 'path', self.builddir + "/build/site"
		the_rest = filename[len(self.builddir + "/build/site"):]
		#print 'the_rest', the_rest
		infile = open(filename)
		outfile1 = open(self.builddir + "/built" + the_rest + "." + lang, "w")
		outfile2 = open(self.builddir + "/built/" + lang + the_rest, "w")
		
		filebuf = infile.readlines()
		for line in filebuf:
			if line.find('id="content"') > -1:
				line += '<div id="lang-choice">\n<ul>\n'
				for trlang, value in trlangs.items():
					if trlang != lang:
						line += '<li><a href="/' + trlang + the_rest + '">' + value + '</a>\n</li>\n'
					else:
						line += '<li>' + value + '</li>\n'
				line += '</ul>\n</div>\n'
				#print 'the line became', line
			outfile1.write(line)
			outfile2.write(line)
			
		infile.close()
		outfile1.close()
		outfile2.close()
		
		if lang == "nb":
			shutil.copy(self.builddir + "/built" + the_rest + "." + lang, self.builddir + "/built" + the_rest + "." + "no")
		
	def copy_to_site(self):
		"""Copy the entire site to 'path'
		"""

		builtdir = os.path.join(self.builddir, "built")
		os.chdir(builtdir)
		os.system("scp -r * " + self.destination)

	

def main():
	# parse command line options
	vcs = "svn"
	langs = []
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hc:d:s:l:", ["help", "vcs", "destination", "langs"])
	except getopt.error, msg:
		print msg
		print "for help use --help"
		sys.exit(2)
	# process options
	for o, a in opts:
		if o in ("-h", "--help"):
			print __doc__
			sys.exit(1)
		elif o in ("-c", "--vcs"):
			if a != "":
				vcs = a
		elif o in ("-d", "--destination"):
			destination = a
		elif o in ("-s", "--sitehome"):
			sitehome = a
		elif o in ("-l", "--langs"):
			for l in a.split(","):
				langs.append(l)
		else:
			assert False, "unhandled option"

	if len(args) != 0:
		print __doc__
		sys.exit(3)

	builder = StaticSiteBuilder(sitehome, destination, vcs)
	builder.validate()
	
	for lang in langs:
		builder.setlang(lang)
		builder.buildsite(lang)
		if len(langs) == 1:
			builder.rename_site_files()
		else:
			builder.rename_site_files(lang)
	builder.copy_to_site()

if __name__ == "__main__":
	main()
