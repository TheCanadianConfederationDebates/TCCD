<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xh="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="3.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> January 11, 2017.</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b>
                <xd:a href="pers:HOLM3">mholmes</xd:a>
            </xd:p>
            <xd:p> This module contains standard templates for processing TEI elements into XHTML5.
            </xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:variable name="linkedResources">
        <!--    Links to CSS and JS.      -->
        <!--    Starting with a Google font embed, just because. Design comes later.        -->
        <link href="https://fonts.googleapis.com/css?family=Merriweather" rel="stylesheet"/>
        <link rel="stylesheet" type="text/css" href="css/html.css"/>
        <script type="text/ecmascript" src="js/script.js"/>
        <script type="text/ecmascript" src="js/utilities.js"/>
    </xsl:variable>

    <xd:doc>
        <xd:desc>The teiHeader is used as a trigger to create the HTML head element.</xd:desc>
    </xd:doc>
    <xsl:template match="teiHeader">
        <head>
            <title>
                <xsl:value-of select="fileDesc/titleStmt/title[1]"/>
            </title>

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
        <xd:desc>The text element template paradoxically starts by generating a bunch of data from
            the teiHeader; since these debate-days are extracts from larger source documents,
            there's no meaningful intro/metadata in the document.</xd:desc>
    </xd:doc>
    <xsl:template match="text">
        <xsl:param name="currId" as="xs:string" tunnel="yes"/>
        <body>
            <xsl:call-template name="header"/>
            <xsl:call-template name="nav"/>
            <h1>
                <xsl:apply-templates
                    select="preceding-sibling::teiHeader[1]/fileDesc/titleStmt/title[1]"/>
            </h1>

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
        <xd:desc>This template creates an appendix for the document containing lists of all linked
            resources such as people.</xd:desc>
    </xd:doc>
    <xsl:template name="appendix">
        <xsl:param name="currId" as="xs:string" tunnel="yes"/>
        <div class="appendix">
            <!--       Find and report the source document for this debate from the bibliography.     -->

            <xsl:variable name="prefix" select="hcmc:getBiblId($currId)"/>
            <xsl:variable name="strDate" select="replace($currId, '.+_([\d\-]+)$', '$1')"/>

            <xsl:variable name="citation">
                <xsl:choose>
                    <xsl:when test="$projectBibliography//bibl[@xml:id=$prefix]">
                        <xsl:apply-templates mode="#current" select="$projectBibliography//bibl[@xml:id=$prefix]/node()"/>
                    </xsl:when>
                    <xsl:when test="matches($strDate, '\d\d\d\d(-\d\d(-\d\d)?)?')">
                        <xsl:variable name="date" select="xs:date($strDate)"/>
                        <xsl:variable name="candidateBibls"
                            select="$projectBibliography//bibl[starts-with(@xml:id, $prefix)]"/>
                        <xsl:choose>
                            <xsl:when test="count($candidateBibls) = 1">
                                <xsl:apply-templates select="$candidateBibls/node()" mode="#current"/>
                            </xsl:when>
                            <xsl:when test="count($candidateBibls) gt 1">
                                <xsl:for-each select="$candidateBibls">
                                    <xsl:variable name="bibl" select="."/>
                                    <xsl:if
                                        test="$bibl/descendant::date[@when][. = substring($strDate, 1, 4)]">
                                        <xsl:apply-templates select="$bibl/node()" mode="#current"/>
                                    </xsl:if>
                                    <xsl:if test="$bibl/descendant::date[@from and @to]">
                                        <xsl:variable name="range" select="hcmc:getDateRange($bibl/descendant::date[@from and @to][1])"/>
                                        <xsl:if
                                            test="
                                                $range[1] le $date and
                                                $range[2] ge $date">
                                            <xsl:apply-templates select="$bibl/node()" mode="#current"/>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>[Error: no source found for <xsl:value-of
                                    select="concat($prefix, ' (', $strDate, ')')"
                                />.]</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <div id="sourceDocument">
                <h3>
                    <xsl:sequence select="$debateSourceCaption"/>
                </h3>
                <p>
                    <xsl:choose>
                        <xsl:when test="$citation/node()">
                            <xsl:sequence select="$citation"/>
                        </xsl:when>
                        <xsl:otherwise>[Error: no source found for <xsl:value-of
                                select="concat($prefix, ' (', $strDate, ')')"/>.] </xsl:otherwise>
                    </xsl:choose>
                </p>
            </div>
            
            <xsl:if test="//text/descendant::note[@xml:id]">
                <div id="footnotes">
                    <h3><xsl:sequence select="$footnotesCaption"/></h3>
                    <ul class="footnotes">
                        <xsl:for-each select="//text/descendant::note[@xml:id]">
                            <li data-el="note" id="{@xml:id}">
                                <xsl:apply-templates/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>

            <xsl:if test="//text/descendant::persName[@ref]">
                <div id="individualsNamed">
                    <h3>
                        <xsl:sequence select="$peopleCaption"/>
                    </h3>
                    <ul data-el="listPerson">
                        <xsl:variable name="persIds"
                            select="distinct-values(//text/descendant::persName/@ref/substring-after(normalize-space(.), 'pers:'))"/>
                        <xsl:for-each
                            select="$teiDocs/TEI[@xml:id = 'personography']//person[@xml:id = $persIds]">
                            <xsl:sort select="string-join(persName, ' ')"/>
                            <xsl:variable name="personDiv" select="doc(concat($outputFolder, '/ajax/', @xml:id, '.xml'))/xh:div"/>
                            <li id="{@xml:id}">
                                <xsl:copy-of select="$personDiv/@data-has-portrait"/>
                                <xsl:sequence
                                    select="$personDiv/node()"
                                />
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
            <!--<div id="infoHeader">&#160;</div>-->
            <div id="infoContent"/>
        </div>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>This template matches a range of different block elements. We convert them into
            HTML5 divs, distinguished by their source element name.</xd:desc>
    </xd:doc>
    <xsl:template match="div | p | ab | quote[@rendition = 'tccd:blockquote'] | lg | l">
        <div data-el="{local-name()}">
            <xsl:if test="self::p and matches(., '^[\s\*]+$')">
                <xsl:attribute name="class">asterism</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@* | node()"/>
        </div>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>This template matches a range of different elements that we want to treat as
            blocks, but which are often in an inline context.</xd:desc>
    </xd:doc>
    <xsl:template match="fw | pb | cb">
        <span data-el="{local-name()}">
            <xsl:if test="self::p and matches(., '^[\s\*]+$')">
                <xsl:attribute name="class">asterism</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@* | node()"/>
        </span>
    </xsl:template>

    <xsl:template match="div/head">
        <xsl:element name="h{count(ancestor::div) + 1}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>The persName element becomes a link to a bio entry we presume is part of the file.
            It's processed differently if it's part of the personography.</xd:desc>
    </xd:doc>
    <xsl:template match="persName[not(ancestor::person) and starts-with(@ref, 'pers:')]">
        <a href="#{substring-after(@ref, 'pers:')}" data-el="persName">
            <xsl:if test="@ref = 'UNSPECIFIED'">
                <xsl:attribute name="class" select="'unidentifiedName'"/>
                <xsl:attribute name="id" select="generate-id(.)"/>
            </xsl:if>
            <xsl:apply-templates select="@* | node()"/>
        </a>
    </xsl:template>
    <xsl:template match="persName[not(ancestor::person) and matches(@ref, 'UNSPECIFIED')]">
        <span data-el="persName" class="unidentifiedName" id="{generate-id(.)}">
            <xsl:apply-templates select="@* | node()"/>
        </span>
    </xsl:template>
    <xsl:template match="persName[ancestor::person]">
        <span data-el="{local-name()}">
            <xsl:apply-templates select="@* | node()"/>
        </span>
<!--     Process any DCB links here.   -->
        <xsl:apply-templates select="ancestor::person/descendant::ptr[contains(@target, 'biographi.ca')]"/>  
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Sometimes persNames are added because they don't actually appear on the original
            printed page. In this case, we add square brackets.</xd:desc>
    </xd:doc>
    <xsl:template match="add">
        <span class="editorialAddition">
            <xsl:text>[</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>]</xsl:text>
        </span>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Sometimes commas are included in names, and sometimes not. Might as well allow for
            this graciously, although we could constrain it with Schematron.</xd:desc>
    </xd:doc>
    <xsl:template
        match="text()[preceding-sibling::*[1][self::surname] and following-sibling::forename]">
        <xsl:if test="not(contains(., ','))">
            <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:value-of select="."/>
    </xsl:template>


    <xd:doc scope="component">
        <xd:desc>The personography and placeography needs special handling.</xd:desc>
    </xd:doc>
    <xsl:template match="particDesc | settingDesc">
        <div data-el="{local-name()}">
            <xsl:apply-templates select="@* | node()"/>
        </div>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Lists are all processed in a similar way. More types may be added.</xd:desc>
    </xd:doc>
    <xsl:template match="listPerson | listBibl | list | listPlace">
        <xsl:apply-templates select="head"/>
        <xsl:element name="{if (self::list[@rend='numbered']) then 'ol' else 'ul'}">
            <xsl:attribute name="data-el" select="local-name()"/>
            <xsl:apply-templates select="@* | node()[not(self::head)]"/>
        </xsl:element>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Lists may contain head elements; these are processed before the list
            itself.</xd:desc>
    </xd:doc>
    <xsl:template match="listPerson/head | list/head | listBibl/head">
        <xsl:variable name="locName" select="local-name()"/>
        <xsl:element name="h{count(ancestor::*[local-name(.) = $locName]|ancestor::div) + 1}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>List items, listBibl items and so on are just processed in the same way (for the
            moment). The person element has a separate template.</xd:desc>
    </xd:doc>
    <xsl:template match="listBibl/bibl | list/item">
        <li>
            <xsl:apply-templates select="@* | node()"/>
        </li>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>The person element needs its own processing.</xd:desc>
    </xd:doc>
    <xsl:template match="listPerson/person">
        <li title="pers:{@xml:id}">
            <xsl:variable name="link" select="concat('pers:', @xml:id)"/>
            <xsl:apply-templates select="@* | node()"/>

            <xsl:if test="parent::listPerson/@xml:id = 'historicalPersonography'">

                <p>
                    <xsl:sequence select="$nameAppearanceCaption"/>
                    <xsl:value-of select="count($teiDocs//persName[@ref = $link])"/>
                </p>
                
                <xsl:if test="$teiDocs/TEI[text/descendant::persName[@ref = $link]]">
                    <ul class="docsMentioningPerson">
                        <xsl:for-each select="$teiDocs/TEI[text/descendant::persName[@ref = $link]]">
                            <li>
                                <a href="{@xml:id}.html" lang="{if (contains(@xml:id, '_fr_')) then 'fr' else 'en'}">
                                    <xsl:value-of select="//titleStmt/title[1]"/>
                                </a>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
            </xsl:if>
        </li>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>The person/affiliation element is complex; it's going to need some elaboration and
            linking once we know how the riding information is going to work.</xd:desc>
    </xd:doc>
    <xsl:template match="person/affiliation[not(preceding-sibling::affiliation or preceding-sibling::state)] | person/state[not(preceding-sibling::affiliation or preceding-sibling::state)]">
        <xsl:sequence select="$participatedCaption"/>
        <ul>
            <li>
                <xsl:apply-templates select="@when"/>
                <xsl:sequence select="$representedCaption"/>
                <xsl:choose>
                    <xsl:when test="@ref">
                        <a href="canadaMap.html?place={replace(normalize-space(@ref), '^plc:', '')}">
                            <xsl:apply-templates select="node()"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="node()"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="@*[not(local-name() = 'when')]"/>
            </li>
            <xsl:apply-templates select="following-sibling::affiliation | following-sibling::state">
                <xsl:with-param name="inList" select="true()" tunnel="yes"/>
            </xsl:apply-templates>
        </ul>
    </xsl:template>
    <xsl:template match="person/affiliation[preceding-sibling::affiliation or preceding-sibling::state]| person/state[preceding-sibling::affiliation or preceding-sibling::state]">
        <xsl:param name="inList" select="false()" tunnel="yes"/>
        <xsl:if test="$inList = true()">
            <li>
                <xsl:apply-templates select="@when"/>
                <xsl:if test="self::affiliation">
                    <xsl:sequence select="$representedCaption"/>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="@ref">
                        <a href="canadaMap.html?place={replace(normalize-space(@ref), '^plc:', '')}">
                            <xsl:apply-templates select="node()"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="node()"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="@*[not(local-name() = 'when')]"/>
            </li>
        </xsl:if>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Figures need to be processed in the context of people.</xd:desc>
    </xd:doc>
    <xsl:template match="person/figure">
        <figure class="portrait">
            <xsl:apply-templates/>
        </figure>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Graphics in figures in person elements.</xd:desc>
    </xd:doc>
    <xsl:template match="person/figure/graphic">
        <img src="portraits/{ancestor::person/@xml:id}.jpg" alt="{normalize-space(ancestor::person/persName[1])}" title="{normalize-space(ancestor::person/persName[1])}"/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>References for graphics in figures in person elements.</xd:desc>
    </xd:doc>
    <xsl:template match="person/figure/listRef">
        <figcaption><xsl:copy-of select="$imageSourceCaption"/>: <xsl:apply-templates select="ref"/></figcaption>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>States usually have labels.</xd:desc>
    </xd:doc>
    <xsl:template match="person/state/label">
        <strong><xsl:apply-templates/></strong>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Notes in most locations are suppressed or processed specially, but 
            here we should just handle them.</xd:desc>
    </xd:doc>
    <xsl:template match="listPerson/person/state/note">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xd:doc scopy="component">
        <xd:desc>Processing for links to places: we might as well show them all
        on the map.</xd:desc>
    </xd:doc>
    <xsl:template match="placeName[starts-with(@ref, 'plc:')]">
        <a href="canadaMap.html?place={replace(normalize-space(@ref), '^plc:', '')}">
            <xsl:apply-templates select="node()"/>
        </a>
    </xsl:template>
    
    
    <xd:doc scope="component">
        <xd:desc>We suppress notes containing only biographi.ca pointers, because these
        are processed right after the name.</xd:desc>
    </xd:doc>
    <xsl:template match="person/listBibl[descendant::ptr[contains(@target, 'biographi.ca')]]"/>


    <xd:doc scope="component">
        <xd:desc>We process the attributes of affiliation elements into actual output.</xd:desc>
    </xd:doc>
    <xsl:template match="affiliation/@when">
        <!--<xsl:text> (</xsl:text>-->
        <xsl:value-of select="."/>
        <xsl:if test="parent::affiliation/@n">
            <xsl:text>: </xsl:text>
            <xsl:value-of select="parent::affiliation/@n"/>
        </xsl:if>
        <!--<xsl:text>)</xsl:text>-->
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
        <xd:desc>The placeName element in the context of a place element is turned into a
            comma-separated sequence of components.</xd:desc>
    </xd:doc>
    <xsl:template match="listPlace/place/placeName">
        <span data-el="{local-name()}">
            <xsl:value-of
                select="
                    string-join((for $c in *
                    return
                        normalize-space($c)), ', ')"
            />
        </span>
        <xsl:if test="parent::place/@type">
            <span> (<xsl:sequence select="hcmc:getPlaceTypeCaption(parent::place/@type)"/>)</span>
        </xsl:if>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>The locations in the placeography are output as links to the map.</xd:desc>
    </xd:doc>
    <xsl:template match="listPlace/place/location">
        <span class="{local-name()}">
            <xsl:if test="string-length(normalize-space(geo)) gt 0">
                <a href="canadaMap.html?place={ancestor::place[1]/@xml:id}" title="{geo}">
<!--                    Globe character. -->
                    <xsl:text>&#x1F310;</xsl:text>
                </a>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@notBefore and @notAfter and (@notAfter ne @notBefore)">
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="@notBefore"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="@notAfter"/>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:when test="@notBefore and not(@notAfter)">
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="@notBefore"/>
                    <xsl:text>-?)</xsl:text>
                </xsl:when>
                <xsl:when test="@notAfter and not(@notBefore)">
                    <xsl:text>(?-</xsl:text>
                    <xsl:value-of select="@notAfter"/>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:when test="@notAfter and @notBefore and (@notAfter eq @notBefore)">
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="@notAfter"/>
                    <xsl:text>)</xsl:text>
                </xsl:when>
            </xsl:choose>
        </span>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>The note element in places currently has pointless stuff in it, which we
            suppress.</xd:desc>
    </xd:doc>
    <xsl:template match="listPlace/place/note">
        <xsl:apply-templates select="node()[not(self::list)]"/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>We suppress notes in regular processing, and handle them in the appendix.</xd:desc>
    </xd:doc>
    <xsl:template match="note"/>

    <xd:doc scope="component">
        <xd:desc>This is a set of inline elements which are all processed in a similar way. hi
            elements, for instance, are used for typographical features; title elements for titles.
            Both are styled using the combination of their attributes as transferred to the HTML5
            output span.</xd:desc>
    </xd:doc>
    <xsl:template match="hi | title">
        <span data-el="{local-name()}">
            <xsl:apply-templates select="@* | node()"/>
        </span>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Handler for the ref element used to encode links.</xd:desc>
    </xd:doc>
    <xsl:template match="ref[@target]">
        <a>
            <xsl:apply-templates select="@* | node()"/>
        </a>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Handler for the choice element with sic/corr.</xd:desc>
    </xd:doc>
    <xsl:template match="choice[sic and corr]">
        <span class="correction" title="orig: {xs:string(sic)}">
            <xsl:apply-templates select="corr"/>
        </span>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Handler for the unclear element with @reason.</xd:desc>
    </xd:doc>
    <xsl:template match="unclear[@reason]">
        <span class="unclear" title="{xs:string(@reason)}">
            <xsl:apply-templates select="@*[not(local-name() = 'reason')]|node()"/>
        </span>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Handler for the lb elements which are breaking: add space.</xd:desc>
    </xd:doc>
    <xsl:template match="lb[not(@break = 'no')]">
        <xsl:text> </xsl:text>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Handler for the ptr element used to encode links.</xd:desc>
    </xd:doc>
    <xsl:template match="ptr[not(contains(@target, 'biographi.ca')) or not(ancestor::person)]">
        <a>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="substring-before(substring-after(@target, '//'), '/')"/>
        </a>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Special handler for the ptr element used to encode links in personography entries,
            when it points to biographi.ca.</xd:desc>
    </xd:doc>
    <xsl:template match="ptr[@target[contains(., 'biographi.ca')]][ancestor::person]">
        <a class="linkLogo" target="{substring-before(substring-after(@target, '//'), '/')}">
            <xsl:if test="parent::bibl[@xml:lang]">
                <xsl:attribute name="lang" select="parent::bibl/@xml:lang"/>
                <xsl:copy-of select="parent::bibl/@xml:lang"/>
            </xsl:if>
            <xsl:apply-templates select="@*"/>
            <img src="images/dcb.jpg" alt="{substring-before(substring-after(@target, '//'), '/')}"
            />
        </a>
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
        <xsl:attribute name="rowspan" select="normalize-space(.)"/>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>@cols attribute because @colspan.</xd:desc>
    </xd:doc>
    <xsl:template match="cell/@cols | row/@cols">
        <xsl:attribute name="colspan" select="normalize-space(.)"/>
    </xsl:template>

    <!--  ####### End table-handling templates. #######  -->

    <xd:doc scope="component">
        <xd:desc>These templates match TEI attributes and produce equivalent XHTML5
            attributes.</xd:desc>
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
        <xsl:attribute name="class"
            select="normalize-space(replace(replace(., '#', ''), '((^|\s)[^:]+):', '$1_'))"/>
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
    <xsl:template match="@rend">
        <xsl:attribute name="data-rend" select="."/>
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
            <!--  This switcher will be filled in later when the language versions are created.          -->
            <div class="langSwitcher"> </div>
            <a href="index.html">
                <img lang="en" src="images/eng-logo.svg" alt="{$projectTitle/xh:span[@lang='en']}"
                    class="siteLogo"/>
                <img lang="fr" src="images/fr-logo.svg" alt="{$projectTitle/xh:span[@lang='fr']}"
                    class="siteLogo"/>
            </a>
        </header>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>The nav template creates the site navigation for all pages.</xd:desc>
    </xd:doc>
    <xsl:template name="nav">
        <nav> </nav>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>The footer template creates the document footer for all pages.</xd:desc>
    </xd:doc>
    <xsl:template name="footer">
        <footer>

            <div class="version">
                <xsl:sequence select="$buildDateCaption"/>
                <xsl:value-of select="$buildDate"/>
                <xsl:text>. </xsl:text>
                <xsl:sequence select="$buildVersionCaption"/>
                <a href="{concat($gitRevUrl, $gitRevision)}">
                    <xsl:value-of select="substring($gitRevision, 1, 8)"/>
                </a>
                <xsl:text>.</xsl:text>
            </div>
        </footer>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Some comments identify specific things which need to be flagged in the
            output.</xd:desc>
    </xd:doc>
    <xsl:template match="comment()[matches(., 'untaggedTable')]">
        <span class="untaggedTable">
            <span lang="en">A table appears here, but it has not yet been encoded so cannot be
                displayed.</span>
            <span lang="fr">Un tableau apparaît ici, mais il n'a pas encore été encodé et ne peut
                donc pas être affiché.</span>
        </span>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>Some captions with multiple language components originate in the XML. We process
            these into their HTML equivalents.</xd:desc>
    </xd:doc>
    <xsl:template match="seg[@xml:lang]">
        <span lang="{@xml:lang}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

</xsl:stylesheet>
