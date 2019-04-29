package ru.bpc.sv2.ui.operations;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.operations.Operation;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbOperationsSess")
public class MbOperationsSess implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Operation filter;
	private Operation activeOperation;
	private int pageNumber;
	private int rowsNum;
	private String tabName;
	private String operType;
	private Date hostDateFrom;
	private Date hostDateTo;
	private String entryId;
	
	public Operation getActiveOperation() {
		return activeOperation;
	}
	
	public void setActiveOperation(Operation activeOperation) {
		this.activeOperation = activeOperation;
	}

	public Operation getFilter() {
		return filter;
	}

	public void setFilter(Operation filter) {
		this.filter = filter;
	}

	public int getPageNumber() {
		return pageNumber;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public Date getHostDateFrom() {
		return hostDateFrom;
	}

	public void setHostDateFrom(Date hostDateFrom) {
		this.hostDateFrom = hostDateFrom;
	}

	public Date getHostDateTo() {
		return hostDateTo;
	}

	public void setHostDateTo(Date hostDateTo) {
		this.hostDateTo = hostDateTo;
	}

	public String getEntryId() {
		return entryId;
	}

	public void setEntryId(String entryId) {
		this.entryId = entryId;
	}
}
