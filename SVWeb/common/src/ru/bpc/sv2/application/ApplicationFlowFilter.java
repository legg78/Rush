package ru.bpc.sv2.application;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ApplicationFlowFilter extends Parameter implements ModelIdentifiable, Serializable, IAuditableObject {

	/**
	 *
	 */
	private static final long serialVersionUID = -4991241886310869900L;
	private Integer id;
	private Integer structId;
	private Integer stageId;
	private String defaultValue;
	private Integer maxCount;
	private Integer minCount;
	private Boolean visible;
	private Boolean updatable;
	private Boolean insertable;
	
	private Integer instId;
	private Integer flowId;
		
	public ApplicationFlowFilter()
	{
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public Integer getMaxCount() {
		return maxCount;
	}

	public void setMaxCount(Integer maxCount) {
		this.maxCount = maxCount;
	}

	public Integer getMinCount() {
		return minCount;
	}

	public void setMinCount(Integer minCount) {
		this.minCount = minCount;
	}

	public Boolean getVisible() {
		return visible;
	}

	public void setVisible(Boolean visible) {
		this.visible = visible;
	}

	public Boolean getUpdatable() {
		return updatable;
	}

	public void setUpdatable(Boolean updatable) {
		this.updatable = updatable;
	}

	public Integer getStructId() {
		return structId;
	}

	public void setStructId(Integer structId) {
		this.structId = structId;
	}

	public Integer getStageId() {
		return stageId;
	}

	public void setStageId(Integer stageId) {
		this.stageId = stageId;
	}

	public Boolean getInsertable() {
		return insertable;
	}

	public void setInsertable(Boolean insertable) {
		this.insertable = insertable;
	}

	public Object getModelId() {
		return getId();
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getFlowId() {
		return flowId;
	}

	public void setFlowId(Integer flowId) {
		this.flowId = flowId;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("visible", this.getVisible());
		result.put("updatable", this.getUpdatable());
		result.put("insertable", this.getInsertable());
		result.put("minCount", this.getMinCount());
		result.put("maxCount", this.getMaxCount());
		result.put("valueV", this.getValueV());
		result.put("valueN", this.getValueN());
		result.put("valueD", this.getValueD());
		
		return result;
	}
	
}

