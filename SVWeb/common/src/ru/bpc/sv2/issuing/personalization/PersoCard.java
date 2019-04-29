package ru.bpc.sv2.issuing.personalization;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.issuing.BaseCard;

import java.util.HashMap;
import java.util.Map;

public class PersoCard extends BaseCard implements  IAuditableObject {
	private static final long serialVersionUID = 1L;

//	private Long id;
	private String mask;
	private String cardUid;
	private Integer seqNumber;
	private String cardholderName;	
	
	private Integer processOrder;
	
	private Integer instId;
	private String instName;
	
	private Integer productId;
	private boolean blockProductId;
	private String productName;	
	
	private String companyName;
	private String onlineStatus;
	private String persoPriority;
	private String pinRequest;
	private String pinMailerRequest;
	private String embossingRequest;
	
	private Integer batchId;
	private boolean included;
	
	private Integer blankTypeId;
	private boolean blockBlankTypeId;
	private String blankTypeName;
	private Integer agentId;
	private boolean blockAgentId;
	private String agentName;	
	private Integer cardTypeId;
	private boolean blockCardTypeId;
	private String cardTypeName;
	private boolean blockPersoPriority;
	
    private String productNumber;
    private String agentNumber;

    private String message;

	public String getMask() {
		return mask;
	}
	public void setMask(String mask) {
		this.mask = mask;
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

	public String getCardholderName() {
		return cardholderName;
	}
	public void setCardholderName(String cardholderName) {
		this.cardholderName = cardholderName;
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

	public Integer getProductId() {
		return productId;
	}
	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public String getProductName() {
		return productName;
	}
	public void setProductName(String productName) {
		this.productName = productName;
	}

	public String getCompanyName() {
		return companyName;
	}
	public void setCompanyName(String companyName) {
		this.companyName = companyName;
	}

	public String getOnlineStatus() {
		return onlineStatus;
	}
	public void setOnlineStatus(String onlineStatus) {
		this.onlineStatus = onlineStatus;
	}

	public String getPersoPriority() {
		return persoPriority;
	}
	public void setPersoPriority(String persoPriority) {
		this.persoPriority = persoPriority;
	}

	public String getPinRequest() {
		return pinRequest;
	}
	public void setPinRequest(String pinRequest) {
		this.pinRequest = pinRequest;
	}

	public String getPinMailerRequest() {
		return pinMailerRequest;
	}
	public void setPinMailerRequest(String pinMailerRequest) {
		this.pinMailerRequest = pinMailerRequest;
	}

	public String getEmbossingRequest() {
		return embossingRequest;
	}
	public void setEmbossingRequest(String embossingRequest) {
		this.embossingRequest = embossingRequest;
	}

	public Integer getBatchId() {
		return batchId;
	}
	public void setBatchId(Integer batchId) {
		this.batchId = batchId;
	}

	public boolean isIncluded() {
		return included;
	}
	public void setIncluded(boolean included) {
		this.included = included;
	}

	public Integer getProcessOrder() {
		return processOrder;
	}
	public void setProcessOrder(Integer processOrder) {
		this.processOrder = processOrder;
	}

	public Integer getBlankTypeId() {
		return blankTypeId;
	}
	public void setBlankTypeId(Integer blankTypeId) {
		this.blankTypeId = blankTypeId;
	}

	public String getBlankTypeName() {
		return blankTypeName;
	}
	public void setBlankTypeName(String blankTypeName) {
		this.blankTypeName = blankTypeName;
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

	public Integer getCardTypeId() {
		return cardTypeId;
	}
	public void setCardTypeId(Integer cardTypeId) {
		this.cardTypeId = cardTypeId;
	}

	public String getCardTypeName() {
		return cardTypeName;
	}
	public void setCardTypeName(String cardTypeName) {
		this.cardTypeName = cardTypeName;
	}

	public boolean isBlockProductId() {
		return blockProductId;
	}
	public void setBlockProductId(boolean blockProductId) {
		this.blockProductId = blockProductId;
	}

	public boolean isBlockBlankTypeId() {
		return blockBlankTypeId;
	}
	public void setBlockBlankTypeId(boolean blockBlankTypeId) {
		this.blockBlankTypeId = blockBlankTypeId;
	}

	public boolean isBlockAgentId() {
		return blockAgentId;
	}
	public void setBlockAgentId(boolean blockAgentId) {
		this.blockAgentId = blockAgentId;
	}

	public boolean isBlockCardTypeId() {
		return blockCardTypeId;
	}
	public void setBlockCardTypeId(boolean blockCardTypeId) {
		this.blockCardTypeId = blockCardTypeId;
	}

	public void setBlockPersoPriority(boolean blockPersoPriority) {
		this.blockPersoPriority = blockPersoPriority;
	}
	public boolean getBlockPersoPriority(){
		return blockPersoPriority;
	}

    public String getProductNumber() {
        return productNumber;
    }
    public void setProductNumber(String productNumber) {
        this.productNumber = productNumber;
    }

    public String getAgentNumber() {
        return agentNumber;
    }
    public void setAgentNumber(String agentNumber) {
        this.agentNumber = agentNumber;
    }

    public String getMessage() {
        return message;
    }
    public void setMessage(String message) {
        this.message = message;
    }

	@Override
	public PersoCard clone() throws CloneNotSupportedException {
		return (PersoCard) super.clone();
	}

    @Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("batchId", getBatchId());
		result.put("agentId", getAgentId());
		result.put("cardTypeId", getCardTypeId());
		result.put("blankTypeId", getBlankTypeId());
		result.put("productId", getProductId());
		result.put("persoPriority", getPersoPriority());
		result.put("pinRequest", getPinRequest());
		result.put("pinMailerRequest", getPinMailerRequest());
		result.put("embossingRequest", getEmbossingRequest());
		return result;
	}
}
