#include "globalstate.h"

GlobalState::GlobalState()
{
    bInPara = false;
    bInTitle = false;
    bInList = false;
    bInTable = false;

    bErrorFiltering = false;
    bPrintPara = true;
    bPrintTitle = false;
    bPrintList = false;
    bPrintTable = false;
    bPrintOnlyCorr = false;
    bPrintTypos = false;
    bPrintSpeller = false;
    bPrintFilename = false;
    bAddID = false;

    errorFilters["error"] = false;
    errorFilters["errorlex"] = false;
    errorFilters["errormorphsyn"] = false;
    errorFilters["errorort"] = false;
    errorFilters["errorortreal"] = false;
    errorFilters["errorsyn"] = false;
    errorFilters["errorlang"] = false;

    sLang = "";
}
