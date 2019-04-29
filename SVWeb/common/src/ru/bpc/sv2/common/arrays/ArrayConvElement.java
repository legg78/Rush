package ru.bpc.sv2.common.arrays;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ArrayConvElement implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer convId;
	private String inElementValue;
	private String outElementValue;
	private String inValue;
	private String outValue;

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getConvId() {
		return convId;
	}

	public void setConvId(Integer convId) {
		this.convId = convId;
	}

	public String getInElementValue() {
		return inElementValue;
	}

	public void setInElementValue(String inElementValue) {
		this.inElementValue = inElementValue;
	}

	public String getOutElementValue() {
		return outElementValue;
	}

	public void setOutElementValue(String outElementValue) {
		this.outElementValue = outElementValue;
	}

	public Object getModelId() {
		return getId();
	}

	public String getInValue() {
		return inValue;
	}

	public void setInValue(String inValue) {
		this.inValue = inValue;
	}

	public String getOutValue() {
		return outValue;
	}

	public void setOutValue(String outValue) {
		this.outValue = outValue;
	}

	@Override
	public ArrayConvElement clone() throws CloneNotSupportedException {
		return (ArrayConvElement) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("inElementValue", this.getInElementValue());
		result.put("outElementValue", this.getOutElementValue());
		
		return result;
	}

}
