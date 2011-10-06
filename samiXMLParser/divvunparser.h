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
    void RecurseTree(TiXmlNode *pParent);
    
private:
    string GetErrorString(TiXmlNode *pParent);
    string GetExtErrorString(TiXmlNode *pParent);
    string GetCorrString(TiXmlNode *pParent);
    string GetAttrString(TiXmlNode *pParent);
    string FormatTypos(string errortext, string corrtext, string attrtext);
    string FormatCorrectString(TiXmlNode *pParent);
    string GetAttribValue(TiXmlElement *pElement, string attrName);
    void DumpTag(TiXmlElement *pElement);
    void SetbElementLang(TiXmlNode *pParent);
    void SetParaAttributes(TiXmlElement *element);
    
    GlobalState gs;
    string pFile;
    string docLang;
    string paraContent;
    bool bBothTagAndOption;
    bool bElementLang;
    bool bOutsideError;
    bool hitString;
    int errorDepth;
    string fileName;
};

#endif