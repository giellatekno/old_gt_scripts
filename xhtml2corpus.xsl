<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:fo="http://www.w3.org/1999/XSL/Format" 
                xmlns:html="http://www.w3.org/1999/xhtml" 
                xmlns:saxon="http://icl.com/saxon"
                exclude-result-prefixes="xsl fo html saxon">

<!-- 
Usage: ~/Desktop/bin/tidy - -quote-nbsp no - -add-xml-decl yes 
						- -enclose-block-text yes -asxml -utf8 -language sme 
						file.html | 
xsltproc /Users/tomi/Documents/eclipse/workspace/gt/script/xhtml2corpus.xsl - > file.xml
-->

<xsl:output method="xml"
		   version="1.0"
		   encoding="UTF-8"
		   indent="yes"
		   doctype-public="-//UIT//DTD Corpus V1.0//EN"
		   doctype-system="http://giellatekno.uit.no/dtd/corpus.dtd"/>

<xsl:param name="filename"></xsl:param> 

<!-- Main block-level conversions -->
<xsl:template match="html:html">
 <document>
  <xsl:attribute name="xml:lang">
  </xsl:attribute>
  <xsl:apply-templates select="html:head"/>
  <xsl:apply-templates select="html:body"/>
 </document>
</xsl:template>

<xsl:template match="html:head">
 <header>
  <title>
   <xsl:value-of select="../html:body//html:h1[1]
   						|../html:body//html:h2[1]
   						|../html:body//html:h3[1]"/>
  </title>
 </header>
</xsl:template>

<!-- This template converts each HTML file encountered into a DocBook 
     section.  For a title, it selects the first h1 element -->
<xsl:template match="html:body">
 <body>
  <p type="title">
   <xsl:value-of select=".//html:h1[1]
   						|.//html:h2[1]
   						|.//html:h3[1]"/>
  </p>

  <xsl:apply-templates select=".//html:*"/>
 </body>
</xsl:template>

<!-- This template matches on all HTML header items and makes them into 
     bridgeheads. It attempts to assign an ID to each bridgehead by looking 
     for a named anchor as a child of the header or as the immediate preceding
     or following sibling -->
<xsl:template match="html:h1
              |html:h2
              |html:h3
              |html:h4
              |html:h5
              |html:h6">
 <xsl:text>
 
 </xsl:text>
 <section>
 <p type="title">
 <!--
  <xsl:choose>
   <xsl:when test="count(html:p/@name)">
    <xsl:attribute name="id">
     <xsl:value-of select="html:p/@name"/>
    </xsl:attribute>
   </xsl:when>
   <xsl:when test="preceding-sibling::* = preceding-sibling::html:p[@name != '']">
    <xsl:attribute name="id">
    <xsl:value-of select="concat($prefix,preceding-sibling::html:p[1]/@name)"/>
    </xsl:attribute>
   </xsl:when>
   <xsl:when test="following-sibling::* = following-sibling::html:p[@name != '']">
    <xsl:attribute name="id">
    <xsl:value-of select="concat($prefix,following-sibling::html:p[1]/@name)"/>
    </xsl:attribute>
   </xsl:when>
  </xsl:choose>
  -->
  <xsl:apply-templates/>
 </p>
 </section>
</xsl:template>
        
<!-- These templates perform one-to-one conversions of HTML elements into
     DocBook elements -->
<xsl:template match="html:p">
<!-- if the paragraph has no text (perhaps only a child <img>), don't 
     make it a para -->
 <xsl:choose>
  <xsl:when test="normalize-space(.) = ''">
   <xsl:apply-templates/>
  </xsl:when>
  <xsl:otherwise>
<xsl:text>

</xsl:text>
 <p>
  <xsl:apply-templates/>
 </p>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>
<xsl:template match="html:pre">
 <programlisting>
  <xsl:apply-templates/>
 </programlisting>
</xsl:template>

<!-- Hyperlinks -->
<!--
<xsl:template match="html:a[contains(@href,'http://')]" priority="1.5">
 <ulink>
  <xsl:attribute name="url">
   <xsl:value-of select="normalize-space(@href)"/>
  </xsl:attribute>
  <xsl:apply-templates/>
 </ulink>
</xsl:template>
<xsl:template match="html:a[contains(@href,'ftp://')]" priority="1.5">
 <ulink>
  <xsl:attribute name="url">
   <xsl:value-of select="normalize-space(@href)"/>
  </xsl:attribute>
  <xsl:apply-templates/>
 </ulink>
</xsl:template>

<xsl:template match="html:a[contains(@href,'#')]" priority="0.6">
 <xref>
  <xsl:attribute name="linkend">
   <xsl:call-template name="make_id">
    <xsl:with-param name="string" select="substring-after(@href,'#')"/>
   </xsl:call-template>
  </xsl:attribute>
 </xref>
</xsl:template>
<xsl:template match="html:a[@name != '']" priority="0.6">
 <anchor>
  <xsl:attribute name="id">
   <xsl:call-template name="make_id">
    <xsl:with-param name="string" select="@name"/>
   </xsl:call-template>
  </xsl:attribute>
  <xsl:apply-templates/>
 </anchor>
</xsl:template>

<xsl:template match="html:a[@href != '']">
 <xref>
  <xsl:attribute name="linkend">
   <xsl:value-of select="$prefix"/>
   <xsl:text>_</xsl:text>
   <xsl:call-template name="make_id">
    <xsl:with-param name="string" select="@href"/>
   </xsl:call-template>
  </xsl:attribute>
 </xref>
</xsl:template>
-->

<!-- Need to come up with good template for converting filenames into ID's -->
<xsl:template name="make_id">
 <xsl:param name="string" select="''"/>
 <xsl:variable name="fixedname">
  <xsl:call-template name="get_filename">
   <xsl:with-param name="path" select="translate($string,' \()','_/_')"/>
  </xsl:call-template>
 </xsl:variable>
 <xsl:choose>
  <xsl:when test="contains($fixedname,'.htm')">
   <xsl:value-of select="substring-before($fixedname,'.htm')"/>
  </xsl:when>
  <xsl:otherwise>
   <xsl:value-of select="$fixedname"/>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template name="string.subst">
 <xsl:param name="string" select="''"/>
 <xsl:param name="substitute" select="''"/>
 <xsl:param name="with" select="''"/>
 <xsl:choose>
  <xsl:when test="contains($string,$substitute)">
   <xsl:variable name="pre" select="substring-before($string,$substitute)"/>
   <xsl:variable name="post" select="substring-after($string,$substitute)"/>
   <xsl:call-template name="string.subst">
    <xsl:with-param name="string" select="concat($pre,$with,$post)"/>
    <xsl:with-param name="substitute" select="$substitute"/>
    <xsl:with-param name="with" select="$with"/>
   </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
   <xsl:value-of select="$string"/>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- Images -->
<!-- Images and image maps -->
<!--
<xsl:template match="html:img">
 <xsl:variable name="tag_name">
  <xsl:choose>
   <xsl:when test="boolean(parent::html:p) and 
        boolean(normalize-space(parent::html:p/text()))">
    <xsl:text>inlinemediaobject</xsl:text>
   </xsl:when>
   <xsl:otherwise>mediaobject</xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <xsl:element name="{$tag_name}">
  <imageobject>
   <xsl:call-template name="process.image"/>
  </imageobject>
 </xsl:element>
</xsl:template>

<xsl:template name="process.image">
 <imagedata>
<xsl:attribute name="fileref">
 <xsl:call-template name="make_absolute">
  <xsl:with-param name="filename" select="@src"/>
 </xsl:call-template>
</xsl:attribute>
<xsl:if test="@height != ''">
 <xsl:attribute name="depth">
  <xsl:value-of select="@height"/>
 </xsl:attribute>
</xsl:if>
<xsl:if test="@width != ''">
 <xsl:attribute name="width">
  <xsl:value-of select="@width"/>
 </xsl:attribute>
</xsl:if>
 </imagedata>
</xsl:template>

<xsl:template name="make_absolute">
 <xsl:param name="filename"/>
 <xsl:variable name="name_only">
  <xsl:call-template name="get_filename">
   <xsl:with-param name="path" select="$filename"/>
  </xsl:call-template>
 </xsl:variable>
 <xsl:value-of select="$graphics_location"/><xsl:value-of select="$name_only"/>
</xsl:template>
-->

<xsl:template match="html:ul[count(*) = 0]">
 <xsl:message>Matched</xsl:message>
 <blockquote>
  <xsl:apply-templates/>
 </blockquote>
</xsl:template>

<xsl:template name="get_filename">
 <xsl:param name="path"/>
 <xsl:choose>
  <xsl:when test="contains($path,'/')">
   <xsl:call-template name="get_filename">
    <xsl:with-param name="path" select="substring-after($path,'/')"/>
   </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
   <xsl:value-of select="$path"/>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- LIST ELEMENTS -->
<xsl:template match="html:ul">
 <xsl:text>
 
 </xsl:text>
 <list>
  <xsl:apply-templates/>
 </list>
</xsl:template>

<xsl:template match="html:ol">
 <xsl:text>
 
 </xsl:text>
 <list>
  <xsl:apply-templates/>
 </list>
</xsl:template>
        
<!-- This template makes a DocBook variablelist out of an HTML definition list -->
<xsl:template match="html:dl">
 <variablelist>
  <xsl:for-each select="html:dt">
   <varlistentry>
    <term>
     <xsl:apply-templates/>
    </term>
    <listitem>
     <xsl:apply-templates select="following-sibling::html:dd[1]"/>
    </listitem>
   </varlistentry>
  </xsl:for-each>
 </variablelist>
</xsl:template>

<xsl:template match="html:dd">
 <xsl:choose>
  <xsl:when test="boolean(html:p)">
   <xsl:apply-templates/>
  </xsl:when>
  <xsl:otherwise>
   <para>
    <xsl:apply-templates/>
   </para>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="html:li">
  <xsl:choose>
   <xsl:when test="count(html:p) = 0">
    <p type="listitem">
     <xsl:apply-templates/>
    </p>
   </xsl:when>
   <xsl:otherwise>
    <xsl:apply-templates/>
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>
        
<xsl:template match="*">
 <xsl:message>No template for <xsl:value-of select="name()"/>
 </xsl:message>
 <xsl:apply-templates/>
</xsl:template>

<xsl:template match="@*">
 <xsl:message>No template for <xsl:value-of select="name()"/>
 </xsl:message>
 <xsl:apply-templates/>
</xsl:template>
        
<!-- inline formatting -->
<xsl:template match="html:b">
 <emphasis role="bold">
  <xsl:apply-templates/>
 </emphasis>
</xsl:template>
<xsl:template match="html:i">
 <emphasis>
  <xsl:apply-templates/>
 </emphasis>
</xsl:template>
<xsl:template match="html:u">
 <citetitle>
  <xsl:apply-templates/>
 </citetitle>
</xsl:template>
        
<!-- Ignored elements -->
<xsl:template match="html:hr"/>
<xsl:template match="html:h1[1]|html:h2[1]|html:h3[1]" priority="1"/>
<xsl:template match="html:br"/>
<xsl:template match="html:p[normalize-space(.) = '' and count(*) = 0]"/>
<xsl:template match="text()">
 <xsl:choose>
  <xsl:when test="normalize-space(.) = ''"></xsl:when>
  <xsl:otherwise><xsl:copy/></xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- Workbench Hacks -->
<!--
<xsl:template match="html:div[contains(@style,'margin-left: 2em')]">
 <blockquote><para>
  <xsl:apply-templates/></para>
 </blockquote>
</xsl:template>

<xsl:template match="html:a[@href != '' 
                      and not(boolean(ancestor::html:p|ancestor::html:li))]" 
              priority="1">
 <para>
 <xref>
  <xsl:attribute name="linkend">
   <xsl:value-of select="$prefix"/>
   <xsl:text>_</xsl:text>
   <xsl:call-template name="make_id">
    <xsl:with-param name="string" select="@href"/>
   </xsl:call-template>
  </xsl:attribute>
 </xref>
 </para>
</xsl:template>

<xsl:template match="html:a[contains(@href,'#') 
                    and not(boolean(ancestor::html:p|ancestor::html:li))]" 
              priority="1.1">
 <para>
 <xref>
  <xsl:attribute name="linkend">
   <xsl:value-of select="$prefix"/>
   <xsl:text>_</xsl:text>
   <xsl:call-template name="make_id">
    <xsl:with-param name="string" select="substring-after(@href,'#')"/>
   </xsl:call-template>
  </xsl:attribute>
 </xref>
 </para>
</xsl:template>
-->

<!-- Table conversion -->
<xsl:template match="html:table">
 <table>
  <xsl:apply-templates select="html:tr"/>
 </table>
</xsl:template>

<xsl:template match="html:tr">
 <row>
  <xsl:apply-templates/>
 </row>
</xsl:template>

<xsl:template match="html:th|html:td">
 <xsl:variable name="position" select="count(preceding-sibling::*) + 1"/>
 <p type="tablecell">
  <xsl:apply-templates/>
 </p>
</xsl:template>

<xsl:template match="html:td_null">
 <xsl:apply-templates/>
</xsl:template>

<xsl:template name="count_columns">
 <xsl:param name="table" select="."/>
 <xsl:param name="row" select="$table/html:tr[1]"/>
 <xsl:param name="max" select="0"/>
 <xsl:choose> 
  <xsl:when test="local-name($table) != 'table'">
   <xsl:message>Attempting to count columns on a non-table element</xsl:message>
  </xsl:when>
  <xsl:when test="local-name($row) != 'tr'">
   <xsl:message>Row parameter is not a valid row</xsl:message>
  </xsl:when>
  <xsl:otherwise>
   <!-- Count cells in the current row -->
   <xsl:variable name="current_count">
    <xsl:call-template name="count_cells">
     <xsl:with-param name="cell" select="$row/html:td[1]|$row/html:th[1]"/>
    </xsl:call-template>
   </xsl:variable>
   <!-- Check for the maximum value of $current_count and $max -->
   <xsl:variable name="new_max">
    <xsl:choose>
     <xsl:when test="$current_count &gt; $max">
      <xsl:value-of select="number($current_count)"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="number($max)"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <!-- If this is the last row, return $max, otherwise continue -->
   <xsl:choose>
    <xsl:when test="count($row/following-sibling::html:tr) = 0">
     <xsl:value-of select="$new_max"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:call-template name="count_columns">
      <xsl:with-param name="table" select="$table"/>
      <xsl:with-param name="row" select="$row/following-sibling::html:tr"/>
      <xsl:with-param name="max" select="$new_max"/>
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template name="count_cells">
 <xsl:param name="cell"/>
 <xsl:param name="count" select="0"/>
 <xsl:variable name="new_count">
  <xsl:choose>
   <xsl:when test="$cell/@colspan &gt; 1">
    <xsl:value-of select="number($cell/@colspan) + number($count)"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="number('1') + number($count)"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <xsl:choose>
  <xsl:when test="count($cell/following-sibling::*) &gt; 0">
   <xsl:call-template name="count_cells">
    <xsl:with-param name="cell"
                    select="$cell/following-sibling::*[1]"/>
    <xsl:with-param name="count" select="$new_count"/>
   </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
   <xsl:value-of select="$new_count"/>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

</xsl:stylesheet>
