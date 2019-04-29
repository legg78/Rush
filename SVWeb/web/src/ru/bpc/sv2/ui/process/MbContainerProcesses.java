package ru.bpc.sv2.ui.process;

import java.io.Serializable;

import ru.bpc.sv2.process.ProcessBO;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbContainerProcesses")
public class MbContainerProcesses implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private ProcessBO process;
	
	private ProcessBO savedFilter;
	private ProcessBO savedActiveProcess;
	private ProcessBO savedNewProcess;
	private String savedBackLink;
	private int savedCurMode;
	private boolean searching;
	
	private boolean keepState;
	
	private int curMode;
	public final static int MODE_CONTAINER = 0;
	public final static int MODE_SELECT_PROCESS = 1;

	public MbContainerProcesses()
	{
		
	}

	public int getCurMode() {
		return curMode;
	}

	public void setCurMode(int curMode) {
		this.curMode = curMode;
	}
	
	public boolean isKeepState() {
		return keepState;
	}

	public void setKeepState(boolean keepState) {
		this.keepState = keepState;
	}

	public ProcessBO getProcessParam() {
		if (process == null)
			process = new ProcessBO();
		return process;
	}

	
	
	public ProcessBO getSavedFilter() {
		return savedFilter;
	}

	public void setSavedFilter(ProcessBO savedFilter) {
		this.savedFilter = savedFilter;
	}

	public ProcessBO getSavedActiveProcess() {
		return savedActiveProcess;
	}

	public void setSavedActiveProcess(ProcessBO savedActiveProcess) {
		this.savedActiveProcess = savedActiveProcess;
	}

	public String getSavedBackLink() {
		return savedBackLink;
	}

	public void setSavedBackLink(String savedBackLink) {
		this.savedBackLink = savedBackLink;
	}

	public ProcessBO getSavedNewProcess() {
		return savedNewProcess;
	}

	public void setSavedNewProcess(ProcessBO savedNewProcess) {
		this.savedNewProcess = savedNewProcess;
	}

	public int getSavedCurMode() {
		return savedCurMode;
	}

	public void setSavedCurMode(int savedCurMode) {
		this.savedCurMode = savedCurMode;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}
	
}
