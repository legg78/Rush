package ru.bpc.sv2.fcl.fees;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class FeeType implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = -5799785518977155610L;

	private int id;
	private String seqnum;
	private String feeType;
	private String entityType;
	private String cycleType;
	private String limitType;
	private String shortDesc;
	private String fullDesc;
	private String lang;
	private boolean needLengthType;

	public FeeType() {}

	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getShortDesc() {
		return shortDesc;
	}
	public void setShortDesc(String shortDesc) {
		this.shortDesc = shortDesc;
	}

	public String getFullDesc() {
		return fullDesc;
	}
	public void setFullDesc(String fullDesc) {
		this.fullDesc = fullDesc;
	}

	public String getSeqnum() {
		return seqnum;
	}
	public void setSeqnum(String seqnum) {
		this.seqnum = seqnum;
	}

	public String getLimitType() {
		return limitType;
	}
	public void setLimitType(String limitType) {
		this.limitType = limitType;
	}

	public String getEntityType() {
		return entityType;
	}
	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getCycleType() {
		return cycleType;
	}
	public void setCycleType(String cycleType) {
		this.cycleType = cycleType;
	}

	public String getFeeType() {
		return feeType;
	}
	public void setFeeType(String feeType) {
		this.feeType = feeType;
	}

	public boolean isNeedLengthType() {
		return needLengthType;
	}
	public void setNeedLengthType(boolean needLengthType) {
		this.needLengthType = needLengthType;
	}

	@Override
	public Object getModelId()
	{
		return getId();
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("feeType", this.getFeeType());
		result.put("entityType", this.getEntityType());
		result.put("cycleType", this.getCycleType());
		result.put("limitType", this.getLimitType());
		result.put("lang", this.getLang());
		result.put("shortDesc", this.getShortDesc());
		result.put("fullDesc", this.getFullDesc());
		return result;
	}
}