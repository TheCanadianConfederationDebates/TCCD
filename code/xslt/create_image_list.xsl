<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> November 17, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This file is used as part of the system that builds a package 
      for an encoder to add name tagging to a collection of XML files.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:include href="utilities_module.xsl"/>
  
  <xsl:param name="collectionPath" as="xs:string"/>
  <xsl:variable name="coll" select="collection(concat($collectionPath, '?*.xml'))"/>
  
  <xsl:template match="/">
    <xsl:message>Creating list of images from files in <xsl:value-of select="$collectionPath"/>...</xsl:message>
    <xsl:variable name="fixedCollectionPath" select="concat(collectionPath, if (ends-with($collectionPath, '/')) then '' else '/')"/>
    <xsl:variable name="fileToSave" select="concat($fixedCollectionPath, 'imageList.txt')"/>
    <xsl:variable name="coll" select="collection(concat($fixedCollectionPath, '?*.xml'))"/>
    <xsl:call-template name="hcmc:createImageList">
      <xsl:with-param name="coll" select="$coll"/>
    <xsl:with-param name="fileToSave" select="$fileToSave"/>
    </xsl:call-template>
  </xsl:template>
  
</xsl:stylesheet>