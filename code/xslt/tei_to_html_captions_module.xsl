<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> January 12, 2017.</xd:p>
            <xd:p><xd:b>Author:</xd:b> <xd:a href="pers:HOLM3">mholmes</xd:a></xd:p>
            <xd:p>
                This module contains multilingual captions used in the generation of XHTML5 
                documents from TEI XML.
            </xd:p>
        </xd:desc>
    </xd:doc>
   
    <xd:doc>
        <xd:desc>Build date information in the footer.</xd:desc>
    </xd:doc>
    <xsl:variable name="buildDateCaption">
        <span lang="en">Build date: </span>
        <span lang="fr">Date de construction: </span>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Build version information in the footer.</xd:desc>
    </xd:doc>
    <xsl:variable name="buildVersionCaption">
        <span lang="en">Commit: </span>
        <span lang="fr">Commit: </span>
    </xsl:variable>
    
    <xd:doc scope="component">
        <xd:desc>The project title.</xd:desc>
    </xd:doc>
    <xsl:variable name="projectTitle">
        <span lang="en">The Confederation Debates 1865–1949</span>
        <span lang="fr">Les Débats de la Confédération 1865–1949</span>
    </xsl:variable>
    
    <xd:doc scope="component">
        <xd:desc>Caption introducing the count of appearances of
        someone's name in the collection.</xd:desc>
    </xd:doc>
    <xsl:variable name="nameAppearanceCaption">
        <span lang="en">Number of times this person appears in the debates: </span>
        <span lang="fr">Nombre de fois que cette personne apparaît dans les débats: </span>
    </xsl:variable>
    
    <xd:doc scope="component">
        <xd:desc>Caption heading the list of people in the appendix of a document.</xd:desc>
    </xd:doc>
    <xsl:variable name="peopleCaption">
        <span lang="en">Participating individuals: </span>
        <span lang="fr">Personnes participantes: </span>
    </xsl:variable>
    
    <xd:doc scope="component">
        <xd:desc>Caption heading the list of people in the map popup.</xd:desc>
    </xd:doc>
    <xsl:variable name="peopleCaptionShort">
        <span lang="en">People</span>
        <span lang="fr">Personnes</span>
    </xsl:variable>
    
    <xd:doc scope="component">
        <xd:desc>Title heading the browsable list of all documents.</xd:desc>
    </xd:doc>
    <xsl:variable name="docIndexTitle">
        <span lang="en">Index of documents</span>
        <span lang="fr">Index des documents</span>
    </xsl:variable>
    
    <xd:doc scope="component">
        <xd:desc>Heading for lists of documents (debates etc.).</xd:desc>
    </xd:doc>
    <xsl:variable name="debatesDocumentsCaption">
        <span lang="en">Debates and documents</span>
        <span lang="fr">Débats et documents</span>
    </xsl:variable>
    
    <xd:doc scope="component">
        <xd:desc>Captions for different types of place: federal riding</xd:desc>
    </xd:doc>
    <xsl:variable name="federalRidingCaption"><span lang="en">Federal riding</span><span lang="fr">[Fr caption needed for "Federal riding"]</span></xsl:variable>
    
    <xd:doc scope="component">
        <xd:desc>Captions for different types of place: provincial riding</xd:desc>
    </xd:doc>
    <xsl:variable name="nonFederalRidingCaption"><span lang="en">Provincial/Territorial riding</span><span lang="fr">[Fr caption needed for "Non-federal riding"]</span></xsl:variable>
    
    <xd:doc scope="component">
        <xd:desc>Captions for different types of place: treaty location</xd:desc>
    </xd:doc>
    <xsl:variable name="treatyLocationCaption"><span lang="en">Treaty negotiation or signing location</span><span lang="fr">[Fr caption needed for "Treaty negotiation or signing location"]</span></xsl:variable>
    
</xsl:stylesheet>