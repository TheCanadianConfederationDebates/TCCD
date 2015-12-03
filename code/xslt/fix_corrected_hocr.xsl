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
        manipulations, including: 
          - stripping all the line-level markup, leaving para- and word-level encoding, which allows 
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

  
  
  <xsl:template match="span[@class='ocr_line']">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Copy everything else as-is. -->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>