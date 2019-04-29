package ru.bpc.sv2.ui.common;

import java.io.Serializable;

import ru.bpc.sv2.common.Address;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbAddress")
// TODO: do we need this?
public class MbAddress implements Serializable {
	private static final long serialVersionUID = 1L;

	private Address address;

	private Long objectId;
	private String entityType;
	private String curLang;
	private String defaultLang;

	public MbAddress() {
	}

	public Address getAddress() {
		return address;
	}

	public void setAddress(Address address) {
		this.address = address;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getCurLang() {
		return curLang;
	}

	public void setCurLang(String curLang) {
		this.curLang = curLang;
	}

	public String getDefaultLang() {
		return defaultLang;
	}

	public void setDefaultLang(String defaultLang) {
		this.defaultLang = defaultLang;
	}

	public void clearState() {
		objectId = null;
		address = null;
	}
}
