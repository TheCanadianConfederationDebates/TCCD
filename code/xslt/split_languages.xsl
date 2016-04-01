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
      delimit the two columns.
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
  
  <xsl:template match="/">
    
  </xsl:template>
  
</xsl:stylesheet>