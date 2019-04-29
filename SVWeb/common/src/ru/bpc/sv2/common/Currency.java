package ru.bpc.sv2.common;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Currency implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private String code;
	private String name;
	private Integer exponent;
	private Integer seqNum;
	private String currencyName;
	private String lang;

	private Integer ferrNo;
	
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
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

	public Integer getExponent() {
		return exponent;
	}

	public void setExponent(Integer exponent) {
		this.exponent = exponent;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getCurrencyName() {
		return currencyName;
	}

	public void setCurrencyName(String currencyName) {
		this.currencyName = currencyName;
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
	
	@Override
	public Currency clone() throws CloneNotSupportedException {
		return (Currency)super.clone();
	}

	public Integer getFerrNo() {
		return ferrNo;
	}

	public void setFerrNo(Integer ferrNo) {
		this.ferrNo = ferrNo;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("lang", this.getLang());
		result.put("currencyName", this.getCurrencyName());
		result.put("code", this.getCode());
		result.put("name", this.getName());
		result.put("exponent", this.getExponent());
		
		return result;
	}
}
