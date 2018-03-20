<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xh="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> January 11, 2017.</xd:p>
            <xd:p><xd:b>Author:</xd:b> <xd:a href="pers:HOLM3">mholmes</xd:a></xd:p>
            <xd:p>
                This module contains functions used in the generation of XHTML5 
                documents from TEI XML.
            </xd:p>
        </xd:desc>
    </xd:doc>
   
    <xd:doc>
        <xd:desc>This function echoes out a message in a slightly prettified way.</xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:message">
        <xsl:param name="msg" as="xs:string"/>
        <xsl:variable name="divider" as="xs:string" select="'*********************************'"/>
        <xsl:message><xsl:value-of select="$divider"/></xsl:message>
        <xsl:message><xsl:value-of select="$msg"/></xsl:message>
        <xsl:message><xsl:value-of select="$divider"/></xsl:message>
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>This function retrieves the canonical name of an entity such
            as a legislature from the project ODD file. Because these canonical 
        names exist in both languages, the result is going to be a mix.</xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:getTaxonomyVal" as="node()*">
        <xsl:param as="xs:string" name="legCode"/>
        <xsl:variable name="valItem" select="$projectOdd//valItem[@ident=$legCode]"/>
        <span title="{$valItem/desc}"><xsl:apply-templates select="$valItem/gloss/node()"/></span>
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>This function retrieves the subelements in the 
            canonical name of a legislature; they can then be
            further processed. </xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:getTaxonomyGloss" as="node()*">
        <xsl:param as="xs:string" name="legCode"/>
        <xsl:variable name="valItem" select="$projectOdd//valItem[@ident=$legCode]"/>
        <xsl:sequence select="$valItem/gloss/node()"/>
    </xsl:function>    
    
    <xd:doc scope="component">
        <xd:desc>This function is designed to combine two language spans
        for text-only output contexts such as html/head/title. </xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:bilingualText" as="xs:string">
        <xsl:param name="inText" as="element(xh:span)+"/>
        <xsl:value-of select="string-join($inText, ' / ')"/>
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>This function simply retrieves one of three captions
        based on the value of a string from the place/@type attribute.</xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:getPlaceTypeCaption" as="node()*">
        <xsl:param name="type" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$type='federal'">
                <xsl:sequence select="$federalRidingCaption"/>
            </xsl:when>
            <xsl:when test="$type='nonFederal'">
                <xsl:sequence select="$nonFederalRidingCaption"/>
            </xsl:when>
            <xsl:when test="$type='treaty'">
                <xsl:sequence select="$treatyLocationCaption"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>This function is designed to infer the putative id
            of a bibliography item from the id of a debate day document. 
            OBSOLETE.</xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:getBiblId" as="xs:string">
        <xsl:param name="inText" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($inText, 'treaty_')">
                <xsl:value-of select="$inText"/>
            </xsl:when>
            <xsl:when test="starts-with($inText, 'lgHC')">
                <xsl:value-of select="concat('lg', 'HC', if (contains($inText, '_fr_')) then '_fr' else '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace($inText, '_[\d\-]+$', '')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>This function is designed to create a pair of bounding
        xs:date values, returned as a sequence, from a date element
        which has @from and @to values which may not be complete
        dates.</xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:getDateRange" as="xs:date+">
        <xsl:param name="inDate" as="element(date)"/>
        <xsl:variable name="from" as="xs:date" select="if (string-length($inDate/@from) = 4) then xs:date(concat($inDate/@from, '-01-01'))
                                                      else if (string-length($inDate/@from) = 7) then xs:date(concat($inDate/@from, '-01'))
                                                      else xs:date($inDate/@from)"/>
        <xsl:variable name="to" as="xs:date" select="if (string-length($inDate/@to) = 4) then xs:date(concat($inDate/@to, '-12-31'))
            else if (string-length($inDate/@to) = 7) then xs:date(concat($inDate/@to, hcmc:getMonthDays(tokenize($inDate/@to, '-')[last()])))
            else xs:date($inDate/@to)"/>
        <xsl:sequence select="($from, $to)"/>
    </xsl:function>
    
    
    <xd:doc scope="component">
        <xd:desc>This function returns the number of days in a month based on the 
        month number. It ignores leap years.</xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:getMonthDays" as="xs:string">
        <xsl:param name="strMonthNum" as="xs:string"/>
        <xsl:variable name="intMonth" as="xs:integer" select="xs:integer($strMonthNum)"/>
        <xsl:choose>
            <xsl:when test="$intMonth = (1, 3, 5, 7, 8, 10, 12)"><xsl:value-of select="'31'"/></xsl:when>
            <xsl:when test="$intMonth = (4, 6, 9, 11)"><xsl:value-of select="'30'"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="'28'"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>