package ru.bpc.sv2.ui.process;

import java.io.Serializable;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.ui.utils.AbstractBean;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.bean.ViewScoped;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbProcesses")
public class MbProcesses extends AbstractBean {
	private static final long serialVersionUID = 1L;
	
	private ProcessBO process;
	private String tabName;
	private String backLink;
	private boolean _modalMode = false;
	private boolean managingNew;
	private boolean searching;
	private ProcessBO savedFilter;
	private int rowsNum;
	private int pageNumber;
	
	private boolean keepState;
	
	public MbProcesses() {
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

	public ProcessBO getProcess() {
		if (process == null)
			process = new ProcessBO();
		return process;
	}

	public void setProcess(ProcessBO process) {
		this.process = process;
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

	public ProcessBO getSavedFilter() {
		return savedFilter;
	}

	public void setSavedFilter(ProcessBO savedFilter) {
		this.savedFilter = savedFilter;
	}

	public boolean isKeepState() {
		return keepState;
	}

	public void setKeepState(boolean keepState) {
		this.keepState = keepState;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public int getPageNumber() {
		return pageNumber;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}

    @Override
    public void clearFilter() {
        // do nothing
    }

}
