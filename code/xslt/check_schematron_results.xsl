<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:schold="http://www.ascc.net/xml/schematron"
  xmlns:iso="http://purl.oclc.org/dsdl/schematron"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Feb 21, 2018</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This file is designed to process the results output from 
      a Schematron process; the output is in Schematron Validation
      Report Language (SVRL). We're only really interested in finding
      straight-up errors, and terminating with a message so that the
      site build process fails.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="text" encoding="UTF-8" indent="no"/>
  
  <xsl:variable name="currDoc" select="tokenize(document-uri(/), '/')[last()]"/>

  <xd:doc scope="component">
    <xd:desc>Root template just reports what it's working on.</xd:desc>
  </xd:doc>
  
  <xsl:template match="/">
    <xsl:message>Checking <xsl:value-of select="$currDoc"/>...</xsl:message>
    <xsl:apply-templates/>
  </xsl:template>

  <xd:doc scope="component">
    <xd:desc>This is the important template, which catches an
      error, reports it and fails the process.</xd:desc>
  </xd:doc>
  <xsl:template match="svrl:failed-assert" mode="#all">
    <xsl:variable name="outputMessage" select="concat(
      '&#x0a;******************************************&#x0a;',
      'Schematron validation failed: &#x0a;',
      $currDoc, ': &#x0a;',
      normalize-space(svrl:text), 
      '&#x0a;******************************************&#x0a;')"/>
    <xsl:message terminate="yes">
      <xsl:value-of select="$outputMessage"/>
    </xsl:message>
  </xsl:template>

  <xd:doc scope="component">
    <xd:desc>This is the default template, which does nothing
    except allow processing to continue.</xd:desc>
  </xd:doc>
  <xsl:template match="@* | node()" priority="-1" mode="#all">
    <xsl:apply-templates select="@* | node()" mode="#current"/>
  </xsl:template>

  
</xsl:stylesheet>