package ru.bpc.sv2.issuing.personalization;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class PrsBatch implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String lang;
	private String name;
	private Integer instId;
	private String instName;
	private Integer agentId;
	private String agentName;
	private String status;
	private Integer hsmId;
	private String hsmDescription;

	private Integer blankTypeId;
	private String blankTypeName;
	private Integer cardTypeId;
	private String cardTypeName;
	private Integer productId;
	private String productName;
	private Integer cardCount;
	private Date statusDate;
	private Date statusDateFrom;
	private Date statusDateTo;
	private Integer sortId;
	private String sortCondition;
	private String persoPriority;
	private String sortLabel;

    private String productNumber;
    private String agentNumber;

    private String cardNumber;
	private String cardUid;
    private String cardMask;
    private String cardholderName;

    private Integer cardCountActual;
    private Integer pinRequestCount;
    private Integer pinMailerRequestCount;
    private Integer embossingRequestCount;
    private String reissueReason;

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

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
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

	public Integer getHsmId() {
		return hsmId;
	}
	public void setHsmId(Integer hsmId) {
		this.hsmId = hsmId;
	}

	public String getHsmDescription() {
		return hsmDescription;
	}
	public void setHsmDescription(String hsmDescription) {
		this.hsmDescription = hsmDescription;
	}

	public Integer getBlankTypeId() {
		return blankTypeId;
	}
	public void setBlankTypeId(Integer blankTypeId) {
		this.blankTypeId = blankTypeId;
	}

	public Integer getCardTypeId() {
		return cardTypeId;
	}
	public void setCardTypeId(Integer cardTypeId) {
		this.cardTypeId = cardTypeId;
	}

	public Integer getProductId() {
		return productId;
	}
	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public Integer getCardCount() {
		return cardCount;
	}
	public void setCardCount(Integer cardCount) {
		this.cardCount = cardCount;
	}

	public String getBlankTypeName() {
		return blankTypeName;
	}
	public void setBlankTypeName(String blankTypeName) {
		this.blankTypeName = blankTypeName;
	}

	public String getCardTypeName() {
		return cardTypeName;
	}
	public void setCardTypeName(String cardTypeName) {
		this.cardTypeName = cardTypeName;
	}

	public String getProductName() {
		return productName;
	}
	public void setProductName(String productName) {
		this.productName = productName;
	}

	public boolean isProcessed() {
		return PersonalizationConstants.BATCH_STATUS_PROCESSED.equals(status);
	}

	public Date getStatusDate() {
		return statusDate;
	}
	public void setStatusDate(Date statusDate) {
		this.statusDate = statusDate;
	}

	public Date getStatusDateFrom() {
        return statusDateFrom;
	}
	public void setStatusDateFrom(Date statusDateFrom) {
		this.statusDateFrom = statusDateFrom;
	}

	public Date getStatusDateTo() {
		return statusDateTo;
	}
	public void setStatusDateTo(Date statusDateTo) {
		this.statusDateTo = statusDateTo;
	}

	public Integer getSortId() {
		return sortId;
	}
	public void setSortId(Integer sortId) {
		this.sortId = sortId;
	}

	public String getSortCondition() {
		return sortCondition;
	}
	public void setSortCondition(String sortCondition) {
		this.sortCondition = sortCondition;
	}

	public String getPersoPriority() {
		return persoPriority;
	}
	public void setPersoPriority(String persoPriority) {
		this.persoPriority = persoPriority;
	}

	public String getSortLabel() {
		return sortLabel;
	}
	public void setSortLabel(String sortLabel) {
		this.sortLabel = sortLabel;
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

    public String getCardNumber() {
        return cardNumber;
    }
    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

	public String getCardUid() {
		return cardUid;
	}
	public void setCardUid(String cardUid) {
		this.cardUid = cardUid;
	}

    public String getCardholderName() {
        return cardholderName;
    }
    public void setCardholderName(String cardholderName) {
        this.cardholderName = cardholderName;
    }

    public String getCardMask() {
        return cardMask;
    }
    public void setCardMask(String cardMask) {
        this.cardMask = cardMask;
    }

    public Integer getCardCountActual() {
        return cardCountActual;
    }
    public void setCardCountActual(Integer cardCountActual) {
        this.cardCountActual = cardCountActual;
    }

    public Integer getEmbossingRequestCount() {
        return embossingRequestCount;
    }
    public void setEmbossingRequestCount(Integer embossingRequestCount) {
        this.embossingRequestCount = embossingRequestCount;
    }

    public Integer getPinMailerRequestCount() {
        return pinMailerRequestCount;
    }
    public void setPinMailerRequestCount(Integer pinMailerRequestCount) {
        this.pinMailerRequestCount = pinMailerRequestCount;
    }

    public Integer getPinRequestCount() {
        return pinRequestCount;
    }
    public void setPinRequestCount(Integer pinRequestCount) {
        this.pinRequestCount = pinRequestCount;
    }

    public String getReissueReason() {
		return reissueReason;
	}
	public void setReissueReason(String reissueReason) {
		this.reissueReason = reissueReason;
	}

	@Override
	public PrsBatch clone() throws CloneNotSupportedException {
		PrsBatch clone = (PrsBatch)super.clone();
		clone.setStatusDate(this.statusDate);
		clone.setStatusDateFrom(this.statusDateFrom);
		clone.setStatusDateTo(this.statusDateTo);
		return clone;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("agentId", getAgentId());
		result.put("productId", getProductId());
		result.put("cardTypeId", getCardTypeId());
		result.put("cardUid", getCardUid());
		result.put("blankTypeId", getBlankTypeId());
		result.put("cardCount", getCardCount());
		result.put("hsmId", getHsmId());
		result.put("status", getStatus());
		result.put("sortId", getSortId());
		result.put("persoPriority", getPersoPriority());
		result.put("lang", getLang());
		result.put("name", getName());
		return result;
	}
}
