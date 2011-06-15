<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:html="http://www.w3.org/1999/xhtml" 
                exclude-result-prefixes="xsl html">
<!--$Revision$ -->

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
		   doctype-system="http://giellatekno.uit.no/dtd/corpus.dtd"/>

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


<xsl:template match="html:p |
					 html:label">
	<xsl:if test="string-length(normalize-space(.)) > 1">
		<xsl:choose>
			<xsl:when test="ancestor::html:i |
							ancestor::html:u |
							ancestor::html:b |
							ancestor::html:p |
							ancestor::html:li">
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
		<xsl:apply-templates/>
		<xsl:if test="html:li//html:ul or html:li//html:ol">
			<xsl:apply-templates select="html:li//html:ul | html:li//html:ol"/>
		</xsl:if>
	</list>
</xsl:template>

<!-- Don't convert the following lists found on ministery pages (the @id is unique):   -->
<!-- (add more matches/@ids as needed, but make sure you are specific enough)          -->
<xsl:template match="html:ul[contains(@id,'AreaTopPrintMeny')]"/>  <!-- font size etc. -->
<xsl:template match="html:ul[contains(@id,'AreaTopLanguageNav')]"/> <!-- language menu -->
<xsl:template match="html:div[contains(@id,'AreaLeftNav')]"/>     <!-- navigation menu -->
<xsl:template match="html:div[contains(@id,'PageFooter')]"/>      <!--     page footer -->

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
	<xsl:choose>
		<!-- Block lists as daughters of listitems: -->
		<xsl:when test="./html:ul or ./html:ol"/>
		<xsl:when test="string-length(normalize-space(.)) > 1">
			<p type="listitem">
				<xsl:apply-templates/>
			</p>
		</xsl:when>
		<!--xsl:otherwise>
			<xsl:apply-templates/>
		</xsl:otherwise-->
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
		<xsl:when test="ancestor::html:b  |
						ancestor::html:i  |
						ancestor::html:em |
						html:u">
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

<xsl:template match="html:i  |
					 html:u  |
					 html:em |
					 html:strong">
	<xsl:choose>
		<xsl:when test="../html:strong |
						../html:b      |
						../html:i      |
						../html:em     |
						../html:span   |
						../html:u">
			<xsl:apply-templates/>
		</xsl:when>
		<xsl:when test="not(../html:p  |
							../html:a  |
							../html:h1 |
							../html:h2 |
							../html:h3 |
							../html:h4 )">
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

<xsl:template match="html:td      |
					 html:th      |
					 html:caption |
					 html:thead">
	<xsl:choose>
		<xsl:when test="text()">
		  <xsl:choose>
		    <xsl:when test="ancestor::html:p |
		    				ancestor::html:b |
		    				ancestor::html:i |
		    				ancestor::html:u |
		    				ancestor::html:a">
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

<!-- typically inline elements -->
<xsl:template match="html:font |
					 html:span |
					 html:a">
	<xsl:choose>
		<xsl:when test="parent::html:p  |
						parent::html:dt |
						parent::html:dd |
						parent::html:b  |
						parent::html:i  |
						parent::html:u  |
						parent::html:h1 |
						parent::html:h2 |
						parent::html:h3 |
						parent::html:h4 |
						parent::html:li |
						parent::html:div">
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

<!-- superscripts and subscripts are dropped to text: (XXX this looks dangerous) -->
<xsl:template match="html:big   |
					 html:small |
					 html:sub   |
					 html:sup">
	<xsl:choose>
		<xsl:when test="text()">
			<xsl:choose>
				<xsl:when test="ancestor::html:p |
								ancestor::html:b |
								ancestor::html:i |
								ancestor::html:u |
								ancestor::html:a">
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

<!-- other formatting -->
<xsl:template match="html:idiv |
					 html:div  |
					 html:note">
	<xsl:choose>
		<!-- Explicitly check for mixed content: -->
		<xsl:when test="text() and html:* ">
			<xsl:choose>
				<xsl:when test="parent::html:p  |
								parent::html:b  |
								parent::html:i  |
								parent::html:u  |
								parent::html:a  |
								parent::html:dt |
								parent::html:h1 |
								parent::html:h2 |
								parent::html:h3 |
								parent::html:h4 |
								parent::html:strong">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<p><xsl:apply-templates/></p>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- Then this must be text-only content: -->
		<xsl:when test="text()">
			<xsl:choose>
				<xsl:when test="parent::html:p  |
								parent::html:b  |
								parent::html:i  |
								parent::html:u  |
								parent::html:a  |
								parent::html:dt |
								parent::html:h1 |
								parent::html:h2 |
								parent::html:h3 |
								parent::html:h4 |
								parent::html:strong">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<p><xsl:apply-templates/></p>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- And this element-only content: -->
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
<!--xsl:template match="html:h1[1]|html:h2[1]|html:h3[1]" priority="1"/-->
<xsl:template match="html:br"/>
<xsl:template match="html:script"/>
<xsl:template match="html:img"/>
<xsl:template match="html:map"/>
<xsl:template match="html:iframe"/>
<xsl:template match="html:noscript"/>
<xsl:template match="html:select"/>
</xsl:stylesheet>
