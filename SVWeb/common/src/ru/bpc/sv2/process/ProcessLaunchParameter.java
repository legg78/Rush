package ru.bpc.sv2.process;

import java.io.Serializable;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProcessLaunchParameter extends Parameter implements Serializable, ModelIdentifiable, Cloneable {

	private static final long serialVersionUID = 1L;
	
	private Long id;
	private Long sessionId;
	private Integer paramId;
	private String paramName;
	private String paramValue;
	
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Long getSessionId() {
		return sessionId;
	}
	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}
	public Integer getParamId() {
		return paramId;
	}
	public void setParamId(Integer paramId) {
		this.paramId = paramId;
	}
	public String getParamName() {
		return paramName;
	}
	public void setParamName(String paramName) {
		this.paramName = paramName;
	}
	public String getParamValue() {
		return paramValue;
	}
	public void setParamValue(String paramValue) {
		this.paramValue = paramValue;
	}
	public Object getModelId() {
		return getId();
	}
	
}