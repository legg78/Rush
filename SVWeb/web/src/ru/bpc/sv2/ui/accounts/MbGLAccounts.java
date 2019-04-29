package ru.bpc.sv2.ui.accounts;

import java.io.Serializable;
import java.util.List;

import ru.bpc.sv2.accounts.AccountGL;
import ru.bpc.sv2.invocation.Filter;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbGLAccounts")
public class MbGLAccounts implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private AccountGL filter;
	private List<Filter> filters;
	private String backLink;

	private AccountGL _activeAccount;

	public MbGLAccounts() {
	}

	public AccountGL getActiveAccount() {
		return _activeAccount;
	}

	public void setActiveAccount(AccountGL activeAccount) {
		_activeAccount = activeAccount;
	}

	public AccountGL getFilter() {
		if (filter == null)
			filter = new AccountGL();
		return filter;
	}

	public void setFilter(AccountGL filter) {
		this.filter = filter;
	}

	public List<Filter> getFilters() {
		return filters;
	}

	public void setFilters(List<Filter> filters) {
		this.filters = filters;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

}
