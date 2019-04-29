<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="report">
        <xsl:for-each select="machine_readable">
            <xsl:text>C,Q,</xsl:text>
            <xsl:value-of select="//report/year"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="//report/quarter"/>
            <xsl:text>,0,</xsl:text>
            <xsl:value-of select="//report/cmid"/>
            <xsl:text>,0,</xsl:text>
            <xsl:value-of select="//report/user_name"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="//report/user_name"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="//report/email"/>
            <xsl:text>,,,</xsl:text>
            <xsl:value-of select="//report/phone_number"/>
            <xsl:text>,,,</xsl:text>
            <xsl:value-of select="//report/current_date"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="//report/send_date"/>
            <xsl:text>,,</xsl:text>
            <xsl:value-of select="//report/currency_flag"/>
        </xsl:for-each>
		<xsl:text>&#xA;</xsl:text>
        <xsl:for-each select="machine_readable">
            <xsl:text>C,Q,</xsl:text>
            <xsl:value-of select="//report/year"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="//report/quarter"/>
            <xsl:text>,1,</xsl:text>
            <xsl:value-of select="//report/cmid_maestro"/>
            <xsl:text>,0,</xsl:text>
            <xsl:value-of select="//report/user_name"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="//report/user_name"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="//report/email"/>
            <xsl:text>,,,</xsl:text>
            <xsl:value-of select="//report/phone_number"/>
            <xsl:text>,,,</xsl:text>
            <xsl:value-of select="//report/current_date"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="//report/send_date"/>
            <xsl:text>,,</xsl:text>
            <xsl:value-of select="//report/currency_flag"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
