<?xml version="1.0"?>
<!--+
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main THIS_FILE inDir=DIR
    | 
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:local="nightbar"
		exclude-result-prefixes="xs xhtml local">

  <xsl:strip-space elements="*"/>
  <xsl:output method="text" name="dis"
	      encoding="UTF-8"
	      omit-xml-declaration="yes"
	      indent="no"/>

  <xsl:output method="text" name="dep"
	      encoding="UTF-8"
	      omit-xml-declaration="yes"
	      indent="no"/>

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

  <xsl:param name="inDir" select="'data4korp/2014-01-24/'"/>
  <xsl:param name="outDir" select="'_outdir_'"/>
  <xsl:variable name="debug" select="false()"/>
  <xsl:variable name="nl" select="'&#xa;'"/>
  <xsl:variable name="sr" select="'\*'"/>
  <xsl:variable name="pre_path" select="'data4korp/2014-01-24/'"/>
  <xsl:variable name="langs" select="'sma sme smj'"/>
  <xsl:variable name="domains" select="'admin bible facta ficti laws news'"/>
  <xsl:variable name="bDir" select="concat($pre_path,'boundcorpus/analysed/','current_lang','/',.)"/>
  <xsl:variable name="fDir" select="concat($pre_path,'freecorpus/analysed/','current_lang','/',.)"/>
  
  <xsl:template match="/" name="main">
    <!-- search all combinations of corpus type, lang, and domain -->
    <xsl:variable name="ntuples">
      <xsl:variable name="tmp">
	<nt>
	  <xsl:for-each select="for $f in collection(concat($inDir,'?recurse=yes;select=*.xml;on-error=warning')) return $f">
	    
	    <xsl:variable name="current_file" select="(tokenize(document-uri(.), '/'))[last()]"/>
	    <xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
	    <xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
	    <xsl:variable name="relative_path" select="substring-after($current_dir, $inDir)"/>
	    
	    <xsl:variable name="file_name" select="substring-before($current_file, '.xml')"/>      
	    
	    
	    <xsl:variable name="current_corpus_type">
	      <xsl:if test="contains($current_dir, 'boundcorpus')">
		<xsl:value-of select="'boundcorpus'"/>
	      </xsl:if>
	      <xsl:if test="contains($current_dir, 'freecorpus')">
		<xsl:value-of select="'freecorpus'"/>
	      </xsl:if>
	    </xsl:variable>
	    
	    <xsl:variable name="current_lang">
	      <xsl:if test="contains($current_dir, 'sma')">
		<xsl:value-of select="'sma'"/>
	      </xsl:if>
	      <xsl:if test="contains($current_dir, 'sme')">
		<xsl:value-of select="'sme'"/>
	      </xsl:if>
	      <xsl:if test="contains($current_dir, 'smj')">
		<xsl:value-of select="'smj'"/>
	      </xsl:if>
	    </xsl:variable>
	    
	    <xsl:variable name="current_domain">
	      <xsl:if test="contains($current_dir, 'admin')">
		<xsl:value-of select="'admin'"/>
	      </xsl:if>
	      <xsl:if test="contains($current_dir, 'bible')">
		<xsl:value-of select="'bible'"/>
	      </xsl:if>
	      <xsl:if test="contains($current_dir, 'facta')">
		<xsl:value-of select="'facta'"/>
	      </xsl:if>
	      <xsl:if test="contains($current_dir, 'ficti')">
		<xsl:value-of select="'ficti'"/>
	      </xsl:if>
	      <xsl:if test="contains($current_dir, 'laws')">
		<xsl:value-of select="'laws'"/>
	      </xsl:if>
	      <xsl:if test="contains($current_dir, 'news')">
		<xsl:value-of select="'news'"/>
	      </xsl:if>
	    </xsl:variable>
	    
	    <xsl:if test="false()">
	      <xsl:message terminate="no">
		<xsl:value-of select="concat('              ==============', $nl)"/>
		<xsl:value-of select="concat('                  ', $current_corpus_type, ' _ ', $current_lang, ' _ ', $current_domain, $nl)"/>
		<xsl:value-of select="'              =============='"/>
	      </xsl:message>
	      <xsl:message terminate="no">
		<xsl:value-of select="concat('processing file ', $file_name, $nl)"/>
		<xsl:value-of select="'.......'"/>
	      </xsl:message>
	    </xsl:if>
	    <t>
	      <xsl:value-of select="concat($current_corpus_type,'_',$current_lang,'_',$current_domain)"/>
	    </t>
	  </xsl:for-each>
	</nt>
      </xsl:variable>

      <nt>
	<xsl:for-each select="distinct-values($tmp//t)">
	  <t>
	    <xsl:value-of select="."/>
	  </t>
	</xsl:for-each>
      </nt>
    </xsl:variable>
    
    <!-- collect file paths and add the translation info from the meta-file -->
    <xsl:variable name="group_output">
      <xsl:variable name="files">
	<files>
	  <xsl:for-each select="$ntuples/nt/t">
	    <xsl:message terminate="no">
	      <xsl:value-of select="concat('_xxx_ ', ., $nl)"/>
	      <xsl:value-of select="'.......'"/>
	    </xsl:message>
	    
	    <xsl:variable name="ct" select="(tokenize(., '_'))[1]"/>      
	    <xsl:variable name="cl" select="(tokenize(., '_'))[2]"/>      
	    <xsl:variable name="cd" select="(tokenize(., '_'))[3]"/>
	    
	    <xsl:variable name="cp" select="concat($inDir,'/',$ct,'/analysed/',$cl,'/',$cd)"/>
	    
	    <xsl:for-each select="for $f in collection(concat($cp,'?recurse=yes;select=*.xml;on-error=warning')) return $f">
	      <xsl:variable name="current_file" select="(tokenize(document-uri(.), '/'))[last()]"/>
	      <xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
	      <xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
	      <xsl:variable name="relative_path" select="concat($inDir, substring-after(document-uri(.), $inDir))"/>
	      <f cl="{$cl}" cd="{$cd}">
		<name>
		  <xsl:value-of select="$relative_path"/>
		</name>
		<xsl:if test=".//translated_from">
		  <xsl:copy-of select=".//translated_from"/>
		</xsl:if>
		<xsl:if test="not(.//translated_from)">
		  <translated_from xml:lang="none"/>
		</xsl:if>
	      </f>
	    </xsl:for-each>
	  </xsl:for-each>
	</files>
      </xsl:variable>

      <!-- sort the files by current lang -->
      <xsl:variable name="lg">
	<groups>
	  <xsl:for-each-group select="$files//f" group-by="@cl">
	    <xsl:sort select="current-grouping-key()"/>
	    <group lang="{current-grouping-key()}">
	      <xsl:for-each select="current-group()">
		<xsl:copy-of select="."/>
	      </xsl:for-each>
	    </group>
	  </xsl:for-each-group>
	</groups>
      </xsl:variable>
      <!-- sort the files by current domain -->
      <xsl:variable name="dlg">
	<gf>
	  <xsl:for-each select="$lg/groups/group">
	    <xsl:variable name="lang" select="./@lang"/>
	    
	    <xsl:for-each-group select="./f" group-by="@cd">
	      <xsl:sort select="current-grouping-key()"/>
	      <group lang="{$lang}" domain="{current-grouping-key()}">
		<xsl:for-each select="current-group()">
		  <xsl:copy-of select="."/>
		</xsl:for-each>
	      </group>
	    </xsl:for-each-group>
	  </xsl:for-each>
	</gf>
      </xsl:variable>
      <!-- sort the files by translation -->
      <tdlg>
	<xsl:for-each select="$dlg/gf/group">
	  <xsl:variable name="lang" select="./@lang"/>
	  <xsl:variable name="domain" select="./@domain"/>
	  
	  <xsl:for-each-group select="./f" group-by="./translated_from/@xml:lang">
	    <xsl:sort select="current-grouping-key()"/>
	    <group lang="{$lang}" tlang="{current-grouping-key()}" domain="{$domain}">
	      <xsl:for-each select="current-group()">
		<xsl:copy-of select="."/>
	      </xsl:for-each>
	    </group>
	  </xsl:for-each-group>
	</xsl:for-each>
      </tdlg>
    </xsl:variable>
    <!-- output the data according to the file groups in parallel: both for dis and for dep -->
    <xsl:for-each select="('dis','dep')">
      <xsl:variable name="current_format" select="."/>
      <xsl:for-each select="$group_output/tdlg/group">
	<xsl:result-document href="sorted_output/{./@lang}_{./@tlang}_{./@domain}.{$current_format}" format="{$current_format}">
	  <xsl:for-each select="./f">
	    <xsl:variable name="text-encoding" as="xs:string" select="'UTF-8'"/>
	    <xsl:variable name="text-uri" as="xs:string" select="concat(substring(./name,1,string-length(./name)-3),$current_format)"/>
	    <!--xsl:copy-of select="document(concat(&quot;'&quot;,./name,&quot;'&quot;))"/-->
	    <xsl:copy-of select="unparsed-text($text-uri, $text-encoding)"/>
	  </xsl:for-each>
	</xsl:result-document>
      </xsl:for-each>
    </xsl:for-each>

    <!-- debugging -->
    <xsl:if test="$debug">
      <xsl:result-document href="_output_tuples.xml" format="xml">
	<xsl:copy-of select="$group_output"/>
      </xsl:result-document>
    </xsl:if>
    
  </xsl:template>
  
</xsl:stylesheet>
