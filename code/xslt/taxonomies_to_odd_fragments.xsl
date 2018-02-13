<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  version="3.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  >
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> September 28, 2016 based on a similar library from the MoEML project.</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This transformation processes the taxonomies.xml and other authority references and the tccd.odd file to 
      modify the latter, building valLists for key attributes from taxonomies which will then be built into the 
      schema. It should be run on the ODD file, and will find the taxonomy file and load it.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xml" encoding="UTF-8" indent="yes" exclude-result-prefixes="#all"/>
  
<!-- External resources. -->
  <xsl:param name="taxonomyFilePath" select="'../../data/schemas/taxonomies.xml'"/>
  <xsl:param name="personographyFilePath" select="'../../data/personography/personography.xml'"/>
  <xsl:param name="placeographyFilePath" select="'../../data/placeography/placeography.xml'"/>
  <xsl:param name="taxonomyFile" select="doc($taxonomyFilePath)"/>
  <xsl:param name="personographyFile" select="doc($personographyFilePath)"/>
  <xsl:param name="placeographyFile" select="doc($placeographyFilePath)"/>
   
  <xsl:template match="/" exclude-result-prefixes="#all">
    <xsl:message>Processing taxonomies comprising <xsl:value-of select="count($taxonomyFile/descendant::category)"/> categories.</xsl:message>
    <xsl:apply-templates/>
  </xsl:template>
  
<!-- Template for name/@ref. -->
  <xsl:template match="elementSpec[@ident='name']/attList/attDef[@ident='ref']/valList" exclude-result-prefixes="#all">
    <valList type="closed">
      <xsl:copy-of select="valItem[@ident='UNSPECIFIED']"/>
      <xsl:for-each select="$taxonomyFile/descendant::taxonomy[@xml:id = 'tccdLegislatures']/descendant::category">
        <!--<xsl:sort select="@xml:id"/>-->
          <valItem ident="lg:{@xml:id}">
            <xsl:copy-of select="gloss"/>
            <xsl:copy-of select="desc"/>
          </valItem>
      </xsl:for-each>
    </valList>
  </xsl:template>
  
<!-- Template for persName/@ref. -->
  <xsl:template match="elementSpec[@ident='persName']/attList/attDef[@ident='ref']/valList" exclude-result-prefixes="#all">
    <xsl:sequence select="hcmc:listPersonToValList($personographyFile//listPerson, .)"/>
  </xsl:template>
  
  <!-- Template for affiliation/@ref. -->
  <xsl:template match="elementSpec[@ident='affiliation']/attList/attDef[@ident='ref']/valList | elementSpec[@ident='placeName']/attList/attDef[@ident='ref']/valList" exclude-result-prefixes="#all">
    <xsl:sequence select="hcmc:listPlaceToValList($placeographyFile//listPlace, .)"/>
  </xsl:template>
  
  
<!-- Standard identity transformation. -->
  <xsl:template match="@* | node()" priority="-1" exclude-result-prefixes="#all">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
<!-- Functions. -->
  
  <xsl:function name="hcmc:listPersonToValList" as="element(valList)" exclude-result-prefixes="#all">
    <xsl:param name="listPerson" as="element(listPerson)+"/>
    <xsl:param name="valList" as="element(valList)"/>    
    <valList type="closed" mode="add">
        <xsl:copy-of select="$valList/valItem[@ident='UNSPECIFIED']"/>
      <xsl:for-each select="$listPerson//person">
        <xsl:sort select="normalize-space(.)"/>
        <valItem ident="pers:{@xml:id}">
          <!--<gloss><xsl:value-of select="normalize-space(persName[1])"/></gloss>-->
          <xsl:variable name="names" select="string-join((for $p in persName return normalize-space($p)), '; ')"/>
          <desc><xsl:value-of select="$names"/><xsl:if test="not(matches($names, '\.\s*$'))">.</xsl:if><xsl:text> </xsl:text><xsl:if test="affiliation or state"><xsl:value-of select="string-join((for $a in (affiliation | state) return concat(normalize-space($a), ' (', if ($a/@when) then concat($a/@when, ': ') else '', $a/@n, ')')), '; ')"/></xsl:if>.</desc>
        </valItem>
      </xsl:for-each>
    </valList>
  </xsl:function>
  
  <xsl:function name="hcmc:listPlaceToValList" as="element(valList)" exclude-result-prefixes="#all">
    <xsl:param name="listPlace" as="element(listPlace)+"/>
    <xsl:param name="valList" as="element(valList)"/>    
    <valList type="closed" mode="add">
      <xsl:copy-of select="$valList/valItem[@ident='UNSPECIFIED']"/>
      <xsl:for-each select="$listPlace//place">
        <xsl:sort select="normalize-space(@xml:id)"/>
        <valItem ident="plc:{@xml:id}">
          <xsl:variable name="riding" select="concat(placeName/district, ' (', placeName/region, '), ', @type, ', ', location/@notBefore, '-', location/@notAfter)"/>
          <xsl:variable name="reps" select="string-join((for $p in note/list/item/persName return normalize-space($p)), '; ')"/>
          <desc><xsl:value-of select="concat($riding, ' ', $reps)"/></desc>
        </valItem>
      </xsl:for-each>
    </valList>
  </xsl:function>
  
</xsl:stylesheet>