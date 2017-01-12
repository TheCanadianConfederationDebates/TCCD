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
                This module contains standard templates for processing TEI elements
                into XHTML5.
            </xd:p>
        </xd:desc>
    </xd:doc>
   
   <xd:doc>
       <xd:desc>The teiHeader is used as a trigger to create the HTML head element.</xd:desc>
   </xd:doc>
    <xsl:template match="teiHeader">
        <head>
            <title><xsl:value-of select="fileDesc/titleStmt/title[1]"/></title>
<!--    Links to CSS and JS; the files do not yet exist.        -->
            <link rel="stylesheet" type="text/css" href="css/html.css"/>
            <script type="text/ecmascript" src="js/script.js"/> 
            
<!--        If there are rendition elements, let them appear here.    -->
            <xsl:if test="descendant::rendition">
                <style type="text/css">
                    <xsl:comment>
                        <xsl:for-each select="descendant::rendition">
                            <xsl:value-of select="concat('&#x0a;', @xml:id, '{', ., '}&#x0a;')"/>
                        </xsl:for-each>
                    </xsl:comment>
                </style>
            </xsl:if>
            
<!--    Lots of Dublin Core metadata goes here.        -->
        </head>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The text element template paradoxically starts by generating 
        a bunch of data from the teiHeader; since these debate-days are extracts
        from larger source documents, there's no meaningful intro/metadata in 
        the document.</xd:desc>
    </xd:doc>
    <xsl:template match="text">
        <body>
<!--           Here there will be banner stuff. -->
            <h1><xsl:apply-templates select="preceding-sibling::teiHeader[1]/fileDesc/titleStmt/title[1]"/></h1>
            
            <xsl:apply-templates/>
        </body>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>This template matches a range of different block elements. We convert them
        into HTML5 divs, distinguished by their source element name.</xd:desc>
    </xd:doc>
    <xsl:template match="div | p | ab | fw | pb | cb">
        <div data-el="{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </div>
    </xsl:template>
    
    <xsl:template match="div/head">
        <xsl:element name="h{count(ancestor::div) + 1}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>These templates match TEI attributes and produce equivalent 
        XHTML5 attributes.</xd:desc>
    </xd:doc>
    <xsl:template match="@xml:id">
        <xsl:attribute name="id" select="."/>
    </xsl:template>
    <xsl:template match="@rendition">
        <xsl:attribute name="class" select="normalize-space(replace(., '#', ''))"/>
    </xsl:template>
    <xsl:template match="@type">
        <xsl:attribute name="data-type" select="."/>
    </xsl:template>
    <xsl:template match="@style">
        <xsl:attribute name="style" select="."/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Attribute templates which suppress output.</xd:desc>
    </xd:doc>
    <xsl:template match="@n | @facs"/>
    
</xsl:stylesheet>