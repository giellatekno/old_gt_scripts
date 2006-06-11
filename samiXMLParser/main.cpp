#include "stdafx.h"
#include "tagfile.h"
#include <iostream>
#include <limits.h>
#include <dirent.h>

bool bInPara = false;
bool bInTitle = false;
bool bInList = false;
bool bInTable = false;
bool bStartOfLine = true;

bool bDocLang = false;
bool bElementLang = false;
bool bPrintEndTag = false;

bool bPrintPara = true;
bool bPrintTitle = false;
bool bPrintList = false;
bool bPrintTable = false;
bool bAddID = false;

int iParaNum = 0;

char sLang[4];
static string const version = "$Revision$";

void TraverseDir (DIR* dirp, string path);
void ProcessFile (const char *pFile);
void ProcessWord (TagParser &parse);
void ProcessTag (TagParser &parse);
void DumpTag (int Spaces, int id, TagParser &parse, bool bEofLine = true);
void print_help();
//const string& Version() const;
void print_version();

using namespace std;

main (int argc, char *argv[])
{
    bool bRecursive = false;
    DIR* dirp;
    string path;
   
    if (argc == 1) { print_help(); return 0; }
    
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-r") == 0) {
            bRecursive = true;
        }

        else if (strcmp(argv[i], "-l") == 0) {
            strcpy(sLang, argv[i+1]);
            i++;
        }
 
        else if (strcmp(argv[i], "-a") == 0) {
            bPrintPara = true;
            bPrintTitle = true;
            bPrintList = true;
            bPrintTable = true;
        }
        
        else if (strcmp(argv[i], "-p") == 0) {
            bPrintPara = true;
        }

        else if (strcmp(argv[i], "-T") == 0) {
            bPrintTitle = true;
            bPrintPara = false;
        }
 
        else if (strcmp(argv[i], "-L") == 0) {
            bPrintList = true;
            bPrintPara = false;
        }

        else if (strcmp(argv[i], "-t") == 0) {
            bPrintTable = true;
            bPrintPara = false;
        }

        else if (strstr(argv[i], ".xml\0") != NULL) ProcessFile (argv[i]);
        
        else if (bRecursive && ((dirp = opendir(argv[i])) != NULL)) {
            path = argv[i];
            path += "/";
            TraverseDir(dirp, path);
        }

        else if (strcmp(argv[i], "--add-id") == 0) {
            bAddID = true;
        }
        
        else if (strcmp(argv[i], "-h") == 0) {
            print_help();
            return 0;
        }
        
        else if (strcmp(argv[i], "-v") == 0) {
            print_version();
            return 0;
        }
        
        else {
            cout << "\nOption " << argv [i] << " is not supported.\n";
            print_help();
            return 0;
        }
    }
    
    return 0;
}

void TraverseDir(DIR* dirp, string path) {
    struct dirent* direntp;
    string fullpath;
    
    fullpath = path;
    
    while ((direntp = readdir(dirp)) != NULL) {
        if (strcmp(direntp->d_name, ".") == 0 || 
            strcmp(direntp->d_name, "..") == 0)
                continue;
        
        if (direntp->d_type == DT_DIR) {
            fullpath += direntp->d_name;
            TraverseDir(opendir(fullpath.c_str()),
                        fullpath + "/");
            fullpath.erase(fullpath.find_last_of("/") +1, fullpath.length());
        }
        
        else if (strstr(direntp->d_name, ".xml\0") != NULL) {
            char *pFile;
            pFile = (char*)malloc(2*PATH_MAX); // to be safe
            strcpy(pFile, fullpath.c_str());
            strcat(pFile, direntp->d_name);
            ProcessFile (pFile);
        }
    }
    
    closedir(dirp);
}

void ProcessFile(const char *pFile)
{
    // Open file
    ifstream in(pFile);
    
    // Create parse object
    TagParser parse(&in,true,false);
    
//    cout << parse.GetFullText() << endl;
    
    while (parse.GetNextToken())
    {
        switch (parse.Type())
        {
            case TagParser::TAG_START_TAG:
            case TagParser::TAG_END_TAG:
                ProcessTag (parse);
                break;
            case TagParser::TAG_WORD:
                ProcessWord (parse);
        }
    }
}

void ProcessWord (TagParser &parse)
{
   string word = parse.Value();

// if language is not given all the paras are printed.
   if ((sLang[0] == '\0' || bElementLang) &&
	   (bPrintPara && bInPara)   ||
       (bPrintTitle && bInTitle) ||
       (bPrintList && bInList)   ||
       (bPrintTable && bInTable))
   {
     bPrintEndTag = true;
     cout << word << " ";
   }
}

void ProcessTag (TagParser &parse)
{
  if (parse.Value() == "document")
    {
	  bDocLang = parse.sGetValue("xml:lang") == sLang ? true : false;
    }
  else if (parse.Value() == "p")
    {
//        list<TagAttribute*> &attr = parse.GetAttribs();
//        for (list<TagAttribute*>::const_iterator i = attr.begin(); i != attr.end(), ++i)
//        {
            bElementLang = parse.sGetValue("xml:lang") == sLang ? true : false;
			if( bDocLang ) {
			  bElementLang = parse.sGetValue("xml:lang") == "" ? true : false;
			}
            bInPara = parse.Type() == TagParser::TAG_START_TAG && (parse.sGetValue("type") == "" ||  parse.sGetValue("type") == "text") ? true : false;
            bInTitle = parse.Type() == TagParser::TAG_START_TAG && parse.sGetValue("type") == "title" ? true : false;
            bInList = parse.Type() == TagParser::TAG_START_TAG && parse.sGetValue("type") == "listitem" ? true : false;
            bInTable = parse.Type() == TagParser::TAG_START_TAG && parse.sGetValue("type") == "tablecell" ? true : false;
//        }

        if (bInPara)
      {
            iParaNum++;
            if (bAddID)
                DumpTag(0, iParaNum, parse);
        }
        else if (bAddID)
            DumpTag(0, 0, parse);

//        if (!bInPara && !bInTitle && !bInList && !bInTable)
        if (parse.Type() == TagParser::TAG_END_TAG && bPrintEndTag) {
            cout << "¶\n";
            bPrintEndTag = false;
        }
    }
}

void DumpTag(int Spaces, int id, TagParser &parse, bool bEofLine)
{
  ostringstream temp;
  
  if (!bStartOfLine)
    cout << "\n";

  while((Spaces--) > 0) 
    cout << " "; 

  cout << "<";
  if (parse.Type() == TagParser::TAG_END_TAG)
    cout << "/";
  else if (id > 0)
  {
    temp << id;
    parse.addAttrib("id", temp.str());
  }
  cout << parse.Value();
  const list<TagAttribute*> &lst = parse.GetAttribs();
  if (lst.size())
  {

    for(list<TagAttribute*>::const_iterator i = lst.begin(); i != lst.end();++i)
    {
      if ((*i)->getName() == "/")
        cout << (*i)->getName();
      else
      {
        cout << " ";
        cout << (*i)->getName()  << "=\"" 
             << (*i)->getValue() << "\"";
      }
    }
  }
  cout << ">";
  if (bEofLine)
    cout << "\n";
  bStartOfLine = true;
}

void print_help()
{
    cout << "\nUsage: ccat <options> [FileName]\n";
	cout << "Print the contents of a corpus file in XML format.\n";
	cout << "The default is to print paragraphs with no type (=text type).\n";
    cout << "The possible options include:\n";

// Commented out the language option so far --sh
    cout << "\t-l <lang>\tProcess elements in language <lang>.\n";
    cout << "\t-a\t Print all text elements.\n";
    cout << "\t-p\t Print plain paragraphs. (default)\n";
    cout << "\t-T\t Print paragraphs with title type.\n";
    cout << "\t-L\t Print paragraphs with list type.\n";
    cout << "\t-t\t Print paragraphs with table type.\n";
    cout << "\t-r <dir> Recursively process directory dir and subdirs encountered.\n";
    cout << "\t-h\t Print this help message.\n";

    cout << endl;
}

/*
const string& Version() const
{
    static string const my_version = "$Revision$";
    return my_version;
}
*/

void print_version()
{
    cout << "ccat version " << version << endl;
}
