<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Apr 1, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      
      <xd:p>
        The purpose of this transformation is to split a
      corrected OCR file generated from pages where the English 
      and French equivalents are in separate columns on the same 
      page into two separate files, one for each language. The 
      split is based on the presence of an XHTML hr (horizontal
      rule) tag, which is placed by the proofer/editor to 
      delimit the two columns. We assume that the English column
      precedes the French column on each page (which has been 
      the case with our initial test data).
      </xd:p>
      
      <xd:p>
        The output consists of two files, each identical to the 
        incoming source file, except that one column (along with
        the hr element) has been removed. The result documents are 
        fed into separate subfolders of the source document location.
      </xd:p>
    </xd:desc>
  </xd:doc>
  
  <!-- We'll use XHTML 1 strict, because that's what Kompozer and hocr2pdf like. -->
  <xsl:output method="xhtml" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"  normalization-form="NFC" omit-xml-declaration="yes" exclude-result-prefixes="#all" byte-order-mark="no" />
  
  <xsl:variable name="fName" select="substring-before(tokenize(document-uri(/), '[\\/]')[last()], '.hocr')"/>
  
  <xsl:variable name="outputDir" select="concat(replace(document-uri(/), tokenize(document-uri(.), '/')[last()], ''), '/by_language/')"/>
  <xsl:variable name="frenchOutputFile" select="concat($outputDir, 'fr/', $fName, '.hocr.html')"/>
  <xsl:variable name="englishOutputFile" select="concat($outputDir, 'en/', $fName, '.hocr.html')"/>
  
  <xsl:template match="/">
<!--  We only bother doing this if there's an hr element 
      which delimits the two language columns. Otherwise 
      there's nothing useful we can do. -->
    <xsl:if test="//hr">
<!--   Create the French document.   -->
      <xsl:result-document href="{$frenchOutputFile}">
        <xsl:apply-templates mode="french"/>
      </xsl:result-document>
      
<!--   Create the English document. -->
      <xsl:result-document href="{$englishOutputFile}">
        <xsl:apply-templates mode="english"/>
      </xsl:result-document>
    </xsl:if>
  </xsl:template>
 
<!--In English mode, suppress divs following the hr. -->
  <xsl:template match="div[ancestor::body][preceding::hr]" mode="english"/>
  
<!--In French mode, suppress divs preceding the hr.  -->
  <xsl:template match="div[ancestor::body][following::hr]" mode="french"/>
  
<!--  
    We have a default template which simply copies 
    to the output (i.e. an identity transform). 
    We apply templates rather than doing a straight 
    copy so that if anything else needs to be tweaked 
    or fixed we can do it here.
  -->
  
  <xsl:template match="@*|node()" priority="-1" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>