package ru.bpc.sv2.credit;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CreditDebt implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = -7937113436736814193L;

	private Long id;
	private Long accountId;
	private Long cardId;
	private Integer productId;
	private Integer serviceId;
	private Long operationId;
	private String operationType;
	private String settlementType;
	private String feeType;
	private String terminalType;
	private Date operationDate;
	private Date postingDate;
	private Integer settlementDay;
	private Date settlementDate;
	private String currency;
	private Long amount;
	private Long debtAmount;
	private String merchantCategoryCode;
	private Integer agingPeriod;
	private Boolean _new;
	private String status;
	private Integer instId;
	private Integer agentId;
	private Integer splitHash;
	private String accountNumber;
	private String cardMask;
	private String cardNumber;
	private String institutionName;
	private String agentName;
	private String serviceName;
	private String productName;

	private Date dateFrom;
	private Date dateTo;
    private String productNumber;
    private String agentNumber;
    private Integer macrosTypeId;
    private String macrosTypeName;
    private String amountPurpose;

    private String unbilled;
	private BigDecimal revertedAmount;

	public String getInstitutionName() {
		return institutionName;
	}
	public void setInstitutionName(String institutionName) {
		this.institutionName = institutionName;
	}
	public Object getModelId() {
		return getId();
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Long getId() {
		return id;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}
	public Integer getInstId() {
		return instId;
	}
	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
	}
	public String getAccountNumber() {
		return accountNumber;
	}
	public Date getDateFrom() {
		return dateFrom;
	}
	public void setDateFrom(Date invoiceDateFrom) {
		this.dateFrom = invoiceDateFrom;
	}
	public Date getDateTo() {
		return dateTo;
	}
	public void setDateTo(Date invoiceDateTo) {
		this.dateTo = invoiceDateTo;
	}
	public String getOperationType() {
		return operationType;
	}
	public void setOperationType(String operationType) {
		this.operationType = operationType;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	public String getCardNumber() {
		return cardNumber;
	}
	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}
	public Long getAccountId() {
		return accountId;
	}
	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}
	public Long getCardId() {
		return cardId;
	}
	public void setCardId(Long cardId) {
		this.cardId = cardId;
	}
	public Integer getProductId() {
		return productId;
	}
	public void setProductId(Integer productId) {
		this.productId = productId;
	}
	public Integer getServiceId() {
		return serviceId;
	}
	public void setServiceId(Integer serviceId) {
		this.serviceId = serviceId;
	}
	public Long getOperationId() {
		return operationId;
	}
	public void setOperationId(Long operationId) {
		this.operationId = operationId;
	}
	public String getSettlementType() {
		return settlementType;
	}
	public void setSettlementType(String settlementType) {
		this.settlementType = settlementType;
	}
	public String getFeeType() {
		return feeType;
	}
	public void setFeeType(String feeType) {
		this.feeType = feeType;
	}
	public String getTerminalType() {
		return terminalType;
	}
	public void setTerminalType(String terminalType) {
		this.terminalType = terminalType;
	}
	public Date getOperationDate() {
		return operationDate;
	}
	public void setOperationDate(Date operationDate) {
		this.operationDate = operationDate;
	}
	public Date getPostingDate() {
		return postingDate;
	}
	public void setPostingDate(Date postingDate) {
		this.postingDate = postingDate;
	}
	public Integer getSettlementDay() {
		return settlementDay;
	}
	public void setSettlementDay(Integer settlementDay) {
		this.settlementDay = settlementDay;
	}
	public String getCurrency() {
		return currency;
	}
	public void setCurrency(String currency) {
		this.currency = currency;
	}
	public Long getAmount() {
		return amount;
	}
	public void setAmount(Long amount) {
		this.amount = amount;
	}
	public Long getDebtAmount() {
		return debtAmount;
	}
	public void setDebtAmount(Long debtAmount) {
		this.debtAmount = debtAmount;
	}
	public String getMerchantCategoryCode() {
		return merchantCategoryCode;
	}
	public void setMerchantCategoryCode(String merchantCategoryCode) {
		this.merchantCategoryCode = merchantCategoryCode;
	}
	public Integer getAgingPeriod() {
		return agingPeriod;
	}
	public void setAgingPeriod(Integer agingPeriod) {
		this.agingPeriod = agingPeriod;
	}
	public Integer getAgentId() {
		return agentId;
	}
	public void setAgentId(Integer agentId) {
		this.agentId = agentId;
	}
	public Integer getSplitHash() {
		return splitHash;
	}
	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}
	public String getCardMask() {
		return cardMask;
	}
	public void setCardMask(String cardMask) {
		this.cardMask = cardMask;
	}
	public void setNew(Boolean _new){
		this._new = _new;
	}
	public Boolean getNew(){
		return _new;
	}
	public String getAgentName() {
		return agentName;
	}
	public void setAgentName(String agentName) {
		this.agentName = agentName;
	}
	public String getServiceName() {
		return serviceName;
	}
	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
	}
	public String getProductName() {
		return productName;
	}
	public void setProductName(String productName) {
		this.productName = productName;
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
	public String getMacrosTypeName() {
		return macrosTypeName;
	}
	public void setMacrosTypeName(String macrosTypeName) {
		this.macrosTypeName = macrosTypeName;
	}
	public String getAmountPurpose() {
		return amountPurpose;
	}
	public void setAmountPurpose(String amountPurpose) {
		this.amountPurpose = amountPurpose;
	}
	public Integer getMacrosTypeId() {
		return macrosTypeId;
	}
	public void setMacrosTypeId(Integer macrosTypeId) {
		this.macrosTypeId = macrosTypeId;
	}
	public Date getSettlementDate() {
		return settlementDate;
	}
	public void setSettlementDate(Date settlementDate) {
		this.settlementDate = settlementDate;
	}
	public BigDecimal getRevertedAmount() {
		return revertedAmount;
	}
	public void setRevertedAmount(BigDecimal revertedAmount) {
		this.revertedAmount = revertedAmount;
	}
	public String getUnbilled() {
		if (unbilled == null && getNew() != null) {
			unbilled = getNew() ? "1" : "0";
		}
		return unbilled;
	}
	public void setUnbilled(String unbilled) {
		this.unbilled = unbilled;
		if (this.unbilled == null) {
			setNew(null);
		} else {
			setNew(this.unbilled.equalsIgnoreCase("1") ? true : false);
		}
	}
}
