#include "tinyxml.h"
#include <iostream>
#include <dirent.h>
#include <iterator>
#include <sstream>
#include <limits.h>

using namespace std;

bool bInPara = false;
bool bInTitle = false;
bool bInList = false;
bool bInTable = false;
bool bStartOfLine = true;

bool bBothTagAndOption = false;

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
bool bPrintFilename = false;
bool bAddID = false;
bool bOutsideError = true;
bool hitString = false;

int iParaNum = 0;

string sLang;
string docLang;
string output;
static string const version = "$Revision$";

void TraverseDir(DIR* dirp, string path);
void ProcessFile(string pFile);
void DumpTag(TiXmlElement* pElement);
string GetAttribValue(TiXmlElement *pElement, string attrName);
void RecurseTree(TiXmlNode* pParent, string fileName);
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
            sLang = argv[i+1];
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

        else if (strcmp(argv[i], "-f") == 0) {
            bPrintFilename = true;
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
            string filename(direntp->d_name);
            if (filename.find("svn-base") == string::npos) {
                string pFile = fullpath + filename;
                ProcessFile (pFile);
            }
        }
    }

    closedir(dirp);
}

void ProcessFile(string pFile)
{
    TiXmlDocument doc(pFile.c_str());
    doc.LoadFile();

    TiXmlHandle docHandle( &doc );

    RecurseTree( docHandle.FirstChild( "document" ).ToNode(), pFile.substr(pFile.rfind("/") + 1) );
    
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

void RecurseTree(TiXmlNode* pParent, string fileName)
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
                output = "";
                string pLang = GetAttribValue(pParent->ToElement(), "xml:lang");
                if (sLang == "" || sLang == docLang) {
                    bElementLang = (pLang == "" || pLang == docLang)? true : false;
                } else {
                    bElementLang = pLang == sLang ? true : false;
                }
                bInPara = (GetAttribValue(pParent->ToElement(), "type") == "" ||  GetAttribValue(pParent->ToElement(), "type") == "text") ? true : false;
                bInTitle = GetAttribValue(pParent->ToElement(), "type") == "title" ? true : false;
                bInList = GetAttribValue(pParent->ToElement(), "type") == "listitem" ? true : false;
                bInTable = GetAttribValue(pParent->ToElement(), "type") == "tablecell" ? true : false;


                if (bAddID &&
                    (bElementLang &&
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
                if ((bPrintLexCorr && tag == "errorlex") ||
                    (bPrintCorr && tag == "error") ||
                    (bPrintMorphSynCorr && tag == "errormorphsyn") ||
                    (bPrintOrtCorr && tag =="errorort") ||
                    (bPrintOrtRealCorr && tag == "errorortreal") ||
                    (bPrintSynCorr && tag == "errorsyn")) {
                    bBothTagAndOption = true;
                }
            } else if (tag == "document") {
                docLang = GetAttribValue(pParent->ToElement(), "xml:lang");
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
//             cerr << endl << "testing p: " << pParent->Parent()->Parent()->Value() << endl;
            if (bElementLang &&
                        ((bPrintPara && bInPara)   ||
                        (bPrintTitle && bInTitle) ||
                        (bPrintList && bInList)   ||
                        (bPrintTable && bInTable))) {
                if (bOutsideError) {
                    if (!bPrintTypos) {
                        output.append(pText->Value());
                        output.append(" ");
                    } else {
                        if (bPrintSpeller) {
                            string ptext = pText->Value();
                            while (ptext.find(" ") != string::npos) {
                                ptext = ptext.replace(ptext.find(" "), 1, "\n");
                            }
                            output.append(ptext);
                            output.append("\n");
                        }
                    }
                } else {
                    if ((bBothTagAndOption && !bPrintTypos) || bPrintOnlyCorr) {
                    } else {
                        if (bPrintTypos && !bBothTagAndOption && !bPrintSpeller &&
                            (bPrintCorr || bPrintLexCorr || bPrintMorphSynCorr || bPrintOrtCorr || bPrintOrtRealCorr || bPrintSynCorr)) {
                        } else {
                            output.append(pText->Value());
                        
                            if (!bPrintTypos) {
                                output.append(" ");
                            }
                        }
                    }
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
            RecurseTree(pChild, fileName);
        }
        if ( tag == "p" ) {
            if (bElementLang &&
                ((bPrintPara && bInPara)   ||
                (bPrintTitle && bInTitle) ||
                (bPrintList && bInList)   ||
                (bPrintTable && bInTable))) {
                if (hitString && !bPrintTypos) {
                    if (bAddID) {
                        output.append("</p>");
                    } else {
                        output.append("¶");
                    }
                    output.append("\n");
                }
            }
            // Set these variables as we leave p
            bInPara =  false;
            bInTitle = false;
            bInList = false;
            bInTable = false;
            cout << output;
        } else if ( tag.substr(0,5) == "error" ) {
            /*cout << endl;
            DumpTag(pParent->ToElement());
            cout << endl;
            */
            bOutsideError = true;
            string corr = GetAttribValue(pParent->ToElement(), "correct");

            if(bElementLang) {
                if(bPrintTypos) {
                    if (!bBothTagAndOption && 
                        (bPrintCorr || bPrintLexCorr || bPrintMorphSynCorr || bPrintOrtCorr || bPrintOrtRealCorr || bPrintSynCorr)) {
                        if (bPrintSpeller) {
                            output.append("\n");
                        }
                    } else {
                        if (corr != "") {
                            output.append("\t");
                            output.append(corr);
                        }
                        TiXmlAttribute* pAttrib=pParent->ToElement()->FirstAttribute();
                        bool firstattr = true;

                        while (pAttrib) {
                            string name = pAttrib->Name();
            //                 cout << endl << name << endl;
                            if (name != "correct") {
                                if (firstattr) {
                                    output.append("\t#");
                                    firstattr = false;
                                } else {
                                    output.append(",");
                                }
                                output.append(name);
                                output.append("=");
                                output.append(pAttrib->Value());
                            }
                            pAttrib = pAttrib->Next();
                        }
                        if (firstattr && bPrintFilename) {
                            output.append("\t#");
                        }
                        if (!firstattr && bPrintFilename) {
                            output.append(", ");
                        }
                        if (bPrintFilename) {
                            output.append("file: ");
                            output.append(fileName);
                        }
                        output.append("\n");
                    }
                } else if (bBothTagAndOption || bPrintOnlyCorr) {
                    if (corr != "") {
                        output.append(corr);
                        output.append(" ");
                    }

                }
            }
            if ((bPrintLexCorr && tag == "errorlex") ||
                (bPrintCorr && tag == "error") ||
                (bPrintMorphSynCorr && tag == "errormorphsyn") ||
                (bPrintOrtCorr && tag =="errorort") ||
                (bPrintOrtRealCorr && tag == "errorortreal") ||
                (bPrintSynCorr && tag == "errorsyn")) {
                bBothTagAndOption = false;
            }

        } else if ( tag == "document" ) {
            if (bAddID) {
                output.append("</");
                output.append(tag);
                output.append(">\n");
                cout << output;
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
    cout << "\t-f\t  Add the source filename as a comment after each error word.\n";
    cout << "\t\t\tOnly useful with the -r & (-typos | -S) options\n\n";

    cout << "Other options:\n";
    cout << "\t-r <dir>  Recursively process directory <dir> and subdirs encountered\n";
    cout << "\t-h\t  Print this help message\n";

    cout << endl;
}

void PrintVersion()
{
    cout << "ccat version " << version << endl;
}
