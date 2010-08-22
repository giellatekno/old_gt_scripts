<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:str="http://exslt.org/strings" >

<!-- Stylesheet template for changing the variable values -->
<!-- in file specific xsl-files of corpus database.       -->
<!-- Called from corpus_fix_meta.sh                       -->
<!-- Test the script:                                     -->
<!-- xsltproc --novalid chage_xsl.xsl file.xsl > file.tmp -->

<!-- Copy the following block for each variable that is changed. -->

<!-- change: -->
<!-- 1. the variable name @name in match block    -->
<!-- 2. the variable name in <text></text> block  -->
<!-- 3. the variable value in <text></text> block -->
<xsl:template match='xsl:variable[@name="license_type"]'>
	<xsl:element name="xsl:variable">
	<xsl:attribute name="name">
	<text>license_type</text>
	</xsl:attribute>

	<xsl:attribute name="select">
	<text>'free'</text>
	</xsl:attribute>
	</xsl:element>
</xsl:template>


<!-- This block copies everything else unchanged. -->
 <xsl:template match="node()|@*">
     <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
     </xsl:copy>
 </xsl:template>

</xsl:stylesheet>
