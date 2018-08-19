<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" version="2.0">
    
    <!-- vlastní šablony -->
    
    <xsl:template name="format_delka">
        <xsl:param name="delka" />
        <xsl:value-of select="concat(minutes-from-duration($delka), ':', format-number(seconds-from-duration($delka), '00'))"/>
    </xsl:template>
    
    <xsl:template name="format_datum">
        <xsl:param name="datum" />
        <xsl:value-of select="format-dateTime($datum, '[D01].[M01].[Y0001]')"/>
    </xsl:template>
    
    
    <!-- sady atributů -->
    
    <xsl:attribute-set name="odkaz">
        <xsl:attribute name="color">blue</xsl:attribute>
        <xsl:attribute name="text-decoration">underline</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="blok">
        <xsl:attribute name="border">1pt solid #ddd</xsl:attribute>
        <xsl:attribute name="background-color">#eee</xsl:attribute>
        <xsl:attribute name="padding">5pt</xsl:attribute>
        <xsl:attribute name="margin-bottom">5pt</xsl:attribute>
    </xsl:attribute-set>
    
    
    <!-- šablony -->
    
    <xsl:template match="/">
        <fo:root>
            
            <fo:layout-master-set>
                <fo:simple-page-master master-name="seznam" 
                    page-height="29cm" page-width="21cm"
                    margin="2cm">
                    <fo:region-body margin-top="1.5cm" margin-bottom="1.5cm" />
                    <fo:region-before extent="0cm"/>
                    <fo:region-after extent="0cm"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            
            <fo:page-sequence master-reference="seznam" font-family="Arial" font-size="10pt">
                
                <fo:static-content flow-name="xsl-region-before" color="grey" font-size="12pt">
                    <fo:block text-align="center">
                        Martin Kapal
                    </fo:block>
                </fo:static-content>
                
                <fo:static-content flow-name="xsl-region-after" color="grey" font-size="12pt">
                    <fo:block text-align="center">
                        Strana <fo:page-number/>
                    </fo:block>
                </fo:static-content>
                
                <fo:flow flow-name="xsl-region-body">
                
                    <fo:block margin-bottom="5pt" font-size="18pt" border-bottom-style="solid" border-bottom-width="0.25pt" border-bottom-color="#888888">
                        <xsl:value-of select="seznam_videi/titulek"/>
                    </fo:block>
                    <fo:block font-size="10pt" color="#666666">
                        <xsl:apply-templates select="seznam_videi/autor"/> •
                        <xsl:variable name="pocet_videi" select="count(seznam_videi/videa/video)"/>
                        <xsl:copy-of select="$pocet_videi"/>
                        <xsl:choose>
                            <xsl:when test="$pocet_videi = 1"> video</xsl:when>
                            <xsl:when test="$pocet_videi &lt; 5"> videa</xsl:when>
                            <xsl:otherwise> videí</xsl:otherwise>
                        </xsl:choose> •
                        <xsl:call-template name="format_datum">
                            <xsl:with-param name="datum" select="seznam_videi/vytvoreno"/>
                        </xsl:call-template>
                        <xsl:if test="seznam_videi/aktualizovano">
                            (aktualizováno 
                            <xsl:call-template name="format_datum">
                                <xsl:with-param name="datum" select="seznam_videi/aktualizovano"/>
                            </xsl:call-template>)
                        </xsl:if>
                        •
                        <xsl:choose>
                            <xsl:when test="seznam_videi/verejne = true()">veřejný</xsl:when>
                            <xsl:otherwise>soukromý</xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                    
                    <xsl:apply-templates select="seznam_videi/videa" mode="seznam"/>
                    <xsl:apply-templates select="seznam_videi/videa" mode="detail"/>
                         
                </fo:flow>
                
            </fo:page-sequence>
        </fo:root>
    </xsl:template>
    
    <xsl:template match="//autor">
        <fo:basic-link external-destination="https://www.youtube.com/channel/{@chid}" xsl:use-attribute-sets="odkaz"><xsl:value-of select="jmeno"/></fo:basic-link>
        <xsl:if test="overeno = true()"> (ověřený)</xsl:if>
        <xsl:if test="google_plus">
            • <fo:basic-link external-destination="https://plus.google.com/{google_plus}" xsl:use-attribute-sets="odkaz">Google+ profil</fo:basic-link>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="videa" mode="seznam">
        <fo:table page-break-after="always" width="100%" border-width="1pt" border-style="solid" background-color="#e8e8e8"
            display-align="center" margin-top="20pt">
            <fo:table-column column-width="5%"/>
            <fo:table-column column-width="10%"/>
            <fo:table-column column-width="75%"/>
            <fo:table-column column-width="10%"/>
            <fo:table-body>
                <xsl:apply-templates select="video" mode="seznam">
                    <xsl:sort select="titulek"/>
                </xsl:apply-templates>
            </fo:table-body>
        </fo:table>
    </xsl:template>
    
    <xsl:template match="video" mode="seznam">
        <fo:table-row height="20pt" border-top="1pt solid black">
            <fo:table-cell>
                <fo:block text-align="center"><xsl:value-of select="position()"/></fo:block>
            </fo:table-cell>
            <fo:table-cell>
                <fo:block>
                    <xsl:variable name="video_id"><xsl:value-of select="@vid"/></xsl:variable>
                    <fo:external-graphic src="url(http://img.youtube.com/vi/{$video_id}/hqdefault.jpg)" 
                        width="100%"
                        content-height="100%"
                        content-width="scale-to-fit" 
                        text-align="center"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell>
                <fo:block margin-left="10pt">
                    <fo:basic-link internal-destination="{@vid}" xsl:use-attribute-sets="odkaz">
                         <xsl:value-of select="titulek"/>
                    </fo:basic-link>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell>
                <fo:block text-align="center">
                    <xsl:call-template name="format_delka">
                        <xsl:with-param name="delka" select="delka"/>
                    </xsl:call-template>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    
    <xsl:template match="videa" mode="detail">
        <xsl:apply-templates select="video" mode="detail">
            <xsl:sort select="titulek"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="video" mode="detail">
        <fo:block margin-bottom="30pt" page-break-after="always">

            <xsl:apply-templates select="titulek" mode="detail"/>
            
            <fo:block xsl:use-attribute-sets="blok">
                <fo:block background-color="#000" height="auto" text-align="center">
                    <xsl:variable name="video_id" select="@vid"/>
                    <fo:external-graphic src="url(http://img.youtube.com/vi/{$video_id}/hqdefault.jpg)" width="50%" content-width="scale-to-fit" />
                </fo:block>
                <fo:block margin-top="5pt">
                    <fo:basic-link font-size="14pt" external-destination="https://www.youtube.com/watch?v={@vid}" xsl:use-attribute-sets="odkaz">www.youtube.com/watch?v=<xsl:value-of select="@vid"/></fo:basic-link>
                </fo:block>
              <fo:block color="#777">
                    Kvalita:
                    <xsl:for-each select="kvality/kvalita">
                        <xsl:value-of select="."/>
                        <xsl:if test="not(position() = last())"> • </xsl:if>
                    </xsl:for-each>
                </fo:block>
            </fo:block>
            
            <fo:block xsl:use-attribute-sets="blok">
                <fo:table width="100%">
                    <fo:table-column column-width="15%"/>
                    <fo:table-column column-width="50%"/>
                    <fo:table-column column-width="35%"/>
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block>Autor: </fo:block>
                                <fo:block>Nahráno: </fo:block>
                                <fo:block>Publikováno: </fo:block>
                                <xsl:if test="titulky"><fo:block>Titulky: </fo:block></xsl:if>
                            </fo:table-cell>
                            
                            <fo:table-cell>
                                <fo:block>
                                    <xsl:apply-templates select="autor"/>
                                </fo:block>
                                <fo:block>
                                    <xsl:call-template name="format_datum">
                                        <xsl:with-param name="datum" select="nahrano"/>
                                    </xsl:call-template>
                                </fo:block>
                                <fo:block>
                                    <xsl:call-template name="format_datum">
                                        <xsl:with-param name="datum" select="publikovano"/>
                                    </xsl:call-template>
                                </fo:block>
                                <xsl:if test="titulky">
                                    <fo:block>
                                        <xsl:for-each select="titulky/jazyk">
                                            <xsl:value-of select="."/>
                                            <xsl:if test="not(position() = last())">, </xsl:if>
                                        </xsl:for-each>
                                    </fo:block>
                                </xsl:if>
                            </fo:table-cell>
                            
                            <fo:table-cell text-align="right">
                                <fo:block font-size="15pt"><xsl:value-of select="translate(format-number(zhlednuti, '#,###'), ',', ' ')"/> zhlédnutí</fo:block>
                                <fo:block>
                                    <fo:inline color="green"><xsl:value-of select="translate(format-number(likes, '#,###'), ',', ' ')"/></fo:inline> líbí • 
                                    <fo:inline color="#cc0000"><xsl:value-of select="translate(format-number(dislikes, '#,###'), ',', ' ')"/></fo:inline> nelíbí</fo:block>
                                <fo:block>Délka: 
                                    <xsl:call-template name="format_delka">
                                        <xsl:with-param name="delka" select="delka"/>
                                    </xsl:call-template>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:block>
            
            <xsl:if test="popis">
                <xsl:apply-templates select="popis"/>
            </xsl:if>
            
            <xsl:apply-templates select="komentare"/>
            
        </fo:block>
            
    </xsl:template>
    
    <xsl:template match="video/titulek" mode="detail">
        <fo:block font-size="26pt" id="{../@vid}">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="video/popis">
        <fo:block xsl:use-attribute-sets="blok" keep-with-next.within-page="always" keep-together.within-page="always">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
   
    <xsl:template match="komentare">
        <fo:block xsl:use-attribute-sets="blok" keep-with-next.within-page="always" keep-together.within-page="always">
            <fo:block font-weight="bold" font-size="13pt" border-bottom="1pt solid #999" margin-bottom="5pt">Komentáře dle hodnocení</fo:block>
            
            <xsl:choose>
                <xsl:when test="komentar[not(@replyto)]">
                    <xsl:apply-templates select="komentar[not(@replyto)]">
                        <xsl:sort select="likes - dislikes" order="descending"></xsl:sort>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>Toto video neobsahuje žádné komentáře.</xsl:otherwise>
            </xsl:choose>
            
        </fo:block>
    </xsl:template>
    
    <xsl:template match="komentar">
        
        <!-- odsadit odpovědi -->
        <xsl:variable name="margin">
            <xsl:choose>
                <xsl:when test="@replyto">15pt</xsl:when>
                <xsl:otherwise>0pt</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <fo:block margin-bottom="10pt" margin-top="10pt">
            <xsl:attribute name="margin-left"><xsl:value-of select="$margin"/></xsl:attribute>
            
            <fo:block>
                <xsl:apply-templates select="autor"/>
                <fo:inline color="#777" padding-left="6pt">
                    <xsl:value-of select="format-dateTime(zverejneno, '[D01].[M01].[Y0001] [H01]:[m01]:[s01]')"/>
                </fo:inline>
            </fo:block>
            
            <xsl:apply-templates select="text"/>
            
            <fo:block>
                Hodnocení:
                <fo:inline>
                    <xsl:attribute name="color">
                        <xsl:choose>
                            <xsl:when test="likes - dislikes &gt; 0">green</xsl:when>
                            <xsl:when test="likes - dislikes &lt; 0">#cc0000</xsl:when>
                            <xsl:otherwise>#000</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="format-number(likes - dislikes, '+#;-#')"/>
                </fo:inline>
            </fo:block>
                
        </fo:block>
        
        <!-- zobrazit odpovědi na tento komentář -->
        <xsl:variable name="cid" select="@cid"/>
        <xsl:apply-templates select="//komentar[@replyto=$cid]">
            <xsl:sort select="likes - dislikes" order="descending"></xsl:sort>
        </xsl:apply-templates>
        
    </xsl:template>
    
    <xsl:template match="komentar/text">
        <fo:block background-color="#fafafa" padding="4pt" margin-bottom="2pt" margin-top="2pt">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="//br">
        <fo:block/>
    </xsl:template>

</xsl:stylesheet>