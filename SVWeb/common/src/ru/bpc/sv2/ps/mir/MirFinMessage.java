package ru.bpc.sv2.ps.mir;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@SuppressWarnings("unused")
public class MirFinMessage implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = 7204592637349588198L;

    private Long id;
    private String status;
    private Long fileId;
    private Boolean incoming;
    private Boolean reversal;
    private Boolean rejected;
    private Long rejectId;
    private Boolean fpdMatched;
    private Long fpdId;
    private Long disputeId;
    private Boolean impact;

    private Long sessionId;
    private Long sessionFileId;
    private String fileName;
    private Date fileDate;

    private Date dateFrom;
    private Date dateTo;
    private String lang;


    private Long instId;
    private String instName;
    private String mti;
    private Long networkId;
    private String networkName;

    private Long splitHash;

    private String de002;
    private String de003_1;
    private String de003_2;
    private String de003_3;
    private Long de004;
    private Long de005;
    private Long de006;
    private String de009;
    private String de010;
    private Date de012;
    private Date de014;

    private String de022_1;
    private String de022_2;
    private String de022_3;
    private String de022_4;
    private String de022_5;
    private String de022_6;
    private String de022_7;
    private String de022_8;
    private String de022_9;
    private String de022_10;
    private String de022_11;

    private Long de023;
    private String de024;
    private String de025;
    private String de026;
    private Long de030_1;
    private Long de030_2;
    private String de031;
    private String de032;
    private String de033;
    private String de037;
    private String de038;
    private String de040;
    private String de041;
    private String de042;
    private String de043_1;
    private String de043_2;
    private String de043_3;
    private String de043_4;
    private String de043_5;
    private String de043_6;
    private String de049;
    private String de050;
    private String de051;
    private String de054;
    private String de055;

    private String de063;
    private Long de071;
    private String de072;
    private Date de073;
    private String de093;
    private String de094;
    private String de095;
    private String de100;

    private Long disputeRn;

    private Long emv_5F2A;
    private String emv_71;
    private String emv_72;
    private String emv_82;
    private String emv_84;
    private String emv_8A;
    private String emv_91;
    private String emv_95;
    private Date emv_9A;
    private Long emv_9C;
    private Long emv_9F02;
    private Long emv_9F03;
    private String emv_9F09;
    private String emv_9F10;
    private Long emv_9F1A;
    private String emv_9F1E;
    private String emv_9F26;
    private String emv_9F27;
    private String emv_9F33;
    private String emv_9F34;
    private Long emv_9F35;
    private String emv_9F36;
    private String emv_9F37;
    private Long emv_9F41;
    private String emv_9F4C;
    private String emv_9F53;

    private String p0025_1;
    private Date p0025_2;
    private String p0137;
    private String p0146;
    private Long p0146_NET;
    private String p0148;
    private String p0149_1;
    private String p0149_2;
    private String p0165;
    private String p0190;
    private String p0198;
    private Boolean p0228;
    private String p0261;
    private Boolean p0262;
    private String p0265;
    private String p0266;
    private String p0267;
    private Long p0268_1;
    private String p0268_2;
    private String p0375;
    private String p2002;
    private String p2063;
    private String p2158_1;
    private Date p2158_2;
    private String p2158_3;
    private String p2158_4;
    private String p2158_5;
    private String p2158_6;
    private String p2159_1;
    private String p2159_2;
    private String p2159_3;
    private Date p2159_4;
    private String p2159_5;
    private Date p2159_6;
    private String p2175_1;
    private String p2175_2;
    private String p0176;
    private String p2072_1;
    private String p2072_2;
    private String p2097_1;
    private String p2097_2;

    private String merchantLocation;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getFileId() {
        return fileId;
    }

    public void setFileId(Long fileId) {
        this.fileId = fileId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Boolean getIncoming() {
        return incoming;
    }

    public void setIncoming(Boolean incoming) {
        this.incoming = incoming;
    }

    public Boolean getReversal() {
        return reversal;
    }

    public void setReversal(Boolean reversal) {
        this.reversal = reversal;
    }

    public Boolean getRejected() {
        return rejected;
    }

    public void setRejected(Boolean rejected) {
        this.rejected = rejected;
    }

    public Long getRejectId() {
        return rejectId;
    }

    public void setRejectId(Long rejectId) {
        this.rejectId = rejectId;
    }

    public Long getFpdId() {
        return fpdId;
    }

    public void setFpdId(Long fpdId) {
        this.fpdId = fpdId;
    }

    public Boolean getFpdMatched() {
        return fpdMatched;
    }

    public void setFpdMatched(Boolean fpdMatched) {
        this.fpdMatched = fpdMatched;
    }

    public Long getDisputeId() {
        return disputeId;
    }

    public void setDisputeId(Long disputeId) {
        this.disputeId = disputeId;
    }

    public Boolean getImpact() {
        return impact;
    }

    public void setImpact(Boolean impact) {
        this.impact = impact;
    }

    public Long getSessionId() {
        return sessionId;
    }

    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public Date getFileDate() {
        return fileDate;
    }

    public void setFileDate(Date fileDate) {
        this.fileDate = fileDate;
    }

    public Object getModelId() {
        return getId();
    }

    public Date getDateFrom() {
        return dateFrom;
    }

    public void setDateFrom(Date dateFrom) {
        this.dateFrom = dateFrom;
    }

    public Date getDateTo() {
        return dateTo;
    }

    public void setDateTo(Date dateTo) {
        this.dateTo = dateTo;
    }

    public String getLang() {
        return lang;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }

    public Long getInstId() {
        return instId;
    }

    public void setInstId(Long instId) {
        this.instId = instId;
    }

    public String getNetworkName() {
        return networkName;
    }

    public void setNetworkName(String networkName) {
        this.networkName = networkName;
    }

    public Long getNetworkId() {
        return networkId;
    }

    public void setNetworkId(Long networkId) {
        this.networkId = networkId;
    }

    public String getMti() {
        return mti;
    }

    public void setMti(String mti) {
        this.mti = mti;
    }

    public String getInstName() {
        return instName;
    }

    public void setInstName(String instName) {
        this.instName = instName;
    }

    public Long getSplitHash() {
        return splitHash;
    }

    public void setSplitHash(Long splitHash) {
        this.splitHash = splitHash;
    }


    public Long getSessionFileId() {
        return sessionFileId;
    }

    public void setSessionFileId(Long sessionFileId) {
        this.sessionFileId = sessionFileId;
    }

    public String getDe050() {
        return de050;
    }

    public void setDe050(String de050) {
        this.de050 = de050;
    }

    public String getMerchantLocation() {
        return merchantLocation;
    }

    public void setMerchantLocation(String merchantLocation) {
        this.merchantLocation = merchantLocation;
    }

    @Override
    public MirFinMessage clone() throws CloneNotSupportedException {
        return (MirFinMessage) super.clone();
    }

    public String getDe002() {
        return de002;
    }

    public void setDe002(String de002) {
        this.de002 = de002;
    }

    public String getDe003_1() {
        return de003_1;
    }

    public void setDe003_1(String de003_1) {
        this.de003_1 = de003_1;
    }

    public String getDe003_2() {
        return de003_2;
    }

    public void setDe003_2(String de003_2) {
        this.de003_2 = de003_2;
    }

    public String getDe003_3() {
        return de003_3;
    }

    public void setDe003_3(String de003_3) {
        this.de003_3 = de003_3;
    }

    public Long getDe004() {
        return de004;
    }

    public void setDe004(Long de004) {
        this.de004 = de004;
    }

    public Long getDe005() {
        return de005;
    }

    public void setDe005(Long de005) {
        this.de005 = de005;
    }

    public Long getDe006() {
        return de006;
    }

    public void setDe006(Long de006) {
        this.de006 = de006;
    }

    public String getDe009() {
        return de009;
    }

    public void setDe009(String de009) {
        this.de009 = de009;
    }

    public String getDe010() {
        return de010;
    }

    public void setDe010(String de010) {
        this.de010 = de010;
    }

    public Date getDe012() {
        return de012;
    }

    public void setDe012(Date de012) {
        this.de012 = de012;
    }

    public Date getDe014() {
        return de014;
    }

    public void setDe014(Date de014) {
        this.de014 = de014;
    }

    public String getDe022_1() {
        return de022_1;
    }

    public void setDe022_1(String de022_1) {
        this.de022_1 = de022_1;
    }

    public String getDe022_2() {
        return de022_2;
    }

    public void setDe022_2(String de022_2) {
        this.de022_2 = de022_2;
    }

    public String getDe022_3() {
        return de022_3;
    }

    public void setDe022_3(String de022_3) {
        this.de022_3 = de022_3;
    }

    public String getDe022_4() {
        return de022_4;
    }

    public void setDe022_4(String de022_4) {
        this.de022_4 = de022_4;
    }

    public String getDe022_5() {
        return de022_5;
    }

    public void setDe022_5(String de022_5) {
        this.de022_5 = de022_5;
    }

    public String getDe022_6() {
        return de022_6;
    }

    public void setDe022_6(String de022_6) {
        this.de022_6 = de022_6;
    }

    public String getDe022_7() {
        return de022_7;
    }

    public void setDe022_7(String de022_7) {
        this.de022_7 = de022_7;
    }

    public String getDe022_8() {
        return de022_8;
    }

    public void setDe022_8(String de022_8) {
        this.de022_8 = de022_8;
    }

    public String getDe022_9() {
        return de022_9;
    }

    public void setDe022_9(String de022_9) {
        this.de022_9 = de022_9;
    }

    public String getDe022_10() {
        return de022_10;
    }

    public void setDe022_10(String de022_10) {
        this.de022_10 = de022_10;
    }

    public String getDe022_11() {
        return de022_11;
    }

    public void setDe022_11(String de022_11) {
        this.de022_11 = de022_11;
    }

    public Long getDe023() {
        return de023;
    }

    public void setDe023(Long de023) {
        this.de023 = de023;
    }

    public String getDe024() {
        return de024;
    }

    public void setDe024(String de024) {
        this.de024 = de024;
    }

    public String getDe025() {
        return de025;
    }

    public void setDe025(String de025) {
        this.de025 = de025;
    }

    public String getDe026() {
        return de026;
    }

    public void setDe026(String de026) {
        this.de026 = de026;
    }

    public Long getDe030_1() {
        return de030_1;
    }

    public void setDe030_1(Long de030_1) {
        this.de030_1 = de030_1;
    }

    public Long getDe030_2() {
        return de030_2;
    }

    public void setDe030_2(Long de030_2) {
        this.de030_2 = de030_2;
    }

    public String getDe031() {
        return de031;
    }

    public void setDe031(String de031) {
        this.de031 = de031;
    }

    public String getDe032() {
        return de032;
    }

    public void setDe032(String de032) {
        this.de032 = de032;
    }

    public String getDe033() {
        return de033;
    }

    public void setDe033(String de033) {
        this.de033 = de033;
    }

    public String getDe037() {
        return de037;
    }

    public void setDe037(String de037) {
        this.de037 = de037;
    }

    public String getDe038() {
        return de038;
    }

    public void setDe038(String de038) {
        this.de038 = de038;
    }

    public String getDe040() {
        return de040;
    }

    public void setDe040(String de040) {
        this.de040 = de040;
    }

    public String getDe041() {
        return de041;
    }

    public void setDe041(String de041) {
        this.de041 = de041;
    }

    public String getDe042() {
        return de042;
    }

    public void setDe042(String de042) {
        this.de042 = de042;
    }

    public String getDe043_1() {
        return de043_1;
    }

    public void setDe043_1(String de043_1) {
        this.de043_1 = de043_1;
    }

    public String getDe043_2() {
        return de043_2;
    }

    public void setDe043_2(String de043_2) {
        this.de043_2 = de043_2;
    }

    public String getDe043_3() {
        return de043_3;
    }

    public void setDe043_3(String de043_3) {
        this.de043_3 = de043_3;
    }

    public String getDe043_4() {
        return de043_4;
    }

    public void setDe043_4(String de043_4) {
        this.de043_4 = de043_4;
    }

    public String getDe043_5() {
        return de043_5;
    }

    public void setDe043_5(String de043_5) {
        this.de043_5 = de043_5;
    }

    public String getDe043_6() {
        return de043_6;
    }

    public void setDe043_6(String de043_6) {
        this.de043_6 = de043_6;
    }

    public String getDe049() {
        return de049;
    }

    public void setDe049(String de049) {
        this.de049 = de049;
    }

    public String getDe051() {
        return de051;
    }

    public void setDe051(String de051) {
        this.de051 = de051;
    }

    public String getDe054() {
        return de054;
    }

    public void setDe054(String de054) {
        this.de054 = de054;
    }

    public String getDe055() {
        return de055;
    }

    public void setDe055(String de055) {
        this.de055 = de055;
    }

    public String getDe063() {
        return de063;
    }

    public void setDe063(String de063) {
        this.de063 = de063;
    }

    public Long getDe071() {
        return de071;
    }

    public void setDe071(Long de071) {
        this.de071 = de071;
    }

    public String getDe072() {
        return de072;
    }

    public void setDe072(String de072) {
        this.de072 = de072;
    }

    public Date getDe073() {
        return de073;
    }

    public void setDe073(Date de073) {
        this.de073 = de073;
    }

    public String getDe093() {
        return de093;
    }

    public void setDe093(String de093) {
        this.de093 = de093;
    }

    public String getDe094() {
        return de094;
    }

    public void setDe094(String de094) {
        this.de094 = de094;
    }

    public String getDe095() {
        return de095;
    }

    public void setDe095(String de095) {
        this.de095 = de095;
    }

    public String getDe100() {
        return de100;
    }

    public void setDe100(String de100) {
        this.de100 = de100;
    }

    public Long getDisputeRn() {
        return disputeRn;
    }

    public void setDisputeRn(Long disputeRn) {
        this.disputeRn = disputeRn;
    }

    public Long getEmv_5F2A() {
        return emv_5F2A;
    }

    public void setEmv_5F2A(Long emv_5F2A) {
        this.emv_5F2A = emv_5F2A;
    }

    public String getEmv_71() {
        return emv_71;
    }

    public void setEmv_71(String emv_71) {
        this.emv_71 = emv_71;
    }

    public String getEmv_72() {
        return emv_72;
    }

    public void setEmv_72(String emv_72) {
        this.emv_72 = emv_72;
    }

    public String getEmv_82() {
        return emv_82;
    }

    public void setEmv_82(String emv_82) {
        this.emv_82 = emv_82;
    }

    public String getEmv_84() {
        return emv_84;
    }

    public void setEmv_84(String emv_84) {
        this.emv_84 = emv_84;
    }

    public String getEmv_8A() {
        return emv_8A;
    }

    public void setEmv_8A(String emv_8A) {
        this.emv_8A = emv_8A;
    }

    public String getEmv_91() {
        return emv_91;
    }

    public void setEmv_91(String emv_91) {
        this.emv_91 = emv_91;
    }

    public String getEmv_95() {
        return emv_95;
    }

    public void setEmv_95(String emv_95) {
        this.emv_95 = emv_95;
    }

    public Date getEmv_9A() {
        return emv_9A;
    }

    public void setEmv_9A(Date emv_9A) {
        this.emv_9A = emv_9A;
    }

    public Long getEmv_9C() {
        return emv_9C;
    }

    public void setEmv_9C(Long emv_9C) {
        this.emv_9C = emv_9C;
    }

    public Long getEmv_9F02() {
        return emv_9F02;
    }

    public void setEmv_9F02(Long emv_9F02) {
        this.emv_9F02 = emv_9F02;
    }

    public Long getEmv_9F03() {
        return emv_9F03;
    }

    public void setEmv_9F03(Long emv_9F03) {
        this.emv_9F03 = emv_9F03;
    }

    public String getEmv_9F09() {
        return emv_9F09;
    }

    public void setEmv_9F09(String emv_9F09) {
        this.emv_9F09 = emv_9F09;
    }

    public String getEmv_9F10() {
        return emv_9F10;
    }

    public void setEmv_9F10(String emv_9F10) {
        this.emv_9F10 = emv_9F10;
    }

    public Long getEmv_9F1A() {
        return emv_9F1A;
    }

    public void setEmv_9F1A(Long emv_9F1A) {
        this.emv_9F1A = emv_9F1A;
    }

    public String getEmv_9F1E() {
        return emv_9F1E;
    }

    public void setEmv_9F1E(String emv_9F1E) {
        this.emv_9F1E = emv_9F1E;
    }

    public String getEmv_9F26() {
        return emv_9F26;
    }

    public void setEmv_9F26(String emv_9F26) {
        this.emv_9F26 = emv_9F26;
    }

    public String getEmv_9F27() {
        return emv_9F27;
    }

    public void setEmv_9F27(String emv_9F27) {
        this.emv_9F27 = emv_9F27;
    }

    public String getEmv_9F33() {
        return emv_9F33;
    }

    public void setEmv_9F33(String emv_9F33) {
        this.emv_9F33 = emv_9F33;
    }

    public String getEmv_9F34() {
        return emv_9F34;
    }

    public void setEmv_9F34(String emv_9F34) {
        this.emv_9F34 = emv_9F34;
    }

    public Long getEmv_9F35() {
        return emv_9F35;
    }

    public void setEmv_9F35(Long emv_9F35) {
        this.emv_9F35 = emv_9F35;
    }

    public String getEmv_9F36() {
        return emv_9F36;
    }

    public void setEmv_9F36(String emv_9F36) {
        this.emv_9F36 = emv_9F36;
    }

    public String getEmv_9F37() {
        return emv_9F37;
    }

    public void setEmv_9F37(String emv_9F37) {
        this.emv_9F37 = emv_9F37;
    }

    public Long getEmv_9F41() {
        return emv_9F41;
    }

    public void setEmv_9F41(Long emv_9F41) {
        this.emv_9F41 = emv_9F41;
    }

    public String getEmv_9F4C() {
        return emv_9F4C;
    }

    public void setEmv_9F4C(String emv_9F4C) {
        this.emv_9F4C = emv_9F4C;
    }

    public String getEmv_9F53() {
        return emv_9F53;
    }

    public void setEmv_9F53(String emv_9F53) {
        this.emv_9F53 = emv_9F53;
    }

    public String getP0025_1() {
        return p0025_1;
    }

    public void setP0025_1(String p0025_1) {
        this.p0025_1 = p0025_1;
    }

    public Date getP0025_2() {
        return p0025_2;
    }

    public void setP0025_2(Date p0025_2) {
        this.p0025_2 = p0025_2;
    }

    public String getP0137() {
        return p0137;
    }

    public void setP0137(String p0137) {
        this.p0137 = p0137;
    }

    public String getP0146() {
        return p0146;
    }

    public void setP0146(String p0146) {
        this.p0146 = p0146;
    }

    public Long getP0146_NET() {
        return p0146_NET;
    }

    public void setP0146_NET(Long p0146_NET) {
        this.p0146_NET = p0146_NET;
    }

    public String getP0148() {
        return p0148;
    }

    public void setP0148(String p0148) {
        this.p0148 = p0148;
    }

    public String getP0149_1() {
        return p0149_1;
    }

    public void setP0149_1(String p0149_1) {
        this.p0149_1 = p0149_1;
    }

    public String getP0149_2() {
        return p0149_2;
    }

    public void setP0149_2(String p0149_2) {
        this.p0149_2 = p0149_2;
    }

    public String getP0165() {
        return p0165;
    }

    public void setP0165(String p0165) {
        this.p0165 = p0165;
    }

    public String getP0190() {
        return p0190;
    }

    public void setP0190(String p0190) {
        this.p0190 = p0190;
    }

    public String getP0198() {
        return p0198;
    }

    public void setP0198(String p0198) {
        this.p0198 = p0198;
    }

    public Boolean getP0228() {
        return p0228;
    }

    public void setP0228(Boolean p0228) {
        this.p0228 = p0228;
    }

    public String getP0261() {
        return p0261;
    }

    public void setP0261(String p0261) {
        this.p0261 = p0261;
    }

    public Boolean getP0262() {
        return p0262;
    }

    public void setP0262(Boolean p0262) {
        this.p0262 = p0262;
    }

    public String getP0265() {
        return p0265;
    }

    public void setP0265(String p0265) {
        this.p0265 = p0265;
    }

    public String getP0266() {
        return p0266;
    }

    public void setP0266(String p0266) {
        this.p0266 = p0266;
    }

    public String getP0267() {
        return p0267;
    }

    public void setP0267(String p0267) {
        this.p0267 = p0267;
    }

    public Long getP0268_1() {
        return p0268_1;
    }

    public void setP0268_1(Long p0268_1) {
        this.p0268_1 = p0268_1;
    }

    public String getP0268_2() {
        return p0268_2;
    }

    public void setP0268_2(String p0268_2) {
        this.p0268_2 = p0268_2;
    }

    public String getP0375() {
        return p0375;
    }

    public void setP0375(String p0375) {
        this.p0375 = p0375;
    }

    public String getP2002() {
        return p2002;
    }

    public void setP2002(String p2002) {
        this.p2002 = p2002;
    }

    public String getP2063() {
        return p2063;
    }

    public void setP2063(String p2063) {
        this.p2063 = p2063;
    }

    public String getP2158_1() {
        return p2158_1;
    }

    public void setP2158_1(String p2158_1) {
        this.p2158_1 = p2158_1;
    }

    public Date getP2158_2() {
        return p2158_2;
    }

    public void setP2158_2(Date p2158_2) {
        this.p2158_2 = p2158_2;
    }

    public String getP2158_3() {
        return p2158_3;
    }

    public void setP2158_3(String p2158_3) {
        this.p2158_3 = p2158_3;
    }

    public String getP2158_4() {
        return p2158_4;
    }

    public void setP2158_4(String p2158_4) {
        this.p2158_4 = p2158_4;
    }

    public String getP2158_5() {
        return p2158_5;
    }

    public void setP2158_5(String p2158_5) {
        this.p2158_5 = p2158_5;
    }

    public String getP2158_6() {
        return p2158_6;
    }

    public void setP2158_6(String p2158_6) {
        this.p2158_6 = p2158_6;
    }

    public String getP2159_1() {
        return p2159_1;
    }

    public void setP2159_1(String p2159_1) {
        this.p2159_1 = p2159_1;
    }

    public String getP2159_2() {
        return p2159_2;
    }

    public void setP2159_2(String p2159_2) {
        this.p2159_2 = p2159_2;
    }

    public String getP2159_3() {
        return p2159_3;
    }

    public void setP2159_3(String p2159_3) {
        this.p2159_3 = p2159_3;
    }

    public Date getP2159_4() {
        return p2159_4;
    }

    public void setP2159_4(Date p2159_4) {
        this.p2159_4 = p2159_4;
    }

    public String getP2159_5() {
        return p2159_5;
    }

    public void setP2159_5(String p2159_5) {
        this.p2159_5 = p2159_5;
    }

    public Date getP2159_6() {
        return p2159_6;
    }

    public void setP2159_6(Date p2159_6) {
        this.p2159_6 = p2159_6;
    }

    public String getP0176() {
        return p0176;
    }

    public void setP0176(String p0176) {
        this.p0176 = p0176;
    }

    public String getP2072_1() {
        return p2072_1;
    }

    public void setP2072_1(String p2072_1) {
        this.p2072_1 = p2072_1;
    }

    public String getP2072_2() {
        return p2072_2;
    }

    public void setP2072_2(String p2072_2) {
        this.p2072_2 = p2072_2;
    }

    public String getP2175_1() {
        return p2175_1;
    }

    public void setP2175_1(String p2175_1) {
        this.p2175_1 = p2175_1;
    }

    public String getP2175_2() {
        return p2175_2;
    }

    public void setP2175_2(String p2175_2) {
        this.p2175_2 = p2175_2;
    }

    public String getP2097_1() {
        return p2097_1;
    }

    public void setP2097_1(String p2097_1) {
        this.p2097_1 = p2097_1;
    }

    public String getP2097_2() {
        return p2097_2;
    }

    public void setP2097_2(String p2097_2) {
        this.p2097_2 = p2097_2;
    }

    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        return result;
    }
}

