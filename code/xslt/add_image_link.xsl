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
    
    
    
<!-- Matches the template with the root of the source document "hocr.html" and reminding us that the image file name is the value of the .jpg filename created. -->  
    
    <xsl:template match="/">
        <xsl:message>Image file name is: <xsl:value-of select="$imageFilePath"/></xsl:message>
        <xsl:apply-templates/>
    </xsl:template>
    
    
    
<!-- When you encounter a div with a class attribute that has a value "ocr_page" make a copy and add two attributes. And then apply-templates to @xml:space and @class as well as all children of this div.-->   
    
    <xsl:template match="div[@class='ocr_page']">
        
        
        
        <xsl:copy>
            
            
            <xsl:attribute name="id" select="concat('page_',$pageNumber)"/>
            
                     
            
            <xsl:attribute name="title" select="concat('image &quot;../images/',tokenize($imageFilePath,'/')[last()],'&quot;; ', @title)"/>
            
            
<!-- Look for templates that match these attributes and nodes, (will find the Identity transform in this case). -->   
            
            <xsl:apply-templates select="@xml:space|@class|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    
<!-- Identity transform. Standard. Matching anything and copying the thing and then calling apply-templates on its attributes and children. -->
    
    <xsl:template match="@*|node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>