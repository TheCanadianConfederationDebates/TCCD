<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Rewritten on:</xd:b> September 28, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This stylesheet processes a TEI template file created by 
        an editor which specifies the metadata and the list of HOCR 
        files which need to be incorporated, to create the single 
        TEI file containing a single debate at a single legislature.
        </xd:p>
      <xd:p>The process works like this:
      <xd:ul>
        <xd:li>Check metadata is complete and referenced files exist.</xd:li>
        <xd:li>Calculate path to local copy of schema.</xd:li>
        <xd:li>Retrieve HOCR files.</xd:li>
        <xd:li>Build facsimile element linking to original images, parsed out from
               HOCR links. Warn if images or image links not found.</xd:li>
        <xd:li>Process HOCR content to create TEI hierarchy of pages.</xd:li>
        <xd:li>Transform page hierarchy into structural hierarchy.</xd:li>
      </xd:ul>
      </xd:p>
    </xd:desc>
  </xd:doc>
  
  <!-- TEI output in UTF-8 NFC. -->
  <xsl:output method="xml" encoding="UTF-8"  normalization-form="NFC" omit-xml-declaration="no" exclude-result-prefixes="#all" byte-order-mark="no" indent="yes" />

  <xsl:variable name="quot">"</xsl:variable>

  
  <xsl:template match="/">
    
    <xsl:variable name="rootEl" as="node()" select="//tei:TEI[1]"/> 
    
    <xsl:variable name="docUri" as="xs:anyURI" select="document-uri(/)"/> 
    
    
    <xsl:message>Input document URI is <xsl:value-of select="$docUri"/></xsl:message>
    
    <!-- It's useful to know the base URI of the TCCD repo itself. -->
    <xsl:variable name="baseDir" select="replace($docUri, '/data/.*$', '')"/>
    
    
    <xsl:message>Input document URI: <xsl:value-of select="$docUri"/></xsl:message>
    
    <xsl:variable name="sourceDir" select="replace($docUri, '/[^/]+$', '')"/>
    <xsl:variable name="docFileName" select="tokenize($docUri, '/')[last()]"/>
    
    <xsl:message>Processing this document:</xsl:message>
    <xsl:message>  <xsl:value-of select="$docFileName"/></xsl:message>
    <xsl:message>in this folder:</xsl:message>
    <xsl:message>  <xsl:value-of select="$sourceDir"/></xsl:message>
    <xsl:if test="$rootEl/@xml:id != substring-before($docFileName, '.xml')">
      <xsl:message>WARNING: Document file name does not match @xml:id on root TEI element.</xsl:message>
    </xsl:if>
    
  <!--Find the source document paths and check the docs are actually there.-->  
    
    <xsl:variable name="hocrDocUris" select="//tei:sourceDesc/tei:list/tei:item/tei:ptr/@target"/>
    <xsl:variable name="hocrDocs">
      <xsl:for-each select="$hocrDocUris">
        <xsl:variable name="fullPath" select="resolve-uri(., $docUri)"/>
        <xsl:if test="not(doc-available($fullPath))">
          <xsl:message terminate="yes">Document <xsl:value-of select="$fullPath"/> is not available. 
            Please check the ptr element in the teiHeader. 
            Terminating.</xsl:message>
        </xsl:if>
        <xsl:sequence select="doc($fullPath)"/>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:message>Found <xsl:value-of select="count($hocrDocs)"/> with OCR content.</xsl:message>
    
<!--  Now we do a bunch of checks to make sure we aren't overwriting data which is already 
      imported or processed. -->
    <xsl:if test="$rootEl/descendant::tei:facsimile or $rootEl/tei:text/tei:body/tei:div or not(//comment()[matches(., 'TEMPLATE:')])">
      <xsl:message terminate="yes">WARNING: This document appears to have already been processed.
                   Aborting this process to avoid overwriting good data. Please 
                   check whether this document already has imported OCR content.</xsl:message>
    </xsl:if>
    
    <xsl:variable name="currDate" select="current-date()"/>
    <xsl:variable name="currDateW3C" select="format-date($currDate, '[Y0001]-[M01]-[D01]')"/>
    <xsl:variable name="currDateText" select="format-date($currDate, '[D] [MNn] [Y0001]')"/>
    
<!--  If we've got this far, we're going to create the output document.  -->
    <TEI>
      <xsl:copy-of select="$rootEl/@*"/>
      <xsl:apply-templates select="$rootEl/tei:teiHeader" mode="tei"/>
      <facsimile>
        <xsl:for-each select="$hocrDocs">
          <xsl:variable name="pageImageUri" select="hcmc:getImageUri(//div[@class='ocr_page'][1]/@title)"/>
          <xsl:variable name="pgId" select="substring-before(tokenize($pageImageUri, '/')[last()], '.')"/>
          <surface xml:id="{$pgId}">
            <graphic url="{$pageImageUri}"/>
          </surface>
        </xsl:for-each>
      </facsimile>
      <xsl:apply-templates select="$rootEl/tei:text" mode="tei"/>
    </TEI>
    <!--
      
    <xsl:message>Creating TEI output in <xsl:value-of select="$outputPath"/>.</xsl:message>
    

    
    <xsl:result-document href="{$outputPath}" encoding="UTF-8"  normalization-form="NFC" omit-xml-declaration="no" exclude-result-prefixes="#all" byte-order-mark="no" indent="yes"><xsl:text>&#x0a;</xsl:text>
      <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_bare.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction><xsl:text>&#x0a;</xsl:text>
      <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_bare.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction><xsl:text>&#x0a;</xsl:text><xsl:text>&#x0a;</xsl:text>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
          <fileDesc>
            <titleStmt>
              <title><xsl:value-of select="substring-after($inputFolder, 'data/')"/></title>
            </titleStmt>
            <publicationStmt>
              <p>This TEI file is part of the 
                <ref target="https://github.com/TheCanadianConfederationDebates/TCCD">Canadian Confederation Debates</ref>
              project. Please refer to the project documentation for more information.</p>
            </publicationStmt>
            <sourceDesc>
              <p>This file was generated on <date when="{$currDateW3C}"><xsl:value-of select="$currDateText"/></date>.
              It was created using XSLT to process corrected HOCR documents.</p>
            </sourceDesc>
          </fileDesc>
        </teiHeader>
        <facsimile>
<!-\- TODO: We deduce information about the original page-images from the OCR data.         -\->
          
        </facsimile>
        <text>
          <body>
            <xsl:for-each select="$inDocs">
              <xsl:sort select="tokenize(document-uri(.), '[\\/]')[last()]"/>
              <xsl:variable name="currDoc" select="."/>
              <xsl:variable name="fName" select="tokenize(document-uri($currDoc), '[\\/]')[last()]"/>
              <xsl:variable name="imageForPage" select="substring-before(substring-after(descendant::div[@class='ocr_page'][contains(@title, 'image')][1]/@title, 'images/'), '&#34;')"/>
              <xsl:comment>This page-break number is not from the document, but from the 
              numbering of image files from the HOCR process. </xsl:comment>
              <pb n="{replace(substring-before($fName, '.hocr.html'), '^.+_Page0+', '')}" facs="{concat('images/', $imageForPage)}"/>
              <xsl:apply-templates select="$currDoc//body"/>
            </xsl:for-each>
          </body>
        </text>
      </TEI>
    </xsl:result-document>-->
  </xsl:template>
  
  <xsl:template match="tei:revisionDesc" exclude-result-prefixes="#all" mode="tei">
    <xsl:message>Recording what we did.</xsl:message>
    <xsl:variable name="w3today" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>    
    <xsl:copy>
      <change who="mholmes" when="{$w3today}">Transformed initial template file to incorporate corrected OCR content.</change>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
<!--  Default identity transformation for TEI elements and attributes. -->
  <xsl:template match="@*|node()" mode="tei" priority="-1">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
<!-- Remove all the template comments. -->
  <xsl:template match="comment()[matches(., 'TEMPLATE:')]" mode="tei"/>
  
  <xsl:template match="body">
    <xsl:apply-templates/>
  </xsl:template>
  
<!--  If we find a horizontal line, we should assume it is a column break. -->
  <xsl:template match="hr">
    <xsl:variable name="nums" select="hcmc:getTruePageColNumbers(ancestor::body)"/>
    <xsl:choose>
      <xsl:when test="count($nums) gt 1">
        <cb n="{$nums[2]}"/>
      </xsl:when>
      <xsl:otherwise>
        <milestone type="unknown"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
<!-- We dump our editorial injections. -->
  <xsl:template match="p[@class='editorial']"/>
  
<!-- The page container has already been used in the root template. -->
  <xsl:template match="div[@type='ocr_page']">
    <xsl:apply-templates/>
  </xsl:template>
  
<!-- We attempt to distinguish forme works from other components. We 
     do this on the assumption that an area which appears first or 
     last, and which contains short text strings, is a forme work. -->
  <xsl:template match="div[@type='ocr_carea'][not(preceding::div[@type='ocr_carea'])][string-length(normalize-space(.)) lt 25] | div[@type='ocr_carea'][not(following::div[@type='ocr_carea'])][string-length(normalize-space(.)) lt 25]">
    <fw>
<!-- Now we attempt to figure out what we have in here. Possibly colnum + running header + colnum.-->
      <xsl:variable name="components" select="tokenize(normalize-space(.), '\s+')"/>
      <xsl:choose>
        <xsl:when test="matches($components[1], 'ivxlcIVXLC0123456789+') and matches(components[last()], 'ivxlcIVXLC0123456789+')">
          <fw type="num"><xsl:value-of select="$components[1]"/></fw>
          <xsl:if test="count($components) gt 2">
            <fw type="running"><xsl:value-of select="string-join((for $c in $components[position() gt 1 and position() lt last()] return $c), ' ')"/></fw>
          </xsl:if>
          <xsl:if test="count($components) gt 1">
            <fw type="num"><xsl:value-of select="$components[last()]"/></fw>
          </xsl:if>
        </xsl:when>
        <xsl:when test="matches($components[1], 'ivxlcIVXLC0123456789+')">
          <fw type="num"><xsl:value-of select="$components[1]"/></fw>
          <xsl:if test="count($components) gt 1">
            <fw type="running"><xsl:value-of select="string-join((for $c in $components[position() gt 1] return $c), ' ')"/></fw>
          </xsl:if>
        </xsl:when>
        <xsl:when test="matches($components[last()], 'ivxlcIVXLC0123456789+')">
          <xsl:if test="count($components) gt 1">
            <fw type="running"><xsl:value-of select="string-join((for $c in $components[position() lt last()] return $c), ' ')"/></fw>
          </xsl:if>
          <fw type="num"><xsl:value-of select="$components[last()]"/></fw>
        </xsl:when>
        <xsl:when test="matches(normalize-space(.), 'ivxlcIVXLC0123456789+')">
          <fw type="num"><xsl:value-of select="normalize-space(.)"/></fw>
        </xsl:when>
        <xsl:otherwise>
          <fw type="running"><xsl:value-of select="."/></fw>
        </xsl:otherwise>
      </xsl:choose>
    </fw>
  </xsl:template>
  
  
  <xsl:template match="p[not(@class='editorial')]">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:function name="hcmc:getImageUri" as="xs:string">
    <xsl:param name="titleAtt" as="xs:string"/>
    <xsl:value-of select="substring-before(substring-after($titleAtt, $quot), $quot)"/>
  </xsl:function>
  
  <xsl:function name="hcmc:getTruePageColNumbers" as="xs:string*">
    <xsl:param name="page"/>
    <xsl:variable name="editorialHeader" select="if ($page//div[@class='editorial']) then $page//div[@class='editorial'][1] else ()"/>
    <xsl:variable name="numsFromEditorialHeader" select="replace($editorialHeader, '^.+(\[[ivxlcIVXLC0123456789\-\s]+\]).+$', '$1')"/>
    <xsl:choose>
      <xsl:when test="string-length($numsFromEditorialHeader) gt 0">
        <xsl:value-of select="tokenize($numsFromEditorialHeader, '[\s\-]+')"/>
      </xsl:when>
      <xsl:otherwise>
<!--        Go back to the original source and try to find the page numbers. -->
        <xsl:variable name="firstMeaningfulDiv" select="if ($page//div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0]) then normalize-space($page//div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0][1]) else ''"/>
        <xsl:variable name="lastMeaningfulDiv" select="if ($page//div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0]) then normalize-space($page//div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0][last()]) else ''"/>
        <xsl:variable name="possPageNum" as="xs:string*">
          <xsl:choose>
            <xsl:when test="string-length($firstMeaningfulDiv) gt 0 and matches($firstMeaningfulDiv, '\d')">
              <xsl:analyze-string select="$firstMeaningfulDiv" regex="((^[ivxc\d]+(\s|$))|((^|\s)[ivxc\d]+$))">
                <xsl:matching-substring><xsl:value-of select="."/></xsl:matching-substring>
                <xsl:non-matching-substring/>
              </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="string-length($lastMeaningfulDiv) gt 0 and matches($lastMeaningfulDiv, '\d')">
              <xsl:analyze-string select="$lastMeaningfulDiv" regex="((^[ivxc\d]+(\s|$))|((^|\s)[ivxc\d]+$))">
                <xsl:matching-substring><xsl:value-of select="normalize-space(.)"/></xsl:matching-substring>
                <xsl:non-matching-substring/>
              </xsl:analyze-string>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$possPageNum"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:function>
  
</xsl:stylesheet>
