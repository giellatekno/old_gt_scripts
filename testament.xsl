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
	<xsl:element name="section">
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="row/p[1]">
</xsl:template>

<xsl:template match="row/p[2]">
	<xsl:element name="p">
		<xsl:attribute name="type">title</xsl:attribute>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="row/p[3]">
	<xsl:element name="p">
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

</xsl:stylesheet>