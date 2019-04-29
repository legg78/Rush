package ru.bpc.sv2.ps.mir;


import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

public class MirFinMessageAddendum implements Serializable, ModelIdentifiable, Cloneable{

    private Long id;
    private Long finId;
    private Long fileId;
    private Boolean incoming;
    private String mti;
    private String de024;
    private Long de071;
    private String de032;
    private String de033;
    private String de063;
    private String de093;
    private String de094;
    private String de100;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getFinId() {
        return finId;
    }

    public void setFinId(Long finId) {
        this.finId = finId;
    }

    public Long getFileId() {
        return fileId;
    }

    public void setFileId(Long fileId) {
        this.fileId = fileId;
    }

    public Boolean getIncoming() {
        return incoming;
    }

    public void setIncoming(Boolean incoming) {
        this.incoming = incoming;
    }

    public String getMti() {
        return mti;
    }

    public void setMti(String mti) {
        this.mti = mti;
    }

    public String getDe024() {
        return de024;
    }

    public void setDe024(String de024) {
        this.de024 = de024;
    }

    public Long getDe071() {
        return de071;
    }

    public void setDe071(Long de071) {
        this.de071 = de071;
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

    public String getDe063() {
        return de063;
    }

    public void setDe063(String de063) {
        this.de063 = de063;
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

    public String getDe100() {
        return de100;
    }

    public void setDe100(String de100) {
        this.de100 = de100;
    }

    public Object getModelId() {
        return getId();
    }
}
