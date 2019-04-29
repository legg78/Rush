package ru.bpc.sv2.accounts;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AccountAlgorithm implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private boolean checkAvailBalance;
	private String description;
	private String lang;

	private String strId;

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

	public boolean getCheckAvailBalance () {
		return checkAvailBalance;
	}
	public void setCheckAvailBalance (boolean checkAvailBalance) {
		this.checkAvailBalance = checkAvailBalance;
	}

	public String getDescription () {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getStrId() {
		return strId;
	}
	public void setStrId(String strId) {
		this.strId = strId;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public AccountAlgorithm clone() throws CloneNotSupportedException {
		return (AccountAlgorithm)super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("seqNum", getSeqNum());
		result.put("checkAvailBalance", getCheckAvailBalance());
		result.put("description", getDescription());
		result.put("lang", getLang());
		return result;
	}

}
