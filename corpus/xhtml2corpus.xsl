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
			</xsl:choose>
		</title>
	</header>
</xsl:template>

<xsl:template match="html:body">
	<body>
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
	<xsl:if test="string-length(normalize-space(.)) > 1">
		<xsl:choose>
			<xsl:when test="ancestor::html:li">
				<span><xsl:apply-templates/></span>
			</xsl:when>
			<xsl:otherwise>
				<section>
					<p type="title">
						<xsl:apply-templates/>
					</p>
				</section>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>


<xsl:template match="html:p|html:label">
	<xsl:if test="string-length(normalize-space(.)) > 1">
		<xsl:choose>
			<xsl:when test="ancestor::html:i|ancestor::html:u|ancestor::html:b|ancestor::html:p|ancestor::html:li">
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

<!-- Beware: lists within lists are ok, lists within listitems are NOT ok: -->
<xsl:template match="html:ul | html:ol">
	<list>
		<xsl:apply-templates select="node()"/>
	</list>
</xsl:template>

<xsl:template match="html:li">
	<p type="listitem">
		<xsl:value-of select="text()"/>
	</p>
	<xsl:apply-templates select="*"/>
</xsl:template>


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
		<xsl:when test="ancestor::html:b|ancestor::html:i|ancestor::html:em|html:u|ancestor::html:h2">
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
		<xsl:when test="ancestor::html:strong|ancestor::html:b|ancestor::html:i|ancestor::html:em|ancestor::html:u">
			<xsl:apply-templates/>
		</xsl:when>
		<xsl:when test="ancestor::html:li">
			<em><xsl:apply-templates/></em>
		</xsl:when>
		<xsl:when test="not(ancestor::html:p|ancestor::html:a|ancestor::html:h1|ancestor::html:h2|ancestor::html:h3|ancestor::html:h4|ancestor::html:li)">
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
	<xsl:if test="string-length(normalize-space(.)) > 1">
		<xsl:choose>
			<xsl:when test="ancestor::html:p|ancestor::html:dt|ancestor::html:dd|ancestor::html:b|ancestor::html:i|ancestor::html:u|ancestor::html:h1|ancestor::html:h2|ancestor::html:h3|ancestor::html:h4|ancestor::html:li">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<p><xsl:apply-templates/></p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
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
		<xsl:when test="ancestor::html:b|ancestor::html:em|ancestor::html:strong|ancestor::html:p|parent::html:i|ancestor::html:h3">
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
	<xsl:choose>
		<xsl:when test="preceding-sibling::html:p">
			<p><xsl:apply-templates/></p>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template> 

<!-- other formatting -->
<xsl:template match="html:font|html:div|html:idiv|html:note">
	<xsl:choose>
		<xsl:when test="text()">
			<xsl:choose>
				<xsl:when test="ancestor::html:p|ancestor::html:b|ancestor::html:i|ancestor::html:u|ancestor::html:a|ancestor::html:dt|ancestor::html:h1|ancestor::html:h2|ancestor::html:h3|ancestor::html:h4|ancestor::html:strong|ancestor::html:span|ancestor::html:li">
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
	<xsl:message>No template for attribute <xsl:value-of select="name()"/>
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
<!-- Don't convert the following lists found on ministery pages (the @id is unique):   -->
<!-- (add more matches/@ids as needed, but make sure you are specific enough)          -->
<xsl:template match="html:ul[contains(@id,'AreaTopPrintMeny')]"/>  <!-- font size etc. -->
<xsl:template match="html:ul[contains(@id,'AreaTopLanguageNav')]"/> <!-- language menu -->
<xsl:template match="html:ul[contains(@class,'QuickNav')]"/>
<xsl:template match="html:div[contains(@class,'tabbedmenu')]"/>
<xsl:template match="html:div[contains(@id,'searchBox')]"/>
<xsl:template match="html:div[contains(@class,'tabbedmenu')]"/>
<xsl:template match="html:div[contains(@class,'documentPaging')]"/>
<xsl:template match="html:div[contains(@id,'ctl00_FullRegion_CenterAndRightRegion_Sorting_sortByDiv')]"/>
<xsl:template match="html:div[contains(@id,'ctl00_FullRegion_CenterAndRightRegion_HitsControl_searchHitSummary')]"/>
<xsl:template match="html:div[contains(@id,'AreaTopSiteNav')]"/>
<xsl:template match="html:div[contains(@id,'AreaTopRight')]"/>
<xsl:template match="html:div[contains(@id,'AreaLeft')]"/>
<xsl:template match="html:div[contains(@id,'AreaRight')]"/>
<xsl:template match="html:div[contains(@id,'ShareArticle')]"/>
<xsl:template match="html:div[contains(@id,'tipafriend')]"/>
<xsl:template match="html:p[contains(@class,'breadcrumbs')]"/>
<xsl:template match="html:div[contains(@id,'AreaLeftNav')]"/>     <!-- navigation menu -->
<xsl:template match="html:div[contains(@id,'PageFooter')]"/>      <!--     page footer -->
<xsl:template match="html:div[contains(@id,'ctl00_MidtSone_ucArtikkel_ctl00_divNavigasjon')]"/> <!-- page footer in sami parliament pages -->
<xsl:template match="html:div[contains(@id,'NAVheaderContainer')]"/>
<xsl:template match="html:div[contains(@id,'NAVbreadcrumbContainer')]"/>
<xsl:template match="html:div[contains(@id,'NAVsubmenuContainer')]"/>
<xsl:template match="html:span[contains(@id,'skiplinks')]"/>
<xsl:template match="html:div[contains(@class,'post-footer')]"/>
<xsl:template match="html:div[contains(@id,'sidebar-wrapper')]"/>
<xsl:template match="html:div[contains(@id,'footer-wrapper')]"/>
</xsl:stylesheet>
