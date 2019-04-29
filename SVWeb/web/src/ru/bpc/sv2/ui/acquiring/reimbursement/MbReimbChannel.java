package ru.bpc.sv2.ui.acquiring.reimbursement;

import java.io.Serializable;

import ru.bpc.sv2.acquiring.reimbursement.ReimbursementChannel;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean(name = "MbReimbChannel")
public class MbReimbChannel implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private ReimbursementChannel reimbursementChannel;
	private String tabName;

	private String backLink;
	private boolean searching;
	private ReimbursementChannel filter;

	public MbReimbChannel() {

	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public ReimbursementChannel getReimbursementChannel() {
		if (reimbursementChannel == null)
			reimbursementChannel = new ReimbursementChannel();
		return reimbursementChannel;
	}

	public void setReimbursementChannel(ReimbursementChannel reimbursementChannel) {
		this.reimbursementChannel = reimbursementChannel;
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

	public ReimbursementChannel getFilter() {
		if (filter == null)
			filter = new ReimbursementChannel();
		return filter;
	}

	public void setFilter(ReimbursementChannel filter) {
		this.filter = filter;
	}

}
