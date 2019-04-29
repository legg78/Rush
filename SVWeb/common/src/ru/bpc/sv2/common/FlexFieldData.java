package ru.bpc.sv2.common;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class FlexFieldData extends FlexField implements Serializable, ModelIdentifiable{

	/**
	 *
	 */
	private static final long serialVersionUID = 5172755069072541747L;
	private Long dataId;
	private Integer fieldId;
	private Long objectId;
	private String fieldValue;
	private FlexFieldData childEntityFilter;
	
	public Long getDataId() {
		return dataId;
	}

	public void setDataId(Long dataId) {
		this.dataId = dataId;
	}
		
	public Integer getFieldId() {
		return fieldId;
	}

	public void setFieldId(Integer fieldId) {
		this.fieldId = fieldId;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getFieldValue() {
		return fieldValue;
	}

	public void setFieldValue(String fieldValue) {
		this.fieldValue = fieldValue;
	}

	@Override
	public Object getModelId() {
		return getDataId()+"_" + getFieldId();
	}

	public FlexFieldData getChildEntityFilter() {
		return childEntityFilter;
	}

	public void setChildEntityFilter(FlexFieldData childObjectFilter) {
		this.childEntityFilter = childObjectFilter;
	}

}
