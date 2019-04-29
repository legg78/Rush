package ru.bpc.sv2.ui.acquiring.reimbursement;

import java.io.Serializable;

import ru.bpc.sv2.acquiring.reimbursement.ReimbursementOperation;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbReimbOperation")
public class MbReimbOperation implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private ReimbursementOperation operation;
	private String tabName;

	private String backLink;
	private boolean searching;
	private ReimbursementOperation filter;

	public MbReimbOperation() {

	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public ReimbursementOperation getOperation() {
		if (operation == null)
			operation = new ReimbursementOperation();
		return operation;
	}

	public void setOperation(ReimbursementOperation operation) {
		this.operation = operation;
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

	public ReimbursementOperation getFilter() {
		return filter;
	}

	public void setFilter(ReimbursementOperation filter) {
		this.filter = filter;
	}

}
