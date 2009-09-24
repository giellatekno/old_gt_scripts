#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""This script builds a multilingual forrest site."""
import subprocess
import os
import sys
import glob
import shutil
import time
import re

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
        else:
           os.mkdir(os.path.join(self.builddir, "built"))

        self.logfile = open(os.path.join(self.builddir, "buildlog" + time.strftime("%Y-%m-%d-%H-%M", time.localtime())), 'w')
        
        os.rename(os.path.join(self.builddir, "forrest.properties"), os.path.join(self.builddir, "forrest.properties.build"))

        self.lang_specific_files = []
        print "Done with setup"

    def __del__(self):
        """Move the backup to the original file_type
        Close the logfile
        """
        os.rename(os.path.join(self.builddir, "forrest.properties.build"), os.path.join(self.builddir, "forrest.properties"))
        self.logfile.close()

    def buildsite(self, lang):
        """Builds a site in the specified language
        Clean up the build files
        Validate files. If they don't validate, exit program
        Build site. stdout and stderr are stored in output and error,
        respectively.
        If we aren't able to rename the built site, exit program
        """
        os.chdir(self.builddir)
        self.setlang(lang)

        print "Cleaning up"
        subp = subprocess.Popen(["forrest", "clean"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        print "Validating..."
        subp = subprocess.Popen(["forrest", "validate"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode == 1:
            
            if error.find("Could not validate document") > -1:
                
                print >>sys.stderr, "\n\nCould not validate doc\n\n"
                self.logfile.writelines(output)
                self.logfile.writelines(error)
                #print >>sys.stderr, output
                #print >>sys.stderr, error
            
                raise SystemExit(subp.returncode)
        
        print "Building", lang, "..."
        (output,error) = subprocess.Popen(["forrest", "site"], stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
        if subp.returncode == 1:
            print >>sys.stderr, "Linking errors detected\n"
            self.logfile.writelines(output)
            self.logfile.writelines(error)

        try:
            os.rename(os.path.join(self.builddir, "build/site"), os.path.join(self.builddir, "built/" + lang)) 
        except OSError, e:
            print >>sys.stderr, "OSError"
            print >>sys.stderr, e
            self.logfile.writelines("OSError")
            self.logfile.writelines(e)
            self.logfile.writelines(output)
            self.logfile.writelines(error)
            raise SystemExit(2)
        except NameError, e:
            print >>sys.stderr, "NameError"
            print >>sys.stderr, e
            self.logfile.writelines("NameError")
            self.logfile.writelines(e)
            self.logfile.writelines(output)
            self.logfile.writelines(error)
            raise SystemExit(3)

        print "Done building ", lang

    def setlang(self, lang):
        """Set the language in the file forrest.properties
        Forrest uses this to build language specific sites
        Exit if an IOError occurs
        """
        try:
            f = open(os.path.join(self.builddir, "forrest.properties.build"), 'r')
            content = f.read()
            content = content.replace("user.language=nb", "user.language=" + lang)
            f.close()
        except IOError:
            print >>sys.stderr, e
            raise SystemExit(2)
        
        try:
            f = open(os.path.join(self.builddir, "forrest.properties"), 'w')
            f.writelines(content)
            f.close()
        except IOError:
            print >>sys.stderr, e

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
        search_pattern = re.compile('\?locale=.+"')
        for lang_specific_file in self.lang_specific_files:
            lang = lang_specific_file.split(".")[1:2][0]
            basename = lang_specific_file.split(".")[-3]

            for file_type in [".html", ".pdf"]:
                fromfile = os.path.join(self.builddir, "built/" + lang + "/" + basename + file_type)
                tofile = os.path.join(self.builddir, "built/en/" + basename + file_type + "." + lang)
                
                if os.path.exists(fromfile):
                    if file_type == ".pdf":
                        try:
                            shutil.copyfile(fromfile, tofile)
                        except IOError, e:
                            print >>sys.stderr, e
                    else:
                        try:
                            fromfile = open(fromname)
                            content = fromfile.read()
                            fromfile.close()
                            # we are looking for "?locale=.*"
                            # .* is the lang
                            # should be changed to $lang/basename + .html
                            matches = search_pattern.findall(input)
                            for match in matches:
                                # match group() gives ?locale=lang"
                                # match group()[:-1] gives ?locale=lang
                                # split gives [?locale, lang]
                                # [1] gives lang
                                lang = match.group()[:-1].split('=')[1]
                                content = content.replace(match.group()[:-1],  '/' + lang + '/' + basename + '.html')
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
    
    for lang in langs:
        builder.find_langspecific_files(lang)
        builder.buildsite(lang)

    builder.move_lang_specific_files()
    builder.rename_and_link_english_files()
        

if __name__ == "__main__":
    main()
