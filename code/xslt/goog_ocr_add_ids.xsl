<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  xmlns="http://www.w3.org/1999/xhtml"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> January 17, 2017</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      
      <xd:p>The purpose of this spreadsheet is to slightly enhance some Google OCR
      which ends up not having useful @id attributes which are needed by the 
      Conestoga transcription system.</xd:p>
      
      <xd:p>The incoming data is standard HOCR (i.e. XHTML 1.1). 
      The process takes the form of a standard identity transform.
      The input file is overwritten.
      </xd:p>
      
    </xd:desc>
  </xd:doc>
  
  <!-- We'll use XHTML 1 strict, because that's what Kompozer and hocr2pdf like. -->
  <xsl:output method="xhtml" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"  normalization-form="NFC" omit-xml-declaration="yes" exclude-result-prefixes="#all" byte-order-mark="no" indent="no" />
  
  <xd:doc scope="component">
    <xd:desc>Root template</xd:desc>
  </xd:doc>
  <xsl:template match="/">
    <xsl:message>Processing <xsl:value-of select="document-uri(.)"/>.</xsl:message>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xd:doc scope="component">
    <xd:desc>Elements that need ids adding to them.</xd:desc>
  </xd:doc>
  <xsl:template match="*[starts-with(@class, 'ocr') and not(@id)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="id" select="hcmc:getId(.)"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy> 
  </xsl:template>
  
  <xd:doc scope="component">
    <xd:desc>The Google OCR is littered with @xml:space="preserve"; we'll dispense with
    all instances except on the body element.</xd:desc>
  </xd:doc>
  <xsl:template match="@xml:space[.='preserve'][not(parent::*[self::body])]"/>
  
  <xd:doc scope="component">
    <xd:desc>We'll collapse whitespace between divs and ps.</xd:desc>
  </xd:doc>
  <xsl:template match="div/text()[normalize-space(.) = '']"><xsl:text>&#x0a;</xsl:text></xsl:template>
  
<!-- Default identity transform. -->
  <xsl:template match="@*|node()" priority="-1" mode="#all">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc scope="component">
    <xd:desc>Function for supplying the correct form for constructing an id.</xd:desc>
  </xd:doc>
  <xsl:function name="hcmc:getId" as="xs:string">
    <xsl:param name="el" as="element()"/>
    <xsl:variable name="elClass" as="xs:string" select="$el/@class"/>
    <xsl:variable name="descriptor" select="substring-after($elClass, '_')"/>
    <xsl:variable name="prefix" select="if (contains($descriptor, 'area')) then 'block' else $descriptor"/>
    <xsl:variable name="counter" select="count($el/preceding::*[@class = $elClass]) + 1"/>
    <xsl:value-of select="if ($descriptor = 'page') then 'page_1' else concat($prefix, '_1_', $counter)"/>
  </xsl:function>
  
  
</xsl:stylesheet>