<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:param name="imageFilePath" as="xs:string" select="''"/>
    <xsl:param name="pageNumber" as="xs:string" select="''"/>
    
    <xsl:output method="xhtml" encoding="UTF-8" normalization-form="NFC"/>
    
    <xsl:template match="/">
        <xsl:message>Image file name is: <xsl:value-of select="$imageFilePath"/></xsl:message>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="div[@class='ocr_page']">
        <xsl:copy>
            <xsl:attribute name="id" select="concat('page_',$pageNumber)"/>
            <xsl:attribute name="title" select="concat('image &quot;../images/',tokenize($imageFilePath,'/')[last()],'&quot;; ', @title)"/>
            <xsl:apply-templates select="@xml:space|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>