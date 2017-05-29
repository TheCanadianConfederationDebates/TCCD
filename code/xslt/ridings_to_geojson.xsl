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
            <xd:p><xd:b>Created on:</xd:b> May 29, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>This file converts the list of places in the placeography file
            into a GeoJSON file for use in the map interface website pages.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc scope="component">
        <xd:desc>Output method is JSON file.</xd:desc>
    </xd:doc>
    <xsl:output method="text" media-type="application/json" encoding="UTF-8" normalization-form="NFC" exclude-result-prefixes="#all"/>
    
    <xd:doc scope="component">
        <xd:desc>Regular expression for checking coordinates.</xd:desc>
    </xd:doc>
    <xsl:variable name="reCoords" select="'^\s*-?[0-9\.]+\s*,\s*-?[0-9\.]+\s*$'"/>
    
    <xd:doc scope="component">
        <xd:desc>Root template does all processing and produces output.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:message>Creating GeoJSON from <xsl:value-of select="count(//place)"/> riding locations in the placeography.</xsl:message>
        <xsl:text>{ "type": "FeatureCollection",
  "features": [</xsl:text>
        <xsl:for-each select="//place[@xml:id][descendant::geo[matches(., $reCoords)]]">
            <xsl:text>{
    "type": "Feature",
    "id": "</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>",
    "geometry": {
        "type": "Point", 
        "coordinates": [</xsl:text><xsl:variable name="latLon" select="tokenize(replace(location/geo, '\s+', ''), ',')"/><xsl:value-of select="concat($latLon[2], ',', $latLon[1])"/><xsl:text>]
        },
    "properties": {
        "name": "</xsl:text><xsl:value-of select="hcmc:escapeForJson(placeName/district)"/><xsl:text>",
        "notBefore": "</xsl:text><xsl:value-of select="location/@notBefore"/><xsl:text>",
        "notAfter": "</xsl:text><xsl:value-of select="location/@notAfter"/><xsl:text>"
        }
      }</xsl:text>
            <xsl:if test="position() lt last()"><xsl:text>,</xsl:text></xsl:if>
        </xsl:for-each>
        <xsl:text>  ]
  }</xsl:text>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Function to escape text for JSON serialization.</xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:escapeForJson" as="xs:string">
        <xsl:param name="inStr" as ="xs:string"/>
        <xsl:value-of select="replace(replace(normalize-space($inStr), '\\', '\\\\'), '&quot;', '\\&quot;')"/>
    </xsl:function>
    
</xsl:stylesheet>