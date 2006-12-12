<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$ -->

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


<xsl:variable name="common_version" select="'$Revision$'"/>
<xsl:variable name="convert2xml_version" select="''"/>
<xsl:variable name="hyph_version" select="''"/>
<xsl:variable name="xhtml2corpus_version" select="''"/>
<xsl:variable name="docbook2corpus2_version" select="''"/>
<xsl:param name="document_id" select="'no_id'"/>


<!-- Fix empty em-type according to the dtd -->
<xsl:template match="em">
	<xsl:element name="em">
	<xsl:choose>
	<xsl:when test="not(@type)">
		<xsl:attribute name="type">
			<xsl:text>italic</xsl:text>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:attribute name="type">
			<xsl:value-of select="@type"/>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:otherwise>
	</xsl:choose>
	</xsl:element>
</xsl:template>

<!--
<xsl:template match="p">
<xsl:if test="string-length(normalize-space(.)) > 0">
 <xsl:apply-templates />
</xsl:if>
</xsl:template>
-->

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

    <xsl:attribute name="id">			
	    <xsl:value-of select="$document_id"/>
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

		<xsl:choose>
        <xsl:when test="$author2_ln">
			 <xsl:element name="author">
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
            </xsl:element>
        </xsl:when>
	    </xsl:choose>
	    <xsl:choose>
        <xsl:when test="$author3_ln">
			 <xsl:element name="author"> 
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
            </xsl:element>
        </xsl:when>
		</xsl:choose>
		<xsl:choose>
        <xsl:when test="$author4_ln">
			 <xsl:element name="author">
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
            </xsl:element>
        </xsl:when>
		</xsl:choose>

		<!-- It is assumed that the translator does not come from
		outside, but is given only in this file -->
		<!-- There is a problem: how to test the existence of a
		translator that is not given here? -->
		<xsl:choose>
        <xsl:when test="$translator_ln">
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
		<xsl:when test="header/translator">
	           <xsl:apply-templates select="translator"/>
		</xsl:when>
        <xsl:when test="$translated_from or header/translated_from">
			 <xsl:element name="translator">
						  <xsl:element name="unknown">
						  </xsl:element>
			 </xsl:element>
        </xsl:when>
		</xsl:choose>

    <xsl:choose>
        <xsl:when test="$translated_from">
            <xsl:element name="translated_from">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="$translated_from"/>
            </xsl:attribute>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
                <xsl:apply-templates select="header/translated_from"/>
        </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
        <xsl:when test="$year">
    <xsl:element name="year">	
                <xsl:value-of select="$year"/>
     </xsl:element>
        </xsl:when>
        <xsl:otherwise>
                <xsl:apply-templates select="header/year"/>			
        </xsl:otherwise>
    </xsl:choose>


				<xsl:choose>
				<xsl:when test="$place">
				<xsl:element name="place">
					 <xsl:value-of select="$place"/>
	            </xsl:element>
				</xsl:when>
				<xsl:otherwise>
            <xsl:apply-templates select="header/place"/>
				</xsl:otherwise>
				</xsl:choose>

	 <xsl:choose>
		<xsl:when test="$publisher">
	<xsl:element name="publChannel">
			<xsl:element name="publication">
				<xsl:element name="publisher">
					 <xsl:value-of select="$publisher"/>
	            </xsl:element>
			    <xsl:choose>
				<xsl:when test="$ISSN">
				<xsl:element name="ISSN">
					 <xsl:value-of select="$ISSN"/>
	            </xsl:element>
				</xsl:when>
				<xsl:otherwise>
            <xsl:apply-templates select="header/ISSN"/>
				</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
				     <xsl:when test="$ISBN">
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
			<xsl:when test="$collection">
				<xsl:element name="collection">
					 <xsl:value-of select="$collection"/>
	            </xsl:element>
			</xsl:when>
			<xsl:otherwise>
		        <xsl:apply-templates select="header/collection"/>
			</xsl:otherwise>
			</xsl:choose>
		    <xsl:choose>
			<xsl:when test="$wordcount">
				<xsl:element name="wordcount">
					 <xsl:value-of select="$wordcount"/>
	            </xsl:element>
			</xsl:when>
			<xsl:otherwise>
		        <xsl:apply-templates select="header/wordcount"/>
			</xsl:otherwise>
			</xsl:choose>

		    <xsl:choose>
			<xsl:when test="$license_type">
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
					<xsl:element name="license">
					<xsl:attribute name="type">	
						<text>standard</text>
					</xsl:attribute>
		            </xsl:element>
	            </xsl:element>
			</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="$sub_name or $sub_email">
				<xsl:element name="submitter">
					<xsl:if test="$sub_email">
						<xsl:attribute name="name">
						<xsl:value-of select="$sub_name"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="$sub_email">
						<xsl:attribute name="email">
						<xsl:value-of select="$sub_email"/>
						</xsl:attribute>
					</xsl:if>
				</xsl:element>
			</xsl:if>

			<xsl:choose>
			<xsl:when test="$monolingual">
			</xsl:when>	
			<xsl:when test="$multilingual">
				<xsl:element name="multilingual">
				<xsl:if test="$mlang_sme">
					<xsl:element name="language">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$smelang"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$mlang_smj">
					<xsl:element name="language">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$smjlang"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$mlang_sma">
					<xsl:element name="language">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$smalang"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$mlang_nno">
					<xsl:element name="language">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$nnolang"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$mlang_nob">
					<xsl:element name="language">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$noblang"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$mlang_fin">
					<xsl:element name="language">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$finlang"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$mlang_swe">
					<xsl:element name="language">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$swelang"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$mlang_eng">
					<xsl:element name="language">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$englang"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$mlang_ger">
					<xsl:element name="language">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$gerlang"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				
				</xsl:element>
			</xsl:when>

			<xsl:otherwise>
				<xsl:element name="multilingual">
				</xsl:element>
			</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="$filename">
				<xsl:element name="origFileName">
					<xsl:value-of select="$filename"/>
				</xsl:element>
			</xsl:if>

			<xsl:if test="$parallel_texts">
				<xsl:if test="$para_sme">
					<xsl:element name="parallel_text">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$smelang"/>
						</xsl:attribute>	  
						<xsl:attribute name="location">
							<xsl:value-of select="$para_sme"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$para_smj">
					<xsl:element name="parallel_text">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$smjlang"/>
						</xsl:attribute>	  
						<xsl:attribute name="location">
							<xsl:value-of select="$para_smj"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$para_sma">
					<xsl:element name="parallel_text">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$smalang"/>
						</xsl:attribute>	  
						<xsl:attribute name="location">
							<xsl:value-of select="$para_sma"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$para_nob">
					<xsl:element name="parallel_text">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$noblang"/>
						</xsl:attribute>	  
						<xsl:attribute name="location">
							<xsl:value-of select="$para_nob"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$para_nno">
					<xsl:element name="parallel_text">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$nnolang"/>
						</xsl:attribute>	  
						<xsl:attribute name="location">
							<xsl:value-of select="$para_nno"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$para_swe">
					<xsl:element name="parallel_text">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$swelang"/>
						</xsl:attribute>	  
						<xsl:attribute name="location">
							<xsl:value-of select="$para_swe"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$para_fin">
					<xsl:element name="parallel_text">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$finlang"/>
						</xsl:attribute>	  
						<xsl:attribute name="location">
							<xsl:value-of select="$para_fin"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$para_ger">
					<xsl:element name="parallel_text">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$gerlang"/>
						</xsl:attribute>	  
						<xsl:attribute name="location">
							<xsl:value-of select="$para_ger"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
				<xsl:if test="$para_eng">
					<xsl:element name="parallel_text">
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="$englang"/>
						</xsl:attribute>	  
						<xsl:attribute name="location">
							<xsl:value-of select="$para_eng"/>
						</xsl:attribute>	  
					</xsl:element>
				</xsl:if>
			</xsl:if>

			<xsl:choose>
			<xsl:when test="$metadata">
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

			<xsl:element name="version">
			<xsl:if test="$template_version">
					<xsl:text>XSLtemplate </xsl:text>
					<xsl:value-of select="$template_version"/>	
					<xsl:text>; </xsl:text>
			</xsl:if>
			<xsl:if test="$current_version">
					<xsl:text>file-specific xsl  </xsl:text>
					<xsl:value-of select="$current_version"/>
					<xsl:text>; </xsl:text>
			</xsl:if>
			<xsl:if test="$common_version">
					<xsl:text>common.xsl  </xsl:text>
					<xsl:value-of select="$common_version"/>			
					<xsl:text>; </xsl:text>
			</xsl:if>
			<xsl:if test="$convert2xml_version">
					<xsl:text>convert2xml  </xsl:text>
					<xsl:value-of select="$convert2xml_version"/>
					<xsl:text>; </xsl:text>
			</xsl:if>
			<xsl:if test="$hyph_version">
					<xsl:text>add_hyph_tags  </xsl:text>
					<xsl:value-of select="$hyph_version"/>
					<xsl:text>; </xsl:text>
			</xsl:if>
            <xsl:if test="$docbook2corpus2_version">
					<xsl:text>docbook2corpus2  </xsl:text>
                    <xsl:value-of select="$docbook2corpus2_version"/>
					<xsl:text>; </xsl:text>
            </xsl:if>
            <xsl:if test="$xhtml2corpus_version">
					<xsl:text>xhtml2corpus  </xsl:text>
                    <xsl:value-of select="$xhtml2corpus_version"/>
					<xsl:text>; </xsl:text>
            </xsl:if>
			</xsl:element>

			<xsl:if test="$note">
					<xsl:element name="note">
					<xsl:value-of select="$note"/>
					</xsl:element>
			</xsl:if>


  </xsl:element>
<xsl:apply-templates select="body"/>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
