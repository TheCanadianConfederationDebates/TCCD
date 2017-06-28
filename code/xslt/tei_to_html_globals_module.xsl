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
            <xd:p><xd:b>Created on:</xd:b> June 7, 2017.</xd:p>
            <xd:p><xd:b>Author:</xd:b> <xd:a href="pers:HOLM3">mholmes</xd:a></xd:p>
            <xd:p>
                This module contains globals used in multiple transformations.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc scope="component">
        <xd:desc>Project base folder, relative to which other resources will be found.
        We make it a parameter so that if we want to, we can process another collection
        of documents outside the current tree (so for example if this code is being 
        developed on a separate branch, but we want to process an up-to-date checkout
        of data from the master branch).</xd:desc>
    </xd:doc>
    <xsl:param name="projectRoot" select="concat(replace(document-uri(/), concat(tokenize(document-uri(/), '/')[last()], '$'), ''), '../../')"/>
    
    <xd:doc scope="component">
        <xd:desc>The outputFolder param defaults to an HTML folder in the project root, but of course
        can be overridden as required.</xd:desc>
    </xd:doc>
    <xsl:param name="outputFolder" select="concat($projectRoot, '/html')"/>
    
    <xd:doc scope="component">
        <xd:desc>The build date in yyyy-mm-dd format, defaulting to today.</xd:desc>
    </xd:doc>
    <xsl:param name="buildDate" as="xs:string" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
    
    <xd:doc>
        <xd:desc>Long form of last git commit is passed in by ant.</xd:desc>
    </xd:doc>
    <xsl:param name="gitRevision" as="xs:string" select="''"/>
    
    <xd:doc>
        <xd:desc>Prefix for links to GitHub commits.</xd:desc>
    </xd:doc>
    <xsl:param name="gitRevUrl" select="'https://github.com/TheCanadianConfederationDebates/TCCD/commit/'"/>
    
    <xd:doc scope="component">
        <xd:desc>Variable containing location of data directories where the XML files
        will be found.</xd:desc>
    </xd:doc>
    <xsl:variable name="projectData" select="concat($projectRoot, 'data/')"/>
    
    <xd:doc scope="component">
        <xd:desc>The complete set of XML documents found in the data folder.</xd:desc>
    </xd:doc>
    <xsl:variable name="xmlDocs" select="collection(concat($projectData, '/?select=*.xml;recurse=yes'))"/>
    
    <xd:doc scope="component">
        <xd:desc>The subset of xmlDocs that we want to actually process (excluding templates etc.).</xd:desc>
    </xd:doc>
    <xsl:variable name="teiDocs" select="$xmlDocs[TEI[text/descendant::persName[@ref[. != 'UNSPECIFIED']] or @xml:id=('personography', 'bibliography', 'placeography')][not(@xml:id='debate')]]"/>
    
    <xd:doc scope="component">
        <xd:desc>The project ODD file, from which we harvest information from 
                 taxonomies.</xd:desc>
    </xd:doc>
    <xsl:variable name="projectOdd" select="doc(concat($projectRoot, 'data/schemas/tccd.odd'))"/>
    
    <xd:doc scope="component">
        <xd:desc>The project taxonomies file, from which has some things we
            use for captions etc. in it.</xd:desc>
    </xd:doc>
    <xsl:variable name="projectTaxonomies" select="doc(concat($projectRoot, 'data/schemas/taxonomies.xml'))"/>
    
</xsl:stylesheet>