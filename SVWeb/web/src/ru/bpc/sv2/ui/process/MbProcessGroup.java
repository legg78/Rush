package ru.bpc.sv2.ui.process;

import java.io.Serializable;

import ru.bpc.sv2.process.ProcessGroup;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbProcessGroup")
public class MbProcessGroup implements Serializable {

	private static final long serialVersionUID = 1L;

	private ProcessGroup group;

	private boolean modalMode = true;
	private String backLink;
	private boolean selectMode;
	private boolean managingNew;
	private boolean searching;
	private String tabName;

	public MbProcessGroup() {

	}

	public void close() {

	}

	public ProcessGroup getGroup() {
		if (group == null) {
			group = new ProcessGroup();
		}
		return group;
	}

	public void setGroup(ProcessGroup group) {
		this.group = group;
	}

	public boolean isModalMode() {
		return modalMode;
	}

	public void setModalMode(boolean modalMode) {
		this.modalMode = modalMode;
	}

	public void clearState() {

	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
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

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void cancel() {

	}
}
