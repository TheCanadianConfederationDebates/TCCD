<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:rng="http://relaxng.org/ns/structure/1.0"
            queryBinding="xslt2">
   <ns xmlns="http://purl.oclc.org/dsdl/schematron"
       xmlns:xlink="http://www.w3.org/1999/xlink"
       xmlns:tei="http://www.tei-c.org/ns/1.0"
       xmlns:teix="http://www.tei-c.org/ns/Examples"
       prefix="tei"
       uri="http://www.tei-c.org/ns/1.0"/>
   <ns xmlns="http://purl.oclc.org/dsdl/schematron"
       xmlns:xlink="http://www.w3.org/1999/xlink"
       xmlns:tei="http://www.tei-c.org/ns/1.0"
       xmlns:teix="http://www.tei-c.org/ns/Examples"
       prefix="xs"
       uri="http://www.w3.org/2001/XMLSchema"/>
   <ns xmlns="http://purl.oclc.org/dsdl/schematron"
       xmlns:xlink="http://www.w3.org/1999/xlink"
       xmlns:tei="http://www.tei-c.org/ns/1.0"
       xmlns:teix="http://www.tei-c.org/ns/Examples"
       prefix="rng"
       uri="http://relaxng.org/ns/structure/1.0"/>
   <ns xmlns="http://purl.oclc.org/dsdl/schematron"
       xmlns:xlink="http://www.w3.org/1999/xlink"
       xmlns:tei="http://www.tei-c.org/ns/1.0"
       xmlns:teix="http://www.tei-c.org/ns/Examples"
       prefix="sch"
       uri="http://purl.oclc.org/dsdl/schematron"/>
   <ns xmlns="http://purl.oclc.org/dsdl/schematron"
       xmlns:xlink="http://www.w3.org/1999/xlink"
       xmlns:tei="http://www.tei-c.org/ns/1.0"
       xmlns:teix="http://www.tei-c.org/ns/Examples"
       prefix="xsl"
       uri="http://www.w3.org/1999/XSL/Transform"/>
   <ns xmlns="http://purl.oclc.org/dsdl/schematron"
       xmlns:xlink="http://www.w3.org/1999/xlink"
       xmlns:tei="http://www.tei-c.org/ns/1.0"
       xmlns:teix="http://www.tei-c.org/ns/Examples"
       prefix="eg"
       uri="http://www.tei-c.org/ns/Examples"/>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-att.datable.w3c-att-datable-w3c-when-constraint-rule-1">
      <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:*[@when]">
        <sch:report test="@notBefore|@notAfter|@from|@to" role="nonfatal">The @when attribute cannot be used with any other att.datable.w3c attributes.</sch:report>
      </sch:rule>
   </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-att.datable.w3c-att-datable-w3c-from-constraint-rule-2">
      <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:*[@from]">
        <sch:report test="@notBefore" role="nonfatal">The @from and @notBefore attributes cannot be used together.</sch:report>
      </sch:rule>
   </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-att.datable.w3c-att-datable-w3c-to-constraint-rule-3">
      <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:*[@to]">
        <sch:report test="@notAfter" role="nonfatal">The @to and @notAfter attributes cannot be used together.</sch:report>
      </sch:rule>
   </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-att.global.rendition-renditionpointer-constraint-rule-4">
      <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:*[@rendition]">
                           <sch:let name="results"
                  value="for $val in tokenize(normalize-space(@rendition),'\s+') return matches($val,'^((simple)|(tccd)):')"/>
                           <sch:assert test="every $x in $results satisfies $x"> Error: Each of the rendition values in "<sch:value-of select="@rendition"/>" must point to a token in the Simple scheme (simple:*) or a tccd-prefixed value (tccd:*) (<sch:value-of select="$results"/>)</sch:assert>
                        </sch:rule>
   </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-att.typed-subtypeTyped-constraint-rule-5">
      <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:*[@subtype]">
        <sch:assert test="@type">The <sch:name/> element should not be categorized in detail with @subtype unless also categorized in general with @type</sch:assert>
      </sch:rule>
   </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-att.styleDef-schemeVersion-schemeVersionRequiresScheme-constraint-rule-6">
      <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:*[@schemeVersion]">
            <sch:assert test="@scheme and not(@scheme = 'free')">
              @schemeVersion can only be used if @scheme is specified.
            </sch:assert>
          </sch:rule>
   </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-p-abstractModel-structure-p-constraint-report-4">
            <rule context="tei:p">
               <report xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:svg="http://www.w3.org/2000/svg"
                 xmlns:math="http://www.w3.org/1998/Math/MathML"
                 test="not(ancestor::tei:floatingText) and (ancestor::tei:p or ancestor::tei:ab)          and not(parent::tei:exemplum                |parent::tei:item                |parent::tei:note                |parent::tei:q                |parent::tei:quote                |parent::tei:remarks                |parent::tei:said                |parent::tei:sp                |parent::tei:stage                |parent::tei:cell                |parent::tei:figure                )">
        Abstract model violation: Paragraphs may not occur inside other paragraphs or ab elements.
      </report>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-p-abstractModel-structure-l-constraint-report-5">
            <rule context="tei:p">
               <report xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:svg="http://www.w3.org/2000/svg"
                 xmlns:math="http://www.w3.org/1998/Math/MathML"
                 test="ancestor::tei:l[not(.//tei:note//tei:p[. = current()])]">
        Abstract model violation: Lines may not contain higher-level structural elements such as div, p, or ab.
      </report>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-desc-deprecationInfo-only-in-deprecated-constraint-rule-7">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:desc[ @type eq 'deprecationInfo']">
	              <sch:assert test="../@validUntil">Information about a
	deprecation should only be present in a specification element
	that is being deprecated: that is, only an element that has a
	@validUntil attribute should have a child &lt;desc
	type="deprecationInfo"&gt;.</sch:assert>
            </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-name-alignRefAndType-constraint-rule-8">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:name">
                           <sch:assert test="matches(@ref, '^((lg:lg)|(UNSPECIFIED))') or not(@type='legislature')">
                      If this is a legislature name, it should have @type='legislature' and 
                      a suitable value for @ref, starting with 'lg:lg'.
                    </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-ptr-ptrAtts-constraint-report-6">
            <rule context="tei:ptr">
               <report xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:svg="http://www.w3.org/2000/svg"
                 xmlns:math="http://www.w3.org/1998/Math/MathML"
                 test="@target and @cRef">Only one of the
attributes @target and @cRef may be supplied on <name/>.</report>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-ref-refAtts-constraint-report-7">
            <rule context="tei:ref">
               <report xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:svg="http://www.w3.org/2000/svg"
                 xmlns:math="http://www.w3.org/1998/Math/MathML"
                 test="@target and @cRef">Only one of the
	attributes @target' and @cRef' may be supplied on <name/>
               </report>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-list-gloss-list-must-have-labels-constraint-rule-9">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:list[@type='gloss']">
	              <sch:assert test="tei:label">The content of a "gloss" list should include a sequence of one or more pairs of a label element followed by an item element</sch:assert>
            </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-milestone-unknownmilestonetype-constraint-rule-10">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:milestone">
                           <sch:report test="@type='unknown'" role="warning">
                              Please examine this milestone and re-encode it 
                              appropriately. Unknown milestone types should 
                              not appear in files committed to the repository.
                           </sch:report>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-lb-lbbreakmaybewarning-constraint-rule-11">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:lb">
                           <sch:report test="@break='maybe'" role="warning">
                              Please examine this linebreak and decide whether it should be
                              @break="yes" (there are two separate words) or @break="no"
                              (this is a single word which is hyphenated only because there
                              is a linebreak).
                           </sch:report>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-lb-nowhitespacearoundintrawordbreak-constraint-rule-12">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:lb[@break='no']">
                           <sch:assert test="not(matches(preceding::text()[1], '((\s+$)|([\-–—]+\s*$))')) and (not(matches(following::text()[1], '^\s+')) or following::*[1][self::tei:pb or self::tei:cb or self::tei:fw or self::tei:milestone])">
                              If a linebreak is non-breaking (@break="no", meaning that it occurs in the middle
                              of a word), then the hyphen and all whitespace around the linebreak should be 
                              removed.
                           </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-title-titleInTitleStmt-constraint-rule-13">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:titleStmt/tei:title">
                           <sch:assert test="ancestor::tei:TEI[@xml:id=('personography', 'placeography', 'taxonomies', 'bibliography')] or (child::tei:name[@ref] and child::tei:date[@when or (@from and @to)])">
                              The title element in a titleStmt must contain both a name element and 
                              a date element with appropriate attributes.
                           </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-l-abstractModel-structure-l-constraint-report-10">
            <rule context="tei:l">
               <report xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:svg="http://www.w3.org/2000/svg"
                 xmlns:math="http://www.w3.org/1998/Math/MathML"
                 test="ancestor::tei:l[not(.//tei:note//tei:l[. = current()])]">
        Abstract model violation: Lines may not contain lines or lg elements.
      </report>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-lg-atleast1oflggapl-constraint-assert-9">
            <rule context="tei:lg">
               <sch:assert xmlns:xi="http://www.w3.org/2001/XInclude"
                     xmlns:svg="http://www.w3.org/2000/svg"
                     xmlns:math="http://www.w3.org/1998/Math/MathML"
                     xmlns="http://www.tei-c.org/ns/1.0"
                     test="count(descendant::tei:lg|descendant::tei:l|descendant::tei:gap) &gt; 0">An lg element
        must contain at least one child l, lg or gap element.</sch:assert>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-lg-abstractModel-structure-l-constraint-report-11">
            <rule context="tei:lg">
               <report xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:svg="http://www.w3.org/2000/svg"
                 xmlns:math="http://www.w3.org/1998/Math/MathML"
                 test="ancestor::tei:l[not(.//tei:note//tei:lg[. = current()])]">
        Abstract model violation: Lines may not contain line groups.
      </report>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-quotation-quotationContents-constraint-report-12">
            <rule context="tei:quotation">
               <report xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:svg="http://www.w3.org/2000/svg"
                 xmlns:math="http://www.w3.org/1998/Math/MathML"
                 test="not(@marks) and not (tei:p)">
On <name/>, either the @marks attribute should be used, or a paragraph of description provided</report>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-TEI-rootIdEqualsFileName-constraint-rule-14">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:TEI">
                           <sch:let name="reqId"
                  value="substring-before(tokenize(document-uri(/), '/')[last()], '.xml')"/>
                           <sch:let name="unexpandedId" value="substring-before($reqId, '_expanded')"/>
                           <sch:assert test="@xml:id = ($reqId, $unexpandedId)"> 
                    The @xml:id attribute on the TEI element (<sch:value-of select="@xml:id"/>) should match the 
                    document filename without extension (<sch:value-of select="$reqId"/>).
                  </sch:assert>
                           <sch:report role="warning" test="$reqId = concat($unexpandedId, '_expanded')">
                              Check this file to make sure it has been expanded correctly.
                              If it has, re-save it over the original template file, and delete
                              the file with "_expanded" in its filename.
                           </sch:report>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-TEI-curlyQuotesNotAllowed-constraint-rule-15">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:TEI">
                           <sch:assert test="not(matches(., '[“”‘’]'))"> 
                              The file <sch:value-of select="@xml:id"/>.xml appears to use at least one
                              "curly" quote or apostrophe (“”‘’). Please use the straight versions of 
                              quotation marks and apostrophes throughout. 
                           </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-TEI-shouldHaveXmlLang-constraint-rule-16">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:TEI">
                           <sch:assert test="@xml:lang or not(starts-with(@xml:id, 'lg'))">
                              All debate day documents should have an @xml:lang attribute on the root
                              element; French documents should be xml:lang="fr" and English documents
                              should be xml:lang="en".
                           </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-div-divnesting1-constraint-rule-17">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:div[@type=('document', 'section')][not(ancestor::tei:TEI[@xml:id = ('personography', 'placeography', 'taxonomies', 'bibliography')])]">
                           <sch:assert test="parent::tei:div[@type=('debate', 'treaty', 'article')]">
                    Error: a div with @type="document" or "section" must be a child of a div with 
                    @type="debate", "treaty" or "article".
                  </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-div-divnesting2-constraint-rule-18">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:div[parent::tei:body][not(ancestor::tei:TEI[@xml:id = ('personography', 'placeography', 'taxonomies', 'bibliography')])]">
                           <sch:assert test="@type=('debate', 'article', 'treaty')">
                              Error: a document body must contain a treaty, a debate, or an article reporting
                              a debate (div/@type="debate", "treaty", or "article").
                           </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-div-abstractModel-structure-l-constraint-report-14">
            <rule context="tei:div">
               <report xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:svg="http://www.w3.org/2000/svg"
                 xmlns:math="http://www.w3.org/1998/Math/MathML"
                 test="ancestor::tei:l">
        Abstract model violation: Lines may not contain higher-level structural elements such as div.
      </report>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-div-abstractModel-structure-p-constraint-report-15">
            <rule context="tei:div">
               <report xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:svg="http://www.w3.org/2000/svg"
                 xmlns:math="http://www.w3.org/1998/Math/MathML"
                 test="ancestor::tei:p or ancestor::tei:ab and not(ancestor::tei:floatingText)">
        Abstract model violation: p and ab may not contain higher-level structural elements such as div.
      </report>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-persName-constraintpersnameref-constraint-rule-19">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:persName[not(parent::tei:person or parent::tei:respStmt)]">
                           <sch:assert test="matches(@ref, '^((pers:[A-Z]{3,4}\d+)|(UNSPECIFIED))$')">
                              The @ref attribute value should start with 'pers:' and have the form
                              'pers:AAAA1' (four, or occasionally only three, letters followed by a number).
                           </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-persName-constraintpersnamewhitespace1-constraint-rule-20">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:persName[not(parent::tei:person or parent::tei:respStmt or ancestor::tei:place)]">
                           <sch:assert test="not(matches(., concat('^[\s', $quotes, $punctuation, ']'))) and not(matches(., concat('[\s', $quotes, $punctuation, ']$')))">
                              A persName should not begin or end with a space or punctuation within 
                              the tag; these should be outside the tag.
                           </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-persName-constraintpersnamewhitespace2-constraint-rule-21">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:persName[not(parent::tei:person or parent::tei:respStmt)]">
                           <sch:assert test="matches(preceding-sibling::node()[1], concat('[\(\s‪', $quotes, '\-—\[]$')) or not(preceding-sibling::node())">
                              Before a persName element, we would expect to see a space or
                              (occasionally, perhaps) an opening quotation mark or square bracket.
                           </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-persName-constraintpersnamewhitespace3-constraint-rule-22">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:persName[not(parent::tei:person or parent::tei:respStmt)]">
                           <sch:assert test="matches(following-sibling::node()[1], concat('^[\)\s‪', $quotes, $punctuation, '\-—]')) or not(following-sibling::node())">
                              After a persName element, we would expect to see a space or
                              some following punctuation.
                           </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-persName-constraintpersnamenotnested-constraint-rule-23">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:persName">
                           <sch:assert test="not(ancestor::tei:persName)">
                              persName elements should not be nested inside other persNames.
                           </sch:assert>
                        </sch:rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-person-personIdNoClashWithPlace-constraint-assert-20">
            <rule context="tei:person">
               <sch:assert xmlns:xi="http://www.w3.org/2001/XInclude"
                     xmlns:svg="http://www.w3.org/2000/svg"
                     xmlns:math="http://www.w3.org/1998/Math/MathML"
                     xmlns="http://www.tei-c.org/ns/1.0"
                     test="not(doc-available('../placeography/placeography.xml')) or not(@xml:id = doc('../placeography/placeography.xml')//tei:place/@xml:id)">
                           The xml:ids of person elements must not clash with those of place elements
                           in the placeography file.
                        </sch:assert>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-place-placeIdNoClashWithPerson-constraint-assert-21">
            <rule context="tei:place">
               <sch:assert xmlns:xi="http://www.w3.org/2001/XInclude"
                     xmlns:svg="http://www.w3.org/2000/svg"
                     xmlns:math="http://www.w3.org/1998/Math/MathML"
                     xmlns="http://www.tei-c.org/ns/1.0"
                     test="not(doc-available('../personography/personography.xml')) or not(@xml:id = doc('../personography/personography.xml')//tei:person/@xml:id)">
                           The xml:ids of place elements must not clash with those of person elements
                           in the personography file.
                        </sch:assert>
            </rule>
         </pattern>
   <pattern xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:teix="http://www.tei-c.org/ns/Examples"
            id="tccd-table-tablerowsmusthavealignedcells-constraint-rule-24">
            <sch:rule xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                context="tei:table">
                           <sch:let name="totalRows" value="count(tei:row)"/>
                           <sch:let name="firstRowCols"
                  value="sum((for $c in tei:row[1]/tei:cell return if ($c/@cols) then xs:integer($c/@cols) else 1))"/>
                           <sch:let name="totalRequiredCells" value="($totalRows * $firstRowCols)"/>
                           <sch:let name="totalActualCells"
                  value="sum((for $c in descendant::tei:cell return if ($c/@cols and $c/@rows) then (xs:integer($c/@cols) * xs:integer($c/@rows)) else if ($c/@cols) then xs:integer($c/@cols) else if ($c/@rows) then xs:integer($c/@rows) else 1))"/>
                           <sch:assert test="$totalRequiredCells = $totalActualCells">
                              Based on its first row, this table should have <sch:value-of select="$totalRequiredCells"/> cells, but it 
                              actually has <sch:value-of select="$totalActualCells"/>.
                           </sch:assert>
                        </sch:rule>
         </pattern>
   <sch:pattern xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:teix="http://www.tei-c.org/ns/Examples">
                        <sch:let name="double.quotes" value="'&#34;“”'"/>
                        <sch:let name="apos.typographic" value="'‘’'"/>
                        <sch:let name="apos.straight" value="''''"/>
                        <sch:let name="quotes" value="concat($apos.straight, '&#34;')"/>
                        <sch:let name="punctuation" value="'\.\?!\(\):;,\[\]…'"/>
                     </sch:pattern>
   <sch:diagnostics/>
</sch:schema>
