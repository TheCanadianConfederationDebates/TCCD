<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns="http://www.tei-c.org/ns/1.0" xmlns:xh="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Jan 23 2018</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>Simple identity transformwhose purpose is to move column numbers
        which were auto-encoded in the wrong place to the head of their columns.
        See issue #107.
      </xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xml" encoding="UTF-8" normalization-form="NFC" exclude-result-prefixes="#all"/>
  
  <xsl:template match="fw[@type='num'][preceding-sibling::*[1][self::fw[@type='num']] or preceding-sibling::*[2][self::fw[@type='num']]]"/>
  
  <xsl:template match="cb">
    <xsl:copy-of select="."/>
    <xsl:text>
     </xsl:text>
      <fw rendition="simple:right">
        <xsl:copy-of select="preceding::fw[@type='num'][1]/@*"/>
        <xsl:copy-of select="preceding::fw[@type='num'][1]/node()"/>
      </fw>
      
      
    
  </xsl:template>
  
<!-- Identity transform template. -->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>