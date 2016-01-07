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
      <xd:p><xd:b>Created on:</xd:b> Dec 3, 2015</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This stylesheet processes HOCR files produced by 
      Tesseract in order to add some features helpful for 
      people doing proofing/correction work on them in 
      an editing interface.</xd:p>
      <xd:p>This file is for a single document transformation.
      A bulk transformer is much more efficient, so another 
      module provides that, for use in e.g. Ant processes.</xd:p>
    </xd:desc>
  </xd:doc>
  
  
  <!-- We'll use XHTML 1 strict, because that's what Kompozer and hocr2pdf like. -->
  <xsl:output method="xhtml" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"  normalization-form="NFC" omit-xml-declaration="yes" exclude-result-prefixes="#all" byte-order-mark="no" />
  
  <xsl:variable name="fName" select="substring-before(tokenize(document-uri(/), '[\\/]')[last()], '.hocr')"/>
  
  <xsl:template match="/"><xsl:apply-templates/></xsl:template>
  
  <xsl:template match="head">
    <xsl:copy>
      <xsl:apply-templates/>
      <meta name="status" content="uncorrected"/>
      <style type="text/css">
        body, div, p{
          display: block;
          margin: 0.5em;
        }
        p{
          margin-top: 0;
          margin-bottom: 0;
        }
        
        span[class="ocr_line"]{
        display: block;
        }
        span[class="ocrx_word"][title*="x_wconf 6"], span[class="ocrx_word"][title*="x_wconf 5"], span[class="ocrx_word"][title*="x_wconf 4"], span[class="ocrx_word"][title*="x_wconf 3"], span[class="ocrx_word"][title*="x_wconf 2"], span[class="ocrx_word"][title*="x_wconf 1"], span[class="ocrx_word"][title*="x_wconf 0"]{
        background-color: #ffff00;
        }
        /* div.ocr_page{
          overflow: scroll;
          max-width: 49%;
          max-height: 100%; 
        } */
        p.editorial{
          border: solid 1px black;
          background-color: #c0ffc0;
          padding: 1em;
        }
        div.pageImage{
          position: fixed;
          right: 0;
          overflow: scroll;
          max-width: 49%;
          max-height: 100%;
        }
        div.pageImage img{
          width: 100%;
        }
      </style>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="title">
    <xsl:copy>
      <xsl:value-of select="$fName"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="body">
    <xsl:copy>
      <p class="editorial">THIS IS AN UNCORRECTED OCR FILE. Once you have corrected it, please change this message to say "Corrected by [your name] on [the date, as yyyy-mm-dd]."<br/>Save the corrected file, and then commit it back to your fork of the GitHub repository, and issue a pull request.</p>
      <!--<div class="pageImage">
      <img src="../images/{$fName}" title="Original page image for checking." alt="Original page-image for checking."/>
      </div>-->
      
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
<!--  We want to convert styles in tags to actual style attributes, for ease of editing in -->
  <xsl:template match="span[@class='ocrx_word'][descendant::strong or descendant::em or descendant::i]">
    <xsl:variable name="styleAttBits" as="xs:string*" select="(if (descendant::strong) then 'font-weight: bold;' else (), if (descendant::em or descendant::i) then 'font-style: italic;' else (), if (@style) then @style else ())"/>
    <xsl:variable name="styleAtt" select="string-join(distinct-values($styleAttBits), ' ')"/>
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name() = 'style')]"/>
      <xsl:attribute name="style" select="$styleAtt"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="strong[ancestor::span[@class='ocrx_word']] | em[ancestor::span[@class='ocrx_word']]"><xsl:apply-templates/></xsl:template>
  
  <!-- Copy everything else as-is. -->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>