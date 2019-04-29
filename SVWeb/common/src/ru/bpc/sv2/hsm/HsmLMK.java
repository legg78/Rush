package ru.bpc.sv2.hsm;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class HsmLMK implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private int seqNum;
	private String description;
	private String lang;
	private String checkValue;
	
	public Object getModelId() {
		return getId();
	}
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public int getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(int seqNum) {
		this.seqNum = seqNum;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}
	public String getCheckValue() {
		return checkValue;
	}
	public void setCheckValue(String checkValue) {
		this.checkValue = checkValue;
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public void incrementSeqnum(){
		this.seqNum++;
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("checkValue", getCheckValue());
		result.put("lang", getLang());
		result.put("description", getDescription());
		return result;
	}
}
