package ru.bpc.sv2.ui.pmo;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoParameter;
import ru.bpc.sv2.pmo.PmoPurposeParameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Manage Bean for List PMO Purpose Parameters page.
 */
@ViewScoped
@ManagedBean (name = "MbPMOParameters")
public class MbPMOParameters extends AbstractBean {
	private static final long serialVersionUID = -5310736374290919846L;

	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private PmoPurposeParameter _activeParameter;
	private PmoPurposeParameter newParameter;
	
	private PmoPurposeParameter parameterFilter;
	private List<Filter> parameterFilters;

	private boolean selectMode;

	private final DaoDataModel<PmoPurposeParameter> _parametersSource;

	private final TableRowSelection<PmoPurposeParameter> _parameterSelection;
	
	private List<SelectItem> orderStagesForCombo;
	
	private static String COMPONENT_ID = "parametersTable";
	private String tabName;
	private String parentSectionId;

	public MbPMOParameters() {
		_parametersSource = new DaoDataModel<PmoPurposeParameter>() {
			private static final long serialVersionUID = -6495649468515648294L;

			@Override
			protected PmoPurposeParameter[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new PmoPurposeParameter[0];
				try {
					setParametersFilters();
					params.setFilters(parameterFilters.toArray(new Filter[parameterFilters.size()]));
					return _paymentOrdersDao.getPurposeParameters(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PmoPurposeParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setParametersFilters();
					params.setFilters(parameterFilters.toArray(new Filter[parameterFilters.size()]));
					return _paymentOrdersDao.getPurposeParametersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_parameterSelection = new TableRowSelection<PmoPurposeParameter>(null, _parametersSource);
	}

	public DaoDataModel<PmoPurposeParameter> getParameters() {
		return _parametersSource;
	}

	public PmoPurposeParameter getActiveParameter() {
		return _activeParameter;
	}

	public void setActiveParameter(PmoPurposeParameter activeParameter) {
		this._activeParameter = activeParameter;
	}

	public SimpleSelection getParameterSelection() {
		if (_activeParameter == null && _parametersSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeParameter != null && _parametersSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeParameter.getModelId());
			_parameterSelection.setWrappedSelection(selection);
			_activeParameter = _parameterSelection.getSingleSelection();			
		}
		return _parameterSelection.getWrappedSelection();
	}
	
	public void setFirstRowActive() {
		_parametersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeParameter = (PmoPurposeParameter) _parametersSource.getRowData();
		selection.addKey(_activeParameter.getModelId());
		_parameterSelection.setWrappedSelection(selection);
		if (_activeParameter != null) {
			setInfo();
		}
	}
	
	public void setInfo() {
		
	}

	public void setParameterSelection(SimpleSelection selection) {
		_parameterSelection.setWrappedSelection(selection);
		_activeParameter = _parameterSelection.getSingleSelection();
		
		if (_activeParameter != null) {
			setInfo();
		}
	}

	public void search() {
		clearBean();
		boolean found = false;
		if (getParameterFilter().getPurposeId() != null) {
			found = true;
		}
		// if no selected purposes found then we must not search for parameters at all
		if (found) {
			searching = true;
		}
	}

	public void clearFilter() {
		parameterFilter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_parametersSource.flushCache();
		if (_parameterSelection != null) {
			_parameterSelection.clearSelection();
		}
		_activeParameter = null;
	}

	public void add() {
		newParameter = new PmoPurposeParameter();
		newParameter.setLang(userLang);
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newParameter = (PmoPurposeParameter) _activeParameter.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newParameter = _activeParameter;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			newParameter.setPurposeId(getParameterFilter().getPurposeId());
			newParameter.setLang(curLang);
			if (isEditMode()) {
				newParameter = _paymentOrdersDao.editPurposeParameter(userSessionId, newParameter);
				_parametersSource.replaceObject(_activeParameter, newParameter);
			} else {
				newParameter = _paymentOrdersDao.addPurposeParameter(userSessionId, newParameter);
				_parameterSelection.addNewObjectToList(newParameter);
			}
			_activeParameter = newParameter;
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);

		}
	}

	public void delete() {
		try {
			_paymentOrdersDao.removePurposeParameter(userSessionId, _activeParameter);
			FacesUtils.addMessageInfo("Parameter (id = " + _activeParameter.getId()
					+ ") has been deleted.");

			_activeParameter = _parameterSelection.removeObjectFromList(_activeParameter);
			if (_activeParameter == null) {
				clearBean();
			} 
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		
	}

	public void setParametersFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getParameterFilter().getPurposeId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("purposeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getParameterFilter().getPurposeId());
			filtersList.add(paramFilter);
		}
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);
		parameterFilters = filtersList;
	}

	public PmoPurposeParameter getParameterFilter() {
		if (parameterFilter == null)
			parameterFilter = new PmoPurposeParameter();
		return parameterFilter;
	}

	public void setParameterFilter(PmoPurposeParameter parameterFilter) {
		this.parameterFilter = parameterFilter;
	}

	public List<Filter> getParameterFilters() {
		return parameterFilters;
	}

	public void setParameterFilters(List<Filter> parameterFilters) {
		this.parameterFilters = parameterFilters;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public PmoPurposeParameter getNewParameter() {
		return newParameter;
	}

	public void setNewParameter(PmoPurposeParameter newParameter) {
		this.newParameter = newParameter;
	}

//	public void changeLanguage(ValueChangeEvent event) {
//		curLang = (String) event.getNewValue();
//
//		Filter[] filters = new Filter[2];
//		filters[0] = new Filter();
//		filters[0].setElement("id");
//		filters[0].setValue(_activePurpose.getId() + "");
//		filters[1] = new Filter();
//		filters[1].setElement("lang");
//		filters[1].setValue(curLang);
//
//		SelectionParams params = new SelectionParams();
//		params.setFilters(filters);
//		try {
//			PmoPurpose[] services = _paymentOrdersDao.getServices(userSessionId, params);
//			if (services != null && services.length > 0) {
//				_activeService = services[0];
//			}
//		} catch (Exception e) {
//			FacesUtils.addMessageError(e);
//			logger.error("", e);
//		}
//	}
	
//	public void confirmEditLanguage() {
//		Filter[] filters = new Filter[2];
//		filters[0] = new Filter();
//		filters[0].setElement("id");
//		filters[0].setValue(newService.getId());
//		filters[1] = new Filter();
//		filters[1].setElement("lang");
//		filters[1].setValue(newService.getLang());
//
//		SelectionParams params = new SelectionParams();
//		params.setFilters(filters);
//		try {
//			PmoService[] services = _paymentOrdersDao.getServices(userSessionId, params);
//			if (services != null && services.length > 0) {
//				newService = services[0];
//			}
//		} catch (Exception e) {
//			FacesUtils.addMessageError(e);
//			logger.error("", e);
//		}
//	}
	public List<SelectItem> getParametersForCombo() {
		try {
			PmoParameter[] parameters = _paymentOrdersDao.getParametersForCombo(userSessionId);
			List<SelectItem> items = new ArrayList<SelectItem>(parameters.length);
			for (PmoParameter param: parameters) {
				items.add(new SelectItem(param.getId(), param.getName()));
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
	
	public List<SelectItem> getOrderStagesForCombo() {
		if (orderStagesForCombo == null) {
			orderStagesForCombo = getDictUtils().getLov(LovConstants.PMO_ORDER_STAGE);
		}
		return orderStagesForCombo;
	}
	
	public void disableLov() {
		if (getNewParameter().isDate()) {
			getNewParameter().setLovId(null);
		}
	}
	
	public List<SelectItem> getLovValues() {
		if (getNewParameter().getLovId() != null) {
			return getDictUtils().getLov(newParameter.getLovId());
		}
		return new ArrayList<SelectItem>(0);
	}
	
	public void updateInfo() {
		if (newParameter.getParamId() != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(newParameter.getParamId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(curLang);
	
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			
			try {
				List<PmoParameter> parameters = _paymentOrdersDao.getParameters(userSessionId, params);
				if (parameters != null && parameters.size() > 0) {
					newParameter.setDataType(parameters.get(0).getDataType());
					newParameter.setLovId(parameters.get(0).getLovId());
					newParameter.setLovName(parameters.get(0).getLovName());
					
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		} else {
			newParameter.setDataType(null);
			newParameter.setLovId(null);
			newParameter.setLovName(null);
		}
		newParameter.setValue(null);
		newParameter.setValueD(null);
		newParameter.setValueN((BigDecimal)null);
		newParameter.setValueV(null);
		newParameter.setLovValue(null);
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
}
