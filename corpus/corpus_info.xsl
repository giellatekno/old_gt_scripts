<?xml version="1.0"?>
<!--+
    | Usage: 
    | __variant 1__: 
    |    java -Xmx2048m net.sf.saxon.Transform -it main THIS_SCRIPT inDir=PATH_TO_CORPUS_DIR outDir=PATH_TO_CORPUS_SUMMARY outFile=CORPUS_SUMMARY_FILE usage=non_seq
    |    __ all corpus info is collected into a variable which is then output at once into the PATH_TO_CORPUS_SUMMARY/CORPUS_SUMMARY_FILE, 
    |       i.e., more memory space required
    |    __ all four parameters can be specified in THIS_SCRIPT, by that shortening the command
    | 
    | __variant 2__: 
    |    java -Xmx2048m net.sf.saxon.Transform -it main THIS_SCRIPT inDir=PATH_TO_CORPUS_DIR  usage=seq > CORPUS_SUMMARY_FILE
    |    __ each file info is output sequentially into the CORPUS_SUMMARY_FILE, i.e., less memory space required, but since inDir is traversed twice,
    |       in the first run, to count the xml files, and in the second run, to extract the infos from each file, it takes more time 
    |    __ if you don't need the total number of xml files you can switch off file_counter (saving time)
    |    __ only inDir and usage can be specified in THIS_SCRIPT, by that shortening the command
    |
    | __ to switch between variant 1 (usage=non_seq) and variant 2 (usage=seq) choose the appropriate value of the usage parameter
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

  <xsl:output method="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  
  <!-- Input dir -->
  <xsl:param name="inDir" select="'converted'"/>
  <!-- Usage -->
  <xsl:param name="usage" select="'seq'"/>

  <!-- Output dir and file -->
  <xsl:variable name="outDir" select="'corpus_report'"/>
  <xsl:variable name="outFile" select="'corpus_summary'"/>
  <xsl:variable name="outFormat" select="'xml'"/>
  <xsl:variable name="e" select="$outFormat"/>
  <xsl:variable name="nl" select="'&#xa;'"/>
  <xsl:variable name="file_counter" select="true()"/>
  
  <xsl:template match="/" name="main">
    <xsl:if test="not($usage = 'seq')">
      <xsl:variable name="file_inventory">
	<xsl:for-each select="for $f in collection(concat($inDir,'?recurse=yes;select=*.xml;on-error=warning')) return $f">
	  <!-- no check needed xsl:if test="not(contains(document-uri(.), 'converted'))" -->
	  <xsl:call-template name="process_file">
	    <xsl:with-param name="the_file" select="."/>
	  </xsl:call-template>
	  <!-- no check needed /xsl:if -->
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
    </xsl:if>
    
    <xsl:if test="$usage = 'seq'">
      <corpus_summary>
	<xsl:attribute name="location">
	  <xsl:value-of select="$inDir"/>
	</xsl:attribute>
	
	<!-- count all files in the dir with converted files -->
	<xsl:if test="$file_counter">
	  <xsl:attribute name="xml_files">
	    <xsl:call-template name="count_files">
	      <xsl:with-param name="the_dir" select="$inDir"/>
	    </xsl:call-template>
	  </xsl:attribute>
	</xsl:if>
	
	<!-- extract infos from each converted file -->
	<xsl:for-each select="for $f in collection(concat($inDir,'?recurse=yes;select=*.xml;on-error=warning')) return $f">
	  <!-- xsl:if test="not(contains(document-uri(.), 'converted'))" -->
	  <xsl:call-template name="process_file">
	    <xsl:with-param name="the_file" select="."/>
	  </xsl:call-template>
	  <!-- /xsl:if -->
	</xsl:for-each>
      </corpus_summary>
    </xsl:if>
    
  </xsl:template>
  
  <!-- extract info from the currently proccessed file --> 
  <xsl:template name="process_file">
    <xsl:param name="the_file"/>
    
    <xsl:variable name="current_file" select="(tokenize(document-uri($the_file), '/'))[last()]"/>
    <xsl:variable name="current_dir" select="substring-before(document-uri($the_file), $current_file)"/>
    <xsl:variable name="current_location" select="substring-after($current_dir, concat($inDir, '/'))"/>
    <xsl:variable name="current_lang" select="$the_file/document/@xml:lang"/>
    
    <xsl:message terminate="no">
      <xsl:value-of select="concat('Location: ', $current_location, $nl)"/>
      <xsl:value-of select="concat('Processing file: ', $current_file, $nl)"/>
    </xsl:message>
    
    <file xml:lang="{$current_lang}">
      <xsl:element name="name">
	<xsl:value-of select="$current_file"/>
      </xsl:element>
      <xsl:element name="f_loc">
	<xsl:value-of select="$current_location"/>
      </xsl:element>
      <xsl:copy-of select="$the_file//genre"/>
      <xsl:copy-of select="$the_file//translated_from"/>
      <xsl:element name="title">
	<xsl:value-of select="$the_file//title"/>
      </xsl:element>
      <xsl:for-each select="$the_file//parallel_text">
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
	<p>
	  <xsl:attribute name="total">
	    <xsl:value-of select="count($the_file//p)"/>
	  </xsl:attribute>
	  <xsl:attribute name="non-emtpy">
	    <xsl:value-of select="count($the_file//p[not(normalize-space(.) = '')])"/>
	  </xsl:attribute>
	  <xsl:attribute name="empty">
	    <xsl:value-of select="count($the_file//p[normalize-space(.) = ''])"/>
	  </xsl:attribute>
	</p>
	<pre>
	  <xsl:attribute name="total">
	    <xsl:value-of select="count($the_file//pre)"/>
	  </xsl:attribute>
	  <xsl:attribute name="non-emtpy">
	    <xsl:value-of select="count($the_file//pre[not(normalize-space(.) = '')])"/>
	  </xsl:attribute>
	  <xsl:attribute name="empty">
	    <xsl:value-of select="count($the_file//pre[normalize-space(.) = ''])"/>
	  </xsl:attribute>
	</pre>
	<section>
	  <xsl:attribute name="total">
	    <xsl:value-of select="count($the_file//section)"/>
	  </xsl:attribute>
	  <xsl:attribute name="non-emtpy">
	    <xsl:value-of select="count($the_file//section[not(normalize-space(.) = '')])"/>
	  </xsl:attribute>
	  <xsl:attribute name="empty">
	    <xsl:value-of select="count($the_file//section[normalize-space(.) = ''])"/>
	  </xsl:attribute>
	</section>
      </size>
    </file>
  </xsl:template>

  <!-- count xml files --> 
  <xsl:template name="count_files">
    <xsl:param name="the_dir"/>
    <xsl:value-of select="count(collection(concat($the_dir,'?recurse=yes;select=*.xml;on-error=warning')))"/>
  </xsl:template>
  
</xsl:stylesheet>

