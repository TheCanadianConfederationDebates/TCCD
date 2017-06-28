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
                This master file handles the transformation of entities such as people
                and places into XHTML5 AJAX fragments for the website.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc scope="component">
        <xd:desc>The output method is XHTML (because we want long-term processability)
        but we will conform to HTML5 and validate with the vnu validator. </xd:desc>
    </xd:doc>
    <xsl:output method="xml" encoding="UTF-8" indent="yes" normalization-form="NFC"
        exclude-result-prefixes="#all" omit-xml-declaration="yes"/>
    
    <xd:doc scope="component">
        <xd:desc>Linked modules which do all the actual processing.</xd:desc>
    </xd:doc>
    <xsl:include href="tei_to_html_templates_module.xsl"/>
    <xsl:include href="tei_to_html_functions_module.xsl"/>
    <xsl:include href="tei_to_html_captions_module.xsl"/>
    <xsl:include href="tei_to_html_globals_module.xsl"/>
    
    <xd:doc>
        <xd:desc>The root template simply invokes a named template in 
        the docs module, which figures out what to process.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:call-template name="createAjaxFragments"/>
    </xsl:template>
    
    
    <!--   This template creates a set of fragments (XHTML5 divs) for all of the 
       entities such as people and places in the project. -->
    <xd:doc scope="component">
        <xd:desc>This template creates AJAX fragments (XHTML5 divs) for all of the
            entities such as people and places in the project. These may be pulled into 
            other files, or called up on the website from (for instance) the map.</xd:desc>
    </xd:doc>
    <xsl:template name="createAjaxFragments">
        <xsl:sequence select="hcmc:message(concat('Creating AJAX fragments from ', count($teiDocs/TEI[@xml:id='personography']//person), ' people and ', count($teiDocs/TEI[@xml:id='placeography']//place), ' places.'))"/>
        <xsl:for-each select="$teiDocs/TEI[@xml:id='personography']//person | $teiDocs/TEI[@xml:id='placeography']//place">
            <xsl:result-document href="{concat($outputFolder, '/ajax/', @xml:id, '.xml')}">
                <div id="{@xml:id}">
                    <xsl:apply-templates select="node()"/>
                    <xsl:if test="parent::listPerson/@xml:id = 'historicalPersonography'">
                        <xsl:variable name="link" select="concat('pers:', @xml:id)"/>
                        <xsl:variable name="instances" select="$teiDocs/TEI[text/descendant::persName[@ref=$link]]"/>
                        <xsl:message>Found <xsl:value-of select="count($instances)"/> documents linking to <xsl:value-of select="$link"/></xsl:message>
                        <xsl:sequence select="$nameAppearanceCaption"/>
                        <xsl:value-of select="count($instances)"/>
                        <xsl:if test="count($instances) gt 0">
                            <xsl:variable name="docListId" select="concat(@xml:id, '_docList')"/>
                            <h5 class="closedDocCaption" onclick="switchExpanderClass(this)"><xsl:sequence select="$debatesDocumentsCaption"/></h5>
                            <ul class="docsMentioningPerson">
                                <xsl:for-each-group select="$instances" group-by="tokenize(@xml:id, '(_fr)?_\d')[1]">
                                    <xsl:variable name="legCaption" select="$projectTaxonomies//category[@xml:id=current-grouping-key()]/gloss"/>
                                    <h6 class="closedDocCaption" onclick="switchExpanderClass(this)"><xsl:apply-templates select="$legCaption/node()"/></h6>
                                    <ul>
                                        <xsl:for-each select="current-group()">
                                            <li><a href="{@xml:id}.html"><xsl:value-of select="//titleStmt/title[1]"/></a></li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:for-each-group>
                                
                            
                                
                                <!--<xsl:for-each select="$instances">
                                    <li><a href="{@xml:id}.html"><xsl:value-of select="//titleStmt/title[1]"/></a></li>
                                </xsl:for-each>-->
                                
                                
                            </ul>
                        </xsl:if>
                    </xsl:if>
                </div>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>