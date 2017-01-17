<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xh="http://www.w3.org/1999/xhtml"
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
    
    <xsl:variable name="linkedResources">
        <!--    Links to CSS and JS.      -->
        <!--    Starting with a Google font embed, just because. Design comes later.        -->
        <link href="https://fonts.googleapis.com/css?family=Merriweather" rel="stylesheet"/> 
        <link rel="stylesheet" type="text/css" href="css/html.css"/>
        <script type="text/ecmascript" src="js/script.js"/> 
    </xsl:variable>
   
   <xd:doc>
       <xd:desc>The teiHeader is used as a trigger to create the HTML head element.</xd:desc>
   </xd:doc>
    <xsl:template match="teiHeader">
        <head>
            <title><xsl:value-of select="fileDesc/titleStmt/title[1]"/></title>
            
<!--        Include linked stylesheets and JS.    -->
            <xsl:sequence select="$linkedResources"/>
            
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
        <xd:desc>For now, we suppress the facsimile element. We may use it later.</xd:desc>
    </xd:doc>
    <xsl:template match="facsimile"/>
    
    <xd:doc>
        <xd:desc>The text element template paradoxically starts by generating 
        a bunch of data from the teiHeader; since these debate-days are extracts
        from larger source documents, there's no meaningful intro/metadata in 
        the document.</xd:desc>
    </xd:doc>
    <xsl:template match="text">
        <xsl:param name="currId" as="xs:string" tunnel="yes"/>
        <body>
            <xsl:call-template name="header"/>
            <xsl:call-template name="nav"/>
            <h1><xsl:apply-templates select="preceding-sibling::teiHeader[1]/fileDesc/titleStmt/title[1]"/></h1>
            
            <div class="body">
                <xsl:choose>
                    <xsl:when test="$currId = 'personography'">
                        <xsl:apply-templates select="ancestor::TEI//particDesc"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
                    
                <xsl:call-template name="appendix"/>
            </div>
            <xsl:call-template name="footer"/>
        </body>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>This template creates an appendix for the document containing
        lists of all linked resources such as people.</xd:desc>
    </xd:doc>
    <xsl:template name="appendix">
        <div class="appendix">
            <xsl:if test="//text/descendant::persName[@ref]">
                <h3><xsl:sequence select="$peopleCaption"/></h3>
                <ul>
                    <xsl:variable name="persIds" select="distinct-values(//text/descendant::persName/@ref/substring-after(normalize-space(.), 'pers:'))"/>
                    <xsl:for-each select="$teiDocs/TEI[@xml:id='personography']//person[@xml:id = $persIds]">
                        <xsl:sort select="string-join(persName, ' ')"/>
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                </ul>
            </xsl:if>
        </div>
        
<!--    This is the popup used to display information from the appendix if scripting
        is active. -->
        <div id="infoPopup" style="display: none;">
            <div class="popupCloser" onclick="this.parentNode.style.display = 'none';">x</div>
            <div id="infoContent"></div>
        </div>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>This template matches a range of different block elements. We convert them
        into HTML5 divs, distinguished by their source element name.</xd:desc>
    </xd:doc>
    <xsl:template match="div | p | ab | fw | pb | cb | quote[@rendition='tccd:blockquote']">
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
        <xd:desc>The persName element becomes a link to a bio entry we presume 
                 is part of the file. It's processed differently if it's part 
                 of the personography.</xd:desc>
    </xd:doc>
    <xsl:template match="persName[not(ancestor::person)]">
        <a href="#{substring-after(@ref, 'pers:')}" data-el="persName">
            <xsl:apply-templates select="@*|node()"/>
        </a>
    </xsl:template>
    <xsl:template match="persName[ancestor::person]">
        <span data-el="persName">
            <xsl:apply-templates select="@*|node()"/>
        </span>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Sometimes commas are included in names, and sometimes not.
                 Might as well allow for this graciously, although we 
                 could constrain it with Schematron.</xd:desc>
    </xd:doc>
    <xsl:template match="text()[preceding-sibling::*[1][self::surname] and following-sibling::forename]">
        <xsl:if test="not(contains(., ','))"><xsl:text>,</xsl:text></xsl:if>
        <xsl:value-of select="."/>
    </xsl:template>
   
    
    <xd:doc scope="component">
        <xd:desc>The personography needs special handling.</xd:desc>
    </xd:doc>
    <xsl:template match="particDesc">
        <div data-el="particDesc">
            <xsl:apply-templates select="@*|node()"/>
        </div>
    </xsl:template>
    <xsl:template match="listPerson">
        <xsl:apply-templates select="head"/>
        <ul data-el="listPerson">
            <xsl:apply-templates select="@*|node()[not(self::head)]"/>
        </ul>
    </xsl:template>
    <xsl:template match="listPerson/head | list/head">
        <xsl:element name="h{count(ancestor::listPerson|ancestor::div) + 1}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="listPerson/person">
        <li>
            <xsl:variable name="link" select="concat('pers:', @xml:id)"/>
            <xsl:apply-templates select="@*|node()"/>
            
            <xsl:if test="parent::listPerson/@xml:id = 'historicalPersonography'">
                
                <xsl:sequence select="$nameAppearanceCaption"/>
                <xsl:value-of select="count($teiDocs//persName[@ref=$link])"/>
                
                <xsl:if test="$teiDocs/TEI[text/descendant::persName[@ref=$link]]">
                    <ul class="docsMentioningPerson">
                        <xsl:for-each select="$teiDocs/TEI[text/descendant::persName[@ref=$link]]">
                            <li><a href="{@xml:id}.html"><xsl:value-of select="//titleStmt/title[1]"/></a></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
            </xsl:if>
            
            
        </li>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>The person/affiliation element is complex; it's going to need 
            some elaboration and linking once we know how the riding information is
            going to work.</xd:desc>
    </xd:doc>
    <xsl:template match="person/affiliation[not(preceding-sibling::affiliation)]">
        <ul>
            <li>
                <xsl:apply-templates select="node()"/>
                <xsl:apply-templates select="@*"/>
            </li>
            <xsl:apply-templates select="following-sibling::affiliation">
                <xsl:with-param name="inList" select="true()" tunnel="yes"/>
            </xsl:apply-templates>
        </ul>
    </xsl:template>
    <xsl:template match="person/affiliation[preceding-sibling::affiliation]">
        <xsl:param name="inList" select="false()" tunnel="yes"/>
        <xsl:if test="$inList = true()">
            <li>
                <xsl:apply-templates select="node()"/>
                <xsl:apply-templates select="@*"/>
            </li>
        </xsl:if>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>We process the attributes of affiliation elements into actual output.</xd:desc>
    </xd:doc>
    <xsl:template match="affiliation/@when">
        <xsl:text> (</xsl:text><xsl:value-of select="."/>
        <xsl:if test="parent::affiliation/@n"><xsl:text>: </xsl:text><xsl:value-of select="parent::affiliation/@n"/></xsl:if>
        <xsl:text>)</xsl:text>
    </xsl:template>
    <xsl:template match="affiliation/@n"/>
    
    <xd:doc scope="component">
        <xd:desc>hi elements are used for typographical features.</xd:desc>
    </xd:doc>
    <xsl:template match="hi">
        <span>
            <xsl:apply-templates select="@*|node()"/>
        </span>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>These templates match TEI attributes and produce equivalent 
        XHTML5 attributes.</xd:desc>
    </xd:doc>
    <xsl:template match="@xml:id">
        <xsl:attribute name="id" select="."/>
    </xsl:template>
    <xsl:template match="@rendition">
        <xsl:attribute name="class" select="normalize-space(replace(replace(., '#', ''), '((^|\s)[^:]+):', '$1_'))"/>
    </xsl:template>
    <xsl:template match="@type">
        <xsl:attribute name="data-type" select="."/>
    </xsl:template>
    <xsl:template match="@style">
        <xsl:attribute name="style" select="."/>
    </xsl:template>
    <xsl:template match="persName/@when">
        <xsl:attribute name="data-when" select="."/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Attribute templates which suppress output.</xd:desc>
    </xd:doc>
    <xsl:template match="@n | @facs | @ref"/>
    
<!-- Named templates for page-structure components..   -->
    <xd:doc scope="component">
        <xd:desc>The header template creates the document banner for all pages.</xd:desc>
    </xd:doc>
    <xsl:template name="header">
        <header>
            <div class="langSwitcher">
                <a href="javascript:switchLang('en')">EN</a>
                <a href="javascript:switchLang('fr')">FR</a>
            </div>
            <a href="index.html">
                <img lang="en" src="images/eng-logo.svg" alt="{$projectTitle/xh:span[@lang='en']}" class="siteLogo"/>
                <img lang="fr" src="images/fr-logo.svg" alt="{$projectTitle/xh:span[@lang='fr']}" class="siteLogo"/>
            </a>
        </header>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>The nav template creates the site navigation for all pages.</xd:desc>
    </xd:doc>
    <xsl:template name="nav">
        <nav>
            
        </nav>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>The footer template creates the document footer for all pages.</xd:desc>
    </xd:doc>
    <xsl:template name="footer">
        <footer>
            
            <div class="version">
                <xsl:sequence select="$buildDateCaption"/> <xsl:value-of select="$buildDate"/><xsl:text>. </xsl:text>
                <xsl:sequence select="$buildVersionCaption"/> <a href="{concat($gitRevUrl, $gitRevision)}"><xsl:value-of select="substring($gitRevision, 1, 8)"/></a><xsl:text>.</xsl:text>
            </div>
        </footer>
    </xsl:template>
    
</xsl:stylesheet>