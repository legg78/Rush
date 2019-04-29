package ru.bpc.sv2.fcl.limits;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class LimitType
	implements IAuditableObject, ModelIdentifiable, Serializable, Cloneable
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 323402049380004460L;
	private Integer id;
	private String seqnum;
	private String limitType;
	private String entityType;
	private String cycleType;
	private boolean internal;
	private String shortDesc;
	private String fullDesc;
	private String lang;
	
	
	public LimitType()
	{
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

	public Integer getId() {
		return id;
	}


	public void setId(Integer id) {
		this.id = id;
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


	public boolean isInternal() {
		return internal;
	}


	public void setInternal(boolean internal) {
		this.internal = internal;
	}


	public Object getModelId()
	{
		return getId();
	}
	
	@Override
	public LimitType clone() throws CloneNotSupportedException{
		return (LimitType)super.clone();
	}


	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("limitType", getLimitType());
		result.put("cycleType", getCycleType());
		result.put("entityType", getEntityType());
		result.put("internal", isInternal());
		result.put("shortDesc", getShortDesc());
		result.put("fullDesc", getFullDesc());
		result.put("lang", getLang());
		return result;
	}
}