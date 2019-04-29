package ru.bpc.sv2.ui.acquiring.reimbursement;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import ru.bpc.sv2.acquiring.reimbursement.ReimbursementBatchEntry;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.ui.utils.AbstractBean;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbReimbBatch")
public class MbReimbBatch extends AbstractBean implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private ReimbursementBatchEntry batchEntry;
	private String tabName;

	private String backLink;
	private boolean searching;
	private ReimbursementBatchEntry filter;

	public MbReimbBatch() {
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("operTab")) {
			MbReimbOperationSearch bean = (MbReimbOperationSearch) ManagedBeanWrapper
					.getManagedBean("MbReimbOperationSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.ACQUIRING_REIMB_BATCH;
	}

	public ReimbursementBatchEntry getBatchEntry() {
		if (batchEntry == null)
			batchEntry = new ReimbursementBatchEntry();
		return batchEntry;
	}

	public void setBatchEntry(ReimbursementBatchEntry batchEntry) {
		this.batchEntry = batchEntry;
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

	public ReimbursementBatchEntry getFilter() {
		return filter;
	}

	public void setFilter(ReimbursementBatchEntry filter) {
		this.filter = filter;
	}
	
	public List<Object> getEmptyTable() {
		List<Object> arr = new ArrayList<Object>(1);
		arr.add(new Object());
		return arr;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
	
}
