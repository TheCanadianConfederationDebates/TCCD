<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="2.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> October 5, 2017.</xd:p>
            <xd:p><xd:b>Author:</xd:b> <xd:a href="pers:HOLM3">mholmes</xd:a></xd:p>
            <xd:p>
                This master file handles the transformation our bilingual HTML documents
                into two separate language collections in French and English. This involves
                <xd:ul>
                    <xd:li>discarding elements with @xml:lang in the other language</xd:li>
                    <xd:li>adding language-switching links to each page, pointing at the
                           equivalent page in the other language</xd:li>
                    <xd:li>Massaging the document indexes such that when the original document
                           is available in both languages, the version in the target language
                           is kept and the other removed.</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc scope="component">
        <xd:desc>Output is XHTML5; doctype is handled with hard-coded text.</xd:desc>
    </xd:doc>
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes" normalization-form="NFC"
        exclude-result-prefixes="#all" omit-xml-declaration="yes"/>
    
    <xd:doc scope="component">
        <xd:desc>For testing purposes, we want to be able to call this transformation
                 passing in a single XHTML document, but in the general use case, we
                 will set the XSLT library itself as the input, in which case the whole
                 set of HTML files will be processed.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="html">
<!-- We have a single input document. -->
                
            </xsl:when>
            <xsl:otherwise>
<!-- The input document is this file itself, therefore we process everything. -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>