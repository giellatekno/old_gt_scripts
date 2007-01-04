<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:str="http://exslt.org/strings" >

<!--$Revision$ -->

<!--
Output the header information
-->
<xsl:output method="xml"
            version="1.0"
            encoding="UTF-8"
            indent="yes"
            doctype-public="-//UIT//DTD Corpus V1.0//EN"
            doctype-system="http://giellatekno.uit.no/dtd/corpus.dtd"/>

<!--
   Root element
-->

<!--
Find the book element, which then is converted to the "document" tag
-->
<xsl:template match="book">
    <!-- Open the "document" tag, which is the root element of the UIT DTD -->
    <xsl:element name="document">
        <xsl:attribute name="xml:lang">
        </xsl:attribute>

        <!-- Open the "header" tag -->
        <xsl:element name="header">
            <!-- Use the function "bookinfo" -->
            <xsl:apply-templates select="bookinfo/title"/>
            <xsl:apply-templates select="bookinfo/author"/>
            <xsl:apply-templates select="bookinfo/date"/>
            <xsl:apply-templates select="bookinfo/corpname"/>
            <xsl:apply-templates select="bookinfo"/>
            <!-- Use the function "info, DocBook V5.0" -->
            <xsl:apply-templates select="info/title"/>
            <xsl:apply-templates select="info/author"/>
            <xsl:apply-templates select="info/date"/>
            <xsl:apply-templates select="info/corpname"/>
            <xsl:apply-templates select="info"/>
        <!-- Close the "header" tag -->
        </xsl:element>

        <!-- Then insert the "body" tag -->
        <xsl:element name="body">
            <!-- Apply the following functions -->
            <xsl:apply-templates select="title"/>
            <xsl:apply-templates select="chapter"/>
            <xsl:apply-templates select="section"/>
            <xsl:apply-templates select="sect1"/>
            <xsl:apply-templates select="para[not(informaltable) and not(table) and not(orderedlist) and not(itemizedlist)]"/>
            <xsl:apply-templates select="para//table"/>
            <xsl:apply-templates select="para//informaltable"/>
            <xsl:apply-templates select="table"/>
            <xsl:apply-templates select="orderedlist"/>
            <xsl:apply-templates select="itemizedlist"/>
            <xsl:apply-templates select="para//orderedlist"/>
            <xsl:apply-templates select="para//itemizedlist"/>
        <!-- Close the "body" tag -->
        </xsl:element>

    <!-- Close the "document" tag -->
    </xsl:element>
</xsl:template>


<!--
    Transform the meta information found in the "bookinfo" tag in docbook to the wanted header info of the UIT DTD.
-->

<!-- Title -->
<xsl:template match="bookinfo/title|info/title">
	<xsl:element name="title">
		<xsl:value-of select="text()"/>
	</xsl:element>
</xsl:template>

<!-- Author -->
<xsl:template match="bookinfo/author|info/author">
	<xsl:element name="author">
        <xsl:element name="person">
            <xsl:attribute name="firstname">
                <xsl:value-of select="forname"/>
            </xsl:attribute>
            <xsl:attribute name="lastname">
                <xsl:value-of select="surname"/>
            </xsl:attribute>
            <xsl:attribute name="sex">unknown</xsl:attribute>
            <xsl:attribute name="born" />
            <xsl:attribute name="nationality"><xsl:value-of select="ancestor::book/@lang" /></xsl:attribute>
        </xsl:element>
    </xsl:element>
</xsl:template>

<!-- Date -->
<xsl:template match="bookinfo/date|info/data">
	<xsl:element name="year">
        <xsl:value-of select="number(substring-before(., '-'))"/>
    </xsl:element>
</xsl:template>

<!-- Some additional info -->
<xsl:template match="bookinfo|info">
    <!-- wordcount, availability, completeness -->
    <xsl:element name="wordcount">
    		<!-- ancestor::book/bookinfo/following-sibling::*/text() following::* ancestor::*-->
    		<xsl:value-of select="count(str:tokenize(string(ancestor::*))) - count(str:tokenize(string(self::*)))" />
    </xsl:element>

<!-- Close the "header" tag -->
</xsl:template>



<!--
    Corpus text body
-->


<!-- Chapter -->
<xsl:template match="chapter">
        <xsl:apply-templates select="title"/>
        <xsl:apply-templates select="chapter"/>
        <xsl:apply-templates select="para[not(informaltable) and not(table) and not(orderedlist) and not(itemizedlist)]"/>
	    <xsl:apply-templates select="para//informaltable"/>
	    <xsl:apply-templates select="para//table"/>
        <xsl:apply-templates select="table"/>
        <xsl:apply-templates select="para//orderedlist"/>
        <xsl:apply-templates select="para//itemizedlist"/>
        <xsl:apply-templates select="orderedlist"/>
        <xsl:apply-templates select="itemizedlist"/>
        <xsl:apply-templates select="sect1"/>
 </xsl:template>

<!-- Sect1 -->
<xsl:template match="sect1">
    <xsl:apply-templates select="title"/>
	<xsl:call-template name="sect"/>
    <xsl:apply-templates select="sect2"/>
 </xsl:template>

<!-- Sect2 -->
<xsl:template match="sect2">
    <xsl:apply-templates select="title"/>
	<xsl:call-template name="sect"/>
    <xsl:apply-templates select="sect3"/>
 </xsl:template>

<!-- Sect3 -->
<xsl:template match="sect3">
   <xsl:apply-templates select="title"/>
	<xsl:call-template name="sect"/>
    <xsl:apply-templates select="sect4"/>
 </xsl:template>

<!-- Sect4 -->
<xsl:template match="sect4">
    <xsl:apply-templates select="title"/>
	<xsl:call-template name="sect"/>
    <xsl:apply-templates select="sect5"/>
 </xsl:template>

<!-- Sect5 -->
<xsl:template match="sect5">
    <xsl:apply-templates select="title"/>
	<xsl:call-template name="sect"/>
 </xsl:template>

<xsl:template name="sect">
    <xsl:apply-templates select="para[not(informaltable) and not(table) and not(orderedlist) and not(itemizedlist)]"/>
    <xsl:apply-templates select="para//table"/>
    <xsl:apply-templates select="para//informaltable"/>
    <xsl:apply-templates select="table"/>
    <xsl:apply-templates select="para//orderedlist"/>
    <xsl:apply-templates select="para//itemizedlist"/>
</xsl:template>

<!-- Title -->
<xsl:template match="title">
	<xsl:if test="normalize-space(.)">
           <xsl:element name="p">
              <xsl:attribute name="type">title</xsl:attribute>
			<xsl:apply-templates mode="para" />
           </xsl:element>
    </xsl:if>
</xsl:template>


<!-- Para -->
<xsl:template match="para">
    <xsl:if test="normalize-space(.)">
    		<xsl:choose>
    			<!-- Guessing whether a para is actually a title -->
    			<xsl:when test="emphasis[@role='bold'] and 130 > string-length(.)">
    				<xsl:element name="p">
    					<xsl:attribute
						name="type">title</xsl:attribute>
	                 <xsl:apply-templates mode="para" />
    				</xsl:element>
    			</xsl:when>
    			<xsl:otherwise>
				<xsl:element name="p">
		            <xsl:apply-templates/>
				</xsl:element>
		    </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>


<!-- Emphasis -->
<xsl:template match="emphasis|em">
    <xsl:element name="em">
			<xsl:if test="@role">
            <xsl:attribute name="type">
            <xsl:value-of select="@role"/>
            </xsl:attribute>
			</xsl:if>
        <xsl:apply-templates />
    </xsl:element>
</xsl:template>

<xsl:template match="emphasis|em" mode="para">	
<xsl:apply-templates />
</xsl:template>

<!-- Table -->

<xsl:template match="informaltable|tgroup|colspec">
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="tbody">
    <xsl:element name="table">
        <xsl:apply-templates select="row" />
    </xsl:element>
</xsl:template>

<xsl:template match="row">
    <xsl:element name="row">
        <xsl:apply-templates select="entry" />
    </xsl:element>
</xsl:template>

<xsl:template match="row/entry">
    <xsl:element name="p">
        <xsl:attribute name="type">tablecell</xsl:attribute>
        <xsl:apply-templates />
    </xsl:element>
</xsl:template>

<xsl:template match="tr">
    <xsl:element name="row">
        <xsl:apply-templates select="td" />
    </xsl:element>
</xsl:template>

<xsl:template match="td">
    <xsl:element name="p">
        <xsl:attribute name="type">tablecell</xsl:attribute>
        <xsl:apply-templates />
    </xsl:element>
</xsl:template>


<!-- List -->
<xsl:template match="orderedlist">
    <xsl:if test="normalize-space(.)">
        <xsl:element name="list">
            <xsl:apply-templates select="listitem" />
        </xsl:element>
    </xsl:if>
</xsl:template>

<xsl:template match="itemizedlist">
    <xsl:if test="normalize-space(.)">
        <xsl:element name="list">
            <xsl:apply-templates select="listitem" />
        </xsl:element>
    </xsl:if>
</xsl:template>

<xsl:template match="listitem">
    <xsl:if test="normalize-space(.)">
        <xsl:element name="p">
            <xsl:attribute name="type">listitem</xsl:attribute>
            <xsl:apply-templates mode="listitem"/>
        </xsl:element>
    </xsl:if>
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

<!-- Ignored elements -->
<xsl:template match="footnote"/>
<xsl:template match="footnoteref"/>
<xsl:template match="note"/>
<xsl:template match="tip"/>

<xsl:template match="corpname"/>
<xsl:template match="subscript|superscript"/>
<xsl:template match="beginpage"/>

</xsl:stylesheet>
