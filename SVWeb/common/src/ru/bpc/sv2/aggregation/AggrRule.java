package ru.bpc.sv2.aggregation;

import ru.bpc.sv2.ModuleItem;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

public class AggrRule extends ModuleItem implements Serializable, ModelIdentifiable {
	private long aggrTypeId;
	private long paramId;
	private String aggrType;
	private String rounding;

	public long getAggrTypeId() {
		return aggrTypeId;
	}

	public void setAggrTypeId(long aggrTypeId) {
		this.aggrTypeId = aggrTypeId;
	}

	public long getParamId() {
		return paramId;
	}

	public void setParamId(long paramId) {
		this.paramId = paramId;
	}

	public String getAggrType() {
		return aggrType;
	}

	public void setAggrType(String aggrType) {
		this.aggrType = aggrType;
	}

	public String getRounding() {
		return rounding;
	}

	public void setRounding(String rounding) {
		this.rounding = rounding;
	}
}
