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
        bool parabElementLang;


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
                SetbElementLang(pParent);
                SetParaAttributes(pParent->ToElement());

                if (gs.bAddID &&
                    (bElementLang && IsInSomePara())) {
                    DumpTag(pParent->ToElement());
                }
            } else if (tag == "span") {
                // record the value of bElementLang of parent p
                parabElementLang = bElementLang;
                SetbElementLang(pParent);
            } else if (tag.substr(0,5) == "error") {
                errorDepth++;
                bOutsideError = false;

                bool hasText = false;

                for (pChild = pParent->FirstChild(); pChild != 0; pChild = pChild->NextSibling())
                {
                    if (pChild->Type() == TiXmlNode::TEXT) {
                        hasText = true;
                    }
                }
                if (!hasText) {
                    if (gs.bPrintTypos) {
                        if (!gs.bErrorFiltering || (gs.bErrorFiltering && gs.errorFilters[tag])) {
                            string errortext = GetExtErrorString(pParent);
                            string corrtext = GetCorrString(pParent);
                            string attribstext = GetAttrString(pParent);
                            paraContent.append(FormatTypos(errortext, corrtext, attribstext));
                        }
                    } else if (gs.bPrintSpeller) {
                        if (!gs.bErrorFiltering || (gs.bErrorFiltering && gs.errorFilters[tag])) {
                            string errortext = GetExtErrorString(pParent);
                            string corrtext = GetCorrString(pParent);
                            string attribstext = GetAttrString(pParent);
                            paraContent.append(FormatTypos(errortext, corrtext, attribstext));
                        }
                    } else if (gs.bPrintOnlyCorr) {
                        if (errorDepth == 0) {
                            paraContent.append(GetCorrString(pParent));
                        }
                    } else if (gs.bErrorFiltering && gs.errorFilters[tag]) {
                        paraContent.append(GetCorrString(pParent));
                    }
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
            if (bElementLang && IsInSomePara()) {
                if (string(pParent->Parent()->Value()).substr(0,5) != "error") {
                    if (gs.bPrintSpeller) {
                        string ptext = pText->Value();
                        while (ptext.find(" ") != string::npos) {
                            ptext = ptext.replace(ptext.find(" "), 1, "\n");
                        }
                        paraContent.append(ptext);
                        paraContent.append("\n");
                    } else if (!gs.bPrintTypos) {
                        paraContent.append(pText->Value());
                        paraContent.append(" ");
                    }
                } else if (!(string(pParent->Parent()->Value()) == "errorlang" and gs.bSkipError)) {
                    if (gs.bPrintTypos) {
                        if (!gs.bErrorFiltering || (gs.bErrorFiltering && gs.errorFilters[pParent->Parent()->Value()])) {
                            string errortext = GetExtErrorString(pParent->Parent());
                            string corrtext = GetCorrString(pParent->Parent());
                            string attribstext = GetAttrString(pParent->Parent());
                            paraContent.append(FormatTypos(errortext, corrtext, attribstext));
                        }
                    } else if (gs.bPrintSpeller) {
                        if (!gs.bErrorFiltering || (gs.bErrorFiltering && gs.errorFilters[pParent->Parent()->Value()])) {
                            string errortext = GetExtErrorString(pParent->Parent());
                            string corrtext = GetCorrString(pParent->Parent());
                            string attribstext = GetAttrString(pParent->Parent());
                            paraContent.append(FormatTypos(errortext, corrtext, attribstext));
                        } else {
                            string etext = pText->Value();
                            etext.append(" ");
                            while (etext.find(" ") != string::npos) {
                                etext = etext.replace(etext.find(" "), 1, "\n");
                            }
                            paraContent.append(etext);
                        }
                    } else if (gs.bPrintOnlyCorr) {
                        if (errorDepth == 0) {
                            paraContent.append(GetCorrString(pParent->Parent()));
                        }
                    } else if (gs.bErrorFiltering && gs.errorFilters[pParent->Parent()->Value()]) {
                        paraContent.append(GetCorrString(pParent->Parent()));
                    } else {
                        paraContent.append(pText->Value());
                        paraContent.append(" ");
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
            if (bElementLang && IsInSomePara()) {
                if (hitString) {
                    if (gs.bAddID) {
                        paraContent.append("</p>\n");
                    } else {
                        if (!gs.bPrintSpeller && !gs.bPrintTypos) {
                            paraContent.append("¶\n");
                        }
                    }
                }
            }
            // Set these variables as we leave p
            gs.bInPara =  false;
            gs.bInTitle = false;
            gs.bInList = false;
            gs.bInTable = false;
            cout << paraContent;
        } else if (tag == "span") {
            // set bElementLang to the value of the p
            bElementLang = parabElementLang;
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

    TiXmlNode* pChild = pParent->FirstChild();

    if (pChild->Type() == TiXmlNode::TEXT) {
        errortext.append(pChild->ToText()->Value());
        errortext.append(" ");
    }

    return errortext;
}

string DivvunParser::GetExtErrorString(TiXmlNode* pParent)
{
    string errortext;

    for (TiXmlNode* pChild = pParent->FirstChild(); pChild != 0; pChild = pChild->NextSibling())
    {
        if (pChild->Type() == TiXmlNode::TEXT) {
            errortext.append(pChild->ToText()->Value());
            errortext.append(" ");
        } else if (pChild->Type() == TiXmlNode::ELEMENT) {
            errortext.append(GetAttribValue(pChild->ToElement(), "correct"));
            errortext.append(" ");
        }
    }

    return errortext;
}

string DivvunParser::FormatTypos(string errortext, string corrtext, string attribstext)
{
    string result;

    result.append(errortext.substr(0, errortext.length() - 1));
    result.append("\t");
    result.append(corrtext.substr(0, corrtext.length() - 1));

    if (!attribstext.empty()) {
        result.append("\t#");
        result.append(attribstext);
    }

    if (gs.bPrintFilename) {
        if (attribstext.empty()) {
            result.append("\t#");
        } else {
            result.append(", ");
        }
        result.append("file: ");
        result.append(fileName);
    }

    result.append("\n");

    return result;
}

string DivvunParser::GetCorrString(TiXmlNode *pParent) {
    string result;

    result.append(GetAttribValue(pParent->ToElement(), "correct"));
    result.append(" ");

    return result;
}

string DivvunParser::GetAttrString(TiXmlNode* pParent)
{
    string result;

    TiXmlAttribute* pAttrib=pParent->ToElement()->FirstAttribute();
    bool firstattr = true;

    while (pAttrib) {
        string name = pAttrib->Name();
        if (name.find("correct") == string::npos) {
            if (firstattr) {
                firstattr = false;
            } else {
                result.append(",");
            }
            result.append(name);
            result.append("=");
            result.append(pAttrib->Value());
        }
        pAttrib = pAttrib->Next();
    }

    return result;
}

void DivvunParser::SetbElementLang(TiXmlNode* pParent)
{
    string pLang = GetAttribValue(pParent->ToElement(), "xml:lang");
    if (gs.sLang == "") {
        bElementLang = true;
    } else if (gs.sLang == docLang) {
        bElementLang = (pLang == "" || pLang == docLang)? true : false;
    } else {
        bElementLang = pLang == gs.sLang ? true : false;
    }
}

void DivvunParser::SetParaAttributes(TiXmlElement* element)
{
    gs.bInPara = (GetAttribValue(element, "type") == "" ||  GetAttribValue(element, "type") == "text") ? true : false;
    gs.bInTitle = GetAttribValue(element, "type") == "title" ? true : false;
    gs.bInList = GetAttribValue(element, "type") == "listitem" ? true : false;
    gs.bInTable = GetAttribValue(element, "type") == "tablecell" ? true : false;
}

bool DivvunParser::IsInSomePara()
{
    return ((gs.bPrintPara && gs.bInPara) ||
            (gs.bPrintTitle && gs.bInTitle) ||
            (gs.bPrintList && gs.bInList) ||
            (gs.bPrintTable && gs.bInTable));
}
