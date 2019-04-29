package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoObjectPurpose;
import ru.bpc.sv2.pmo.PmoParameterValue;
import ru.bpc.sv2.pmo.PmoPurpose;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

/**
 * Manage Bean for List PMO Purposes has parameter form.
 */
@ViewScoped
@ManagedBean (name = "MbObjectPurposes")
public class MbObjectPurposes extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private PmoPurpose _activePurpose;
	private PmoPurpose newPurpose;

	private PmoObjectPurpose purposeFilter;

	private boolean selectMode;

	private final DaoDataModel<PmoPurpose> _purposesSource;

	private final TableRowSelection<PmoPurpose> _purposeSelection;
	
	private String privilege; 
	
	public MbObjectPurposes() {
		_purposesSource = new DaoDataListModel<PmoPurpose>(logger) {
			@Override
			protected List<PmoPurpose> loadDaoListData(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setPrivilege(getPrivilege());
					params.setFilters(filters);
					return _paymentOrdersDao.getPurposes(userSessionId, params);
				}
				return new ArrayList<PmoPurpose>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setFilters(filters);
					params.setPrivilege(getPrivilege());
					return _paymentOrdersDao.getPurposesCount(userSessionId, params);
				}
				return 0;
			}
		};
		_purposeSelection = new TableRowSelection<PmoPurpose>(null, _purposesSource);
	}

	public DaoDataModel<PmoPurpose> getPurposes() {
		return _purposesSource;
	}

	public PmoPurpose getActivePurpose() {
		return _activePurpose;
	}

	public void setActivePurpose(PmoPurpose activePurpose) {
		this._activePurpose = activePurpose;
	}

	public SimpleSelection getPurposeSelection() {
		if (_activePurpose == null && _purposesSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activePurpose != null && _purposesSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activePurpose.getModelId());
			_purposeSelection.setWrappedSelection(selection);
			_activePurpose = _purposeSelection.getSingleSelection();			
		}
		return _purposeSelection.getWrappedSelection();
	}
	
	public void setPurposeSelection(SimpleSelection selection) {
		_purposeSelection.setWrappedSelection(selection);
		_activePurpose = _purposeSelection.getSingleSelection();
		
		if (_activePurpose != null) {
			setInfo();
		}
	}

	public void setFirstRowActive() {
		_purposesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activePurpose = (PmoPurpose) _purposesSource.getRowData();
		selection.addKey(_activePurpose.getModelId());
		_purposeSelection.setWrappedSelection(selection);
		if (_activePurpose != null) {
			setInfo();
		}
	}
	
	public void setInfo() {
		//set param filter for getting list of purpose parameter values
		MbObjectPurposeParameterValues bean = (MbObjectPurposeParameterValues) ManagedBeanWrapper
				.getManagedBean("MbObjectPurposeParameterValues");
		PmoParameterValue ppFilter = new PmoParameterValue();
		ppFilter.setPurposeId(_activePurpose.getId());
		ppFilter.setEntityType(getPurposeFilter().getEntityType());
		ppFilter.setObjectId(getPurposeFilter().getObjectId());
		bean.setParameterValueFilter(ppFilter);
		bean.setPrivilege(getPrivilege());
		bean.search();
	}
	
	public void setPurposeParameterSelection(SimpleSelection selection) {
		_purposeSelection.setWrappedSelection(selection);
		_activePurpose = _purposeSelection.getSingleSelection();
		if (_activePurpose != null) {
			setInfo();
		}
	}

	public void search() {
		clearBean();
		clearBeansStates();
		searching = true;
	}
	
	public void clearBeansStates() {
		MbObjectPurposeParameterValues bean = (MbObjectPurposeParameterValues) ManagedBeanWrapper
			.getManagedBean("MbObjectPurposeParameterValues");
		bean.clearFilter();
//		bean.search();
	}
	
	public void clearFilter() {
		purposeFilter = null;
		clearBean();
		clearBeansStates();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_purposesSource.flushCache();
		if (_purposeSelection != null) {
			_purposeSelection.clearSelection();
		}
		_activePurpose = null;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		filters.add(Filter.create("lang", userLang));
	}

	public PmoObjectPurpose getPurposeFilter() {
		if (purposeFilter == null)
			purposeFilter = new PmoObjectPurpose();
		return purposeFilter;
	}

	public void setPurposeFilter(PmoObjectPurpose purposeFilter) {
		this.purposeFilter = purposeFilter;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public PmoPurpose getNewPurpose() {
		return newPurpose;
	}

	public void setNewPurpose(PmoPurpose newPurpose) {
		this.newPurpose = newPurpose;
	}

	public String getPrivilege() {
		return privilege;
	}

	public void setPrivilege(String privilege) {
		this.privilege = privilege;
	}
}
