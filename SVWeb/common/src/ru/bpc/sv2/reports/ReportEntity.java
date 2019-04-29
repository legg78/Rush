package ru.bpc.sv2.reports;

import java.io.Serializable;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ReportEntity implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject{
	private Integer id;
	private String entityType;
	private String objectType;
	private Integer seqNum;
	private Integer reportId;
	
	@Override
	public Object getModelId() {
		return getId();
	}
	
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Integer getReportId() {
		return reportId;
	}

	public void setReportId(Integer reportId) {
		this.reportId = reportId;
	}
	
	public boolean isAnyObjectType(){
		return objectType.equals("%");
	}
	
	@Override
	public Map<String, Object> getAuditParameters() {
		// TODO Auto-generated method stub
		return null;
	}
}
