package ru.bpc.sv2.audit;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AuditableObject implements ModelIdentifiable, Serializable, Cloneable {

	private static final long serialVersionUID = 1L;

	private String entityType;
	private String tableName;
	private Boolean active;
	private Boolean activeNew;
	private String name;

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getTableName() {
		return tableName;
	}

	public void setTableName(String tableName) {
		this.tableName = tableName;
	}

	public Boolean getActive() {
		return active;
	}

	public void setActive(Boolean active) {
		this.active = active;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public static long getSerialversionuid() {
		return serialVersionUID;
	}

	public Object getModelId() {
		return getEntityType();
	}

	public Boolean getActiveNew() {
		return activeNew;
	}

	public void setActiveNew(Boolean activeNew) {
		this.activeNew = activeNew;
	}

	@Override
	public AuditableObject clone() throws CloneNotSupportedException {
		return (AuditableObject)super.clone();
	}
}
