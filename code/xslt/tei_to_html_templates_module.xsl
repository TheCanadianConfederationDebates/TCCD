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
                    <xsl:when test="$currId = 'placeography'">
                        <xsl:apply-templates select="ancestor::TEI//settingDesc"/>
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
                <div id="individualsNamed">
                    <h3><xsl:sequence select="$peopleCaption"/></h3>
                    <ul data-el="listPerson">
                        <xsl:variable name="persIds" select="distinct-values(//text/descendant::persName/@ref/substring-after(normalize-space(.), 'pers:'))"/>
                        <xsl:for-each select="$teiDocs/TEI[@xml:id='personography']//person[@xml:id = $persIds]">
                            <xsl:sort select="string-join(persName, ' ')"/>
                            <li id="{@xml:id}">
                                <xsl:sequence select="doc(concat($outputFolder, '/ajax/', @xml:id, '.xml'))/xh:div/node()"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>
        </div>
        
<!--    This is the popup used to display information from the appendix if scripting
        is active. -->
        <div id="infoPopup" style="display: none;">
            <div class="popupCloser" onclick="this.parentNode.style.display = 'none';">x</div>
            <div id="infoHeader">&#160;</div>
            <div id="infoContent"></div>
        </div>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>This template matches a range of different block elements. We convert them
        into HTML5 divs, distinguished by their source element name.</xd:desc>
    </xd:doc>
    <xsl:template match="div | p | ab | fw | pb | cb | quote[@rendition='tccd:blockquote'] | lg | l">
        <div data-el="{local-name()}">
            <xsl:if test="self::p and matches(., '^[\s\*]+$')">
                <xsl:attribute name="class">asterism</xsl:attribute>
            </xsl:if>
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
    <xsl:template match="persName[not(ancestor::person) and starts-with(@ref, 'pers:')]">
        <a href="#{substring-after(@ref, 'pers:')}" data-el="persName">
            <xsl:if test="@ref='UNSPECIFIED'">
                <xsl:attribute name="class" select="'unidentifiedName'"/>
                <xsl:attribute name="id" select="generate-id(.)"/>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </a>
    </xsl:template>
    <xsl:template match="persName[not(ancestor::person) and matches(@ref, 'UNSPECIFIED')]">
        <span data-el="persName" class="unidentifiedName" id="{generate-id(.)}">
            <xsl:apply-templates select="@*|node()"/>
        </span>
    </xsl:template>
    <xsl:template match="persName[ancestor::person]">
        <span data-el="{local-name()}">
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
        <xd:desc>The personography and placeography needs special handling.</xd:desc>
    </xd:doc>
    <xsl:template match="particDesc | settingDesc">
        <div data-el="{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </div>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Lists are all processed in a similar way. More types may be added.</xd:desc>
    </xd:doc>
    <xsl:template match="listPerson | listBibl | list | listPlace">
        <xsl:apply-templates select="head"/>
        <ul data-el="{local-name()}">
            <xsl:apply-templates select="@*|node()[not(self::head)]"/>
        </ul>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Lists may contain head elements; these are processed before 
            the list itself.</xd:desc>
    </xd:doc>
    <xsl:template match="listPerson/head | list/head | listBibl/head">
        <xsl:variable name="locName" select="local-name()"/>
        <xsl:element name="h{count(ancestor::*[local-name(.) = $locName]|ancestor::div) + 1}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>List items, listBibl items and so on are just processed 
            in the same way (for the moment). The person element has a 
            separate template.</xd:desc>
    </xd:doc>
    <xsl:template match="listBibl/bibl | list/item">
        <li>
            <xsl:apply-templates select="@*|node()"/>
        </li>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>The person element needs its own processing.</xd:desc>
    </xd:doc>
    <xsl:template match="listPerson/person">
        <li title="pers:{@xml:id}">
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
        <xd:desc>The place element needs its own processing.</xd:desc>
    </xd:doc>
    <xsl:template match="listPlace/place">
        <li title="plc:{@xml:id}">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    
    
    <xd:doc scope="component">
        <xd:desc>The placeName element in the context of a place element
            is turned into a comma-separated sequence of components.</xd:desc>
    </xd:doc>
    <xsl:template match="listPlace/place/placeName">
        <span class="{local-name()}"><xsl:value-of select="string-join((for $c in * return normalize-space($c)), ', ')"/></span>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>The locations in the placeography are output as links to the map.</xd:desc>
    </xd:doc>
    <xsl:template match="listPlace/place/location">
        <span class="{local-name()}">
            <xsl:if test="string-length(normalize-space(geo)) gt 0">
            <a href="map.html?place={ancestor::place[1]/@xml:id}"><xsl:value-of select="geo"/></a>
            </xsl:if>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="if (@notBefore) then @notBefore else ''"/>
            <xsl:if test="@notBefore or @notAfter"><xsl:text>-</xsl:text></xsl:if>
            <xsl:value-of select="if (@notAfter) then @notAfter else ''"/>
            <xsl:text>)</xsl:text>
        </span>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>The note element in places currently has pointless stuff in
        it, which we suppress.</xd:desc>
    </xd:doc>
    <xsl:template match="listPlace/place/note">
        <xsl:apply-templates select="node()[not(self::list)]"/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>This is a set of inline elements which are all processed in 
            a similar way. hi elements, for instance, are used for typographical 
            features; title elements for titles. Both are styled using the 
            combination of their attributes as transferred to the HTML5 output
            span.</xd:desc>
    </xd:doc>
    <xsl:template match="hi | title">
        <span data-el="{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </span>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Handler for the ref element used to encode links.</xd:desc>
    </xd:doc>
    <xsl:template match="ref[@target]">
        <a><xsl:apply-templates select="@* | node()"/></a>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Handler for the lb elements which are breaking: add space.</xd:desc>
    </xd:doc>
    <xsl:template match="lb[not(@break='no')]">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Handler for the ptr element used to encode links.</xd:desc>
    </xd:doc>
    <xsl:template match="ptr[not(contains(@target, 'biographi.ca')) or not(ancestor::person)]">
        <a><xsl:apply-templates select="@*"/><xsl:value-of select="substring-before(substring-after(@target, '//'), '/')"/></a>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Special handler for the ptr element used to encode links in personography
            entries, when it points to biographi.ca.</xd:desc>
    </xd:doc>
    <xsl:template match="ptr[@target[contains(., 'biographi.ca')]][ancestor::person]">
        <a class="linkLogo"><xsl:apply-templates select="@*"/><img src="images/dcb.jpg" alt="{substring-before(substring-after(@target, '//'), '/')}" target="{substring-before(substring-after(@target, '//'), '/')}"/></a>
    </xsl:template>
    
    <!--  ####### Begin table-handling templates. #######  -->
    <xd:doc scope="component">
        <xd:desc>Template for handling table.</xd:desc>
    </xd:doc>
    <xsl:template match="table">
        <div class="tableContainer">
            <div class="tablePadding">
                <table>
                    <xsl:apply-templates select="@* | node()"/>
                </table>
            </div>
        </div>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Table rows become trs.</xd:desc>
    </xd:doc>
    <xsl:template match="row">
        <tr>
            <xsl:apply-templates select="@* | node()"/>
        </tr>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Table cells become tds.</xd:desc>
    </xd:doc>
    <xsl:template match="cell">
        <td>
            <xsl:apply-templates select="@* | node()"/>
        </td>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>@role on cells or rows is supported for label.</xd:desc>
    </xd:doc>
    <xsl:template match="cell/@role | row/@role">
        <xsl:attribute name="class" select="."/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>@rows attribute because @rowspan.</xd:desc>
    </xd:doc>
    <xsl:template match="cell/@rows | row/@rows">
        <xsl:attribute name="rowspan" select="."/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>@cols attribute because @colspan.</xd:desc>
    </xd:doc>
    <xsl:template match="cell/@cols | row/@cols">
        <xsl:attribute name="colspan" select="."/>
    </xsl:template>
    
    <!--  ####### End table-handling templates. #######  -->
    
    <xd:doc scope="component">
        <xd:desc>These templates match TEI attributes and produce equivalent 
        XHTML5 attributes.</xd:desc>
    </xd:doc>
    <xsl:template match="@xml:id">
        <xsl:attribute name="id" select="."/>
    </xsl:template>
    <xsl:template match="@xml:lang">
        <xsl:attribute name="lang" select="."/>
        <xsl:attribute name="xml:lang" select="."/>
    </xsl:template>
    <xsl:template match="@target">
        <xsl:attribute name="href" select="."/>
    </xsl:template>
    <xsl:template match="@rendition">
        <xsl:attribute name="class" select="normalize-space(replace(replace(., '#', ''), '((^|\s)[^:]+):', '$1_'))"/>
    </xsl:template>
    <xsl:template match="@type">
        <xsl:attribute name="data-type" select="."/>
    </xsl:template>
    <xsl:template match="@level">
        <xsl:attribute name="data-level" select="."/>
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
    
    <xd:doc scope="component">
        <xd:desc>Some comments identify specific things which need to be flagged in the output.</xd:desc>
    </xd:doc>
    <xsl:template match="comment()[matches(., 'untaggedTable')]">
        <span class="untaggedTable">
            <span lang="en">A table appears here, but it has not yet been encoded so cannot be 
            displayed.</span>
            <span lang="fr">Un tableau apparaît ici, mais il n'a pas encore été encodé et ne 
                peut donc pas être affiché.</span>
        </span>
    </xsl:template>
    
</xsl:stylesheet>