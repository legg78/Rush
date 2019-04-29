package ru.bpc.sv2.reports;

import java.io.Serializable;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ReportRunParameter extends Parameter implements ModelIdentifiable, Serializable, Cloneable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Long runId;
	private Integer parameterId;
	
	public Object getModelId() {
		return getId();		
	}
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getRunId() {
		return runId;
	}

	public void setRunId(Long runId) {
		this.runId = runId;
	}

	public Integer getParameterId() {
		return parameterId;
	}

	public void setParameterId(Integer parameterId) {
		this.parameterId = parameterId;
	}
	
	@Override
	public ReportRunParameter clone() throws CloneNotSupportedException {
		return (ReportRunParameter)super.clone();
	}
}
