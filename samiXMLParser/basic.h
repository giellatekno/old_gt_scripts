#ifndef __BASIC_PARSER_XX_YY_
#define __BASIC_PARSER_XX_YY_

//#include <strstream>
//#include <ios>
//#include <streambuf>
//#include <string>

//typedef basic_ios<char> ios;

//=============================================================
class CharSet
{
friend class BasicParser;
public:
       CharSet        ();
       CharSet        (const char *sSkipChars,bool bNegate = false);
  
  void skipChars      (const char *sSkipChars,bool bNegate = false);  
  int  isInSet        (int ch);

  void AddCharsToMask (const char *pMask,bool bReset);
  void AddCharsToMaskN(const char *pMask,bool bReset);

protected:
  unsigned char Mask[32];
};

inline int CharSet::isInSet(int ch)
{
  return Mask[ch >> 3] & (1 <<(ch & 7));
}

//=============================================================
class BasicParser
{
public:
	   BasicParser    ();
       BasicParser    (ios *pStream);
       BasicParser    (streambuf *pBuf);
  virtual ~BasicParser();
  void setInput       (streambuf *pBuf);

  // reads a new line.
  bool getline        (string &Token,int NewLineSign = '\n');
  // returns the next character.
  int  getch          ();
  // ungets the last character (only one level deep).
  int  ungetch        ();

  //***sets the current set of skip chars.
  void skipChars      (const char *sSkipChars,bool bNegate = false);
  void resetSkipChars ();

  //***process characters (according to current skip chars).
  int  getWord        (string &Token);  
  int  getNumber      (string &Token);
  int  getWordOrNum   (string &Token);    
  int  skip           ();
	   
  //***process characters (according to argument skip chars).
  int  getWord        (string &Token,const char *sSkipChars,bool bNegate = false);  
  int  getNumber      (string &Token,const char *sSkipChars,bool bNegate = false);
  int  getWordOrNum   (string &Token,const char *sSkipChars,bool bNegate = false);    
  int  skip           (const char *sSkipChars,bool bNegate = false);

  //***process characters (according to argument skip chars set).
  int  getWord        (string &Token,CharSet &sSkip);  
  int  getNumber      (string &Token,CharSet &sSkip);
  int  getWordOrNum   (string &Token,CharSet &sSkip);    
  int  skip           (CharSet &sSkip);

  // set lowercase mode (if lowercase mode, all tokens are turned to lowercase).
  void lowercaseMode  (bool  Mode);

  // returns the current line number.
  int  lineno() const;

  // returns true if end of input stream is reached.
  bool isEof() const;  
 
  void ToLower(string &arg);
protected:

  CharSet       SkipChars;
  streambuf    *pBuf;
  int           LineNo;
  bool          lowercase;

  bool          UngetChar;
  int           curChar;
};

//=============================================================
class StringParser : public BasicParser
{
public:
  StringParser(const char *pTheString);
  StringParser(string &str);

protected:
  istringstream str;
};

//=============================================================
inline void BasicParser::setInput(streambuf *_pBuf)
{
  pBuf = _pBuf;
  LineNo = 0;
}
  
inline int  BasicParser::lineno() const
{
  return LineNo;
}

inline bool BasicParser::isEof() const
{
  return false;
}

inline int  BasicParser::getch()
{
  if (UngetChar)
  {
    UngetChar = false;
	return curChar;
  }
/*
  return (pBuf->gptr() != 0 && pBuf->gptr() < pBuf->egptr()
			? (int) (unsigned int)*_Gninc() : uflow());
 */
  curChar = pBuf->sbumpc();
  if (curChar == '\n')
	++LineNo;
  
  return curChar;
}

inline int BasicParser::ungetch()
{
  UngetChar = true;
  return UngetChar;
}

inline void BasicParser::lowercaseMode(bool  Mode)
{
  lowercase = Mode;
}

inline int  BasicParser::getWord(string &Token)
{
  return getWord(Token,SkipChars);
}

inline int  BasicParser::getNumber(string &Token)
{
  return getNumber(Token,SkipChars);
}

inline int  BasicParser::getWordOrNum(string &Token)
{
  return getWordOrNum(Token,SkipChars);
}

inline int  BasicParser::skip()
{
  return skip(SkipChars);
}

inline void BasicParser::skipChars(const char *sChars,bool bNegate)
{
  SkipChars.skipChars(sChars,bNegate);
}

inline void BasicParser::resetSkipChars()
{
  SkipChars.skipChars(" \t\n\r",false);
}

//=============================================================
inline StringParser::StringParser(const char *pstr)
            : BasicParser(str.rdbuf())
			, str(pstr)
{
}

inline StringParser::StringParser(string &_str)
            : BasicParser(str.rdbuf())
            , str(_str.c_str())
{
}

#endif
