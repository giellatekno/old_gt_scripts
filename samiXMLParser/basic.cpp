#include "stdafx.h"
#include "basic.h"

//////////////////////////////////////////////////////////////////////////////
#define MAP_SIZE 32


CharSet::CharSet()
{
  memset(Mask,0,MAP_SIZE);
}

CharSet::CharSet(const char *sSkipChars,bool bNegate)
{
  skipChars(sSkipChars,bNegate);
}

void CharSet::skipChars(const char *sChars,bool bNegate)
{
  if (bNegate)
    AddCharsToMaskN(sChars,true);
  else
    AddCharsToMask(sChars,true);
}

void CharSet::AddCharsToMask(const char *pMask,bool bReset)
{
  if (bReset)
    memset(Mask,0,MAP_SIZE);
  for(unsigned char *ctrl = (unsigned char*) pMask;*ctrl;*ctrl++)
    Mask[*ctrl >> 3] |= (1 << (*ctrl & 7));    
}

void CharSet::AddCharsToMaskN(const char *pMask,bool bReset)
{
  if (bReset)
    memset(Mask,0xFF,MAP_SIZE);
  for(unsigned char *ctrl = (unsigned char*) pMask;*ctrl;*ctrl++)
    Mask[*ctrl >> 3] &= ~ (1 << (*ctrl & 7));    
}

//////////////////////////////////////////////////////////////////////////////
BasicParser::BasicParser()
           : pBuf(0)
		   , LineNo(0)
		   , UngetChar(false)
		   , lowercase(false)
{
  resetSkipChars();
}

BasicParser::BasicParser(ios *pStream)
           : pBuf(pStream->rdbuf())
		   , LineNo(0)
		   , UngetChar(false)
		   , lowercase(false)
{
  resetSkipChars();
}

BasicParser::BasicParser(streambuf *_pBuf)
           : pBuf(_pBuf)
		   , LineNo(0)
		   , UngetChar(false)
		   , lowercase(false)
{
  resetSkipChars();
}

BasicParser::~BasicParser()
{
}

//////////////////////////////////////////////////////////////////////////////
bool BasicParser::getline(string &Token,int NewLineSign)
{
  char Buf[UCHAR_MAX];
  int  ch;
  int  i=0;

  Token = "";
  for(;(ch=getch())!=EOF;i++)
  {    
	if (ch == NewLineSign)
	  break;

	if (i >= UCHAR_MAX)
	{
	  Token.append(Buf,UCHAR_MAX);
	  i=0;
	}
  	else
	  Buf[i] = (char) ch;
  }
  if (i>0)  
    Token.append(Buf,i);  
  
  return ch!=EOF;
}

//////////////////////////////////////////////////////////////////////////////
int  BasicParser::skip(CharSet &sSkip)
{
  int  ch;
  int  i=0;

  while((ch=getch())!=EOF)
  {    
	if (!sSkip.isInSet(ch))
	{
	  ungetch();
	  return ch;
	}
  }  
  return EOF;
}

//////////////////////////////////////////////////////////////////////////////
int  BasicParser::getWord(string &Token,CharSet &sSkip)
{
  char Buf[UCHAR_MAX];  
  int  ch;
  int  i=0;

  Token = "";
  for(;(ch=getch())!=EOF;i++)
  {    
	if (sSkip.isInSet(ch))
	{
	  ungetch();
	  break;
	}

	if (i >= UCHAR_MAX)
	{
	  Token.append(Buf,UCHAR_MAX);
	  i=0;
	}
	else
	  Buf[i] = (char) ch;
  }
  if (i>0)  
    Token.append(Buf,i);  

  if (lowercase)
	ToLower(Token);
  
  return ch;
}

//////////////////////////////////////////////////////////////////////////////
int  BasicParser::getNumber(string &Token,CharSet &sSkip)
{
  char Buf[UCHAR_MAX];
  int  ch;
  int  i=0;

  Token = "";
  for(;(ch=getch())!=EOF;i++)
  {    
	if (!isdigit(ch))
	{
	  ungetch();
	  break;
	}

	if (i >= UCHAR_MAX)
	{
	  Token.append(Buf,UCHAR_MAX);
	  i=0;
	}
	else
	  Buf[i] = (char) ch;
  }
  if (i>0)  
    Token.append(Buf,i);  
  
  if (lowercase)
	ToLower(Token);

  return ch;
}

//////////////////////////////////////////////////////////////////////////////
int  BasicParser::getWordOrNum(string &Token,CharSet &sSkip)
{
  int ch = getch();
  ungetch();

  if (isdigit(ch))
	return getNumber(Token,sSkip);
  return getWord(Token,sSkip);
}

//////////////////////////////////////////////////////////////////////////////
void BasicParser::ToLower(string &arg)
{
  char *p = (char *) arg.c_str();

  while(*p!='\0')  
	*p++ = tolower(*p);  
}

//////////////////////////////////////////////////////////////////////////////
int  BasicParser::getWord(string &Token,const char *sSkipChars,bool bNegate)
{  
  CharSet Set(sSkipChars,bNegate);
  return getWord(Token,Set);
}

int  BasicParser::getNumber(string &Token,const char *sSkipChars,bool bNegate)
{
  CharSet Set(sSkipChars,bNegate);
  return getNumber(Token,Set);
}

int  BasicParser::getWordOrNum(string &Token,const char *sSkipChars,bool bNegate)
{
  CharSet Set(sSkipChars,bNegate);
  return getWordOrNum(Token,Set);
}

int  BasicParser::skip(const char *sSkipChars,bool bNegate)
{
  CharSet Set(sSkipChars,bNegate);
  return skip(Set);
}
