package ru.bpc.sv2.ui.acquiring;

import java.io.Serializable;
import java.util.List;

import ru.bpc.sv2.acquiring.Terminal;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbTerminalSess")
public class MbTerminalSess implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Terminal activeTerminal;
	private Terminal filter;
	private String tabName;
	private Long accountId;
	private String backLink;
	private boolean selectMode;
	private int rowsNum;
	private int pageNumber;
	
	private List<Terminal> terminalsList;

	public Terminal getActiveTerminal() {
		return activeTerminal;
	}

	public void setActiveTerminal(Terminal activeTerminal) {
		this.activeTerminal = activeTerminal;
	}

	public Terminal getFilter() {
		return filter;
	}

	public void setFilter(Terminal filter) {
		this.filter = filter;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public Long getAccountId() {
		return accountId;
	}

	public void setAccountId(Long accountId) {
		this.accountId = accountId;
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

	public List<Terminal> getTerminalsList() {
		return terminalsList;
	}

	public void setTerminalsList(List<Terminal> terminalsList) {
		this.terminalsList = terminalsList;
	}
}
