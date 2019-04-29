package ru.bpc.sv2.common.application;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class AppFlowStep implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqnum;
	private Integer flowId;
	private String stepLabel;
	private String applStatus;
	private String stepSource;
	private Boolean readOnly;
	private Integer displayOrder;
	private String lang;
	private Boolean keyStep = false;
	
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
	
	public Integer getFlowId(){
		return this.flowId;
	}
	
	public void setFlowId(Integer flowId){
		this.flowId = flowId;
	}
	
	public String getStepLabel(){
		return this.stepLabel;
	}
	
	public void setStepLabel(String stepLabel){
		this.stepLabel = stepLabel;
	}
	
	public String getApplStatus(){
		return this.applStatus;
	}
	
	public void setApplStatus(String applStatus){
		this.applStatus = applStatus;
	}
	
	public String getStepSource(){
		return this.stepSource;
	}
	
	public void setStepSource(String stepSource){
		this.stepSource = stepSource;
	}
	
	public Boolean getReadOnly(){
		return this.readOnly;
	}
	
	public void setReadOnly(Boolean readOnly){
		this.readOnly = readOnly;
	}
	
	public Integer getDisplayOrder(){
		return this.displayOrder;
	}
	
	public void setDisplayOrder(Integer displayOrder){
		this.displayOrder = displayOrder;
	}
	
	public String getLang(){
		return this.lang;
	}
	
	public void setLang(String lang){
		this.lang = lang;
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

	public Boolean isKeyStep() {
		return keyStep;
	}

	public void setKeyStep(Boolean keyStep) {
		this.keyStep = keyStep;
	}
}