package ru.bpc.sv2.ui.common;

import java.io.Serializable;

import ru.bpc.sv2.common.Contact;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbContact")
public class MbContact implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Contact contact;
	private Contact newContact;
	private Long objectId;
	private Long personId;
	private String entityType;
	private String backLink;
	private boolean personNeeded = false;
	private int curMode;
	private String contactPanelName;

	public MbContact() {
	}

	public Contact getContact() {
		return contact;
	}

	public void setContact(Contact contact) {
		this.contact = contact;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public Long getPersonId() {
		return personId;
	}

	public void setPersonId(Long personId) {
		this.personId = personId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public void clearState() {
		objectId = null;
		personNeeded = false;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isPersonNeeded() {
		return personNeeded;
	}

	public void setPersonNeeded(boolean personNeeded) {
		this.personNeeded = personNeeded;
	}

	public String getContactPanelName() {
		return contactPanelName;
	}

	public void setContactPanelName(String contactPanelName) {
		this.contactPanelName = contactPanelName;
	}

	public int getCurMode() {
		return curMode;
	}

	public void setCurMode(int curMode) {
		this.curMode = curMode;
	}

	public Contact getNewContact() {
		return newContact;
	}

	public void setNewContact(Contact newContact) {
		this.newContact = newContact;
	}

}
