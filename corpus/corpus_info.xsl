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
  <xsl:variable name="inFile" select="'default.txt'"/>

  <!-- Output dir and file -->
  <xsl:variable name="outDir" select="'outDir'"/>
  <xsl:variable name="outFile" select="'corpus_summary'"/>
  <xsl:variable name="outFormat" select="'xml'"/>
  <xsl:variable name="e" select="$outFormat"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/>

  <xsl:template match="/" name="main">
    <xsl:variable name="file_inventory">
      <corpus_summary>
	
	<xsl:attribute name="location">
	  <xsl:value-of select="$inDir"/>
	</xsl:attribute>
	
	<xsl:attribute name="xml_files">
	  <xsl:value-of select="count(collection(concat($inDir,'?recurse=yes;select=*.xml')))"/>
	</xsl:attribute>
	
	<xsl:for-each select="for $f in collection(concat($inDir,'?recurse=yes;select=*.xml;on-error=warning')) return $f">
	  
	  <xsl:variable name="current_file" select="(tokenize(document-uri(.), '/'))[last()]"/>
	  <xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
	  <xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
	  <xsl:variable name="current_lang" select="./document/@xml:lang"/>
	  
	  <file xml:lang="{$current_lang}">
	    <xsl:element name="name">
	      <xsl:value-of select="$current_file"/>
	    </xsl:element>
	    <xsl:element name="location">
	      <xsl:value-of select="$current_location"/>
	    </xsl:element>
	    <xsl:copy-of select=".//genre"/>
	    <xsl:copy-of select=".//translated_from"/>
	    <xsl:element name="title">
	      <xsl:value-of select=".//title"/>
	    </xsl:element>
	    <xsl:element name="parallel_text">
	      <xsl:copy-of select=".//parallel_text/@xml:lang"/>
	      <xsl:element name="name">
		<xsl:value-of select=".//parallel_text/@location"/>
	      </xsl:element>
	      <xsl:element name="location">
		<xsl:value-of select="concat(substring-before($current_location, $current_lang), 
				      .//parallel_text/@xml:lang, 
				      substring-after($current_location, $current_lang))"/>
	      </xsl:element>
	    </xsl:element>
	    <size>
	      <p_count>
		<xsl:value-of select="count(.//p)"/>
	      </p_count>
	      <e_p_count>
		<xsl:value-of select="count(.//p[normalize-space(.) = ''])"/>
	      </e_p_count>
	      <ne_p_count>
		<xsl:value-of select="count(.//p[not(normalize-space(.) = '')])"/>
	      </ne_p_count>

	      <section_count>
		<xsl:value-of select="count(.//section)"/>
	      </section_count>
	    </size>
	  </file>
	</xsl:for-each>
      </corpus_summary>
    </xsl:variable>
    
    <xsl:result-document href="{$outDir}/{$outFile}.{$e}" format="{$outFormat}">
      <xsl:copy-of select="$file_inventory"/>
    </xsl:result-document>
    
  </xsl:template>
  
</xsl:stylesheet>

