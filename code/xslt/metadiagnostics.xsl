<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  version="2.0"
  xpath-default-namespace="http://www.w3.org/1999/xhtml">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Nov 25, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This stylesheet is designed to analyze a set of existing
      documents in XHTML5 format which contain simple tabular data,
      and produce JSON output which can be used to create graphs and 
      visualizations.</xd:p>
    </xd:desc>
  </xd:doc>
  
  
  <xsl:output method="text" media-type="application/json" encoding="UTF-8" normalization-form="NFC"/>
  
<!-- Parameters with default values: -->
<!-- The folder containing the diagnostics files. -->
  <xsl:param name="diagnosticsFolder" as="xs:string" select="'../diagnostics'"/>
  <xsl:variable name="fixedDiagnosticsFolder" as="xs:string" select="concat($diagnosticsFolder, if (ends-with($diagnosticsFolder, '/')) then '' else '/')"/>
  
<!-- The output file name. -->
  <xsl:param name="outputFile" as="xs:string" select="concat($fixedDiagnosticsFolder, 'metadiagnostics.json')"/>
  
<!-- The collection based on the folder. -->
  <xsl:variable name="inputFiles" select="collection(concat($fixedDiagnosticsFolder, '/?select=*.html'))//html[matches(@id, '^diagnostics_')]"/>
  
<!-- Do the work, which is basically very simple. -->
  <xsl:template match="/">
    
<!-- Report what's going to happen. -->
    <xsl:message>
      This process will analyze <xsl:value-of select="count($inputFiles)"/> single-day
      diagnostics files to produce a single JSON file (<xsl:value-of select="$outputFile"/>)
      and a single JavaScript file for C3/D3 (<xsl:value-of select="replace($outputFile, '\.json', '.js')"/>.)
    </xsl:message>

<!-- Root is a single object containing an array. -->
<!-- First we create a simple JSON file that might be useful
     for various things. -->
    <xsl:result-document href="{$outputFile}">
<xsl:text>{"diagnostics": [
</xsl:text>

<!-- Process each diagnostics file, ordered by date... -->
    <xsl:for-each select="$inputFiles">
      <xsl:sort select="@id"/>
      <xsl:variable name="currFile" select="."/>
      <xsl:variable name="strDate" as="xs:string" select="substring-after(@id, '_')"/>
      <xsl:variable name="fileDate" select="xs:date($strDate)"/>
      <xsl:text>{ 
                  "date": "</xsl:text><xsl:value-of select="$strDate"/><xsl:text>",
                  "hocr_orig": </xsl:text><xsl:value-of select="normalize-space($currFile//td[@id='hocrPagesRaw'])"/><xsl:text>,
                  "hocr_edited": </xsl:text><xsl:value-of select="normalize-space($currFile//td[@id='hocrPagesEdited'])"/><xsl:text>,
                  "tei_pages": </xsl:text><xsl:value-of select="normalize-space($currFile//td[@id='pagesInTei'])"/><xsl:text>,
                  "nametagged_pages": </xsl:text><xsl:value-of select="normalize-space($currFile//td[@id='teiPagesNamesTagged'])"/><xsl:text>,
                  "names_tagged": </xsl:text><xsl:value-of select="if ($currFile//td[@id='teiNamesTagged']) then normalize-space($currFile//td[@id='teiNamesTagged']) else 0"/><xsl:text>,
                  "unspecified_names_tagged": </xsl:text><xsl:value-of select="if ($currFile//td[@id='teiUnspecifiedNamesTagged']) then normalize-space($currFile//td[@id='teiUnspecifiedNamesTagged']) else 0"/>
                  <xsl:text>}</xsl:text><xsl:if test="position() ne last()"><xsl:text>,
</xsl:text></xsl:if>
      
    </xsl:for-each>

<xsl:text>
]}
</xsl:text>
    </xsl:result-document>
    
<!--  Next we create a JS file which will be used with C3/D3 to construct a chart
      by calling it in the context of an XHTML5 document. -->
    
    <xsl:result-document href="{replace($outputFile, '\.json', '.js')}" method="text" media-type="application/ecmascript" normalization-form="NFC" encoding="UTF-8">
      <xsl:text>
      var progressChart = c3.generate({
      bindto: '#progressChart',
      data: {
      x: 'x',
      columns: [
      ['x',</xsl:text>
      
      <xsl:for-each select="$inputFiles">
        <xsl:variable name="thisFile" select="."/>
        <xsl:text>'</xsl:text><xsl:value-of select="substring-after(@id, '_')"/><xsl:text>'</xsl:text><xsl:if test="position() lt last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each> 
      <xsl:text>],
      ['Original scanned pages', </xsl:text><xsl:for-each select="$inputFiles//td[@id='hocrPagesRaw']"><xsl:value-of select="normalize-space(.)"/><xsl:if test="position() lt last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each><xsl:text>],
      ['Edited HOCR pages', </xsl:text><xsl:for-each select="$inputFiles//td[@id='hocrPagesEdited']"><xsl:value-of select="normalize-space(.)"/><xsl:if test="position() lt last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each><xsl:text>],
      ['Pages in TEI', </xsl:text><xsl:for-each select="$inputFiles//td[@id='pagesInTei']"><xsl:value-of select="normalize-space(.)"/><xsl:if test="position() lt last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each><xsl:text>],
      ['Pages in TEI with names tagged', </xsl:text><xsl:for-each select="$inputFiles//td[@id='teiPagesNamesTagged']"><xsl:value-of select="normalize-space(.)"/><xsl:if test="position() lt last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each><xsl:text>]
        ],
      axes: {
        data1: 'y',
        data1: 'y2'
      }
      
      },
      axis: {
        x: {
          type: 'timeseries',
          tick: {
          fit: true,
          culling: false,
          rotate: 90,
          format: '%Y-%m-%d'
        }
      },
      y: {
        label: {
          text: 'Pages',
          position: 'outer-middle'
        },
        tick:{
          outer: false,
          min: 0,
          max: 10000,
          format: d3.format('d')
        }
      },
      y2: {
        show: true,
        tick:{
          format: d3.format('.0%')
        }
      }
    },
    padding: {
    right: 100,
    left: 75
    }
    });
      </xsl:text>

    </xsl:result-document>
    
  </xsl:template>
  
</xsl:stylesheet>