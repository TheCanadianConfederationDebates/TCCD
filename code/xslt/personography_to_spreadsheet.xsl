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
            <xd:p>This file converts the list of people in the personography
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
        <xsl:message>Creating CSV from from <xsl:value-of select="count(//listPerson[@xml:id='historicalPersonography']/person)"/> people in the personography.</xsl:message>
<!--     Header row.    -->
        <xsl:text>@xml:id&#9;nameDate&#9;surname&#9;forename&#9;affiliation&#9;state&#9;biblio (en)&#9;biblio (fr)</xsl:text>
        <xsl:for-each select="//listPerson[@xml:id='historicalPersonography']/person">
            <xsl:sort select="if (persName/surname) then persName[1]/surname[1] else ''"/>
            <xsl:text>&#x0a;</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:value-of select="concat('&#9;', persName[1]/@when)"/>
            <xsl:value-of select="concat('&#9;', persName[1]/surname[1])"/>
            <xsl:value-of select="concat('&#9;', if (persName[1]/forename) then persName[1]/forename[1] else '')"/>
            <xsl:value-of select="concat('&#9;', hcmc:processAffiliations(affiliation))"/>
            <xsl:value-of select="concat('&#9;', string-join((state/@when), '; '))"/>
            <xsl:value-of select="concat('&#9;', if (descendant::bibl[@xml:lang='en']/ptr) then descendant::bibl[@xml:lang='en'][1]/ptr[1]/@target else '')"/>
            <xsl:value-of select="concat('&#9;', if (descendant::bibl[@xml:lang='fr']/ptr) then descendant::bibl[@xml:lang='fr'][1]/ptr[1]/@target else '')"/>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Turning of affiliation elements into string output.</xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:processAffiliations" as="xs:string*">
        <xsl:param name="affs" as="element(affiliation)*"/>
        <xsl:variable name="affsOut" as="xs:string*">
            <xsl:for-each select="$affs">
                <xsl:value-of select="concat('&lt;affiliation', string-join((for $att in @* return concat(' ', $att/local-name(), '=&quot;', $att, '&quot;')), ''), '&gt;', ., '&gt;/affiliation&gt;')"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="normalize-space(string-join($affsOut, '; '))"/>
    </xsl:function>
    
</xsl:stylesheet>