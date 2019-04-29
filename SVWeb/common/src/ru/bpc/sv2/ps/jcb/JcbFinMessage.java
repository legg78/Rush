package ru.bpc.sv2.ps.jcb;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.Date;

public class JcbFinMessage implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;
    private Long id;
    private Integer splitHash;
    private String status;
    private String statusDesc;
    private Integer instId;
    private String instName;
    private Integer networkId;
    private String networkName;
    private Long fileId;
    private String fileName;
    private Boolean isIncoming;
    private Boolean isReversal;
    private Boolean isRejected;
    private Long rejectId;
    private Long disputeId;
    private Long disputeRn;
    private Integer impact;
    private Integer mti;
    private String de002;
    private String de0031;
    private String de0032;
    private String de0033;
    private String de002Mask;
    private Long de004;
    private Long de005;
    private Long de006;
    private String de009;
    private String de010;
    private Date de012;
    private Date de014;
    private Date de016;
    private String de0221;
    private String de0222;
    private String de0223;
    private String de0224;
    private String de0225;
    private String de0226;
    private String de0227;
    private String de0228;
    private String de0229;
    private String de02210;
    private String de02211;
    private String de02212;
    private Integer de023;
    private String de024;
    private String de025;
    private String de026;
    private Long de0301;
    private Long de0302;
    private String de031;
    private String de032;
    private String de033;
    private String de037;
    private String de038;
    private String de040;
    private String de041;
    private String de042;
    private String de0431;
    private String de0432;
    private String de0433;
    private String de0434;
    private String de0435;
    private String de0436;
    private String de049;
    private String de050;
    private String de051;
    private String de054;
    private String de055;
    private Long de071;
    private String de072;
    private String de093;
    private String de094;
    private String de100;
    private String p3001;
    private String p3002;
    private String p3003;
    private String p3005;
    private String p30071;
    private Date p30072;
    private String p3008;
    private Integer p3009;
    private String p3011;
    private String p3012;
    private String p3013;
    private String p3014;
    private String p3201;
    private String p3202;
    private String p3203;
    private String p3205;
    private String p3206;
    private String p3207;
    private String p3208;
    private Integer p3209;
    private String p3210;
    private String p3211;
    private Integer p3250;
    private String p3251;
    private String p3302;
    private String emv9f26;
    private Long emv9f02;
    private String emv9f27;
    private String emv9f10;
    private String emv9f36;
    private String emv95;
    private String emv82;
    private Date emv9a;
    private Integer emv9c;
    private String emv9f37;
    private Integer emv5f2a;
    private String emv9f33;
    private String emv9f34;
    private Integer emv9f1a;
    private Integer emv9f35;
    private String emv84;
    private String emv9f09;
    private Long emv9f03;
    private String emv9f1e;
    private Long emv9f41;
    private String emv4f;
    private String lang;

    public Long getId(){
        return id;
    }
    public void setId( Long id ){
        this.id = id;
    }

    public Integer getSplitHash(){
        return splitHash;
    }
    public void setSplitHash( Integer splitHash ){
        this.splitHash = splitHash;
    }

    public String getStatus(){
        return status;
    }
    public void setStatus( String status ){
        this.status = status;
    }

    public String getStatusDesc(){
        return statusDesc;
    }
    public void setStatusDesc( String statusDesc ){
        this.statusDesc = statusDesc;
    }

    public Integer getInstId(){
        return instId;
    }
    public void setInstId( Integer instId ){
        this.instId = instId;
    }

    public String getInstName(){
        return instName;
    }
    public void setInstName( String instName ){
        this.instName = instName;
    }

    public Integer getNetworkId(){
        return networkId;
    }
    public void setNetworkId( Integer networkId ){
        this.networkId = networkId;
    }

    public String getNetworkName(){
        return networkName;
    }
    public void setNetworkName( String networkName ){
        this.networkName = networkName;
    }

    public Long getFileId(){
        return fileId;
    }
    public void setFileId( Long fileId ){
        this.fileId = fileId;
    }

    public String getFileName(){
        return fileName;
    }
    public void setFileName( String fileName ){
        this.fileName = fileName;
    }

    public Boolean getIsIncoming(){
        return isIncoming;
    }
    public void setIsIncoming( Boolean isIncoming ){
        this.isIncoming = isIncoming;
    }

    public Boolean getIsReversal(){
        return isReversal;
    }
    public void setIsReversal( Boolean isReversal ){
        this.isReversal = isReversal;
    }

    public Boolean getIsRejected(){
        return isRejected;
    }
    public void setIsRejected( Boolean isRejected ){
        this.isRejected = isRejected;
    }

    public Long getRejectId(){
        return rejectId;
    }
    public void setRejectId( Long rejectId ){
        this.rejectId = rejectId;
    }

    public Long getDisputeId(){
        return disputeId;
    }
    public void setDisputeId( Long disputeId ){
        this.disputeId = disputeId;
    }

    public Long getDisputeRn(){
        return disputeRn;
    }
    public void setDisputeRn( Long disputeRn ){
        this.disputeRn = disputeRn;
    }

    public Integer getImpact(){
        return impact;
    }
    public void setImpact( Integer impact ){
        this.impact = impact;
    }

    public Integer getMti(){
        return mti;
    }
    public void setMti( Integer mti ){
        this.mti = mti;
    }

    public String getDe002(){
        return de002;
    }
    public void setDe002( String de002 ){
        this.de002 = de002;
    }

    public String getDe0031(){
        return de0031;
    }
    public void setDe0031( String de0031 ){
        this.de0031 = de0031;
    }

    public String getDe0032(){
        return de0032;
    }
    public void setDe0032( String de0032 ){
        this.de0032 = de0032;
    }

    public String getDe0033(){
        return de0033;
    }
    public void setDe0033( String de0033 ){
        this.de0033 = de0033;
    }

    public String getDe002Mask(){
        return de002Mask;
    }
    public void setDe002Mask( String de002Mask ){
        this.de002Mask = de002Mask;
    }

    public Long getDe004(){
        return de004;
    }
    public void setDe004( Long de004 ){
        this.de004 = de004;
    }

    public Long getDe005(){
        return de005;
    }
    public void setDe005( Long de005 ){
        this.de005 = de005;
    }

    public Long getDe006(){
        return de006;
    }
    public void setDe006( Long de006 ){
        this.de006 = de006;
    }

    public String getDe009(){
        return de009;
    }
    public void setDe009( String de009 ){
        this.de009 = de009;
    }

    public String getDe010(){
        return de010;
    }
    public void setDe010( String de010 ){
        this.de010 = de010;
    }

    public Date getDe012(){
        return de012;
    }
    public void setDe012( Date de012 ){
        this.de012 = de012;
    }

    public Date getDe014(){
        return de014;
    }
    public void setDe014( Date de014 ){
        this.de014 = de014;
    }

    public Date getDe016(){
        return de016;
    }
    public void setDe016( Date de016 ){
        this.de016 = de016;
    }

    public String getDe0221(){
        return de0221;
    }
    public void setDe0221( String de0221 ){
        this.de0221 = de0221;
    }

    public String getDe0222(){
        return de0222;
    }
    public void setDe0222( String de0222 ){
        this.de0222 = de0222;
    }

    public String getDe0223(){
        return de0223;
    }
    public void setDe0223( String de0223 ){
        this.de0223 = de0223;
    }

    public String getDe0224(){
        return de0224;
    }
    public void setDe0224( String de0224 ){
        this.de0224 = de0224;
    }
    public String getDe0225(){
        return de0225;
    }
    public void setDe0225( String de0225 ){
        this.de0225 = de0225;
    }

    public String getDe0226(){
        return de0226;
    }
    public void setDe0226( String de0226 ){
        this.de0226 = de0226;
    }

    public String getDe0227(){
        return de0227;
    }
    public void setDe0227( String de0227 ){
        this.de0227 = de0227;
    }

    public String getDe0228(){
        return de0228;
    }
    public void setDe0228( String de0228 ){
        this.de0228 = de0228;
    }

    public String getDe0229(){
        return de0229;
    }
    public void setDe0229( String de0229 ){
        this.de0229 = de0229;
    }

    public String getDe02210(){
        return de02210;
    }
    public void setDe02210( String de02210 ){
        this.de02210 = de02210;
    }

    public String getDe02211(){
        return de02211;
    }
    public void setDe02211( String de02211 ){
        this.de02211 = de02211;
    }

    public String getDe02212(){
        return de02212;
    }
    public void setDe02212( String de02212 ){
        this.de02212 = de02212;
    }

    public Integer getDe023(){
        return de023;
    }
    public void setDe023( Integer de023 ){
        this.de023 = de023;
    }

    public String getDe024(){
        return de024;
    }
    public void setDe024( String de024 ){
        this.de024 = de024;
    }

    public String getDe025(){
        return de025;
    }
    public void setDe025( String de025 ){
        this.de025 = de025;
    }

    public String getDe026(){
        return de026;
    }
    public void setDe026( String de026 ){
        this.de026 = de026;
    }

    public Long getDe0301(){
        return de0301;
    }
    public void setDe0301( Long de0301 ){
        this.de0301 = de0301;
    }

    public Long getDe0302(){
        return de0302;
    }
    public void setDe0302( Long de0302 ){
        this.de0302 = de0302;
    }

    public String getDe031(){
        return de031;
    }
    public void setDe031( String de031 ){
        this.de031 = de031;
    }

    public String getDe032(){
        return de032;
    }
    public void setDe032( String de032 ){
        this.de032 = de032;
    }

    public String getDe033(){
        return de033;
    }
    public void setDe033( String de033 ){
        this.de033 = de033;
    }

    public String getDe037(){
        return de037;
    }
    public void setDe037( String de037 ){
        this.de037 = de037;
    }

    public String getDe038(){
        return de038;
    }
    public void setDe038( String de038 ){
        this.de038 = de038;
    }

    public String getDe040(){
        return de040;
    }
    public void setDe040( String de040 ){
        this.de040 = de040;
    }

    public String getDe041(){
        return de041;
    }
    public void setDe041( String de041 ){
        this.de041 = de041;
    }

    public String getDe042(){
        return de042;
    }
    public void setDe042( String de042 ){
        this.de042 = de042;
    }

    public String getDe0431(){
        return de0431;
    }
    public void setDe0431( String de0431 ){
        this.de0431 = de0431;
    }

    public String getDe0432(){
        return de0432;
    }
    public void setDe0432( String de0432 ){
        this.de0432 = de0432;
    }

    public String getDe0433(){
        return de0433;
    }
    public void setDe0433( String de0433 ){
        this.de0433 = de0433;
    }

    public String getDe0434(){
        return de0434;
    }
    public void setDe0434( String de0434 ){
        this.de0434 = de0434;
    }

    public String getDe0435(){
        return de0435;
    }
    public void setDe0435( String de0435 ){
        this.de0435 = de0435;
    }

    public String getDe0436(){
        return de0436;
    }
    public void setDe0436( String de0436 ){
        this.de0436 = de0436;
    }

    public String getDe049(){
        return de049;
    }
    public void setDe049( String de049 ){
        this.de049 = de049;
    }

    public String getDe050(){
        return de050;
    }
    public void setDe050( String de050 ){
        this.de050 = de050;
    }

    public String getDe051(){
        return de051;
    }
    public void setDe051( String de051 ){
        this.de051 = de051;
    }

    public String getDe054(){
        return de054;
    }
    public void setDe054( String de054 ){
        this.de054 = de054;
    }

    public String getDe055(){
        return de055;
    }
    public void setDe055( String de055 ){
        this.de055 = de055;
    }

    public Long getDe071(){
        return de071;
    }
    public void setDe071( Long de071 ){
        this.de071 = de071;
    }

    public String getDe072(){
        return de072;
    }
    public void setDe072( String de072 ){
        this.de072 = de072;
    }

    public String getDe093(){
        return de093;
    }
    public void setDe093( String de093 ){
        this.de093 = de093;
    }

    public String getDe094(){
        return de094;
    }
    public void setDe094( String de094 ){
        this.de094 = de094;
    }

    public String getDe100(){
        return de100;
    }
    public void setDe100( String de100 ){
        this.de100 = de100;
    }

    public String getP3001(){
        return p3001;
    }
    public void setP3001( String p3001 ){
        this.p3001 = p3001;
    }

    public String getP3002(){
        return p3002;
    }
    public void setP3002( String p3002 ){
        this.p3002 = p3002;
    }

    public String getP3003(){
        return p3003;
    }
    public void setP3003( String p3003 ){
        this.p3003 = p3003;
    }

    public String getP3005(){
        return p3005;
    }
    public void setP3005( String p3005 ){
        this.p3005 = p3005;
    }

    public String getP30071(){
        return p30071;
    }
    public void setP30071( String p30071 ){
        this.p30071 = p30071;
    }

    public Date getP30072(){
        return p30072;
    }
    public void setP30072( Date p30072 ){
        this.p30072 = p30072;
    }

    public String getP3008(){
        return p3008;
    }
    public void setP3008( String p3008 ){
        this.p3008 = p3008;
    }

    public Integer getP3009(){
        return p3009;
    }
    public void setP3009( Integer p3009 ){
        this.p3009 = p3009;
    }

    public String getP3011(){
        return p3011;
    }
    public void setP3011( String p3011 ){
        this.p3011 = p3011;
    }

    public String getP3012(){
        return p3012;
    }
    public void setP3012( String p3012 ){
        this.p3012 = p3012;
    }

    public String getP3013(){
        return p3013;
    }
    public void setP3013( String p3013 ){
        this.p3013 = p3013;
    }

    public String getP3014(){
        return p3014;
    }
    public void setP3014( String p3014 ){
        this.p3014 = p3014;
    }

    public String getP3201(){
        return p3201;
    }
    public void setP3201( String p3201 ){
        this.p3201 = p3201;
    }

    public String getP3202(){
        return p3202;
    }
    public void setP3202( String p3202 ){
        this.p3202 = p3202;
    }

    public String getP3203(){
        return p3203;
    }
    public void setP3203( String p3203 ){
        this.p3203 = p3203;
    }

    public String getP3205(){
        return p3205;
    }
    public void setP3205( String p3205 ){
        this.p3205 = p3205;
    }

    public String getP3206(){
        return p3206;
    }
    public void setP3206( String p3206 ){
        this.p3206 = p3206;
    }

    public String getP3207(){
        return p3207;
    }
    public void setP3207( String p3207 ){
        this.p3207 = p3207;
    }

    public String getP3208(){
        return p3208;
    }
    public void setP3208( String p3208 ){
        this.p3208 = p3208;
    }

    public Integer getP3209(){
        return p3209;
    }
    public void setP3209( Integer p3209 ){
        this.p3209 = p3209;
    }

    public String getP3210(){
        return p3210;
    }
    public void setP3210( String p3210 ){
        this.p3210 = p3210;
    }

    public String getP3211(){
        return p3211;
    }
    public void setP3211( String p3211 ){
        this.p3211 = p3211;
    }

    public Integer getP3250(){
        return p3250;
    }
    public void setP3250( Integer p3250 ){
        this.p3250 = p3250;
    }

    public String getP3251(){
        return p3251;
    }
    public void setP3251( String p3251 ){
        this.p3251 = p3251;
    }

    public String getP3302(){
        return p3302;
    }
    public void setP3302( String p3302 ){
        this.p3302 = p3302;
    }

    public String getEmv9f26(){
        return emv9f26;
    }
    public void setEmv9f26( String emv9f26 ){
        this.emv9f26 = emv9f26;
    }

    public Long getEmv9f02(){
        return emv9f02;
    }
    public void setEmv9f02( Long emv9f02 ){
        this.emv9f02 = emv9f02;
    }

    public String getEmv9f27(){
        return emv9f27;
    }
    public void setEmv9f27( String emv9f27 ){
        this.emv9f27 = emv9f27;
    }

    public String getEmv9f10(){
        return emv9f10;
    }
    public void setEmv9f10( String emv9f10 ){
        this.emv9f10 = emv9f10;
    }

    public String getEmv9f36(){
        return emv9f36;
    }
    public void setEmv9f36( String emv9f36 ){
        this.emv9f36 = emv9f36;
    }

    public String getEmv95(){
        return emv95;
    }
    public void setEmv95( String emv95 ){
        this.emv95 = emv95;
    }

    public String getEmv82(){
        return emv82;
    }
    public void setEmv82( String emv82 ){
        this.emv82 = emv82;
    }

    public Date getEmv9a(){
        return emv9a;
    }
    public void setEmv9a( Date emv9a ){
        this.emv9a = emv9a;
    }

    public Integer getEmv9c(){
        return emv9c;
    }
    public void setEmv9c( Integer emv9c ){
        this.emv9c = emv9c;
    }

    public String getEmv9f37(){
        return emv9f37;
    }
    public void setEmv9f37( String emv9f37 ){
        this.emv9f37 = emv9f37;
    }

    public Integer getEmv5f2a(){
        return emv5f2a;
    }
    public void setEmv5f2a( Integer emv5f2a ){
        this.emv5f2a = emv5f2a;
    }

    public String getEmv9f33(){
        return emv9f33;
    }
    public void setEmv9f33( String emv9f33 ){
        this.emv9f33 = emv9f33;
    }

    public String getEmv9f34(){
        return emv9f34;
    }
    public void setEmv9f34( String emv9f34 ){
        this.emv9f34 = emv9f34;
    }

    public Integer getEmv9f1a(){
        return emv9f1a;
    }
    public void setEmv9f1a( Integer emv9f1a ){
        this.emv9f1a = emv9f1a;
    }

    public Integer getEmv9f35(){
        return emv9f35;
    }
    public void setEmv9f35( Integer emv9f35 ){
        this.emv9f35 = emv9f35;
    }

    public String getEmv84(){
        return emv84;
    }
    public void setEmv84( String emv84 ){
        this.emv84 = emv84;
    }

    public String getEmv9f09(){
        return emv9f09;
    }
    public void setEmv9f09( String emv9f09 ){
        this.emv9f09 = emv9f09;
    }

    public Long getEmv9f03(){
        return emv9f03;
    }
    public void setEmv9f03( Long emv9f03 ){
        this.emv9f03 = emv9f03;
    }

    public String getEmv9f1e(){
        return emv9f1e;
    }
    public void setEmv9f1e( String emv9f1e ){
        this.emv9f1e = emv9f1e;
    }

    public Long getEmv9f41(){
        return emv9f41;
    }
    public void setEmv9f41( Long emv9f41 ){
        this.emv9f41 = emv9f41;
    }

    public String getEmv4f(){
        return emv4f;
    }
    public void setEmv4f( String emv4f ){
        this.emv4f = emv4f;
    }

    public String getLang(){
        return lang;
    }
    public void setLang( String lang ){
        this.lang = lang;
    }

    @Override
    public Object getModelId() {
        return getId();
    }
    @Override
    public Object clone(){
        Object result = null;
        try {
            result = super.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
        }
        return result;
    }
}
