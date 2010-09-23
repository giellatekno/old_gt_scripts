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
  <xsl:param name="inFile_01" select="'default.xml'"/>
  <xsl:param name="inFile_02" select="'default.xml'"/>
  <xsl:param name="slang" select="'sme'"/>
  <xsl:param name="tlang" select="'nob'"/>
<!--   <xsl:param name="slang" select="'nob'"/> -->
<!--   <xsl:param name="tlang" select="'sme'"/> -->
  
  <!-- Output dir and file -->
  <xsl:variable name="outDir" select="'para_check'"/>
  <xsl:variable name="outFile" select="'paracheck'"/>
  <xsl:variable name="outFormat" select="'xml'"/>
  <xsl:variable name="e" select="$outFormat"/>

  <xsl:template match="/" name="main">
    <xsl:variable name="para_files">
      <parallel_files>
	<xsl:attribute name="direction">
	  <xsl:value-of select="concat($slang, '2', $tlang)"/>
	</xsl:attribute>
	<xsl:for-each select="for $f in document($inFile_01)//file return $f">
	  <xsl:variable name="current_f_loc" select="./f_loc"/>
	  <xsl:variable name="current_f_name" select="./f_name"/>
	  <xsl:variable name="current_pf_loc" select="./pf_loc"/>
	  <xsl:variable name="current_pf_name" select="./pf_name"/>
	  <file>
	    <xsl:variable name="hit">
	      <sf>
		<xsl:value-of select="concat($current_f_loc, $current_f_name)"/>
	      </sf>
	      <tf>
		<xsl:value-of select="concat($current_pf_loc, $current_pf_name)"/>
	      </tf>
	    </xsl:variable>

	    <xsl:variable name="dit">
	      <sf>
		<xsl:value-of select="concat(document($inFile_02)//file[./f_name = $current_pf_name]/pf_loc,
				      document($inFile_02)//file[./f_name = $current_pf_name]/pf_name)"/>
	      </sf>
	      <tf>
		<xsl:value-of select="concat(document($inFile_02)//file[./f_name = $current_pf_name]/f_loc,
				      document($inFile_02)//file[./f_name = $current_pf_name]/f_name)"/>
	      </tf>
	    </xsl:variable>
	    <xsl:attribute name="parallelity">
	      <xsl:value-of select="$hit = $dit"/>
	    </xsl:attribute>
	    <xsl:if test="not($hit = $dit)">
	      <xsl:attribute name="is_sFile">
		<xsl:value-of select="boolean(document($hit/sf))"/>
	      </xsl:attribute>
	      <xsl:attribute name="is_tFile">
		<xsl:value-of select="boolean(document($hit/tf))"/>
	      </xsl:attribute>
	    </xsl:if>
	    <hit>
	      <xsl:copy-of select="$hit"/>
	    </hit>
	    <xsl:if test="not($hit = $dit)">
	      <dit>
		<xsl:copy-of select="$dit"/>
	      </dit>
	    </xsl:if>
	  </file>
	</xsl:for-each>
      </parallel_files>
    </xsl:variable>
    
    <xsl:result-document href="{$outDir}/{concat($slang, '2', $tlang)}_{$outFile}.{$e}" format="{$outFormat}">
      <xsl:copy-of select="$para_files"/>
    </xsl:result-document>
    
  </xsl:template>

</xsl:stylesheet>

