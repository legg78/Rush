package ru.bpc.sv2.application;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ApplicationFlow implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = -4991241886310869900L;
	private Integer id;
	private Integer seqnum;
	private String appType;
	private Integer instId;
	private String instName;
	private Long templateAppId;
	private Boolean customerExist;
	private Boolean contractExist;
	private String customerType;
	private String contractType;
	private Integer modId;
	private String modName;
	private String name;
	private String description;
	private String lang;
	private String xsdSource;
	private String xsltSource;
	
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqnum() {
		return seqnum;
	}
	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public String getAppType() {
		return appType;
	}
	public void setAppType(String appType) {
		this.appType = appType;
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

	public Long getTemplateAppId() {
		return templateAppId;
	}
	public void setTemplateAppId(Long templateAppId) {
		this.templateAppId = templateAppId;
	}

	public Boolean getCustomerExist() {
		return customerExist;
	}
	public void setCustomerExist(Boolean isCustomerExist) {
		this.customerExist = isCustomerExist;
	}

	public Boolean getContractExist() {
		return contractExist;
	}
	public void setContractExist(Boolean isContractExist) { 
		this.contractExist = isContractExist;
	}

	public String getCustomerType() {
		return customerType;
	}
	public void setCustomerType(String customerType) {
		this.customerType = customerType;
	}

	public String getContractType() {
		return contractType;
	}
	public void setContractType(String contractType) {
		this.contractType = contractType;
	}

	public Integer getModId() {
		return modId;
	}
	public void setModId(Integer modId) {
		this.modId = modId;
	}

	public String getModName() {
		return modName;
	}
	public void setModName(String modName) {
		this.modName = modName;
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

	public String getXsdSource() {
		return xsdSource;
	}
	public void setXsdSource(String xsdSource) {
		this.xsdSource = xsdSource;
	}

	public String getXsltSource() {
		return xsltSource;
	}
	public void setXsltSource(String xsltSource) {
		this.xsltSource = xsltSource;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public ApplicationFlow clone() throws CloneNotSupportedException {
		return (ApplicationFlow) super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("appType", this.getAppType());
		result.put("instId", this.getInstId());
		result.put("templateAppId", this.getTemplateAppId());
		result.put("customerExist", this.getCustomerExist());
		result.put("contractExist", this.getContractExist());
		result.put("customerType", this.getCustomerType());
		result.put("contractType", this.getContractType());
		result.put("modId", this.getModId());
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		result.put("description", this.getDescription());
		return result;
	}
}
