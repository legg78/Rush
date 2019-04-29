package ru.bpc.sv2.acm;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ComponentState implements Serializable, ModelIdentifiable, Cloneable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Long userId;
	private String componentId;
	private String state;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getUserId() {
		return userId;
	}

	public void setUserId(Long userId) {
		this.userId = userId;
	}

	public String getComponentId() {
		return componentId;
	}

	public void setComponentId(String componentId) {
		this.componentId = componentId;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public Object getModelId() {
		return getId();
	}

	@Override
	public ComponentState clone() throws CloneNotSupportedException {
		return (ComponentState) super.clone();
	}

}
