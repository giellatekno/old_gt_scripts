<?xml version="1.0"?>
<!--+
    | 
    | Splits all xml files from the directory "inDir" into several smaller xml files
    | of the size "fileSize".
    | 
    | NB: The user has to adjust the paths to the input files accordingly
    | Usage: java net.sf.saxon.Transform -it main THIS_FILE
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="xs">

  <xsl:include href="correct_diacritics_rum.xsl"/>
  <xsl:include href="entities.xsl"/>

  <xsl:strip-space elements="*"/>

  <xsl:output method="text" name="txt"
	      encoding="UTF-8"
	      omit-xml-declaration="yes"
	      indent="no"/>

  <xsl:output method="xml" name="xml"
              encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>


  <xsl:param name="lang" select="'rum'"/>
  <xsl:variable name="debug" select="true()"/>
  <xsl:variable name="of" select="'xml'"/>
  <xsl:variable name="e" select="$of"/>


  <!-- input file, extention of the output file -->
  <xsl:param name="inFile" select="'_x_'"/>
  <xsl:param name="inDir" select="'_xxx_'"/>
  <xsl:param name="outDir" select="'_outSplitData'"/>
  <xsl:param name="fileSize" select="2500"/>
  <xsl:variable name="dataLang" select="'ron'"/>
  <xsl:variable name="dataName" select="'europarl_ron'"/>
  

  <xsl:template match="/" name="main">
    
    <xsl:for-each select="collection(concat($inDir, '?select=*.xml'))">
      
      <xsl:variable name="current_file" select="substring-before((tokenize(document-uri(.), '/'))[last()], '.xml')"/>
      <xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
      <xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
      
      <xsl:message terminate="no">
	<xsl:value-of select="concat('Processing file: ', $current_file)"/>
	<xsl:value-of select="concat('Location: ', $current_dir, $nl)"/>
      </xsl:message>
      
      <xsl:variable name="line_total" select="count(./corpus/s)"/>
      
      <xsl:for-each select="./corpus/s">
	
	<xsl:message terminate="no">
	  <xsl:value-of select="concat('line: ', concat('s_', position()))"/>
	  <!-- xsl:value-of select="concat('Location: ', $current_dir, $nl)"/ -->
	</xsl:message>
	
        <!-- number of stories to go into a file -->
	<xsl:variable name="subcorpus_id" select="position() - $fileSize + 1"/>
	<xsl:variable name="from_filler" select="string-length(string($line_total)) - string-length(string($subcorpus_id))"/>
	<xsl:variable name="to_filler" select="string-length(string($line_total)) - string-length(string(position()))"/>
	
	<xsl:if test="position() mod $fileSize = 0">
	  <xsl:variable name="from_id_filler">
	    <xsl:if test="string-length(string($line_total)) &gt; string-length(string($subcorpus_id))">
	       <xsl:call-template name="get_filler">                    
                    <xsl:with-param name="data" select="$from_filler"/>
                </xsl:call-template>		
	    </xsl:if>
	  </xsl:variable>
	  
	  <xsl:variable name="to_id_filler">
	    <xsl:if test="string-length(string($line_total)) &gt; string-length(string(position()))">
	       <xsl:call-template name="get_filler">                    
                    <xsl:with-param name="data" select="$to_filler"/>
                </xsl:call-template>		
	    </xsl:if>
	  </xsl:variable>

	  <xsl:variable name="from_id" select="concat($from_id_filler,$subcorpus_id)"/>
	  <xsl:variable name="to_id" select="concat($to_id_filler,position())"/>
	  
	  
	  <xsl:result-document href="{$outDir}/{$current_file}_{$from_id}-{$to_id}.{$e}" format="{$of}">
	    <xsl:message terminate="no">
	      <xsl:value-of select="concat('sent ', ./@id)"/>
	    </xsl:message>
	    <corpus id="{concat($dataName, '_', $from_id, '-' , $to_id)}" xml:lang="{$dataLang}">
	      <xsl:if test="$of = 'xml'">
		<xsl:copy-of select="preceding-sibling::s[position() &lt; $fileSize]"/>
		<xsl:copy-of select="."/>
	      </xsl:if>
	      <xsl:if test="$of = 'txt'">
		<xsl:for-each select="preceding-sibling::s[position() &lt; $fileSize]">
		  <xsl:value-of select="concat(., ' ', $eol, $nl)"/>
		</xsl:for-each>
		<xsl:value-of select="concat(., ' ', $eol, $nl)"/>
	      </xsl:if>
	    </corpus>
	  </xsl:result-document>
	</xsl:if>
	
	<!-- special case when the last element's position is not modulo N without rest -->
	<xsl:if test="not(last() mod $fileSize = 0) and (position() = last())">
	  <xsl:result-document href="{$outDir}/{$current_file}_{last() - (last() mod $fileSize) + 1}-{last()}.{$e}" format="{$of}">
	    <xsl:message terminate="no">
	      <xsl:value-of select="concat('sent ', ./@id, ' ___ ', (last() - (last() mod $fileSize)))"/>
	    </xsl:message>
	    <corpus id="{concat($dataName, '_', $subcorpus_id, '-' , position())}" xml:lang="{$dataLang}">
	      <xsl:if test="$of = 'xml'">
		<xsl:copy-of select="preceding-sibling::s[position() &lt; ((last() mod $fileSize) + 1)]"/>
		<xsl:copy-of select="."/>
	      </xsl:if>
	      <xsl:if test="$of = 'txt'">
		<xsl:for-each select="preceding-sibling::s[position() &lt; ((last() mod $fileSize) + 1)]">
		  <xsl:value-of select="concat(., ' ', $eol, $nl)"/>
		</xsl:for-each>
		<xsl:value-of select="concat(., ' ', $eol, $nl)"/>
	      </xsl:if>
	    </corpus>
	  </xsl:result-document>
	</xsl:if>
	
      </xsl:for-each>
      
    </xsl:for-each>

  </xsl:template>

  <xsl:template name="get_filler">
   <xsl:param name="data"/>
   <xsl:if test="$data &gt; 1">
     <xsl:call-template name="get_filler">       
       <xsl:with-param name="data" select="$data - 1"/>
     </xsl:call-template>	
   </xsl:if>
   <xsl:value-of select="'0'"/>
  </xsl:template>
  
</xsl:stylesheet>
