package ru.bpc.sv2.application;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ApplicationType implements Serializable, ModelIdentifiable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 7798903626420733465L;
	private String appType;
	
	public String getAppType() {
		return appType;
	}
	public void setAppType(String appType) {
		this.appType = appType;
	}
	public Object getModelId()
	{
		return getAppType();
	}
}
