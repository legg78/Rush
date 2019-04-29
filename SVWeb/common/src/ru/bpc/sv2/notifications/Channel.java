package ru.bpc.sv2.notifications;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Channel implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private String addressPattern;
	private Integer msgMaxLength;
	private String addressSource;
	@Deprecated
	private Integer instId;
	private String name;
	private String description;
	private String lang;
	private String instName;
	
	public Object getModelId() {
		
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getAddressPattern() {
		return addressPattern;
	}

	public void setAddressPattern(String addressPattern) {
		this.addressPattern = addressPattern;
	}

	public Integer getMsgMaxLength() {
		return msgMaxLength;
	}

	public void setMsgMaxLength(Integer msgMaxLength) {
		this.msgMaxLength = msgMaxLength;
	}

	public String getAddressSource() {
		return addressSource;
	}

	public void setAddressSource(String addressSource) {
		this.addressSource = addressSource;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
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

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("addressPattern", getAddressPattern());
		result.put("msgMaxLength", getMsgMaxLength());
		result.put("addressSource", getAddressSource());
		result.put("lang", getLang());
		result.put("name", getName());
		result.put("description", getDescription());
		return result;
	}

}
