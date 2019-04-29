package ru.bpc.sv2.configuration;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

public class KeyValuePair implements Serializable, ModelIdentifiable {
	private String key;
	private String value;
	private boolean show=true;

	public String getKey() {
		return key;
	}

	public KeyValuePair(String key, String value) {
		this.key = key;
		this.value = value;
	}

	public KeyValuePair() {
	}

	public void setKey(String key) {
		this.key = key;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public boolean isShow() {
		return show;
	}

	public void setShow(boolean show) {
		this.show = show;
	}

	@Override
	public Object getModelId() {
		return key;
	}
}
