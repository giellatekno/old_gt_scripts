<?xml version="1.0"?>
<!--+
    | 
    | Script to transform the xml-converted corpus file in html format with link between the parallel files for easy checck
    | Usage: java net.sf.saxon.Transform -it main STYLESHEET_NAME.xsl (inFile=INPUT_FILE_NAME.xml | inDir=INPUT_DIR)
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:local="nightbar"
                xmlns:misc="someURI"
                xmlns:File="java:java.io.File"
		xmlns:fmp="http://www.filemaker.com/fmpxmlresult"
		xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
		exclude-result-prefixes="xs local fmp ss File misc">

  <!-- Caveat: file_checker.xsl needed -->
  <xsl:import href="/Users/ciprian/local/xsl/file_checker.xsl"/>

  <xsl:strip-space elements="*"/>

  <xsl:output method="xml" name="xml"
              encoding="UTF-8"
              omit-xml-declaration="no"
              indent="yes"/>
  <xsl:output method="xml" name="html"
              encoding="UTF-8"
              omit-xml-declaration="yes"
              indent="yes"/>
  <xsl:output method="text" name="txt"
	      encoding="UTF-8"/>
  
  <!-- in -->
  <xsl:param name="inDir" select="'xxxdirxxx'"/>
  <xsl:param name="inFile" select="'xxxfilexxx.xml'"/>
  <xsl:param name="this" select="base-uri(document(''))"/>
  <xsl:variable name="this_name" select="(tokenize($this, '/'))[last()]"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/> 

 
  <!-- out -->
  <xsl:variable name="outDir" select="'html_check'"/>
  
  <xsl:variable name="oe" select="'html'"/>
  <xsl:variable name="tb" select="'&#9;'"/>
  <xsl:variable name="nl" select="'&#xA;'"/>
  <xsl:variable name="debug" select="false()"/>  
  <xsl:variable name="lang_pair" select="'__nob__sme__'"/>

  <xsl:template match="/" name="main">
    
    <xsl:if test="misc:file-exists(resolve-uri($inFile))">
      <xsl:call-template name="processFile">
    	<xsl:with-param name="file" select="document($inFile)"/>
    	<xsl:with-param name="name" select="$file_name"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="misc:file-exists(resolve-uri($inDir))">
      
      <xsl:message terminate="no">
	<xsl:value-of select="concat('Processing dir: ', $inDir)"/>
      </xsl:message>
      
      <xsl:for-each select="for $f in collection(concat($inDir, '?select=*.xml;recurse=yes;on-error=warning')) return $f">
	
	<xsl:variable name="current_file" select="substring-before((tokenize(document-uri(.), '/'))[last()], '.xml')"/>
	<xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
	<xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
	
	<xsl:call-template name="processFile">
	  <xsl:with-param name="file" select="."/>
	  <xsl:with-param name="name" select="$current_file"/>
	  <xsl:with-param name="ie" select="'xml'"/>
	  <xsl:with-param name="relPath" select="$current_location"/>
	</xsl:call-template>
      </xsl:for-each>
    </xsl:if>
    
    <xsl:if test="not(misc:file-exists(resolve-uri($inFile)))">
      <xsl:value-of select="concat($nl, 'No  file ', $inFile, ' found.', $nl)"/>
    </xsl:if>

    <xsl:if test="not(misc:file-exists(resolve-uri($inDir)))">
      <xsl:value-of select="concat($nl, 'No  dir ', $inDir, ' found.', $nl)"/>
    </xsl:if>

  </xsl:template>

  <!-- template to process file, once its existence has been determined -->
  <xsl:template name="processFile">
    <xsl:param name="file"/>
    <xsl:param name="name"/>
    <xsl:param name="ie"/>
    <xsl:param name="relPath"/>

    <xsl:variable name="oLang" select="$file//document/@xml:lang"/>
    <xsl:variable name="pLang" select="if ($oLang='sme') then 'nob' else 'sme'"/>
    <xsl:variable name="oWordcount" select="$file//wordcount"/>
    <xsl:variable name="pRelPath" select="concat($pLang,
					  substring-after($relPath, $oLang))"/>

    <xsl:variable name="current_abs_loc" select="substring-before(document-uri(.), $name)"/>
    <xsl:variable name="current_location" select="concat($inDir, substring-after($current_abs_loc, $inDir))"/>
    <xsl:variable name="current_pfile" select="normalize-space($file//parallel_text[./@xml:lang = $pLang]/@location)"/>
    
    <xsl:variable name="parallel_file" select="if (ends-with($current_pfile, '.xml')) then $current_pfile else concat($current_pfile, '.xml')"/>
    <xsl:variable name="parallel_location" select="concat(substring-before($current_location, $oLang),
    						   ./$pLang,
    						   substring-after($current_location, $oLang))"/>
    

    <!--xsl:variable name="pFile" select="document(concat($pRelPath, $file//parallel_text[./@xml:lang=$pLang]/@location))"/-->
    <xsl:variable name="pFile" select="document(concat($parallel_location, $parallel_file))"/>
    <xsl:variable name="pWordcount" select="$pFile//wordcount"/>

    <xsl:variable name="ld" select="count(tokenize($pRelPath, '/'))"/>

    <xsl:variable name="linkDepth">
      <xsl:for-each select="tokenize($pRelPath, '/')[position() &lt; last()]">
	<xsl:value-of select="'../'"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:message terminate="no">
      <xsl:value-of select="concat('Processing file: ', $relPath, $name, '.', $ie)"/>
    </xsl:message>      
    

    <!-- out -->
    <xsl:result-document href="{$outDir}/{$relPath}{$name}.{$oe}" format="{$oe}">
      <!--xsl:copy-of copy-namespaces="no" select="."/-->
      
      <html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <link href="style.css" rel="stylesheet" type="text/css"/>
  <title><xsl:value-of select="concat('File name ', $name, '.', $ie)"/></title>
</head>
      <body>
	<span style="background-color:#FFF;">
	  <h3><xsl:value-of select="concat($name, '.', $ie)"/></h3>
	  <xsl:value-of select="concat($nl, 'oLang=', $oLang, '&#160;&#160;&#160;&#160;&#160;oWordCount=', $oWordcount, $nl)"/>
	  <br/>
	  <h4> Parallel file: <a href="{concat('./', $linkDepth, $pRelPath, $file//parallel_text[./@xml:lang=$pLang]/@location, '.', $oe)}">
	  <xsl:value-of select="concat($file//parallel_text[./@xml:lang=$pLang]/@location, '.', $oe)"/>
	</a>
	  </h4>
	  <xsl:value-of select="concat($nl, 'pLang=', $pLang, '&#160;&#160;&#160;&#160;&#160;pWordCount=', $pWordcount, $nl)"/>
	  <h4>Location: &#160;&#160;<xsl:value-of select="concat($nl, substring-after($relPath, concat($oLang, '/')), $nl)"/></h4>
	  <hr/>
	  <hr/>
	</span>
	<xsl:for-each select="$file//p">
	  <p style="background-color:{if ((position() mod 2) = 0) then '#FFF' else '#F2F2F2'};">
	    <xsl:copy-of select="./@*"/>
	  <xsl:copy-of select="./node()"/></p>
	</xsl:for-each>
      </body>
      </html>
      
    </xsl:result-document>

    <xsl:if test="$debug">
      <xsl:message terminate="no">
	<xsl:value-of select="concat('   Done!',' Output file  ',$name,' in: ', $outDir)"/>
      </xsl:message>
    </xsl:if>

  </xsl:template>
  
</xsl:stylesheet>

