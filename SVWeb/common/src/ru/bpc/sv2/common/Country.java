package ru.bpc.sv2.common;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Country implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String code;
	private String name;
	private String currCode;
	private String visaCountryCode;
	private String mastercardRegion;
	private String mastercardEurozone;
	private String countryName;
	private String lang;

	private Integer ferrNo;
    private Integer visaRegion;
	
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCurrCode() {
		return currCode;
	}

	public void setCurrCode(String currCode) {
		this.currCode = currCode;
	}

	public String getVisaCountryCode() {
		return visaCountryCode;
	}

	public void setVisaCountryCode(String visaCountryCode) {
		this.visaCountryCode = visaCountryCode;
	}

	public String getMastercardRegion() {
		return mastercardRegion;
	}

	public void setMastercardRegion(String mastercardRegion) {
		this.mastercardRegion = mastercardRegion;
	}

	public String getMastercardEurozone() {
		return mastercardEurozone;
	}

	public void setMastercardEurozone(String mastercardEurozone) {
		this.mastercardEurozone = mastercardEurozone;
	}

	public String getCountryName() {
		return countryName;
	}

	public void setCountryName(String countryName) {
		this.countryName = countryName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Object getModelId() {
		
		return getId();
	}

	public Integer getFerrNo() {
		return ferrNo;
	}

	public void setFerrNo(Integer ferrNo) {
		this.ferrNo = ferrNo;
	}

    public Integer getVisaRegion() {
        return visaRegion;
    }

    public void setVisaRegion(Integer visaRegion) {
        this.visaRegion = visaRegion;
    }

    @Override
    public Country clone() throws CloneNotSupportedException {
        return (Country)super.clone();
    }

    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("lang", this.getLang());
        result.put("code", this.getCode());
        result.put("currCode", this.getCurrCode());
        result.put("name", this.getName());
        result.put("mastercardEurozone", this.getMastercardEurozone());
        result.put("mastercardRegion", this.getMastercardRegion());
        result.put("visaCountryCode", this.getVisaCountryCode());
        result.put("visaRegion", this.getVisaRegion());
        return result;
    }

}
