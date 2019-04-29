<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="report">
        <xsl:for-each select="issuing/param">
            <xsl:if test="value_1 != '0'">
                <xsl:text>D,Q,</xsl:text>
                <xsl:value-of select="//report/cmid"/>
                <xsl:text>,0,</xsl:text>
                <xsl:if test="//report/card_type_id = '1005'">
                    <xsl:text>QB</xsl:text>
                </xsl:if>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="//report/quarter"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="//report/year"/>
                <xsl:text>,</xsl:text>
                <xsl:choose>
                    <xsl:when test="group_id = '116'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1039'">
                                <xsl:text>a1s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1040'">
                                <xsl:text>mna2s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1041'">
                                <xsl:text>mda1s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1042'">
                                <xsl:text>mda2s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1043'">
                                <xsl:text>mda3s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1044'">
                                <xsl:text>a3s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '117'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1039'">
                                <xsl:text>b1s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1040'">
                                <xsl:text>mnb2s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1041'">
                                <xsl:text>mdb1s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1042'">
                                <xsl:text>mdb2s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1043'">
                                <xsl:text>mdb3s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1044'">
                                <xsl:text>b3s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '119'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1045'">
                                <xsl:text>d5s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1046'">
                                <xsl:text>d4bs,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1047'">
                                <xsl:text>d18s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1048'">
                                <xsl:text>d19s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1049'">
                                <xsl:text>d4s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '120'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1050'">
                                <xsl:text>d1s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '121'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1051'">
                                <xsl:text>e3s14,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1052'">
                                <xsl:text>e3s15,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1053'">
                                <xsl:text>e3s16,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '122'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1054'">
                                <xsl:text>d4s20,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1055'">
                                <xsl:text>d4s22,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1058'">
                                <xsl:text>d4s25,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1059'">
                                <xsl:text>d4s26,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1060'">
                                <xsl:text>d4s27,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1061'">
                                <xsl:text>d4s28,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1062'">
                                <xsl:text>d4s29,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="value_1" />
                <xsl:text>&#xA;</xsl:text>
                <xsl:if test = "substring-before(value_2,',') != '0'">
                    <xsl:text>D,Q,</xsl:text>
                    <xsl:value-of select="//report/cmid"/>
                    <xsl:text>,0,</xsl:text>
                    <xsl:if test="//report/card_type_id = '1005'">
                        <xsl:text>QB</xsl:text>
                    </xsl:if>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="//report/quarter"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="//report/year"/>
                    <xsl:text>,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="group_id = '116'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1039'">
                                    <xsl:text>a1t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1040'">
                                    <xsl:text>mna2t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1041'">
                                    <xsl:text>mda1t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1042'">
                                    <xsl:text>mda2t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1043'">
                                    <xsl:text>mda3t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1044'">
                                    <xsl:text>a3t,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '117'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1039'">
                                    <xsl:text>b1t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1040'">
                                    <xsl:text>mnb2t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1041'">
                                    <xsl:text>mdb1t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1042'">
                                    <xsl:text>mdb2t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1043'">
                                    <xsl:text>mdb3t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1044'">
                                    <xsl:text>b3t,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '121'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1051'">
                                    <xsl:text>e3t14,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1052'">
                                    <xsl:text>e3t15,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1053'">
                                    <xsl:text>e3t16,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '122'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1058'">
                                    <xsl:text>e3t25,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1059'">
                                    <xsl:text>e3t26,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1060'">
                                    <xsl:text>e3t27,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1061'">
                                    <xsl:text>e3t28,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1062'">
                                    <xsl:text>e3t29,</xsl:text>
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
