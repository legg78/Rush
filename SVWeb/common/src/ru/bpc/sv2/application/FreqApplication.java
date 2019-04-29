package ru.bpc.sv2.application;

public class FreqApplication extends Application implements Cloneable {
	private String operType;
	private String operReason;

	public String getOperReason() {
		return operReason;
	}
	public void setOperReason(String operReason) {
		this.operReason = operReason;
	}

	public String getOperType() {
		return operType;
	}
	public void setOperType(String operType) {
		this.operType = operType;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
}
