#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""This script builds a multilingual forrest site."""
import subprocess
import os
import sys
import shutil
import time
import re
import getopt
from lxml import etree

class Translate_XML:
	"""Load site.xml and tabs.xml and their translation files.
	Translate the tags 
	"""

	def __init__(self, site, lang):
		self.lang = lang
		self.sitehome = os.path.join(os.getenv("GTHOME"), "xtdoc/" + site)

		os.chdir(self.sitehome)
		subp = subprocess.call(["svn", "revert", "src/documentation/content/xdocs/site.xml", "src/documentation/content/xdocs/tabs.xml", "src/documentation/skins/common/xslt/html/document-to-html.xsl", "src/documentation/skins/sdpelt/xslt/html/site-to-xhtml.xsl"])

		self.site = etree.parse(os.path.join(self.sitehome, "src/documentation/content/xdocs/site.xml"))
		try:
			self.site.xinclude()
		except etree.XIncludeError:
			print "xinclude in site.xml failed for site", site
		self.tabs = etree.parse(os.path.join(self.sitehome, "src/documentation/content/xdocs/tabs.xml"))
		try:
			self.tabs.xinclude()
		except etree.XIncludeError:
			print "xinclude in tabs.xml failed for site", site

		self.dth = etree.parse(os.path.join(self.sitehome, "src/documentation/skins/common/xslt/html/document-to-html.xsl"))

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
		print self.translate.__name__, self.lang
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
					print "Old", el.text
					el.text = self.commont[el.text]
					print "New", el.text
			outfile = open(os.path.join(self.sitehome,"src/documentation/skins/common/xslt/html/document-to-html.xsl"), "w")
			outfile.write(etree.tostring(self.dth.getroot()))
			outfile.close()

class StaticSiteBuilder:
	"""This class is used to build a static version of the divvun site.
	"""

	def __init__(self, site, lang = ""):
		"""
			builddir: tells where the forrest should begin its crawl
			make a directory, built, where generated sites are stored
			logfile: print all errors into this one
			take a backup of the original forrest.properties file
			lang_specific_file: keeps trace of which files are localized
		"""
		print "Setting up..."
		print site
		self.site = site
		self.builddir = os.path.join(os.getenv("GTHOME"), "xtdoc/" + self.site)

		os.chdir(self.builddir)
		subprocess.call(["svn", "revert", "forrest.properties"])
		subprocess.call(["forrest", "clean"])
		
		if os.path.isdir(os.path.join(self.builddir, "built")):
		   shutil.rmtree(os.path.join(self.builddir, "built"))

		os.mkdir(os.path.join(self.builddir, "built"))
		self.logfile = open(os.path.join(self.builddir, "buildlog" + time.strftime("%Y-%m-%d-%H-%M", time.localtime())), 'w')
		os.environ['LC_ALL'] = "C"
		self.lang_specific_files = []
		
		print "Done with setup"

	def __del__(self):
		"""Move the backup to the original file_type
		Close the logfile
		"""
		os.chdir(self.builddir)
		subprocess.call(["svn", "revert", "forrest.properties"])
		self.logfile.close()

	def validate(self):
		print "Validating..."
		os.chdir(self.builddir)
		subp = subprocess.Popen(["forrest", "validate"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		(output, error) = subp.communicate()

		if subp.returncode == 1:
	
			if "Could not validate document" in error:
	
				print >>sys.stderr, "\n\nCould not validate doc\n\n"
				self.logfile.writelines(output)
				self.logfile.writelines(error)
				#print >>sys.stderr, output
				#print >>sys.stderr, error
	
				raise SystemExit(subp.returncode)
	
	def buildsite(self):
		"""Builds a site in the specified language
		Clean up the build files
		Validate files. If they don't validate, exit program
		Build site. stdout and stderr are stored in output and error,
		respectively.
		If we aren't able to rename the built site, exit program
		"""
		os.chdir(self.builddir)
		subprocess.call(["forrest", "clean"])

		trans = Translate_XML( self.site, lang)
		trans.parse_translations()
		trans.translate()

		print "Building", self.lang, "..."
		subp = subprocess.Popen(["forrest", "site"], stdout=self.logfile, stderr=self.logfile)
		subp.wait()
		if subp.returncode == 1:
			print >>sys.stderr, "Linking errors detected\n"

		commands = ["find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Atilde;&cedil;/ø/g'", "find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Atilde;&iexcl;/á/g'", "find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Auml;Œ/Č/g'", "find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Auml;&lsquo;/đ/g'", "find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Auml;/č/g'", "find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Aring;&iexcl;/š/g'", "find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Atilde;&yen;/å/g'", "find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Atilde;&hellip;/Å/g'", "find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/&Atilde;&curren;/ä/g'"]

		if self.lang != "en":
			for key, value in trans.commont.items():
				try:
					if key != "Search":
						commands.append("find build/site -name \*.html | LC_ALL=C xargs perl -p -i -e 's/" + key + "/" + value.encode('utf-8') + "/g'")
				except TypeError:
					continue
		for command in commands:
			os.system(command)
		print "Done building ", self.lang

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


		search_pattern = re.compile("user.language=\w{1,3}")

		for line in incontent:
			if "jvmargs" in line:
				"Replace or add content"
	
				match = search_pattern.search(line).group()
				if match:
					line = line.replace(match, "user.language=" + lang)
				else:
					line = line[:-1] + " -Duser.language=" + lang + "\n"
	
				if line[0] == "#":
					line = line[1:]

			outproperties.write(line)

		outproperties.close()
	
	def find_langspecific_files(self, lang):
		"""Find the files that are translated in the forrest documentation
		tree. Compute the relative path (which will be seen in the web browser)
		to together with the file name, and store this in self.lang_specific_file
		"""

		fullpath = os.path.join(self.builddir, "src/documentation/content/xdocs")
		fullpath_len = len(fullpath) + 1
		xdocs_tree = os.walk(fullpath)
		for leafs in xdocs_tree:
			part_path = leafs[0]
			part_path = part_path[fullpath_len:]
			files = leafs[2]
			for langfile in files:
				if langfile.find("." + lang + ".") > 1:
					self.lang_specific_files.append(os.path.join(part_path, langfile))

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
			os.chdir(builddir)
			subprocess.call("cp", "-a", "*", langdir)
			
		
		tree = os.walk(os.path.join(builddir))

		for leafs in tree:
			files = leafs[2]
			for htmlpdf_file in files:
				if htmlpdf_file.endswith((".html", ".pdf")) and lang != "":
					os.rename(htmlpdf_file, htmlpdf_file + "." + lang)
					
		# Copy the site with renamed files to builtdir
		subprocess.call("cp", "-a", "*", builtdir)

	def copy_to_site(self, path):
		"""Copy the entire site to 'path'
		"""

		builtdir = os.path.join(self.builddir, "built")
		os.chdir(builtdir)
		os.system("scp -r * ~/Sites/.")

	

def main():
	#if len(sys.argv) != 3:
		#print __doc__
		#sys.exit(0)
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

	#args = sys.argv[1:]

	builder = StaticSiteBuilder("techdoc")
	builder.validate()
	# Ensure menus and tabs are in english for techdoc
	builder.setlang("en")
	builder.buildsite("en")
	builder.rename_site_files()
	builder.copy_to_site(os.path.join(os.getenv("HOME"), "Sites"))

	langs = ["fi", "nb", "sma", "se", "smj", "sv", "en" ]
	#langs = ["smj", "sma"]
	builder = StaticSiteBuilder("sd")
	builder.validate()
	
	for lang in langs:
		builder.setlang(lang)
		builder.buildsite(lang)
		builder.rename_site_files(lang)
	builder.copy_to_site(os.path.join(os.getenv("HOME"), "Sites"))

if __name__ == "__main__":
	main()
