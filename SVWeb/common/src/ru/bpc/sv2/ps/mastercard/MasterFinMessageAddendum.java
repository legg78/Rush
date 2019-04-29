package ru.bpc.sv2.ps.mastercard;


import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class MasterFinMessageAddendum implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = 1L;

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
    private String p0501_1;
    private String p0501_2;
    private Long p0501_3;
    private Long p0501_4;

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

    public String getP0501_1() {
        return p0501_1;
    }

    public void setP0501_1(String p0501_1) {
        this.p0501_1 = p0501_1;
    }

    public String getP0501_2() {
        return p0501_2;
    }

    public void setP0501_2(String p0501_2) {
        this.p0501_2 = p0501_2;
    }

    public Long getP0501_3() {
        return p0501_3;
    }

    public void setP0501_3(Long p0501_3) {
        this.p0501_3 = p0501_3;
    }

    public Long getP0501_4() {
        return p0501_4;
    }

    public void setP0501_4(Long p0501_4) {
        this.p0501_4 = p0501_4;
    }

    @Override
    public Object getModelId() {
        return getId();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("finId", getFinId());
        result.put("fileId", getFileId());
        return result;
    }
}
