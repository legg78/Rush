package ru.bpc.sv2;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

public class ModuleItem implements Serializable, ModelIdentifiable {
	protected Long id;
	protected String module;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getModule() {
		return module;
	}

	public void setModule(String module) {
		this.module = module;
	}


	@Override
	public Object getModelId() {
		return id;
	}
}
