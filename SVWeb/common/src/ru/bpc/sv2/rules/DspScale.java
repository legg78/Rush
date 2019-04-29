package ru.bpc.sv2.rules;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * BPC Group 2017 (c) All Rights Reserved
 */
public class DspScale implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqnum;
	private String scaleType;
	private String label;
	private String description;
	private Integer modId;
	private String modName;
	private String lang;
	private Integer initRuleId;
	private String initRuleName;
	
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public String getScaleType() {
		return scaleType;
	}

	public void setScaleType(String scaleType) {
		this.scaleType = scaleType;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Integer getModId() {
		return modId;
	}

	public void setModId(Integer modId) {
		this.modId = modId;
	}

	public String getModName() {
		return modName;
	}

	public void setModName(String modName) {
		this.modName = modName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	@Override
	public Object getModelId() {
		return getId();
	}

	public Integer getInitRuleId() {
		return initRuleId;
	}

	public void setInitRuleId(Integer initRuleId) {
		this.initRuleId = initRuleId;
	}

	public String getInitRuleName() {
		return initRuleName;
	}

	public void setInitRuleName(String initRuleName) {
		this.initRuleName = initRuleName;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		return (new HashMap<String, Object>() {{
			put("id", getId());
			put("seqnum", getSeqnum());
			put("scaleType", getScaleType());
			put("label", getLabel());
			put("description", getDescription());
			put("modId", getModId());
			put("modName", getModName());
			put("lang", getLang());
			put("initRuleId", getInitRuleId());
			put("initRuleName", getInitRuleName());
		}});
	}

	@Override
	public String toString() {
		return "DspScale{" +
				"id=" + id +
				", seqnum=" + seqnum +
				", scaleType='" + scaleType + '\'' +
				", label='" + label + '\'' +
				", description='" + description + '\'' +
				", modId=" + modId +
				", modName='" + modName + '\'' +
				", lang='" + lang + '\'' +
				", initRuleId=" + initRuleId +
				", initRuleName='" + initRuleName + '\'' +
				'}';
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
}
