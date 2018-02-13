<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="3.0">
    
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
    <xsl:include href="tei_to_html_captions_module.xsl"/>
    <xsl:include href="tei_to_html_globals_module.xsl"/>
    
    <xd:doc>
        <xd:desc>The root template simply invokes a named template in 
        the docs module, which figures out what to process.</xd:desc>
    </xd:doc>
    <xsl:template match="xsl:stylesheet">
        <xsl:call-template name="allDocs"/>
    </xsl:template>
    
</xsl:stylesheet>