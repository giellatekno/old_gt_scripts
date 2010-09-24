<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet	version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:java-file="java:java.io.File"
		xmlns:java-uri="java:java.net.URI"
		xmlns:misc="someURI">
  
  <xsl:function name="misc:file-exists" as="xs:boolean">
    <xsl:param name="uri" as="xs:string?"/>
    <xsl:value-of
	select="java-file:exists(java-file:new(java-uri:new($uri)))"/>
  </xsl:function>
</xsl:stylesheet>

