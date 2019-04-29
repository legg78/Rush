package ru.bpc.sv2.net;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CardTypeFeature implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject  {
	private Long id;
	private Integer cardTypeId;
	private Integer seqNum;
	private String cardFeature;	
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}
	public Integer getCardTypeId() {
		return cardTypeId;
	}
	public void setCardTypeId(Integer cardTypeId) {
		this.cardTypeId = cardTypeId;
	}
	public String getCardFeature() {
		return cardFeature;
	}
	public void setCardFeature(String cardFeature) {
		this.cardFeature = cardFeature;
	}
	public Object getModelId() {
		return this.id;
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
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("cardTypeId", getCardTypeId());
		result.put("cardFeature", getCardFeature());
		return result;
	}
	

}
