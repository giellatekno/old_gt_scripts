<?xml version="1.0" encoding="UTF-8"?>
<!--+
	| add_error_markup.xsl
	|
	| This stylesheet uses XSLT 2 regex and grouping features + recursion to
	| convert the ()$€£¥() error markup to xsl elements.
	+-->

<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
			  version="1.0" 
			  encoding="UTF-8"
			  indent="yes"/>

 <!-- Match all paragraphs containing error markup: -->
 <xsl:template match="p[matches(.,'[€$£¥]')]">
  <p>
    <!--xsl:choose>
      <xsl:when test="em | hyph | span"> < ! - - Possible content of a converted doc- - >
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose-->
    <xsl:variable name="text" select="."/>
    <xsl:call-template name="add-markup">
      <xsl:with-param name="text" select="."/>
    </xsl:call-template>
  </p>
</xsl:template>

<xsl:template name="add-markup">
    <xsl:param name="text" />

    <xsl:analyze-string select="$text"
         regex="(.* )(\w+)$(\w+)( .*)">
  
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
        <errorort>
          <xsl:attribute name="correct">
            <xsl:value-of select="regex-group(3)"/>
          </xsl:attribute>
          <xsl:value-of select="regex-group(2)"/>
        </errorort>
        <xsl:value-of select="regex-group(4)"/>
      </xsl:matching-substring>
  
      <xsl:non-matching-substring>
        NO MATCHES!!!
        <xsl:value-of select="$text"/>
      </xsl:non-matching-substring>
  
    </xsl:analyze-string>
</xsl:template>

<!-- Copy everything else -->
 <xsl:template match="node()|@*">
     <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
     </xsl:copy>
 </xsl:template>

</xsl:stylesheet>
