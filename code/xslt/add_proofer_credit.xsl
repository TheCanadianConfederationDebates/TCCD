<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> May 8, 2018</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This is a one-time-use file which is designed to be run against
      a collection of completed debate day files, and which will then attempt
      to discover the user names or full names of individuals who have done 
      proofing on any of the pages of the document from the associated HOCR
      files, and add respStmt elements to the header to acknowledge them.</xd:p>
    </xd:desc>
  </xd:doc>
  
<!--  Bring in our utilities. -->
  <xsl:include href="utilities_module.xsl"/>
  
<!--  Output is XML. This is an identity transform. -->
  <xsl:output method="xml" encoding="UTF-8" normalization-form="NFC"
    exclude-result-prefixes="#all"/>
  
<!--  Some variables for documents, paths and constants. -->
<!-- Wherever this gets called from, we want to do things relative to its actual location. -->
  <xsl:param name="baseDir" select="replace(document-uri(/), concat(tokenize(document-uri(/), '/')[last()], '$'), '')"/>
  
<!--  Current date-time in case we need it. -->
  <xsl:variable name="currDateTime" as="xs:dateTime" select="current-dateTime()"/>
  
<!--  The root for all our documents. -->
  <xsl:variable name="docRoot" select="concat($baseDir, '/../../data')"/>
  
<!--  The utilities folder, where various things are stored including collections of files. -->
  <xsl:variable name="utilitiesDir" select="concat($baseDir, '/../utilities')"/>
  
  
<!-- Root template. -->
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
<!-- Template to handle respStmts. -->
  <xsl:template match="titleStmt">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      
      <xsl:for-each select="//sourceDesc/list/item/ptr">
        <xsl:variable name="thisHocr" select="@target"/>
        <xsl:variable name="hocrDoc" select="doc(concat($baseDir, '/', $thisHocr))"/>
        <xsl:variable name="pos" select="position()"/>
        <xsl:variable name="pNum" select="xs:integer(//facsimile/surface[$pos]/tokenize(@xml:id, '_')[last()])"/>
        <xsl:message>Processing document <xsl:value-of select="document-uri($hocrDoc)"/></xsl:message>
        <xsl:choose>
          
<!--       Original hand-corrected format.   -->
          <xsl:when test="$hocrDoc/descendant::xh:p[@class='editorial']">
            <xsl:variable name="edNote" select="normalize-space($hocrDoc/descendant::xh:p[@class='editorial'][1])"/>
            <xsl:variable name="corrName" select="replace(substring-before(substring-after($edNote, 'by '), ' on'), '[\[\]]+', '')"/>
            <xsl:variable name="corrDate" select="replace($edNote, '^.+(\d\d\d\d-\d\d-\d\d).*$', '$1')"/>
            
            
            <xsl:text>&#x0a;</xsl:text>
            <respStmt><xsl:text>&#x0a;</xsl:text>
              <resp>Proofing/correction p. <xsl:value-of select="$pNum"/><xsl:if test="string-length($corrDate) gt 0"/><date when="{$corrDate}"/></resp><xsl:text>&#x0a;</xsl:text>
              <name><xsl:value-of select="$corrName"/></name><xsl:text>&#x0a;</xsl:text>
            </respStmt><xsl:text>&#x0a;</xsl:text>
          </xsl:when>
          
<!--        Pages from the crowd-source site.  -->
          <xsl:when test="$hocrDoc//xh:meta[@name='user']/@content">
            <xsl:variable name="userNames" select="$hocrDoc//xh:meta[@name='user']/@content"/>
            <xsl:for-each select="distinct-values($userNames)">
              <xsl:text>&#x0a;</xsl:text>
              <respStmt><xsl:text>&#x0a;</xsl:text>
                <resp>Proofing/correction p. <xsl:value-of select="$pNum"/></resp><xsl:text>&#x0a;</xsl:text>
                <name><xsl:value-of select="."/></name><xsl:text>&#x0a;</xsl:text>
              </respStmt><xsl:text>&#x0a;</xsl:text>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:comment>No info about proofer/corrector for p. <xsl:value-of select="$pNum"/></xsl:comment>
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:for-each>
      
    </xsl:copy>
  </xsl:template>
  
  
<!--   Identity transform. -->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>