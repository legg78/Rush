package ru.bpc.sv2.process.filereader;

public class FlatFileItem {

	private String recordName;
	private String recordText;
	private Object bean;
	private Class<?> beanType;

	public FlatFileItem(String recordName, String recordText, Object bean, Class<?> beanType) {
		this.recordName = recordName;
		this.recordText = recordText;
		this.bean = bean;
		this.beanType = beanType;
	}

	public String getRecordName() {
		return recordName;
	}

	public void setRecordName(String recordName) {
		this.recordName = recordName;
	}

	public String getRecordText() {
		return recordText;
	}

	public void setRecordText(String recordText) {
		this.recordText = recordText;
	}

	public Object getBean() {
		return bean;
	}

	public void setBean(Object bean) {
		this.bean = bean;
	}

	public Class<?> getBeanType() {
		return beanType;
	}

	public void setBeanType(Class<?> beanType) {
		this.beanType = beanType;
	}
}
