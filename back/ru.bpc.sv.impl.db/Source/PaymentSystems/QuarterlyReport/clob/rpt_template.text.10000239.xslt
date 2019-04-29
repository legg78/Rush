<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="report">
        <xsl:for-each select="acquiring/param">
            <xsl:if test="value_1 != '0'">
                <xsl:text>D,Q,</xsl:text>
                <xsl:value-of select="//report/cmid"/>
                <xsl:text>,0,QC,</xsl:text>
                <xsl:value-of select="//report/quarter"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="//report/year"/>
                <xsl:text>,</xsl:text>
                <xsl:choose>
                    <xsl:when test="group_id = '131'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1063'">
                                <xsl:text>a5as,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1064'">
                                <xsl:text>amna2s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1065'">
                                <xsl:text>amda1s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1066'">
                                <xsl:text>amda2s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1067'">
                                <xsl:text>amda3s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1068'">
                                <xsl:text>a6s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '132'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1063'">
                                <xsl:text>b5bs,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1064'">
                                <xsl:text>bmnb2s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1065'">
                                <xsl:text>bmdb1s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1066'">
                                <xsl:text>bmdb2s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1067'">
                                <xsl:text>bmdb3s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1068'">
                                <xsl:text>b6s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '133'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1083'">
                                <xsl:text>h3at,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1084'">
                                <xsl:text>h9t,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1085'">
                                <xsl:text>h6s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1086'">
                                <xsl:text>h7gs,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1087'">
                                <xsl:text>h8s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1088'">
                                <xsl:text>h9b,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1089'">
                                <xsl:text>h9c,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1090'">
                                <xsl:text>h9d,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1091'">
                                <xsl:text>h9e,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '134'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1092'">
                                <xsl:text>e3s17,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1093'">
                                <xsl:text>e3s18,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1094'">
                                <xsl:text>e3s19,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="value_1" />
                <xsl:text>&#xA;</xsl:text>
                <xsl:if test = "substring-before(value_2,',') != '0'">
                    <xsl:text>D,Q,</xsl:text>
                    <xsl:value-of select="//report/cmid"/>
                    <xsl:text>,0,QC,</xsl:text>
                    <xsl:value-of select="//report/quarter"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="//report/year"/>
                    <xsl:text>,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="group_id = '131'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1063'">
                                    <xsl:text>a5at,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1064'">
                                    <xsl:text>amna2t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1065'">
                                    <xsl:text>amda1t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1066'">
                                    <xsl:text>amda2t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1067'">
                                    <xsl:text>amda3t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1068'">
                                    <xsl:text>a6t,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '132'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1063'">
                                    <xsl:text>b5bt,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1064'">
                                    <xsl:text>bmnb2t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1065'">
                                    <xsl:text>bmdb1t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1066'">
                                    <xsl:text>bmdb2t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1067'">
                                    <xsl:text>bmdb3t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1068'">
                                    <xsl:text>b6t,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '134'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1092'">
                                    <xsl:text>e3t17,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1093'">
                                    <xsl:text>e3t18,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1094'">
                                    <xsl:text>e3t19,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:value-of select="substring-before(value_2,',')" />
                    <xsl:text>&#xA;</xsl:text>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
