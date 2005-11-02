<?xml version="1.0" encoding="UTF-8"?>

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


<!-- Add title/author info/publisher info manually 
    if different from AntiWord output: -->
<xsl:variable name="title" select="''"/>
<xsl:variable name="author" select="''"/>
<xsl:variable name="author-gender" select="'f'"/>
<xsl:variable name="author2" select="''"/>
<xsl:variable name="author-gender2" select="'f'"/>
<xsl:variable name="author3" select="''"/>
<xsl:variable name="author-gender3" select="'f'"/>
<xsl:variable name="author4" select="''"/>
<xsl:variable name="author-gender4" select="'f'"/>
<xsl:variable name="publisher" select="''"/>
<xsl:variable name="translated-from" select="''"/>
<xsl:variable name="year" select="''"/>
<xsl:variable name="ISBN" select="''"/>
<xsl:variable name="ISSN" select="''"/>
<xsl:variable name="genre" select="''"/>

<xsl:variable name="mainlang" select="'sme'"/>

<!-- These id:s are for identifying paragraph/section languages -->
<!-- Example: <xsl:variable name="id" select="'1234' and '5678'"/> -->
<xsl:variable name="smeid" select="''"/>
<xsl:variable name="smjid" select="''"/>
<xsl:variable name="smaid" select="''"/>
<xsl:variable name="nobid" select="''"/>
<xsl:variable name="nnoid" select="''"/>
<xsl:variable name="sweid" select="''"/>
<xsl:variable name="finid" select="''"/>

<!-- What about sections/paragraphs/etc. that are not correctly identified for
     language? -->
<!-- Idea: Xpath that uniquely identifies the node, and adds the language info. -->

<xsl:variable name="smelang" select="'sme'"/>
<xsl:variable name="smjlang" select="'smj'"/>
<xsl:variable name="smalang" select="'sma'"/>
<xsl:variable name="noblang" select="'nob'"/>
<xsl:variable name="nnolang" select="'nno'"/>
<xsl:variable name="swelang" select="'swe'"/>
<xsl:variable name="finlang" select="'fin'"/>


<xsl:template match="node()|@*">
    <xsl:copy>
        <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
</xsl:template>


<!-- Add info about the main language: -->
<xsl:template match="document">
    <xsl:if test="$mainlang">
        <xsl:element name="document">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="$mainlang"/>
            </xsl:attribute>
            <xsl:apply-templates />
            <xsl:if test="string-length($author2) > 0">
            		<author>
            			<person>
            				<xsl:attribute name="name">
            					<xsl:value-of select="$author2"/>
            				</xsl:attribute>
            				<xsl:attribute name="sex">
            					<xsl:value-of select="$author-gender2"/>
            				</xsl:attribute>
            			</person>
            		</author>
            </xsl:if>
            <xsl:if test="string-length($author3) > 0">
            		<author>
            			<person>
            				<xsl:attribute name="name">
            					<xsl:value-of select="$author3"/>
            				</xsl:attribute>
            				<xsl:attribute name="sex">
            					<xsl:value-of select="$author-gender3"/>
            				</xsl:attribute>
            			</person>
            		</author>
            </xsl:if>
            <xsl:if test="string-length($author4) > 0">
            		<author>
            			<person>
            				<xsl:attribute name="name">
            					<xsl:value-of select="$author4"/>
            				</xsl:attribute>
            				<xsl:attribute name="sex">
            					<xsl:value-of select="$author-gender4"/>
            				</xsl:attribute>
            			</person>
            		</author>
            </xsl:if>
        </xsl:element>
    </xsl:if>
</xsl:template>

<xsl:template match="title">
    <!-- Use the variable declared above iff the DocBook does not contain a title,
         or the variable is different from the DocBook version-->
    <xsl:choose>
        <xsl:when test="string-length($title) > 0">
            <xsl:element name="title">
                <xsl:value-of select="$title"/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="title">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="person">
    <!-- Use the variable declared above iff the DocBook does not contain a title,
         or the variable is different from the DocBook version-->
    <xsl:choose>
        <xsl:when test="string-length($author) > 0">
            <xsl:element name="person">
                <xsl:attribute name="name">
                    <xsl:value-of select="$author"/>
                </xsl:attribute>
                <xsl:attribute name="sex">
                    <xsl:value-of select="$author-gender"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="person">
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
                <xsl:attribute name="sex">
                    <xsl:value-of select="$author-gender"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="publisher">
    <!-- Use the variable declared above iff the DocBook does not contain a title,
         or the variable is different from the DocBook version-->
    <xsl:choose>
        <xsl:when test="string-length($publisher) > 0">
            <xsl:element name="publisher">
                <xsl:value-of select="$publisher"/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="publisher">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="genre">
	<xsl:choose>
		<xsl:when test="string-length($genre) > 0">
			<xsl:element name="genre">
				<xsl:attribute name="code">
					<xsl:value-of select="$genre"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="genre">
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="translated-from">
    <!-- Use the variable declared above iff the DocBook does not contain a title,
         or the variable is different from the DocBook version-->
    <xsl:choose>
        <xsl:when test="string-length($translated-from) > 0">
            <xsl:element name="translated-from">
                <xsl:value-of select="$translated-from"/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="translated-from">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="year">
    <!-- Use the variable declared above iff the DocBook does not contain a title,
         or the variable is different from the DocBook version-->
    <xsl:choose>
        <xsl:when test="string-length($year) > 0">
            <xsl:element name="year">
                <xsl:value-of select="$year"/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="year">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="ISBN">
    <!-- Use the variable declared above iff the DocBook does not contain a title,
         or the variable is different from the DocBook version-->
    <xsl:choose>
        <xsl:when test="string-length($ISBN) > 0">
            <xsl:element name="ISBN">
                <xsl:value-of select="$ISBN"/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="ISBN">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="ISSN">
    <!-- Use the variable declared above iff the DocBook does not contain a title,
         or the variable is different from the DocBook version-->
    <xsl:choose>
        <xsl:when test="string-length($ISSN) > 0">
            <xsl:element name="ISSN">
                <xsl:value-of select="$ISSN"/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="ISSN">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Tag the specified elements with the specified language: -->
<!-- Change the language to what is needed. -->
<!-- The numbers in the expression [@id = '1234'] are generated automatically,
     see the output from conversion to gtxml for the correct number for the
     paragraphs to change. Then add that number below, and rerun the  script. -->
<xsl:template match="id('$smeid')">
    <!-- Add the language specified below to the sections specified above: -->
    <xsl:attribute name="xml:lang">
        <xsl:value-of select="$smelang"/>
    </xsl:attribute>
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="id('$smjid')">
    <!-- Add the language specified below to the sections specified above: -->
    <xsl:attribute name="xml:lang">
        <xsl:value-of select="$smjlang"/>
    </xsl:attribute>
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="id('$smaid')">
    <!-- Add the language specified below to the sections specified above: -->
    <xsl:attribute name="xml:lang">
        <xsl:value-of select="$smalang"/>
    </xsl:attribute>
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="id('$nobid')">
    <!-- Add the language specified below to the sections specified above: -->
    <xsl:attribute name="xml:lang">
        <xsl:value-of select="$noblang"/>
    </xsl:attribute>
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="id('$nnoid')">
    <!-- Add the language specified below to the sections specified above: -->
    <xsl:attribute name="xml:lang">
        <xsl:value-of select="$nnolang"/>
    </xsl:attribute>
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="id('$sweid')">
    <!-- Add the language specified below to the sections specified above: -->
    <xsl:attribute name="xml:lang">
        <xsl:value-of select="$swelang"/>
    </xsl:attribute>
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="id('$finid')">
    <!-- Add the language specified below to the sections specified above: -->
    <xsl:attribute name="xml:lang">
        <xsl:value-of select="$finlang"/>
    </xsl:attribute>
    <xsl:apply-templates />
</xsl:template>

</xsl:stylesheet>
