<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:proj="http://expath.org/ns/project"
                xmlns:w="http://expath.org/ns/website#build"
                name="pipeline"
                version="1.0">

   <!-- the project.xml -->
   <p:input port="source" primary="true"/>

   <!-- the parameters -->
   <p:input port="parameters" primary="true" kind="parameter"/>

   <p:import href="http://expath.org/ns/project/library.xpl"/>
   <p:import href="http://expath.org/ns/project/build.xproc"/>

   <p:declare-step type="w:inject-version">
      <p:documentation>
         <p>Inject version and revision into webpage.xsl.</p>
         <p>Does not need the corresponding entry in the manifest, as it is an
            override of an existing entry from src/.  It just has to keep the
            same base URI, it will then override webpage.xsl automatically.</p>
      </p:documentation>
      <p:option name="version" required="true"/>
      <p:input  port="source"     primary="true"/>
      <p:input  port="parameters" primary="true" kind="parameter"/>
      <p:output port="result"     primary="true"/>
      <p:xslt>
         <p:with-param name="proj:version" select="$version"/>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               version="2.0">
                  <xsl:param name="proj:version"  as="xs:string"/>
                  <xsl:param name="proj:revision" as="xs:string"/>
                  <!-- Copy everything... -->
                  <xsl:template match="node()">
                     <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates select="node()"/>
                     </xsl:copy>
                  </xsl:template>
                  <!-- ...but resolve the $version and $revision global variables. -->
                  <xsl:template match="xsl:stylesheet/xsl:variable[@name = ('version', 'revision')]">
                     <xsl:copy>
                        <xsl:copy-of select="@* except @select"/>
                        <xsl:attribute name="select" select="
                            replace(
                              replace(@select, '@@REVISION@@', $proj:revision),
                              '@@VERSION@@', $proj:version)"/>
                     </xsl:copy>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <p:variable name="version" select="/proj:project/@version"/>

   <w:inject-version name="inject">
      <p:with-option name="version" select="$version"/>
      <p:input port="source">
         <p:document href="../src/webpage.xsl"/>
      </p:input>
      <p:input port="parameters">
         <p:pipe step="pipeline" port="parameters"/>
      </p:input>
   </w:inject-version>

   <!-- call the standard step with the modified webpage.xsl -->
   <proj:build ignore-dirs=".~,.svn">
      <p:input port="source">
         <p:pipe step="pipeline" port="source"/>
      </p:input>
      <p:input port="files">
         <p:pipe step="inject" port="result"/>
      </p:input>
      <p:input port="manifest">
         <p:inline>
            <manifest/>
	 </p:inline>
      </p:input>
   </proj:build>

</p:declare-step>
