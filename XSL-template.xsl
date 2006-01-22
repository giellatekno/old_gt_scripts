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

<!-- Add the metainformation manually -->
<xsl:variable name="title" select="''"/>
<xsl:variable name="author1_fn" select="''"/>
<xsl:variable name="author1_ln" select="''"/>
<xsl:variable name="author1_gender" select="'unknown'"/>
<xsl:variable name="author1_born" select="''"/>
<xsl:variable name="author1_nat" select="''"/>
<xsl:variable name="author2_fn" select="''"/>
<xsl:variable name="author2_ln" select="''"/>
<xsl:variable name="author2_gender" select="''"/>
<xsl:variable name="author2_born" select="''"/>
<xsl:variable name="author2_nat" select="''"/>
<xsl:variable name="author3_fn" select="''"/>
<xsl:variable name="author3_ln" select="''"/>
<xsl:variable name="author3_gender" select="''"/>
<xsl:variable name="author3_born" select="''"/>
<xsl:variable name="author3_nat" select="''"/>
<xsl:variable name="author4_fn" select="''"/>
<xsl:variable name="author4_ln" select="''"/>
<xsl:variable name="author4_gender" select="''"/>
<xsl:variable name="author4_born" select="''"/>
<xsl:variable name="author4_nat" select="''"/>
<xsl:variable name="translated_from" select="''"/>
<xsl:variable name="publisher" select="''"/>
<xsl:variable name="publChannel" select="''"/>
<xsl:variable name="year" select="''"/>
<xsl:variable name="ISBN" select="''"/>
<xsl:variable name="ISSN" select="''"/>
<xsl:variable name="place" select="''"/>
<xsl:variable name="genre" select="''"/>
<xsl:variable name="collection" select="''"/>
<xsl:variable name="translator_fn" select="''"/>
<xsl:variable name="translator_ln" select="''"/>
<xsl:variable name="translator_gender" select="'unknown'"/>
<xsl:variable name="translator_born" select="''"/>
<xsl:variable name="translator_nat" select="''"/>
<xsl:variable name="license_type" select="''"/>
<xsl:variable name="sub_name" select="''"/>
<xsl:variable name="sub_email" select="''"/>
<xsl:variable name="wordcount" select="''"/>
<xsl:variable name="metadata" select="'uncomplete'"/>

<xsl:variable name="mainlang" select="''"/>

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
<xsl:template  match="document">
    <xsl:element name="document">
    <xsl:attribute name="xml:lang">
	<xsl:choose>
    <xsl:when test="string-length($mainlang) > 0">
            <xsl:value-of select="$mainlang"/>
	</xsl:when>
	<xsl:otherwise>
            <xsl:value-of select="@xml:lang"/>
	</xsl:otherwise>
	</xsl:choose>
    </xsl:attribute>

	<xsl:element name="header">
    <xsl:element name="title">
    <xsl:choose>
        <xsl:when test="string-length($title) > 0">
                <xsl:value-of select="$title"/>
        </xsl:when>
		<xsl:when test="header/title">
              <xsl:apply-templates select="header/title"/>
		</xsl:when>
	    </xsl:choose>
     </xsl:element>

	<xsl:choose>
		<xsl:when test="string-length($genre) > 0">
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
        <xsl:when test="string-length($author1_ln) > 0">
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
		<xsl:when test="header/author/person">
            <xsl:apply-templates select="header/author/person"/>
		</xsl:when>
        <xsl:otherwise>
			 <xsl:element name="author">
			 			 <xsl:element name="unknown">
						 </xsl:element>
			 </xsl:element>
        </xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
        <xsl:when test="string-length($author2_ln) > 0">
            <xsl:element name="person">
                <xsl:attribute name="firstname">
                    <xsl:value-of select="$author2_fn"/>
                </xsl:attribute>
                <xsl:attribute name="lastname">
                    <xsl:value-of select="$author2_ln"/>
                </xsl:attribute>
                <xsl:attribute name="sex">
                    <xsl:value-of select="$author2_gender"/>
                </xsl:attribute>
          		<xsl:attribute name="born">
            		<xsl:value-of select="$author2_born"/>
            	</xsl:attribute>
            	<xsl:attribute name="nationality">
            		<xsl:value-of select="$author2_nat"/>
            	</xsl:attribute>
            </xsl:element>
        </xsl:when>
	    </xsl:choose>
	    <xsl:choose>
        <xsl:when test="string-length($author3_ln) > 0">
            <xsl:element name="person">
                <xsl:attribute name="firstname">
                    <xsl:value-of select="$author3_fn"/>
                </xsl:attribute>
                <xsl:attribute name="lastname">
                    <xsl:value-of select="$author3_ln"/>
                </xsl:attribute>
                <xsl:attribute name="sex">
                    <xsl:value-of select="$author3_gender"/>
                </xsl:attribute>
          		<xsl:attribute name="born">
            		<xsl:value-of select="$author3_born"/>
            	</xsl:attribute>
            	<xsl:attribute name="nationality">
            		<xsl:value-of select="$author3_nat"/>
            	</xsl:attribute>
            </xsl:element>
        </xsl:when>
		</xsl:choose>
		<xsl:choose>
        <xsl:when test="string-length($author4_ln) > 0">
            <xsl:element name="person">
                <xsl:attribute name="firstname">
                    <xsl:value-of select="$author4_fn"/>
                </xsl:attribute>
                <xsl:attribute name="lastname">
                    <xsl:value-of select="$author4_ln"/>
                </xsl:attribute>
                <xsl:attribute name="sex">
                    <xsl:value-of select="$author4_gender"/>
                </xsl:attribute>
          		<xsl:attribute name="born">
            		<xsl:value-of select="$author4_born"/>
            	</xsl:attribute>
            	<xsl:attribute name="nationality">
            		<xsl:value-of select="$author4_nat"/>
            	</xsl:attribute>
            </xsl:element>
        </xsl:when>
		</xsl:choose>

		<!-- It is assumed that the translator does not come from
		outside, but is given only in this file -->
		<!-- There is a problem: how to test the existence of a
		translator that is not given here? -->
		<xsl:choose>
        <xsl:when test="string-length($translator_ln) > 0">
			 <xsl:element name="translator">
				<xsl:element name="person">
                <xsl:attribute name="firstname">
                    <xsl:value-of select="$translator_fn"/>
                </xsl:attribute>
                <xsl:attribute name="lastname">
                    <xsl:value-of select="$translator_ln"/>
                </xsl:attribute>
                <xsl:attribute name="sex">
                    <xsl:value-of select="$translator_gender"/>
                </xsl:attribute>
          		<xsl:attribute name="born">
            		<xsl:value-of select="$translator_born"/>
            	</xsl:attribute>
            	<xsl:attribute name="nationality">
            		<xsl:value-of select="$translator_nat"/>
            	</xsl:attribute>
				</xsl:element>
			</xsl:element>
        </xsl:when>
		<xsl:when test="header/translator/person">
            <xsl:apply-templates select="translator/person"/>
		</xsl:when>
        <xsl:when test="$translated_from or header/translated_from">
			 <xsl:element name="translator">
						  <xsl:element name="unknown">
						  </xsl:element>
			 </xsl:element>
        </xsl:when>
		</xsl:choose>

    <xsl:choose>
        <xsl:when test="string-length($year) > 0">
    <xsl:element name="year">	
                <xsl:value-of select="$year"/>
     </xsl:element>
        </xsl:when>
        <xsl:otherwise>
                <xsl:apply-templates select="header/year"/>			
        </xsl:otherwise>
    </xsl:choose>


	 <xsl:choose>
		<xsl:when test="string-length($publisher) > 0">
	<xsl:element name="publChannel">
			<xsl:element name="publication">
				<xsl:element name="publisher">
					 <xsl:value-of select="$publisher"/>
	            </xsl:element>
			    <xsl:choose>
				<xsl:when test="string-length($ISSN) > 0">
				<xsl:element name="ISSN">
					 <xsl:value-of select="$ISSN"/>
	            </xsl:element>
				</xsl:when>
				<xsl:otherwise>
            <xsl:apply-templates select="header/ISSN"/>
				</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
				     <xsl:when test="string-length($ISBN) > 0">
				<xsl:element name="ISBN">
					 <xsl:value-of select="$ISBN"/>
	            </xsl:element>
				</xsl:when>
				<xsl:otherwise>
            <xsl:apply-templates select="header/ISBN"/>
				</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
		</xsl:when>
		<xsl:when test="contains($publChannel, 'unpublished')">
		<xsl:element name="publChannel">
			<xsl:element name="unpublished">
			</xsl:element>
		</xsl:element>
		</xsl:when>
        <xsl:otherwise>
		    <xsl:apply-templates select="header/publChannel"/>
        </xsl:otherwise>
	</xsl:choose>

    <xsl:choose>
        <xsl:when test="string-length($translated_from) > 0">
            <xsl:element name="translated_from">
                <xsl:value-of select="$translated_from"/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
                <xsl:apply-templates select="header/translated_from"/>
        </xsl:otherwise>
    </xsl:choose>

				<xsl:choose>
				<xsl:when test="string-length($place) > 0">
				<xsl:element name="place">
					 <xsl:value-of select="$place"/>
	            </xsl:element>
				</xsl:when>
				<xsl:otherwise>
            <xsl:apply-templates select="header/place"/>
				</xsl:otherwise>
				</xsl:choose>

		    <xsl:choose>
			<xsl:when test="string-length($collection) > 0">
				<xsl:element name="collection">
					 <xsl:value-of select="$collection"/>
	            </xsl:element>
			</xsl:when>
			<xsl:otherwise>
		        <xsl:apply-templates select="header/collection"/>
			</xsl:otherwise>
			</xsl:choose>
		    <xsl:choose>
			<xsl:when test="string-length($wordcount) > 0">
				<xsl:element name="wordcount">
					 <xsl:value-of select="$wordcount"/>
	            </xsl:element>
			</xsl:when>
			<xsl:otherwise>
		        <xsl:apply-templates select="header/wordcount"/>
			</xsl:otherwise>
			</xsl:choose>

		    <xsl:choose>
			<xsl:when test="string-length($license_type) > 0">
				<xsl:element name="availability">
			<xsl:choose>
			<xsl:when test="contains($license_type, 'free')">
					<xsl:element name="free">
		            </xsl:element>
			</xsl:when>
			<xsl:otherwise>
					<xsl:element name="license">
					<xsl:attribute name="type">		
						<xsl:value-of select="$license_type"/>
					 </xsl:attribute>
					</xsl:element>
			</xsl:otherwise>
			</xsl:choose>
	            </xsl:element>
			</xsl:when>
			<xsl:when test="header/availability">
		        <xsl:apply-templates select="header/availablity"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="availability">
					<xsl:element name="free">
		            </xsl:element>
	            </xsl:element>
			</xsl:otherwise>
			</xsl:choose>

		    <xsl:choose>
			<xsl:when test="string-length($sub_name) > 0">
				<xsl:element name="sub_name">
					 <xsl:value-of select="$sub_name"/>
	            </xsl:element>
			</xsl:when>
			<xsl:otherwise>
		        <xsl:apply-templates select="header/sub_name"/>
			</xsl:otherwise>
			</xsl:choose>

		    <xsl:choose>
			<xsl:when test="string-length($sub_email) > 0">
				<xsl:element name="sub_email">
					 <xsl:value-of select="$sub_email"/>
	            </xsl:element>
			</xsl:when>
			<xsl:otherwise>
		        <xsl:apply-templates select="sub_email"/>
			</xsl:otherwise>
			</xsl:choose>

		    <xsl:choose>
			<xsl:when test="string-length($metadata) > 0">
				<xsl:element name="metadata">
				<xsl:choose>
					<xsl:when test="contains($metadata, 'uncomplete')">
						<xsl:element name="uncomplete">
			            </xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="complete">
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
	            </xsl:element>
			</xsl:when>
			<xsl:otherwise>
		        <xsl:apply-templates select="header/metadata"/>
			</xsl:otherwise>
			</xsl:choose>
  </xsl:element>
<xsl:apply-templates select="body"/>
  </xsl:element>
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
