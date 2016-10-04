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
      <xd:p>This file is a test driver for the dictionary_module.xsl file.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:include href="dictionary_module.xsl"/>
  
  <xsl:output method="text" encoding="UTF-8" byte-order-mark="no" normalization-form="NFC"
  indent="no"/>
  
  <xsl:variable name="simplePara" as="element()">
    <p> Hon. Mr. Rose moved
      that on Tuesday next <lb/>
      thel House resolve itself into Committee of <lb/>
       <lb/>
      
      <pb n="615"/>
      <fw>
        <fw type="num">4</fw>
        <fw type="running">juin 1869</fw>
      </fw> the Whole on the
      resolutions respecting Prince <lb/>
      Edward Island. Those resolutions, of course, <lb/>
      did not embody any conclusive arrangement, <lb/>
      but were rather an authority for opening <lb/>
      negotiation with Prince Edward Island on <lb/>
      terms which the Government were not with- <lb/>
      out hope would result in completing the Union <lb/>
      of the British North American Provinces on <lb/>
      the seaboard at least. The Island was owned <lb/>
      by some 62 individuals, to whom it was origi— <lb/>
      nally granted by the Crown at a merely nom- <lb/>
      inal rent, and as their titles obstructed the <lb/>
      Union it was thought they ought to be extin- <lb/>
      guished. Blah blah the potting- <lb/> shed.<lb/>
      
    </p>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:call-template name="runTests"/>
  </xsl:template>
  
  <xsl:template name="runTests">
    <xsl:call-template name="dictWordCount"/>
    <xsl:call-template name="testSimpleWords"/>
    <xsl:call-template name="testBrokenWords"/>
    <xsl:call-template name="testSimpleParaPass1"/>
  </xsl:template>
  
  <xsl:template name="dictWordCount">
    <xsl:text>&#x0a;Word count in dictionary: </xsl:text> <xsl:value-of select="hcmc:dictWordCount()"/><xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>
  
  <xsl:template name="testSimpleWords">
    <xsl:variable name="simpleWords" select="('thing', 'walking', 'oxygen', 'ddddbog', 'splrrrg')"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:for-each select="$simpleWords">
      <xsl:choose>
        <xsl:when test="hcmc:isWord(.)"><xsl:text>&#x0a;</xsl:text><xsl:value-of select="."/> <xsl:text> IS a word.</xsl:text></xsl:when>
        <xsl:otherwise><xsl:text>&#x0a;</xsl:text><xsl:value-of select="."/> <xsl:text> is NOT a word.</xsl:text></xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>
  
  <xsl:template name="testBrokenWords">
    <xsl:variable name="brokenWords" select="('think-ing', 'walk-ed', 'oxy-gen', 'talk-fest', 'book-cover', 'auto-hyphenate', 'bzzz-what')"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:for-each select="$brokenWords">
      <xsl:variable name="bits" select="tokenize(., '\-')"/>
      <xsl:variable name="result" select="hcmc:isRealBreak($bits[1], $bits[2])"/>
      <xsl:text>&#x0a;</xsl:text><xsl:value-of select="concat($bits[1], $bits[2])"/><xsl:text> is </xsl:text>
      <xsl:value-of select="if ($result = 'no') then 'definitely' else if ($result = 'yes') then 'definitely NOT' else 'possibly'"/><xsl:text> a word.</xsl:text>
    </xsl:for-each>
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>
  
  <xsl:template name="testSimpleParaPass1" as="xs:string*">
    <xsl:variable name="output1" as="element()">
      <xsl:apply-templates select="$simplePara" mode="lbpass1"/>
    </xsl:variable>
    <xsl:variable name="output2" as="element()">
      <xsl:apply-templates select="$output1" mode="lbpass2"/>
    </xsl:variable>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
    <xsl:value-of select="serialize($output2)"/>
  </xsl:template>
  
  <xsl:function name="hcmc:serializeNode" as="xs:string*">
    <xsl:param name="inNode" as="node()"/>
    <xsl:choose>
      <xsl:when test="$inNode/self::text()"><xsl:value-of select="$inNode"/></xsl:when>
      <xsl:when test="$inNode/self::attribute()"><xsl:value-of select="concat(' ', name($inNode), '=', $doubleQuote, $inNode, $doubleQuote)"/></xsl:when>
      <xsl:when test="$inNode/self::*"><xsl:text>&lt;</xsl:text><xsl:value-of select="name($inNode)"/><xsl:for-each select="$inNode/@*"><xsl:sequence select="hcmc:serializeNode(.)"/></xsl:for-each>
        <xsl:choose>
          <xsl:when test="$inNode/node()"><xsl:text>&gt;</xsl:text><xsl:for-each select="$inNode/node()"><xsl:sequence select="hcmc:serializeNode(.)"/></xsl:for-each><xsl:text>&lt;/</xsl:text><xsl:value-of select="name($inNode)"/><xsl:text>&gt;</xsl:text></xsl:when> <xsl:otherwise><xsl:text>/&gt;</xsl:text></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>