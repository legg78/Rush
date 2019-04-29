package ru.bpc.sv2.accounts;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class EntryTemplatePair implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer bunchTypeId;
	private String transactionType;
	private Integer transactionNum;
	private String dateName;

	private Integer creditId;
	private Integer creditSeqNum;
	private String creditAccountName;
	private String creditPostingMethod;
	private String creditBalanceType;
	private Integer creditBalanceImpact;
	private String creditDestEntityType;
	private String creditDestAccountType;
	private String creditAmountName;
	private String creditModId;
	private String creditModDesc;
	private List<AccTypeModifier> creditAccTypeModifiers;
	
	private Integer debitId;
	private Integer debitSeqNum;
	private String debitAccountName;
	private String debitPostingMethod;
	private String debitBalanceType;
	private Integer debitBalanceImpact;
	private String debitDestEntityType;
	private String debitDestAccountType;
	private String debitAmountName;
	private String debitModId;
	private String debitModDesc;
	private List<AccTypeModifier> debitAccTypeModifiers;

	private boolean editDebit;
	private boolean editCredit;
	private boolean negativeAllowed;

	public Object getModelId() {
		return creditId + "_" + debitId;
	}

	public Integer getBunchTypeId() {
		return bunchTypeId;
	}

	public void setBunchTypeId(Integer bunchTypeId) {
		this.bunchTypeId = bunchTypeId;
	}

	public String getTransactionType() {
		return transactionType;
	}

	public void setTransactionType(String transactionType) {
		this.transactionType = transactionType;
	}

	public Integer getTransactionNum() {
		return transactionNum;
	}

	public void setTransactionNum(Integer transactionNum) {
		this.transactionNum = transactionNum;
	}

	public String getDateName() {
		return dateName;
	}

	public void setDateName(String dateName) {
		this.dateName = dateName;
	}

	public Integer getCreditId() {
		return creditId;
	}

	public void setCreditId(Integer creditId) {
		this.creditId = creditId;
	}

	public Integer getCreditSeqNum() {
		return creditSeqNum;
	}

	public void setCreditSeqNum(Integer creditSeqNum) {
		this.creditSeqNum = creditSeqNum;
	}

	public String getCreditAccountName() {
		return creditAccountName;
	}

	public void setCreditAccountName(String creditAccountName) {
		this.creditAccountName = creditAccountName;
	}

	public String getCreditPostingMethod() {
		return creditPostingMethod;
	}

	public void setCreditPostingMethod(String creditPostingMethod) {
		this.creditPostingMethod = creditPostingMethod;
	}

	public String getCreditBalanceType() {
		return creditBalanceType;
	}

	public void setCreditBalanceType(String creditBalanceType) {
		this.creditBalanceType = creditBalanceType;
	}

	public Integer getCreditBalanceImpact() {
		return creditBalanceImpact;
	}

	public void setCreditBalanceImpact(Integer creditBalanceImpact) {
		this.creditBalanceImpact = creditBalanceImpact;
	}

	public String getCreditDestEntityType() {
		return creditDestEntityType;
	}

	public void setCreditDestEntityType(String creditDestEntityType) {
		this.creditDestEntityType = creditDestEntityType;
	}

	public String getCreditDestAccountType() {
		return creditDestAccountType;
	}

	public void setCreditDestAccountType(String creditDestAccountType) {
		this.creditDestAccountType = creditDestAccountType;
	}

	public Integer getDebitId() {
		return debitId;
	}

	public void setDebitId(Integer debitId) {
		this.debitId = debitId;
	}

	public Integer getDebitSeqNum() {
		return debitSeqNum;
	}

	public void setDebitSeqNum(Integer debitSeqNum) {
		this.debitSeqNum = debitSeqNum;
	}

	public String getDebitAccountName() {
		return debitAccountName;
	}

	public void setDebitAccountName(String debitAccountName) {
		this.debitAccountName = debitAccountName;
	}

	public String getDebitPostingMethod() {
		return debitPostingMethod;
	}

	public void setDebitPostingMethod(String debitPostingMethod) {
		this.debitPostingMethod = debitPostingMethod;
	}

	public String getDebitBalanceType() {
		return debitBalanceType;
	}

	public void setDebitBalanceType(String debitBalanceType) {
		this.debitBalanceType = debitBalanceType;
	}

	public Integer getDebitBalanceImpact() {
		return debitBalanceImpact;
	}

	public void setDebitBalanceImpact(Integer debitBalanceImpact) {
		this.debitBalanceImpact = debitBalanceImpact;
	}

	public String getDebitDestEntityType() {
		return debitDestEntityType;
	}

	public void setDebitDestEntityType(String debitDestEntityType) {
		this.debitDestEntityType = debitDestEntityType;
	}

	public String getDebitDestAccountType() {
		return debitDestAccountType;
	}

	public void setDebitDestAccountType(String debitDestAccountType) {
		this.debitDestAccountType = debitDestAccountType;
	}

	public boolean isEditDebit() {
		return editDebit;
	}

	public void setEditDebit(boolean editDebit) {
		this.editDebit = editDebit;
	}

	public boolean isEditCredit() {
		return editCredit;
	}

	public void setEditCredit(boolean editCredit) {
		this.editCredit = editCredit;
	}

	public boolean isNegativeAllowed() {
		return negativeAllowed;
	}

	public void setNegativeAllowed(boolean negativeAllowed) {
		this.negativeAllowed = negativeAllowed;
	}

	public String getCreditAmountName() {
		return creditAmountName;
	}

	public void setCreditAmountName(String creditAmountName) {
		this.creditAmountName = creditAmountName;
	}

	public String getDebitAmountName() {
		return debitAmountName;
	}

	public void setDebitAmountName(String debitAmountName) {
		this.debitAmountName = debitAmountName;
	}

	public List<AccTypeModifier> getCreditAccTypeModifiers() {
		if(creditAccTypeModifiers == null){
			creditAccTypeModifiers = new ArrayList<AccTypeModifier>();
		}
		return creditAccTypeModifiers;
	}

	public void setCreditAccTypeModifiers(
			List<AccTypeModifier> creditAccTypeModifiers) {
		this.creditAccTypeModifiers = creditAccTypeModifiers;
	}

	public List<AccTypeModifier> getDebitAccTypeModifiers() {
		if(debitAccTypeModifiers == null){
			debitAccTypeModifiers = new ArrayList<AccTypeModifier>();
		}
		return debitAccTypeModifiers;
	}
	
	public void setDebitAccTypeModifiers(List<AccTypeModifier> debitAccTypeModifiers) {
		this.debitAccTypeModifiers = debitAccTypeModifiers;
	}

	public String getCreditModId() {
		return creditModId;
	}

	public void setCreditModId(String creditModId) {
		this.creditModId = creditModId;
	}
	
	public String getCreditModDesc() {
		return creditModDesc;
	}

	public void setCreditModDesc(String creditModDesc) {
		this.creditModDesc = creditModDesc;
	}

	public String getDebitModDesc() {
		return debitModDesc;
	}

	public void setDebitModDesc(String debitModDesc) {
		this.debitModDesc = debitModDesc;
	}
	
	public String getDebitModId() {
		return debitModId;
	}

	public void setDebitModId(String debitModId) {
		this.debitModId = debitModId;
	}

	@Override
	public EntryTemplatePair clone() throws CloneNotSupportedException {

		return (EntryTemplatePair) super.clone();
	}

	public EntryTemplate getDebit() {
		EntryTemplate debit = new EntryTemplate();
		debit.setId(debitId);
		debit.setBunchTypeId(bunchTypeId);
		debit.setTransactionNum(transactionNum);
		debit.setTransactionType(transactionType);
		debit.setAmountName(debitAmountName);
		debit.setDateName(dateName);
		debit.setAccountName(debitAccountName);
		debit.setPostingMethod(debitPostingMethod);
		debit.setBalanceType(debitBalanceType);
		debit.setDestEntityType(debitDestEntityType);
		debit.setDestAccountType(debitDestAccountType);
		debit.setSeqNum(debitSeqNum);
		debit.setBalanceImpact(-1);
		debit.setNegativeAllowed(negativeAllowed);
		debit.setModId(debitModId);
		return debit;
	}

	public EntryTemplate getCredit() {
		EntryTemplate credit = new EntryTemplate();
		credit.setId(creditId);
		credit.setBunchTypeId(bunchTypeId);
		credit.setTransactionNum(transactionNum);
		credit.setTransactionType(transactionType);
		credit.setAmountName(creditAmountName);
		credit.setDateName(dateName);
		credit.setAccountName(creditAccountName);
		credit.setPostingMethod(creditPostingMethod);
		credit.setBalanceType(creditBalanceType);
		credit.setDestEntityType(creditDestEntityType);
		credit.setDestAccountType(creditDestAccountType);
		credit.setSeqNum(creditSeqNum);
		credit.setBalanceImpact(1);
		credit.setNegativeAllowed(negativeAllowed);
		credit.setModId(creditModId);
		return credit;
	}

	public void setDebit(EntryTemplate debit) {
		if (debit == null) {
			debitId = null;
			debitAccountName = null;
			debitPostingMethod = null;
			debitBalanceType = null;
			debitDestEntityType = null;
			debitDestAccountType = null;
			debitSeqNum = null;
			debitBalanceImpact = null;
		} else {
			debitId = debit.getId();
			bunchTypeId = debit.getBunchTypeId();
			transactionNum = debit.getTransactionNum();
			transactionType = debit.getTransactionType();
			debitAmountName = debit.getAmountName();
			dateName = debit.getDateName();
			debitAccountName = debit.getAccountName();
			debitPostingMethod = debit.getPostingMethod();
			debitBalanceType = debit.getBalanceType();
			debitDestEntityType = debit.getDestEntityType();
			debitDestAccountType = debit.getDestAccountType();
			debitSeqNum = debit.getSeqNum();
			debitBalanceImpact = debit.getBalanceImpact();
		}
	}

	public void setCredit(EntryTemplate credit) {
		if (credit == null) {
			creditId = null;
			creditAccountName = null;
			creditPostingMethod = null;
			creditBalanceType = null;
			creditDestEntityType = null;
			creditDestAccountType = null;
			creditSeqNum = null;
			creditBalanceImpact = null;
		} else {
			creditId = credit.getId();
			bunchTypeId = credit.getBunchTypeId();
			transactionNum = credit.getTransactionNum();
			transactionType = credit.getTransactionType();
			creditAmountName = credit.getAmountName();
			dateName = credit.getDateName();
			creditAccountName = credit.getAccountName();
			creditPostingMethod = credit.getPostingMethod();
			creditBalanceType = credit.getBalanceType();
			creditDestEntityType = credit.getDestEntityType();
			creditDestAccountType = credit.getDestAccountType();
			creditSeqNum = credit.getSeqNum();
			creditBalanceImpact = credit.getBalanceImpact();
		}
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("transactionType", this.getTransactionType());
		result.put("transactionNum", this.getTransactionNum());
		result.put("dateName", this.getDateName());
		result.put("negativeAllowed", this.isNegativeAllowed());
		
		return result;
	}
}
