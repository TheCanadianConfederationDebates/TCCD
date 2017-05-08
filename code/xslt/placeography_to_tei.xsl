<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
  xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
  xmlns:presentation="urn:oasis:names:tc:opendocument:xmlns:presentation:1.0"
  xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
  xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
  xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
  xmlns:math="http://www.w3.org/1998/Math/MathML"
  xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
  xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
  xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
  xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer"
  xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events"
  xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:rpt="http://openoffice.org/2005/report"
  xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:grddl="http://www.w3.org/2003/g/data-view#"
  xmlns:tableooo="http://openoffice.org/2009/table" xmlns:drawooo="http://openoffice.org/2010/draw"
  xmlns:calcext="urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0"
  xmlns:loext="urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0"
  xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0"
  xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0"
  xmlns:css3t="http://www.w3.org/TR/css3-text/"
  exclude-result-prefixes="#all"
  xmlns="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> 2017-05-08</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>The purpose of this spreadsheet is to processed an expanded FODS file created 
      by processing a standard FODS version of the parliamentary sheet from the placeography file downloaded from
      Google Sheets here: 
      https://docs.google.com/spreadsheets/d/1Eci1nYqYoGwnc0xAMNPNvwvUtv-6UXrJzHc_3v1KNvM
      to create a TEI file containing a complete list of ridings and their locations for the project.</xd:p>
      <xd:p>This is not a generic process; the FODS file is idiosyncratic and the processing 
      involves assumptions and knowledge about the structure of the original spreadsheet data.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:include href="utilities_module.xsl"/>
  
  <xsl:output method="xml" encoding="UTF-8" exclude-result-prefixes="#all" normalization-form="NFC" indent="yes"/>
  
  <!-- Wherever this gets called from, we want to do things relative to its actual location. -->
  <xsl:variable name="baseDir" select="replace(document-uri(/), concat(tokenize(document-uri(/), '/')[last()], '$'), '')"/>
  
<!-- We may have some personography information in another existing TEI file that 
     will need to be combined with the incoming data. If so, this variable says 
     where that file is to be found. -->
  <xsl:param name="personography" select="doc(concat($baseDir, '../../data/personography/personography.xml'))"/>
  
<!-- Input document root may need to be accessible from functions etc. -->
  <xsl:variable name="docRoot" select="/"/>
  
<!-- The header row is our method of looking up data. We assume it's
     the first row, but allow for override. -->
  <xsl:param name="headerRowPos" as="xs:integer" select="1"/>
  <xsl:variable name="headerRow" select="$docRoot//table:table-row[$headerRowPos]"/>
    
  <!--  Find a variety of column offsets we're going to need.            -->
  <xsl:variable name="idCol" select="hcmc:getColOffsetFromCaption('xml:id')"/>
  <xsl:variable name="mapCol" select="hcmc:getColOffsetFromCaption('Map')"/>
  <xsl:variable name="dateCol" select="hcmc:getColOffsetFromCaption('Election / Signing Date')"/>
  <xsl:variable name="electionTypeCol" select="hcmc:getColOffsetFromCaption('Election Type')"/>
  <xsl:variable name="parliamentCol" select="hcmc:getColOffsetFromCaption('Parliament')"/>
  <xsl:variable name="provinceTreatyCol" select="hcmc:getColOffsetFromCaption('Province / Treaty #')"/>
  <xsl:variable name="ridingCol" select="hcmc:getColOffsetFromCaption('Riding / Place of Negotiation')"/>
  <xsl:variable name="placeOfSigningCol" select="hcmc:getColOffsetFromCaption('Place of Signing')"/>
  <xsl:variable name="lastNameCol" select="hcmc:getColOffsetFromCaption('Last Name')"/>
  <xsl:variable name="firstNameCol" select="hcmc:getColOffsetFromCaption('First Name')"/>
  <xsl:variable name="middleNameCol" select="hcmc:getColOffsetFromCaption('Middle Name (s)')"/>
  <xsl:variable name="occupationCol" select="hcmc:getColOffsetFromCaption('Occupation')"/>
  <xsl:variable name="partyCol" select="hcmc:getColOffsetFromCaption('Party')"/>
  <xsl:variable name="votesCol" select="hcmc:getColOffsetFromCaption('Votes')"/>
  <xsl:variable name="votesPercentCol" select="hcmc:getColOffsetFromCaption('Votes (%)')"/>
  <xsl:variable name="electedCol" select="hcmc:getColOffsetFromCaption('Elected')"/>
  <xsl:variable name="treatySignersCol" select="hcmc:getColOffsetFromCaption('Treaty Signatories')"/>
  <xsl:variable name="latLongCol" select="hcmc:getColOffsetFromCaption('Latitude / Longitude')"/>
  <xsl:variable name="commentsCol" select="hcmc:getColOffsetFromCaption('Comments')"/>
    
  <xsl:template match="/">

    
    <xsl:variable name="newPlaces">
      <listPlace xml:id="ridings">



        <xsl:variable name="provRidings" select="for $r in //table:table-row[position() gt 1] return hcmc:getMassagedIdentifier($r)"/>

        <xsl:variable name="distinctProvRidings" select="distinct-values($provRidings)"/>
        
        <xsl:message>Found <xsl:value-of select="count($provRidings)"/> riding rows, of which <xsl:value-of select="count($distinctProvRidings)"/> are distinct.</xsl:message>
        
        <xsl:variable name="sortedDistinctRidings" as="xs:string+">
          <xsl:for-each select="$distinctProvRidings">
            <xsl:sort select="."/>
            <xsl:value-of select="."/>
          </xsl:for-each>
        </xsl:variable>
        
        <xsl:message select="string-join($sortedDistinctRidings, '&#x0a;')"/>
        
        <xsl:for-each select="$distinctProvRidings">
          <xsl:variable name="currRiding" select="."/>
<!-- Get the list of rows for this prov/riding.         -->
          <xsl:variable name="currRidingRows" select="$docRoot//table:table-row[hcmc:getMassagedIdentifier(.) = $currRiding]"/>
          <xsl:variable name="distinctCoords" select="distinct-values(for $r in $currRidingRows return replace($r/table:table-cell[$latLongCol], '\s+', ''))"/>
          <xsl:for-each select="$distinctCoords">
            <xsl:variable name="currCoords" select="."/>
            <xsl:variable name="recsForTheseCoords" select="$currRidingRows[replace(table:table-cell[$latLongCol], '\s+', '') = $currCoords]"/>
            <place n="{$recsForTheseCoords[1]/table:table-cell[$idCol]}" type="{if (ends-with($currRiding, '|P')) then 'federal' else 'nonFederal'}">
              <xsl:sequence select="hcmc:getMassagedPlaceName($recsForTheseCoords[1])"/>
              <date notBefore="{hcmc:getMinDate($recsForTheseCoords)}" notAfter="{hcmc:getMaxDate($recsForTheseCoords)}"/>
            </place>
          </xsl:for-each>
          
        </xsl:for-each>
        
      </listPlace>
    </xsl:variable>
    
    <xsl:result-document href="{concat($baseDir, 'tempPlaces.xml')}" method="xml">
      <xsl:sequence select="$newPlaces"/>
    </xsl:result-document>
    

  </xsl:template>

<!-- Fix curly quotes. -->
  <xsl:template match="text()" mode="#all">
    <xsl:value-of select="hcmc:straightenQuotes(.)"/>
  </xsl:template>



<!--  Identity transform. -->
  <xsl:template match="@*|node()" mode="#all" priority="-1">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
<!-- FUNCTIONS.  -->
  
<!-- This function discovers the offset of a column based on a 
     complete or partial caption, by looking at the header row. -->
  <xsl:function name="hcmc:getColOffsetFromCaption" as="xs:integer">
    <xsl:param name="caption" as="xs:string"/>
    <xsl:choose>
<!--    Perfect match: best case.  -->
      <xsl:when test="$headerRow/table:table-cell[.=$caption]">
        <xsl:value-of select="count($headerRow/table:table-cell[.=$caption][1]/preceding-sibling::table:table-cell) + 1"/>
      </xsl:when>
<!--      If no perfect match, look for a partial match. -->
      <xsl:when test="$headerRow/table:table-cell[contains(., $caption)]">
        <xsl:value-of select="count($headerRow/table:table-cell[contains(., $caption)][1]/preceding-sibling::table:table-cell) + 1"/>
      </xsl:when>
<!--      Fall back to a case-insensitive partial match. -->
      <xsl:when test="$headerRow/table:table-cell[contains(lower-case(.), lower-case($caption))]">
        <xsl:value-of select="count($headerRow/table:table-cell[contains(lower-case(.), lower-case($caption))][1]/preceding-sibling::table:table-cell) + 1"/>
      </xsl:when>
      <xsl:otherwise>
<!--       Not found. Return zero.  -->
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:function>
  
<!-- This function creates a "massaged" version of a text node for comparison purposes. -->
  <xsl:function name="hcmc:massageForMatch" as="xs:string">
    <xsl:param name="inString" as="xs:string"/>
    <xsl:value-of select="replace(upper-case(normalize-space(replace(translate($inString, '-', ' '), '\p{P}+', ''))), '(^|\s)ST\s', '$1SAINT ')"/>
  </xsl:function>
  
<!-- This function gets the massaged concatenated values of three key cells in a row,
     for comparison purposes. -->
  <xsl:function name="hcmc:getMassagedIdentifier" as="xs:string">
    <xsl:param name="row" as="element(table:table-row)"/>
    <xsl:value-of select="concat(
      hcmc:massageForMatch($row/table:table-cell[$provinceTreatyCol]), '|', 
      hcmc:massageForMatch($row/table:table-cell[$ridingCol]), 
      if (string-length(normalize-space($row/table:table-cell[$parliamentCol])) gt 0) then '|P' else '')"/>
  </xsl:function>
  
  <!-- This function gets a TEI placename element from a . -->
  <xsl:function name="hcmc:getMassagedPlaceName" as="element(placeName)">
    <xsl:param name="row" as="element(table:table-row)"/>
    <placeName>
      <state><xsl:value-of select="upper-case(normalize-space(replace($row/table:table-cell[$provinceTreatyCol], '[\-‒–—―+]', '-')))"/></state>
      <region><xsl:value-of select="upper-case(normalize-space(replace($row/table:table-cell[$ridingCol], '[\-‒–—―+]', '-')))"/></region>
    </placeName>
  </xsl:function>
  
<!-- This function, passed a set of table rows, gets the lowest date year from the date column. -->
  <xsl:function name="hcmc:getMinDate" as="xs:string">
    <xsl:param name="rows" as="element(table:table-row)+"/>
    <xsl:variable name="years" as="xs:integer+" select="for $r in $rows return xs:integer(tokenize($r/table:table-cell[$dateCol], '/')[last()])"/>
    <xsl:value-of select="min($years)"/>
  </xsl:function>
  
  <!-- This function, passed a set of table rows, gets the highest date year from the date column. -->
  <xsl:function name="hcmc:getMaxDate" as="xs:string">
    <xsl:param name="rows" as="element(table:table-row)+"/>
    <xsl:variable name="years" as="xs:integer+" select="for $r in $rows return xs:integer(tokenize($r/table:table-cell[$dateCol], '/')[last()])"/>
    <xsl:value-of select="max($years)"/>
  </xsl:function>
</xsl:stylesheet>
