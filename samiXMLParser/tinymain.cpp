#include <iostream>
#include <sstream>
#include <dirent.h>
#include <iterator>
#include "divvunparser.h"
#include "globalstate.h"

using namespace std;


static string const version = "$Rev$";

void TraverseDir(DIR* dirp, string path, GlobalState gs);
void PrintVersion();
void PrintHelp();

int main( int argc, char *argv[] )
{
    GlobalState gs;
    bool bRecursive = false;
    DIR* dirp;
    string path;

    if (argc == 1) { PrintHelp(); return 0; }

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-r") == 0) {
            bRecursive = true;
        }

        else if (strcmp(argv[i], "-l") == 0) {
            gs.sLang = argv[i+1];
            i++;
        }

        else if (strcmp(argv[i], "-a") == 0) {
            gs.bPrintPara = true;
            gs.bPrintTitle = true;
            gs.bPrintList = true;
            gs.bPrintTable = true;
        }

        else if (strcmp(argv[i], "-p") == 0) {
            gs.bPrintPara = true;
        }

        else if (strcmp(argv[i], "-T") == 0) {
            gs.bPrintTitle = true;
            gs.bPrintPara = false;
        }

        else if (strcmp(argv[i], "-L") == 0) {
            gs.bPrintList = true;
            gs.bPrintPara = false;
        }

        else if (strcmp(argv[i], "-t") == 0) {
            gs.bPrintTable = true;
            gs.bPrintPara = false;
        }

        else if (strcmp(argv[i], "-C") == 0) {
            gs.bErrorFiltering = true;
            gs.errorFilters["error"] = true;
        }

        else if (strcmp(argv[i], "-ort") == 0) {
            gs.bErrorFiltering = true;
            gs.errorFilters["errorort"] = true;
        }

        else if (strcmp(argv[i], "-ortreal") == 0) {
            gs.bErrorFiltering = true;
            gs.errorFilters["errorortreal"] = true;
        }

        else if (strcmp(argv[i], "-syn") == 0) {
            gs.bErrorFiltering = true;
            gs.errorFilters["errorsyn"] = true;
        }

        else if (strcmp(argv[i], "-lex") == 0) {
            gs.bErrorFiltering = true;
            gs.errorFilters["errorlex"] = true;
        }

        else if (strcmp(argv[i], "-morphsyn") == 0) {
            gs.bErrorFiltering = true;
            gs.errorFilters["errormorphsyn"] = true;
        }

        else if (strcmp(argv[i], "-c") == 0) {
            gs.bPrintOnlyCorr = true;
        }
        
        else if (strcmp(argv[i], "-typos") == 0) {
            gs.bPrintTypos = true;
        }

        else if (strcmp(argv[i], "-S") == 0) {
            gs.bPrintSpeller = true;
        }

        else if (strcmp(argv[i], "-f") == 0) {
            gs.bPrintFilename = true;
        }
        
        else if (strcmp(argv[i], "--add-id") == 0) {
            gs.bAddID = true;
        }

        else if (strstr(argv[i], ".xml\0") != NULL) {
            DivvunParser dp(string(argv[i]), gs);
            dp.ProcessFile();
        }

        else if (bRecursive && ((dirp = opendir(argv[i])) != NULL)) {
            path = argv[i];
            path += "/";
            TraverseDir(dirp, path, gs);
        }

        else if (strcmp(argv[i], "-h") == 0) {
            PrintHelp();
            return 0;
        }

        else if (strcmp(argv[i], "-v") == 0) {
            PrintVersion();
            return 0;
        }

        else {
            cout << "\nOption " << argv [i] << " is not supported.\n";
            PrintHelp();
            return 0;
        }
    }

 
}

void TraverseDir(DIR* dirp, string path, GlobalState gs) {
    struct dirent* direntp;
    string fullpath;

    fullpath = path;

    while ((direntp = readdir(dirp)) != NULL) {
        if (strcmp(direntp->d_name, ".") == 0 ||
            strcmp(direntp->d_name, "..") == 0)
                continue;

        

        if (direntp->d_type == DT_DIR) {
            fullpath += direntp->d_name;
            TraverseDir(opendir(fullpath.c_str()), fullpath + "/", gs);
            fullpath.erase(fullpath.find_last_of("/") +1, fullpath.length());
        }
        else if (strstr(direntp->d_name, ".xml\0") != NULL) {
            string filename(direntp->d_name);
            if (filename.find("svn-base") == string::npos) {
                string pFile = fullpath + filename;
                DivvunParser dp(pFile, gs);
                dp.ProcessFile();
            }
        }
    }

    closedir(dirp);
}


void PrintHelp()
{
    cout << "\nUsage: ccat <options> [FileName]\n";
    cout << "Print the contents of a corpus file in XML format.\n";
    cout << "The default is to print paragraphs with no type (=text type).\n";
    cout << "The possible options include:\n\n";

    cout << "Content options:\n";
    cout << "\t-l <lang> Print only elements in language <lang>\n";
    cout << "\t-a\t  Print all text elements\n";
    cout << "\t-p\t  Print plain paragraphs (default)\n";
    cout << "\t-T\t  Print paragraphs with title type\n";
    cout << "\t-L\t  Print paragraphs with list type\n";
    cout << "\t-t\t  Print paragraphs with table type\n";
    cout << "\t-c\t  Print corrected text instead of the original typos & errors\n\n";

    cout << "Error markup filtering options:\n";
    cout << "\t-C\t  Only print unclassified (§/<error..>) corrections\n";
    cout << "\t-ort\t  Only print ortoghraphic, non-word ($/<errorort..>) corrections\n";
    cout << "\t-ortreal  Only print ortoghraphic, real-word (¢/<errorortreal..>)\n\t\t\tcorrections\n";
    cout << "\t-morphsyn Only print morphosyntactic (£/<errormorphsyn..>) corrections\n";
    cout << "\t-syn\t  Only print syntactic (¥/<errorsyn..>) corrections\n";
    cout << "\t-lex\t  Only print lexical (€/<errorlex..>) corrections\n\n";

    cout << "Error markup printing options:\n";
    cout << "\t-typos\t  Print only the errors/typos in the text, \n\t\t\twith corrections tab-separated\n";
    cout << "\t-S\t  Print the whole text one word per line; typos have \n\t\t\ttab separated corrections\n";
    cout << "\t-f\t  Add the source filename as a comment after each error word.\n";
    cout << "\t\t\tOnly useful with the -r & (-typos | -S) options\n\n";

    cout << "Other options:\n";
    cout << "\t-r <dir>  Recursively process directory <dir> and subdirs encountered\n";
    cout << "\t-v\t  Print version info\n";
    cout << "\t-h\t  Print this help message\n";

    cout << endl;
}

void PrintVersion()
{
    cout << "ccat version " << version << endl;
}
