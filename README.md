EXPath Website
==============

The EXPath website implementation: [http://expath.org/](http://expath.org/).

The content itself is not part of this repository, but is in the
repository `web-content`.  Within Servlex, next to the repostiory
where the website is installed, there must be a file
`expath-website/config.xml`, with the following content (the values
must be absolute paths where to find the specifications and the web
content):

    <config>
       <org-spec-dir>file:/.../expath-website/org-specs/</org-spec-dir>
       <w3c-spec-dir>file:/.../expath-website/expath-cg/specs/</w3c-spec-dir>
       <web-content-dir>file:/.../expath-website/web-content/pages/</web-content-dir>
    </config>
