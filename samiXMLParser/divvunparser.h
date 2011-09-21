#ifndef DIVVUNPARSER_H
#define DIVVUNPARSER_H

#include <string>
#include "globalstate.h"
#include "tinyxml.h"

using namespace std;

class DivvunParser {
public:
    DivvunParser(string inFile, GlobalState inGs);
    void ProcessFile();
    void RecurseTree(TiXmlNode *pParent, string fileName);
    string GetAttribValue(TiXmlElement *pElement, string attrName);
    void DumpTag(TiXmlElement *pElement);
    
private:
    string GetErrorString(TiXmlNode *pChild);
    string FormatErrorString(string errortext);
    
    GlobalState gs;
    string pFile;
    string docLang;
    string paraContent;
    bool bBothTagAndOption;
    bool bElementLang;
    bool bOutsideError;
    bool hitString;
    int errorDepth;
};

#endif