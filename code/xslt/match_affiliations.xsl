<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> May 24, 2017</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>Process to check each affiliation in the personography file against 
      potential placeography entries. Produces a report in text format.
      Run this file on itself; it loads its data from files.</xd:p>
      
      <xd:p>It also process the actual personography file to produce an
      output file which adds @ref attributes to affiliation elements which
      have been matched.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xml" encoding="UTF-8" normalization-form="NFC"/>
  
  <xsl:variable name="personography" select="doc('../../data/personography/personography.xml')"/>
  
  <xsl:variable name="placeography" select="doc('../../data/placeography/placeography.xml')"/>
  
  <xsl:template match="/">
    <!--<xsl:for-each select="$personography//person">
      
      <xsl:variable name="currPerson" select="concat(normalize-space(ancestor::person/persName), ' (', ancestor::person/@xml:id, ')')"/>
      <xsl:for-each select="affiliation[@n]">
        <xsl:variable name="currAffil" select="."/>
        <xsl:variable name="currType" select="if (contains(@n, 'House of Commons')) then 'federal' else 'nonFederal'"/>
        <xsl:variable name="currYear" select="@when"/>
        <xsl:variable name="currRidingName" select="hcmc:massageForMatch($currAffil)"/>
        <xsl:variable name="currRegion" select="hcmc:getRegionFromN(@n)"/>
        <xsl:variable name="matchingPlaces" select="hcmc:getMatchingPlaces($currType, $currRegion, $currRidingName)"/>
        <xsl:choose>
          <xsl:when test="count($matchingPlaces) gt 0">
            <xsl:text>
Found </xsl:text><xsl:value-of select="count($matchingPlaces)"/><xsl:text> match(es) for </xsl:text><xsl:value-of select="concat(string-join($currRegion, ' | '), '/', $currRidingName, ' (', $currYear, ')')"/>
            <xsl:for-each select="$matchingPlaces">
              <xsl:text>
                     </xsl:text><xsl:value-of select="concat(placeName/region, '/', placeName/district, ' (', location/@notBefore, '-', location/@notAfter, ')')"/>
              
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>
              No matching place for </xsl:text><xsl:value-of select="concat(string-join($currRegion, ' | '), '/', $currRidingName, ' (', $currYear, ')')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:for-each>-->
    
<!--  Process the actual personography to see what we get.  -->
    <xsl:result-document href="../../data/personography/personography_linked.xml" method="xml" encoding="UTF-8"
      normalization-form="NFC" exclude-result-prefixes="#all" xml:space="preserve">
      <xsl:apply-templates select="$personography/node()"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="affiliation[@n]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="currPerson" select="concat(normalize-space(ancestor::person/persName), ' (', ancestor::person/@xml:id, ')')"/>
      <xsl:variable name="currAffil" select="."/>
      <xsl:variable name="currType" select="if (contains(@n, 'House of Commons')) then 'federal' else 'nonFederal'"/>
      <xsl:variable name="currYear" select="@when"/>
      <xsl:variable name="currRidingName" select="hcmc:massageForMatch($currAffil)"/>
      <xsl:variable name="currRegion" select="hcmc:getRegionFromN(@n)"/>
      <!--<xsl:message><xsl:value-of select="concat('Trying to match: ', $currRidingName, ' (', $currRegion, '), ', $currYear, ' [', $currType, ']')"/></xsl:message>-->
      <xsl:variable name="matchingPlaces" select="hcmc:getMatchingPlaces($currType, $currRegion, $currRidingName)"/>
      <xsl:if test="$matchingPlaces[location/@notBefore le $currYear and (location/@notAfter gt $currYear or not(location/@notAfter))]">
        <xsl:attribute name="ref" select="concat('plc:', $matchingPlaces[location/@notBefore le $currYear and (location/@notAfter gt $currYear or not(location/@notAfter))][1]/@xml:id)"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
<!-- Identity transform templates for the personography. -->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- This function creates a "massaged" version of a text node for comparison purposes. -->
  <xsl:function name="hcmc:massageForMatch" as="xs:string">
    <xsl:param name="inString" as="xs:string"/>
    <xsl:value-of select="replace(upper-case(normalize-space(replace(translate($inString, '-', ' '), '\p{P}+', ''))), '(^|\s)ST\s', '$1SAINT ')"/>
  </xsl:function>
  
  <xsl:function name="hcmc:getRegionFromN" as="xs:string*">
    <xsl:param name="inString" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="contains($inString, 'House of Commons')">
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:when test="contains($inString, 'MB')">MANITOBA</xsl:when>
      <xsl:when test="contains($inString, 'NB')">NEW BRUNSWICK</xsl:when>
      <xsl:when test="contains($inString, 'Ont/Que')"><xsl:sequence select="('ONTARIO', 'QUEBEC', 'PROVINCE OF CANADA LEGISLATIVE COUNCIL')"/></xsl:when>
      <xsl:when test="contains($inString, 'NF')">NEWFOUNDLAND</xsl:when>
      <xsl:when test="contains($inString, 'AB/SK')"><xsl:sequence select="('ALBERTA', 'SASKATCHEWAN')"/></xsl:when>
      <xsl:when test="contains($inString, 'AB')">ALBERTA</xsl:when>
      <xsl:when test="contains($inString, 'SK')">SASKATCHEWAN</xsl:when>
      <xsl:when test="contains($inString, 'PEI')">PRINCE EDWARD ISLAND</xsl:when>
      <xsl:when test="contains($inString, 'BC')">BRITISH COLUMBIA</xsl:when>
      <xsl:when test="contains($inString, 'NS')">NOVA SCOTIA</xsl:when>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="hcmc:getMatchingPlaces" as="element(place)*">
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="region" as="xs:string*"/>
    <xsl:param name="riding" as="xs:string"/>
    <!--<xsl:for-each select="$placeography//place[@type=$type]">
      <xsl:message><xsl:value-of select="concat('Matching against: ', hcmc:massageForMatch(placeName/district), ' (', hcmc:massageForMatch(placeName/region), '), ', location/@notBefore)"/></xsl:message>
    </xsl:for-each>-->
    <xsl:sequence select="$placeography//place[@type=$type][hcmc:massageForMatch(placeName/region) = $region or normalize-space(string-join($region, '')) = ''][hcmc:massageForMatch(placeName/district) = $riding]"/>
  </xsl:function>
  
</xsl:stylesheet>