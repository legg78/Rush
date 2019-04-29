package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoPurpose;
import ru.bpc.sv2.pmo.PmoPurposeParameter;
import ru.bpc.sv2.pmo.PmoService;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

/**
 * Manage Bean for List PMO Purposes page.
 */
@ViewScoped
@ManagedBean (name = "MbServicesForProvider")
public class MbServicesForProvider extends AbstractBean {
	private static final long serialVersionUID = -2637641392388678799L;

	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private PmoPurpose _activePurpose;
	private PmoPurpose newPurpose;
	
	private PmoPurpose purposeFilter;
	private List<SelectItem> mccs;
	private List<SelectItem> operTypes;
	private boolean selectMode;

	private final DaoDataModel<PmoPurpose> _purposesSource;

	private final TableRowSelection<PmoPurpose> _purposeSelection;
	
	private List<SelectItem> hostAlgorithmForCombo;
	
	private static String COMPONENT_ID = "purposesTable";
	private String tabName;
	private String parentSectionId;
	private ArrayList<SelectItem> modifiers;

	public MbServicesForProvider() {
		_purposesSource = new DaoDataListModel<PmoPurpose>(logger) {
			private static final long serialVersionUID = 5814539590834341049L;

			@Override
			protected List<PmoPurpose> loadDaoListData(SelectionParams params) {
				if (isSearching()) {
					setFilters();
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
		else if (_activePurpose != null && _purposesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activePurpose.getModelId());
			_purposeSelection.setWrappedSelection(selection);
			_activePurpose = _purposeSelection.getSingleSelection();
		}
		return _purposeSelection.getWrappedSelection();
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
		//set param filter for getting list of purpose parameters
		MbPMOParameters parameterSearch = ManagedBeanWrapper.getManagedBean(MbPMOParameters.class);
		PmoPurposeParameter ppFilter = new PmoPurposeParameter();
		ppFilter.setPurposeId(_activePurpose.getId());
		parameterSearch.setParameterFilter(ppFilter);
		parameterSearch.search();
	}
	
	public void setPurposeSelection(SimpleSelection selection) {
		_purposeSelection.setWrappedSelection(selection);
		_activePurpose = _purposeSelection.getSingleSelection();
		if (_activePurpose != null) {
			setInfo();
		}
	}

	public void search() {
		clearBean();
		clearBeansStates();
		boolean found = false;
		if (getPurposeFilter().getProviderId() != null) {
			found = true;
		}
		if (found) {
			searching = true;
		}
	}
	
	public void clearBeansStates() {
		MbPMOParameters parameterSearch = (MbPMOParameters) ManagedBeanWrapper
			.getManagedBean("MbPMOParameters");
		parameterSearch.clearFilter();
//		parameterSearch.setSearching(true);
		parameterSearch.search();
	}
	
	public void clearFilter() {
		purposeFilter = null;
		clearBean();
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

	public void add() {
		newPurpose = new PmoPurpose();
		newPurpose.setLang(userLang);
		newPurpose.setInstId(getPurposeFilter().getInstId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newPurpose = (PmoPurpose) _activePurpose.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newPurpose = _activePurpose;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			newPurpose.setProviderId(getPurposeFilter().getProviderId());
			newPurpose.setInstId(getPurposeFilter().getInstId());
			newPurpose.setLang(curLang);
			if (isEditMode()) {
				newPurpose = _paymentOrdersDao.editPurpose(userSessionId, newPurpose);
				_purposesSource.replaceObject(_activePurpose, newPurpose);
			} else {
				newPurpose = _paymentOrdersDao.addPurpose(userSessionId, newPurpose);
				_purposeSelection.addNewObjectToList(newPurpose);
			}
			_activePurpose = newPurpose;
			setInfo();
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);

		}
	}

	public void delete() {
		try {
			_paymentOrdersDao.removePurpose(userSessionId, _activePurpose);
			FacesUtils.addMessageInfo("Purpose (id = " + _activePurpose.getId() + ") has been deleted.");

			_activePurpose = _purposeSelection.removeObjectFromList(_activePurpose);
			if (_activePurpose == null) {
				clearBean();
			} else {
				setInfo();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		filters.add(Filter.create("lang", curLang));

		if (getPurposeFilter().getProviderId() != null) {
			filters.add(Filter.create("providerId", getPurposeFilter().getProviderId()));
		}
		if (getPurposeFilter().getInstId() != null) {
			filters.add(Filter.create("instId", getPurposeFilter().getInstId()));
		}
	}

	public PmoPurpose getPurposeFilter() {
		if (purposeFilter == null)
			purposeFilter = new PmoPurpose();
		return purposeFilter;
	}

	public void setPurposeFilter(PmoPurpose purposeFilter) {
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

	public List<SelectItem> getServicesForCombo() {
		try {
			List<Filter> localFilters = new ArrayList<Filter>(2);
			localFilters.add(Filter.create("lang", curLang));
			localFilters.add(Filter.create("instId", getPurposeFilter().getInstId()));

			SelectionParams params = new SelectionParams(localFilters);
			List<PmoService> services = _paymentOrdersDao.getServicesForCombo(userSessionId, params);
			List<SelectItem> items = new ArrayList<SelectItem>(services.size());

			for (PmoService serv: services) {
				items.add(new SelectItem(serv.getId(), serv.getLabel()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public List<SelectItem> getHostAlgorithmForCombo() {
		if (hostAlgorithmForCombo == null) {
			hostAlgorithmForCombo = getDictUtils().getLov(LovConstants.PMO_HOST_ALGORITHM);
		}
		return hostAlgorithmForCombo;
	}
	
	public List<SelectItem> getMccs() {
		if (mccs == null) {
			mccs = getDictUtils().getLov(LovConstants.MCC);
		}
		return mccs;
	}
	
	public List<SelectItem> getOperTypes() {
		if (operTypes == null) {
			operTypes = getDictUtils().getLov(LovConstants.OPERATION_TYPE);
		}
		return operTypes;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
	public ArrayList<SelectItem> getModifiers() {
		if (modifiers == null) {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("SCALE_TYPE", ScaleConstants.SCALE_FOR_SERV_PRO);
			modifiers =  (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.MODIFIER_LIST, paramMap);
		}		
		return modifiers;
	}

	public List<SelectItem> getAmountAlgorithms() {
		return getDictUtils().getArticles(DictNames.PAYMENT_AMOUNT_ALGORITHMS, false);
	}
}
