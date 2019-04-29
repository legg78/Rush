package ru.bpc.sv2.reports;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class OutReportParameter implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Long id;
	private String dataType;
	private String description;
	private Integer displayOrder;
	private Boolean grouping;
	private Boolean sorting;
	private String label;
	private String lang;
	private Long reportId;
	private Integer seqnum;

	@Override
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Integer getDisplayOrder() {
		return displayOrder;
	}

	public void setDisplayOrder(Integer displayOrder) {
		this.displayOrder = displayOrder;
	}

	public Boolean getGrouping() {
		return grouping;
	}

	public void setGrouping(Boolean grouping) {
		this.grouping = grouping;
	}

	public Boolean getSorting() {
		return sorting;
	}

	public void setSorting(Boolean sorting) {
		this.sorting = sorting;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Long getReportId() {
		return reportId;
	}

	public void setReportId(Long reportId) {
		this.reportId = reportId;
	}

	public Integer getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map <String, Object> map = new HashMap<String, Object>();
		map.put("id", getId());
		map.put("dataType", getDataType());
		map.put("description", getDescription());
		map.put("displayOrder", getDisplayOrder());
		map.put("grouping", getGrouping());
		map.put("sorting", getSorting());
		map.put("label", getLabel());
		map.put("lang", getLang());
		map.put("reportId", getReportId());
		
		return map;
	}

}