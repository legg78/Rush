package ru.bpc.sv2.ui.process;

import java.io.Serializable;

import ru.bpc.sv2.process.ProcessParameter;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbProcessParams")
public class MbProcessParams implements Serializable {
	private static final long serialVersionUID = 1L;

	private ProcessParameter processParam;

	private ProcessParameter savedFilter;
	private ProcessParameter savedActiveParameter;
	private String savedBackLink;
	private ProcessParameter savedNewParameter;
	private int savedCurMode;
	private boolean searching;

	private int curMode;
	public final static int MODE_PROCESS = 0;
	public final static int MODE_SELECT_PARAM = 1;

	public MbProcessParams() {
	}

	public int getCurMode() {
		return curMode;
	}

	public void setCurMode(int curMode) {
		this.curMode = curMode;
	}

	public ProcessParameter getProcessParam() {
		if (processParam == null)
			processParam = new ProcessParameter();
		return processParam;
	}

	public void setProcessParam(ProcessParameter processParam) {
		this.processParam = processParam;
	}

	public ProcessParameter getSavedFilter() {
		return savedFilter;
	}

	public void setSavedFilter(ProcessParameter savedFilter) {
		this.savedFilter = savedFilter;
	}

	public ProcessParameter getSavedActiveParameter() {
		return savedActiveParameter;
	}

	public void setSavedActiveParameter(ProcessParameter savedActiveParameter) {
		this.savedActiveParameter = savedActiveParameter;
	}

	public String getSavedBackLink() {
		return savedBackLink;
	}

	public void setSavedBackLink(String savedBackLink) {
		this.savedBackLink = savedBackLink;
	}

	public ProcessParameter getSavedNewParameter() {
		return savedNewParameter;
	}

	public void setSavedNewParameter(ProcessParameter savedNewParameter) {
		this.savedNewParameter = savedNewParameter;
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
