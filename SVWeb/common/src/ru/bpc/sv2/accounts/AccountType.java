package ru.bpc.sv2.accounts;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AccountType implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer instId;
	private String accountType;
	private Integer seqNum;
	private Integer numberFormatId;
	private String numberFormatName;
	private String instName;
	private String numberPrefix;
	private String productType;
	private boolean isChecked;
	private boolean isCheckedOld;
	private Integer minCount;
	private Integer avalCount;
	private Integer currentCount;
	private Integer maxCount;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public String getAccountType() {
		return accountType;
	}
	public void setAccountType(String accountType) {
		this.accountType = accountType;
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getNumberFormatId() {
		return numberFormatId;
	}
	public void setNumberFormatId(Integer numberFormatId) {
		this.numberFormatId = numberFormatId;
	}

	public String getNumberFormatName() {
		return numberFormatName;
	}
	public void setNumberFormatName(String numberFormatName) {
		this.numberFormatName = numberFormatName;
	}

	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getNumberPrefix() {
		return numberPrefix;
	}
	public void setNumberPrefix(String numberPrefix) {
		this.numberPrefix = numberPrefix;
	}

	public String getProductType() {
		return productType;
	}
	public void setProductType(String productType) {
		this.productType = productType;
	}

	public boolean isChecked() {
		return isChecked;
	}
	public void setChecked(boolean checked) {
		isChecked = checked;
	}

	public boolean isCheckedOld() {
		return isCheckedOld;
	}
	public void setCheckedOld(boolean checkedOld) {
		isCheckedOld = checkedOld;
	}

	public Integer getMinCount() {
		return minCount;
	}
	public void setMinCount(Integer minCount) {
		this.minCount = minCount;
	}

	public Integer getAvalCount() {
		return avalCount;
	}
	public void setAvalCount(Integer avalCount) {
		this.avalCount = avalCount;
	}

	public Integer getCurrentCount() {
		return currentCount;
	}
	public void setCurrentCount(Integer currentCount) {
		this.currentCount = currentCount;
	}

	public Integer getMaxCount() {
		return maxCount;
	}
	public void setMaxCount(Integer maxCount) {
		this.maxCount = maxCount;
	}

	@Override
	public AccountType clone() throws CloneNotSupportedException {
		return (AccountType)super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("instId", this.getInstId());
		result.put("accountType", this.getAccountType());
		result.put("numberFormatId", this.getNumberFormatId());
		result.put("numberPrefix", this.getNumberPrefix());
		result.put("productType", this.getProductType());
		return result;
	}
}
