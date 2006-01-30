<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">


<!--
Output the header information
-->
<xsl:output method="xml"
            version="1.0"
            encoding="UTF-8"
            indent="yes"
            doctype-public="-//UIT//DTD Corpus V1.0//EN"
            doctype-system="http://giellatekno.uit.no/dtd/corpus.dtd"/>

            



<xsl:template match="document">
	<xsl:copy>
		 <xsl:attribute name="xml:lang">
        		<xsl:value-of select="@xml:lang"/>
        	</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>

<xsl:template match="header">
	<xsl:copy-of select="." />
</xsl:template>

<xsl:template match="row">
	<xsl:if test="normalize-space(child::p[3])">
	<xsl:element name="section">
		<xsl:apply-templates />
	</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template match="row/p[1]">
</xsl:template>

<xsl:template match="row/p[2]">
	<xsl:element name="p">
		<xsl:attribute name="counter">
			<xsl:value-of select='text()' />
		</xsl:attribute>
	</xsl:element>
</xsl:template>

<xsl:template match="row/p[3]">
	<xsl:element name="p">
		<xsl:if test="contains(preceding-sibling::p[2], '3') ">
			<xsl:attribute name="type">title</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

</xsl:stylesheet>