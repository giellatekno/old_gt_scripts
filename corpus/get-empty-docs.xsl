<?xml version="1.0"?>
<!--+
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main THIS_SCRIPT inDIR=PATH_TO_CORPUS_DIR
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:local="nightbar"
		exclude-result-prefixes="xs local">

  <xsl:strip-space elements="*"/>

  <xsl:output method="text" name="txt"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:output method="xml" name="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>
  
  <!-- Input dir -->
  <xsl:param name="inDir" select="'default'"/>
  <xsl:param name="inFile" select="'default.txt'"/>

  <!-- Output dir and file -->
  <xsl:variable name="outDir" select="'outDir'"/>
  <xsl:variable name="outFile" select="'corpus_summary'"/>
  <xsl:variable name="outFormat" select="'xml'"/>
  <xsl:variable name="e" select="$outFormat"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/>

  <xsl:template match="/" name="main">
    <xsl:variable name="empty_files">
      <empty_files>
	
	<xsl:attribute name="counter">
	  <xsl:value-of select="count(document($inFile)/corpus_summary/file[size/p_count = size/e_p_count])"/>
	</xsl:attribute>
	
	<xsl:for-each select="document($inFile)/corpus_summary/file[size/p_count = size/e_p_count]">
	  <xsl:copy-of select="."/>
	</xsl:for-each>
      </empty_files>
    </xsl:variable>
    
    <xsl:result-document href="{$outDir}/{$outFile}.{$e}" format="{$outFormat}">
      <xsl:copy-of select="$empty_files"/>
    </xsl:result-document>
    
  </xsl:template>

</xsl:stylesheet>

