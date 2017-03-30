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
            <xd:p><xd:b>Created on:</xd:b> March 30, 2017.</xd:p>
            <xd:p><xd:b>Author:</xd:b> <xd:a href="pers:HOLM3">mholmes</xd:a></xd:p>
            <xd:p>
                This file processes all items in the project which have an 
                @xml:id attribute and lists them in a table.
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
        <xd:desc>The complete set of XML documents found in the data folder.</xd:desc>
    </xd:doc>
    <xsl:variable name="xmlDocs" select="collection(concat($projectRoot, '/data/?select=*.xml;recurse=yes'))"/>
    
    <xd:doc scope="component">
        <xd:desc>The items we're going to list. We don't include surface elements because there
        are lots of them and their ids are derived rather than assigned; and we ignore notes
        because they're purely local.</xd:desc>
    </xd:doc>
    <xsl:variable name="itemsWithIds" select="$xmlDocs//*[not(self::surface or self::note)][@xml:id]"/>
    
    <xd:doc>
        <xd:desc>The root template builds the output document directly.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="outDoc">
            <!--<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;
            </xsl:text>-->
            <html lang="en" xmlns="http://www.w3.org/1999/xhtml" id="a_to_z">
                <head>
                    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                    <title>Project A to Z</title>
                    <link href="https://fonts.googleapis.com/css?family=Merriweather" rel="stylesheet" />
                    <link rel="stylesheet" type="text/css" href="css/html.css" />
                    <script type="text/ecmascript" src="js/script.js"></script>
                    <script type="text/ecmascript" src="js/sorttable.js"></script>
                </head>
                
                
                <body>
                    
                    <h1><span data-el="title">Project A to Z</span></h1>
                    <div class="body">
                        <table class="sortable">
                            <thead>
                                <tr>
                                    <th class="SortHeader" style="width: 10%">@xml:id</th>
                                    <th class="SortHeader" style="width: 20%;">Type</th>
                                    <th class="SortHeader" style="width: 70%;">Details</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="$itemsWithIds">
                                    <xsl:sort select="upper-case(@xml:id)"/>
                                    <tr>
                                        <td><xsl:value-of select="@xml:id"/></td>
                                        <td>
                                            <xsl:choose>
                                                <xsl:when test="local-name() = 'person'">Person</xsl:when>
                                                <xsl:when test="local-name() = 'TEI'">Document</xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="local-name(.)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </td>
                                        <td>
                                            <xsl:choose>
                                                <xsl:when test="local-name() = 'person'"><xsl:value-of select="persName"/></xsl:when>
                                                <xsl:when test="local-name() = 'TEI'"><xsl:value-of select="teiHeader/fileDesc/titleStmt/title"/></xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:variable name="content" select="normalize-space(.)"/>
                                                    <xsl:value-of select="substring($content, 1, 100)"/><xsl:if test="string-length($content) gt 100">...</xsl:if>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                    </div>
                </body>
            </html>
        </xsl:variable>
        <xsl:result-document href="{concat($outputFolder, '/', 'a_to_z.htm')}">
            <xsl:sequence select="$outDoc"/>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>