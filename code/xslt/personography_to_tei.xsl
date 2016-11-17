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
      <xd:p><xd:b>Created on:</xd:b> 2016-11-07</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>The purpose of this spreadsheet is to processed an expanded FODS file (created 
      by processing a standard FODS version of the personography.ods file downloaded from
      Google Sheets) to create a TEI file containing a complete personography for the project.</xd:p>
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
  <xsl:param name="existingPersonography" select="doc(concat($baseDir, '../../data/personography/personography.xml'))"/>
  
<!-- Input document root may need to be accessible from functions etc. -->
  <xsl:variable name="docRoot" select="/"/>
  
<!-- The header row is our method of looking up data. We assume it's
     the first row, but allow for override. -->
  <xsl:param name="headerRowPos" as="xs:integer" select="1"/>
  <xsl:variable name="headerRow" select="$docRoot//table:table-row[$headerRowPos]"/>
    
  <xsl:template match="/">
    <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="personography">
      <teiHeader>
        <xsl:copy-of select="$existingPersonography//fileDesc"/>
        <profileDesc>
          <particDesc>
            
            <xsl:copy-of select="$existingPersonography//listPerson[not(@xml:id='historicalPersonography')]"/>
            
            <listPerson xml:id="historicalPersonography">
              
<!--  Find a variety of column offsets we're going to need.            -->
              <xsl:variable name="idCol" select="hcmc:getColOffsetFromCaption('xml:id')"/>
              <xsl:variable name="addNameCol" select="hcmc:getColOffsetFromCaption('Title')"/>
              <xsl:variable name="surnameCol" select="hcmc:getColOffsetFromCaption('Last Name')"/>
              <xsl:variable name="firstNameCol" select="hcmc:getColOffsetFromCaption('First Name')"/>
              <xsl:variable name="middleNameCol" select="hcmc:getColOffsetFromCaption('Middle Name')"/>
              <xsl:variable name="yearCol" select="hcmc:getColOffsetFromCaption('Year')"/>
              <xsl:variable name="ridingCol" select="hcmc:getColOffsetFromCaption('Riding')"/>
              <xsl:variable name="roleCol" select="hcmc:getColOffsetFromCaption('Roles')"/>
              <xsl:variable name="enBioLinkCol" select="hcmc:getColOffsetFromCaption('DCB English')"/>
              <xsl:variable name="frBioLinkCol" select="hcmc:getColOffsetFromCaption('DCB French')"/>
              <xsl:variable name="commentsCol" select="hcmc:getColOffsetFromCaption('Comments')"/>
              <xsl:variable name="treatyNumCol" select="hcmc:getColOffsetFromCaption('Treaty #')"/>
              <xsl:variable name="treatyLocCol" select="hcmc:getColOffsetFromCaption('Treaty Signature location')"/>
              
              <xsl:variable name="people">
                <xsl:for-each select="distinct-values(//table:table-row[position() ge 2]/table:table-cell[$idCol]/normalize-space(.))">
                  <xsl:variable name="currId" select="."/>
                  <xsl:if test="$currId ne ''">
                    <person xml:id="{$currId}">
    <!--        We need to retrieve and merge instances of names for this person.
                They may change slightly over time, but if they don't, we may 
                collapse them later on.-->
                      <xsl:variable name="persNames">
                        <xsl:for-each select="$docRoot//table:table-row[normalize-space(table:table-cell[$idCol]) = $currId]">
                          <xsl:sort select="table:table-cell[$yearCol]"/>
                          <xsl:variable name="thisRow" select="."/>
                          <xsl:variable name="currYear" select="normalize-space($thisRow/table:table-cell[$yearCol])"/>
                          <persName when="{$currYear}">
                            <surname><xsl:value-of select="hcmc:normalCaseName($thisRow/table:table-cell[$surnameCol])"/></surname><xsl:if test="string-length(normalize-space($thisRow/table:table-cell[$firstNameCol])) gt 0">,
                            <forename><xsl:value-of select="hcmc:normalCaseName($thisRow/table:table-cell[$firstNameCol])"/></forename></xsl:if>
                            <xsl:if test="string-length(normalize-space($thisRow/table:table-cell[$middleNameCol])) gt 0"><forename><xsl:value-of select="hcmc:normalCaseName($thisRow/table:table-cell[$middleNameCol])"/></forename></xsl:if>
                            <xsl:if test="string-length(normalize-space($thisRow/table:table-cell[$addNameCol])) gt 0"><xsl:text> </xsl:text>(<addName><xsl:value-of select="hcmc:normalCaseName($thisRow/table:table-cell[$addNameCol])"/></addName>)</xsl:if>
                          </persName>
                          
<!--        We get their "affiliation" (usually riding) for this row.                  -->
                          <affiliation when="{$currYear}"><xsl:value-of select="normalize-space($thisRow/table:table-cell[$ridingCol])"/></affiliation>
                          
<!--        We get their role (often within a band or as a representative of some kind) and store it in <state>.   -->
                          <xsl:if test="string-length(normalize-space($thisRow/table:table-cell[$roleCol])) gt 0">
                            <state when="{$currYear}">
                              <label><xsl:value-of select="normalize-space($thisRow/table:table-cell[$roleCol])"/></label>
                              <xsl:variable name="treatyLoc" select="replace(normalize-space($thisRow/table:table-cell[$treatyLocCol]), 'signed at ', '')"/>          <xsl:variable name="treatyNum" select="normalize-space($thisRow/table:table-cell[$treatyNumCol])"/>
                              <xsl:if test="string-length($treatyLoc) gt 0 or string-length($treatyNum) gt 0">
                                <note>
                                  <xsl:if test="string-length($treatyNum) gt 0">Treaty # <num type="treaty"><xsl:value-of select="$treatyNum"/></num>. </xsl:if>
                                  <xsl:if test="string-length($treatyLoc) gt 0">Location: <placeName><xsl:value-of select="$treatyLoc"/></placeName>. </xsl:if>
                                </note>
                              </xsl:if>
                            </state>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>
                      
    <!--      Now we issue a warning if the first and last names don't match, just in case.        -->
                      <xsl:for-each select="$persNames/persName">
                        <xsl:if test="position() gt 1">
                        <xsl:variable name="pos" select="position()"/>
                          <xsl:if test="not(lower-case(surname[1]) = lower-case($persNames/persName[$pos - 1]/surname[1])) or not(lower-case(forename[1]) = lower-case($persNames/persName[$pos - 1]/forename[1]))">
                            <xsl:text>&#x0a;</xsl:text>
                            <xsl:comment>WARNING: person with @xml:id="<xsl:value-of select="$currId"/>" has non-matching names: <xsl:value-of select="concat(surname[1], ', ', forename[1], ' versus ', $persNames/persName[$pos - 1]/surname[1], ', ', $persNames/persName[$pos - 1]/forename[1])"/>.</xsl:comment>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:if>
                        </xsl:if>
                      </xsl:for-each>
                      
    <!--      We currently don't bother trying to collapse the names in the output; it's
              a bit difficult to figure out what constitutes a difference. -->
                      <!--<xsl:sequence select="$persNames"/>-->
                      <xsl:for-each select="$persNames/node()">
                        <xsl:choose>
                          <xsl:when test="self::persName and preceding-sibling::persName">
                            <xsl:if test="not(xs:string(.) = xs:string(preceding-sibling::persName[1]))">
                              <xsl:copy-of select="."/>
                            </xsl:if>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:copy-of select="."/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>

<!--      Now we're dealing with things which SHOULD NOT be different from row to row.                  -->
                      <xsl:variable name="enBioLinks" select="distinct-values($docRoot//table:table-row[normalize-space(table:table-cell[$idCol]) = $currId]/table:table-cell[$enBioLinkCol][string-length(normalize-space(.)) gt 8]/normalize-space(.))"/>
                      <xsl:variable name="frBioLinks" select="distinct-values($docRoot//table:table-row[normalize-space(table:table-cell[$idCol]) = $currId]/table:table-cell[$frBioLinkCol][string-length(normalize-space(.)) gt 8]/normalize-space(.))"/>
                      <xsl:if test="count($enBioLinks) gt 0 or count($frBioLinks) gt 0">
                        <listBibl>
                          <xsl:for-each select="$enBioLinks">
                            <bibl xml:lang="en"><ptr target="{.}"/></bibl>
                          </xsl:for-each>
                          <xsl:for-each select="$frBioLinks">
                            <bibl xml:lang="fr"><ptr target="{.}"/></bibl>
                          </xsl:for-each>
                        </listBibl>
                      </xsl:if>
                      
<!--      Comments columns                -->
                      <xsl:for-each select="distinct-values($docRoot//table:table-row[normalize-space(table:table-cell[$idCol]) = $currId]/table:table-cell[$commentsCol][string-length(normalize-space(.)) gt 0]/normalize-space(.))">
                        <note><xsl:value-of select="."/></note>
                      </xsl:for-each>
                      
                    </person>
                  </xsl:if>
                </xsl:for-each>
              </xsl:variable>
              
              <xsl:result-document href="personography-errors.txt" method="text" encoding="UTF-8" normalization-form="NFC">
                <xsl:for-each select="$people/descendant::comment()">
                  <xsl:text>&#x0a;</xsl:text>
                  <xsl:value-of select="."/>
                  <xsl:text>&#x0a;</xsl:text>
                </xsl:for-each>
              </xsl:result-document>
              <xsl:sequence select="$people"/>
            </listPerson>
          </particDesc>
        </profileDesc>
      </teiHeader>
      <text>
        <body>
          <p>No content: core data is in the header.</p>
        </body>
      </text>
    </TEI>
    

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

</xsl:stylesheet>
