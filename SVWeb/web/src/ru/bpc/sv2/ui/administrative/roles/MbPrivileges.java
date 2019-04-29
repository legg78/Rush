package ru.bpc.sv2.ui.administrative.roles;

import java.io.Serializable;

import ru.bpc.sv2.administrative.roles.Privilege;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean(name = "MbPrivileges")
public class MbPrivileges implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Privilege priv;
	private boolean managingNew;
	private boolean modalMode = true;
	private String backLink;
	private boolean searching;
	private String tabName;

	public MbPrivileges() {
	}

	public Privilege getPriv() {
		return priv;
	}

	public void setPriv(Privilege priv) {
		this.priv = priv;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void cancel() {
		priv = null;
	}

	public boolean isManagingNew() {
		return managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		this.managingNew = managingNew;
	}

	public boolean isModalMode() {
		return modalMode;
	}

	public void setModalMode(boolean modalMode) {
		this.modalMode = modalMode;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}
}
