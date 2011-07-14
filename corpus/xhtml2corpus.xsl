<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:fo="http://www.w3.org/1999/XSL/Format" 
                xmlns:html="http://www.w3.org/1999/xhtml" 
                xmlns:saxon="http://icl.com/saxon"
                exclude-result-prefixes="xsl fo html saxon">
<!--$Revision: 38657 $ -->

<!-- 
Usage: ~/Desktop/bin/tidy - -quote-nbsp no - -add-xml-decl yes 
						- -enclose-block-text yes -asxml -utf8 -language sme 
						file.html | 
xsltproc xhtml2corpus.xsl - > file.xml
-->

<xsl:strip-space elements="*"/>

<xsl:output method="xml"
		   version="1.0"
		   encoding="UTF-8"
		   indent="yes"
		   doctype-public="-//UIT//DTD Corpus V1.0//EN"
		   doctype-system="http://www.giellatekno.uit.no/dtd/corpus.dtd"/>

<!-- Main block-level conversions -->
<xsl:template match="html:html">
	<document>
		<xsl:apply-templates select="html:head"/>
		<xsl:apply-templates select="html:body"/>
	</document>
</xsl:template>

<xsl:template match="html:head">
	<header>
		<title>
			<xsl:choose>
				<xsl:when test="html:title">
						<xsl:value-of select="html:title"/>
				</xsl:when>
				<xsl:otherwise>	
					<xsl:value-of select="../html:body//html:h1[1]
											|../html:body//html:h2[1]
											|../html:body//html:h3[1]"/>
				</xsl:otherwise>
			</xsl:choose>
		</title>
	</header>
</xsl:template>


<!--     For a title, it selects the first h1 element -->
<xsl:template match="html:body">
	<body>
		<p type="title">
			<xsl:value-of select=".//html:h1[1]
									|.//html:h2[1]
									|.//html:h3[1]"/>
		</p>
		<xsl:apply-templates />
	</body>
</xsl:template>


<!-- This template matches on all HTML header items and makes them into 
     bridgeheads. It attempts to assign an ID to each bridgehead by looking 
     for a named anchor as a child of the header or as the immediate preceding
     or following sibling -->
<xsl:template match="html:h1
              |html:h2
              |html:h3
              |html:h4
              |html:h5
              |html:h6">
	<section>
		<p type="title">
			<xsl:apply-templates/>
		</p>
	</section>
</xsl:template>


<xsl:template match="html:p|html:label">
	<xsl:if test="string-length(normalize-space(.)) > 1">
		<xsl:choose>
			<xsl:when test="ancestor::html:i|ancestor::html:u|ancestor::html:b|ancestor::html:p">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<p> 
					<xsl:apply-templates /> 
				</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template match="html:pre">
	<pre>
		<xsl:apply-templates/>
	</pre>
</xsl:template>

<!-- LIST ELEMENTS -->

<xsl:template match="html:ul">
	<xsl:if test="string-length(normalize-space(html:li/text())) > 1">
		<list>
			<xsl:apply-templates select="html:li[not(html:ol) and not(html:ul)]"/>
		</list>
	</xsl:if>
	<xsl:apply-templates select="html:li//html:ol"/>
	<xsl:apply-templates select="html:li//html:ul"/>
</xsl:template>

<xsl:template match="html:ol">
	<list>
		<xsl:apply-templates/>
		<xsl:apply-templates select="html:li//html:ol"/>
		<xsl:apply-templates select="html:li//html:ul"/>
	</list>
</xsl:template>

<!-- <xsl:template match="html:ol/html:ol"> -->
<!--     <list> -->
<!--         <xsl:apply-templates/> -->
<!--     </list> -->
<!-- </xsl:template> -->

<!-- This template makes a DocBook variablelist out of an HTML definition list -->
<xsl:template match="html:dl">
	<xsl:for-each select="html:dt">
		<p type="listitem">
			<xsl:apply-templates/>
		</p>
		<xsl:apply-templates select="following-sibling::html:dd"/>
	</xsl:for-each>
</xsl:template>

<xsl:template match="html:dd">
	<xsl:choose>
		<xsl:when test="html:p">
			<xsl:apply-templates/>
		</xsl:when>
		<xsl:otherwise>
			<p>
				<xsl:apply-templates/>
			</p>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="html:li">
	<xsl:if test="string-length(normalize-space(.)) > 1">
		<p type="listitem">
			<xsl:value-of select="text()"/>
		</p>
	</xsl:if>
</xsl:template>

<xsl:template match="html:center">
	<xsl:if test="string-length(normalize-space(.)) > 1">
		<p >
			<xsl:value-of select="text()"/>
		</p>
	</xsl:if>
</xsl:template>

<xsl:template match="html:dato">
	<xsl:value-of select="text()"/>
</xsl:template>


<!-- inline formatting -->
<xsl:template match="html:b">
	<xsl:choose>
		<xsl:when test="ancestor::html:b|ancestor::html:i|ancestor::html:em|html:u">
			<xsl:apply-templates/>
		</xsl:when>
		<xsl:when test="not(ancestor::html:p|ancestor::html:a)">
				<p>
				<em type="bold">
					<xsl:apply-templates/>
				</em>
			</p>
		</xsl:when>
		<xsl:otherwise>
			<em type="bold">
				<xsl:apply-templates/>
			</em>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="html:i|html:em|html:u|html:strong">
	<xsl:choose>
		<xsl:when test="ancestor::html:strong|ancestor::html:b|ancestor::html:i|ancestor::html:em|html:u">
			<xsl:apply-templates/>
		</xsl:when>
		<xsl:when test="not(ancestor::html:p|ancestor::html:a|ancestor::html:h1|ancestor::html:h2|ancestor::html:h3|ancestor::html:h4)">
			<p>
				<em type="bold">
					<xsl:apply-templates/>
				</em>
			</p>
		</xsl:when>
		<xsl:otherwise>
			<em type="italic">
				<xsl:apply-templates/>
			</em>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Table formatting -->
<xsl:template match="html:tbody">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:table">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:td|html:caption|html:th|html:thead">
	<xsl:choose>
		<xsl:when test="text()">
		<xsl:choose>
		<xsl:when test="ancestor::html:p|ancestor::html:b|ancestor::html:i|ancestor::html:u|ancestor::html:a">
				<xsl:apply-templates select="text()"/>
		</xsl:when>
		<xsl:otherwise>
				<p><xsl:apply-templates select="text()"/></p>
		</xsl:otherwise>
		</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
				<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="html:tr">
	<xsl:apply-templates />
</xsl:template>

<!-- references -->
<xsl:template match="html:a">
	<xsl:choose>
		<xsl:when test="ancestor::html:p|ancestor::html:dt|ancestor::html:dd|ancestor::html:b|ancestor::html:i|ancestor::html:u|ancestor::html:h1|ancestor::html:h2|ancestor::html:h3|ancestor::html:h4">
			<xsl:apply-templates/>
		</xsl:when>
		<xsl:otherwise>
			<p><xsl:apply-templates/></p>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="html:form|html:input">
	<xsl:apply-templates/>
</xsl:template>

<!-- quotations -->
<xsl:template match="html:blockquote|html:q">
	<xsl:apply-templates />
</xsl:template>

<!-- superscripts and subscripts are dropped to text -->
<xsl:template match="html:big|html:small|html:sub|html:sup">
	<xsl:choose>
		<xsl:when test="text()">
			<xsl:choose>
				<xsl:when test="ancestor::html:p|ancestor::html:b|ancestor::html:i|ancestor::html:u|ancestor::html:a">
					<xsl:apply-templates select="text()"/>
				</xsl:when>
				<xsl:otherwise>
					<p><xsl:apply-templates select="text()"/></p>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="html:span//text()">
	<xsl:choose>
		<xsl:when test="ancestor::html:b|ancestor::html:em|ancestor::html:strong|ancestor::html:p|parent::html:i">
			<xsl:value-of select="."/>
		</xsl:when>
		<xsl:when test="ancestor::html:td">
			<p><xsl:value-of select="."/></p>
		</xsl:when>
		<xsl:otherwise>
			<span><xsl:value-of select="."/></span>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>  
   
<xsl:template match="html:span">  
  <xsl:apply-templates/>  
</xsl:template> 

<!-- other formatting -->
<xsl:template match="html:font|html:div|html:idiv|html:note">
	<xsl:choose>
		<xsl:when test="text()">
			<xsl:choose>
				<xsl:when test="ancestor::html:p|ancestor::html:b|ancestor::html:i|ancestor::html:u|ancestor::html:a|ancestor::html:dt|ancestor::html:h1|ancestor::html:h2|ancestor::html:h3|ancestor::html:h4|ancestor::html:strong|ancestor::html:span">
					<xsl:apply-templates select="text()"/>
				</xsl:when>
				<xsl:otherwise>
					<p><xsl:apply-templates select="text()"/></p>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="*">
	<xsl:message>No template for <xsl:value-of select="name()"/>
		<xsl:text>: </xsl:text><xsl:value-of select="text()"/>
	</xsl:message>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="@*">
	<xsl:message>No template for <xsl:value-of select="name()"/>
		<xsl:text>: </xsl:text><xsl:value-of select="text()"/>
	</xsl:message>
	<xsl:apply-templates/>
</xsl:template>

<!-- Ignored elements -->
<xsl:template match="html:hr"/>
<xsl:template match="html:br"/>
<xsl:template match="html:script"/>
<xsl:template match="html:img"/>
<xsl:template match="html:map"/>
<xsl:template match="html:iframe"/>
<xsl:template match="html:noscript"/>
<xsl:template match="html:select"/>
</xsl:stylesheet>
