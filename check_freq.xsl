<?xml version="1.0"?>
<!--+
    | 
    | compares two lists of words and outputs both the intersection set
    | and the set of items which are in the first but not in the second set
    | NB: The user has to adjust the paths to the input files accordingly
    | Usage: java net.sf.saxon.Transform -it main THIS_FILE
    | 
    | Input f-sorted file (s_lemma.txt):
    | 30	og
    | 28	i
    | 8	veg
    | 1	Oslo
    | 
    | Input unsorted file (u_lemma.txt):
    | i
    | på
    | veg
    | til
    | Tromsø
    | og
    | bord
    | om
    | 
    | command (with parameter adjusted inside the file)
    | _six check_freq.xsl
    | 
    | Output file (out/output_stuff.txt):
    | 
    | 30      og
    | 28      i
    | 8       veg
    | 
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="xs">

  <xsl:strip-space elements="*"/>

  <xsl:output method="text" name="txt"
	      encoding="UTF-8"
	      omit-xml-declaration="yes"
	      indent="no"/>

  <xsl:output method="xml" name="xml"
              encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:variable name="tab" select="'&#x9;'"/>
  <xsl:variable name="spc" select="'&#x20;'"/>
  <xsl:variable name="nl" select="'&#xA;'"/>
  <xsl:variable name="cl" select="':'"/>
  <xsl:variable name="scl" select="';'"/>
  <xsl:variable name="us" select="'_'"/>
  <xsl:variable name="qm" select="'&#34;'"/>
  <xsl:variable name="cm" select="','"/>

  <xsl:param name="sl" select="'sma'"/>
  <xsl:param name="tl" select="'nob'"/>
  <xsl:variable name="debug" select="true()"/>
  <xsl:variable name="of" select="'txt'"/>
  <xsl:variable name="e" select="$of"/>


  <!-- input file, extention of the output file -->
  <xsl:param name="inFile_ns" select="'u_lemma.txt'"/>
  <xsl:param name="inFile_s" select="'s_lemma.txt'"/>
  <xsl:param name="outDir" select="'out'"/>
  
  <!-- xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.tbx')"/ -->
  <xsl:param name="regex_01" select="'^([^\,]+),([^\,]+),([^\,]+),([^\,]+),([^\,]+),([^\,]+),([^\,]+)$'"/>
  <xsl:param name="regex_02" select="'^([^\,]+),([^\,]+),([^\,]+),([^\,]+),([^\,]+),([^\,]+),([^\,]+)$'"/>


  <xsl:template match="/" name="main">
    
    <xsl:choose>
      <xsl:when test="unparsed-text-available($inFile_ns) and unparsed-text-available($inFile_s)">

	<!-- file -->
	<xsl:variable name="file_s" select="unparsed-text($inFile_s)"/>
	<xsl:variable name="file_ns" select="unparsed-text($inFile_ns)"/>

	<xsl:variable name="file_lines_s" select="tokenize($file_s, $nl)" as="xs:string+"/>
	<!-- xsl:variable name="file_lines_ns" select="tokenize($file_ns, $nl)" as="xs:string+"/ -->

	<xsl:variable name="file_string_ns">
	  <instances>
	    <xsl:for-each select="tokenize($file_ns, $nl)">
	      <xsl:value-of select="concat('__', .)"/>	      
	    </xsl:for-each>
	      <xsl:value-of select="'__'"/>
	  </instances>
	</xsl:variable>

	<xsl:result-document href="{$outDir}/output_stuff.{$e}" format="{$of}">
	  <xsl:for-each select="$file_lines_s[not(normalize-space(.) = '')]">

	    <xsl:variable name="c_lemma" select="substring-after(., $tab)"/>
	    
	    <xsl:if test="contains($file_string_ns, $c_lemma)">
	      <xsl:message terminate="no">
		<xsl:value-of select="concat('current freq-sorted lemma ... ', ., ' __IN__ ', $nl)"/>
	      </xsl:message>
	      <xsl:value-of select="concat(., $nl)"/>
	    </xsl:if>
	    
	    <xsl:if test="not(contains($file_string_ns, $c_lemma))">
	      <xsl:message terminate="no">
		<xsl:value-of select="concat('current freq-sorted lemma ... ', ., ' __OUT__ ', $nl)"/>
	      </xsl:message>
	    </xsl:if>
	    
	  </xsl:for-each>
	</xsl:result-document>
	
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="concat('Cannot locate file: ', $inFile_s, ' or ', $inFile_ns, $nl)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
