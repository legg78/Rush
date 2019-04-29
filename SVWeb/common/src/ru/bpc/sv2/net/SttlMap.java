package ru.bpc.sv2.net;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class SttlMap implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String issInstId;
	private String issNetworkId;
	private String acqInstId;
	private String acqNetworkId;
	private String cardInstId;
	private String cardNetworkId;
	private Integer modId;
	private Integer priority;
	private String sttlType;
	private String matchStatus;
	
	private String issInstName;
	private String acqInstName;
	private String cardInstName;
	private String issNetworkName;
	private String acqNetworkName;
	private String cardNetworkName;
	private String modName;
	private String operType;
	
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

	public String getIssInstId() {
		return issInstId;
	}

	public void setIssInstId(String issInstId) {
		this.issInstId = issInstId;
	}

	public String getIssNetworkId() {
		return issNetworkId;
	}

	public void setIssNetworkId(String issNetworkId) {
		this.issNetworkId = issNetworkId;
	}

	public String getAcqInstId() {
		return acqInstId;
	}

	public void setAcqInstId(String acqInstId) {
		this.acqInstId = acqInstId;
	}

	public String getAcqNetworkId() {
		return acqNetworkId;
	}

	public void setAcqNetworkId(String acqNetworkId) {
		this.acqNetworkId = acqNetworkId;
	}

	public String getCardInstId() {
		return cardInstId;
	}

	public void setCardInstId(String cardInstId) {
		this.cardInstId = cardInstId;
	}

	public String getCardNetworkId() {
		return cardNetworkId;
	}

	public void setCardNetworkId(String cardNetworkId) {
		this.cardNetworkId = cardNetworkId;
	}

	public Integer getModId() {
		return modId;
	}

	public void setModId(Integer modId) {
		this.modId = modId;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public String getSttlType() {
		return sttlType;
	}

	public void setSttlType(String sttlType) {
		this.sttlType = sttlType;
	}

	public String getIssInstName() {
		return issInstName;
	}

	public void setIssInstName(String issInstName) {
		this.issInstName = issInstName;
	}

	public String getAcqInstName() {
		return acqInstName;
	}

	public void setAcqInstName(String acqInstName) {
		this.acqInstName = acqInstName;
	}

	public String getCardInstName() {
		return cardInstName;
	}

	public void setCardInstName(String cardInstName) {
		this.cardInstName = cardInstName;
	}

	public String getIssNetworkName() {
		return issNetworkName;
	}

	public void setIssNetworkName(String issNetworkName) {
		this.issNetworkName = issNetworkName;
	}

	public String getAcqNetworkName() {
		return acqNetworkName;
	}

	public void setAcqNetworkName(String acqNetworkName) {
		this.acqNetworkName = acqNetworkName;
	}

	public String getCardNetworkName() {
		return cardNetworkName;
	}

	public void setCardNetworkName(String cardNetworkName) {
		this.cardNetworkName = cardNetworkName;
	}

	public String getModName() {
		return modName;
	}

	public void setModName(String modName) {
		this.modName = modName;
	}

	public String getMatchStatus() {
		return matchStatus;
	}

	public void setMatchStatus(String matchStatus) {
		this.matchStatus = matchStatus;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public boolean isAnyOperType(){
		return operType != null && operType.equals("%");
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public boolean isAnyIssInst() {
		// can be only "%", not null, not anything else
		return issInstId != null && "%".equals(issInstId);
	}
	
	public boolean isAnyAcqInst() {
		// can be only "%", not null, not anything else
		return acqInstId != null && "%".equals(acqInstId);
	}

	public boolean isAnyCardInst() {
		// can be only "%", not null, not anything else
		return cardInstId != null && "%".equals(cardInstId);
	}

	public boolean isAnyIssNetwork() {
		// can be only "%", not null, not anything else
		return issNetworkId != null && "%".equals(issNetworkId);
	}

	public boolean isAnyAcqNetwork() {
		// can be only "%", not null, not anything else
		return acqNetworkId != null && "%".equals(acqNetworkId);
	}

	public boolean isAnyCardNetwork() {
		// can be only "%", not null, not anything else
		return cardNetworkId != null && "%".equals(cardNetworkId);
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("issInstId", getIssInstId());
		result.put("issNetworkId", getIssNetworkId());
		result.put("acqInstId", getAcqInstId());
		result.put("acqNetworkId", getAcqNetworkId());
		result.put("cardInstId", getCardInstId());
		result.put("cardNetworkId", getCardNetworkId());
		result.put("modId", getModId());
		result.put("priority", getPriority());
		result.put("sttlType", getSttlType());
		result.put("matchStatus", getMatchStatus());
		result.put("operType", getOperType());
		return result;
	}
}
