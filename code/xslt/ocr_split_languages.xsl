<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
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
        The transformation takes as an input parameter the folder 
        path of a collection of edited HOCR files.
      </xd:p>
      
      <xd:p>
        The first time you run the transformation, it will see that 
        no list of potential forme works has been established, so it 
        will first create this list as a file called formeworks.txt in 
        the collection folder; you should edit the result following the 
        instructions at the top of the file, and save it.
      </xd:p>
      
      <xd:p>
        The second time the process is run, now that the forme works 
        have been identified, the split language files will be created,
        with the forme works being discarded in the process. 
        The output consists of two files, each identical to the 
        incoming source file, except that one column (along with
        the hr element) has been removed. The result documents are 
        fed into separate subfolders of the source document location.
      </xd:p>
    </xd:desc>
  </xd:doc>
  
<!-- This points to the folder of corrected HOCR documents which we wish to process. -->
  <xsl:param name="collectionPath" as="xs:string"/>
  
  <xsl:variable name="hocrFiles" select="collection(concat($collectionPath, '?select=*.hocr.html;recurse=no'))"/>
  
  <!-- We'll use XHTML 1 strict, because that's what Kompozer and hocr2pdf like. -->
  <xsl:output method="xhtml" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"  normalization-form="NFC" omit-xml-declaration="yes" exclude-result-prefixes="#all" byte-order-mark="no" />
  
<!--  Output element for the interim file for defining forme works. -->
  <xsl:output name="formeWorksOutput" method="text" encoding="UTF-8" normalization-form="NFC"/>


  
  <xsl:variable name="definedFormeWorksFile" select="concat($collectionPath, '/formeworks.txt')"/>
  
  <xsl:variable name="definedFormeWorks" select="if (unparsed-text-available($definedFormeWorksFile)) then tokenize(unparsed-text($definedFormeWorksFile), '\s*\n\s*') else ()"/>
  
  <xsl:template match="/">
    <xsl:message>Processing this folder: <xsl:value-of select="$collectionPath"/></xsl:message>
    
<!--  We only bother doing this if there's an hr element 
      which delimits the two language columns. Otherwise 
      there's nothing useful we can do. -->
    <xsl:choose>
      <xsl:when test="$hocrFiles//hr">
        <xsl:choose>
          <!-- Check there are actually some files there.-->
          <xsl:when test="count($hocrFiles) lt 1">
            <xsl:message terminate="yes">No corrected HOCR files found in <xsl:value-of select="$collectionPath"/></xsl:message>
          </xsl:when>
          
          <!-- Have we already run through the process once to create the 
     list of confirmed forme works? -->
          <xsl:when test="count($definedFormeWorks) gt 0">
            <xsl:message>Defined forme works file found. Proceeding to split languages.</xsl:message>
            <!-- We can split the texts. -->
            <xsl:variable name="outputDir" select="concat($collectionPath, 'by_language/')"/>
            
            <xsl:for-each select="$hocrFiles">
              <xsl:variable name="fName" select="tokenize(document-uri(.), '/')[last()]"/>
              <xsl:variable name="frenchOutputFile" select="concat($outputDir, 'fr/', $fName)"/>
              <xsl:variable name="englishOutputFile" select="concat($outputDir, 'en/', $fName)"/>
              
              <!--   Create the French document.   -->
              <xsl:result-document href="{$frenchOutputFile}">
                <xsl:apply-templates mode="french"/>
              </xsl:result-document>
              
              <!--   Create the English document. -->
              <xsl:result-document href="{$englishOutputFile}">
                <xsl:apply-templates mode="english"/>
              </xsl:result-document>
            </xsl:for-each>
            
          </xsl:when>
          <xsl:otherwise>
            <!-- We need instead to create the potential forme works list for the 
     user to edit. -->
            <xsl:message>This appears to be the first run; trying to create forme works file.</xsl:message>
            <xsl:message>File will be saved at <xsl:value-of select="$definedFormeWorksFile"/></xsl:message>              
            <xsl:variable name="potentialFormeWorksRough" select="for $d in $hocrFiles//div[@class='ocr_carea'] return hcmc:cleanString($d)"/>
            <xsl:variable name="potentialFormeWorks" select="for $s in $potentialFormeWorksRough return if (string-length($s) lt 25 and string-length($s) gt 0 and not(matches($s, '^\d+$'))) then $s else ()"/>
            <xsl:result-document href="{$definedFormeWorksFile}" format="formeWorksOutput">
              <xsl:text>###Each line is a potential ignorable "forme work" such as a running header.</xsl:text>
              <xsl:text>&#x0a;###Delete the ones that are NOT running headers.</xsl:text>
              <xsl:text>&#x0a;###When you have done this, run the transformation again.</xsl:text>
              <xsl:text>&#x0a;####The remaining ones will be removed from the split language output files.</xsl:text>
              <xsl:for-each select="distinct-values($potentialFormeWorks)">
                <xsl:text>&#x0a;</xsl:text><xsl:value-of select="."/>
              </xsl:for-each>
            </xsl:result-document>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>No hr elements have been found in the file collection, 
        so it appears that these files have not been proofed.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
 
<!--In English mode, suppress divs following the hr. -->
  <xsl:template match="div[ancestor::body][preceding::hr]" mode="english"/>
  
<!--In French mode, suppress divs preceding the hr.  -->
  <xsl:template match="div[ancestor::body][following::hr]" mode="french"/>
  
<!-- We always discard forme works.  -->
  <xsl:template match="div[normalize-space(.) = $definedFormeWorks]" mode="english french"/>
<!-- We always discard empty divs. -->
  <xsl:template match="div[hcmc:cleanString(.) = '']" mode="english french"/>
  
<!--  
    We have a default template which simply copies 
    to the output (i.e. an identity transform). 
    We apply templates rather than doing a straight 
    copy so that if anything else needs to be tweaked 
    or fixed we can do it here.
  -->
  
  <xsl:template match="@*|node()" priority="-1" mode="#all" exclude-result-prefixes="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="hcmc:cleanString" as="xs:string">
    <xsl:param name="inStr" as="xs:string"/>
    <xsl:value-of select="normalize-space(translate($inStr, '&#xa0;', ''))"/>
  </xsl:function>
  
</xsl:stylesheet>