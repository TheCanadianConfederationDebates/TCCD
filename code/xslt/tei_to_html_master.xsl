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
                This master file handles the transformation of all our TEI XML documents
                into a standalone website in XHTML5.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc scope="component">
        <xd:desc>The output method is XHTML (because we want long-term processability)
        but we will conform to HTML5 and validate with the vnu validator. The empty
        DOCTYPE declaration will be inserted as unescaped CDATA when a document is
        created.</xd:desc>
    </xd:doc>
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes" normalization-form="NFC"
        exclude-result-prefixes="#all" omit-xml-declaration="yes"/>
    
    <xd:doc scope="component">
        <xd:desc>Linked modules which do all the actual processing.</xd:desc>
    </xd:doc>
    <xsl:include href="tei_to_html_docs_module.xsl"/>
    <xsl:include href="tei_to_html_templates_module.xsl"/>
    <xsl:include href="tei_to_html_functions_module.xsl"/>
    
    <xd:doc scope="component">
        <xd:desc>Project base folder, relative to which other resources will be found.
        We make it a parameter so that if we want to, we can process another collection
        of documents outside the current tree (so for example if this code is being 
        developed on a separate branch, but we want to process an up-to-date checkout
        of data from the master branch).</xd:desc>
    </xd:doc>
    <xsl:param name="projectRoot" select="concat(replace(document-uri(/), concat(tokenize(document-uri(/), '/')[last()], '$'), ''), '../../')"/>
    
    
    <xd:doc scope="component">
        <xd:desc>Variable containing location of data directories where the XML files
        will be found.</xd:desc>
    </xd:doc>
    <xsl:variable name="projectData" select="concat($projectRoot, 'data/')"/>
    
    <xd:doc scope="component">
        <xd:desc>The complete set of XML documents found in the data folder.</xd:desc>
    </xd:doc>
    <xsl:variable name="xmlDocs" select="collection(concat($projectData, '/?select=*.xml;recurse=yes'))"/>
    
    <xd:doc>
        <xd:desc>The root template simply invokes a named template in 
        the docs module, which figures out what to process.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:call-template name="allDocs"/>
    </xsl:template>
    
</xsl:stylesheet>