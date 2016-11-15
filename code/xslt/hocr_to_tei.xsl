<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Rewritten on:</xd:b> September 28, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This stylesheet processes a TEI template file created by 
        an editor which specifies the metadata and the list of HOCR 
        files which need to be incorporated, to create the single 
        TEI file containing a single debate at a single legislature.
        </xd:p>
      <xd:p>The process works like this:
      <xd:ul>
        <xd:li>Check metadata is complete and referenced files exist.</xd:li>
        <xd:li>Calculate path to local copy of schema.</xd:li>
        <xd:li>Retrieve HOCR files.</xd:li>
        <xd:li>Build facsimile element linking to original images, parsed out from
               HOCR links. Warn if images or image links not found.</xd:li>
        <xd:li>Process HOCR content to create TEI hierarchy of pages.</xd:li>
        <xd:li>Transform page hierarchy into structural hierarchy.</xd:li>
        <xd:li>Make further passes through the text to refine the handling
               of hyphenated linebreaks, based on dictionary evidence.</xd:li>
      </xd:ul>
      </xd:p>
    </xd:desc>
  </xd:doc>
  
  <!-- TEI output in UTF-8 NFC. -->
  <xsl:output method="xml" encoding="UTF-8"  normalization-form="NFC" omit-xml-declaration="no" exclude-result-prefixes="#all" byte-order-mark="no" indent="yes" />
  
<!-- Dictionary module allows us to process linebreaks properly. -->
  <xsl:include href="dictionary_module.xsl"/>
  
<!-- Utilities for various purposes including relative path calculation. -->
  <xsl:include href="utilities_module.xsl"/>

  <xsl:variable name="quot">"</xsl:variable>
  <xsl:variable name="reMonths" as="xs:string" select="'((jan)|(feb)|(mar)|(apr)|(may)|(jun)|(jul)|(aug)|(sep)|(oct)|(nov)|(dec)|(fév)|(avr)|(mai)|(jui)|(aoû)|(déc))'"/>
  <xsl:variable name="reYear" as="xs:string" select="'\d\d\d\d'"/>


<!-- Regular expressions used to determine the status of split paragraphs. -->
  <xsl:variable name="reOpenBeginning">^[\s"'\(\[]*[^A-Z]</xsl:variable>
  <xsl:variable name="reOpenEnd">[^\.\\!\?][\)\[\s]*$</xsl:variable>
  <xsl:variable name="reNewBeginning">^[\s"'\(\[]*[A-Z]</xsl:variable>
  <xsl:variable name="reClosedEnd">[\.\\!\?][\)\[\s]*$</xsl:variable>
  
    <xsl:variable name="rootEl" as="node()" select="//tei:TEI[1]"/> 
    
    <xsl:variable name="docUri" as="xs:anyURI" select="document-uri(/)"/> 
  
  <xsl:template match="/">
    
    
    
    <xsl:message>Input document URI is <xsl:value-of select="$docUri"/></xsl:message>
    
    <!-- It's useful to know the base URI of the TCCD repo itself. -->
    <xsl:variable name="baseDir" select="replace($docUri, '/data/.*$', '')"/>
    
    <xsl:variable name="sourceDir" select="replace($docUri, '/[^/]+$', '')"/>
    <xsl:variable name="docFileName" select="tokenize($docUri, '/')[last()]"/>
    
    <xsl:if test="$rootEl/@xml:id != substring-before($docFileName, '.xml')">
      <xsl:message>WARNING: Document file name does not match @xml:id on root TEI element.</xsl:message>
    </xsl:if>
    
  <!--Find the source document paths and check the docs are actually there.-->  
    
    <xsl:variable name="hocrDocUris" select="//tei:sourceDesc/tei:list/tei:item/tei:ptr/@target"/>
    
    <xsl:message>Found <xsl:value-of select="count($hocrDocUris)"/> URIs for HOCR documents.</xsl:message>
    
    <xsl:variable name="hocrDocs" as="node()*">
      <xsl:for-each select="$hocrDocUris">
        <xsl:variable name="fullPath" select="resolve-uri(., $docUri)"/>
        <xsl:if test="not(doc-available($fullPath))">
          <xsl:message terminate="yes">Document <xsl:value-of select="$fullPath"/> is not available. 
            Please check the ptr element in the teiHeader. 
            Terminating.</xsl:message>
        </xsl:if>
        <xsl:sequence select="doc($fullPath)"/>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:message>Found <xsl:value-of select="count($hocrDocs)"/> documents with OCR content.</xsl:message>
    
<!--  Now we do a bunch of checks to make sure we aren't overwriting data which is already 
      imported or processed. -->
    <xsl:if test="$rootEl/descendant::tei:facsimile or count($rootEl/tei:text/tei:body/tei:div/tei:p) gt 1 or not(//comment()[matches(., 'TEMPLATE:')])">
      <xsl:message terminate="yes">WARNING: This document appears to have already been processed.
                   Aborting this process to avoid overwriting good data. Please 
                   check whether this document already has imported OCR content.</xsl:message>
    </xsl:if>
    
    <xsl:variable name="currDate" select="current-date()"/>
    <xsl:variable name="currDateW3C" select="format-date($currDate, '[Y0001]-[M01]-[D01]')"/>
    <xsl:variable name="currDateText" select="format-date($currDate, '[D] [MNn] [Y0001]')"/>
    
<!--  If we've got this far, we're going to create the output document.  -->
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:copy-of select="$rootEl/@*[not(local-name(.) = 'type')]"/>
      <xsl:attribute name="type" select="'full'"/>
      <xsl:apply-templates select="$rootEl/tei:teiHeader" mode="tei"/>
      
<!--  We stash this in a variable because we need to be able to read the 
      image URLs later. -->
      <xsl:variable name="facsimile">
        <facsimile>
          <xsl:for-each select="$hocrDocs">
            <xsl:variable name="pageImageUri" select="hcmc:getImageUri(//xh:div[@class='ocr_page'][1]/@title)"/>
            <xsl:variable name="pgId" select="substring-before(tokenize($pageImageUri, '/')[last()], '.')"/>
            <surface xml:id="{$pgId}">
              <graphic url="{$pageImageUri}"/>
            </surface>
          </xsl:for-each>
        </facsimile>
      </xsl:variable>
      
<!--     Write it out to the document. -->
      <xsl:sequence select="$facsimile"/>

      <text>
        <body>
          <div type="debate">
            <xsl:variable name="firstPassOutput"> 
              <xsl:for-each select="$hocrDocs">
                <xsl:variable name="pos" select="position()"/>
                <xsl:variable name="pageNum" select="hcmc:getPageNumber(.)"/>
                <xsl:message>Processing page <xsl:value-of select="$pageNum"/></xsl:message>
                <pb n="{$pageNum}" facs="{$facsimile/descendant::tei:surface[$pos]/tei:graphic/@url}"/>
                <xsl:apply-templates select="//xh:div[@class='ocr_page']/*"/>
              </xsl:for-each>
            </xsl:variable>
            
<!--        NOTE: WE ARE NOT USING THIS SEQUENCE-JOINING CODE; IT'S NOT WORKABLE 
            GIVEN THE SAD STATE OF OUR INCOMING DATA. -->
            
<!--        This pass attempts to label paragraphs and formeworks in a manner that 
            makes it easier (on the next pass) to combine split paras and incorporate 
            formeworks inside them where appropriate. -->
            <!--<xsl:variable name="sequenceTypesDetected">
              <xsl:apply-templates mode="assignSequenceTypes" select="$firstPassOutput"/>
            </xsl:variable>-->
            
<!--        Next we do a special pass to confirm that the values we assigned in the 
            previous pass were actually sane. If this fails, the transformation exits
            with a detailed error message. -->
            <!--<xsl:variable name="dummy">
              <xsl:apply-templates mode="checkParaSeq" select="$sequenceTypesDetected/*"/>
            </xsl:variable>-->

            <!--<xsl:message>Ran the dummy test on <xsl:value-of select="count($dummy/*)"/> elements.</xsl:message>-->
            
<!--        Now we do another pass to act on the information we've previously calculated 
            and stored. -->
            <!--<xsl:variable name="sequencesJoined">
              <xsl:apply-templates mode="joinSequences" select="$sequenceTypesDetected"/>
            </xsl:variable>-->
            
<!--       Now we move to a couple more passes which handle the linebreak issues, using 
           an external module. -->
            <xsl:variable name="lbpass1Output">
              <xsl:apply-templates mode="lbpass1" select="$firstPassOutput"/>
            </xsl:variable>
            
            <xsl:apply-templates mode="lbpass2" select="$lbpass1Output"/>
          </div>
        </body>
        
      </text>

      
    </TEI>

  </xsl:template>
  
<!-- General TEI templates, mainly for header, in first pass. -->
  
  <xsl:template match="tei:revisionDesc" exclude-result-prefixes="#all" mode="tei">
    <xsl:variable name="w3today" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>    
    <xsl:copy>
      <change who="mholmes" when="{$w3today}">Transformed initial template file to incorporate corrected OCR content.</change>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
<!--  Default identity transformation for TEI elements and attributes. -->
  <xsl:template mode="#all" match="@*|tei:*|tei:*/node()" priority="-2">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
<!-- Remove all the template comments. -->
  <xsl:template match="comment()[matches(., 'TEMPLATE:')]" mode="tei"/>
  
  
  
<!--NOTE: THIS IS UNWORKABLE GIVEN THE REALLY SCRAPPY DATA WE HAVE. THERE ARE 
    TOO MANY VAGUE DIVIDERS, HEADINGS AND OTHER THINGS WHICH LOOK LIKE UNCLOSED
    PARAS BUT AREN'T. THE CODE IS HERE, BUT IS NOT BEING CALLED RIGHT NOW.
    
    TEI templates intended for second-pass processing, which set up attributes 
     that we're going to use in the next pass for rejoining split paragraphs and so on. 
     There are several types of thing, and we store these values in a phony temporary 
     @x attribute:
     
      - A STANDALONE paragraph, which opens and closes itself. Normally this is a para which 
        begins with a capital letter and ends with a closing punctuation mark, but it also 
        may include the initial paragraph which has text, which is always treated as an opener,
        even though it may itself be a continuation of a preceding para which we 
        have not captured. A standalone paragraph obviously brings to an end any preceding
        sequence of paras. If its preceding para is CONTINUING, an error should be raised.
        
      - An OPENING paragraph, which either begins with a capital or is the first paragraph
        in the text, and ends in the middle of a sentence (no closing punctuation). This 
        constitutes the beginning of a sequence, and subsequent paras and forme works will
        be gathered into it at the next pass. If its following paragraph (should one exist)
        is not CONTINUING or CLOSING, an error should be raised.
        
      - A CONTINUING paragraph, which does not start with a capital (and therefore is a 
        continuation of the preceding para) and does not end with closing punctuation. This
        will be gathered into a preceding paragraph during the next round of processing. If 
        its following paragraph (should one exist) is not CONTINUING or CLOSING, an error 
        should be raised.
        
      - A CLOSING paragraph, which does not start with a capital (i.e. it continues a 
        preceding para) but which does end with closing punctuation. This type of paragraph
        will be gathered into a preceding paragraph during processing, but it will be the 
        last component to be so gathered, closing the sequence. If its following paragraph
        is not STANDALONE or OPENING, then an error should be raised.
        
      - A GATHERABLE formeworks or milestone tag which whose preceding paragraph tag (if there is one) 
        is OPENING or CONTINUING. We would expect to gather this fw tag into its preceding
        paragraph in the next pass. If the subsequent paragraph is not CONTINUING or CLOSING,
        an error should be raised, but this will be accomplished by the processing of the 
        paragraph tag preceding the formeworks tag.
        
      - A SEPARATE formeworks or milestone tag, which either precedes any paragraph in the document 
        sequence, or whose preceding paragraph is STANDALONE or CLOSING. This fw tag will
        be output between paragraphs in the next pass.
  -->
  
<!--  This function tries to calculate the correct setting for a paragraph. -->
  <xsl:function name="hcmc:paraSeqType" as="xs:string">
    <xsl:param name="thisPara" as="element(tei:p)"/>
    <xsl:param name="precedingPara" as="element(tei:p)*"/>
    <xsl:param name="followingPara" as="element(tei:p)*"/>
    <xsl:variable name="thisParaType" as="xs:string">
      <xsl:choose>
<!-- It's the first para in the set and it's cleanly closed.       -->
        <xsl:when test="matches($thisPara, $reClosedEnd) and not($precedingPara)">STANDALONE</xsl:when>
<!-- It's the first para in the set and it's open at the end.       -->
        <xsl:when test="matches($thisPara, $reOpenEnd) and not($precedingPara)">OPENING</xsl:when>
<!-- It's a fresh opening and a fresh closing. -->
        <xsl:when test="matches($thisPara, $reNewBeginning) and matches($thisPara, $reClosedEnd)">STANDALONE</xsl:when>
<!-- It's a fresh opening which is not closed. -->
        <xsl:when test="matches($thisPara, $reNewBeginning) and matches($thisPara, $reOpenEnd)">OPENING</xsl:when>
<!-- It's open at both ends. -->
        <xsl:when test="matches($thisPara, $reOpenBeginning) and matches($thisPara, $reOpenEnd)">CONTINUING</xsl:when>
<!-- It's open at the beginning and closed at the end. -->
        <xsl:when test="matches($thisPara, $reOpenBeginning) and matches($thisPara, $reClosedEnd)">CLOSING</xsl:when>
<!-- Otherwise we presumably have some sort of error and we need to modify this code a bit. -->
        <xsl:otherwise><xsl:message terminate="yes">ERROR: The paragraph beginning 
        "<xsl:value-of select="substring($thisPara, 1, 30)"/>"
        and ending
        "<xsl:value-of select="substring($thisPara, string-length($thisPara) - 30, 30)"/>"
        cannot be assigned a sequence type by the current algorithm.</xsl:message></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:value-of select="$thisParaType"/>
  </xsl:function>
  
<!-- This function tries to calculate the correct setting for a formeworks
     or milestone tag. -->
  <xsl:function name="hcmc:milestoneSeqType" as="xs:string">
    <xsl:param name="thisTag" as="element()"/>
    <xsl:param name="precedingPara" as="element(tei:p)*"/>
    <xsl:variable name="thisTagType" as="xs:string">
      <xsl:choose>
<!-- If there's no preceding para, it must be separate.       -->
        <xsl:when test="not($precedingPara)">SEPARATE</xsl:when>
<!-- If the preceding para is closed, it must be separate. -->
        <xsl:when test="matches($precedingPara, $reClosedEnd)">SEPARATE</xsl:when>
<!-- If the preceding para is open then this must be gatherable. -->
        <xsl:when test="matches($precedingPara, $reOpenEnd)">GATHERABLE</xsl:when>
        <xsl:otherwise><xsl:message terminate="yes">ERROR: The fw  
          "<xsl:value-of select="$thisTag"/>"
          <xsl:if test="$precedingPara">
          which follows the paragraph ending:
          "<xsl:value-of select="substring($precedingPara, string-length($precedingPara) - 30, 30)"/>"
          </xsl:if>
          cannot be assigned a sequence type by the current algorithm.</xsl:message></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$thisTagType"/>
  </xsl:function>
  
<!-- Second-pass templates that assign values to paras and formeworks. -->
  <xsl:template match="tei:p" mode="assignSequenceTypes">
    <xsl:copy>
      <xsl:attribute name="x" select="hcmc:paraSeqType(., if (preceding::tei:p) then preceding::tei:p[1] else (), if (following::tei:p) then following::tei:p[1] else ())"/>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
<!-- Where fws might be nested, we only care about the top-level one.  -->
  <xsl:template match="tei:fw[not(ancestor::tei:fw)] | tei:pb | tei:cb | tei:milestone" mode="assignSequenceTypes">
    <xsl:copy>
      <xsl:attribute name="x" select="hcmc:milestoneSeqType(., if (preceding::tei:p) then preceding::tei:p[1] else ())"/>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
<!-- Sequence diagnostic checker templates which should raise errors for illogical sequences. -->
  <xsl:template mode="checkParaSeq" match="tei:p">
    <xsl:message>CHECKING A PARAGRAPH.</xsl:message>
    <xsl:variable name="result" as="xs:boolean">       
      <xsl:choose>
<!-- If this one is open-ended and the next is a starter, something is wrong. -->
        <xsl:when test="@x = ('OPENING', 'CONTINUING') and following::tei:p[1][@x=('STANDALONE', 'OPENING')]"><xsl:sequence select="false()"/></xsl:when>
<!-- If this one is closed-ended and the next is continuing, something is wrong. -->    
        <xsl:when test="@x = ('STANDALONE', 'CLOSING') and following::tei:p[1][@x='CONTINUING']"><xsl:sequence select="false()"/></xsl:when>
        <xsl:otherwise><xsl:sequence select="true()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$result = false()">
      <xsl:message terminate="yes">ERROR: The paragraph beginning 
        "<xsl:value-of select="substring(., 1, 30)"/>"
        and ending
        "<xsl:value-of select="substring(., string-length(.) - 30, 30)"/>"
        seems to have been assigned a sequence value that does not make 
        sense. <xsl:choose><xsl:when test="preceding::tei:p">
          The preceding paragraph was assigned a value of 
          <xsl:value-of select="preceding::tei:p[1]/@x"/>;
        </xsl:when><xsl:otherwise>It is the first para in the sequence;</xsl:otherwise></xsl:choose>
        This para has the value <xsl:value-of select="@x"/>.
        <xsl:choose><xsl:when test="following::tei:p">
          The following paragraph was assigned a value of 
          <xsl:value-of select="following::tei:p[1]/@x"/>.
        </xsl:when><xsl:otherwise>There is no following para.</xsl:otherwise></xsl:choose>
      </xsl:message>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="checkParaSeq" match="tei:fw | tei:pb | tei:cb | tei:milestone">
    <xsl:message>CHECKING A MILESTONE.</xsl:message>
    <xsl:variable name="result" as="xs:boolean">       
      <xsl:choose>
        <!-- If this one is gatherable and the preceding para is closed-ended, something is wrong. -->
        <xsl:when test="@x = 'GATHERABLE' and preceding::tei:p[1][@x=('STANDALONE', 'CLOSING')]"><xsl:sequence select="false()"/></xsl:when>
        <!-- If this one is separate and the preceding para is open-ended, something is wrong. -->    
        <xsl:when test="@x = 'SEPARATE' and following::tei:p[1][@x=('OPENING', 'CONTINUING')]"><xsl:sequence select="false()"/></xsl:when>
        <!-- If this one is separate and the following para is open, something is wrong. -->    
        <xsl:when test="@x = 'SEPARATE' and following::tei:p[1][@x=('CONTINUING', 'CLOSING')]"><xsl:sequence select="false()"/></xsl:when>
        <xsl:otherwise><xsl:sequence select="true()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$result = false()">
      <xsl:message terminate="yes">ERROR: The fw or milestone
        <xsl:value-of select="local-name(.)"/> ("<xsl:value-of select="."/>")
        seems to have been assigned a sequence value that does not make 
        sense. <xsl:choose><xsl:when test="preceding::tei:p">
          The preceding paragraph was assigned a value of 
          <xsl:value-of select="preceding::tei:p[1]/@x"/>;
        </xsl:when><xsl:otherwise>There is no preceding para;</xsl:otherwise></xsl:choose>
        This fw has the value <xsl:value-of select="@x"/>.
        <xsl:choose><xsl:when test="following::tei:p">
          The following paragraph was assigned a value of 
          <xsl:value-of select="following::tei:p[1]/@x"/>.
        </xsl:when><xsl:otherwise>There is no following para.</xsl:otherwise></xsl:choose>
      </xsl:message>
    </xsl:if>
  </xsl:template>
  
<!-- Third pass templates which actually combine broken paras and intervening fws. 
     In the process, we remove unwanted @n attributes. -->
  <!--<xsl:template match="tei:p[@x=('STANDALONE')]" mode="joinSequences">
    <p>
      <xsl:copy-of select="@*[not(local-name() = 'x')]"/>
      <xsl:copy-of select="node()"/>
    </p>
  </xsl:template>-->
  <xsl:template match="tei:*/@x" mode="joinSequences"/>
  
  <xsl:template match="tei:p[@x=('OPENING')]" mode="joinSequences">
    <xsl:variable name="thisId" select="generate-id(.)"/>
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name() = 'x')]"/>
      <xsl:copy-of select="node()"/>
      <xsl:for-each select="following::tei:p[@x=('CONTINUING', 'CLOSING')][preceding::tei:p[@x='OPENING'][1][generate-id(.) = $thisId]] | following::tei:*[@x='GATHERABLE'][not(ancestor::tei:fw)][preceding::tei:p[@x='OPENING'][1][generate-id(.) = $thisId]]">
        <xsl:choose>
          <xsl:when test="self::tei:p">
            <xsl:copy-of select="node()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:copy-of select="@*[not(local-name() = 'x')]"/>
              <xsl:copy-of select="node()"/>
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
<!-- Things we gathered in above need to be suppressed when we come to them. -->
  <xsl:template match="tei:*[@x='GATHERABLE'] | tei:p[@x=('CONTINUING', 'CLOSING')]" mode="joinSequences"/>
  
  
<!-- OLD STUFF THAT WAS FRAGILE AND BUGGY.  -->
<!-- First the initial para before the interrupting formeworks. -->
  <!--
  <xsl:template mode="assignSequenceTypes" match="tei:p[following-sibling::tei:*[1][self::tei:fw or self::tei:pb or self::tei:cb or self::tei:milestone]][matches(., '[^\.\\!\?]\s*$')][following-sibling::tei:p[1][matches(., '^\s*[^A-Z]')]]">
    <xsl:variable name="thisParaId" select="generate-id(.)"/>
    <p>
      <xsl:apply-templates select="node()" mode="#current"/>
      <xsl:copy-of select="(following-sibling::tei:fw | following-sibling::tei:pb | following-sibling::tei:cb | following-sibling::tei:milestone)[preceding-sibling::tei:p[1][generate-id(.) = $thisParaId]]"/>
<!-\- NOTE: BUG HERE. The code only incorporates the first paragraph in a sequence, 
     but paras can be very long and multiple items must be incorporated. This has 
     to be carefully recoded. -\->
      <xsl:copy-of select="following-sibling::tei:p[1][matches(., '^\s*[^A-Z]')]/node()"/>
    </p>
  </xsl:template>
  
<!-\- Now the following p that we want to suppress because we've handled it above. -\->
  <xsl:template mode="assignSequenceTypes" match="tei:p[preceding-sibling::tei:*[1][self::tei:fw or self::tei:pb or self::tei:cb or self::tei:milestone]][matches(., '^\s*[^A-Z]')][preceding-sibling::tei:p[1][matches(., '[^\.\\!\?]\s*$')]]"><xsl:comment>Para "<xsl:value-of select="substring(., 1, 80)"/>..." merged into previous para.</xsl:comment></xsl:template>
  
<!-\- Now the formeworks/milestones that we want to suppress because they're handled above. -\->
  <xsl:template mode="assignSequenceTypes" match="tei:*[self::tei:pb or self::tei:cb or self::tei:fw or self::tei:milestone][preceding-sibling::tei:p[1][matches(., '[^\.\\!\?]\s*$')]][following-sibling::tei:p[1][matches(., '^\s*[^A-Z]')]]"><xsl:comment>Milestone merged into previous para.</xsl:comment></xsl:template>-->
  
  
<!-- XHTML to TEI templates.  -->
<!--  If we find a horizontal line, we should assume it is a column break. -->
  <xsl:template match="xh:hr">
    <xsl:variable name="nums" select="hcmc:getTruePageColNumbers(ancestor::body)"/>
    <xsl:choose>
      <xsl:when test="not(following-sibling::*)"></xsl:when>
      <xsl:when test="count($nums) gt 1">
        <cb n="{$nums[2]}"/>
      </xsl:when>
      <xsl:otherwise>
        <milestone type="unknown"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="xh:br"><lb/></xsl:template>
  
  <xsl:template match="xh:span[@class='ocr_line']">
    <xsl:apply-templates mode="#current"/><lb/>
  </xsl:template>
  
  <xsl:template match="xh:span[@class='unclear']">
    <unclear n="{@title}"><xsl:apply-templates mode="#current"/></unclear>
  </xsl:template>
  
<!-- We dump our editorial injections. -->
  <xsl:template match="p[@class='editorial']"/>
  
<!-- The page container has already been used in the root template. -->
<!--  <xsl:template match="div[@type='ocr_page']">
    <pb/>
    <xsl:apply-templates/>
  </xsl:template>-->
  
<!-- We attempt to distinguish forme works from other components. We 
     do this on the assumption that an area which appears first or 
     last, and which contains short text strings, is a forme work. -->
  <xsl:template match="xh:div[@class='ocr_carea']">
    <xsl:variable name="thisArea" select="."/>
    <xsl:choose>
      <xsl:when test="hcmc:isMostLikelyFormeWorks(string($thisArea)) and (((not(preceding::xh:div[@class='ocr_carea'])) or (hcmc:isMostLikelyFormeWorks(string(preceding::xh:div[@class='ocr_carea'][1])))) or ((not(following::xh:div[@class='ocr_carea'])) or (hcmc:isMostLikelyFormeWorks(string(following::xh:div[@class='ocr_carea'][1])))))">
          <!-- Now we attempt to figure out what we have in here. Possibly colnum + running header + colnum.-->
          <xsl:variable name="components" select="tokenize(normalize-space(.), '\s+')"/>
          <xsl:choose>
            <xsl:when test="hcmc:isLikelyDate(.)">
              <fw type="dateline"><xsl:apply-templates select="node()" mode="fw"/></fw>
            </xsl:when>
            <xsl:when test="matches($components[1], '[ivxlcIVXLC0123456789]+') and matches($components[last()], 'ivxlcIVXLC0123456789+')">
              <fw type="num"><xsl:value-of select="$components[1]"/></fw>
              <xsl:if test="count($components) gt 2">
                <fw type="running"><xsl:value-of select="string-join((for $c in $components[position() gt 1 and position() lt last()] return $c), ' ')"/></fw>
              </xsl:if>
              <xsl:if test="count($components) gt 1">
                <fw type="num"><xsl:value-of select="$components[last()]"/></fw>
              </xsl:if>
            </xsl:when>
            <xsl:when test="matches($components[1], '[ivxlcIVXLC0123456789]+')">
              <fw type="num"><xsl:value-of select="$components[1]"/></fw>
              <xsl:if test="count($components) gt 1">
                <fw type="running"><xsl:value-of select="string-join((for $c in $components[position() gt 1] return $c), ' ')"/></fw>
              </xsl:if>
            </xsl:when>
            <xsl:when test="matches($components[last()], '[ivxlcIVXLC0123456789]+')">
              <xsl:if test="count($components) gt 1">
                <fw type="running"><xsl:value-of select="string-join((for $c in $components[position() lt last()] return $c), ' ')"/></fw>
              </xsl:if>
              <fw type="num"><xsl:value-of select="$components[last()]"/></fw>
            </xsl:when>
            <xsl:when test="matches(normalize-space(.), '[ivxlcIVXLC0123456789]+')">
              <fw type="num"><xsl:value-of select="normalize-space(.)"/></fw>
            </xsl:when>
            <xsl:otherwise>
              <fw type="running"><xsl:apply-templates select="." mode="fw"/></fw>
            </xsl:otherwise>
          </xsl:choose>
        
      </xsl:when>
<!-- Otherwise we just process its contents. -->
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="xh:p" mode="fw">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="xh:br" mode="fw">
    <xsl:if test="following-sibling::node()[string-length(normalize-space(.)) gt 0]">
      <lb/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text()" mode="fw">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="xh:p[not(@class='editorial')]">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="xh:span"><xsl:apply-templates/></xsl:template>
  
  <xsl:function name="hcmc:getImageUri" as="xs:string">
    <xsl:param name="titleAtt" as="node()"/>
    <xsl:variable name="srcDocUri" select="document-uri($titleAtt/ancestor::node()[last()])"/>
    <xsl:variable name="relUri" select="substring-before(substring-after($titleAtt, $quot), $quot)"/>
    <xsl:variable name="fullPath" select="resolve-uri($relUri, $srcDocUri)"/>
    <xsl:value-of select="hcmc:createRelativeUri($fullPath, $docUri)"/>
  </xsl:function>
  
<!-- This function applies a number of crude tests in an attempt to 
     determine whether a page- or column-leading or -trailing div should 
     be tagged as <fw>. -->
  <xsl:function name="hcmc:isMostLikelyFormeWorks" as="xs:boolean">
    <xsl:param name="inStr" as="xs:string"/>
    <xsl:variable name="normInStr" select="normalize-space($inStr)"/>
    <xsl:variable name="len" select="string-length($normInStr)"/>
    <xsl:variable name="muchUpperCase" select="matches($normInStr, '[A-Z]{5,}')"/>
    <xsl:variable name="hasDate" select="matches($normInStr, '1[89]\d\d')"/>
    <xsl:variable name="isNumber" select="matches($normInStr, '^[ivxlcIVXLC0123456789]+$')"/>
    <xsl:value-of select="($isNumber) or (($muchUpperCase or $hasDate) and ($len lt 30)) or ($muchUpperCase and $hasDate and $len lt 40)"/>
  </xsl:function>
  
<!-- This function tries to find the page number in the editorial header at the top. If that page number 
     is missing, it will attempt to get it from the linked page-image content. Finally, failing that, 
     it will default to using the filename. -->
  <xsl:function name="hcmc:getPageNumber" as="xs:string">
    <xsl:param name="hocrFile" as="node()"/>
    <xsl:choose>
      <xsl:when test="$hocrFile/descendant::xh:p[@class='editorial'][matches(., '\[[ivxlcIVXLC0123456789]+\]')]">
        <xsl:value-of select="replace(normalize-space($hocrFile/descendant::xh:p[@class='editorial'][matches(., '\[[ivxlcIVXLC0123456789]+\]')][1]), '.*\[([ivxlcIVXLC0123456789]+)\].*', '$1')"/>
      </xsl:when>
      <xsl:when test="$hocrFile/descendant::xh:div[@class='ocr_page']/@title[matches(., '\.jpg')]">
        <xsl:value-of select="$hocrFile/descendant::xh:div[@class='ocr_page'][1]/@title/substring-before(substring-after(., 'Page_'), '.jpg')"/>
      </xsl:when>
      <xsl:when test="matches(document-uri($hocrFile), '_\d+\.hocr\.html$')">
        <xsl:value-of select="replace(tokenize(document-uri($hocrFile), '_')[last()], '\.hocr\.html$', '')"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="'nk'"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="hcmc:getTruePageColNumbers" as="xs:string*">
    <xsl:param name="page"/>
    <xsl:variable name="editorialHeader" select="if ($page//xh:div[@class='editorial']) then $page//xh:div[@class='editorial'][1] else ()"/>
    <xsl:variable name="numsFromEditorialHeader" select="replace($editorialHeader, '^.+(\[[ivxlcIVXLC0123456789\-\s]+\]).+$', '$1')"/>
    <xsl:choose>
      <xsl:when test="string-length($numsFromEditorialHeader) gt 0">
        <xsl:value-of select="tokenize($numsFromEditorialHeader, '[\s\-]+')"/>
      </xsl:when>
      <xsl:otherwise>
<!--        Go back to the original source and try to find the page numbers. -->
        <xsl:variable name="firstMeaningfulDiv" select="if ($page//xh:div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0]) then normalize-space($page//xh:div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0][1]) else ''"/>
        <xsl:variable name="lastMeaningfulDiv" select="if ($page//xh:div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0]) then normalize-space($page//xh:div[@class='ocr_carea'][string-length(normalize-space(.)) gt 0][last()]) else ''"/>
        <xsl:variable name="possPageNum" as="xs:string*">
          <xsl:choose>
            <xsl:when test="string-length($firstMeaningfulDiv) gt 0 and matches($firstMeaningfulDiv, '\d')">
              <xsl:analyze-string select="$firstMeaningfulDiv" regex="((^[ivxc\d]+(\s|$))|((^|\s)[ivxc\d]+$))">
                <xsl:matching-substring><xsl:value-of select="."/></xsl:matching-substring>
                <xsl:non-matching-substring/>
              </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="string-length($lastMeaningfulDiv) gt 0 and matches($lastMeaningfulDiv, '\d')">
              <xsl:analyze-string select="$lastMeaningfulDiv" regex="((^[ivxc\d]+(\s|$))|((^|\s)[ivxc\d]+$))">
                <xsl:matching-substring><xsl:value-of select="normalize-space(.)"/></xsl:matching-substring>
                <xsl:non-matching-substring/>
              </xsl:analyze-string>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$possPageNum"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="hcmc:isLikelyDate" as="xs:boolean">
    <xsl:param name="inStr" as="xs:string"/>
    <xsl:value-of select="matches($inStr, $reMonths, 'mi') and matches($inStr, $reYear, 'm')"/>
  </xsl:function>
  
  
</xsl:stylesheet>
