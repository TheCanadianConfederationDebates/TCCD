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
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xhtml" encoding="UTF-8" normalization-form="NFC" omit-xml-declaration="yes" exclude-result-prefixes="#all" />
  
  <xsl:variable name="fName" select="substring-before(tokenize(document-uri(/), '[\\/]')[last()], '.hocr')"/>
  
  <xsl:template match="/">
<!--  We'll use an HTML5 doctype. We can flip back to XHTML later for the 
    purposes of e.g. hocr2pdf. -->
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html>
</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="head">
    <xsl:copy>
      <xsl:apply-templates/>
      <meta name="status" content="uncorrected"/>
      <style type="text/css">
        body, div, p{
        display: block;
        margin: 0.5em;
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
      <p contenteditable="true" class="editorial">THIS IS AN UNCORRECTED OCR FILE. Once you have corrected it, please change this message to say "Corrected by [your name] on [the date, as yyyy-mm-dd]."<br/>Like this message, each individual word is editable in a web browser. You can then use File / Save to save the resulting corrected file, and then commit it back to the GitHub repository.</p>
      <!--<div class="pageImage">
      <img src="../images/{$fName}" title="Original page image for checking." alt="Original page-image for checking."/>
      </div>-->
      
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!--<xsl:template match="span[@class='ocrx_word']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="contenteditable">true</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>-->
  
  <!-- Copy everything else as-is. -->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>