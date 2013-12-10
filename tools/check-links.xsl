<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:jt="http://saxon.sf.net/java-type"
                xmlns:file="java:java.io.File"
                xmlns:uri="java:java.net.URI"
                xmlns:my="my-private-uri-TODO"
                exclude-result-prefixes="xs h jt file uri my"
                version="2.0">

   <xsl:output indent="yes"/>

   <xsl:param name="root" select="resolve-uri('../build/')" as="xs:anyURI"/>
   <xsl:param name="suffix" select="'.html'" as="xs:string"/>

   <xsl:template name="main">
      <xsl:sequence select="my:recurse-dir(file:new($root))"/>
   </xsl:template>

   <xsl:function name="my:recurse-dir">
      <xsl:param name="dir" as="jt:java.io.File"/>
      <xsl:for-each select="file:list($dir)">
         <xsl:variable name="f" select="file:new($dir, xs:string(.))"/>
         <xsl:choose>
            <xsl:when test="file:isDirectory($f)">
               <xsl:message select="'Recursing:', $f"/>
               <xsl:sequence select="my:recurse-dir($f)"/>
            </xsl:when>
            <xsl:when test="ends-with(., $suffix)">
               <xsl:message select="'Checking:', $f"/>
               <xsl:sequence select="my:check-file($f)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:message select="'Ignored:', $f"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:function>

   <xsl:function name="my:check-file">
      <xsl:param name="f" as="jt:java.io.File"/>
      <xsl:for-each select="document(file:toURI($f))//h:a/@href">
         <xsl:if test=". ne '.'
                       and not(starts-with(., '#'))
                       and not(uri:is-absolute(uri:new(.)))">
            <xsl:variable name="target" select="file:new(resolve-uri(., base-uri(.)))"/>
            <!--xsl:message select="'HREF:', $target"/-->
            <xsl:if test="not(file:exists($target))">
               <xsl:message select="'BROKEN LINK:', $target"/>
               <broken base="{ base-uri(.) }">
                  <href>
                     <xsl:value-of select="."/>
                  </href>
                  <resolved>
                     <xsl:value-of select="$target"/>
                  </resolved>
               </broken>
            </xsl:if>
         </xsl:if>
      </xsl:for-each>
   </xsl:function>

</xsl:stylesheet>
