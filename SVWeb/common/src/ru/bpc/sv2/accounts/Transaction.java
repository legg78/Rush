package ru.bpc.sv2.accounts;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.TreeIdentifiable;

public class Transaction implements Serializable, TreeIdentifiable<Transaction>, ModelIdentifiable, Cloneable{
	private static final long serialVersionUID = 1L;

	private Long transactionId;
	private Long bunchId;
	private String transType;
	private BigDecimal amount;
	private BigDecimal debitAmount;
	private BigDecimal creditAmount;
	private BigDecimal avalBal;
	private Date operationDate;
	private Date postingDate;
	private Long macrosId;
	private String currency;
	private String debitCurrency;
	private String creditCurrency;
	private Long debitAccountId;
	private String operationType;
	private String transactionType;
	private String debitAccountNumber; 
	private String debitAccountType;
	private Date debitPostingDate;
	private Date debitSttlDate;
	private Integer debitSttlDay;
	private Long creditAccountId;
	private String creditAccountNumber; 
	private String creditAccountType;
	private Date creditPostingDate;
	private Date creditSttlDate;
	private Integer creditSttlDay;
	
	private Long debitBalanceId;
	private BigDecimal debitBalance;
	private String debitBalanceType;
	
	private Long creditBalanceId;
	private BigDecimal creditBalance;
	private String creditBalanceType;
	
	private Long accountId;
	private String balanceType;

	private String amountPurpose; 
	
	
	private String description;
	private String macrosDescription;
	private String bunchDescription;
	
	private String entityType;
	private Long id;
	private Long parentId;
	private int level;
	private boolean isLeaf;
	private List<Transaction> children;
	private String debitStatus;
	private String creditStatus;
	private String merchantNumber;
	private String merchantName;
	private String merchantCity;
	private String merchantCountry;
	private String merchantStreet;
	private String objectId;
	private String originalId;
	
	public Object getModelId() {
		return getEntityType()+getLongId();
	}

	public Long getCreditAccountId() {
		return creditAccountId;
	}

	public void setCreditAccountId(Long creditAccountId) {
		this.creditAccountId = creditAccountId;
	}

	public BigDecimal getAmount() {		
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Long getDebitAccountId() {
		return debitAccountId;
	}

	public void setDebitAccountId(Long debitAccountId) {
		this.debitAccountId = debitAccountId;
	}

	public Long getMacrosId() {
		return macrosId;
	}

	public void setMacrosId(Long macrosId) {
		this.macrosId = macrosId;
	}

	public Long getTransactionId() {
		return transactionId;
	}

	public void setTransactionId(Long transactionId) {
		this.transactionId = transactionId;
	}

	public String getTransType() {
		return transType;
	}

	public void setTransType(String transType) {
		this.transType = transType;
	}

	public Date getCreditPostingDate() {
		return creditPostingDate;
	}

	public void setCreditPostingDate(Date creditPostingDate) {
		this.creditPostingDate = creditPostingDate;
	}

	public Date getDebitPostingDate() {
		return debitPostingDate;
	}

	public void setDebitPostingDate(Date debitPostingDate) {
		this.debitPostingDate = debitPostingDate;
	}

	public String getDebitAccountType() {
		return debitAccountType;
	}

	public void setDebitAccountType(String debitAccountType) {
		this.debitAccountType = debitAccountType;
	}

	public String getCreditAccountType() {
		return creditAccountType;
	}

	public void setCreditAccountType(String creditAccountType) {
		this.creditAccountType = creditAccountType;
	}

	public Long getDebitBalanceId() {
		return debitBalanceId;
	}

	public void setDebitBalanceId(Long debitBalanceId) {
		this.debitBalanceId = debitBalanceId;
	}

	public String getDebitBalanceType() {
		return debitBalanceType;
	}

	public void setDebitBalanceType(String debitBalanceType) {
		this.debitBalanceType = debitBalanceType;
	}

	public Long getCreditBalanceId() {
		return creditBalanceId;
	}

	public void setCreditBalanceId(Long creditBalanceId) {
		this.creditBalanceId = creditBalanceId;
	}

	public String getCreditBalanceType() {
		return creditBalanceType;
	}

	public void setCreditBalanceType(String creditBalanceType) {
		this.creditBalanceType = creditBalanceType;
	}

	public Long getAccountId() {
		return accountId;
	}

	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public String getBalanceType() {
		return balanceType;
	}

	public void setBalanceType(String balanceType) {
		this.balanceType = balanceType;
	}

	public String getAmountPurpose() {
		return amountPurpose;
	}

	public void setAmountPurpose(String amountPurpose) {
		this.amountPurpose = amountPurpose;
	}

	public String getDebitAccountNumber() {
		return debitAccountNumber;
	}

	public void setDebitAccountNumber(String debitAccountNumber) {
		this.debitAccountNumber = debitAccountNumber;
	}

	public String getCreditAccountNumber() {
		return creditAccountNumber;
	}

	public void setCreditAccountNumber(String creditAccountNumber) {
		this.creditAccountNumber = creditAccountNumber;
	}

	public Date getDebitSttlDate() {
		return debitSttlDate;
	}

	public void setDebitSttlDate(Date debitSttlDate) {
		this.debitSttlDate = debitSttlDate;
	}

	public Integer getDebitSttlDay() {
		return debitSttlDay;
	}

	public void setDebitSttlDay(Integer debitSttlDay) {
		this.debitSttlDay = debitSttlDay;
	}

	public Date getCreditSttlDate() {
		return creditSttlDate;
	}

	public void setCreditSttlDate(Date creditSttlDate) {
		this.creditSttlDate = creditSttlDate;
	}

	public Integer getCreditSttlDay() {
		return creditSttlDay;
	}

	public void setCreditSttlDay(Integer creditSttlDay) {
		this.creditSttlDay = creditSttlDay;
	}

	public BigDecimal getDebitBalance() {
		return debitBalance;
	}

	public void setDebitBalance(BigDecimal debitBalance) {
		this.debitBalance = debitBalance;
	}

	public BigDecimal getCreditBalance() {
		return creditBalance;
	}

	public void setCreditBalance(BigDecimal creditBalance) {
		this.creditBalance = creditBalance;
	}

	public Transaction clone() throws CloneNotSupportedException {
		return (Transaction)super.clone();
	}
	
	public List<Transaction> getChildren() {
		return children;
	}

	public void setChildren(List<Transaction> children) {
		this.children = children;
	}
	
	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}
	
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + level;
		result = prime * result
				+ ((parentId == null) ? 0 : parentId.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Transaction other = (Transaction) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;		
		
		return true;
	}

	public Long getLongId() {
		if (isTransaction()) {
			return transactionId;
		} else if (isMacros()) {
			return macrosId;
		} else if (isBunch()) {
			return bunchId;
		}
		return null;
	}

	public void setLongId(Long id) {
		this.id = id;
	}

	public Long getParentLongId() {
		return parentId;
	}

	public void setParentLongId(Long parentId) {
		this.parentId = parentId;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public boolean isLeaf() {
		return isLeaf;
	}


	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	public Long getId() {
		return null;
	}

	public void setId(Integer id) {		
	}

	public Long getParentId() {
		return null;
	}

	public void setParentId(Integer parentId) {		
	}

	public String getDescription() {
		if (isTransaction()) {
			return description;
		} else if (isMacros()) {
			return macrosDescription;
		} else if (isBunch()) {
			return bunchDescription;
		}
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}
	
	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public BigDecimal getDebitAmount() {
		return debitAmount;
	}

	public void setDebitAmount(BigDecimal debitAmount) {
		this.debitAmount = debitAmount;
	}

	public BigDecimal getCreditAmount() {
		return creditAmount;
	}

	public void setCreditAmount(BigDecimal creditAmount) {
		this.creditAmount = creditAmount;
	}
	
	public boolean isTransaction() {
		return EntityNames.TRANSACTION.equals(entityType);
	}
	
	public boolean isBunch() {
		return EntityNames.BUNCH.equals(entityType);
	}
	
	public boolean isMacros() {
		return EntityNames.MACROS.equals(entityType);
	}
	
	public boolean getIsMacros() {
		return isMacros();
	}
	
	public String getDebitCurrency() {
		return debitCurrency;
	}

	public void setDebitCurrency(String debitCurrency) {
		this.debitCurrency = debitCurrency;
	}

	public String getCreditCurrency() {
		return creditCurrency;
	}

	public void setCreditCurrency(String creditCurrency) {
		this.creditCurrency = creditCurrency;
	}

	public Long getBunchId() {
		return bunchId;
	}

	public void setBunchId(Long bunchId) {
		this.bunchId = bunchId;
	}

	public String getMacrosDescription() {
		return macrosDescription;
	}

	public void setMacrosDescription(String macrosDescription) {
		this.macrosDescription = macrosDescription;
	}

	public String getBunchDescription() {
		return bunchDescription;
	}

	public void setBunchDescription(String bunchDescription) {
		this.bunchDescription = bunchDescription;
	}

	public String getDebitStatus() {
		return debitStatus;
	}

	public void setDebitStatus(String debitStatus) {
		this.debitStatus = debitStatus;
	}

	public String getCreditStatus() {
		return creditStatus;
	}

	public void setCreditStatus(String creditStatus) {
		this.creditStatus = creditStatus;
	}

	public String getOperationType() {
		return operationType;
	}

	public void setOperationType(String operationType) {
		this.operationType = operationType;
	}

	public String getTransactionType() {
		return transactionType;
	}

	public void setTransactionType(String transactionType) {
		this.transactionType = transactionType;
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

	public BigDecimal getAvalBal() {
		return avalBal;
	}

	public void setAvalBal(BigDecimal avalBal) {
		this.avalBal = avalBal;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getMerchantCity() {
		return merchantCity;
	}

	public void setMerchantCity(String merchantCity) {
		this.merchantCity = merchantCity;
	}

	public String getMerchantCountry() {
		return merchantCountry;
	}

	public void setMerchantCountry(String merchantCountry) {
		this.merchantCountry = merchantCountry;
	}

	public String getMerchantStreet() {
		return merchantStreet;
	}

	public void setMerchantStreet(String merchantStreet) {
		this.merchantStreet = merchantStreet;
	}

	public String getMerchantNumber() {
		return merchantNumber;
	}

	public void setMerchantNumber(String merchantNumber) {
		this.merchantNumber = merchantNumber;
	}

	public String getObjectId() {
		return objectId;
	}

	public void setObjectId(String objectId) {
		this.objectId = objectId;
	}

	public String getOriginalId() {
		return originalId;
	}

	public void setOriginalId(String originalId) {
		this.originalId = originalId;
	}
	
}
