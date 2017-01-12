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
            <xd:p><xd:b>Created on:</xd:b> January 12, 2017.</xd:p>
            <xd:p><xd:b>Author:</xd:b> <xd:a href="pers:HOLM3">mholmes</xd:a></xd:p>
            <xd:p>
                This module contains multilingual captions used in the generation of XHTML5 
                documents from TEI XML.
            </xd:p>
        </xd:desc>
    </xd:doc>
   
    <xd:doc>
        <xd:desc>Build date information in the footer.</xd:desc>
    </xd:doc>
    <xsl:variable name="buildDateCaption">
        <span lang="en">Build date: </span>
        <span lang="fr">Date de construction: </span>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Build version information in the footer.</xd:desc>
    </xd:doc>
    <xsl:variable name="buildVersionCaption">
        <span lang="en">Commit: </span>
        <span lang="fr">Commit: </span>
    </xsl:variable>
    
</xsl:stylesheet>