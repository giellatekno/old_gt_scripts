<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:saxon="http://icl.com/saxon"
                exclude-result-prefixes="xsl fo html saxon">
<!-- find the title in Ávvir xml-files -->
	<xsl:output method="text"/>
	<xsl:template match="p">
		<xsl:if test="@class = 'tittel'">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
