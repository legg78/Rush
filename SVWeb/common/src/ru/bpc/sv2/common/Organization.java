package ru.bpc.sv2.common;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

@Deprecated
public class Organization implements Serializable, ModelIdentifiable, Cloneable{
	private static final long serialVersionUID = 1L;

	private Integer id;
	private String name;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Override
	public Organization clone() throws CloneNotSupportedException {
		return (Organization)super.clone();
	}

}
