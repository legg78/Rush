package ru.bpc.sv2.aup;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AuthTemplate implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String templType;
	private String respCode;
	private Integer modId;
	private Integer scaleId;
	private String condition;
	private String name;
	private String description;
	private String lang;

	public Object getModelId() {
		return getId();
	}

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

	public String getTemplType() {
		return templType;
	}

	public void setTemplType(String templType) {
		this.templType = templType;
	}

	public String getRespCode() {
		return respCode;
	}

	public void setRespCode(String respCode) {
		this.respCode = respCode;
	}

	public Integer getModId() {
		return modId;
	}

	public void setModId(Integer modId) {
		this.modId = modId;
	}

	public Integer getScaleId() {
		return scaleId;
	}

	public void setScaleId(Integer scaleId) {
		this.scaleId = scaleId;
	}

	public String getCondition() {
		return condition;
	}

	public void setCondition(String condition) {
		this.condition = condition;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
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

	@Override
	public AuthTemplate clone() throws CloneNotSupportedException {
		return (AuthTemplate) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", this.getId());
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		result.put("description", this.getDescription());
		result.put("modId", this.getModId());
		result.put("templType", this.getTemplType());
		result.put("respCode", this.getRespCode());
		result.put("condition", this.getCondition());
		
		return result;
	}

}
