package ru.bpc.sv2.operations;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class EntityOperTypeBundle implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqnum;
	private Integer instId;
	private String entityType;
	private String operType;
	private String invokeMethod;
	private Integer reasonLovId;
	private String objectType;
	private Long wizardId;
	private String operTypeName;
	private String lang;
	private String name;
	private String entityObjectType;

	public Object getModelId() {
		return getId();
	}
	
	public Integer getId(){
		return this.id;
	}
	
	public void setId(Integer id){
		this.id = id;
	}
	
	public Integer getSeqnum(){
		return this.seqnum;
	}
	
	public void setSeqnum(Integer seqnum){
		this.seqnum = seqnum;
	}
	
	public Integer getInstId(){
		return this.instId;
	}
	
	public void setInstId(Integer instId){
		this.instId = instId;
	}
	
	public String getEntityType(){
		return this.entityType;
	}
	
	public void setEntityType(String entityType){
		this.entityType = entityType;
	}
	
	public String getOperType(){
		return this.operType;
	}
	
	public void setOperType(String operType){
		this.operType = operType;
	}
	
	public String getInvokeMethod(){
		return this.invokeMethod;
	}
	
	public void setInvokeMethod(String invokeMethod){
		this.invokeMethod = invokeMethod;
	}
	
	public Integer getReasonLovId(){
		return this.reasonLovId;
	}
	
	public void setReasonLovId(Integer reasonLovId){
		this.reasonLovId = reasonLovId;
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

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public Long getWizardId() {
		return wizardId;
	}

	public void setWizardId(Long wizardId) {
		this.wizardId = wizardId;
	}

	public String getOperTypeName() {
		return operTypeName;
	}

	public void setOperTypeName(String operTypeName) {
		this.operTypeName = operTypeName;
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

	public String getEntityObjectType() {
		return entityObjectType;
	}

	public void setEntityObjectType(String entityObjectType) {
		this.entityObjectType = entityObjectType;
	}
}
