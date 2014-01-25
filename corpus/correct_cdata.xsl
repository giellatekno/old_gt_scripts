<?xml version="1.0"?>
<!--+
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main THIS_FILE inDir=DIR
    | 
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="xs xhtml">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" name="xml"
	      encoding="UTF-8"
	      cdata-section-elements="disambiguation dependency"
	      omit-xml-declaration="no"
	      indent="yes"/>
  <xsl:output method="text" name="txt"
              encoding="UTF-8"/>

  <xsl:param name="inDir" select="'aGandhi'"/>
  <xsl:param name="outDir" select="'out_cd-corrected'"/>
  <xsl:variable name="of" select="'xml'"/>
  <xsl:variable name="e" select="$of"/>
  <xsl:variable name="debug" select="false()"/>
  <xsl:variable name="nl" select="'&#xa;'"/>
  <xsl:variable name="sr" select="'\*'"/>
  
  <xsl:template match="/" name="main">

    <xsl:for-each select="for $f in collection(concat($inDir,'?recurse=yes;select=*.xml;on-error=warning')) return $f">
      
      <xsl:variable name="current_file" select="(tokenize(document-uri(.), '/'))[last()]"/>
      <xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
      <xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
      <xsl:variable name="relative_path" select="substring-after($current_dir, $inDir)"/>
      <xsl:variable name="file_name" select="substring-before($current_file, '.xml')"/>      

      <xsl:if test="true()">
	<xsl:message terminate="no">
	  <xsl:value-of select="concat('-----------------------------------------', $nl)"/>
	  <xsl:value-of select="concat('location ', $relative_path, $nl)"/>
	  <xsl:value-of select="concat('processing file ', $current_file, $nl)"/>
	  <xsl:value-of select="'-----------------------------------------'"/>
	</xsl:message>
      </xsl:if>

      <xsl:result-document href="{$outDir}/{$relative_path}/{$file_name}.{$of}" format="{$of}">
	<!--xsl:copy-of copy-namespaces="no" select=".//disambiguation"/-->
	<document>
	  <xsl:copy-of select="./document/@*"/>
	  <xsl:copy-of copy-namespaces="no" select=".//header"/>
	  <body>
	    <disambiguation>
	      <xsl:value-of  disable-output-escaping="yes" select="concat($nl, '&lt;![CDATA[', .//disambiguation,']]&gt;', $nl)"/>
	    </disambiguation>
	    <dependency>
	      <xsl:value-of  disable-output-escaping="yes" select="concat($nl, '&lt;![CDATA[',.//dependency,']]&gt;', $nl)"/>
	    </dependency>
	  </body>
	</document>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>
