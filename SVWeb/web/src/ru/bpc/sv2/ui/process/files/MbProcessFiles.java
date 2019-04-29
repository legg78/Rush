package ru.bpc.sv2.ui.process.files;

import java.io.Serializable;

import ru.bpc.sv2.process.ProcessFile;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbProcessFiles")
public class MbProcessFiles implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private ProcessFile processFile;
	private String tabName;
	private String backLink;
	private boolean _modalMode = false;
	private boolean managingNew;
	private boolean searching;

	public MbProcessFiles() {
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

	public ProcessFile getProcessFile() {
		if (processFile == null)
			processFile = new ProcessFile();
		return processFile;
	}

	public void setProcessFile(ProcessFile processFile) {
		this.processFile = processFile;
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
		processFile = new ProcessFile();
	}

	public void editProcess() {
		managingNew = false;
	}
}
