<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Nov 21, 2017</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This file is designed to convert HTML files from https://www.aadnc-aandc.gc.ca/
      containing treaty texts into TEI.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:variable name="sourceUrls" select="('https://www.aadnc-aandc.gc.ca/eng/1100100028664/1100100028665', 'https://www.aadnc-aandc.gc.ca/fra/1100100028664/1100100028665', 'https://www.aadnc-aandc.gc.ca/eng/1100100028675/1100100028679', 'https://www.aadnc-aandc.gc.ca/fra/1100100028675/1100100028679', 'https://www.aadnc-aandc.gc.ca/eng/1100100028689/1100100028690', 'https://www.aadnc-aandc.gc.ca/fra/1100100028689/1100100028690', 'https://www.aadnc-aandc.gc.ca/eng/1100100028699/1100100028700', 'https://www.aadnc-aandc.gc.ca/fra/1100100028699/1100100028700', 'https://www.aadnc-aandc.gc.ca/eng/1100100028710/1100100028783', 'https://www.aadnc-aandc.gc.ca/fra/1100100028710/1100100028783', 'https://www.aadnc-aandc.gc.ca/eng/1100100028793/1100100028803', 'https://www.aadnc-aandc.gc.ca/fra/1100100028793/1100100028803', 'https://www.aadnc-aandc.gc.ca/eng/1100100028813/1100100028853', 'https://www.aadnc-aandc.gc.ca/fra/1100100028813/1100100028853', 'https://www.aadnc-aandc.gc.ca/eng/1100100028863/1100100028864', 'https://www.aadnc-aandc.gc.ca/fra/1100100028863/1100100028864', 'https://www.aadnc-aandc.gc.ca/eng/1100100028874/1100100028906', 'https://www.aadnc-aandc.gc.ca/fra/1100100028874/1100100028906', 'https://www.aadnc-aandc.gc.ca/eng/1100100028916/1100100028947', 'https://www.aadnc-aandc.gc.ca/fra/1100100028916/1100100028947')"/>
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8" normalization-form="NFC" exclude-result-prefixes="#all"/>
  
  <xsl:template match="/">
    <!--<xsl:variable name="fileId" select="'temp'"/>-->
    
    <xsl:variable name="fileName" select="tokenize(document-uri(.), '/')[last()]"/>
    
    <xsl:variable name="fileNameNoExtension" select="replace($fileName, '\.html', '')"/>
    
    <xsl:variable name="langId" select="tokenize($fileNameNoExtension, '_')[1]"/>
    
    <xsl:variable name="fileId" select="tokenize($fileNameNoExtension, '_')[last()]"/>
    
    <xsl:variable name="sourceUrl" select="for $i in $sourceUrls return if (ends-with($i, $fileId) and contains($i, concat('/', $langId, '/'))) then $i else ()"/>
    
    <xsl:message>Processing file <xsl:value-of select="$fileNameNoExtension"/> from source <xsl:value-of select="$sourceUrl"/>. </xsl:message>
    
    <TEI xmlns="http://www.tei-c.org/ns/1.0"
      xml:id="{$fileId}"
      type="full">
      <teiHeader>
        <fileDesc>
          <titleStmt>
            
            <title><xsl:value-of select="//meta[@name='description']/@content"/></title>
            
            <respStmt>
              <resp>Original transcription</resp>
              <orgName><orgName xml:lang="fr">Affaires autochtones et du Nord Canada</orgName>
                <orgName xml:lang="en">Indigenous and Northern Affairs Canada</orgName></orgName>
            </respStmt>
            <respStmt>
              <resp>Conversion from HTML to TEI</resp>
              <persName ref="pers:HOLM3">Martin Holmes</persName>
            </respStmt>
            
          </titleStmt>
          
          <publicationStmt>
            <p>Published by The Confederation Debates project.</p>
          </publicationStmt>
          <sourceDesc>
            
            <bibl>
              
              
              <editor>Edmond Cloutier, C.M.G., O.A., D.S.P. Queen's Printer and Controller of Stationery Ottawa</editor>.
              
              
              <title><xsl:value-of select="//meta[@name='description']/@content"/></title>.
              
              
              <date when="1957">1957</date>.  
              
              
              <idno>92099-1</idno>.
              
            </bibl>
            
            
            <list>
              <item>
                <ptr target="{$sourceUrl}"/>
              </item>
            </list>
          </sourceDesc>
        </fileDesc>
        <encodingDesc>
          <samplingDecl>
            
            <p/>
          </samplingDecl>
        </encodingDesc>
        <revisionDesc>
          <change who="mholmes" when="2017-11-21">Transformed original HTML to TEI.</change>
        </revisionDesc>
      </teiHeader>
      
      <text>
        <body>
          <div type="treaty">
            
            <xsl:apply-templates select="//div[@id='wb-main-in']"/>
            
          </div>
        </body>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template match="div">
    <div>
      <xsl:apply-templates select="@*|node()"/>
    </div>
  </xsl:template>
  
  <xsl:template match="p">
    <p>
      <xsl:apply-templates select="@*|node()"/>
    </p>
  </xsl:template>
  
  <xsl:template match="br">
    <lb/>
  </xsl:template>
  
  <xsl:template match="ol">
    <list rend="numbered">
      <xsl:apply-templates select="@*|node()"/>
    </list>
  </xsl:template>
  
  <xsl:template match="ul">
    <list rend="bulleted">
      <xsl:apply-templates select="@*|node()"/>
    </list>
  </xsl:template>
  
  <xsl:template match="ol/li | ul/li">
    <item>
      <xsl:apply-templates select="@*|node()"/>
    </item>
  </xsl:template>
  
  <xsl:template match="h1 | h2 | h3">
    <head>
      <xsl:apply-templates select="@*|node()"/>
    </head>
  </xsl:template>
  
  <xsl:template match="em">
    <emph rendition="simple:italic">
      <xsl:apply-templates select="@*|node()"/>
    </emph>
  </xsl:template>
  
  <xsl:template match="strong">
    <emph rendition="simple:bold">
      <xsl:apply-templates select="@*|node()"/>
    </emph>
  </xsl:template>
  
  <xsl:template match="table">
    <table>
      <xsl:apply-templates select="@*|node()"/>
    </table>
  </xsl:template>
  
  <xsl:template match="tr">
    <row>
      <xsl:apply-templates select="@*|node()"/>
    </row>
  </xsl:template>
  
  <xsl:template match="td">
    <cell>
      <xsl:apply-templates select="@*|node()"/>
    </cell>
  </xsl:template>
  
  <xsl:template match="@colspan">
    <xsl:attribute name="cols" select="."/>
  </xsl:template>
  
  <xsl:template match="@rowspan">
    <xsl:attribute name="rows" select="."/>
  </xsl:template>
  
  <xsl:template match="@*"/>
  
  
</xsl:stylesheet>