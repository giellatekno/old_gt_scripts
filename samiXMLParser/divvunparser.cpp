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
                } else {
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
            if (bElementLang &&
                ((gs.bPrintPara && gs.bInPara)   ||
                (gs.bPrintTitle && gs.bInTitle) ||
                (gs.bPrintList && gs.bInList)   ||
                (gs.bPrintTable && gs.bInTable))) {
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
