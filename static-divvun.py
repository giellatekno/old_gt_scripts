#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""TODO: Store all files linked to in site*.xml and tab*.xml. Compare these and the files collected from source. Build only those present in both places."""

"""This script builds a multilingual forrest site."""
import subprocess
import os
import sys
import shutil
import time
import re
import getopt

class StaticSiteBuilder:
    """This class is used to build a static version of the divvun site.
    """
    def __init__(self, builddir):
        """
            builddir: tells where the forrest should begin its crawl
            make a directory, built, where generated sites are stored
            logfile: print all errors into this one
            take a backup of the original forrest.properties file
            lang_specific_file: keeps trace of which files are localized
        """
        print "Setting up..."
        self.builddir = builddir
        
        if os.path.isdir(os.path.join(self.builddir, "built")):
           shutil.rmtree(os.path.join(self.builddir, "built"))
        
        os.mkdir(os.path.join(self.builddir, "built"))

        self.logfile = open(os.path.join(self.builddir, "buildlog" + time.strftime("%Y-%m-%d-%H-%M", time.localtime())), 'w')
        
        os.rename(os.path.join(self.builddir, "forrest.properties"), os.path.join(self.builddir, "forrest.properties.build"))

        os.environ['LC_ALL'] = "C"

        self.lang_specific_files = []
        print "Done with setup"

    def __del__(self):
        """Move the backup to the original file_type
        Close the logfile
        """
        os.rename(os.path.join(self.builddir, "forrest.properties.build"), os.path.join(self.builddir, "forrest.properties"))
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
        
    def buildsite(self, lang):
        """Builds a site in the specified language
        Clean up the build files
        Validate files. If they don't validate, exit program
        Build site. stdout and stderr are stored in output and error,
        respectively.
        If we aren't able to rename the built site, exit program
        """
        os.chdir(self.builddir)

        print "Building", lang, "..."
        subp = subprocess.Popen(["forrest", "site"], stdout=self.logfile, stderr=self.logfile)
        subp.wait()
        if subp.returncode == 1:
            print >>sys.stderr, "Linking errors detected\n"

        try:
            os.rename(os.path.join(self.builddir, "build/site/en"), os.path.join(self.builddir, "built/" + lang)) 
        except OSError, e:
            print >>sys.stderr, "OSError"
            print >>sys.stderr, e
            self.logfile.writelines("OSError\n")
            self.logfile.writelines(str(e) + "\n")
            raise SystemExit(2)
        except NameError, e:
            print >>sys.stderr, "NameError"
            print >>sys.stderr, e
            self.logfile.writelines("NameError\n")
            self.logfile.writelines(str(e) + "\n")
            raise SystemExit(3)

        print "Done building ", lang

    def setlang(self, lang):
        """Set the language in the file forrest.properties
        Forrest uses this to build language specific sites
        Exit if an IOError occurs
        """
        try:
            inproperties = open(os.path.join(self.builddir, "forrest.properties.build"), 'r')
        except IOError:
            print >>sys.stderr, e
            self.logfile.write("Problems when reading content in forrest.properties.build")
            self.logfile.write("IOError\n")
            self.logfile.write(str(e) + "\n")
            raise SystemExit(2)
        
        try:
            outproperties = open(os.path.join(self.builddir, "forrest.properties"), 'w')
        except IOError:
            print >>sys.stderr, e
            self.logfile.write("Problems when writing content to forrest.properties")
            self.logfile.write("IOError\n")
            self.logfile.write(str(e) + "\n")
            raise SystemExit(2)

        incontent = inproperties.readlines()
        
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

        inproperties.close()
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

    def rename_and_link_english_files(self):
        """Search for files ending with html and pdf in the en site. Give all
        the files the ending .en. Do also make a symbolic link to this file
        using all the other language endings, except if a real file already
        exists.
        """
        tree = os.walk(os.path.join(self.builddir, "built/en"))

        for leafs in tree:
            #print leafs
            files = leafs[2]
            for htmlpdf_file in files:
                #print htmlpdf_file
                if htmlpdf_file.endswith((".html", ".pdf")):
                    fullname = os.path.join(leafs[0], htmlpdf_file)
                    #print fullname, fullname + '.' + "en"
                    os.rename(fullname, fullname + ".en")
                    for lang in ["fi", "nb", "se", "sma", "smj", "sv"]:
                        try:
                            os.symlink(fullname + '.' + "en", fullname + '.' + lang)
                        except OSError:
                            #print fullname + '.' + lang, "already exists, skipping linking."
                            pass


    def move_lang_specific_files(self):
        """Move the files that really are translated from the language
        specific sites to en. We use the files found in the forrest tree
        to pick these files.
        Go through all the names in self.lang_specific_files.
        Find which language we should lookup
        Get the basename of the file
        Search for files ending with html or pdf
        Not all translated files in the forrest tree is converted to html,
        so if a file doesn't exist in the generated site, log the errors.
        """
        search_pattern = re.compile('\?locale=.+" ')
        for lang_specific_file in self.lang_specific_files:
            lang = lang_specific_file.split(".")[1:2][0]
            basename = lang_specific_file.split(".")[-3]

            for file_type in [".html", ".pdf"]:
                fromname = os.path.join(self.builddir, "built/" + lang + "/" + basename + file_type)
                toname = os.path.join(self.builddir, "built/en/" + basename + file_type + "." + lang)
                
                if os.path.exists(fromname):
                    if file_type == ".pdf":
                        try:
                            shutil.copyfile(fromname, toname)
                        except IOError, e:
                            print >>sys.stderr, e
                    else:
                        try:
                            fromfile = open(fromname)
                            content = fromfile.read()
                            fromfile.close()
                            # we are looking for "?locale=.*"
                            # .* is the lang
                            # which then should be changed to
                            # $lang/basename + .html
                            matches = search_pattern.findall(content)
                            for match in matches:
                                # match is '?locale=lang" '
                                # match[:-2] gives ?locale=lang
                                # split gives [?locale, lang]
                                # [1] gives lang
                                lang = match[:-2].split('=')[1]
                                content = content.replace(match[:-2],  '/' + lang + '/' + basename + '.html')
                            tofile = open(toname, "w")
                            tofile.write(content)
                            tofile.close()
                        except IOError, e:
                            print >>sys.stderr, e
                else:
                    pass
                    #print >>sys.stderr, "File", fromfile, "doesn't exist"


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
    langs = ["en", "fi", "nb", "se", "sma", "smj", "sv"]
    builder = StaticSiteBuilder(os.path.join(os.getenv("GTHOME"), "xtdoc/sd"))

    builder.validate()
    
    for lang in langs:
        builder.setlang(lang)
        builder.find_langspecific_files(lang)
        builder.buildsite(lang)

    builder.move_lang_specific_files()
    builder.rename_and_link_english_files()


if __name__ == "__main__":
    main()
