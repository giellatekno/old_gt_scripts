<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="xml" 
            version="1.0" 
            encoding="UTF-8" 
            indent="yes"
            doctype-public="-//UIT//DTD Corpus V1.0//EN"
            doctype-system="http://giellatekno.uit.no/dtd/corpus.dtd"/>

<xsl:template match="node()|@*">
    <xsl:copy>
        <xsl:attribute name="id">
            <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
        <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>