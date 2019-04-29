<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="report">
        <xsl:for-each select="acquiring/param">
            <xsl:if test="value_1 != '0'">
                <xsl:text>D,Q,</xsl:text>
                <xsl:value-of select="//report/cmid"/>
                <xsl:text>,0,QM,</xsl:text>
                <xsl:value-of select="//report/quarter"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="//report/year"/>
                <xsl:text>,</xsl:text>
                <xsl:choose>
                    <xsl:when test="group_id = '123'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1063'">
                                <xsl:text>a5as,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1064'">
                                <xsl:text>a14s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1065'">
                                <xsl:text>a5s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1066'">
                                <xsl:text>a8s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1067'">
                                <xsl:text>a12s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1068'">
                                <xsl:text>a6s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '124'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1063'">
                                <xsl:text>b5as,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1064'">
                                <xsl:text>b14s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1065'">
                                <xsl:text>b5s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1066'">
                                <xsl:text>b8s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1067'">
                                <xsl:text>b12s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1068'">
                                <xsl:text>b6s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '125'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1063'">
                                <xsl:text>b5asa,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1064'">
                                <xsl:text>b14sa,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1065'">
                                <xsl:text>b5sa,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1066'">
                                <xsl:text>b8sa,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1067'">
                                <xsl:text>b12sa,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1068'">
                                <xsl:text>b6sa,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '126'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1063'">
                                <xsl:text>b5asm,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1064'">
                                <xsl:text>b14sm,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1065'">
                                <xsl:text>b5sm,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1066'">
                                <xsl:text>b8sm,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1067'">
                                <xsl:text>b12sm,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1068'">
                                <xsl:text>b6sm,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '127'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1063'">
                                <xsl:text>c5as,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1064'">
                                <xsl:text>c14s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1065'">
                                <xsl:text>c5s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1066'">
                                <xsl:text>c8s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1067'">
                                <xsl:text>c12s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1068'">
                                <xsl:text>c6s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '129'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1069'">
                                <xsl:text>h1t,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1070'">
                                <xsl:text>h3t,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1071'">
                                <xsl:text>h9t,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '130'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1072'">
                                <xsl:text>h6s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1073'">
                                <xsl:text>h6n,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1074'">
                                <xsl:text>h6l,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1075'">
                                <xsl:text>h7gs,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1076'">
                                <xsl:text>h7gn,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1077'">
                                <xsl:text>h7gl,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1078'">
                                <xsl:text>h8s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1079'">
                                <xsl:text>h9b,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1080'">
                                <xsl:text>h9c,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1081'">
                                <xsl:text>h9d,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1082'">
                                <xsl:text>h9e,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="value_1" />
                <xsl:text>&#xA;</xsl:text>
                <xsl:if test = "substring-before(value_2,',') != '0'">
                    <xsl:text>D,Q,</xsl:text>
                    <xsl:value-of select="//report/cmid"/>
                    <xsl:text>,0,QM,</xsl:text>
                    <xsl:value-of select="//report/quarter"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="//report/year"/>
                    <xsl:text>,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="group_id = '123'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1063'">
                                    <xsl:text>a5at,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1064'">
                                    <xsl:text>a14t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1065'">
                                    <xsl:text>a5t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1066'">
                                    <xsl:text>a8t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1067'">
                                    <xsl:text>a12t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1068'">
                                    <xsl:text>a6t,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '124'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1063'">
                                    <xsl:text>b5at,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1064'">
                                    <xsl:text>b14t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1065'">
                                    <xsl:text>b5t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1066'">
                                    <xsl:text>b8t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1067'">
                                    <xsl:text>b12t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1068'">
                                    <xsl:text>b6t,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '125'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1063'">
                                    <xsl:text>b5ata,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1064'">
                                    <xsl:text>b14ta,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1065'">
                                    <xsl:text>b5ta,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1066'">
                                    <xsl:text>b8ta,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1067'">
                                    <xsl:text>b12ta,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1068'">
                                    <xsl:text>b6ta,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '126'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1063'">
                                    <xsl:text>b5atm,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1064'">
                                    <xsl:text>b14tm,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1065'">
                                    <xsl:text>b5tm,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1066'">
                                    <xsl:text>b8tm,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1067'">
                                    <xsl:text>b12tm,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1068'">
                                    <xsl:text>b6tm,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '127'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1063'">
                                    <xsl:text>c5at,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1064'">
                                    <xsl:text>c14t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1065'">
                                    <xsl:text>c5t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1066'">
                                    <xsl:text>c8t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1067'">
                                    <xsl:text>c12t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1068'">
                                    <xsl:text>c6t,</xsl:text>
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
