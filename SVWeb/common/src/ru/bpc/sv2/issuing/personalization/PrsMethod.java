package ru.bpc.sv2.issuing.personalization;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class PrsMethod implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String lang;
	private String name;
	private Integer instId;
	private String instName;
	private String pinStoreMethod;
	private String pvvStoreMethod;
	private String pinVerifyMethod;
	private String pinLength;
	private boolean cvvRequired;
	private boolean cvv2Required;
	private boolean icvvRequired;
	private Integer pvkIndex;
	private Integer keySchemaId;
	private String keySchemaName;
	private String serviceCode;	
//	private Integer emvTemplateId;
	private String emvTemplateName;
//	private String cardConfig;
//	private String pffVersion;
	private Boolean ddaRequired;
	private Integer imkIndex;
	private String pvkComponent;
	private String pvkFormat;
	private Integer moduleLength;
	private String decimalisationTable;
	private Integer maxScript;
	private String expDateFormat;
	
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

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
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

	public String getPinStoreMethod() {
		return pinStoreMethod;
	}

	public void setPinStoreMethod(String pinStoreMethod) {
		this.pinStoreMethod = pinStoreMethod;
	}

	public String getPvvStoreMethod() {
		return pvvStoreMethod;
	}

	public void setPvvStoreMethod(String pvvStoreMethod) {
		this.pvvStoreMethod = pvvStoreMethod;
	}

	public String getPinVerifyMethod() {
		return pinVerifyMethod;
	}

	public void setPinVerifyMethod(String pinVerifyMethod) {
		this.pinVerifyMethod = pinVerifyMethod;
	}

	public boolean isCvvRequired() {
		return cvvRequired;
	}

	public void setCvvRequired(boolean cvvRequired) {
		this.cvvRequired = cvvRequired;
	}

	public boolean isIcvvRequired() {
		return icvvRequired;
	}

	public void setIcvvRequired(boolean icvvRequired) {
		this.icvvRequired = icvvRequired;
	}

	public Integer getPvkIndex() {
		return pvkIndex;
	}

	public void setPvkIndex(Integer pvkIndex) {
		this.pvkIndex = pvkIndex;
	}

	public Integer getKeySchemaId() {
		return keySchemaId;
	}

	public void setKeySchemaId(Integer keySchemaId) {
		this.keySchemaId = keySchemaId;
	}

	public String getKeySchemaName() {
		return keySchemaName;
	}

	public void setKeySchemaName(String keySchemaName) {
		this.keySchemaName = keySchemaName;
	}

	public String getServiceCode() {
		return serviceCode;
	}

	public void setServiceCode(String serviceCode) {
		this.serviceCode = serviceCode;
	}

//	public Integer getEmvTemplateId() {
//		return emvTemplateId;
//	}
//
//	public void setEmvTemplateId(Integer emvTemplateId) {
//		this.emvTemplateId = emvTemplateId;
//	}

	public String getEmvTemplateName() {
		return emvTemplateName;
	}

	public void setEmvTemplateName(String emvTemplateName) {
		this.emvTemplateName = emvTemplateName;
	}

	@Override
	public PrsMethod clone() throws CloneNotSupportedException {
		return (PrsMethod) super.clone();
	}

//	public String getCardConfig() {
//		return cardConfig;
//	}
//
//	public void setCardConfig(String cardConfig) {
//		this.cardConfig = cardConfig;
//	}
//
//	public String getPffVersion() {
//		return pffVersion;
//	}
//
//	public void setPffVersion(String pffVersion) {
//		this.pffVersion = pffVersion;
//	}

	public Boolean getDdaRequired() {
		return ddaRequired;
	}

	public void setDdaRequired(Boolean ddaRequired) {
		this.ddaRequired = ddaRequired;
	}

	public Integer getImkIndex() {
		return imkIndex;
	}

	public void setImkIndex(Integer imkIndex) {
		this.imkIndex = imkIndex;
	}

	public String getPvkComponent() {
		return pvkComponent;
	}

	public void setPvkComponent(String pvkComponent) {
		this.pvkComponent = pvkComponent;
	}

	public String getPvkFormat() {
		return pvkFormat;
	}

	public void setPvkFormat(String pvkFormat) {
		this.pvkFormat = pvkFormat;
	}

	public Integer getModuleLength() {
		return moduleLength;
	}

	public void setModuleLength(Integer moduleLength) {
		this.moduleLength = moduleLength;
	}

	public String getDecimalisationTable() {
		return decimalisationTable;
	}

	public void setDecimalisationTable(String decimalisationTable) {
		this.decimalisationTable = decimalisationTable;
	}

	public Integer getMaxScript() {
		return maxScript;
	}

	public void setMaxScript(Integer maxScript) {
		this.maxScript = maxScript;
	}

	public String getExpDateFormat() {
		return expDateFormat;
	}

	public void setExpDateFormat(String expDateFormat) {
		this.expDateFormat = expDateFormat;
	}

	public String getPinLength() {
		return pinLength;
	}

	public void setPinLength(String pinLength) {
		this.pinLength = pinLength;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("pvvStoreMethod", getPvvStoreMethod());
		result.put("pinStoreMethod", getPinStoreMethod());
		result.put("pinVerifyMethod", getPinVerifyMethod());
		result.put("cvvRequired", isCvvRequired());
		result.put("icvvRequired", isIcvvRequired());
		result.put("pvkIndex", getPvkIndex());
		result.put("keySchemaId", getKeySchemaId());
		result.put("serviceCode", getServiceCode());
		result.put("ddaRequired", getDdaRequired());
		result.put("imkIndex", getImkIndex());
		result.put("pvkComponent", getPvkComponent());
		result.put("pvkFormat", getPvkFormat());
		result.put("moduleLength", getModuleLength());
		result.put("maxScript", getMaxScript());
		result.put("decimalisationTable", getDecimalisationTable());
		result.put("expDateFormat", getExpDateFormat());
		result.put("pinLength", getPinLength());
		result.put("lang", getLang());
		result.put("name", getName());
		return result;
	}

	public boolean isCvv2Required() {
		return cvv2Required;
	}

	public void setCvv2Required(boolean cvv2Required) {
		this.cvv2Required = cvv2Required;
	}
}
