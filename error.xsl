<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	extension-element-prefixes="str"
>
    <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="text()"/>

    <xsl:template match="/">
            <html>
                    <body>
                        <h1><xsl:value-of select="/root/add/doc/field[@name='oai_id']"/></h1>
                        <xsl:apply-templates/>
                        <xsl:call-template name="original_md"/>
                        <xsl:call-template name="solr_doc"/>
                    </body>
            </html>
    </xsl:template>

    <xsl:template match="/root/response/lst[@name='error']">
            <dl>
                    <dt>Error code: <xsl:value-of select="int[@name='code']" /></dt>
                    <dd><xsl:value-of select="str[@name='msg']" /></dd>
            </dl>
    </xsl:template>


    <xsl:template name="original_md">
            <h2>The orginal metadata</h2>
            <pre><xsl:value-of select="/root/add/doc/field[@name='original_metadata_ss']"/></pre>
    </xsl:template>

    <xsl:template name="solr_doc">
            <h2>The actual solr doc</h2>
            <pre>
                    &lt;doc&gt;
                    <xsl:for-each select="/root/add/doc/field">
                        <xsl:text>&lt;field name="</xsl:text><xsl:value-of select="@name"/><xsl:text>"&gt;</xsl:text><xsl:value-of select="."/>&lt;/field&gt;
                    </xsl:for-each>
                    &lt;/doc&gt;
            </pre>
    </xsl:template>
</xsl:stylesheet>
