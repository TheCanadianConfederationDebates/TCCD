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
      <xd:p><xd:b>Created on:</xd:b> Jan 7, 2015</xd:p>
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
  
<!-- Per DH: Throwing away ocr_line (replace with <br/>) ocr_word (don't replace).
     <strong> and <em> (unless we can easily find a way to preserve them, but 
     only in newspapers). Throw away paragraph ids too. Try to recognize forme works on the basis of their 
     position and offsets, and tag them with a special class. 
  
     Ont-Que first, then 
  -->
    
  <xsl:param name="inputFolder"/>
  <xsl:param name="outputFolder"/>
  
  <!-- We'll use XHTML 1 strict, because that's what Kompozer and hocr2pdf like. -->
  <xsl:output method="xhtml" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"  normalization-form="NFC" omit-xml-declaration="yes" exclude-result-prefixes="#all" byte-order-mark="no" />

  
  <xsl:variable name="inDocs" select="collection(concat($inputFolder, '/?select=*.hocr;recurse=yes'))"/>
  
  <!--<xsl:variable name="fName" select="substring-before(tokenize(document-uri(/), '[\\/]')[last()], '.hocr')"/>-->
  
  <xsl:template match="/">
    <xsl:message>Found <xsl:value-of select="count($inDocs)"/> input documents in <xsl:value-of select="$inputFolder"/>.</xsl:message>
    <xsl:message>Creating output in <xsl:value-of select="$outputFolder"/>.</xsl:message>
    <xsl:for-each select="$inDocs">
      <xsl:variable name="fName" select="tokenize(document-uri(/), '[\\/]')[last()]"/>
      <xsl:result-document href="{concat($outputFolder, '/', $fName, '.html')}">
        <xsl:apply-templates/>
      </xsl:result-document>
    </xsl:for-each>
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
        p{
          margin-top: 0;
          margin-bottom: 0;
        }
        span.lowConfidenceOcr{
        background-color: #ffff00;
        }
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
      <xsl:value-of select="substring-before(tokenize(document-uri(.), '[\\/]')[last()], '.hocr')"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="body">
    <xsl:copy>
      
      <!--  We are attempting to recognize the page/column number(s) and pull them out. -->
      <xsl:variable name="firstMeaningfulDiv" select="if (//div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0]) then normalize-space(//div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0][1]) else ''"/>
      <xsl:variable name="lastMeaningfulDiv" select="if (//div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0]) then normalize-space(//div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0][last()]) else ''"/>
      <xsl:variable name="possPageNum" as="xs:string*">
        <xsl:choose>
          <xsl:when test="string-length($firstMeaningfulDiv) gt 0 and matches($firstMeaningfulDiv, '\d')">
            <xsl:analyze-string select="$firstMeaningfulDiv" regex="((^[ivxc\d]+(\s|$))|((^|\s)[ivxc\d]+$))">
              <xsl:matching-substring><xsl:value-of select="."/></xsl:matching-substring>
              <xsl:non-matching-substring/>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:when test="string-length($lastMeaningfulDiv) gt 0 and matches($lastMeaningfulDiv, '\d')">
            <xsl:analyze-string select="$lastMeaningfulDiv" regex="((^[ivxc\d]+(\s|$))|((^|\s)[ivxc\d]+$))">
              <xsl:matching-substring><xsl:value-of select="normalize-space(.)"/></xsl:matching-substring>
              <xsl:non-matching-substring/>
            </xsl:analyze-string>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      
      
      <p class="editorial">THIS IS AN UNCORRECTED OCR FILE. Once you have corrected it, please change this message to say 
        "Corrected by [your name] on [the date, as yyyy-mm-dd]."<br/>Save the corrected file, and then commit it back to 
        your fork of the GitHub repository, and issue a pull request.<br/>
        The OCR process believes the page/column numbers on this page to be:<br/>
        [<xsl:value-of select="string-join($possPageNum, '-')"/>]<br/>
        Please correct these if they are wrong.
      </p>
      <!--<div class="pageImage">
      <img src="../images/{$fName}" title="Original page image for checking." alt="Original page-image for checking."/>
      </div>-->

      <xsl:apply-templates/>
      
      <p class="editorial">Don't forget to complete the green box at the top of the file! Then you can delete this 
      box.</p>
    </xsl:copy>
  </xsl:template>
  
<!--  We want to convert styles in tags to actual style attributes, for ease of editing in -->
<!--  <xsl:template match="span[@class='ocrx_word'][descendant::strong or descendant::em or descendant::i]">
    <xsl:variable name="styleAttBits" as="xs:string*" select="(if (descendant::strong) then 'font-weight: bold;' else (), if (descendant::em or descendant::i) then 'font-style: italic;' else (), if (@style) then @style else ())"/>
    <xsl:variable name="styleAtt" select="string-join(distinct-values($styleAttBits), ' ')"/>
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name() = 'style')]"/>
      <xsl:attribute name="style" select="$styleAtt"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="strong[ancestor::span[@class='ocrx_word']] | em[ancestor::span[@class='ocrx_word']] | i[ancestor::span[@class='ocrx_word']]"><xsl:apply-templates/></xsl:template>-->
  
  <!--  We are dropping ocr_carea divs and ocr_par ps that contain nothing. -->
  <xsl:template match="div[@class='ocr_carea'][string-length(normalize-space(.)) lt 1] | div[@class='ocr_par'][string-length(normalize-space(.)) lt 1]"/>
  
<!-- We are ignoring strong, em and i.  -->
  <xsl:template match="strong | em | i">
    <xsl:apply-templates/>
  </xsl:template>
  
<!-- We are turning ocr_line spans into br tags. -->
  <xsl:template match="span[@class='ocr_line']">
    <xsl:apply-templates/><br/>
  </xsl:template>
  
<!-- We are ignoring word tags. -->
  <xsl:template match="span[@class='ocrx_word']">
    <xsl:choose>
      <xsl:when test="matches(@title, 'x_wconf [0123456]')">
        <span class="lowConfidenceOcr"><xsl:apply-templates/></span>
      </xsl:when>
      <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
<!-- We are throwing away ids on para tags. -->
  <xsl:template match="p">
    <p>
      <xsl:copy-of select="@class | @dir"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <!-- Copy everything else as-is. -->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>