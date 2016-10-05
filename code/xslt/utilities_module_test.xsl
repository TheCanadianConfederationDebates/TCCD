<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Oct 4, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This file is a test driver for the utilities_module.xsl file.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:include href="utilities_module.xsl"/>
  
  <xsl:output method="text" encoding="UTF-8" byte-order-mark="no" normalization-form="NFC"
  indent="no"/>
  
  <xsl:variable name="relPathPair1" select="(
    '/home/mholmes/WorkData/history/confederation_debates/TCCD/data/PEI/Federal/final/images/PEI_H_of_C_18690603_Page_597.jpg',
    '/home/mholmes/WorkData/history/confederation_debates/TCCD/data/PEI/Federal/lgHC_1869-06-03_expanded.xml')"/>
  
  <xsl:variable name="relPathPair2" select="(
   '/home/mholmes/WorkData/history/confederation_debates/TCCD/data/PEI/Federal/lgHC_1869-06-03_expanded.xml',
   '/home/mholmes/WorkData/history/confederation_debates/TCCD/data/PEI/Federal/final/images/PEI_H_of_C_18690603_Page_597.jpg'
    )"/>
  
  <xsl:variable name="relPathPair3" select="('/one/two/three/file1.txt', '/one/two/three/file2.txt')"/>
  
  <xsl:template match="/">
    <xsl:call-template name="runTests"/>
  </xsl:template>
  
  <xsl:template name="runTests">
    <xsl:call-template name="relPathPairTest1"/>
    <xsl:call-template name="relPathPairTest2"/>
    <xsl:call-template name="relPathPairTest3"/>
  </xsl:template>
  
  <xsl:template name="relPathPairTest1">
    <xsl:text>&#x0a;&#x0a;Relative path pair test 1: path to:&#x0a;</xsl:text>
    <xsl:value-of select="$relPathPair1[1]"/>
    <xsl:text>&#x0a;from:&#x0a;</xsl:text>
    <xsl:value-of select="$relPathPair1[2]"/>
    <xsl:text>&#x0a;Result:&#x0a;</xsl:text>
    <xsl:value-of select="hcmc:createRelativeUri($relPathPair1[1], $relPathPair1[2])"/>
  </xsl:template>
  
  <xsl:template name="relPathPairTest2">
    <xsl:text>&#x0a;&#x0a;Relative path pair test 2: path to:&#x0a;</xsl:text>
    <xsl:value-of select="$relPathPair2[1]"/>
    <xsl:text>&#x0a;from:&#x0a;</xsl:text>
    <xsl:value-of select="$relPathPair2[2]"/>
    <xsl:text>&#x0a;Result:&#x0a;</xsl:text>
    <xsl:value-of select="hcmc:createRelativeUri($relPathPair2[1], $relPathPair2[2])"/>
  </xsl:template>
  
  <xsl:template name="relPathPairTest3">
    <xsl:text>&#x0a;&#x0a;Relative path pair test 3: path to:&#x0a;</xsl:text>
    <xsl:value-of select="$relPathPair3[1]"/>
    <xsl:text>&#x0a;from:&#x0a;</xsl:text>
    <xsl:value-of select="$relPathPair3[2]"/>
    <xsl:text>&#x0a;Result:&#x0a;</xsl:text>
    <xsl:value-of select="hcmc:createRelativeUri($relPathPair3[1], $relPathPair3[2])"/>
  </xsl:template>
  
  
</xsl:stylesheet>