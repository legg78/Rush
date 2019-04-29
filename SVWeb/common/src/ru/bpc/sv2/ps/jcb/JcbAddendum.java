package ru.bpc.sv2.ps.jcb;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class JcbAddendum implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;
    private Long id;
    private Long finId;
    private Long fileId;
    private Boolean isIncoming;
    private String mti;
    private String de024;
    private String de032;
    private String de033;
    private Long de071;
    private String de093;
    private String de094;
    private String de100;
    private String p3600;
    private Long p36001;
    private String p36002;
    private String p36003;
    private String p3601;
    private String p3602;
    private String p3604;

    public Long getId(){
        return id;
    }
    public void setId( Long id ){
        this.id = id;
    }

    public Long getFinId(){
        return finId;
    }
    public void setFinId( Long finId ){
        this.finId = finId;
    }

    public Long getFileId(){
        return fileId;
    }
    public void setFileId( Long fileId ){
        this.fileId = fileId;
    }

    public Boolean getIsIncoming(){
        return isIncoming;
    }
    public void setIsIncoming( Boolean isIncoming ){
        this.isIncoming = isIncoming;
    }

    public String getMti(){
        return mti;
    }
    public void setMti( String mti ){
        this.mti = mti;
    }

    public String getDe024(){
        return de024;
    }
    public void setDe024( String de024 ){
        this.de024 = de024;
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

    public Long getDe071(){
        return de071;
    }
    public void setDe071( Long de071 ){
        this.de071 = de071;
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

    public String getP3600(){
        return p3600;
    }
    public void setP3600( String p3600 ){
        this.p3600 = p3600;
    }

    public Long getP36001(){
        return p36001;
    }
    public void setP36001( Long p36001 ){
        this.p36001 = p36001;
    }

    public String getP36002(){
        return p36002;
    }
    public void setP36002( String p36002 ){
        this.p36002 = p36002;
    }

    public String getP36003(){
        return p36003;
    }
    public void setP36003( String p36003 ){
        this.p36003 = p36003;
    }

    public String getP3601(){
        return p3601;
    }
    public void setP3601( String p3601 ){
        this.p3601 = p3601;
    }

    public String getP3602(){
        return p3602;
    }
    public void setP3602( String p3602 ){
        this.p3602 = p3602;
    }

    public String getP3604(){
        return p3604;
    }
    public void setP3604( String p3604 ){
        this.p3604 = p3604;
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
    @Override
    public Object getModelId() {
        return getId();
    }
}
