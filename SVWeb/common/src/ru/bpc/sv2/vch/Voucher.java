package ru.bpc.sv2.vch;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class Voucher implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private Long batchId;
	private Long cardId;
	private Date expirDate;
	private Double operAmount;
	private Long operId;
	private String operType;
	private String authCode;
	private Double operRequestAmount;
	private Date operDate;
	private Integer cardNumber;
	
	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Integer getSeqnum(){
		return this.seqnum;
	}
	
	public void setSeqnum(Integer seqnum){
		this.seqnum = seqnum;
	}
	
	public Long getBatchId(){
		return this.batchId;
	}
	
	public void setBatchId(Long batchId){
		this.batchId = batchId;
	}
	
	public Long getCardId(){
		return this.cardId;
	}
	
	public void setCardId(Long cardId){
		this.cardId = cardId;
	}
	
	public Date getExpirDate(){
		return this.expirDate;
	}
	
	public void setExpirDate(Date expirDate){
		this.expirDate = expirDate;
	}
	
	public Double getOperAmount(){
		return this.operAmount;
	}
	
	public void setOperAmount(Double operAmount){
		this.operAmount = operAmount;
	}
	
	public Long getOperId(){
		return this.operId;
	}
	
	public void setOperId(Long operId){
		this.operId = operId;
	}
	
	public String getOperType(){
		return this.operType;
	}
	
	public void setOperType(String operType){
		this.operType = operType;
	}
	
	public String getAuthCode(){
		return this.authCode;
	}
	
	public void setAuthCode(String authCode){
		this.authCode = authCode;
	}
	
	public Double getOperRequestAmount(){
		return this.operRequestAmount;
	}
	
	public void setOperRequestAmount(Double operRequestAmount){
		this.operRequestAmount = operRequestAmount;
	}
	
	public Date getOperDate(){
		return this.operDate;
	}
	
	public void setOperDate(Date operDate){
		this.operDate = operDate;
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

	public Integer getCardNumber() {
		return cardNumber;
	}

	public void setCardNumber(Integer cardNumber) {
		this.cardNumber = cardNumber;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("batchId", getBatchId());
		result.put("expirDate", getExpirDate());
		result.put("operAmount", getOperAmount());
		result.put("operType", getOperType());
		result.put("authCode", getAuthCode());
		result.put("operRequestAmount", getOperRequestAmount());
		result.put("operDate", getOperDate());
		result.put("cardNumber", getCardNumber());
		return result;
	}
}