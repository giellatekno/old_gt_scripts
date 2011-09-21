#ifndef GLOBALSTATE_H
#define GLOBALSTATE_H

#include <string>

using namespace std;

class GlobalState {
public:
    GlobalState();
    
    bool bInPara;
    bool bInTitle;
    bool bInList;
    bool bInTable;

    bool bPrintPara;
    bool bPrintTitle;
    bool bPrintList;
    bool bPrintTable;
    bool bPrintCorr;
    bool bPrintOrtCorr;
    bool bPrintOrtRealCorr;
    bool bPrintSynCorr;
    bool bPrintLexCorr;
    bool bPrintMorphSynCorr;
    bool bPrintOnlyCorr;
    bool bPrintTypos;
    bool bPrintSpeller;
    bool bPrintFilename;
    bool bAddID;
  
    string sLang;
};

#endif