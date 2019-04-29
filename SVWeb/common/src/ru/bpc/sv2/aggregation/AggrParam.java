package ru.bpc.sv2.aggregation;

import ru.bpc.sv2.ModuleItem;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

public class AggrParam extends ModuleItem implements Serializable, ModelIdentifiable {
	private String name;
	private String table;
	private String field;
	private String type;
	private Long parentId;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getTable() {
		return table;
	}

	public void setTable(String table) {
		this.table = table;
	}

	public String getField() {
		return field;
	}

	public void setField(String field) {
		this.field = field;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}
}
