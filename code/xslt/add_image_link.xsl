<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0">
    
    
    
<!-- Identifying parameters for the file path to each image and for the page number of each image. Values found in saxon arguments in "build_nfld_fix.xml" -->    
    
    <xsl:param name="imageFilePath" as="xs:string" select="''"/>
    <xsl:param name="pageNumber" as="xs:string" select="''"/>
    
    
    
<!-- Outputting to html files, each .hocr.html -->    
    
    <xsl:output method="xhtml" encoding="UTF-8" normalization-form="NFC"/>
    
    
    
<!-- Matches the template with the root of the XML source document "build_nfld_fix.xml" and reminding us that the image file name is the value of the .jpg filename created. -->  
    
    <xsl:template match="/">
        <xsl:message>Image file name is: <xsl:value-of select="$imageFilePath"/></xsl:message>
        <xsl:apply-templates/>
    </xsl:template>
    
    
    
<!-- Finds all divs with a class attribute that has a value "ocr_page" and make a copy that adds two attributes-->   
    
    <xsl:template match="div[@class='ocr_page']">
        
        
        
        <xsl:copy>
            
<!-- In this div create an attribute "id" with a value that combines "page_" with the value found in $pageNumber -->
            
            <xsl:attribute name="id" select="concat('page_',$pageNumber)"/>
            
            
            <!-- In this div create an attribute "title" with a value that combines "image &quot;../images/'" with the file name of the image file path and "quot;; " ending with the attributes already in the pre-existing title element -->            
            
            <xsl:attribute name="title" select="concat('image &quot;../images/',tokenize($imageFilePath,'/')[last()],'&quot;; ', @title)"/>
            
            
<!-- Keeping all pre-existing xml attributes [?] or nodes [?] -->   
            
            <xsl:apply-templates select="@xml:space|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    
<!-- matching and keeping all attributes or nodes -->
    
    <xsl:template match="@*|node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>