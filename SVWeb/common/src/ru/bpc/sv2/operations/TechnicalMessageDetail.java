package ru.bpc.sv2.operations;

import java.io.Serializable;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class TechnicalMessageDetail extends Parameter implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long operId;
	private String techId;
	private Integer columnLevel;
	private String dictCode;
	private Integer columnOrder;
	
	public Object getModelId() {
		return getTechId() + getOperId() + getColumnOrder();		
	}
	
	public Long getOperId() {
		return operId;
	}
	public void setOperId(Long operId) {
		this.operId = operId;
	}
	public String getTechId() {
		return techId;
	}
	public void setTechId(String techId) {
		this.techId = techId;
	}
	public String getDictCode() {
		return dictCode;
	}
	public void setDictCode(String dictCode) {
		this.dictCode = dictCode;
	}
	
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
 
	public Integer getColumnLevel() {
		return columnLevel;
	}
	public void setColumnLevel(Integer columnLevel) {
		this.columnLevel = columnLevel;
	}

	public Integer getColumnOrder() {
		return columnOrder;
	}
	
	public void setColumnOrder(Integer columnOrder) {
		this.columnOrder = columnOrder;
	}
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
}
