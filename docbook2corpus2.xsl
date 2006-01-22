<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:str="http://exslt.org/strings" >

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
            <xsl:value-of select="@lang"/>
        </xsl:attribute>

        <!-- Open the "header" tag -->
        <xsl:element name="header">
            <!-- Use the function "bookinfo" -->
            <xsl:apply-templates select="bookinfo/title"/>
            <xsl:apply-templates select="bookinfo/author"/>
            <xsl:apply-templates select="bookinfo/date"/>
            <xsl:apply-templates select="bookinfo/corpname"/>
            <xsl:apply-templates select="bookinfo"/>
        <!-- Close the "header" tag -->
        </xsl:element>

        <!-- Then insert the "body" tag -->
        <xsl:element name="body">
            <!-- Apply the following functions -->
            <xsl:apply-templates select="title"/>
            <xsl:apply-templates select="chapter"/>
            <xsl:apply-templates select="para"/>
            <xsl:apply-templates select="table"/>
            <xsl:apply-templates select="orderedlist"/>
        <!-- Close the "body" tag -->
        </xsl:element>

    <!-- Close the "document" tag -->
    </xsl:element>
</xsl:template>


<!--
    Transform the meta information found in the "bookinfo" tag in docbook to the wanted header info of the UIT DTD.
-->

<!-- Title -->
<xsl:template match="bookinfo/title">
	<xsl:element name="title">
		<xsl:value-of select="text()"/>
	</xsl:element>
</xsl:template>

<!-- Author -->
<xsl:template match="bookinfo/author">
<xsl:choose>
<xsl:when test="count(bookinfo/author) > 0">
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
</xsl:when>
</xsl:choose>
</xsl:template>

<!-- Date -->
<xsl:template match="bookinfo/date">
	<xsl:element name="year">
        <xsl:value-of select="number(substring-before(., '-'))"/>
    </xsl:element>
</xsl:template>

<!-- Publisher -->
<xsl:template match="bookinfo/corpname">
<xsl:choose>
<xsl:when test="count(bookinfo/corpname) > 0">
	<xsl:element name="publChannel">
        <xsl:element name="publisher">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:element>
</xsl:when>
</xsl:choose>
</xsl:template>

<!-- Some additional info -->
<xsl:template match="bookinfo">
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
	<xsl:element name="chapter">
        <xsl:apply-templates select="title"/>
        <xsl:apply-templates select="chapter"/>
        <xsl:apply-templates select="para"/>
        <xsl:apply-templates select="table"/>
        <xsl:apply-templates select="orderedlist"/>
    </xsl:element>
 </xsl:template>

<!-- Title -->
<xsl:template match="title">
	<xsl:if test="normalize-space(.)">
		<xsl:choose>
	        <!-- Guessing whether a title is actually a paragraph -->
	        <xsl:when
	            test="string-length(.) > 130 and not(starts-with(translate(., '0123456789', '9999999999'), '9'))">
	            <xsl:element name="p">
	                <xsl:apply-templates/>
	            </xsl:element>
	        </xsl:when>
	        <!-- Else it is a title -->
	        <xsl:otherwise>
	            <xsl:element name="p">
	                <xsl:attribute name="type">title</xsl:attribute>
	                <xsl:apply-templates mode="para" />
	            </xsl:element>
	        </xsl:otherwise>
	    </xsl:choose>
    </xsl:if>
</xsl:template>


<!-- Para -->
<xsl:template match="para">
    <xsl:if test="normalize-space(.)">
    		<xsl:choose>
    			<!-- Guessing whether a para is actually a title -->
    			<xsl:when test="emphasis[@role='bold'] and 130 > string-length(.)">
    				<xsl:element name="p">
    					<xsl:attribute name="type">title</xsl:attribute>
	                 <xsl:apply-templates mode="para" />
    				</xsl:element>
    			</xsl:when>
    			<xsl:otherwise>
		        <xsl:element name="p">
		            <xsl:apply-templates />
		        </xsl:element>
		    </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>


<!-- Emphasis -->
<xsl:template match="emphasis">
    <xsl:element name="em">
        <xsl:attribute name="type">
            <xsl:value-of select="@role"/>
        </xsl:attribute>
        <xsl:apply-templates />
    </xsl:element>
</xsl:template>

<xsl:template match="emphasis" mode="para">
	<xsl:apply-templates />
</xsl:template>

<!-- Table -->
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

<xsl:template match="entry">
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

</xsl:stylesheet>
