<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Dec 12, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This is a one-time-use transformation to merge information
      about the legislature a particular individual was in when representing
      a specific riding in a specific year into the already-created personography
      file.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xml" encoding="UTF-8" normalization-form="NFC" indent="yes"/>
  
  <xsl:variable name="affilData" select="doc('../../data/personography/affils_to_volumes.xml')"/>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
<!-- Match the affiliation and add the extra info in @n attribute. -->
  <xsl:template match="affiliation">
    <affiliation>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="persRef" select="concat('pers:', ancestor::person/@xml:id)"/>
      <xsl:variable name="pos" select="count(preceding-sibling::affiliation) + 1"/>
      <xsl:variable name="legId" select="$affilData//ref[@target=$persRef][@n=$pos]"/>
      <xsl:if test="$legId">
        <xsl:attribute name="n" select="hcmc:getExplanation($legId)"/>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </affiliation>
  </xsl:template>
  
  
<!-- Identity transform. -->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="hcmc:getExplanation" as="xs:string">
    <xsl:param name="legId" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$legId='bcLeg'">BC Leg</xsl:when>
      <xsl:when test="$legId='bcHofC'">BC House of Commons</xsl:when>
      <xsl:when test="$legId='abskLeg'">AB/SK Leg</xsl:when>
      <xsl:when test="$legId='abskHofC'">AB/SK House of Commons</xsl:when>
      <xsl:when test="$legId='manConv'">MB Convention of 40</xsl:when>
      <xsl:when test="$legId='manProvGov'">MB Government</xsl:when>
      <xsl:when test="$legId='manHofC'">MB House of Commons</xsl:when>
      <xsl:when test="$legId='nsLeg'">NS Leg</xsl:when>
      <xsl:when test="$legId='ontqueLeg'">Ont/Que Leg</xsl:when>
      <xsl:when test="$legId='nbLeg'">NB Leg</xsl:when>
      <xsl:when test="$legId='peiLeg'">PEI Leg</xsl:when>
      <xsl:when test="$legId='peiHofC'">PEI House of Commons</xsl:when>
      <xsl:when test="$legId='nfLeg'">NF Leg</xsl:when>
      <xsl:when test="$legId='nfHofC'">NF House of Commons</xsl:when>
      <xsl:when test="$legId='nfNatConv'">NF National Convention</xsl:when>
      
      <xsl:otherwise>Unknown legislature</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>