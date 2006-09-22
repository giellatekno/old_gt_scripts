<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id:  -->

<!-- xsl-file for creating empty document in case of constant errors -->

<!-- Format query results for display -->

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    version="1.0">

<xsl:output method="xml" 
            version="1.0" 
            encoding="UTF-8" 
            indent="yes"
            doctype-public="-//UIT//DTD Corpus V1.0//EN"
			doctype-system="http://giellatekno.uit.no/dtd/corpus.dtd"/> 

<!-- Add info about the main language: -->
<xsl:template  match="document">
    <xsl:element name="document">
    <xsl:attribute name="xml:lang">
	<xsl:choose>
    <xsl:when test="$mainlang">
            <xsl:value-of select="$mainlang"/>
	</xsl:when>
    <xsl:when test="string-length(@xml:lang) = 0">
            <xsl:value-of select="$smelang"/>
	</xsl:when>
	<xsl:otherwise>
            <xsl:value-of select="@xml:lang"/>
	</xsl:otherwise>
	</xsl:choose>
    </xsl:attribute>

	<xsl:element name="header">
    <xsl:choose>
        <xsl:when test="$title">
		    <xsl:element name="title">
                <xsl:value-of select="$title"/>
		     </xsl:element>
        </xsl:when>
		<xsl:when test="header/title">
              <xsl:apply-templates select="header/title"/>
		</xsl:when>
		<xsl:otherwise>
		    <xsl:element name="title">
		     </xsl:element>
		</xsl:otherwise>
	    </xsl:choose>

	<xsl:choose>
		<xsl:when test="$genre">
			<xsl:element name="genre">
				<xsl:attribute name="code">
					<xsl:value-of select="$genre"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:when>
		<xsl:when test="header/genre">
            <xsl:apply-templates select="header/genre"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="genre">
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>

	<!-- Only first author is tested from the original documents, others -->
	<!-- are just added -->
		<xsl:choose>
        <xsl:when test="$author1_ln">
			 <xsl:element name="author">
				<xsl:element name="person">
                <xsl:attribute name="firstname">
                    <xsl:value-of select="$author1_fn"/>
                </xsl:attribute>
                <xsl:attribute name="lastname">
                    <xsl:value-of select="$author1_ln"/>
                </xsl:attribute>
                <xsl:attribute name="sex">
                    <xsl:value-of select="$author1_gender"/>
                </xsl:attribute>
          		<xsl:attribute name="born">
            		<xsl:value-of select="$author1_born"/>
            	</xsl:attribute>
            	<xsl:attribute name="nationality">
            		<xsl:value-of select="$author1_nat"/>
            	</xsl:attribute>
				</xsl:element>
			</xsl:element>
        </xsl:when>
		<xsl:when test="header/author">
            <xsl:apply-templates select="header/author"/>
		</xsl:when>
        <xsl:otherwise>
			 <xsl:element name="author">
			 			 <xsl:element name="unknown">
						 </xsl:element>
			 </xsl:element>
        </xsl:otherwise>
		</xsl:choose>

			<xsl:if test="$note">
					<xsl:element name="note">
					<xsl:value-of select="$note">
					</xsl:element>
			</xsl:if>

  </xsl:element>
<xsl:element name="body"/>
  </xsl:element>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
