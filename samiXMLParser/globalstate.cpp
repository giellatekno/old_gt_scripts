#include "globalstate.h"

GlobalState::GlobalState()
{
    bInPara = false;
    bInTitle = false;
    bInList = false;
    bInTable = false;

    bPrintPara = true;
    bPrintTitle = false;
    bPrintList = false;
    bPrintTable = false;
    bPrintCorr = false;
    bPrintOrtCorr = false;
    bPrintOrtRealCorr = false;
    bPrintSynCorr = false;
    bPrintLexCorr = false;
    bPrintMorphSynCorr = false;
    bPrintOnlyCorr = false;
    bPrintTypos = false;
    bPrintSpeller = false;
    bPrintFilename = false;
    bAddID = false;
    
    sLang = "";
}
