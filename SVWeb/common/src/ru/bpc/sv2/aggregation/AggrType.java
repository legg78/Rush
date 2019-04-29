package ru.bpc.sv2.aggregation;

import ru.bpc.sv2.ModuleItem;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

public class AggrType extends ModuleItem implements Serializable, ModelIdentifiable {
	private String name;
	private String description;
	private String condition;
	private int networkId;

	public int getNetworkId() {
		return networkId;
	}

	public void setNetworkId(int networkId) {
		this.networkId = networkId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getCondition() {
		return condition;
	}

	public void setCondition(String condition) {
		this.condition = condition;
	}
}
