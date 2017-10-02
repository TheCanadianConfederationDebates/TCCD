<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:hcmc="http://hcmc.uvic/ca/ns"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> June 2, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>This file converts the list of places in the placeography
            into a CSV spreadsheet for Dan to tinker with.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc scope="component">
        <xd:desc>Output method is CSV file.</xd:desc>
    </xd:doc>
    <xsl:output method="text" media-type="text/csv" encoding="UTF-8" normalization-form="NFC" exclude-result-prefixes="#all"/>
    
    <xd:doc scope="component">
        <xd:desc>Root template does all processing and produces output.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:message>Creating CSV from from <xsl:value-of select="count(//place)"/> places in the placeography.</xsl:message>
<!--     Header row.    -->
        <xsl:text>@xml:id&#9;@type&#9;region&#9;district&#9;locationDates&#9;geo&#9;note</xsl:text>
        <xsl:for-each select="//place">
            <xsl:sort select="placeName"/>
            <xsl:text>&#x0a;</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:value-of select="concat('&#9;', @type)"/>
            <xsl:value-of select="concat('&#9;', placeName/region)"/>
            <xsl:value-of select="concat('&#9;', placeName/district)"/>
            <xsl:value-of select="concat('&#9;', location/@notBefore, '-', location/@notAfter)"/>
            <xsl:value-of select="concat('&#9;', location/geo)"/>
            <xsl:value-of select="concat('&#9;', normalize-space(note))"/>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>