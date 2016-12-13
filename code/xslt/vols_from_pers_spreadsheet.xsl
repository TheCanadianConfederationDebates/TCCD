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
  
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Dec 5, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This file is designed to extract some specific information
      from a processed FODS file created from the personography spreadsheet. 
      Specifically, for each affiliation (=year and riding) for each individual
      (= unique person id), it creates an item in a list which can be used to 
      later update the TEI personography.xml file with key information based
      on a yet-to-be-constructed bibliography of source volumes.</xd:p>
      
      <xd:p>
        This is necessitated by an unwise decision earlier in the conversion 
        of the personography spreadsheet to throw away this particular information
        on the grounds that it would not be necessary. It turns out it is. :-)
      </xd:p>
      
      <xd:p>The case of Manitoba in 1870:
        Most reps will have two entries for that year: 
        
        1. Convention of 40: 1870-01-25
        2. Manitoba Provisional Government: 1870-03-09
        
      </xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:include href="fods_module.xsl"/>
  
  <xsl:output method="xml" encoding="UTF-8" normalization-form="NFC" indent="yes" exclude-result-prefixes="#all"/>
  
  <xsl:variable name="inSheet" select="doc('../../data/personography_expanded.fods')"/>
  
  <xsl:variable name="headerRow" select="//table:table-row[1]"/>
  
<!--    First we figure out some stuff. -->
  <xsl:variable name="bcLegCol" select="hcmc:getColOffsetFromCaption('BC Leg', $headerRow)"/>
  <xsl:variable name="bcHofCCol" select="hcmc:getColOffsetFromCaption('BC H of C', $headerRow)"/>
  <xsl:variable name="abskLegCol" select="hcmc:getColOffsetFromCaption('Alb/Sask Legislative Assembly', $headerRow)"/>
  <xsl:variable name="abskHofCCol" select="hcmc:getColOffsetFromCaption('Alb/Sask H of C', $headerRow)"/>
  <xsl:variable name="manConvCol" select="hcmc:getColOffsetFromCaption('Manitoba Convention', $headerRow)"/>
  <xsl:variable name="manProvGovCol" select="hcmc:getColOffsetFromCaption('Manitoba Provisional', $headerRow)"/>
  <xsl:variable name="manHofCCol" select="hcmc:getColOffsetFromCaption('Manitoba H of C', $headerRow)"/>
  <xsl:variable name="ontqueLegCol" select="hcmc:getColOffsetFromCaption('Ont/Que', $headerRow)"/>
  <xsl:variable name="nbLegCol" select="hcmc:getColOffsetFromCaption('NB - ', $headerRow)"/>
  <xsl:variable name="nsLegCol" select="hcmc:getColOffsetFromCaption('NS ', $headerRow)"/>
  <xsl:variable name="peiLegCol" select="hcmc:getColOffsetFromCaption('PEI ', $headerRow)"/>
  <xsl:variable name="peiHofCCol" select="hcmc:getColOffsetFromCaption('PEI H of C ', $headerRow)"/>
  <xsl:variable name="nfLegCol" select="hcmc:getColOffsetFromCaption('Nfld Legislative', $headerRow)"/>
  <xsl:variable name="nfHofCCol" select="hcmc:getColOffsetFromCaption('Nfld H of C ', $headerRow)"/>
  <xsl:variable name="nfNatConvCol" select="hcmc:getColOffsetFromCaption('NFLD National Convention', $headerRow)"/>

  <xsl:variable name="dateRow" select="hcmc:getColOffsetFromCaption('Debate / Negotiation Year', $headerRow)"/>
  
  <xsl:variable name="ridingRow" select="hcmc:getColOffsetFromCaption('Riding', $headerRow)"/>
  
  
  
  <xsl:template match="/">
    
    <TEI xml:id="affils_to_volumes" version="5.0">
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title>Temporary list of source volumes for affiliations</title>
            <author>Martin Holmes</author>
          </titleStmt>
          <publicationStmt><p>Temporary file not intended for publication</p></publicationStmt>
          <sourceDesc><p>Generated file.</p></sourceDesc>
        </fileDesc>
      </teiHeader>
      <text>
        <body>
          <div>
            <list>
              <xsl:for-each select="//table:table-row[position() gt 1]">
                <item>
                  <xsl:variable name="thisId" select="normalize-space(table:table-cell[1])"/>
                  <xsl:variable name="thisYear" select="normalize-space(table:table-cell[$dateRow])"/>
                  <xsl:variable name="thisRiding" select="normalize-space(table:table-cell[$ridingRow])"/>
                  <xsl:variable name="biblRefs" select="hcmc:getBiblRefs(.)"/>
                  <xsl:variable name="dateToUse" select="if (($thisYear = '1870') and ('manConv' = $biblRefs)) then '1870-01-25' else if (($thisYear = '1870') and ('manProvGov' = $biblRefs)) then '1870-03-09' else $thisYear"/>
                  <xsl:for-each select="$biblRefs">
                    <ptr target="pers:{$thisId}" type="{.}" subtype="{$thisRiding}" n="{$dateToUse}"/>
                  </xsl:for-each>
                </item>
              </xsl:for-each>
            </list>
          </div>
        </body>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:function name="hcmc:getBiblRefs" as="xs:string*">
    <xsl:param name="row" as="element(table:table-row)"/>
    <xsl:variable name="result" as="xs:string*">
      <xsl:if test="normalize-space($row/table:table-cell[$bcLegCol]) != ''">bcLeg</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$bcHofCCol]) != ''">bcHofC</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$abskLegCol]) != ''">abskLeg</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$abskHofCCol]) != ''">abskHofC</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$manConvCol]) != ''">manConv</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$manProvGovCol]) != ''">manProvGov</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$manHofCCol]) != ''">manHofC</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$nsLegCol]) != ''">nsLeg</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$ontqueLegCol]) != ''">ontqueLeg</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$nbLegCol]) != ''">nbLeg</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$peiLegCol]) != ''">peiLeg</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$peiHofCCol]) != ''">peiHofC</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$nfLegCol]) != ''">nfLeg</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$nfHofCCol]) != ''">nfHofC</xsl:if>
      <xsl:if test="normalize-space($row/table:table-cell[$nfNatConvCol]) != ''">nfNatConv</xsl:if>
    </xsl:variable>
    
    <xsl:sequence select="$result"/>
    
  </xsl:function>
  
</xsl:stylesheet>