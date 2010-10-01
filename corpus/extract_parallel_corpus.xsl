<?xml version="1.0"?>
<!--+
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main THIS_SCRIPT lang1=FIRST_LANGUAGE lang2=SECOND_LANGUAGE inDir=PATH_TO_CORPUS_DIR
    +-->

<!-- java -Xmx2048m net.sf.saxon.Transform -it main extract_parallel_corpus.xsl slang=nob tlang=sme inDir=converted  -->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:local="nightbar"
		xmlns:misc="someURI"
		xmlns:File="java:java.io.File"
		exclude-result-prefixes="xs local File misc">

  <xsl:import href="file_checker.xsl"/>

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
  <xsl:param name="slang" select="'nob'"/>
  <xsl:param name="tlang" select="'sme'"/>
  
  <!-- Output dir and file -->
  <xsl:variable name="outDir" select="'parallel_corpus_tmp'"/>
  <xsl:variable name="outFile" select="'parallel-corpus_summary'"/>
  <xsl:variable name="outFormat" select="'xml'"/>
  <xsl:variable name="e" select="$outFormat"/>
  <xsl:variable name="nl" select="'&#xa;'"/>
  <xsl:variable name="debug" select="'true'"/>

  <xsl:template match="/" name="main">
    <xsl:message terminate="no">
      <xsl:value-of select="concat('Extracting parallel files for ', $slang, ' and ', $tlang, ' from the ', $inDir, ' directory', $nl)"/>
      <xsl:value-of select="concat('...........................................................................................', $nl)"/>
    </xsl:message>
    <xsl:variable name="parallel_files">
	<xsl:for-each select="for $f in collection(concat($inDir, '/', $slang,'?recurse=yes;select=*.xml;on-error=warning')) return $f">
	  <!-- This test is for environments that contain symblic links recursively (e.g., XServe).-->
	  <!-- You might have to adapt the pattern for yout environment.-->
	  <xsl:if test="not(contains(document-uri(.), 'converted/converted'))">
	    <!-- 	  <xsl:if test="not(contains(document-uri(.), 'converted'))"> -->
	    
	    <xsl:if test=".//parallel_text/@xml:lang = $tlang">
	      <xsl:variable name="current_lang" select="./document/@xml:lang"/>
	      <xsl:variable name="current_file" select="(tokenize(document-uri(.), '/'))[last()]"/>
	      <xsl:variable name="current_abs_loc" select="substring-before(document-uri(.), $current_file)"/>
	      <xsl:variable name="current_location" select="concat($inDir, substring-after($current_abs_loc, $inDir))"/>
	      <xsl:variable name="current_pfile" select="normalize-space(.//parallel_text[./@xml:lang = $tlang]/@location)"/>
	      
	      <xsl:variable name="parallel_file" select="if (ends-with($current_pfile, '.xml')) then $current_pfile else concat($current_pfile, '.xml')"/>
	      <xsl:variable name="parallel_location" select="concat(substring-before($current_location, $slang),
							     ./$tlang,
							     substring-after($current_location, $slang))"/>
	      
	      <xsl:variable name="f_orig_path" select="concat('orig', substring-after($current_location, 'converted'))"/>
	      <xsl:variable name="f_orig_name" select="substring($current_file, 1, string-length($current_file) - 4)"/>
	      <xsl:variable name="pf_orig_path" select="concat('orig', substring-after($parallel_location, 'converted'))"/>
	      <xsl:variable name="pf_orig_name" select="$current_pfile"/>
	      
	      <xsl:message terminate="no">
		<xsl:value-of select="concat('current_abs_loc: ', $nl)"/>
		<xsl:value-of select="concat($current_abs_loc, $nl)"/>
		<xsl:value-of select="concat('current_file: ', $current_file, $nl)"/>
		<xsl:value-of select="concat('current_location: ', $current_location, $nl)"/>
		<xsl:value-of select="concat('current_pfile: ', $current_pfile, $nl)"/>
	      </xsl:message>
	      
	      <xsl:if test="$debug = 'true'">
		<xsl:message terminate="no">
		  <xsl:value-of select="concat('-----------------------------------------', $nl)"/>
		  <xsl:value-of select="concat('here sf: ', $nl)"/>
		  <xsl:value-of select="concat($current_location, $current_file, $nl)"/>
		  <xsl:value-of select="concat('here tf: ', $nl)"/>
		  <xsl:value-of select="concat($parallel_location, $parallel_file, $nl)"/>
		  <xsl:value-of select="'-----------------------------------------'"/>
		</xsl:message>
	      </xsl:if>
	      
	      <xsl:variable name="here">
		<sf>
		  <xsl:value-of select="concat($current_location, $current_file)"/>
		</sf>
		<tf>
		  <xsl:value-of select="concat($parallel_location, $parallel_file)"/>
		</tf>
	      </xsl:variable>
	      <xsl:variable name="there">
		<sf>
		  <xsl:value-of select="concat($current_location,
					normalize-space(document(concat($parallel_location, $parallel_file))//parallel_text[./@xml:lang = $slang]/@location),
					'.xml')"/>
		</sf>
		<tf>
		  <xsl:value-of select="concat($parallel_location, $parallel_file)"/>
		</tf>
	      </xsl:variable>
	      
	      <file xml:lang="{$current_lang}">
		<xsl:attribute name="parallelity">
		  <xsl:value-of select="$here = $there"/>
		</xsl:attribute>
		
		<xsl:if test="not($here = $there)">
		  
		  <!-- 		<xsl:attribute name="f_orig"> -->
		  <!-- 		  <xsl:value-of select="misc:file-exists(resolve-uri(concat($f_orig_path, $f_orig_name)))"/> -->
		  <!-- 		</xsl:attribute> -->
		  
		  <!-- 		<xsl:attribute name="pf_orig"> -->
		  <!-- 		  <xsl:value-of select="misc:file-exists(resolve-uri(concat($pf_orig_path, $pf_orig_name)))"/> -->
		  <!-- 		</xsl:attribute> -->
		  
		  <xsl:variable name="exists_pf_orig" select="misc:file-exists(resolve-uri(concat($pf_orig_path, $pf_orig_name)))"/>
		  
		  <xsl:if test="$exists_pf_orig">
		    <xsl:attribute name="reason">
		      <xsl:value-of select="'conversion_error'"/>
		    </xsl:attribute>
		  </xsl:if>
		  <xsl:if test="not($exists_pf_orig)">
		    <xsl:attribute name="reason">
		      <xsl:value-of select="'no_original_file'"/>
		    </xsl:attribute>
		  </xsl:if>
		  
		  
		  <!-- 		<xsl:attribute name="h_xml"> -->
		  <!-- 		  <xsl:value-of select="boolean(document(concat($current_location, $current_file)))"/> -->
		  <!-- 		</xsl:attribute> -->
		  
		  <!-- 		<xsl:attribute name="t_xml"> -->
		  <!-- 		  <xsl:value-of select="boolean(document(concat($parallel_location, $parallel_file)))"/> -->
		  <!-- 		</xsl:attribute> -->
		  
		  <!-- 		<here> -->
		  <!-- 		  <xsl:copy-of select="$here"/> -->
		  <!-- 		</here> -->
		  <!-- 		<there> -->
		  <!-- 		  <xsl:copy-of select="$there"/> -->
		  <!-- 		</there> -->
		</xsl:if>
		
		<xsl:element name="location">
		  <xsl:element name="h_loc">
		    <xsl:value-of select="concat($current_location, $current_file)"/>
		  </xsl:element>
		  <xsl:element name="t_loc">
		    <xsl:value-of select="concat($parallel_location, $parallel_file)"/>
		    <!-- 		  <xsl:value-of select="concat(substring-before($current_location, $slang), -->
		    <!-- 					./$tlang, -->
		    <!-- 					substring-after($current_location, $slang), -->
		    <!-- 					$current_pfile, '.xml')"/> -->
		  </xsl:element>
		</xsl:element>
		<xsl:element name="title">
		  <xsl:value-of select=".//title"/>
		</xsl:element>
		<xsl:copy-of select=".//genre"/>
		<h_translated_from>
		  <xsl:copy-of select=".//translated_from/@xml:lang"/>
		</h_translated_from>
		<h_size>
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
		</h_size>
		
		<xsl:if test="$here = $there">
		  <xsl:variable name="t_doc" select="document(concat($parallel_location, $parallel_file))"/>
		  
		  <t_translated_from>
		    <xsl:copy-of select="$t_doc//translated_from/@xml:lang"/>
		  </t_translated_from>
		  
		  <t_size>
		    <p_count>
		      <xsl:value-of select="count($t_doc//p)"/>
		    </p_count>
		    <e_p_count>
		      <xsl:value-of select="count($t_doc//p[normalize-space(.) = ''])"/>
		    </e_p_count>
		    <ne_p_count>
		      <xsl:value-of select="count($t_doc//p[not(normalize-space(.) = '')])"/>
		    </ne_p_count>
		    
		    <pre_count>
		      <xsl:value-of select="count($t_doc//pre)"/>
		    </pre_count>
		    <e_pre_count>
		      <xsl:value-of select="count($t_doc//pre[normalize-space(.) = ''])"/>
		    </e_pre_count>
		    <ne_pre_count>
		      <xsl:value-of select="count($t_doc//pre[not(normalize-space(.) = '')])"/>
		    </ne_pre_count>
		    
		    <section_count>
		      <xsl:value-of select="count($t_doc//section)"/>
		    </section_count>
		    
		    <e_section_count>
		      <xsl:value-of select="count($t_doc//section[normalize-space(.) = ''])"/>
		    </e_section_count>
		    
		    <ne_section_count>
		      <xsl:value-of select="count($t_doc//section[not(normalize-space(.) = '')])"/>
		    </ne_section_count>
		  </t_size>
		</xsl:if>
		
		<!-- 	      <xsl:element name="pf_name"> -->
		<!-- 		<xsl:value-of select="concat($current_pfile, '.xml')"/> -->
		<!-- 	      </xsl:element> -->
		
	      </file>
	      <xsl:message terminate="no">
		<xsl:value-of select="concat('========================================================================================', $nl)"/>
	      </xsl:message>
	    </xsl:if>
	  </xsl:if>
	</xsl:for-each>
      </xsl:variable>

      <xsl:if test="$debug = 'true'">
	<xsl:message terminate="no">
	  <xsl:value-of select="concat('-----------------------------------------', $nl)"/>
	  <xsl:value-of select="concat('Generating log file:', $nl)"/>
	  <xsl:value-of select="concat('log_', $slang, '2', $tlang, '-parallel-corpus.', $e, $nl)"/>
	  <xsl:value-of select="'-----------------------------------------'"/>
	</xsl:message>
	<xsl:result-document href="./log_{$slang}2{$tlang}-parallel-corpus.{$e}" format="{$outFormat}">
	  <p_files>
	    <xsl:copy-of select="$parallel_files"/>
	  </p_files>
	</xsl:result-document>
      </xsl:if>
      
      <xsl:for-each select="(concat($slang, '2', $tlang), concat($tlang, '2', $slang), 'xxx2yyy', 'all2all')">
	
	<xsl:variable name="cpd" select="."/>
	<xsl:variable name="cpd_1" select="substring-before(., '2')"/>
	<xsl:variable name="cpd_2" select="substring-after(., '2')"/>
	
	<!-- extract the files for lang1_to_lang2 -->
	<xsl:if test="$cpd_1 = $slang">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('Parallel corpus for ', $cpd, $nl)"/>
	    <xsl:value-of select="concat('_________________________________', $nl)"/>
	  </xsl:message>
	  <xsl:for-each select="$parallel_files/file[./t_translated_from/@xml:lang = $cpd_1][not(./h_translated_from/@xml:lang)][h_size/ne_p_count &gt; 0][t_size/ne_p_count &gt; 0]">
	    <xsl:result-document href="{$outDir}/{$cpd}/{$slang}/{(tokenize(./location/h_loc, '/'))[last()]}" format="{$outFormat}">
	      <xsl:copy-of select="document(./location/h_loc)"/>
	    </xsl:result-document>
	    <xsl:result-document href="{$outDir}/{$cpd}/{$tlang}/{(tokenize(./location/t_loc, '/'))[last()]}" format="{$outFormat}">
	      <xsl:copy-of select="document(./location/t_loc)"/>
	    </xsl:result-document>
	  </xsl:for-each>
	</xsl:if>
	<!-- extract the files for lang2_to_lang1 -->
	<xsl:if test="$cpd_2 = $slang">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('Parallel corpus for ', $cpd, $nl)"/>
	    <xsl:value-of select="concat('_________________________________', $nl)"/>
	  </xsl:message>
	  <xsl:for-each select="$parallel_files/file[./h_translated_from/@xml:lang = $cpd_1][not(./t_translated_from/@xml:lang)][h_size/ne_p_count &gt; 0][t_size/ne_p_count &gt; 0]">
	    <xsl:result-document href="{$outDir}/{$cpd}/{$slang}/{(tokenize(./location/h_loc, '/'))[last()]}" format="{$outFormat}">
	      <xsl:copy-of select="document(./location/h_loc)"/>
	    </xsl:result-document>
	    <xsl:result-document href="{$outDir}/{$cpd}/{$tlang}/{(tokenize(./location/t_loc, '/'))[last()]}" format="{$outFormat}">
	      <xsl:copy-of select="document(./location/t_loc)"/>
	    </xsl:result-document>
	  </xsl:for-each>
	</xsl:if>
	<!-- extract the files for which the translated_from info is underspecified -->
	<xsl:if test="$cpd = 'xxx2yyy'">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('Parallel corpus for ', $cpd, $nl)"/>
	    <xsl:value-of select="concat('_________________________________', $nl)"/>
	  </xsl:message>
	  <xsl:for-each select="$parallel_files/file[not(./h_translated_from/@xml:lang)][not(./t_translated_from/@xml:lang)][h_size/ne_p_count &gt; 0][t_size/ne_p_count &gt; 0]">
	    <xsl:result-document href="{$outDir}/{$cpd}/{$slang}/{(tokenize(./location/h_loc, '/'))[last()]}" format="{$outFormat}">
	      <xsl:copy-of select="document(./location/h_loc)"/>
	    </xsl:result-document>
	    <xsl:result-document href="{$outDir}/{$cpd}/{$tlang}/{(tokenize(./location/t_loc, '/'))[last()]}" format="{$outFormat}">
	      <xsl:copy-of select="document(./location/t_loc)"/>
	    </xsl:result-document>
	  </xsl:for-each>
	</xsl:if>
	<!-- extract the files for which the translated_from info is overspecified (Man weiss ja nie!) -->
	<xsl:if test="$cpd = 'all2all'">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('Parallel corpus for ', $cpd, $nl)"/>
	    <xsl:value-of select="concat('_________________________________', $nl)"/>
	  </xsl:message>
	  <xsl:for-each select="$parallel_files/file[./h_translated_from/@xml:lang = $tlang][./t_translated_from/@xml:lang = $slang][h_size/ne_p_count &gt; 0][t_size/ne_p_count &gt; 0]">
	    <xsl:result-document href="{$outDir}/{$cpd}/{$slang}/{(tokenize(./location/h_loc, '/'))[last()]}" format="{$outFormat}">
	      <xsl:copy-of select="document(./location/h_loc)"/>
	    </xsl:result-document>
	    <xsl:result-document href="{$outDir}/{$cpd}/{$tlang}/{(tokenize(./location/t_loc, '/'))[last()]}" format="{$outFormat}">
	      <xsl:copy-of select="document(./location/t_loc)"/>
	    </xsl:result-document>
	  </xsl:for-each>
	</xsl:if>
      </xsl:for-each>

    </xsl:template>
    
</xsl:stylesheet>
