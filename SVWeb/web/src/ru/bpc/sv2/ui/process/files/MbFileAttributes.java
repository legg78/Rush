package ru.bpc.sv2.ui.process.files;

import java.io.Serializable;

import ru.bpc.sv2.process.ProcessFileAttribute;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbFileAttributes")
public class MbFileAttributes implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private ProcessFileAttribute fileAttribute;
	private String tabName;
	private String backLink;
	private boolean _modalMode = false;
	private boolean managingNew;
	private boolean searching;

	public MbFileAttributes() {
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public boolean isModalMode() {
		return _modalMode;
	}

	public void setModalMode(boolean modalMode) {
		_modalMode = modalMode;
	}

	public ProcessFileAttribute getFileAttribute() {
		if (fileAttribute == null)
			fileAttribute = new ProcessFileAttribute();
		return fileAttribute;
	}

	public void setFileAttribute(ProcessFileAttribute process) {
		this.fileAttribute = process;
	}

	public boolean isManagingNew() {
		return managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		this.managingNew = managingNew;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public void create() {
		managingNew = true;
		fileAttribute = new ProcessFileAttribute();
	}

	public void editProcess() {
		managingNew = false;
	}
}
