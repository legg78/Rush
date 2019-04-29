package ru.bpc.sv2.acquiring;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class MccSelection implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer terminalId;
	private String operType;
	private Integer priority;
	private String mcc;
	private String mccDescription;
	private String lang;
	private Long mccTemplateId;
	private Long purposeId;
	private String operReason;
	private String merchantNameSpec;
	
	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Integer getTerminalId(){
		return this.terminalId;
	}
	
	public void setTerminalId(Integer terminalId){
		this.terminalId = terminalId;
	}
	
	public String getOperType(){
		return this.operType;
	}
	
	public void setOperType(String operType){
		this.operType = operType;
	}
	
	public Integer getPriority(){
		return this.priority;
	}
	
	public void setPriority(Integer priority){
		this.priority = priority;
	}
	
	public String getMcc(){
		return this.mcc;
	}
	
	public void setMcc(String mcc){
		this.mcc = mcc;
	}
	
	public Object clone(){
		Object result = null;
		try {
			result = super.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}
		return result;
	}

	public String getMccDescription() {
		return mccDescription;
	}

	public void setMccDescription(String mccDescription) {
		this.mccDescription = mccDescription;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Long getMccTemplateId() {
		return mccTemplateId;
	}

	public void setMccTemplateId(Long mccTemplateId) {
		this.mccTemplateId = mccTemplateId;
	}

	public Long getPurposeId() {
		return purposeId;
	}

	public void setPurposeId(Long purposeId) {
		this.purposeId = purposeId;
	}

	public String getOperReason() {
		return operReason;
	}

	public void setOperReason(String operReason) {
		this.operReason = operReason;
	}

	public String getMerchantNameSpec() {
		return merchantNameSpec;
	}

	public void setMerchantNameSpec(String merchantNameSpec) {
		this.merchantNameSpec = merchantNameSpec;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("operType", this.getOperType());
		result.put("mcc", this.getMcc());
		result.put("priority", this.getPriority());
		result.put("purposeId", this.getPurposeId());
		result.put("operReason", this.getOperReason());
		result.put("terminalId", this.getTerminalId());
		return result;
	}
}