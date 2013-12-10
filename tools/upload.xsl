<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:http="http://www.expath.org/mod/http-client"
                xmlns:ser="http://www.fgeorges.org/xslt/serial"
                xmlns:my="my..."
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="webpage.xsl"/>

   <xsl:param name="rel-base"  select="'../../releases/'"/>
   <xsl:param name="href-base" select="'../build.OLD/'"/>
   <!--xsl:param name="href-base" select="'http://localhost:8181/exist/rest/db/xxx/'"/>
   <xsl:param name="username"  select="'admin'"/>
   <xsl:param name="password"  select="'adminadmin'"/-->

   <xsl:variable name="my:rel-base"  select="resolve-uri($rel-base,  base-uri(sitemap))"/>
   <xsl:variable name="my:href-base" select="resolve-uri($href-base, base-uri(sitemap))"/>

   <xsl:template match="/">
      <xsl:sequence select="my:delete-dir($my:href-base)"/>
      <xsl:apply-templates select="*" mode="map"/>
   </xsl:template>

   <xsl:function name="my:delete-dir" xmlns:file="java:java.io.File">
      <xsl:param name="dir" as="xs:anyURI"/>
      <xsl:variable name="f" select="file:new($dir)"/>
      <xsl:if test="file:exists($f)">
         <xsl:sequence xmlns:utils="java:org.apache.commons.io.FileUtils"
                       select="utils:deleteDirectory($f)"/>
      </xsl:if>
   </xsl:function>

   <xsl:function name="my:resolve-uri" as="xs:anyURI">
      <xsl:param name="relative" as="xs:anyURI?"/>
      <xsl:param name="base"     as="xs:anyURI"/>
      <xsl:sequence select="
          if ( exists($relative) ) then
            resolve-uri($relative, $base)
          else
            $base"/>
   </xsl:function>

   <xsl:template match="sitemap" mode="map">
      <xsl:apply-templates select="*" mode="map">
         <xsl:with-param name="base"  select="base-uri(.)"/>
         <xsl:with-param name="rel"   select="$my:rel-base"/>
         <xsl:with-param name="href"  select="$my:href-base"/>
         <xsl:with-param name="menus" select="menu" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="menu" mode="map"/>

   <xsl:template match="dir" mode="map">
      <xsl:param name="base" as="xs:anyURI"/>
      <xsl:param name="rel"  as="xs:anyURI"/>
      <xsl:param name="href" as="xs:anyURI"/>
      <xsl:apply-templates select="*" mode="map">
         <xsl:with-param name="base" select="my:resolve-uri(@base,    $base)"/>
         <xsl:with-param name="rel"  select="my:resolve-uri(@release, $rel)"/>
         <xsl:with-param name="href" select="my:resolve-uri(@href,    $href)"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="dir[@copy/xs:boolean(.)]" mode="map">
      <xsl:param name="base" as="xs:anyURI"/>
      <xsl:param name="rel"  as="xs:anyURI"/>
      <xsl:param name="href" as="xs:anyURI"/>
      <xsl:variable name="b" select="my:resolve-uri(@base, $base)"/>
      <xsl:variable name="h" select="my:resolve-uri(@href, $href)"/>
      <xsl:sequence xmlns:utils="java:org.apache.commons.io.FileUtils"
                    xmlns:file="java:java.io.File"
                    select="utils:copyDirectory(file:new($b), file:new($h))"/>
      <xsl:if test="exists(* except exclude)">
         <xsl:sequence select="error((), 'dir[@copy] can only have ''exclude'' children')"/>
      </xsl:if>
      <xsl:apply-templates select="*" mode="map">
         <xsl:with-param name="base" select="$b"/>
         <xsl:with-param name="rel"  select="()"/> <!-- rel not useable anymore by descendants -->
         <xsl:with-param name="href" select="$h"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="exclude" mode="map">
      <xsl:param name="href" as="xs:anyURI"/>
      <xsl:variable name="h" select="resolve-uri(@name, $href)"/>
      <xsl:sequence xmlns:utils="java:org.apache.commons.io.FileUtils"
                    xmlns:file="java:java.io.File"
                    select="utils:forceDelete(file:new($h))"/>
   </xsl:template>

   <!--xsl:variable name="my:content-types-alist" as="element()+">
      <ct ext="css"  type="text/css"/>
      <!- - TODO: I guess there's a more appropriated type for XSLT. - ->
      <ct ext="xsl"  type="application/xml"/>
      <ct ext="xml"  type="application/xml"/>
      <ct ext="html" type="text/html"/>
   </xsl:variable-->

   <xsl:template match="rsrc" mode="map">
      <xsl:param name="base" as="xs:anyURI"/>
      <xsl:param name="rel"  as="xs:anyURI"/>
      <xsl:param name="href" as="xs:anyURI"/>
      <xsl:variable name="s" select="
          if ( exists(@name) ) then
            my:resolve-uri(@name, $rel)
          else
            my:resolve-uri(@src, $base)"/>
      <xsl:variable name="h" select="my:resolve-uri(@href, $href)"/>
      <!-- logging -->
      <xsl:message select="'Write rsrc', $h"/>
      <!-- copy the resource -->
      <xsl:sequence xmlns:file="java:java.io.File"
                    xmlns:utils="java:org.apache.commons.io.FileUtils"
                    select="utils:copyFile(file:new($s), file:new($h))"/>
   </xsl:template>

   <xsl:template match="page" mode="map">
      <xsl:param name="base"  as="xs:anyURI"/>
      <xsl:param name="href"  as="xs:anyURI"/>
      <xsl:param name="menus" as="element(menu)+" tunnel="yes"/>
      <xsl:variable name="s" select="resolve-uri(@src, $base)"  as="xs:anyURI"/>
      <xsl:variable name="h" select="resolve-uri(@href, $href)" as="xs:anyURI"/>
      <!--xsl:variable name="ext" select="replace(@src, '^.*\.', '')" as="xs:string"/-->
      <!--xsl:variable name="type" select="$my:content-types-alist[@ext eq $ext]/@type"/-->
      <!-- logging -->
      <xsl:message select="'Write page', $h"/>
      <!-- write the page -->
      <xsl:result-document href="{ $h }" method="html">
         <xsl:apply-templates select="doc($s)/*">
            <xsl:with-param name="menu" select="$menus[@name eq current()/@menu]"/>
         </xsl:apply-templates>
      </xsl:result-document>
      <!--xsl:choose>
         <xsl:when test="$ext eq 'xml'">
            <xsl:variable name="body" as="element()">
               <http:body content-type="{ $type }"/>
            </xsl:variable>
            <xsl:variable name="content">
               <xsl:apply-templates select="doc($s)" mode="format"/>
            </xsl:variable>
            <xsl:sequence select="my:put-in-exist($h, $body, $content)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="body" as="element()">
               <http:body href="{ $s }" content-type="{ $type }"/>
            </xsl:variable>
            <xsl:sequence select="my:put-in-exist($h, $body, ())"/>
         </xsl:otherwise>
      </xsl:choose-->
   </xsl:template>

   <!--xsl:template match="page" mode="map">
      <xsl:param name="base" as="xs:anyURI"/>
      <xsl:param name="href" as="xs:anyURI"/>
      <xsl:variable name="s" select="resolve-uri(@src, $base)"  as="xs:anyURI"/>
      <xsl:variable name="h" select="resolve-uri(@href, $href)" as="xs:anyURI"/>
      <xsl:variable name="ext" select="replace(@src, '^.*\.', '')" as="xs:string"/>
      <xsl:variable name="type" select="$my:content-types-alist[@ext eq $ext]/@type"/>
      <xsl:choose>
         <xsl:when test="$ext eq 'xml'">
            <xsl:variable name="body" as="element()">
               <http:body content-type="{ $type }"/>
            </xsl:variable>
            <xsl:variable name="content">
               <xsl:apply-templates select="doc($s)" mode="format"/>
            </xsl:variable>
            <xsl:sequence select="my:put-in-exist($h, $body, $content)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="body" as="element()">
               <http:body href="{ $s }" content-type="{ $type }"/>
            </xsl:variable>
            <xsl:sequence select="my:put-in-exist($h, $body, ())"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:function name="my:put-in-exist" mode="map">
      <xsl:param name="href"    as="xs:anyURI"/>
      <xsl:param name="body"    as="element(http:body)"/>
      <xsl:param name="content" as="document-node()?"/>
      <xsl:variable name="req" as="element()">
         <http:request method="put" auth-method="basic" send-authorization="true"
                       username="{ $username }" password="{ $password }">
            <xsl:copy-of select="$body"/>
         </http:request>
      </xsl:variable>
<xsl:message>
   REQ: <xsl:copy-of select="$req"/>
</xsl:message>
      <xsl:variable name="res" select="http:send-request($req, $href, $content)"/>
<xsl:message>
   RES: <xsl:copy-of select="$res"/>
</xsl:message>
      <xsl:if test="$res/xs:integer(@status) ne 201">
         <xsl:sequence select="error((), 'TODO: Error in sending HTTP!', $res)"/>
      </xsl:if>
   </xsl:function>

   <xsl:template match="node()" mode="format">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="format"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="sample" mode="format">
      <xsl:copy-of select="document(@href)"/>
   </xsl:template-->

</xsl:stylesheet>
