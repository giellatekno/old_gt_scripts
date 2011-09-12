#include "tinyxml.h"
#include <iostream>
#include <dirent.h>
#include <iterator>
#include <sstream>

using namespace std;

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
bool bPrintCorr = false;
bool bPrintOrtCorr = false;
bool bPrintOrtRealCorr = false;
bool bPrintSynCorr = false;
bool bPrintLexCorr = false;
bool bPrintMorphSynCorr = false;
bool bPrintOnlyCorr = false;
bool bPrintTypos = false;
bool bPrintSpeller = false;
bool bAddID = false;
bool bOutsideError = true;
bool hitString = false;

int iParaNum = 0;

char sLang[4];
static string const version = "$Revision$";

void TraverseDir (DIR* dirp, string path);
void ProcessFile (const char *pFile);
void DumpTag(TiXmlElement* pElement);
string GetAttribValue(TiXmlElement *pElement, string attrName);
void RecurseTree( TiXmlNode* pParent );
void PrintVersion();
void PrintHelp();

int main( int argc, char *argv[] )
{
   bool bRecursive = false;
    DIR* dirp;
    string path;

    if (argc == 1) { PrintHelp(); return 0; }

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

        else if (strcmp(argv[i], "-C") == 0) {
            bPrintCorr = true;
        }

        else if (strcmp(argv[i], "-ort") == 0) {
            bPrintOrtCorr = true;
        }

        else if (strcmp(argv[i], "-ortreal") == 0) {
            bPrintOrtRealCorr = true;
        }

        else if (strcmp(argv[i], "-syn") == 0) {
            bPrintSynCorr = true;
        }

        else if (strcmp(argv[i], "-lex") == 0) {
            bPrintLexCorr = true;
        }

        else if (strcmp(argv[i], "-morphsyn") == 0) {
            bPrintMorphSynCorr = true;
        }

        else if (strcmp(argv[i], "-c") == 0) {
            bPrintOnlyCorr = true;
        }
        
        else if (strcmp(argv[i], "-typos") == 0) {
            bPrintTypos = true;
        }

        else if (strcmp(argv[i], "-S") == 0) {
            bPrintTypos = true;
            bPrintSpeller = true;
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
    TiXmlDocument doc( pFile );
    doc.LoadFile();

    TiXmlHandle docHandle( &doc );

    RecurseTree( docHandle.FirstChild( "document" ).ToNode() );
    
}

void DumpTag(TiXmlElement* pElement)
{
    if (pElement) {

        cout << "<" << pElement->Value();

        TiXmlAttribute* pAttrib=pElement->FirstAttribute();
        while (pAttrib)
        {
            cout << " " << pAttrib->Name() << "=\"" << pAttrib->Value() << "\"";
            pAttrib=pAttrib->Next();
        }
        cout << ">" << endl;
    }
}

string GetAttribValue(TiXmlElement *pElement, string attrName)
{
    string result = "";
    if (pElement) {
        TiXmlAttribute* pAttrib=pElement->FirstAttribute();
        while (pAttrib)
        {
            if (pAttrib->Name() == attrName) {
                result = pAttrib->Value();
            }
            pAttrib=pAttrib->Next();
        }
        
    }
    return result;
}

void RecurseTree( TiXmlNode* pParent )
{
    if( pParent ) {
        TiXmlText* pText;
        TiXmlNode* pChild;
        int t = pParent->Type();
        string tag;
        
        
        switch ( t )
        {
        case TiXmlNode::DOCUMENT:
            cerr << "Document" << endl;
            exit(2);
            break;

        case TiXmlNode::ELEMENT:
            hitString = false;
            tag = pParent->Value();
            if (tag == "p") {
                bElementLang = GetAttribValue(pParent->ToElement(), "xml:lang") == sLang ? true : false;
                if( bDocLang ) {
                    (bElementLang = GetAttribValue(pParent->ToElement(), "xml:lang") == "" || GetAttribValue(pParent->ToElement(), "xml:lang") == sLang)  ? true : false;
                }

                bInPara = (GetAttribValue(pParent->ToElement(), "type") == "" ||  GetAttribValue(pParent->ToElement(), "type") == "text") ? true : false;
                bInTitle = GetAttribValue(pParent->ToElement(), "type") == "title" ? true : false;
                bInList = GetAttribValue(pParent->ToElement(), "type") == "listitem" ? true : false;
                bInTable = GetAttribValue(pParent->ToElement(), "type") == "tablecell" ? true : false;


                if (bAddID &&
                    ((sLang[0] == '\0' || bElementLang) &&
                    (bPrintPara && bInPara)   ||
                    (bPrintTitle && bInTitle) ||
                    (bPrintList && bInList)   ||
                    (bPrintTable && bInTable)
                    )
                ) {
                    DumpTag(pParent->ToElement());
                }
            } else if (tag.substr(0,5) == "error") {
                bOutsideError = false;
            } else if (tag == "document") {
                bDocLang = GetAttribValue(pParent->ToElement(), "xml:lang") == sLang ? true : false;
                if (bAddID) {
                    DumpTag(pParent->ToElement());
                }
            }
            break;

        case TiXmlNode::COMMENT:
//             cerr << "Comment: " << pParent->Value() << endl;
            break;

        case TiXmlNode::UNKNOWN:
            cerr << "Unknown" << endl;
            exit (2);
            break;

        case TiXmlNode::TEXT:
            hitString = true;
            pText = pParent->ToText();
            if (bOutsideError) {
                if (!bPrintTypos) {
                    if ((sLang[0] == '\0' || bElementLang) &&
                        ((bPrintPara && bInPara)   ||
                        (bPrintTitle && bInTitle) ||
                        (bPrintList && bInList)   ||
                        (bPrintTable && bInTable))) {
                        cout << pText->Value() << " ";
                    }
                } else {
                    if (bPrintSpeller &&
                        ((bPrintPara && bInPara)   ||
                        (bPrintTitle && bInTitle) ||
                        (bPrintList && bInList)   ||
                        (bPrintTable && bInTable))) {
                        istringstream iss(pText->Value());
                        copy(istream_iterator<string>(iss),
                            istream_iterator<string>(),
                            ostream_iterator<string>(cout, "\n"));
                    }
                }
            } else {
                if (!bPrintOnlyCorr) {
                    cout << pText->Value() << " ";
                }
            }
            break;

        case TiXmlNode::DECLARATION:
            cerr << "Declaration" << endl;
            exit (2);
            break;
        default:
            break;
        }

        for (pChild = pParent->FirstChild(); pChild != 0; pChild = pChild->NextSibling())
        {
            RecurseTree( pChild );
        }
        if ( tag == "p" ) {
            if ((sLang[0] == '\0' || bElementLang) &&
                ((bPrintPara && bInPara)   ||
                (bPrintTitle && bInTitle) ||
                (bPrintList && bInList)   ||
                (bPrintTable && bInTable))) {
                if (hitString && !bPrintTypos) {
                    if (bAddID) {
                        cout << "</p>";
                    } else {
                        cout << "¶";
                    }
                    cout << endl;
                }
            }
        } else if ( tag.substr(0,5) == "error" ) {
            /*cout << endl;
            DumpTag(pParent->ToElement());
            cout << endl;
            */
            bOutsideError = true;
            string corr = GetAttribValue(pParent->ToElement(), "correct");

            
            if((bPrintOrtCorr && tag == "errorort") || (bPrintOrtRealCorr && tag == "errorortreal") || (bPrintSynCorr && tag == "errorsyn") || (bPrintMorphSynCorr && tag == "errormorphsyn") || (bPrintLexCorr && tag == "errorlex") || bPrintCorr || bPrintTypos) {
                if (corr != "") {
                    cout << "\t" << corr;
                }
                TiXmlAttribute* pAttrib=pParent->ToElement()->FirstAttribute();
                bool firstattr = true;

                while (pAttrib) {
                    string name = pAttrib->Name();
    //                 cout << endl << name << endl;
                    if (name != "correct") {
                        if (firstattr) {
                            cout << "\t#";
                            firstattr = false;
                        } else {
                            cout << ",";
                        }
                        cout << name << "=" << pAttrib->Value();
                    }
                    pAttrib = pAttrib->Next();
                }
                cout << endl;

            } else if (bPrintOnlyCorr) {
                if (corr != "") {
                    cout << corr << " ";
                }
            }
        } else if ( tag == "document" ) {
            if (bAddID) {
                cout << "</" << tag << ">" << endl;
            }
        }
    }
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
//    cout << "\t-f\t  Add the source filename as a comment after each word.\n";
//    cout << "\t\t\t  Only useful together with the -r option used together\n";
//    cout << "\t\t\t  with -typos or -S.\n\n";

    cout << "Other options:\n";
    cout << "\t-r <dir>  Recursively process directory <dir> and subdirs encountered\n";
    cout << "\t-h\t  Print this help message\n";

    cout << endl;
}

void PrintVersion()
{
    cout << "ccat version " << version << endl;
}
