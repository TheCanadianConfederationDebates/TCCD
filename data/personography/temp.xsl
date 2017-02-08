<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    xpath-default-namespace=""
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="2.0">
<!--   Quick-and-dirty stylesheet to grab members from 
    Wikipedia page. -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        
        <listPerson>
            
            <xsl:for-each select="//table[@width='95%']">
                <xsl:for-each select="tr[position() gt 1]">
                    <xsl:choose>
                        <xsl:when test="count(td) gt 3">
                            <xsl:variable name="affiliation">
                                <affiliation when="1945"><xsl:value-of select="normalize-space(td[1])"/></affiliation>
                            </xsl:variable>
                            <xsl:variable name="persName" select="hcmc:getNameFromCell(td[3])"/>
                    <person>
                        <xsl:sequence select="$persName"/>
                        <xsl:copy-of select="$affiliation"/>
                        <xsl:sequence select="hcmc:getNoteFromCell(td[3])"/>
                    </person>
                    <xsl:if test="td[1]/@rowspan">
                        <xsl:variable name="thisRow" select="."/>
                        <xsl:variable name="folls" select="for $i in 2 to xs:integer(td[1]/@rowspan) return $i"/>
                        <xsl:for-each select="$folls">
                            <xsl:variable name="curr" select=". - 1"/>
                            <xsl:variable name="persName" select="hcmc:getNameFromCell($thisRow/following-sibling::tr[$curr]/td[2])"/>
                            <person>
                                <xsl:sequence select="$persName"/>
                                <xsl:copy-of select="$affiliation"/>
                                <xsl:sequence select="hcmc:getNoteFromCell($thisRow/following-sibling::tr[$curr]/td[2])"/>
                            </person>
                        </xsl:for-each>
                    </xsl:if>
                        </xsl:when>
                        <xsl:otherwise></xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:for-each>
            </xsl:for-each>
                
        </listPerson>
        
    </xsl:template>
    
    <xsl:function name="hcmc:getNameFromCell" as="element()">
        <xsl:param name="cell" as="xs:string"/>
        <xsl:variable name="nameOnly" select="replace(normalize-space($cell), '\s*\([^\)]+\)$', '')"/>
         <persName when="1945">
            <xsl:variable name="names" select="tokenize($nameOnly, '\s+')"/>
            <xsl:variable name="forenames" select="string-join((for $n in (1 to count($names)-1) return $names[$n]), ' ')"/>
            <surname><xsl:value-of select="$names[last()]"/></surname><xsl:text>, </xsl:text>
            <forename><xsl:value-of select="$forenames"/></forename>
        </persName>
    </xsl:function>
    
    <xsl:function name="hcmc:getNoteFromCell" as="element()?">
        <xsl:param name="cell" as="xs:string"/>
        <xsl:variable name="note" select="if (contains($cell, '(')) then substring-before(substring-after(normalize-space($cell), '('), ')') else ''"/>
        <xsl:choose>
            <xsl:when test="string-length($note) gt 0">
                <note><xsl:value-of select="$note"/></note>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>