<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    
    <xsl:output method="html" encoding="UTF-8" />
    
    <!-- vlastní šablony -->
    
    <xsl:template name="format_delka">
        <xsl:param name="delka" />
        <xsl:value-of select="concat(minutes-from-duration($delka), ':', format-number(seconds-from-duration($delka), '00'))"/>
    </xsl:template>
    
    <xsl:template name="format_datum">
        <xsl:param name="datum" />
        <xsl:value-of select="format-dateTime($datum, '[D01].[M01].[Y0001]')"/>
    </xsl:template>
    
    
    <!-- šablony -->
    
    <xsl:template match="/">
        <xsl:result-document href="playlist.html">
            <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
            <html>
                <head>
                    <title><xsl:value-of select="seznam_videi/titulek"/></title>
                    <link rel="stylesheet" type="text/css" href="playlist.css"/>
                </head>
                <body>
                    <div id="hlavni">
                        <h1><xsl:value-of select="seznam_videi/titulek"/></h1>
                        
                        <div class="blok" id="podnadpis">
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
                        </div>
                        
                        <xsl:apply-templates select="seznam_videi/videa" mode="seznam"/>
                        <xsl:apply-templates select="seznam_videi/videa" mode="detail"/>
                        
                        <footer>Martin Kapal 2016</footer>
                        
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="//autor">
        <a href="https://www.youtube.com/channel/{@chid}" target="_blank"><xsl:value-of select="jmeno"/></a>
        <xsl:if test="overeno = true()"><span class="overeno" title="Ověřený uživatel">✔</span></xsl:if>
        <xsl:if test="google_plus">
            (<a href="https://plus.google.com/{google_plus}" target="_blank">Google+ profil</a>)
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="videa" mode="seznam">
        <table class="blok" id="seznam">
            <xsl:apply-templates select="video" mode="seznam">
                <xsl:sort select="titulek"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>
    
    <xsl:template match="video" mode="seznam">
        <tr>
            <td width="15">
                <xsl:value-of select="position()"/>
            </td>
            <td width="120">
                <xsl:variable name="video_id"><xsl:value-of select="@vid"/></xsl:variable>
                <a href="playlist_detail_{@vid}.html"><img class="thumb" src="http://img.youtube.com/vi/{$video_id}/1.jpg" alt="{titulek}"/></a>
            </td>
            <td>
                <a href="playlist_detail_{@vid}.html"><xsl:value-of select="titulek"/></a>
            </td>
            <td width="50" class="delka">
                <xsl:call-template name="format_delka">
                    <xsl:with-param name="delka" select="delka"/>
                </xsl:call-template>
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="videa" mode="detail">
        <xsl:apply-templates select="video" mode="detail">
            <xsl:sort select="titulek"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="video" mode="detail">
        <xsl:result-document href="playlist_detail_{@vid}.html">
            <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
            <html>
                <head>
                    <title><xsl:value-of select="titulek"/></title>
                    <link rel="stylesheet" type="text/css" href="playlist.css"/>
                </head>
                <body>
                    <div id="hlavni">
                        
                        <div><a class="tlacitko" href="playlist.html">↩ Zpět na seznam videí</a></div>
                    
                        <div class="video">
                           
                           <div class="blok">
                               <div class="video_area">
                                   <xsl:variable name="video_id" select="@vid"/>
                                   <iframe width="100%" height="480" src="https://www.youtube.com/embed/{$video_id}" frameborder="0" allowfullscreen="true"></iframe>
                               </div>
                               <div class="video_bar">
                                   <div class="delka">
                                       <xsl:call-template name="format_delka">
                                           <xsl:with-param name="delka" select="delka"/>
                                       </xsl:call-template>
                                   </div>
                                   <div class="kvality_titulky">
                                       <span class="kvality">
                                           <xsl:for-each select="kvality/kvalita">
                                               <xsl:value-of select="."/>
                                               <xsl:if test="not(position() = last())"> • </xsl:if>
                                           </xsl:for-each>
                                       </span>
                                       <xsl:if test="titulky">
                                           <span class="titulky">
                                               Titulky:
                                               <xsl:for-each select="titulky/jazyk">
                                                   <xsl:value-of select="."/>
                                                   <xsl:if test="not(position() = last())">, </xsl:if>
                                               </xsl:for-each>
                                           </span>
                                       </xsl:if>
                                   </div>
                               </div>
                               
                               <div class="zakladni_info">
                                   <div class="titulek_autor">
                                       <xsl:apply-templates select="titulek" mode="detail"/>
                                       Autor: <xsl:apply-templates select="autor"/>
                                   </div>
                                   <div class="statistiky">
                                       <div class="zhlednuti"><xsl:value-of select="translate(format-number(zhlednuti, '#,###'), ',', ' ')"/></div>
                                       <span class="likes"><xsl:value-of select="translate(format-number(likes, '#,###'), ',', ' ')"/></span> líbí 
                                       <span class="dislikes"><xsl:value-of select="translate(format-number(dislikes, '#,###'), ',', ' ')"/></span> nelíbí
                                   </div>
                               </div>
                               
                           </div>
                           
                           <div class="blok">
                               <div class="datum_nahrani_publikovani">Nahráno: <xsl:value-of select="format-dateTime(nahrano, '[D01].[M01].[Y0001]')"/><br/>
                               Publikováno: <xsl:value-of select="format-dateTime(publikovano, '[D01].[M01].[Y0001]')"/></div>
                               
                               <xsl:if test="popis">
                                   <br/>
                                   <xsl:apply-templates select="popis"/>
                               </xsl:if>
                           </div>
                           
                           <xsl:apply-templates select="komentare"/>
                           
                       </div>
                        
                        <footer>Martin Kapal 2016</footer>
                     </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="video/titulek" mode="detail">
        <h1><xsl:apply-templates/></h1>
    </xsl:template>

    <xsl:template match="video/popis">
        <xsl:apply-templates/>
    </xsl:template>
   
    <xsl:template match="komentare">
        <div class="blok">
            <h2>Komentáře dle hodnocení</h2>
            <xsl:choose>
                <xsl:when test="komentar[not(@replyto)]">
                    <xsl:apply-templates select="komentar[not(@replyto)]">
                        <xsl:sort select="likes - dislikes" order="descending"></xsl:sort>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>Toto video neobsahuje žádné komentáře.</xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <xsl:template match="komentar">
        
        <!-- odsadit odpovědi -->
        <xsl:variable name="margin">
            <xsl:choose>
                <xsl:when test="@replyto">komentar komentar_odpoved</xsl:when>
                <xsl:otherwise>komentar</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <div class="komentar">
            <xsl:attribute name="class"><xsl:value-of select="$margin"/></xsl:attribute>
            
            <div>
                <xsl:apply-templates select="autor"/>
                <span class="datum_komentare">
                    <xsl:value-of select="format-dateTime(zverejneno, '[D01].[M01].[Y0001] [H01]:[m01]:[s01]')"/>
                </span>
            </div>
            
            <xsl:apply-templates select="text"/>
            
            <div class="hodnoceni">
                Hodnocení:
                <span>
                    <xsl:attribute name="class">
                        <xsl:choose>
                            <xsl:when test="likes - dislikes &gt; 0">likes</xsl:when>
                            <xsl:when test="likes - dislikes &lt; 0">dislikes</xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="format-number(likes - dislikes, '+#;-#')"/>
                </span>
            </div>
                
        </div>
        
        <!-- zobrazit odpovědi na tento komentář -->
        <xsl:variable name="cid" select="@cid"/>
        <xsl:apply-templates select="//komentar[@replyto=$cid]">
            <xsl:sort select="likes - dislikes" order="descending"></xsl:sort>
        </xsl:apply-templates>
        
    </xsl:template>
    
    <xsl:template match="komentar/text">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="//br">
        <br/>
    </xsl:template>

</xsl:stylesheet>