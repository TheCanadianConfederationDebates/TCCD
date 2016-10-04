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
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Oct 4, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This module provides functions used when processing 
      language and typography features, based on the expanded hunspell
      Canadian English dictionary in ../utilities/dict.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:variable name="dict" select="tokenize(unparsed-text('../utilities/dict/en_CA-large-expanded.dic'), '\n')"/>
  
<!--  For easier use in regexes etc. -->
  <xsl:variable name="singleQuote">'</xsl:variable>
  <xsl:variable name="doubleQuote">"</xsl:variable>
  
<!-- Simple report of the number of words found in the dictionary file. -->
  <xsl:function name="hcmc:dictWordCount" as="xs:integer">
    <xsl:value-of select="count($dict)"/>
  </xsl:function>
  
<!-- Capitalize the first letter in a string. -->
  <xsl:function name="hcmc:capFirst" as="xs:string">
    <xsl:param name="inStr" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="string-length($inStr) gt 1">
        <xsl:value-of select="concat(upper-case(substring($inStr, 1, 1)), substring($inStr, 2))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="upper-case($inStr)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
<!-- Lower-case the first letter in a string. -->
  <xsl:function name="hcmc:lowerFirst" as="xs:string">
    <xsl:param name="inStr" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="string-length($inStr) gt 1">
        <xsl:value-of select="concat(lower-case(substring($inStr, 1, 1)), substring($inStr, 2))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="lower-case($inStr)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
<!-- Does a string show up in the dictionary as a word? -->
  <xsl:function name="hcmc:isWord" as="xs:boolean">
    <xsl:param name="inStr" as="xs:string"/>
    <xsl:value-of select="($inStr = $dict) or (hcmc:lowerFirst($inStr) = $dict)"/>
  </xsl:function>
  
<!-- Does a pair of components turn out to be a broken word or not? 
     Result allows for definite and cautious answers. -->
  <xsl:function name="hcmc:isRealBreak" as="xs:string">
    <xsl:param name="firstBit" as="xs:string"/>
    <xsl:param name="secondBit" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="hcmc:isWord(concat($firstBit, $secondBit))"><xsl:value-of select="'no'"/></xsl:when>
      <xsl:when test="hcmc:isWord($firstBit) and hcmc:isWord($secondBit)"><xsl:value-of select="'yes'"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="'maybe'"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
<!--  This function prepares a run of text for use in other 
      functions by removing or replacing various punctuation 
      and similar characters. -->
  <xsl:function name="hcmc:prepText" as="xs:string">
    <xsl:param name="inStr" as="xs:string"/>
    <xsl:value-of select="replace(translate($inStr, concat($doubleQuote, '?!%$()[]`~*.,:;'), ''),'[‘’]', $singleQuote)"/>
  </xsl:function>
  
<!-- This function gets the last word or part-word of a text 
     run in a form which can be used in other functions. -->
  <xsl:function name="hcmc:getLastBit" as="xs:string">
    <xsl:param name="inLine" as="xs:string"/>
    <xsl:value-of select="replace(
                            hcmc:prepText(
                              tokenize(normalize-space($inLine), '\s+')[last()]
                              ), '[\-–—]+\s*$', '')"/>
  </xsl:function>
  
<!-- This function gets the first word or part-word of a text
     run in a form which can be used in other functions. -->
  <xsl:function name="hcmc:getFirstBit" as="xs:string">
    <xsl:param name="inLine" as="xs:string"/>
    <xsl:value-of select="hcmc:prepText(tokenize(normalize-space($inLine), '\s+')[1])"/>
  </xsl:function>
  
<!-- The following templates, all in the lbpass1 and lbpass2 modes, 
     process a block-level element in such a way that linebreaks around 
     hyphens are turned into either simple <lb/>s with the hyphen retained 
     (in the case of compounds) or <lb break="no"/> with the hyphen removed. 
     Trailing and leading whitespace is also removed around the linebreak 
     in these cases. -->
  
<!-- We do this in two passes because it's way easier that way. -->
  
<!--  Default template, which should apply to virtually everything. -->
  <xsl:template mode="lbpass1 lbpass2" match="@* | node()" priority="-1">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
<!-- This is the trigger template which finds a line ending with a hyphen
     and makes the decision, encoding the result in the lb tag.  -->
  <xsl:template mode="lbpass1" match="lb[matches(preceding::text()[1], '[\-–—]+\s*$')]">
    <xsl:variable name="firstBit" select="hcmc:getLastBit(preceding::text()[1])"/>
    <xsl:variable name="secondBit" select="hcmc:getFirstBit(following::text()[1])"/>
    <lb break="{hcmc:isRealBreak($firstBit, $secondBit)}"/>
  </xsl:template>
  
<!-- This is the second-pass template which handles text nodes which 
     need to be tweaked in the environment of a linebreak. -->
  <xsl:template mode="lbpass2" match="text()">
    <xsl:choose>
<!--   If it both follows a non-break 
      and precedes one, it gets both operations.-->
      <xsl:when test="preceding::*[1][self::lb[@break='no']] and following::*[1][self::lb[@break='no']]">
        <xsl:value-of select="replace(replace(., '[\-–—]+\s*$', ''), '^\s+', '')"/>
      </xsl:when>
      <xsl:when test="preceding::*[1][self::lb[@break='no']]">
        <xsl:value-of select="replace(., '^\s+', '')"/>
      </xsl:when>
      <xsl:when test="following::*[1][self::lb[@break='no']]">
        <xsl:value-of select="replace(., '[\-–—]+\s*$', '')"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>