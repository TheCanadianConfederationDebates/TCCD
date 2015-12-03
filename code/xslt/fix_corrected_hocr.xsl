<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  version="2.0">
<!-- NOTE: MOST OF WHAT'S PROMISED BELOW IS NOT YET THERE! -->
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Nov 27, 2015</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This identity transform takes the enhanced HOCR files we have previously
        created which were used for correction, and removes all the enhanced features
        to return the file to a basic HOCR format. It also does a number of other cunning
        manipulations: 
          - Strips all the line-level markup, leaving para- and word-level encoding, which allows 
            the hocr2pdf tool to read the files successfully and create a text-over-image 
          - Identifies situations in which word elements have been emptied by the correctors,
            and removes them.
          - Where lines have been rewritten completely, removing the word elements, 
            attempts to reconstruct them by calculating plausible box sizes and positions
            for them.
      PDF.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xhtml" encoding="UTF-8" omit-xml-declaration="yes"
    exclude-result-prefixes="#all" normalization-form="NFC"/>

  <xsl:variable name="reBbox" select="'bbox(\s+\d+){4}'"/>
  
  <xsl:template match="span[@class='ocr_line']">
    <xsl:choose>
      <xsl:when test="child::text()[string-length(normalize-space(.)) gt 0]">
        <xsl:sequence select="hcmc:recalculateWordBoxes(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
<!--  
  This function deals with an OCR line which has been edited at the line
  level, meaning that some of its word spans may have been deleted, and
  text content added directly to it. We need to do something about this 
  because the hocr2pdf tool requires word-level spans, not line-level. 
  
  What we attempt to do is process each text node which is a direct
  child of the line, calculating the space available to it, and creating word
  spans which divide that space among the words in the node based 
  on their character length. This is obviously crude but not impractical.
  -->
  <xsl:function name="hcmc:recalculateWordBoxes" as="node()*">
    <xsl:param name="line" as="element(span)"/>
    <xsl:for-each select="$line/node()">
      <xsl:choose>
<!--    If it is a well-formed word element, we spit it out.    -->
        <xsl:when test="self::span[@class='ocrx_word'][matches(@title, $reBbox)]">
          <xsl:copy-of select="."/>
        </xsl:when>
        <xsl:when test="self::text()">
<!-- If it's a text node, we need to calculate the space within which it fits, 
          and then create word-boxes for each word. 
          For starting position:
          If it has a preceding sibling word box with dimensions, 
          we can use the right and top values from that (with a 
          little pad to allow for any space); if it doesn't, then we 
          use the left and top values from the line. 
          For ending position: 
          If it has a following-sibling word box with dimensions,
          we can use the left and top values for that (minus a 
          little pad for the space); if it doesn't, we use the 
          bottom and right values for the line. -->
          
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>
  
<!--  Simple utility functions for grabbing dimensions from title attributes. -->
  <xsl:function name="hcmc:getLeftFromTitleAtt" as="xs:integer">
    <xsl:param name="titleAtt" as="xs:string"/>
    <xsl:value-of select="xs:integer(tokenize(normalize-space(substring-before(substring-after($titleAtt, 'bbox '), ';')), '\s+')[1])"/>
  </xsl:function>
  <xsl:function name="hcmc:getTopFromTitleAtt" as="xs:integer">
    <xsl:param name="titleAtt" as="xs:string"/>
    <xsl:value-of select="xs:integer(tokenize(normalize-space(substring-before(substring-after($titleAtt, 'bbox '), ';')), '\s+')[2])"/>
  </xsl:function>
  <xsl:function name="hcmc:getRightFromTitleAtt" as="xs:integer">
    <xsl:param name="titleAtt" as="xs:string"/>
    <xsl:value-of select="xs:integer(tokenize(normalize-space(substring-before(substring-after($titleAtt, 'bbox '), ';')), '\s+')[3])"/>
  </xsl:function>
  <xsl:function name="hcmc:getBottomFromTitleAtt" as="xs:integer">
    <xsl:param name="titleAtt" as="xs:string"/>
    <xsl:value-of select="xs:integer(tokenize(normalize-space(substring-before(substring-after($titleAtt, 'bbox '), ';')), '\s+')[4])"/>
  </xsl:function>
  
  <!-- Copy everything else as-is. -->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>