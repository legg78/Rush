package ru.bpc.sv2.pmo;

import java.io.Serializable;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for List PMO Host tab page.
 */
public class PmoPaymentOrderParameter extends Parameter implements ModelIdentifiable, Serializable, Cloneable
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 9160260928538889903L;
	
	private Long id;
	private Long orderId;
	private Integer paramId;
	private String paramValue;
	private Boolean fixed;
	private Boolean editable;
	
	public PmoPaymentOrderParameter()
	{
	}

	public Object getModelId() {
		return getParamId(); 
	}
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getParamId() {
		return paramId;
	}

	public void setParamId(Integer paramId) {
		this.paramId = paramId;
	}

	public String getParamValue() {
		return paramValue;
	}

	public void setParamValue(String paramValue) {
		this.paramValue = paramValue;
	}

	public Boolean getFixed() {
		return fixed;
	}

	public void setFixed(Boolean fixed) {
		this.fixed = fixed;
	}

	public Boolean getEditable() {
		return editable;
	}

	public void setEditable(Boolean editable) {
		this.editable = editable;
	}

	public Long getOrderId() {
		return orderId;
	}

	public void setOrderId(Long orderId) {
		this.orderId = orderId;
	}

}