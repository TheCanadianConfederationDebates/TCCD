<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> March 5, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> <xd:a href="mol:HOLM3">mholmes</xd:a></xd:p>
            <xd:p>Creates a sitemap file for Google Search.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:include href="tei_to_html_globals_module.xsl"/>
    
    <xsl:variable name="outputDir" select="concat($projectRoot, '/html/')"/>
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8" normalization-form="NFC"/>
    
    <xsl:param name="siteUrl" select="'http://hcmc.uvic.ca/confederation/'"/>
    
    <xsl:template match="/">
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"> 
            <xsl:for-each select="collection(concat($outputDir, '/?select=*.html;recurse=yes'))">
                <url>
                    <loc><xsl:value-of select="concat($siteUrl, substring-after(document-uri(.), '/html/'))"/></loc> 
                </url>
            </xsl:for-each>
        </urlset>
        <xsl:call-template name="robotsTxt"/>
    </xsl:template>
    
    <xsl:template name="robotsTxt">
        <xsl:result-document method="text" href="{concat($outputDir, 'robots.txt')}" indent="no" encoding="UTF-8">
            <xsl:text>Sitemap: </xsl:text><xsl:value-of select="concat($siteUrl, 'sitemap.xml')"/><xsl:text>&#x0a;</xsl:text>
        </xsl:result-document>
    </xsl:template>
    
    
</xsl:stylesheet>