#ifndef __TAGFILE__xx_yy_
#define __TAGFILE__xx_yy_

#include "basic.h"
#include "tmplcoll.h"

/////////////////////////////////////////////////////////////////////////
class TagAttribute
{
public:
  TagAttribute(string &_Name,string &_Value)
	: Name(_Name) , Value(_Value)
  {
  }
  const string & getName() const
  {
	return Name;
  }
  const string & getValue() const
  {
	return Value;
  }
protected:	
  string Name;
  string Value;
};

/////////////////////////////////////////////////////////////////////////
class TagParser
{
public:

  enum tagUnitType
  {
	EOFTAG,
    TAG_WORD,
    TAG_START_TAG,
    TAG_END_TAG	
  };
  enum { MAX_TOKEN = 20 };

  TagParser(ios *pStream,bool ConvertSpecialChars = true,bool TagToLower = true);
  TagParser(streambuf *pBuf,bool ConvertSpecialChars = true,bool TagToLower = true);
  
  // general access methods
  tagUnitType Type() const;  
  const string &Value() const;

  // if type == TAG_START_TAG
  bool         GetNextToken();

  const list<TagAttribute*> &GetAttribs() const;

  const char * GetValue(const char *pName) const;
  string       sGetValue(const char *pName) const;

  string GetFullText();

protected:
  virtual bool ProcessSpecialChar(char *&in,char *&out);

  bool ParseTag();
  void ParseTagAttribs();
  bool ParseToken();  

  BasicParser  tok;
  tagUnitType  type;
  string       Token;
  save_ptr_list<TagAttribute> attr;
  bool         ConvertSpecialChars;
  bool         TagToLower;
};

/////////////////////////////////////////////////////////////////////////
/*
class TagFactory
{
public:

    enum tagUnitType
    {
        EOFTAG,
        TAG_WORD,
        TAG_START_TAG,
        TAG_END_TAG
    };
    enum { MAX_TOKEN = 20 };
    
    TagFactory(streambuf *pBuf, bool ConvertSpecialChars = true, TagToLower = true);
    
    void Type(const tagUnitType eType);
    void Value(const string sValue);
};
*/
inline TagParser::tagUnitType TagParser::Type() const
{
  return type;
}

inline const string &TagParser::Value() const 
{ 
  return Token; 
}

inline const list<TagAttribute*> &TagParser::GetAttribs() const
{
  return attr;
}

#endif
