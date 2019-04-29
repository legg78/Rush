package ru.bpc.sv2.cmn;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class StandardKeyTypeMap implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = -1854126430419758204L;

	private Integer id;
	private Integer standardId;
	private Integer seqnum;
	private String keyType;
	private String standardKeyType;
	
	private String standardKeyTypeName;
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


	public Integer getStandardId() {
		return standardId;
	}


	public void setStandardId(Integer standardId) {
		this.standardId = standardId;
	}


	public Integer getSeqnum() {
		return seqnum;
	}


	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}


	public String getKeyType() {
		return keyType;
	}


	public void setKeyType(String keyType) {
		this.keyType = keyType;
	}


	public String getStandardKeyType() {
		return standardKeyType;
	}


	public void setStandardKeyType(String standardKeyType) {
		this.standardKeyType = standardKeyType;
	}


	public String getStandardKeyTypeName() {
		return standardKeyTypeName;
	}


	public void setStandardKeyTypeName(String standardKeyTypeName) {
		this.standardKeyTypeName = standardKeyTypeName;
	}

	public String getLang() {
		return lang;
	}


	public void setLang(String lang) {
		this.lang = lang;
	}


	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("keyType", this.getKeyType());
		result.put("standardKeyType", this.getStandardKeyType());
		
		return result;
	}
}
