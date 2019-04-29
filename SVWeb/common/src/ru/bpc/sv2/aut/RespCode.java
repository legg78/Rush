package ru.bpc.sv2.aut;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class RespCode implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	public static final String SUCCESS = "RESP0001";
	
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqnum;
	private String respCode;
	private Integer isReversal;
	private String procType;
	private String authStatus;
	private String procMode;
	private String statusReason;
	private String operType;
	private Integer priority;
	private String msgType;
	private String signCompletion;
	private String sttlType;
	private String operReason;
	
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
	
	public String getRespCode(){
		return this.respCode;
	}
	
	public void setRespCode(String respCode){
		this.respCode = respCode;
	}
	
	public Integer getIsReversal(){
		return this.isReversal;
	}
	
	public void setIsReversal(Integer isReversal){
		this.isReversal = isReversal;
	}
	
	public String getProcType(){
		return this.procType;
	}
	
	public void setProcType(String procType){
		this.procType = procType;
	}
	
	public String getAuthStatus(){
		return this.authStatus;
	}
	
	public void setAuthStatus(String authStatus){
		this.authStatus = authStatus;
	}
	
	public String getProcMode(){
		return this.procMode;
	}
	
	public void setProcMode(String procMode){
		this.procMode = procMode;
	}
	
	public String getStatusReason(){
		return this.statusReason;
	}
	
	public void setStatusReason(String statusReason){
		this.statusReason = statusReason;
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

	public String getMsgType() {
		return msgType;
	}

	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}

	public String getSignCompletion() {
		return signCompletion;
	}

	public void setSignCompletion(String signCompletion) {
		this.signCompletion = signCompletion;
	}

	public String getSttlType() {
		return sttlType;
	}

	public void setSttlType(String sttlType) {
		this.sttlType = sttlType;
	}

	public String getOperReason() {
		return operReason;
	}

	public void setOperReason(String operReason) {
		this.operReason = operReason;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("operType", this.getOperType());
		result.put("msgType", this.getMsgType());
		result.put("isReversal", this.getIsReversal());
		result.put("respCode", this.getRespCode());
		result.put("signCompletion", this.getSignCompletion());
		result.put("priority", this.getPriority());
		result.put("authStatus", this.getAuthStatus());
		result.put("statusReason", this.getStatusReason());
		result.put("procMode", this.getProcMode());
		result.put("procType", this.getProcType());
		result.put("sttlType", this.getSttlType());
		
		return result;
	}
	
}