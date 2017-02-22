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
    version="2.0">
    
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
            as a legislature from the project ODD file. 
            NOTE: THIS NEEDS TO BE IMPROVED TO HANDLE
            FRENCH NAMES WHEN WE HAVE THEM.</xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:getTaxonomyVal" as="node()*">
        <xsl:param as="xs:string" name="legCode"/>
        <xsl:variable name="valItem" select="$projectOdd//valItem[@ident=$legCode]"/>
        <span title="{$valItem/desc}"><xsl:value-of select="$valItem/gloss"/></span>
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>This function is designed to combine two language spans
        for text-only output contexts such as html/head/title. </xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:bilingualText" as="xs:string">
        <xsl:param name="inText" as="element(xh:span)+"/>
        <xsl:value-of select="string-join($inText, ' / ')"/>
    </xsl:function>
    
</xsl:stylesheet>