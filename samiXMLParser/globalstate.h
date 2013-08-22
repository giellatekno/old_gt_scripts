#ifndef GLOBALSTATE_H
#define GLOBALSTATE_H

#include <string>
#include <map>

using namespace std;

class GlobalState {
public:
    GlobalState();

    bool bInPara;
    bool bInTitle;
    bool bInList;
    bool bInTable;

    bool bErrorFiltering;
    bool bPrintPara;
    bool bPrintTitle;
    bool bPrintList;
    bool bPrintTable;
    bool bPrintOnlyCorr;
    bool bSkipError;
    bool bPrintTypos;
    bool bPrintSpeller;
    bool bPrintFilename;
    bool bAddID;

    map<string, bool> errorFilters;
    string sLang;
};

#endif
