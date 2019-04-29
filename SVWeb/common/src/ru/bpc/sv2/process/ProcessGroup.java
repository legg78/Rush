package ru.bpc.sv2.process;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProcessGroup implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private String name;
	private String description;
	private String lang;
	private String semaphoreName;
	private Boolean blockRun;
	private Boolean checkResult;
	private boolean force;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getSemaphoreName() {
		return semaphoreName;
	}

	public void setSemaphoreName(String semaphoreName) {
		this.semaphoreName = semaphoreName;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
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

	public boolean isForce() {
		return force;
	}

	public void setForce(boolean force) {
		this.force = force;
	}
	
	public Boolean getBlockRun() {
		return blockRun;
	}

	public void setBlockRun(Boolean blockRun) {
		this.blockRun = blockRun;
	}

	public Boolean getCheckResult() {
		return checkResult;
	}

	public void setCheckResult(Boolean checkResult) {
		this.checkResult = checkResult;
	}

	@Override
	public ProcessGroup clone() throws CloneNotSupportedException {
		return (ProcessGroup)super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("semaphoreName", getSemaphoreName());
		result.put("name", getName());
		result.put("description", getDescription());
		result.put("lang", getLang());
		return result;
	}
}
