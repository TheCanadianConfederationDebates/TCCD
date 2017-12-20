<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Dec 19, 2017</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>The objective of this utility stylesheet is 
      to find cases where headings have actually been 
      tagged as p elements. Requested by GL.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xml" encoding="UTF-8" normalization-form="NFC"/>
  
<!-- Match a p element with a specific configuration, but only
     in a context in which it's safe to transform it.-->
  
  <xsl:template match="p[contains(@rendition, 'simple:centre') or contains(@rendition, 'simple:right')][not(ancestor::quote)][not(preceding-sibling::*) or preceding-sibling::*[1][self::head]]">

    <xsl:variable name="one"><p><xsl:apply-templates select="node()" mode="first"/></p></xsl:variable>
    <head>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="$one/p/node()" mode="second"/>
    </head>
  </xsl:template>
  
<!-- <emph> elements in this context need to be removed. -->
  <xsl:template match="emph" mode="first">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
<!--  There are sometimes pointless lb elements in here. -->
  <xsl:template match="lb[normalize-space(string-join(following-sibling::node(), '')) = '']" mode="first"/>
   
<!-- We should trim pointless leading and trailing spaces too. -->
<!--  <xsl:template match="p/text()[normalize-space(.) = ''][not(preceding-sibling::node()) or not(following-sibling::node())]" mode="special"/>-->
  
  <!-- NOTE: This one is not matching; WHY? -->
  <xsl:template match="p/text()[following-sibling::node() and not(preceding-sibling::node())]" mode="second">
    <xsl:value-of select="replace(., '^[\s\n]+', '', 'm')"/>
  </xsl:template>
  

  <xsl:template match="text()[preceding-sibling::node() and not(following-sibling::node())]" mode="second">
    <xsl:value-of select="replace(., '\s+$', '', 'm')"/>
  </xsl:template>
  
<!--  Default identity template. -->
  <xsl:template match="@*|node()" priority="-1" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>