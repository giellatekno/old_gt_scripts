#include "globalstate.h"
#include "divvunparser.h"
#include <iostream>
#include <sstream>


DivvunParser::DivvunParser(string inFile, GlobalState inGs)
{
    pFile = inFile;
    bBothTagAndOption = false;
    bElementLang = false;
    bOutsideError = true;
    hitString = false;
    gs = inGs;
    errorDepth = -1;
}

void DivvunParser::ProcessFile()
{
    TiXmlDocument doc(pFile.c_str());
    fileName = pFile.substr(pFile.rfind("/") + 1);
    doc.LoadFile();

    TiXmlHandle docHandle( &doc );

    RecurseTree(docHandle.FirstChild("document").ToNode());
}

void DivvunParser::RecurseTree(TiXmlNode* pParent)
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
                paraContent = "";
                string pLang = GetAttribValue(pParent->ToElement(), "xml:lang");
                if (gs.sLang == "" || gs.sLang == docLang) {
                    bElementLang = (pLang == "" || pLang == docLang)? true : false;
                } else {
                    bElementLang = pLang == gs.sLang ? true : false;
                }
                gs.bInPara = (GetAttribValue(pParent->ToElement(), "type") == "" ||  GetAttribValue(pParent->ToElement(), "type") == "text") ? true : false;
                gs.bInTitle = GetAttribValue(pParent->ToElement(), "type") == "title" ? true : false;
                gs.bInList = GetAttribValue(pParent->ToElement(), "type") == "listitem" ? true : false;
                gs.bInTable = GetAttribValue(pParent->ToElement(), "type") == "tablecell" ? true : false;


                if (gs.bAddID &&
                    (bElementLang &&
                    (gs.bPrintPara && gs.bInPara)   ||
                    (gs.bPrintTitle && gs.bInTitle) ||
                    (gs.bPrintList && gs.bInList)   ||
                    (gs.bPrintTable && gs.bInTable)
                    )
                ) {
                    DumpTag(pParent->ToElement());
                }
            } else if (tag.substr(0,5) == "error") {
                errorDepth++;
                bOutsideError = false;
                if ((gs.bPrintLexCorr && tag == "errorlex") ||
                    (gs.bPrintCorr && tag == "error") ||
                    (gs.bPrintMorphSynCorr && tag == "errormorphsyn") ||
                    (gs.bPrintOrtCorr && tag =="errorort") ||
                    (gs.bPrintOrtRealCorr && tag == "errorortreal") ||
                    (gs.bPrintSynCorr && tag == "errorsyn")) {
                    bBothTagAndOption = true;
                }
//                 cerr << "BTAO: " << bBothTagAndOption << " tag: " << tag << "\n";
    
                if (bElementLang &&
                ((gs.bPrintPara && gs.bInPara)   ||
                (gs.bPrintTitle && gs.bInTitle) ||
                (gs.bPrintList && gs.bInList)   ||
                (gs.bPrintTable && gs.bInTable))) {
                    string errortext = GetErrorString(pParent);
                    paraContent.append(FormatErrorString(errortext));
                    paraContent.append(FormatCorrectString(pParent));
                }

                if ((gs.bPrintLexCorr && tag == "errorlex") ||
                    (gs.bPrintCorr && tag == "error") ||
                    (gs.bPrintMorphSynCorr && tag == "errormorphsyn") ||
                    (gs.bPrintOrtCorr && tag =="errorort") ||
                    (gs.bPrintOrtRealCorr && tag == "errorortreal") ||
                    (gs.bPrintSynCorr && tag == "errorsyn")) {
                    bBothTagAndOption = false;
                }

            
            } else if (tag == "document") {
                docLang = GetAttribValue(pParent->ToElement(), "xml:lang");
                if (gs.bAddID) {
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
            if (bElementLang &&
                ((gs.bPrintPara && gs.bInPara)   ||
                (gs.bPrintTitle && gs.bInTitle) ||
                (gs.bPrintList && gs.bInList)   ||
                (gs.bPrintTable && gs.bInTable))) {
                if (string(pParent->Parent()->Value()).substr(0,5) != "error") {
                    if (!gs.bPrintTypos) {
                        paraContent.append(pText->Value());
                        paraContent.append(" ");
                    } else {
                        if (gs.bPrintSpeller) {
                            string ptext = pText->Value();
                            while (ptext.find(" ") != string::npos) {
                                ptext = ptext.replace(ptext.find(" "), 1, "\n");
                            }
                            paraContent.append(ptext);
                            paraContent.append("\n");
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
            RecurseTree(pChild);
        }
        if ( tag == "p" ) {
            if (bElementLang &&
                ((gs.bPrintPara && gs.bInPara)   ||
                (gs.bPrintTitle && gs.bInTitle) ||
                (gs.bPrintList && gs.bInList)   ||
                (gs.bPrintTable && gs.bInTable))) {
                if (hitString && !gs.bPrintTypos) {
                    if (gs.bAddID) {
                        paraContent.append("</p>");
                    } else {
                        paraContent.append("¶");
                    }
                    paraContent.append("\n");
                }
            }
            // Set these variables as we leave p
            gs.bInPara =  false;
            gs.bInTitle = false;
            gs.bInList = false;
            gs.bInTable = false;
            cout << paraContent;
        } else if ( tag.substr(0,5) == "error" ) {
            /*cout << endl;
            DumpTag(pParent->ToElement());
            cout << endl;
            */
            errorDepth--;
            bOutsideError = true;

            

        } else if ( tag == "document" ) {
            if (gs.bAddID) {
                paraContent.append("</");
                paraContent.append(tag);
                paraContent.append(">\n");
                cout << paraContent;
            }
        }
    }
}

string DivvunParser::GetAttribValue(TiXmlElement *pElement, string attrName)
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


void DivvunParser::DumpTag(TiXmlElement* pElement)
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

string DivvunParser::GetErrorString(TiXmlNode* pParent)
{
    string errortext;
    for (TiXmlNode* pChild = pParent->FirstChild(); pChild != 0; pChild = pChild->NextSibling())
    {
        if (pChild->Type() == TiXmlNode::TEXT) {
            errortext.append(pChild->ToText()->Value());
            errortext.append(" ");
        } else if (pChild->Type() == TiXmlNode::ELEMENT && (gs.bPrintOnlyCorr || gs.bPrintTypos) && !gs.bPrintSpeller) {
            errortext.append(GetAttribValue(pChild->ToElement(), "correct"));
            errortext.append(" ");
        } if (pChild->Type() == TiXmlNode::ELEMENT && gs.bPrintSpeller && bBothTagAndOption) {
            errortext.append(GetAttribValue(pChild->ToElement(), "correct"));
            errortext.append(" ");
        }
    }
    return errortext;
}

string DivvunParser::FormatErrorString(string errortext)
{
    string result;
    if ((bBothTagAndOption && !gs.bPrintTypos) || gs.bPrintOnlyCorr) {
    } else {
        if (gs.bPrintTypos && !bBothTagAndOption && !gs.bPrintSpeller &&
            (gs.bPrintCorr || gs.bPrintLexCorr || gs.bPrintMorphSynCorr || gs.bPrintOrtCorr || gs.bPrintOrtRealCorr || gs.bPrintSynCorr)) {
        } else {
            if (gs.bPrintSpeller  && !bBothTagAndOption && 
                (gs.bPrintCorr || gs.bPrintLexCorr || gs.bPrintMorphSynCorr || gs.bPrintOrtCorr || gs.bPrintOrtRealCorr || gs.bPrintSynCorr)) {
                while (errortext.find(" ") != string::npos) {
                    errortext = errortext.replace(errortext.find(" "), 1, "\n");
                }
                result.append(errortext);
            } else { 
                if (gs.bPrintTypos) {
                    result.append(errortext.substr(0, errortext.length() - 1));
                } else {
                    result = errortext;
                }
            }
        }
    }
    return result;
}

string DivvunParser::FormatCorrectString(TiXmlNode* pParent)
{
    string result;
    
    string corr = GetAttribValue(pParent->ToElement(), "correct");
    pParent->ToElement()->RemoveAttribute("correct");
    
    if(gs.bPrintTypos) {
        if (!bBothTagAndOption && 
            (gs.bPrintCorr || gs.bPrintLexCorr || gs.bPrintMorphSynCorr || gs.bPrintOrtCorr || gs.bPrintOrtRealCorr || gs.bPrintSynCorr)) {
        } else {
            if (corr != "") {
                result.append("\t");
                result.append(corr);
            }
            TiXmlAttribute* pAttrib=pParent->ToElement()->FirstAttribute();
            bool firstattr = true;

            while (pAttrib) {
                string name = pAttrib->Name();
//                 cout << endl << name << endl;
                if (firstattr) {
                    result.append("\t#");
                    firstattr = false;
                } else {
                    result.append(",");
                }
                result.append(name);
                result.append("=");
                result.append(pAttrib->Value());
                pAttrib = pAttrib->Next();
            }
            if (firstattr && gs.bPrintFilename) {
                result.append("\t#");
            }
            if (!firstattr && gs.bPrintFilename) {
                result.append(", ");
            }
            if (gs.bPrintFilename) {
                result.append("file: ");
                result.append(fileName);
            }
            result.append("\n");
        }
    } else if (bBothTagAndOption || (gs.bPrintOnlyCorr && errorDepth < 1)) {
        if (corr != "") {
            result.append(corr);
            result.append(" ");
        }

    }
    
    return result;
}

