<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Oct 5, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>Module for generic utilities likely to be 
      required in multiple contexts. Tested using 
      test driver file utilities_module_test.xsl.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:function name="hcmc:stripCommonPrefix" as="xs:string+">
    <xsl:param name="path1" as="xs:string"/>
    <xsl:param name="path2" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="not(contains($path1, '/') and contains($path2, '/'))">
        <xsl:sequence select="($path1, $path2)"/>
      </xsl:when>
      <xsl:when test="substring-before($path1, '/') = substring-before($path2, '/')">
        <xsl:sequence select="hcmc:stripCommonPrefix(substring-after($path1, '/'), substring-after($path2, '/'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="($path1, $path2)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="hcmc:createRelativeUri" as="xs:string?">
    <xsl:param name="from" as="xs:string"/>
    <xsl:param name="to" as="xs:string"/>
    <!-- First we remove the longest common path components from the beginning of each path. -->
    <xsl:variable name="truncPaths" select="hcmc:stripCommonPrefix($from, $to)"/>
    <xsl:variable name="numClimbsRequired" select="count(tokenize($truncPaths[2], '/')) - count(tokenize($truncPaths[1], '/'))"/>
    <xsl:variable name="climbs" select="if ($numClimbsRequired gt 0) then string-join((for $n in 1 to $numClimbsRequired return '../'), '') else ''"/>
    <xsl:value-of select="concat($climbs, $truncPaths[1])"/>
  </xsl:function>
  
</xsl:stylesheet>