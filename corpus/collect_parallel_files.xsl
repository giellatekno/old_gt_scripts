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
  <xsl:param name="slang" select="'sme'"/>
  <xsl:param name="tlang" select="'nob'"/>
  
  <!-- Output dir and file -->
  <xsl:variable name="outDir" select="'xyz'"/>
  <xsl:variable name="outFile" select="'parallel-corpus_summary'"/>
  <xsl:variable name="outFormat" select="'xml'"/>
  <xsl:variable name="e" select="$outFormat"/>
  <xsl:variable name="nl" select="'&#xa;'"/>

  <xsl:template match="/" name="main">
    <xsl:variable name="file_inventory">
      <xsl:for-each select="for $f in collection(concat($inDir, '/', $slang,'?recurse=yes;select=*.xml;on-error=warning')) return $f">
	<!-- This test is for environments that contain symblic links recursively (e.g., XServe).-->
	<!-- You might have to adapt the pattern for yout environment.-->
	<xsl:if test="not(contains(document-uri(.), 'converted/converted'))">
	  <!-- 	  <xsl:if test="not(contains(document-uri(.), 'converted'))"> -->
	  
	  <xsl:if test=".//parallel_text/@xml:lang = $tlang">
	    
	    <xsl:variable name="current_file" select="(tokenize(document-uri(.), '/'))[last()]"/>
	    <xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
	    <xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
	    <xsl:variable name="current_pfile" select="normalize-space(.//parallel_text[./@xml:lang = $tlang]/@location)"/>

	    <xsl:message terminate="no">
	      Processing file: 
	      <xsl:value-of select="$current_file"/>
	    </xsl:message>

	    
	    <file>
	      <xsl:element name="f_name">
		<xsl:value-of select="$current_file"/>
	      </xsl:element>
	      <xsl:element name="f_loc">
		<xsl:value-of select="$current_location"/>
	      </xsl:element>

	      <xsl:element name="pf_name">
		<xsl:value-of select="concat($current_pfile, '.xml')"/>
	      </xsl:element>
	      <xsl:element name="pf_loc">
		<xsl:value-of select="concat(substring-before($current_location, $slang),
				      ./$tlang,
				      substring-after($current_location, $slang))"/>
		
	      </xsl:element>

	    </file>
	    <xsl:message terminate="no">
	      =================================
	    </xsl:message>
	  </xsl:if>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:result-document href="{$outDir}/{$slang}-{$tlang}_{$outFile}.{$e}" format="{$outFormat}">
      <paco_summary>
	<xsl:attribute name="location">
	  <xsl:value-of select="$inDir"/>
	</xsl:attribute>
	<xsl:copy-of select="$file_inventory"/>
      </paco_summary>
    </xsl:result-document>
  </xsl:template>
  
</xsl:stylesheet>

