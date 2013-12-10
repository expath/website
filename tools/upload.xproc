<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step">

   <p:output port="result"/>

   <p:option name="rest-base" select="'http://localhost:8181/exist/rest/db/expath'"/>
   <p:option name="username" select="'admin'"/>
   <p:option name="password" select="'adminadmin'"/>

   <p:wrap wrapper="c:body" match="/">
      <p:input port="source">
         <p:document href="modules.xml"/>
      </p:input>
   </p:wrap>

   <p:add-attribute match="/c:body" attribute-name="content-type"
      attribute-value="application/xml"/>

   <p:wrap wrapper="c:request" match="/"/>

   <p:add-attribute match="/c:request" attribute-name="username">
      <p:with-option name="attribute-value" select="$username"/>
   </p:add-attribute>

   <p:add-attribute match="/c:request" attribute-name="password">
      <p:with-option name="attribute-value" select="$password"/>
   </p:add-attribute>

   <p:add-attribute match="/c:request" attribute-name="href"
      attribute-value="http://localhost:8181/exist/rest/db/expath/modules.xml"/>

   <p:set-attributes match="/c:request">
      <p:input port="attributes">
         <p:inline>
            <c:request method="put" auth-method="Basic" send-authorization="true"/>
         </p:inline>
      </p:input>
   </p:set-attributes>

   <p:http-request/>

</p:declare-step>
