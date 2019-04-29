package ru.bpc.sv2.issuing;

import ru.bpc.sv2.invocation.IAuditableObject;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class CardInstance extends BaseCard implements IAuditableObject {
	private static final long serialVersionUID = 1L;

//	private Long id;
	private Integer splitHash;
	private Long cardId;
	private String cardUid;
	
	private Integer seqNumber;
	private String status;
	private Date regDate;
	private Date issDate;
	private Date startDate;
	private Date expirDate;
	
	private String cardholderName;	
	private String companyName;
	private String state;
//	private String pinRequest;
//	private String pinMailerRequest;
//	private String embossingRequest;
//	private String persoPriority;
	private Integer persoMethodId;
	private String persoMethodName;
	private Integer binId;
	private String binName;
	
	private Integer instId;
	private String instName;
	private Integer agentId;
	private String agentName;
	private Integer blankId;
	private String blankName;
	private String deliveryChannel;

	public String getBlankName() {
		return blankName;
	}
	public void setBlankName(String blankName) {
		this.blankName = blankName;
	}

	public Integer getSplitHash() {
		return splitHash;
	}
	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public Long getCardId() {
		return cardId;
	}
	public void setCardId(Long cardId) {
		this.cardId = cardId;
	}

	public String getCardUid() {
		return cardUid;
	}
	public void setCardUid(String cardUid) {
		this.cardUid = cardUid;
	}

	public Integer getSeqNumber() {
		return seqNumber;
	}
	public void setSeqNumber(Integer seqNumber) {
		this.seqNumber = seqNumber;
	}

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	public Date getRegDate() {
		return regDate;
	}
	public void setRegDate(Date regDate) {
		this.regDate = regDate;
	}

	public Date getIssDate() {
		return issDate;
	}
	public void setIssDate(Date issDate) {
		this.issDate = issDate;
	}

	public Date getStartDate() {
		return startDate;
	}
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getExpirDate() {
		return expirDate;
	}
	public void setExpirDate(Date expirDate) {
		this.expirDate = expirDate;
	}

	public String getCardholderName() {
		return cardholderName;
	}
	public void setCardholderName(String cardholderName) {
		this.cardholderName = cardholderName;
	}

	public String getCompanyName() {
		return companyName;
	}
	public void setCompanyName(String companyName) {
		this.companyName = companyName;
	}

	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}

	public Integer getPersoMethodId() {
		return persoMethodId;
	}
	public void setPersoMethodId(Integer persoMethodId) {
		this.persoMethodId = persoMethodId;
	}

	public String getPersoMethodName() {
		return persoMethodName;
	}
	public void setPersoMethodName(String persoMethodName) {
		this.persoMethodName = persoMethodName;
	}

	public Integer getBinId() {
		return binId;
	}
	public void setBinId(Integer binId) {
		this.binId = binId;
	}

	public String getBinName() {
		return binName;
	}
	public void setBinName(String binName) {
		this.binName = binName;
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

	public Integer getAgentId() {
		return agentId;
	}
	public void setAgentId(Integer agentId) {
		this.agentId = agentId;
	}

	public String getAgentName() {
		return agentName;
	}
	public void setAgentName(String agentName) {
		this.agentName = agentName;
	}

	public String getDeliveryChannel() {
		return deliveryChannel;
	}
	public void setDeliveryChannel(String deliveryChannel) {
		this.deliveryChannel = deliveryChannel;
	}

	public Integer getBlankId() {
		return blankId;
	}
	public void setBlankId(Integer blankId) {
		this.blankId = blankId;
	}

    @Override
	public CardInstance clone() throws CloneNotSupportedException {
		return (CardInstance) super.clone();
	}

    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("cardId", getCardId());
        result.put("cardUid", getCardUid());
        result.put("persoPriority", getPersoPriority());
        result.put("pinRequest", getPinRequest());
        result.put("pinMailerRequest", getPinMailerRequest());
        result.put("embossingRequest", getEmbossingRequest());
        return result;
    }

}
