package ru.bpc.sv2.ui.process;

import java.io.Serializable;

import ru.bpc.sv2.process.ProcessParameter;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbProcessParameters")
public class MbProcessParameters implements Serializable {
	private static final long serialVersionUID = 1L;

	private ProcessParameter parameter;

	private boolean _modalMode = false;
	private boolean managingNew;
	private String backLink;
	private String tabName;
	private boolean searching;

	public MbProcessParameters() {

	}

	public boolean isModalMode() {
		return _modalMode;
	}

	public void setModalMode(boolean modalMode) {
		_modalMode = modalMode;
	}

	public ProcessParameter getParameter() {
		if (parameter == null) {
			parameter = new ProcessParameter();
		}
		return parameter;
	}

	public void setParameter(ProcessParameter parameter) {
		this.parameter = parameter;
	}

	public boolean isManagingNew() {
		return managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		this.managingNew = managingNew;
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

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
}
