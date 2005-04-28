<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="xml" 
            version="1.0" 
            encoding="UTF-8" 
            indent="yes"
            doctype-public="-//UIT//DTD Corpus V1.0//EN"
            doctype-system="http://giellatekno.uit.no/dtd/corpus.dtd"/>

<!--<xsl:strip-space elements="title emphasis"/>-->

<!--
   Root element 
-->

<xsl:template match="book">
    <xsl:text>
</xsl:text>
    <xsl:element name="document">
        <xsl:attribute name="xml:lang">
            <xsl:value-of select="@lang"/>
        </xsl:attribute>
        <xsl:text>
  </xsl:text>
        <xsl:element name="header">
        <xsl:text>
     </xsl:text>
            <xsl:apply-templates select="bookinfo"/>
        </xsl:element>
        <xsl:text>

  </xsl:text>
        <body>
            <xsl:apply-templates select="chapter"/>
            <xsl:apply-templates select="para"/>
            <xsl:apply-templates select="table"/>
            <xsl:apply-templates select="orderedlist"/>
            <xsl:text>
  </xsl:text>
        </body>
        <xsl:text>
</xsl:text>
    </xsl:element>
</xsl:template>

<!--
    Meta information
-->

<xsl:template match="bookinfo">
<!--    <xsl:element name="fileDesc"> -->
        <xsl:text>
        </xsl:text>
        <xsl:element name="title">
            <xsl:value-of select="title"/>
        </xsl:element>
        <xsl:text>
        </xsl:text>
<!--
        <xsl:element name="language">
            <xsl:value-of select="/book/@lang"/>
        </xsl:element>
--> 
       <xsl:text>
        </xsl:text>
        <xsl:element name="translated-from">
            
        </xsl:element>
        <xsl:text>
        </xsl:text>
        <xsl:element name="genre">
            <xsl:comment>
                <xsl:text>Uncomment the relevant option:</xsl:text>
            </xsl:comment>
            <xsl:comment>
                
            </xsl:comment>
        </xsl:element>
        <xsl:text>
     </xsl:text>
<!--     </xsl:element> -->
     <xsl:text>
     </xsl:text>
<!--     <xsl:element name="sourceDesc">-->
        <xsl:apply-templates select="author"/>
        <xsl:apply-templates select="date"/>
        <xsl:choose>
            <xsl:when test="corpname">
                <xsl:apply-templates select="corpname"/>            
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="publChannel">
                    <xsl:element name="unpublished"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>
     </xsl:text>
<!--     </xsl:element>-->
    <xsl:text>
  </xsl:text>
</xsl:template>

<xsl:template match="author">
    <xsl:text>
        </xsl:text>
    <xsl:element name="author">
        <xsl:text>
            </xsl:text>
        <xsl:element name="person">
            <xsl:attribute name="name">
                <xsl:value-of select="concat(surname, ' ', forname)"/>
            </xsl:attribute>
            <xsl:attribute name="sex">m</xsl:attribute>
        </xsl:element>
        <xsl:text>
        </xsl:text>
    </xsl:element>
</xsl:template>

<xsl:template match="date">
    <xsl:text>
        </xsl:text>
    <xsl:element name="year">
        <xsl:value-of select="number(substring-before(., '-'))"/>
    </xsl:element>
</xsl:template>

<xsl:template match="corpname">
    <xsl:text>
        </xsl:text>
    <xsl:element name="publChannel">
        <xsl:text>
            </xsl:text>
        <xsl:element name="publisher">
            <xsl:value-of select="."/>
        </xsl:element>
        <xsl:text>
            </xsl:text>
        <xsl:element name="ISBN"/>
        <xsl:text>
            </xsl:text>
        <xsl:element name="ISSN"/>
        <xsl:text>
        </xsl:text>
    </xsl:element>
</xsl:template>


<!--
    Corpus text body
-->

<xsl:template match="chapter">
    <xsl:if test="normalize-space(.)">
        <xsl:text>
    </xsl:text>
        <xsl:element name="section">
            <xsl:apply-templates mode="chapter"/>
            <xsl:text>   </xsl:text>
        </xsl:element>
    </xsl:if>
</xsl:template>

<xsl:template match="chapter" mode="chapter">
    <xsl:if test="normalize-space(.)">
        <xsl:text>
    </xsl:text>
        <xsl:element name="section">
            <xsl:apply-templates mode="chapter"/>
            <xsl:text>   </xsl:text>
        </xsl:element>
    </xsl:if>
</xsl:template>

<xsl:template match="title" mode="chapter">
<!--    <xsl:strip-space elements="*"/>-->
    <xsl:choose>
        <xsl:when test="normalize-space(.)">
            <xsl:text>       </xsl:text>
            <xsl:choose>
                <!-- Guessing wheather a title is actually a paragraph -->
                <xsl:when 
                    test="string-length(.) > 130 and not(starts-with(translate(., '0123456789', '9999999999'), '9'))">
<!--                 <xsl:element name="text"> -->
                        <xsl:text>
          </xsl:text>
                        <xsl:element name="p">
                            <xsl:apply-templates mode="text"/>
                        <xsl:text>
          </xsl:text>
                        </xsl:element>
                        <xsl:text>
       </xsl:text>
<!--                </xsl:element>-->
                </xsl:when>
                <!-- Else it is a title -->
                <xsl:otherwise>
                    <xsl:element name="p">
                        <xsl:attribute name="type">title</xsl:attribute>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:otherwise>

            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="title" mode="text">
    <xsl:if test="normalize-space(.)">
        
    </xsl:if>
</xsl:template>


<xsl:template match="para" mode="chapter">
<!--    <xsl:strip-space elements="*"/>-->
    <xsl:if test="normalize-space(.)">
        <xsl:choose>
            <xsl:when test="emphasis[@role='bold'] and 130 > string-length(.)">
                <xsl:apply-templates select="emphasis" mode="para"/>
            </xsl:when>
            <xsl:when test="descendant::tbody">
<!--                <xsl:element name="text">-->
                    <xsl:apply-templates mode="text"/>
<!--                </xsl:element>-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>     </xsl:text>
<!--                <xsl:element name="text">-->
                    <xsl:text>
          </xsl:text>
                    <xsl:element name="p">
                        <xsl:apply-templates mode="text"/>
                        <xsl:text>         </xsl:text>
                    </xsl:element>
                    <xsl:text>
       </xsl:text>
<!--                </xsl:element>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<xsl:template match="para" mode="text">
    <xsl:element name="p">
        <xsl:apply-templates mode="text"/>
    </xsl:element>
</xsl:template>


<xsl:template match="emphasis" mode="text">
    <xsl:element name="em">
        <xsl:attribute name="type">
            <xsl:value-of select="@role"/>
        </xsl:attribute>
        <xsl:apply-templates mode="text"/>
    </xsl:element>
</xsl:template>

<xsl:template match="emphasis" mode="para">
<!--    <xsl:strip-space elements="*"/>-->
    <xsl:choose>
    <xsl:when 
        test="starts-with(translate(., '0123456789', '9999999999'), '9') or 
              not(contains(., '.'))">
        <xsl:text>     </xsl:text>
        <xsl:element name="p">
            <xsl:attribute name="type">title</xsl:attribute>
            <xsl:apply-templates mode="chapter"/>
        </xsl:element>
    </xsl:when>
    <xsl:otherwise>
        <xsl:text>     </xsl:text>
<!--        <xsl:element name="text">-->
            <xsl:text>
            </xsl:text>
            <xsl:element name="p">
                <xsl:apply-templates mode="text"/>
            <xsl:text>
            </xsl:text>
            </xsl:element>            
            <xsl:text>
        </xsl:text>
<!--        </xsl:element>-->
    </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="tbody" mode="text">
    <xsl:element name="table">
        <xsl:apply-templates select="row" mode="text"/>
    </xsl:element>
</xsl:template>

<xsl:template match="row" mode="text">
    <xsl:text>
        </xsl:text>
    <xsl:element name="row">
        <xsl:apply-templates select="entry" mode="text"/>
    </xsl:element>
    <xsl:text>
    </xsl:text>
</xsl:template>

<xsl:template match="entry" mode="text">
    <xsl:text>
           </xsl:text>
    <xsl:element name="p">
        <xsl:attribute name="type">tablecell</xsl:attribute>
        <xsl:apply-templates mode="text"/>
        <xsl:text>    </xsl:text>
    </xsl:element>
    <xsl:text>
        </xsl:text>
</xsl:template>

<xsl:template match="orderedlist" mode="chapter">
    <xsl:if test="normalize-space(.)">
        <xsl:text>    </xsl:text>
<!--        <xsl:element name="text">-->
            <xsl:text>
        </xsl:text>
            <xsl:element name="list">
                <xsl:apply-templates select="listitem" mode="text"/>
            </xsl:element>            
            <xsl:text>
     </xsl:text>
<!--        </xsl:element>-->
        <xsl:text>
    </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="itemizedlist" mode="chapter">
    <xsl:if test="normalize-space(.)">
        <xsl:text>    </xsl:text>
<!--        <xsl:element name="text">-->
            <xsl:text>
        </xsl:text>
            <xsl:element name="list">
                <xsl:apply-templates select="listitem" mode="text"/>
            </xsl:element>            
            <xsl:text>
     </xsl:text>
<!--        </xsl:element>-->
        <xsl:text>
    </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="listitem" mode="text">
    <xsl:if test="normalize-space(.)">
        <xsl:text>
           </xsl:text>
        <xsl:element name="p">
            <xsl:attribute name="type">listitem</xsl:attribute>
            <xsl:apply-templates mode="listitem"/>
            <xsl:text>        </xsl:text>
        </xsl:element>
        <xsl:text>
        </xsl:text>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>