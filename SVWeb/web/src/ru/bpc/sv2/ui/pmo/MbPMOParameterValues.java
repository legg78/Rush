package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoParameterValue;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

/**
 * Manage Bean for List PMO Purpose Parameter Values page.
 */
@RequestScoped
@KeepAlive
@ManagedBean (name = "MbPMOParameterValues")
public class MbPMOParameterValues extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private PmoParameterValue _activeParameterValue;
	private PmoParameterValue newParameterValue;

	
	private PmoParameterValue filter;
	private List<Filter> parameterValueFilters;

	private boolean selectMode;

	private final DaoDataModel<PmoParameterValue> _parameterValuesSource;

	private final TableRowSelection<PmoParameterValue> _parameterValueSelection;
	
	private ArrayList<SelectItem> entityTypes;
	
	private static String COMPONENT_ID = "parameterValuesTable";
	private String tabName;
	private String parentSectionId;
	
	public MbPMOParameterValues() {
		

		_parameterValuesSource = new DaoDataModel<PmoParameterValue>() {
			@Override
			protected PmoParameterValue[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new PmoParameterValue[0];
				try {
					setParameterValuesFilters();
					params.setFilters(parameterValueFilters.toArray(new Filter[parameterValueFilters.size()]));
					return _paymentOrdersDao.getParameterValues(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PmoParameterValue[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setParameterValuesFilters();
					params.setFilters(parameterValueFilters.toArray(new Filter[parameterValueFilters.size()]));
					return _paymentOrdersDao.getParameterValuesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_parameterValueSelection = new TableRowSelection<PmoParameterValue>(null, _parameterValuesSource);
	}

	public DaoDataModel<PmoParameterValue> getParameterValues() {
		return _parameterValuesSource;
	}

	public PmoParameterValue getActiveParameterValue() {
		return _activeParameterValue;
	}

	public void setActiveParameterValue(PmoParameterValue activeParameterValue) {
		this._activeParameterValue = activeParameterValue;
	}

	public SimpleSelection getParameterValueSelection() {
		if (_activeParameterValue == null && _parameterValuesSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeParameterValue != null && _parameterValuesSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeParameterValue.getModelId());
			_parameterValueSelection.setWrappedSelection(selection);
			_activeParameterValue = _parameterValueSelection.getSingleSelection();			
		}
		return _parameterValueSelection.getWrappedSelection();
	}
	
	public void setFirstRowActive() {
		_parameterValuesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeParameterValue = (PmoParameterValue) _parameterValuesSource.getRowData();
		selection.addKey(_activeParameterValue.getModelId());
		_parameterValueSelection.setWrappedSelection(selection);
		if (_activeParameterValue != null) {
			setInfo();
		}
	}
	
	public void setInfo() {
		
	}

	public void setParameterValueSelection(SimpleSelection selection) {
		_parameterValueSelection.setWrappedSelection(selection);
		_activeParameterValue = _parameterValueSelection.getSingleSelection();
		
		if (_activeParameterValue != null) {
			setInfo();
		}
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_parameterValuesSource.flushCache();
		if (_parameterValueSelection != null) {
			_parameterValueSelection.clearSelection();
		}
		_activeParameterValue = null;
	}

	public void add() {
		try {
			newParameterValue = getFilter().clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newParameterValue = new PmoParameterValue();
		}
		newParameterValue.setLang(userLang);
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newParameterValue = (PmoParameterValue) _activeParameterValue.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newParameterValue = _activeParameterValue;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
//			newParameterValue.setPurpParamId(getParameterValueFilter().getPurpParamId());
//			newParameterValue.setLang(curLang);
			if (isEditMode()) {
				newParameterValue = _paymentOrdersDao.editParameterValue(userSessionId, newParameterValue);
				_parameterValuesSource.replaceObject(_activeParameterValue, newParameterValue);
			} else {
				newParameterValue = _paymentOrdersDao.addParameterValue(userSessionId, newParameterValue);
				_parameterValueSelection.addNewObjectToList(newParameterValue);
			}
			_activeParameterValue = newParameterValue;
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);

		}
	}

	public void delete() {
		try {
			_paymentOrdersDao.removeParameterValue(userSessionId, _activeParameterValue);
			FacesUtils.addMessageInfo("Parameter (id = " + _activeParameterValue.getId()
					+ ") has been deleted.");

			_activeParameterValue = _parameterValueSelection.removeObjectFromList(_activeParameterValue);
			if (_activeParameterValue == null) {
				clearBean();
			} 
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		
	}

	public void setParameterValuesFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getFilter().getId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getId());
			filtersList.add(paramFilter);
		}
		if (getFilter().getPurpParamId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("purpParamId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getPurpParamId());
			filtersList.add(paramFilter);
		}
		
		parameterValueFilters = filtersList;
	}

	public PmoParameterValue getFilter() {
		if (filter == null)
			filter = new PmoParameterValue();
		return filter;
	}

	public void setFilter(PmoParameterValue filter) {
		this.filter = filter;
	}

	public List<Filter> getParameterValueFilters() {
		return parameterValueFilters;
	}

	public void setParameterValueFilters(List<Filter> parameterFilters) {
		this.parameterValueFilters = parameterFilters;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public PmoParameterValue getNewParameterValue() {
		return newParameterValue;
	}

	public void setNewParameterValue(PmoParameterValue newParameterValue) {
		this.newParameterValue = newParameterValue;
	}

//	public List<SelectItem> getParametersForCombo() {
//		try {
//			PmoParameter[] parameters = _paymentOrdersDao.getParametersForCombo(userSessionId);
//			List<SelectItem> items = new ArrayList<SelectItem>(parameters.length);
//			for (PmoParameter param: parameters) {
//				items.add(new SelectItem(param.getId(), param.getLabel()));
//			}
//			return items;
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//		}
//		return new ArrayList<SelectItem>(0);
//	}
	
//	public List<SelectItem> getOrderStagesForCombo() {
//		if (orderStagesForCombo == null) {
//			orderStagesForCombo = getDictUtils().getLov(LovConstants.PMO_ORDER_STAGE);
//		}
//		return orderStagesForCombo;
//	}
	
	public void disableLov() {
		if (getNewParameterValue().isDate()) {
			getNewParameterValue().setLovId(null);
		}
	}
	
	public List<SelectItem> getLovValues() {
		if (getNewParameterValue().getLovId() != null) {
			return getDictUtils().getLov(newParameterValue.getLovId());
		}
		return new ArrayList<SelectItem>(0);
	}
	
//	public void updateInfo() {
//		if (newParameterValue.getParamId() != null) {
//			Filter[] filters = new Filter[2];
//			filters[0] = new Filter();
//			filters[0].setElement("id");
//			filters[0].setValue(newParameterValue.getParamId());
//			filters[1] = new Filter();
//			filters[1].setElement("lang");
//			filters[1].setValue(curLang);
//	
//			SelectionParams params = new SelectionParams();
//			params.setFilters(filters);
//			
//			try {
//				PmoParameter[] parameters = _paymentOrdersDao.getParameters(userSessionId, params);
//				if (parameters != null && parameters.length > 0) {
//					newParameterValue.setDataType(parameters[0].getDataType());
//					newParameterValue.setLovId(parameters[0].getLovId());
//					newParameterValue.setLovName(parameters[0].getLovName());
//					
//				}
//			} catch (Exception e) {
//				FacesUtils.addMessageError(e);
//				logger.error("", e);
//			}
//		} else {
//			newParameterValue.setDataType(null);
//			newParameterValue.setLovId(null);
//			newParameterValue.setLovName(null);
//		}
//		newParameterValue.setValue(null);
//		newParameterValue.setValueD(null);
//		newParameterValue.setValueN((BigDecimal)null);
//		newParameterValue.setValueV(null);
//		newParameterValue.setLovValue(null);
//	}
	
//	public List<SelectItem> getEntityTypes() {
//		ArrayList<SelectItem> items = new ArrayList<SelectItem>(1);
//		items.add(new SelectItem(EntityNames.TERMINAL, getDictUtils().getAllArticlesDesc().get(
//				EntityNames.TERMINAL)));
//		return items;
//	}

	public List<SelectItem> getEntityTypes() {
		if (entityTypes == null) {
			entityTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.ENTITY_TYPES);
		}
		if (entityTypes == null)
			entityTypes = new ArrayList<SelectItem>();
		return entityTypes;
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
