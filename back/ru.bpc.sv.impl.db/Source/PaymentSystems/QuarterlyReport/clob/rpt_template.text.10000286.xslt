<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="report">
        <xsl:for-each select="machine_readable/param">
            <xsl:if test="value_1 != '0'">
                <xsl:text>D,Q,</xsl:text>
                <xsl:choose>
                    <xsl:when test="card_type_id = '1005'">
                        <xsl:value-of select="//report/cmid_maestro"/>
                    </xsl:when>
					<xsl:otherwise>
                        <xsl:value-of select="//report/cmid"/>
     				</xsl:otherwise>
                </xsl:choose>
                <xsl:text>,0,</xsl:text>
                <xsl:if test="card_type_feature = 'CFCHDEBT'">
                    <xsl:choose>
                        <xsl:when test="card_type_id = '1004'">
                            <xsl:text>QL</xsl:text>
                        </xsl:when>
                        <xsl:when test="card_type_id = '1006'">
                            <xsl:text>QK</xsl:text>
                        </xsl:when>
                        <xsl:when test="card_type_id = '1007'">
                            <xsl:text>HA</xsl:text>
                        </xsl:when>
                        <xsl:when test="card_type_id = '1021'">
                            <xsl:text>HB</xsl:text>
                        </xsl:when>
                        <xsl:when test="card_type_id = '1023'">
                            <xsl:text>BW</xsl:text>
                        </xsl:when>
                        <xsl:when test="card_type_id = '1005'">
                            <xsl:text>QB</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:if test="card_type_feature = 'CFCHCRDT'">
                    <xsl:choose>
                        <xsl:when test="card_type_id = '1004'">
                            <xsl:text>QE</xsl:text>
                        </xsl:when>
                        <xsl:when test="card_type_id = '1006'">
                            <xsl:text>QD</xsl:text>
                        </xsl:when>
                        <xsl:when test="card_type_id = '1007'">
                            <xsl:text>QU</xsl:text>
                        </xsl:when>
                        <xsl:when test="card_type_id = '1021'">
                            <xsl:text>QF</xsl:text>
                        </xsl:when>
                        <xsl:when test="card_type_id = '1023'">
                            <xsl:text>BP</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>                
				<xsl:if test="card_type_feature = 'ACQUIRING'">
                    <xsl:choose>
                        <xsl:when test="card_type_id = '1002'">
							<xsl:choose>
							<xsl:when test="(param_id = '1063' or param_id = '1065' or param_id = '1066' or param_id = '1067')">
								<xsl:choose>
									<xsl:when test="impact = '1'">
										<xsl:text>CB</xsl:text>
									</xsl:when>
									<xsl:when test="impact = '-1'">
										<xsl:text>CD</xsl:text>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>CA</xsl:text>
							</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
                        <xsl:when test="card_type_id = '1005'">
							<xsl:text>QC</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="//report/quarter"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="//report/year"/>
                <xsl:text>,</xsl:text>
				<xsl:choose>
                    <xsl:when test="group_id = '106'">
                        <xsl:choose>
                            <xsl:when test="param_id = '1007'">
                                <xsl:text>dbo,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1010'">
                                <xsl:text>d1so,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '1012'">
                                <xsl:text>d6bo,</xsl:text>
                            </xsl:when>
                            <xsl:when test="param_id = '2057'">
                                <xsl:text>d4so,</xsl:text>
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
                            <xsl:when test="param_id = '2060'">
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
                            <xsl:when test="param_id = '2061'">
                                <xsl:text>b6s,</xsl:text>
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
                <xsl:if test = "value_2 != '0'">
                    <xsl:text>D,Q,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="card_type_id = '1005'">
                            <xsl:value-of select="//report/cmid_maestro"/>
                        </xsl:when>
			    		<xsl:otherwise>
                            <xsl:value-of select="//report/cmid"/>
         				</xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>,0,</xsl:text>
                    <xsl:if test="card_type_feature = 'CFCHDEBT'">
                        <xsl:choose>
                            <xsl:when test="card_type_id = '1004'">
                                <xsl:text>QL</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1006'">
                                <xsl:text>QK</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1007'">
                                <xsl:text>HA</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1021'">
                                <xsl:text>HB</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1023'">
                                <xsl:text>BW</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1005'">
                                <xsl:text>QB</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="card_type_feature = 'CFCHCRDT'">
                        <xsl:choose>
                            <xsl:when test="card_type_id = '1004'">
                                <xsl:text>QE</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1006'">
                                <xsl:text>QD</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1007'">
                                <xsl:text>QU</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1021'">
                                <xsl:text>QF</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1023'">
                                <xsl:text>BP</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
					<xsl:if test="card_type_feature = 'ACQUIRING'">
                        <xsl:choose>
                            <xsl:when test="card_type_id = '1002'">
								<xsl:choose>
								<xsl:when test="(param_id = '1063' or param_id = '1065' or param_id = '1066' or param_id = '1067')">
									<xsl:choose>
										<xsl:when test="impact = '1'">
											<xsl:text>CB</xsl:text>
										</xsl:when>
										<xsl:when test="impact = '-1'">
											<xsl:text>CD</xsl:text>
										</xsl:when>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>CA</xsl:text>
								</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
                            <xsl:when test="card_type_id = '1005'">
                                <xsl:text>QC</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
					<xsl:text>,</xsl:text>
                    <xsl:value-of select="//report/quarter"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="//report/year"/>
                    <xsl:text>,</xsl:text>
					<xsl:choose>
                        <xsl:when test="group_id = '106'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1007'">
                                    <xsl:text>dbc,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1010'">
                                    <xsl:text>d1sc,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1012'">
                                    <xsl:text>d6bc,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '2057'">
                                    <xsl:text>d4sc,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '115'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1034'">
                                    <xsl:text>e3s25,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '122'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1058'">
                                    <xsl:text>e3s25,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1059'">
                                    <xsl:text>e3s26,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1060'">
                                    <xsl:text>e3s27,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1061'">
                                    <xsl:text>e3s28,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1062'">
                                    <xsl:text>e3s29,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
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
                                <xsl:when test="param_id = '2060'">
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
                                <xsl:when test="param_id = '2061'">
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
                    <xsl:value-of select="value_2" />
                    <xsl:text>&#xA;</xsl:text>
                </xsl:if>
                <xsl:if test="card_type_feature != 'ACQUIRING'">
					<xsl:if test="value_3 != '0'">
						<xsl:text>D,Q,</xsl:text>
                        <xsl:choose>
                            <xsl:when test="card_type_id = '1005'">
                                <xsl:value-of select="//report/cmid_maestro"/>
                            </xsl:when>
					        <xsl:otherwise>
                                <xsl:value-of select="//report/cmid"/>
     	        			</xsl:otherwise>
                        </xsl:choose>
						<xsl:text>,0,</xsl:text>
						<xsl:if test="card_type_feature = 'CFCHDEBT'">
							<xsl:choose>
								<xsl:when test="card_type_id = '1004'">
									<xsl:text>QL</xsl:text>
								</xsl:when>
								<xsl:when test="card_type_id = '1006'">
									<xsl:text>QK</xsl:text>
								</xsl:when>
								<xsl:when test="card_type_id = '1007'">
									<xsl:text>HA</xsl:text>
								</xsl:when>
								<xsl:when test="card_type_id = '1021'">
									<xsl:text>HB</xsl:text>
								</xsl:when>
								<xsl:when test="card_type_id = '1023'">
									<xsl:text>BW</xsl:text>
								</xsl:when>
								<xsl:when test="card_type_id = '1005'">
									<xsl:text>QB</xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="card_type_feature = 'CFCHCRDT'">
							<xsl:choose>
								<xsl:when test="card_type_id = '1004'">
									<xsl:text>QE</xsl:text>
								</xsl:when>
								<xsl:when test="card_type_id = '1006'">
									<xsl:text>QD</xsl:text>
								</xsl:when>
								<xsl:when test="card_type_id = '1007'">
									<xsl:text>QU</xsl:text>
								</xsl:when>
								<xsl:when test="card_type_id = '1021'">
									<xsl:text>QF</xsl:text>
								</xsl:when>
								<xsl:when test="card_type_id = '1023'">
									<xsl:text>BP</xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:text>,</xsl:text>
						<xsl:value-of select="//report/quarter"/>
						<xsl:text>,</xsl:text>
						<xsl:value-of select="//report/year"/>
						<xsl:text>,</xsl:text>
						<xsl:choose>
							<xsl:when test="group_id = '106'">
								<xsl:choose>
									<xsl:when test="param_id = '1007'">
										<xsl:text>dbs,</xsl:text>
									</xsl:when>
									<xsl:when test="param_id = '1010'">
										<xsl:text>d1s,</xsl:text>
									</xsl:when>
									<xsl:when test="param_id = '1012'">
										<xsl:text>d6bs,</xsl:text>
									</xsl:when>
									<xsl:when test="param_id = '2057'">
										<xsl:text>d4s,</xsl:text>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="group_id = '115'">
								<xsl:choose>
									<xsl:when test="param_id = '1034'">
										<xsl:text>e3t25,</xsl:text>
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
						<xsl:value-of select="value_3" />
						<xsl:text>&#xA;</xsl:text>
					</xsl:if>
				</xsl:if>
            </xsl:if>
            <xsl:if test="value_1 = '0'">
                <xsl:if test = "value_2 != '0'">
                    <xsl:text>D,Q,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="card_type_id = '1005'">
                            <xsl:value-of select="//report/cmid_maestro"/>
                        </xsl:when>
			    		<xsl:otherwise>
                            <xsl:value-of select="//report/cmid"/>
     	    			</xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>,0,</xsl:text>
                    <xsl:if test="card_type_feature = 'CFCHDEBT'">
                        <xsl:choose>
                            <xsl:when test="card_type_id = '1004'">
                                <xsl:text>QL</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1006'">
                                <xsl:text>QK</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1007'">
                                <xsl:text>HA</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1021'">
                                <xsl:text>HB</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1023'">
                                <xsl:text>BW</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1005'">
                                <xsl:text>QB</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="card_type_feature = 'CFCHCRDT'">
                        <xsl:choose>
                            <xsl:when test="card_type_id = '1004'">
                                <xsl:text>QE</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1006'">
                                <xsl:text>QD</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1007'">
                                <xsl:text>QU</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1021'">
                                <xsl:text>QF</xsl:text>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1023'">
                                <xsl:text>BP</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
					<xsl:if test="card_type_feature = 'ACQUIRING'">
                        <xsl:choose>
                            <xsl:when test="card_type_id = '1002'">
								<xsl:choose>
								<xsl:when test="(param_id = '1063' or param_id = '1065' or param_id = '1066' or param_id = '1067')">
									<xsl:choose>
										<xsl:when test="impact = '1'">
											<xsl:text>CB</xsl:text>
										</xsl:when>
										<xsl:when test="impact = '-1'">
											<xsl:text>CD</xsl:text>
										</xsl:when>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>CA</xsl:text>
								</xsl:otherwise>
								</xsl:choose>
                            </xsl:when>
                            <xsl:when test="card_type_id = '1005'">
								<xsl:text>QC</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
					<xsl:text>,</xsl:text>
                    <xsl:value-of select="//report/quarter"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="//report/year"/>
					<xsl:text>,</xsl:text>
                    <xsl:text></xsl:text>
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
                                <xsl:when test="param_id = '1109'">
                                    <xsl:text>acs,</xsl:text>
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
                                    <xsl:text>dbc,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1010'">
                                    <xsl:text>d1sc,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1012'">
                                    <xsl:text>d6bc,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '2057'">
                                    <xsl:text>d4sc,</xsl:text>
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
                                <xsl:when test="param_id = '2059'">
                                    <xsl:text>b3s,</xsl:text>
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
                        <xsl:when test="group_id = '145'">
                            <xsl:choose>
                                <xsl:when test="param_id = '1113'">
                                    <xsl:text>f2s,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="group_id = '223'">
                            <xsl:choose>
                                <xsl:when test="param_id = '2054'">
                                    <xsl:text>b4as,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '2055'">
                                    <xsl:text>b4bs,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1114'">
                                    <xsl:text>b4cs,</xsl:text>
                                </xsl:when>
                                <xsl:when test="param_id = '1115'">
                                    <xsl:text>b4ds,</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:value-of select="value_2" />
                    <xsl:text>&#xA;</xsl:text>
					<xsl:if test = "value_3 != '0'">
                        <xsl:text>D1,Q,</xsl:text>
                        <xsl:choose>
                            <xsl:when test="card_type_id = '1005'">
                                <xsl:value-of select="//report/cmid_maestro"/>
                            </xsl:when>
					        <xsl:otherwise>
                                <xsl:value-of select="//report/cmid"/>
     	        			</xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>,0,</xsl:text>
                        <xsl:if test="card_type_feature = 'CFCHDEBT'">
                            <xsl:choose>
                                <xsl:when test="card_type_id = '1004'">
                                    <xsl:text>QL</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1006'">
                                    <xsl:text>QK</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1007'">
                                    <xsl:text>HA</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1021'">
                                    <xsl:text>HB</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1023'">
                                    <xsl:text>BW</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1005'">
                                    <xsl:text>QB</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                        <xsl:if test="card_type_feature = 'CFCHCRDT'">
                            <xsl:choose>
                                <xsl:when test="card_type_id = '1004'">
                                    <xsl:text>QE</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1006'">
                                    <xsl:text>QD</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1007'">
                                    <xsl:text>QU</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1021'">
                                    <xsl:text>QF</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1023'">
                                    <xsl:text>BP</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
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
                                    <xsl:when test="param_id = '1109'">
                                        <xsl:text>act,</xsl:text>
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
                            <xsl:when test="group_id = '106'">
                                <xsl:choose>
                                    <xsl:when test="param_id = '1007'">
                                        <xsl:text>dbs,</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="param_id = '1010'">
                                        <xsl:text>d1s,</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="param_id = '1012'">
                                        <xsl:text>d6bs,</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="param_id = '2057'">
                                        <xsl:text>d4s,</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="group_id = '112'">
                                <xsl:choose>
                                    <xsl:when test="param_id = '1106'">
                                        <xsl:text>g3at,</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="group_id = '113'">
                                <xsl:choose>
                                    <xsl:when test="param_id = '1024'">
                                        <xsl:text>g5at,</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="group_id = '114'">
                                <xsl:choose>
                                    <xsl:when test="param_id = '1027'">
                                        <xsl:text>g6at,</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
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
                                    <xsl:when test="param_id = '2059'">
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
                            <xsl:when test="group_id = '145'">
                                <xsl:choose>
                                    <xsl:when test="param_id = '1113'">
                                        <xsl:text>f2t,</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="group_id = '223'">
                                <xsl:choose>
                                    <xsl:when test="param_id = '2054'">
                                        <xsl:text>b4at,</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="param_id = '2055'">
                                        <xsl:text>b4bt,</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="param_id = '1114'">
                                        <xsl:text>b4ct,</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="param_id = '1115'">
                                        <xsl:text>b4dt,</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:value-of select="value_3" />
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                </xsl:if>
				<xsl:if test = "value_2 = '0'">
                    <xsl:if test = "value_3 != '0'">
                        <xsl:text>D,Q,</xsl:text>
                        <xsl:choose>
                            <xsl:when test="card_type_id = '1005'">
                                <xsl:value-of select="//report/cmid_maestro"/>
                            </xsl:when>
					        <xsl:otherwise>
                                <xsl:value-of select="//report/cmid"/>
     	        			</xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>,0,</xsl:text>
                        <xsl:if test="card_type_feature = 'CFCHDEBT'">
                            <xsl:choose>
                                <xsl:when test="card_type_id = '1004'">
                                    <xsl:text>QL</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1006'">
                                    <xsl:text>QK</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1007'">
                                    <xsl:text>HA</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1021'">
                                    <xsl:text>HB</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1023'">
                                    <xsl:text>BW</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1005'">
                                    <xsl:text>QB</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                        <xsl:if test="card_type_feature = 'CFCHCRDT'">
                            <xsl:choose>
                                <xsl:when test="card_type_id = '1004'">
                                    <xsl:text>QE</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1006'">
                                    <xsl:text>QD</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1007'">
                                    <xsl:text>QU</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1021'">
                                    <xsl:text>QF</xsl:text>
                                </xsl:when>
                                <xsl:when test="card_type_id = '1023'">
                                    <xsl:text>BP</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="//report/quarter"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="//report/year"/>
                        <xsl:text>,</xsl:text>
                        <xsl:choose>
                            <xsl:when test="group_id = '106'">
                                <xsl:choose>
                                    <xsl:when test="param_id = '1008'">
                                        <xsl:text>d3s,</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="param_id = '1009'">
                                        <xsl:text>d3l,</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="param_id = '1011'">
                                        <xsl:text>das,</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="param_id = '2056'">
                                        <xsl:text>d3as,</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="param_id = '2058'">
                                        <xsl:text>dat,</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="group_id = '112'">
                                <xsl:choose>
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
                                    <xsl:when test="param_id = '1028'">
                                        <xsl:text>g6bt,</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="param_id = '1029'">
                                        <xsl:text>g6ct,</xsl:text>
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
                        </xsl:choose>
                        <xsl:value-of select="value_3" />
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>