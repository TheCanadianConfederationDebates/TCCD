<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 8, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>The object of this file is to compare two listPerson
            elements to find candidate matches (where the surname and 
            forenames match). This is to aid in disambiguating and 
            merging lists from separate sources which may contain 
            the same name.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:param name="mainDoc" select="doc('../../data/personography/personography.xml')"/>
    <xsl:param name="secondDoc" select="doc('../../data/personography/temp.xml')"/>
    
    
    
    <xsl:template match="/">
        <xsl:for-each select="$secondDoc//person">
            <xsl:variable name="lcSurname" select="lower-case(persName/surname)"/>
            <xsl:variable name="lcForename" select="lower-case(persName/forename)"/>
            <xsl:variable name="fullName" select="normalize-space(persName)"/>
            <xsl:variable name="pos" select="position()"/>
            <xsl:for-each select="$mainDoc//person">
                <xsl:if test="lower-case(persName[1]/surname[1]) = $lcSurname">
                    <xsl:if test="lower-case(persName[1]/forename[1]) = $lcForename">
                        <xsl:text>&#x0a;</xsl:text>
                        <xsl:text>person element at position </xsl:text>
                            <xsl:value-of select="$pos"/> 
                        <xsl:text> (</xsl:text><xsl:value-of select="$fullName"/>)<xsl:text> looks like it matches person with id </xsl:text>
                        <xsl:value-of select="@xml:id"/>
                        <xsl:text> (</xsl:text><xsl:value-of select="normalize-space(persName[1])"/><xsl:text>, </xsl:text><xsl:value-of select="string-join((descendant::affiliation/@when), ', ')"/><xsl:text>)&#x0a;</xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
        
        
    </xsl:template>
    
</xsl:stylesheet>