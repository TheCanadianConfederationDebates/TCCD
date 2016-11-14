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
  
<!--  Some global variables. -->
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>This is a normal "straight" apostrophe. Escaping makes this 
      hard to handle in many contexts, so we stick it in a variable.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="apos">'</xsl:variable>
  
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>This function takes two paths/URIs as input, and strips
    all the leading path components which are common to both. It 
    returns both the truncated paths as a sequence of two strings.
    The function is recursive.</xd:p>
      <xd:p>Example input:
      <xd:ul>
        <xd:li>one/two/three/four/somefile.txt</xd:li>
        <xd:li>one/two/trois/quatre/otherfile.txt</xd:li>
      </xd:ul>
        Return:
        <xd:ul>
          <xd:li>('three/four/somefile.txt', 'trois/quatre/otherfile.txt')</xd:li>
        </xd:ul>
      </xd:p>
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
  
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>This function accepts two parameters which are paths or URIs.
            It returns the relative path from the first to the second.</xd:p>
      <xd:p>Example input:
        <xd:ul>
          <xd:li>one/two/three/four/somefile.txt</xd:li>
          <xd:li>one/two/trois/quatre/otherfile.txt</xd:li>
        </xd:ul>
        Return:
        <xd:ul>
          <xd:li>../../trois/quatre/otherfile.txt</xd:li>
        </xd:ul>
      </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="hcmc:createRelativeUri" as="xs:string?">
    <xsl:param name="from" as="xs:string"/>
    <xsl:param name="to" as="xs:string"/>
    
<!-- First we remove the longest common path components from the beginning of each path. -->
    <xsl:variable name="truncPaths" select="hcmc:stripCommonPrefix($from, $to)"/>
    
<!-- Now calculate how many ../ bits we need, if any, by figuring out the 
     number of components in each path.   -->
    <xsl:variable name="numClimbsRequired" select="count(tokenize($truncPaths[2], '/')) - count(tokenize($truncPaths[1], '/'))"/>
    <xsl:variable name="climbs" select="if ($numClimbsRequired gt 0) then string-join((for $n in 1 to $numClimbsRequired return '../'), '') else ''"/>
    
<!-- Return concatenation of ../ bits and remaining target path.   -->
    <xsl:value-of select="concat($climbs, $truncPaths[1])"/>
  </xsl:function>
  
<!--  This function takes an upper-case form of a name and returns something which is (we hope) 
      a normal-case version (first letter upper, generally). -->
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>This function takes a name of some kind as input, and 
      returns a version of the name which is normalized for case.</xd:p>
      <xd:p>Example input:
        <xd:ul>
          <xd:li>FRED O'REILLY</xd:li>
        </xd:ul>
        Return:
        <xd:ul>
          <xd:li>Fred O’Reilly</xd:li>
        </xd:ul>
      </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="hcmc:normalCaseName" as="xs:string">
    <xsl:param name="inStr" as="xs:string"/>
    <xsl:variable name="normInStr" select="replace(replace(normalize-space($inStr), '\s*-\s*', '-'), $apos, '’')"/>
    <xsl:choose>
      <xsl:when test="contains($normInStr, ' ')">
        <xsl:variable name="nameBits" select="tokenize($normInStr, '\s+')"/>
        <xsl:variable name="fixedNameBits" select="for $n in $nameBits return hcmc:normalCaseName($n)"/>
        <xsl:value-of select="string-join($fixedNameBits, ' ')"/>
      </xsl:when>
      <xsl:when test="contains($normInStr, '-')">
        <xsl:variable name="nameBits" select="tokenize($normInStr, '-')"/>
        <xsl:variable name="fixedNameBits" select="for $n in $nameBits return hcmc:normalCaseName($n)"/>
        <xsl:value-of select="string-join($fixedNameBits, '-')"/>
      </xsl:when>
      <xsl:when test="matches($normInStr, '^[Oo]’[A-Za-z]')">
        <xsl:value-of select="concat('O’', upper-case(substring($normInStr, 3, 1)), lower-case(substring($normInStr, 4)))"/>
      </xsl:when>
      <xsl:when test="matches($normInStr, '^[Mm][Cc][A-Z]')">
        <xsl:value-of select="concat('Mc', upper-case(substring($normInStr, 3, 1)), lower-case(substring($normInStr, 4)))"/>
      </xsl:when>
      <xsl:when test="matches($normInStr, '^[Mm][Aa][Cc][A-Z]')">
        <xsl:value-of select="concat('Mac', upper-case(substring($normInStr, 4, 1)), lower-case(substring($normInStr, 5)))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(upper-case(substring($normInStr, 1, 1)), lower-case(substring($normInStr, 2)))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  
</xsl:stylesheet>