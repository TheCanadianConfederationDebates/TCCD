<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="2.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> January 11, 2017.</xd:p>
            <xd:p><xd:b>Author:</xd:b> <xd:a href="pers:HOLM3">mholmes</xd:a></xd:p>
            <xd:p>
                This module identifies the collection of TEI documents which need
                to be converted to XHTML5 and generates one or more result documents
                from each one.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>xsl:key to provide quicker, cleaner access to mentions of people. Use for 
            example like this, to find documents which mention a person:
            select="$xmlDocs/key('mentionsOfPeople', 'CART2')"
            </xd:desc>
    </xd:doc>
    <xsl:key name="mentionsOfPeople" match="persName[@ref]" use="substring-after(@ref, 'pers:')"/>
    
    <xd:doc>
        <xd:desc>The base template, allDocs, finds all the XML files and processes
        them as required to produce output in XHTML5.</xd:desc>
    </xd:doc>
    <xsl:template name="allDocs">
        <xsl:sequence select="hcmc:message(concat('Processing documents in ', $projectData))"/>
        <xsl:sequence select="hcmc:message(concat('Found ', count($teiDocs), ' candidate documents.'))"/>
        
        <xsl:for-each select="$teiDocs/TEI">
            <xsl:variable name="currId" select="@xml:id"/>
            <xsl:result-document href="{concat($outputFolder, '/', $currId, '.html')}">
                <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;
            </xsl:text>
                <html lang="en" xmlns="http://www.w3.org/1999/xhtml" id="{$currId}">
                    <xsl:apply-templates>
                        <xsl:with-param name="currId" select="$currId" tunnel="yes"/>
                    </xsl:apply-templates>
                </html>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>