<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="report">
        <xsl:for-each select="issuing/param">
            <xsl:if test="value_1 != '0'">
                <xsl:text>D,Q,</xsl:text>
                <xsl:value-of select="//report/cmid"/>
                <xsl:text>,0,</xsl:text>
                <xsl:choose>
                    <xsl:when test="//report/card_type_id = '1006'">
                        <xsl:text>QK</xsl:text>
                    </xsl:when>
                    <xsl:when test="//report/card_type_id = '1007'">
                        <xsl:text>QL</xsl:text>
                    </xsl:when>
                    <xsl:when test="//report/card_type_id = '1021'">
                        <xsl:text>HB</xsl:text>
                    </xsl:when>
                    <xsl:when test="//report/card_type_id = '1023'">
                        <xsl:text>BU</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="//report/quarter"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="//report/year"/>
                <xsl:text>,</xsl:text>
                <xsl:choose>
                    <xsl:when test="group_id = '101'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1000'">
                                <xsl:text>a1s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1001'">
                                <xsl:text>a13s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1002'">
                                <xsl:text>a1bs,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1003'">
                                <xsl:text>a7s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1004'">
                                <xsl:text>a11s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1006'">
                                <xsl:text>a3s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '102'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1000'">
                                <xsl:text>b1s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1001'">
                                <xsl:text>b13s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1002'">
                                <xsl:text>b1bs,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1003'">
                                <xsl:text>b7s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1004'">
                                <xsl:text>b11s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1006'">
                                <xsl:text>b3s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '103'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1000'">
                                <xsl:text>b1sa,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1001'">
                                <xsl:text>b13sa,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1002'">
                                <xsl:text>b1bsa,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1003'">
                                <xsl:text>b7sa,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1004'">
                                <xsl:text>b11sa,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1006'">
                                <xsl:text>b4as,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '104'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1000'">
                                <xsl:text>b1sm,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1001'">
                                <xsl:text>b13sm,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1002'">
                                <xsl:text>b1bsm,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1003'">
                                <xsl:text>b7sm,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1004'">
                                <xsl:text>b11sm,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1006'">
                                <xsl:text>b4bs,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '105'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1000'">
                                <xsl:text>c1s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1001'">
                                <xsl:text>c13s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1002'">
                                <xsl:text>c1bs,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1003'">
                                <xsl:text>c7s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1004'">
                                <xsl:text>c11s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1006'">
                                <xsl:text>c3s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '106'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1007'">
                                <xsl:text>dbs,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1008'">
                                <xsl:text>d3s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1009'">
                                <xsl:text>d3l,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1010'">
                                <xsl:text>d1s,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1011'">
                                <xsl:text>das,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1012'">
                                <xsl:text>d4s,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '112'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1106'">
                                <xsl:text>g3as,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '113'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1024'">
                                <xsl:text>g5as,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '114'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1027'">
                                <xsl:text>g6as,</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="group_id = '115'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1030'">
                                <xsl:text>d4s20,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1031'">
                                <xsl:text>d4s22,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1034'">
                                <xsl:text>d4s25,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1035'">
                                <xsl:text>d4s26,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1036'">
                                <xsl:text>d4s27,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1037'">
                                <xsl:text>d4s28,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1038'">
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
                    <xsl:choose>
                        <xsl:when test="//report/card_type_id = '1006'">
                            <xsl:text>QK</xsl:text>
                        </xsl:when>
                        <xsl:when test="//report/card_type_id = '1007'">
                            <xsl:text>QL</xsl:text>
                        </xsl:when>
                        <xsl:when test="//report/card_type_id = '1021'">
                            <xsl:text>HB</xsl:text>
                        </xsl:when>
                        <xsl:when test="//report/card_type_id = '1023'">
                            <xsl:text>BU</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="//report/quarter"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="//report/year"/>
                    <xsl:text>,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="group_id = '101'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1000'">
                                    <xsl:text>a1t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1001'">
                                    <xsl:text>a13t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1002'">
                                    <xsl:text>a1bt,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1003'">
                                    <xsl:text>a7t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1004'">
                                    <xsl:text>a11t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1006'">
                                    <xsl:text>a3t,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '102'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1000'">
                                    <xsl:text>b1t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1001'">
                                    <xsl:text>b13t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1002'">
                                    <xsl:text>b1bt,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1003'">
                                    <xsl:text>b7t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1004'">
                                    <xsl:text>b11t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1006'">
                                    <xsl:text>b3t,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '103'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1000'">
                                    <xsl:text>b1ta,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1001'">
                                    <xsl:text>b13ta,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1002'">
                                    <xsl:text>b1bta,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1003'">
                                    <xsl:text>b7ta,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1004'">
                                    <xsl:text>b11ta,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1006'">
                                    <xsl:text>b4at,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '104'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1000'">
                                    <xsl:text>b1tm,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1001'">
                                    <xsl:text>b13tm,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1002'">
                                    <xsl:text>b1btm,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1003'">
                                    <xsl:text>b7tm,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1004'">
                                    <xsl:text>b11tm,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1006'">
                                    <xsl:text>b4bt,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '105'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1000'">
                                    <xsl:text>c5at,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1001'">
                                    <xsl:text>c13t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1002'">
                                    <xsl:text>c1bt,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1003'">
                                    <xsl:text>c7t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1004'">
                                    <xsl:text>c11t,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1006'">
                                    <xsl:text>c3t,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '112'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1106'">
                                    <xsl:text>g3at,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1107'">
                                    <xsl:text>g3bt,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1108'">
                                    <xsl:text>g3ct,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '113'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1024'">
                                    <xsl:text>g5at,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1025'">
                                    <xsl:text>g5bt,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1026'">
                                    <xsl:text>g5ct,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '114'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1027'">
                                    <xsl:text>g6at,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1028'">
                                    <xsl:text>g6bt,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1029'">
                                    <xsl:text>g6ct,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '115'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1034'">
                                    <xsl:text>e3t25,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1035'">
                                    <xsl:text>e3t26,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1036'">
                                    <xsl:text>e3t27,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1037'">
                                    <xsl:text>e3t28,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1038'">
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
