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
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Dec 5, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>Module for FODS-related generic functions.</xd:p>
    </xd:desc>
  </xd:doc>
  
  
  <!-- Spreadsheet files tend to assume a truly huge sheet extending thousands of cells 
     and rows; we assume that above a certain point, these will be pointless empty 
     cells and we discard them. Set this variable based on the scale of your spreadsheet.-->
  <xsl:param name="maxEmptyColumns" as="xs:integer" select="100"/>
  
  <!-- Column headers are usually in the first row, but 
     may not be. -->
  <xsl:param name="colHeaderRow" as="xs:integer" select="1"/>
  
  <!-- It's possible that a header row will have no content 
     in its trailing columns even though following rows do.
     If so, set this to override the result of counting 
     columns in the header row.-->
  <xsl:param name="minColCount" as="xs:integer" select="0"/>
  
  
  <!-- This function discovers the offset of a column based on a 
     complete or partial caption, by looking at the header row. -->
  <xsl:function name="hcmc:getColOffsetFromCaption" as="xs:integer">
    <xsl:param name="caption" as="xs:string"/>
    <xsl:param name="headerRow" as="element(table:table-row)"/>
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
  
  <!-- FUNCTIONS.  -->
  
  <!-- Find the number of columns in the header row which 
     have meaningful content. We will discard all cells 
     beyond this range, since we can assume they're empty.
     But see caveat above in comment on $minColCount param. -->
  <xsl:function name="hcmc:findColCount" as="xs:integer">
    <xsl:param name="headerRow" as="element(table:table-row)"/>
    <xsl:param name="startFrom" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="$startFrom gt count($headerRow/table:table-cell)">
        <xsl:value-of select="max((($startFrom - 1), $minColCount))"/>
      </xsl:when>
      <xsl:when test="$headerRow/table:table-cell[$startFrom]/following-sibling::table:table-cell[string-length(normalize-space(.)) gt 0]">
        <xsl:value-of select="hcmc:findColCount($headerRow, $startFrom+1)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="max(($startFrom, $minColCount))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function> 
  
</xsl:stylesheet>