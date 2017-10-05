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
        <xsl:choose>
            <xsl:when test="html">
                <xsl:message>Processing a single input document.</xsl:message>
<!-- We have a single input document. -->
                <xsl:variable name="docId" select="html/@id"/>
<!-- We process all docs in English mode if that's selected (en or both) and as long as they're not 
     explicitly French documents. -->
                <xsl:if test="$targetLang = ('en', 'both') and not(matches(html/@id, '_fr_'))">
                    <xsl:variable name="outputDoc" select="concat($outputFolder, '/en/', $docId, '.html')"/>
                    <xsl:message>Writing to <xsl:value-of select="$outputDoc"/>.</xsl:message>
                    <xsl:result-document href="{$outputDoc}">
                        <xsl:apply-templates select="html" mode="en">
                            <xsl:with-param name="docId" select="$docId" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:if>
<!-- We process all docs in French mode if that's selected (fr or both) and there's no matching French
     document. -->
                <xsl:if test="$targetLang = ('fr', 'both') and not($htmlDocs//html[@id[not(.=$docId)]/replace(., '_fr_', '') = $docId])"><xsl:variable name="outputDoc" select="concat($outputFolder, '/fr/', $docId, '.html')"/>
                    <xsl:message>Writing to <xsl:value-of select="$outputDoc"/>.</xsl:message>
                    <xsl:result-document href="{$outputDoc}">
                        <xsl:apply-templates select="html" mode="fr">
                            <xsl:with-param name="docId" select="$docId" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
<!-- The input document is this file itself, therefore we process everything. -->
                <xsl:for-each select="$htmlDocs/html">
                    <xsl:variable name="docId" select="@id"/>
                    <!-- We process all docs in English mode if that's selected (en or both) and as long as they're not 
     explicitly French documents. -->
                    <xsl:if test="$targetLang = ('en', 'both') and not(matches(@id, '_fr_'))">
                        <xsl:result-document href="{concat($outputFolder, '/en/', $docId, '.html')}">
                            <xsl:apply-templates select="." mode="en">
                                <xsl:with-param name="docId" select="$docId" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xsl:result-document>
                    </xsl:if>
                    <!-- We process all docs in French mode if that's selected (fr or both) and there's no matching French
     document. -->
                    <xsl:if test="$targetLang = ('fr', 'both') and not($htmlDocs//html[@id[not(.=$docId)]/replace(., '_fr_', '') = $docId])">
                        <xsl:result-document href="{concat($outputFolder, '/fr/', $docId, '.html')}">
                            <xsl:apply-templates select="." mode="fr">
                                <xsl:with-param name="docId" select="$docId" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xsl:result-document>
                    </xsl:if>
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
            <a href="{if ($htmlDocs/html[replace(@id, '_fr_', '') = $docId]) then concat('../fr/', $htmlDocs//html[replace(@id, '_fr_', '') = $docId][1]/@id, '.html') else concat('../fr/', $docId, '.html')}">FR</a>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>French documents link to the best English equivalent.</xd:desc>
    </xd:doc>    
    <xsl:template match="div[@class='langSwitcher']" mode="fr">
        <xsl:param name="docId" tunnel="yes"/>
        <xsl:variable name="enDocId" select="replace($docId, '_fr_', '')"/>
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
</xsl:stylesheet>