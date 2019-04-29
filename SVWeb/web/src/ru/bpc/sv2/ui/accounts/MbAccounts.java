package ru.bpc.sv2.ui.accounts;

import java.io.Serializable;

import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.AccountGL;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbAccounts")
public class MbAccounts implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private AccountGL glFilter;
	private AccountGL activeGLAccount;
	private String glBackLink;
	private String glTabName;
	private int glRowsNum;
	private int glPageNumber;
	
	private Account filter;
	private Account activeAccount;
	private String backLink;
	private String tabName;
	private int rowsNum;
	private int pageNumber;
	private String module;
	
	public MbAccounts() {

	}

	public AccountGL getGlFilter() {
		return glFilter;
	}

	public void setGlFilter(AccountGL glFilter) {
		this.glFilter = glFilter;
	}

	public AccountGL getActiveGLAccount() {
		return activeGLAccount;
	}

	public void setActiveGLAccount(AccountGL activeGLAccount) {
		this.activeGLAccount = activeGLAccount;
	}

	public String getGlBackLink() {
		return glBackLink;
	}

	public void setGlBackLink(String glBackLink) {
		this.glBackLink = glBackLink;
	}

	public String getGlTabName() {
		return glTabName;
	}

	public void setGlTabName(String glTabName) {
		this.glTabName = glTabName;
	}

	public int getGlRowsNum() {
		return glRowsNum;
	}

	public void setGlRowsNum(int glRowsNum) {
		this.glRowsNum = glRowsNum;
	}

	public int getGlPageNumber() {
		return glPageNumber;
	}

	public void setGlPageNumber(int glPageNumber) {
		this.glPageNumber = glPageNumber;
	}

	public Account getFilter() {
		return filter;
	}

	public void setFilter(Account filter) {
		this.filter = filter;
	}

	public Account getActiveAccount() {
		return activeAccount;
	}

	public void setActiveAccount(Account activeAccount) {
		this.activeAccount = activeAccount;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
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

	public String getModule() {
		return module;
	}

	public void setModule(String module) {
		this.module = module;
	}
}
