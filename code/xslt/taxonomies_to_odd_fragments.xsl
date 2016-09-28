<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  >
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> September 28, 2016 based on a similar library from the MoEML project.</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This transformation processes the taxonomies.xml file and the tccd.odd file to 
      modify the latter, building valLists for key attributes from taxonomies which will then be built into the 
      schema. It should be run on the ODD file, and will find the taxonomy file and load it.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  
  <xsl:param name="taxonomyFilePath" select="'../../data/schemas/taxonomies.xml'"/>
  <xsl:param name="taxonomyFile" select="doc($taxonomyFilePath)"/>
  
  <xsl:template match="/">
    <xsl:message>Processing taxonomies comprising <xsl:value-of select="count($taxonomyFile/descendant::category)"/> categories.</xsl:message>
    <xsl:apply-templates/>
  </xsl:template>
  
<!-- Template for name/@ref. -->
  <xsl:template match="elementSpec[@ident='name']/attList/attDef[@ident='ref']/valList">
    <valList type="closed">
      <xsl:copy-of select="valItem[@ident='unspecified']"/>
      <xsl:for-each select="$taxonomyFile/descendant::taxonomy[@xml:id = 'tccdLegislatures']/descendant::category">
        <!--<xsl:sort select="@xml:id"/>-->
          <valItem ident="lg:{@xml:id}">
            <xsl:copy-of select="gloss"/>
            <xsl:copy-of select="desc"/>
          </valItem>
      </xsl:for-each>
    </valList>
  </xsl:template>
  
  
<!-- Standard identity transformation. -->
  <xsl:template match="@* | node()" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>