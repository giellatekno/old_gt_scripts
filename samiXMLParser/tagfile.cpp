#include "stdafx.h"
#include "tagfile.h"

//===========================================================    	
struct SpecialCharTable
{
  char *TheString;
  int   TheStringLen;
  int   Value;
}
  Table[] = 
  {
	{ "&quot;", 6 , '"'   },
	{ "&amp;" , 5 , '&'   },
    { "&lt;"  , 4 , '<'   },
	{ "&gt;"  , 4 , '>'   },
	{ "&nbsp;", 6 , ' '   },
	{ 0       , 0 , 0     }
  };

//===========================================================
TagParser::TagParser(ios *pStream,bool _ConvertSpecialChars,bool _TagToLower)
         : tok(pStream)
		 , ConvertSpecialChars(_ConvertSpecialChars)
		 , TagToLower(_TagToLower)
{
}

TagParser::TagParser(streambuf *pBuf,bool _ConvertSpecialChars,bool _TagToLower)
         : tok(pBuf)
		 , ConvertSpecialChars(_ConvertSpecialChars)
		 , TagToLower(_TagToLower)
{
}

//===========================================================
bool TagParser::GetNextToken()
{
  int ch;

  Token = "";

  if ((ch = tok.skip()) !=EOF)
  {
    if (ch == '<')
	  return ParseTag();
    return ParseToken();
  }
  return false;
}

//===========================================================
bool TagParser::ParseTag()
{
  int ch;

  if (attr.size())
  {
   //attr.DeleteAll();
   for (save_ptr_list<TagAttribute>::iterator i = attr.begin();i!=attr.end();++i)
   {
     delete (*i);
   }
   attr.clear();
  }

  ch = tok.getch();
  ch = tok.getch();
  if (ch == EOF)
	return false;

  if (ch == '/')
	type = TAG_END_TAG;
  else
  {
    type = TAG_START_TAG;
    tok.ungetch();
  }

  // does the tag have attributes ? 
  // (i.e. is the tag followed by a space)
  if (tok.getWord(Token," \n\r\t>")!='>')  
    ParseTagAttribs();
  if (TagToLower)
	tok.ToLower(Token);
  
  ch = tok.getch();
  assert(ch == '>');
  return true;
}

//===========================================================    	
void TagParser::ParseTagAttribs()
{ 
  string Name;
  string Value;

  while(1)
  {
    if (tok.skip(" \t\n\"") == '>')
	  return;	
    if (tok.getWord(Name," \t\n=>"))
	{	 
	  bool bHasClose = false;

	  if (tok.skip() == '=')
		tok.getch();

	  if (tok.skip() == '"')
	  {
		tok.getch();
		bHasClose = true;
	  }
	  else
		tok.ungetch();

	  if (bHasClose)
	    tok.getWord(Value,"\"\t\n>");	  
	  else
		tok.getWord(Value," \"\t\n>");	  

	  if (TagToLower)
	  {
		tok.ToLower(Name);
	    tok.ToLower(Value);
	  }

	  attr.push_back(new TagAttribute(Name,Value));
	}
	else
	  break;
  }
}

//===========================================================    	
bool TagParser::ParseToken()
{
  type = TAG_WORD;
  tok.getWord(Token," \n\t<");

  if (Token == "")
	return false;

  if (!ConvertSpecialChars)
	return true;

  // substitue special characters
  // (makes the string 
  char *out;
  char *in;

  for(in = out = (char*) Token.c_str(); *in !='\0'; out++)
  {
	 if ( *in == '&')
	 {
	   if (!ProcessSpecialChar(in,out))
	     *out = *in++;
	 }
	 else
		 *out = *in++;
  }
  *out = '\0';
  return true;  
}
		   
//===========================================================    	
bool TagParser::ProcessSpecialChar(char *&in,char *&out)
{
   char *nextchar = in+1;

   if (*nextchar == '#')	   
   {
	  ++nextchar;
	  *out = atoi(nextchar);		  	   		  
	  while(isdigit(*nextchar))
		nextchar ++;
	  in = nextchar;
   }
   else
   {
	 int i;

	 for(i=0;Table[i].TheStringLen!=0;i++) 
	 {
		if (strncmp(in,Table[i].TheString,Table[i].TheStringLen)==0)
		{
		  *out = Table[i].Value; 
		  in +=  Table[i].TheStringLen;
		  break;
		}
	 }	  		
	 if (!Table[i].TheStringLen)
	   return false;
   }
   return true;
}

//===========================================================    	
string       TagParser::sGetValue(const char *pName) const
{
  for(list<TagAttribute*>::const_iterator i = attr.begin();i!=attr.end();++i)
  {
//    string str = (*i)->getName().c_str();
//    transform(str.begin(), str.end(), str.begin(), _tolower);
    if (strcmp((*i)->getName().c_str(),pName)==0)
	  return (*i)->getValue();
  }
  return "";
}

//===========================================================    	
const char * TagParser::GetValue(const char *pName) const
{
  for(list<TagAttribute*>::const_iterator i = attr.begin();i!=attr.end();++i)
  {
//    string str = (*i)->getName().c_str();
//    transform(str.begin(), str.end(), str.begin(), _tolower);
    if (strcmp((*i)->getName().c_str(),pName)==0)
	  return (*i)->getValue().c_str();
  }
  return "";
}

//===========================================================    	
string TagParser::GetFullText()
{
  switch(Type())
  {
    case TagParser::TAG_START_TAG:
	{
		 string ret;

		 ret = string("<") + Value();
		 const list<TagAttribute*> &lst = GetAttribs();

		 if (lst.size())
		 {
			ret += string(" ");
		    for(list<TagAttribute*>::const_iterator i = lst.begin(); i != lst.end();++i)
  		      ret += (*i)->getName() + "=" + (*i)->getValue() + " ";
		 }
		 ret += ">";
	 }
	  break;
    case TagParser::TAG_END_TAG:
	  return string("</") + Value() + ">";
    case TagParser::TAG_WORD:
	  return Value();
  } 
  return "";
}