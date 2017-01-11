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
        <xd:desc>The base template, allDocs, finds all the XML files and processes
        them as required to produce output in XHTML5.</xd:desc>
    </xd:doc>
    <xsl:template name="allDocs">
        <xsl:sequence select="hcmc:message(concat('Processing documents in ', $projectData))"/>
        <xsl:sequence select="hcmc:message(concat('Found ', count($xmlDocs[TEI]), ' candidate documents.'))"/>
    </xsl:template>
    
</xsl:stylesheet>