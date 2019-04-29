package ru.bpc.sv2.common.arrays;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ArrayElement extends Parameter implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer arrayId;
	private Integer elementNumber;
		
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getArrayId() {
		return arrayId;
	}

	public void setArrayId(Integer arrayId) {
		this.arrayId = arrayId;
	}
	
	public Integer getElementNumber() {
		return elementNumber;
	}

	public void setElementNumber(Integer elementNumber) {
		this.elementNumber = elementNumber;
	}

	public Object getModelId() {
		return getId();
	}

	@Override
	public ArrayElement clone() throws CloneNotSupportedException {
		return (ArrayElement) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("valueV", this.getValueV());
		result.put("valueN", this.getValueN());
		result.put("valueD", this.getValueD());
		result.put("elementNumber", this.getElementNumber());
		result.put("lovId", this.getLovId());
		result.put("name", this.getName());
		result.put("description", this.getDescription());
		
		return result;
	}

}
