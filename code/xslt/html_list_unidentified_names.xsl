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
            <xd:p><xd:b>Created on:</xd:b> March 14, 2017.</xd:p>
            <xd:p><xd:b>Author:</xd:b> <xd:a href="pers:HOLM3">mholmes</xd:a></xd:p>
            <xd:p>
                This file processes the web content to create a page listing all the 
                names which have not been identified.
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
        <xd:desc>The complete set of HTML documents found in the HTML folder.</xd:desc>
    </xd:doc>
    <xsl:variable name="htmlDocs" select="collection(concat($outputFolder, '/?select=*.html;recurse=no'))"/>
    
    <xd:doc scope="component">
        <xd:desc>The names we're going to list.</xd:desc>
    </xd:doc>
    <xsl:variable name="unidentifiedNames" select="$htmlDocs/html[not(@id='unidentified_names')]//span[@class='unidentifiedName']"/>
    
    <xd:doc>
        <xd:desc>The root template builds the output document directly.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="outDoc">
            <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;
</xsl:text>
            <html lang="en" xmlns="http://www.w3.org/1999/xhtml" id="unidentified_names">
                <head>
                    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                    <title>Unidentified names</title>
                    <link href="https://fonts.googleapis.com/css?family=Merriweather" rel="stylesheet" />
                    <link rel="stylesheet" type="text/css" href="css/html.css" /><script type="text/ecmascript" src="js/script.js"></script>
                </head>
                
                
                <body>
                    
                    <h1><span data-el="title">Unidentified Names</span></h1>
                    <div class="body">
                        <ul>
                            <xsl:for-each select="$unidentifiedNames">
                                <li><a href="{ancestor::html/@id}.html#{@id}"><xsl:value-of select="."/></a> (<xsl:value-of select="ancestor::html/head/title"/>)</li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </body>
            </html>
        </xsl:variable>
        <xsl:result-document href="{concat($outputFolder, '/', 'unidentified_names.htm')}">
            <xsl:sequence select="$outDoc"/>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>