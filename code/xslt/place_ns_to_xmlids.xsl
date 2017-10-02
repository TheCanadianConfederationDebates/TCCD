<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> May 24, 2017</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>Identity transform to turn @n attributes on place elements
        into unique @xml:ids which don't clash with those
        in the personography.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xml" encoding="UTF-8" normalization-form="NFC" exclude-result-prefixes="#all"/>
  
  <xsl:variable name="personography" select="doc('../../data/personography/personography.xml')"/>
  
  <xsl:template match="place/@n">
    <xsl:variable name="currPrefix" select="."/>
    <xsl:variable name="precedingInstances" select="preceding::place/@n[.=$currPrefix]"/>
    <xsl:variable name="xmlIds" select="$personography//@xml:id[starts-with(., $currPrefix)]"/>
    <xsl:variable name="xmlIdNums" select="for $x in $xmlIds return xs:integer(replace($x, $currPrefix, ''))"/>
    <xsl:variable name="xmlNumMax" select="if (count($xmlIdNums) gt 0) then max($xmlIdNums) else 0"/>
    <xsl:variable name="nextNum" select="$xmlNumMax + count($precedingInstances) + 1"/>
    <xsl:attribute name="xml:id" select="concat($currPrefix, $nextNum)"/>
  </xsl:template>
  
<!-- Identity transform template. -->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>