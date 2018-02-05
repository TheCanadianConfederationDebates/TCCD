<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:x="urn:schemas-microsoft-com:office:excel"
  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:html="http://www.w3.org/TR/REC-html40"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Feb 5, 2018</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>Transform to create TEI file for the source of images
      in the personography.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:variable name="imageSources" select="doc('../../data/personography/portrait_sources.xml')"/>
  
  <xsl:include href="tei_to_html_globals_module.xsl"/>
  
  <xsl:output method="xml" encoding="UTF-8" indent="yes" normalization-form="NFC" exclude-result-prefixes="#all"/>
  
  <xsl:template match="tei:person/tei:persName">
    <xsl:next-match/>
    <xsl:variable name="currId" select="parent::tei:person/@xml:id"/>
    <xsl:if test="matches($portraitList, concat('\|', $currId, '\.jpg\|'))">
      <figure>
        <graphic url="portraits/{$currId}.jpg"/>
        <xsl:variable name="provenanceRow" select="$imageSources//Row[Cell[1][normalize-space(.) = $currId]]"/>
        <xsl:if test="$provenanceRow">
          <listRef>
            <xsl:variable name="sourceInstitution" select="normalize-space($provenanceRow/Cell[2])"/>
            <xsl:variable name="enUrl" select="if (count($provenanceRow/Cell) lt 4) then normalize-space($provenanceRow/Cell[3]) else 
              if ($sourceInstitution = 'LAC') then concat('http://collectionscanada.gc.ca/pam_archives/index.php?fuseaction=genitem.displayItem&amp;rec_nbr=', normalize-space($provenanceRow/Cell[3]), '&amp;lang=eng')
              else if (matches($provenanceRow/Cell[3], '^\s*http')) then normalize-space($provenanceRow/Cell[3])
              else if (matches($provenanceRow/Cell[4], '^\s*http')) then normalize-space($provenanceRow/Cell[4]) else 'WARNING: NO URL AVAILABLE.'"/>
            <xsl:variable name="frUrl" select="replace(if (count($provenanceRow/Cell) lt 4) then normalize-space($provenanceRow/Cell[3]) else 
              if ($sourceInstitution = 'LAC') then concat('http://collectionscanada.gc.ca/pam_archives/index.php?fuseaction=genitem.displayItem&amp;rec_nbr=', normalize-space($provenanceRow/Cell[3]), '&amp;lang=fra')
              else if (matches($provenanceRow/Cell[3], '^\s*http')) then normalize-space($provenanceRow/Cell[3])
              else if (matches($provenanceRow/Cell[4], '^\s*http')) then normalize-space($provenanceRow/Cell[4]) else 'WARNING: NO URL AVAILABLE.', '/en_CA/', '/fr_CA/')"/>
            
            <ref  target="{$enUrl}" xml:lang="en"><xsl:value-of select="$sourceInstitution"/></ref>
            <ref target="{$frUrl}" xml:lang="fr"><xsl:value-of select="replace($sourceInstitution, 'Canadian Parliament', 'Parlement du Canada')"/></ref>
          </listRef>
        </xsl:if>
      </figure>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>