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
            <xd:p><xd:b>Created on:</xd:b> October 5, 2017.</xd:p>
            <xd:p><xd:b>Author:</xd:b> <xd:a href="pers:HOLM3">mholmes</xd:a></xd:p>
            <xd:p>
                This master file handles the transformation our bilingual HTML documents
                into two separate language collections in French and English, each in a
                subfolder ("en" or "fr"). This involves:
                <xd:ul>
                    <xd:li>discarding elements with @xml:lang in the other language</xd:li>
                    <xd:li>adding language-switching links to each page, pointing at the
                           equivalent page in the other language</xd:li>
                    <xd:li>Mmssaging the document indexes such that when the original document
                           is available in both languages, the version in the target language
                           is kept and the other removed.</xd:li>
                    <xd:li>tweaking links to site-wide resources such as JS and CSS files so that 
                           they point one folder higher.</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc scope="component">
        <xd:desc>The <xd:ref name="targetLang">targetLang</xd:ref> attribute can take the values
        "en", "fr" or "both" (the default). This is only used in single-document testing; in the 
        general case (processing the whole site), both versions are always created.</xd:desc>
    </xd:doc>
    <xsl:param name="targetLang" select="'both'"/>
    
    <xd:doc scope="component">
        <xd:desc>Linked module with useful globals in it.</xd:desc>
    </xd:doc>
    <xsl:include href="tei_to_html_globals_module.xsl"/>
    
    <xd:doc scope="component">
        <xd:desc>The complete set of HTML documents found in the output folder.</xd:desc>
    </xd:doc>
    <xsl:variable name="htmlDocs" select="collection(concat($outputFolder, '/?select=*.html;recurse=no'))"/>
    
    <xd:doc scope="component">
        <xd:desc>The complete set of AJAX fragments found in the output folder/ajax.</xd:desc>
    </xd:doc>
    <xsl:variable name="ajaxDocs" select="collection(concat($outputFolder, '/ajax/?select=*.xml;recurse=no'))"/>
    
    <xd:doc scope="component">
        <xd:desc>A handy list of the ids of all English docs which have a French parallel.</xd:desc>
    </xd:doc>
    <xsl:variable name="engDocsWithFrenchParallels" as="xs:string*">
        <xsl:for-each select="$htmlDocs/html/@id[matches(., '_fr_')]">
            <xsl:variable name="enId" select="replace(., '_fr_', '_')"/>
            <!--<xsl:message>Eng id = <xsl:value-of select="$enId"/></xsl:message>-->
            <xsl:if test="$htmlDocs/html[@id=$enId]"><xsl:value-of select="$enId"/></xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc scope="component">
        <xd:desc>Output is XHTML5; doctype is handled with hard-coded text.</xd:desc>
    </xd:doc>
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes" normalization-form="NFC"
        exclude-result-prefixes="#all" omit-xml-declaration="yes"/>
    
    <xd:doc scope="component">
        <xd:desc>For testing purposes, we want to be able to call this transformation
                 passing in a single XHTML document, but in the general use case, we
                 will set the XSLT library itself as the input, in which case the whole
                 set of HTML files will be processed.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:message>English documents with French parallel documents:
        <xsl:value-of select="string-join($engDocsWithFrenchParallels, '&#x0a;')"/></xsl:message>
        <xsl:choose>
            <xsl:when test="html">
                <xsl:message>Processing a single input document.</xsl:message>
<!-- We have a single input document. -->
                <xsl:variable name="docId" select="html/@id"/>
<!-- We process all docs in English mode if that's selected (en or both) and as long as they're not 
     explicitly French documents. -->
                <xsl:if test="$targetLang = ('en', 'both') and not(matches(html/@id, '_fr_')) and not($docId = 'index')">
                    <xsl:variable name="outputDoc" select="concat($outputFolder, '/en/', $docId, '.html')"/>
                    <xsl:message>Writing to <xsl:value-of select="$outputDoc"/>.</xsl:message>
                    <xsl:result-document href="{$outputDoc}">
                        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;
</xsl:text>
                        <xsl:apply-templates select="html" mode="en">
                            <xsl:with-param name="docId" select="if ($docId = 'home') then 'index' else $docId" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:if>
<!-- We process all docs in French mode if that's selected (fr or both) and there's no matching French
     document. -->
                <xsl:if test="$targetLang = ('fr', 'both') and not($htmlDocs//html[@id[not(.=$docId)]/replace(., '_fr_', '') = $docId]) and not($docId = 'index')"><xsl:variable name="outputDoc" select="concat($outputFolder, '/fr/', $docId, '.html')"/>
                    <xsl:message>Writing to <xsl:value-of select="$outputDoc"/>.</xsl:message>
                    <xsl:result-document href="{$outputDoc}">
                        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;
</xsl:text>
                        <xsl:apply-templates select="html" mode="fr">
                            
                            <xsl:with-param name="docId" select="if ($docId = 'home') then 'index' else $docId" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
<!-- The input document is this file itself, therefore we process everything. -->
                <xsl:for-each select="$htmlDocs/html[not(@id='index')]">
                    <xsl:variable name="docId" select="xs:string(@id)"/>
                    <xsl:message>Processing <xsl:value-of select="$docId"/></xsl:message>
                    <!-- We process all docs in English mode if that's selected (en or both) and as long as they're not 
     explicitly French documents. -->
                    <xsl:if test="$targetLang = ('en', 'both') and not(matches(@id, '_fr_'))">
                        <xsl:variable name="outputDoc" select="concat($outputFolder, '/en/', if ($docId = 'home') then 'index' else $docId, '.html')"/>
                        <xsl:result-document href="{$outputDoc}">
                            <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;
</xsl:text>
                            <xsl:apply-templates select="." mode="en">
                                <xsl:with-param name="docId" select="if ($docId = 'home') then 'index' else $docId" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xsl:result-document>
                    </xsl:if>
                    <!-- We process all docs in French mode if that's selected (fr or both) and there's no matching French
     document. -->
                    <xsl:if test="$targetLang = ('fr', 'both') and not($htmlDocs//html[@id[not(.=$docId)]/replace(., '_fr_', '') = $docId])">
                        <xsl:variable name="outputDoc" select="concat($outputFolder, '/fr/', if ($docId = 'home') then 'index' else $docId, '.html')"/>
                        <xsl:result-document href="{$outputDoc}">
                            <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;
</xsl:text>
                            <xsl:apply-templates select="." mode="fr">
                                <xsl:with-param name="docId" select="if ($docId = 'home') then 'index' else $docId" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xsl:result-document>
                    </xsl:if>
                </xsl:for-each>
                
<!--      Now the AJAX documents.          -->
                <xsl:for-each select="$ajaxDocs">
                    <xsl:message>Processing <xsl:value-of select="div/@id"/></xsl:message>
                    <xsl:variable name="enOutputDoc" select="concat($outputFolder, '/en/ajax/', tokenize(document-uri(.), '/')[last()])"/>
                    <xsl:result-document href="{$enOutputDoc}" method="xml" encoding="UTF8">
                        <xsl:apply-templates mode="en"/>
                    </xsl:result-document>
                    
                    <xsl:variable name="frOutputDoc" select="concat($outputFolder, '/fr/ajax/', tokenize(document-uri(.), '/')[last()])"/>
                    <xsl:result-document href="{$frOutputDoc}" method="xml" encoding="UTF8">
                        <xsl:apply-templates mode="fr"/>
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    
    <xd:doc scope="component">
        <xd:desc>Mostly we're just copying, so this is the default identity template.</xd:desc>
    </xd:doc>
    <xsl:template match="node()|@*" priority="-1" mode="#all">
        <xsl:param name="docId" tunnel="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current">
                <xsl:with-param name="docId" select="$docId" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Suppress English stuff if we're in French.</xd:desc>
    </xd:doc>
    <xsl:template match="*[not(self::html)][@lang='en']" mode="fr"/>
       
    <xd:doc scope="component">
        <xd:desc>Suppress French stuff if we're in English.</xd:desc>
    </xd:doc>
    <xsl:template match="*[not(self::html)][@lang='fr']" mode="en"/>
    
    <xd:doc scope="component">
        <xd:desc>English documents link to the best French equivalent.
        <ref name="docId">docId</ref> is the root id of the document
        being processed.</xd:desc>
    </xd:doc>
    <xsl:template match="div[@class='langSwitcher']" mode="en">
        <xsl:param name="docId" tunnel="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <a href="{if ($docId = $engDocsWithFrenchParallels) then concat('../fr/', replace($docId, '_(\d\d\d\d-)', '_fr_$1'), '.html') else concat('../fr/', $docId, '.html')}">FR</a>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>French documents link to the best English equivalent.</xd:desc>
    </xd:doc>    
    <xsl:template match="div[@class='langSwitcher']" mode="fr">
        <xsl:param name="docId" tunnel="yes"/>
        <xsl:variable name="enDocId" select="replace($docId, '_fr_', '_')"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <a href="{concat('../en/', $enDocId, '.html')}">EN</a>
        </xsl:copy>
    </xsl:template> 
    
    <xd:doc scope="component">
        <xd:desc>All attributes with local links to resources need to be tweaked.</xd:desc>
    </xd:doc>
    <xsl:template match="img/@src[not(contains(., ':'))] | link/@href | script/@src" mode="#all">
        <xsl:attribute name="{local-name()}" select="concat('../', .)"/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>The "home" pages are a special case; they're changed into index pages.</xd:desc>
    </xd:doc>
    <xsl:template match="html/@id[. = 'home']" mode="#all">
        <xsl:attribute name="id" select="'index'"/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>The infoHeader in the popup has a background graphic with an image in it.
        The URL needs to be tweaked.</xd:desc>
    </xd:doc>
    <xsl:template match="div[@id = 'infoHeader']/@style[contains(., 'portraits')]" mode="#all">
        <xsl:attribute name="style" select="replace(., 'portraits', '../portraits')"/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>The text inside a script element needs to be output without
        escaping, otherwise it breaks the JavaScript.</xd:desc>
    </xd:doc>
    <xsl:template match="script[not(@src)]/text()" mode="#all">
        <xsl:value-of select="." disable-output-escaping="yes"/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>Two of the documents we link from document index pages are project-level
        diagnosis/monitoring pages. Those remain in the root directory and therefore 
        need to be linked with ../, since the contents pages are moving down into language
        subdirectories.</xd:desc>
    </xd:doc>
    <xsl:template match="li/a[matches(@href, '^(unidentified_names.htm)|(a_to_z.htm)$')]" mode="#all">
        <a href="{concat('../', @href)}"><xsl:apply-templates/></a>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>We need to make sure that when we're processing a document index, 
        where there are parallel documents in both languages, we only include a 
        link to the one that's in the core language.</xd:desc>
    </xd:doc>
    <xsl:template match="li[child::a[matches(@href, '^[^/\.]+_fr_[^/\.]+\.html$')]][ancestor::ul[@class='docList']]" mode="en">
        <xsl:variable name="targetId" select="replace(replace(a/@href, '\.html$', ''), '_fr_', '_')"/>
        <xsl:choose>
            <xsl:when test="$targetId = $engDocsWithFrenchParallels"></xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="li[child::a[matches(@href, '^[^/\.]+\.html$')]][ancestor::ul[@class='docList']]" mode="fr">
        <xsl:variable name="targetId" select="replace(a/@href, '\.html$', '')"/>
        <xsl:choose>
            <xsl:when test="$targetId = $engDocsWithFrenchParallels"></xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xd:doc scope="component">
        <xd:desc>Links to PDFs need to have a ../ added to them, since we keep
            only one copy of the folder of PDFs in the root.</xd:desc>
    </xd:doc>
    <xsl:template match="a[matches(@href, '^pdfs/.+\.pdf$')]" mode="#all">
        <a href="{concat('../', @href)}"><xsl:apply-templates/></a>
    </xsl:template>
    
</xsl:stylesheet>

