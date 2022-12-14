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
<!-- variable filename contains the original name of the file (from submitter)-->
<xsl:variable name="filename" select="''"/>
<xsl:variable name="text_encoding" select="''"/>
<xsl:variable name="title" select="''"/>
<xsl:variable name="author1_fn" select="''"/>
<xsl:variable name="author1_ln" select="''"/>
<xsl:variable name="author1_gender" select="'unknown'"/>
<xsl:variable name="author1_nat" select="''"/>
<xsl:variable name="author1_born" select="''"/>
<xsl:variable name="author2_fn" select="''"/>
<xsl:variable name="author2_ln" select="''"/>
<xsl:variable name="author2_gender" select="''"/>
<xsl:variable name="author2_nat" select="''"/>
<xsl:variable name="author2_born" select="''"/>
<xsl:variable name="author3_fn" select="''"/>
<xsl:variable name="author3_ln" select="''"/>
<xsl:variable name="author3_gender" select="''"/>
<xsl:variable name="author3_nat" select="''"/>
<xsl:variable name="author3_born" select="''"/>
<xsl:variable name="author4_fn" select="''"/>
<xsl:variable name="author4_ln" select="''"/>
<xsl:variable name="author4_gender" select="''"/>
<xsl:variable name="author4_nat" select="''"/>
<xsl:variable name="author4_born" select="''"/>
<xsl:variable name="publisher" select="''"/>
<xsl:variable name="publChannel" select="''"/>
<xsl:variable name="year" select="''"/>
<xsl:variable name="ISBN" select="''"/>
<xsl:variable name="ISSN" select="''"/>
<xsl:variable name="place" select="''"/>
<xsl:variable name="genre" select="''"/>
<xsl:variable name="collection" select="''"/>
<xsl:variable name="translated_from" select="''"/>
<xsl:variable name="translator_fn" select="''"/>
<xsl:variable name="translator_ln" select="''"/>
<xsl:variable name="translator_gender" select="'unknown'"/>
<xsl:variable name="translator_born" select="''"/>
<xsl:variable name="translator_nat" select="''"/>
<!-- select license type: free, standard or other -->
<xsl:variable name="license_type" select="''"/>
<xsl:variable name="sub_name" select="''"/>
<xsl:variable name="sub_email" select="''"/>
<xsl:variable name="wordcount" select="''"/>
<!-- Set this variable to 1 if the source for this doc is OCR -->
<!-- Those docs typically contain lots of orthographic errors and need special treatment -->
<xsl:variable name="ocr" select="''"/>
<xsl:variable name="metadata" select="'uncomplete'"/>
<xsl:variable name="template_version" select="'$Revision$'"/>
<xsl:variable name="current_version" select="'Revision'"/>
<!-- Free text field for notes -->
<xsl:variable name="note" select="''"/>

<!-- The main language of the document -->
<xsl:variable name="mainlang" select="'sme'"/>

<!-- Other languages, in case of multilingual document. -->
<!-- Select "1" for the variable multilingual -->
<xsl:variable name="monolingual" select="''"/> <!--lg rec is off!-->
<xsl:variable name="multilingual" select="''"/> <!--this is default-->

<!-- Select the potential langugages by adding the number "1" in the -->
<!-- selection frame. If no languages are selected, the document is -->
<!-- checked for all the languages below. -->
<xsl:variable name="mlang_dan" select="''"/>
<xsl:variable name="mlang_eng" select="''"/>
<xsl:variable name="mlang_fin" select="''"/>
<xsl:variable name="mlang_fkv" select="''"/>
<xsl:variable name="mlang_ger" select="''"/>
<xsl:variable name="mlang_isl" select="''"/>
<xsl:variable name="mlang_kal" select="''"/>
<xsl:variable name="mlang_kpv" select="''"/>
<xsl:variable name="mlang_nno" select="''"/>
<xsl:variable name="mlang_nob" select="''"/>
<xsl:variable name="mlang_rus" select="''"/>
<xsl:variable name="mlang_sma" select="''"/>
<xsl:variable name="mlang_sme" select="''"/>
<xsl:variable name="mlang_smj" select="''"/>
<xsl:variable name="mlang_swe" select="''"/>
<xsl:variable name="mlang_oth" select="''"/>

<!-- If the document has parallel texts, select "1" for parallel_texts -->
<!-- Add the locations of the parallel files to the variables-->
<xsl:variable name="parallel_texts" select="''"/>
<xsl:variable name="para_dan" select="''"/>
<xsl:variable name="para_eng" select="''"/>
<xsl:variable name="para_fin" select="''"/>
<xsl:variable name="para_fkv" select="''"/>
<xsl:variable name="para_ger" select="''"/>
<xsl:variable name="para_isl" select="''"/>
<xsl:variable name="para_kal" select="''"/>
<xsl:variable name="para_nno" select="''"/>
<xsl:variable name="para_nob" select="''"/>
<xsl:variable name="para_sma" select="''"/>
<xsl:variable name="para_sme" select="''"/>
<xsl:variable name="para_smj" select="''"/>
<xsl:variable name="para_swe" select="''"/>
<xsl:variable name="para_kpv" select="''"/>
<xsl:variable name="para_rus" select="''"/>


<!-- Tag the specified elements with the specified language: -->
<xsl:variable name="danlang" select="'dan'"/>
<xsl:variable name="englang" select="'eng'"/>
<xsl:variable name="finlang" select="'fin'"/>
<xsl:variable name="fkvlang" select="'fkv'"/>
<xsl:variable name="gerlang" select="'ger'"/>
<xsl:variable name="isllang" select="'isl'"/>
<xsl:variable name="kallang" select="'kal'"/>
<xsl:variable name="nnolang" select="'nno'"/>
<xsl:variable name="noblang" select="'nob'"/>
<xsl:variable name="smalang" select="'sma'"/>
<xsl:variable name="smelang" select="'sme'"/>
<xsl:variable name="smjlang" select="'smj'"/>
<xsl:variable name="swelang" select="'swe'"/>
<xsl:variable name="kpvlang" select="'kpv'"/>
<xsl:variable name="ruslang" select="'rus'"/>


<!-- Add all paragraphs that should have xml:lang=X           -->
<!-- Uncomment the following and add the paths, for example:  -->
<!-- <xsl:template match="/root/section[2]/paragraph[5] |
                      /root/section[3]/paragraph[2] ">        -->
<!--
<xsl:template match="//body/p[5]">
	<xsl:element name="p">
	<xsl:attribute name="xml:lang">
		<xsl:value-of select="$smelang"/>
	</xsl:attribute>
	<xsl:apply-templates/>
</xsl:element>
 </xsl:template>
-->

<!-- Change or remove problematic characters from the text.   -->
<!-- Specify the elements to match (here all p's within       -->
<!-- //body, that do contain text, but do NOT contain em and  -->
<!-- span elements), and specify the characters               -->
<!-- to be replaced and the replacements. If needed,          -->
<!-- copy this template and target several different elements,-->
<!-- but don't make several templates that match the same set -->
<!-- of elements - then only one of them will apply. Also try -->
<!-- to restrict the template to nodes that do not contain    -->
<!-- other markup, as such markup otherwise will be removed.  -->
<!--
<xsl:template match="p[parent::body][not(./em | ./span)][text()]">
    <xsl:variable name="text" select='current()' />
    <xsl:variable name="type" select='@type' />
    <xsl:variable name="lang" select='@xml:lang' />
    <xsl:element name="p">
        <xsl:if test="$type">
            <xsl:attribute name="type">
                <xsl:value-of select="$type"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="$lang">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="$lang"/>
            </xsl:attribute>
        </xsl:if>

        <xsl:call-template name="globalTextReplace">
           <xsl:with-param name="inputString" select="$text"/>
           <xsl:with-param name="target" select="'str1/str2/str3/'"/>
           <xsl:with-param name="replacement" select="'rpl1/rpl2/rpl3/'"/>
           <xsl:with-param name="continue" select="0"/>
        </xsl:call-template>
    </xsl:element>
</xsl:template>
-->

</xsl:stylesheet>
