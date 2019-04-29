package ru.bpc.sv2.fraud;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class SuiteCase implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer suiteId;
	private Integer caseId;
	private Integer priority;
	private String suiteName;
	private String caseName;
	private String lang;
	
	public Object getModelId() {
		return suiteId + "_" + caseId;
	}

	public Integer getSuiteId() {
		return suiteId;
	}

	public void setSuiteId(Integer suiteId) {
		this.suiteId = suiteId;
	}

	public Integer getCaseId() {
		return caseId;
	}

	public void setCaseId(Integer caseId) {
		this.caseId = caseId;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public String getSuiteName() {
		return suiteName;
	}

	public void setSuiteName(String suiteName) {
		this.suiteName = suiteName;
	}

	public String getCaseName() {
		return caseName;
	}

	public void setCaseName(String caseName) {
		this.caseName = caseName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("suiteId", this.getSuiteId());
		result.put("caseId", this.getCaseId());
		result.put("priority", this.getPriority());
		
		return result;
	}
}
