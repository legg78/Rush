package ru.bpc.sv2.application;

import java.io.Serializable;

import java.util.List;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.TreeIdentifiable;

public class ApplicationFlowFilterStruct extends Parameter implements ModelIdentifiable, TreeIdentifiable<ApplicationFlowFilterStruct>, Serializable {

	/**
	 *
	 */
	private static final long serialVersionUID = -4991241886310869900L;
	private Long id;
	private Long parentId;
	
	private String defaultValue;
	private String appType;
	private Integer stId;
	
	private Integer maxCount;
	private Integer minCount;
	private Boolean visible;
	private Boolean updatable;
	private Boolean insertable;
		
	private Integer stageId;
	private Integer flowFilterId;
	private Integer flowFilterSeqnum;
	
	private int level;
	private boolean isLeaf;
	private List<ApplicationFlowFilterStruct> children;
	
	private boolean minMaxError;
	
	public ApplicationFlowFilterStruct()
	{
	}
	
	public Long getParentId() {
		return parentId;
	}
	public void setParentId(Long parentId) {
		this.parentId = parentId;
		modelId = null;
	}
	public String getAppType() {
		return appType;
	}
	public void setAppType(String appType) {
		this.appType = appType;
	}

	public List<ApplicationFlowFilterStruct> getChildren() {
		return children;
	}
	public void setChildren(List<ApplicationFlowFilterStruct> children) {
		this.children = children;
	}
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
		modelId = null;
	}

	public String getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	private String modelId = null;
	
	public Object getModelId()
	{
		if (modelId == null){
			modelId = getId().toString();
			if (getParentId() != null){
				modelId += getParentId();
			}
		}
		return modelId;
	}

	@Override
	public boolean equals( Object obj )
	{
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		ApplicationFlowFilterStruct other = (ApplicationFlowFilterStruct) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;		
		
		return true;
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

	public Integer getStId() {
		return stId;
	}

	public void setStId(Integer stId) {
		this.stId = stId;
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

	public Boolean getInsertable() {
		return insertable;
	}

	public void setInsertable(Boolean insertable) {
		this.insertable = insertable;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result
				+ ((parentId == null) ? 0 : parentId.hashCode());
		result = prime * result + ((stId == null) ? 0 :stId);
		return result;
	}

	
	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public boolean isLeaf() {
		return isLeaf;
	}

	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	public Integer getFlowFilterId() {
		return flowFilterId;
	}

	public void setFlowFilterId(Integer flowFilterId) {
		this.flowFilterId = flowFilterId;
	}

	public Integer getFlowFilterSeqnum() {
		return flowFilterSeqnum;
	}

	public void setFlowFilterSeqnum(Integer flowFilterSeqnum) {
		this.flowFilterSeqnum = flowFilterSeqnum;
	}

	public Integer getStageId() {
		return stageId;
	}

	public void setStageId(Integer stageId) {
		this.stageId = stageId;
	}

	/**
	 * Copy this object values to target object except children.
	 * @param target
	 */
	public void copyTo(ApplicationFlowFilterStruct target){
		target.setId(id);
		target.setParentId(parentId);
		target.setStId(stId);
		target.setAppType(appType);
		target.setDefaultValue(defaultValue);
		target.setMaxCount(maxCount);
		target.setMinCount(minCount);
		target.setVisible(visible);
		target.setUpdatable(updatable);
		target.setInsertable(insertable);
		target.setStageId(stageId);
		target.setFlowFilterId(flowFilterId);
		target.setFlowFilterSeqnum(flowFilterSeqnum);
		target.setLeaf(isLeaf);
		target.setLevel(level);
		target.setValue(getValue());
		target.setValueD(valueD);
		target.setValueN(valueN);
		target.setValueV(valueV);
		target.setLovId(getLovId());
		target.setLovValue(getLovValue());
	}

	public boolean isMinMaxError() {
		return minMaxError;
	}

	public void setMinMaxError(boolean minMaxError) {
		this.minMaxError = minMaxError;
	}
	
	@Override
	public String toString() {
		String result = String.format("[name:\"%s\", id:%d]", getName(), getId());
		return result;
	}
}

