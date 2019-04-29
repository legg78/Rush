package ru.bpc.sv2.common;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Dictionary
	implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject
{

	/**
	 *
	 */
	private static final long serialVersionUID = -1626280767824227121L;
	private String dict;
	private String code;
	private String name;
	private String description;
	private String lang;
	private boolean numeric;
	private boolean editable;
	private Integer id;
	private Integer instId;
	private String instName;
	private String moduleCode;
	
	private Integer ferrNo;
	private Integer seqNum;
	
	public String getFullCode() {
		return getDict() + getCode();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Object getModelId()
	{
		return getId();
	}

	public String getDict() {
		return dict;
	}

	public void setDict(String dict) {
		this.dict = dict;
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

	public boolean isNumeric() {
		return numeric;
	}

	public void setNumeric(boolean numeric) {
		this.numeric = numeric;
	}

	public boolean isEditable() {
		return editable;
	}

	public void setEditable(boolean editable) {
		this.editable = editable;
	}
	
	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	@Override
	public Dictionary clone() {
		try {
			return (Dictionary)super.clone();
		} catch (CloneNotSupportedException e) {
			return this;
		}
	}

	public Integer getFerrNo() {
		return ferrNo;
	}

	public void setFerrNo(Integer ferrNo) {
		this.ferrNo = ferrNo;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getModuleCode() {
		return moduleCode;
	}

	public void setModuleCode(String moduleCode) {
		this.moduleCode = moduleCode;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("dict", this.getDict());
		result.put("code", this.getCode());
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		result.put("numeric", this.isNumeric());
		result.put("description", this.getDescription());
		
		return result;
	}
}