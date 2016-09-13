<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Sep 13, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      
      <xd:p>The purpose of this spreadsheet is to pre-process some HOCR 
      documents obtained from Google, in order to bring them into line 
      with the structure and format of the HOCR documents we generate 
      for other datasets using Tesseract. Once they're massaged into 
      similarity, they can enter the same processing and editing chain 
      as the rest of our data.</xd:p>
      
      <xd:p>The incoming data is standard HOCR (i.e. XHTML 1.1) but it 
      has some specific differences, documented and dealt with below. 
      The process takes the form of a standard identity transform.</xd:p>
      
    </xd:desc>
  </xd:doc>
  
  <xsl:template match="/">
    <xsl:apply-templates mode="#default"/>
  </xsl:template>
  
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>The Google ocr system identifier is insanely long and complicated. Junk it.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="meta[@name='ocr-system']">
    <meta name="ocr-system" content="google"/>
  </xsl:template>
  
  <xd:doc scope="component">
    <xd:desc>
      
      <xd:p>One specific difference lies in the names of segments. Tesseract 3
        gives us these:
        
        ocr_page ocr_carea ocr_par ocr_line ocrx_word
        
        while the Google data has these:
        
        ocr_page ocr_par ocr_block ocrx_block ocrx_word ocrp_lang ocr_line
        
        So the equivalences are, we presume:
        
        ocr_page      ocr_page
        ocr_carea     ???
        ???           ocr_block    (listed but apparently not used)
        ???           ocrx_block
        ocr_par       ocr_par
        ocr_line      ocr_line
        ocrx_word     ocrx_word
        
        This means that I think we can presume the equivalence of ocr_carea and 
        ocrx_block, and convert the latter into the former.
        
      </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="@class">
    <xsl:choose>
      <xsl:when test=".='ocrx_block'">
        <xsl:attribute name="class" select="'ocr_carea'"/>
      </xsl:when>
      <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>
        The Google content has some very detailed style information which we don't
        really need. Even normalizing it to strong and em elements reveals that most
        if not all of it is simply wrong, so we discard it in favour of having human
        editors add bold and italic where required.
      </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="@style"/>
<!--  Old version which normalized. -->
  <!--<xsl:template match="span[@style]">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="matches(@style, 'bold') and matches(@style, 'italic')">
          <strong><em><xsl:apply-templates select="@*[not(local-name(.)='style')] | node()"/></em></strong>
        </xsl:when>
        <xsl:when test="matches(@style, 'bold')">
          <strong><xsl:apply-templates select="@*[not(local-name(.)='style')] | node()"/></strong>
        </xsl:when>
        <xsl:when test="matches(@style, 'italic')">
          <em><xsl:apply-templates select="@*[not(local-name(.)='style')] | node()"/></em>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@*[not(local-name(.)='style')] | node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>-->
  
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>
        There are sequences of empty blocks which we don't need to keep; we'll just keep the first one, 
        and also eliminate some whitespace.
      </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="div[@class='ocrx_block'][normalize-space(.) = ''][preceding-sibling::*[1][self::div[@class='ocrx_block'][normalize-space(.) = '']]]"/>
  <xsl:template match="text()[normalize-space(.) = ''][preceding-sibling::*[1][self::div[@class='ocrx_block'][normalize-space(.) = ''][preceding-sibling::*[self::div[@class='ocrx_block'][normalize-space(.) = '']]]]]"/>
  
<!-- Default identity transform. -->
  <xsl:template match="@*|node()" priority="-1" mode="#all">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>