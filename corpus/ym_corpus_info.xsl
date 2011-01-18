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
  <xsl:param name="inDir" select="'converted'"/>
  <xsl:param name="inFile" select="'default.txt'"/>

  <!-- Output dir and file -->
  <xsl:variable name="outDir" select="'corpus_report'"/>
  <xsl:variable name="outFile" select="'corpus_summary'"/>
  <xsl:variable name="outFormat" select="'xml'"/>
  <xsl:variable name="e" select="$outFormat"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/>
  <xsl:variable name="nl" select="'&#xa;'"/>

  <xsl:template match="/" name="main">
    <xsl:variable name="file_inventory">
	
	<xsl:for-each select="for $f in collection(concat($inDir,'?recurse=yes;select=*.xml;on-error=warning')) return $f">
<!-- this is just in case you have some symbolic link in the converted directory pointing to itself; otherwise comment out or adapt accordingly! -->
	  <xsl:if test="not(contains(document-uri(.), 'converted/converted'))">
	<!--  <xsl:if test="not(contains(document-uri(.), 'converted'))"> -->
	    
	    <xsl:variable name="current_file" select="(tokenize(document-uri(.), '/'))[last()]"/>
	    <xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
	    <xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
	    <xsl:variable name="current_lang" select="./document/@xml:lang"/>

	    <xsl:message terminate="no">
	      <xsl:value-of select="concat('Processing file: ', $current_file, $nl)"/>
	      <xsl:value-of select="concat('Location: ', $current_dir, $nl)"/>
	    </xsl:message>
	    
	    <file xml:lang="{$current_lang}">
	      <xsl:element name="name">
		<xsl:value-of select="$current_file"/>
	      </xsl:element>
	      <xsl:element name="f_loc">
		<xsl:value-of select="$current_location"/>
	      </xsl:element>
	      <xsl:copy-of select=".//genre"/>
	      <xsl:copy-of select=".//translated_from"/>
	      <xsl:element name="title">
		<xsl:value-of select=".//title"/>
	      </xsl:element>
	      <xsl:for-each select=".//parallel_text">
		<xsl:element name="parallel_text">
		  <xsl:copy-of select="./@xml:lang"/>
		  <xsl:element name="name">
		    <xsl:value-of select="./@location"/>
		  </xsl:element>
		  <xsl:element name="pf_loc">
		    <xsl:value-of select="concat(substring-before($current_location, $current_lang), 
					  ./@xml:lang, 
					  substring-after($current_location, $current_lang))"/>
		  </xsl:element>
		</xsl:element>
	      </xsl:for-each>
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
		
		<pre_count>
		  <xsl:value-of select="count(.//pre)"/>
		</pre_count>
		<e_pre_count>
		  <xsl:value-of select="count(.//pre[normalize-space(.) = ''])"/>
		</e_pre_count>
		<ne_pre_count>
		  <xsl:value-of select="count(.//pre[not(normalize-space(.) = '')])"/>
		</ne_pre_count>
		
		<section_count>
		  <xsl:value-of select="count(.//section)"/>
		</section_count>
		
		<e_section_count>
		  <xsl:value-of select="count(.//section[normalize-space(.) = ''])"/>
		</e_section_count>
		
		<ne_section_count>
		  <xsl:value-of select="count(.//section[not(normalize-space(.) = '')])"/>
		</ne_section_count>
	      </size>
	    </file>
	  </xsl:if>
	</xsl:for-each>
    </xsl:variable>
    
    <xsl:result-document href="{$outDir}/{$outFile}.{$e}" format="{$outFormat}">
      
      <corpus_summary>
	<xsl:attribute name="location">
	  <xsl:value-of select="$inDir"/>
	</xsl:attribute>
	<xsl:attribute name="xml_files">
	  <xsl:value-of select="count($file_inventory/file)"/>
	</xsl:attribute>
	<xsl:copy-of select="$file_inventory"/>
      </corpus_summary>

    </xsl:result-document>
    
  </xsl:template>
  
</xsl:stylesheet>

