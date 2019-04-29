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
import ru.bpc.sv2.pmo.PmoParameterValue;
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
 * Manage Bean for List PMO Purpose Parameter Values page.
 */
@ViewScoped
@ManagedBean (name = "MbObjectPurposeParameterValues")
public class MbObjectPurposeParameterValues extends AbstractBean {
	private static final long serialVersionUID = 9200456671290775865L;

	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private PmoParameterValue _activeParameterValue;
	private PmoParameterValue newParameterValue;
	
	private PmoParameterValue parameterValueFilter;
	private List<Filter> parameterValueFilters;

	private boolean selectMode;

	private final DaoDataModel<PmoParameterValue> _parameterValuesSource;

	private final TableRowSelection<PmoParameterValue> _parameterValueSelection;
	
	private ArrayList<SelectItem> entityTypes;
	
	private static String COMPONENT_ID = "parameterValuesTable";
	private String tabName;
	private String parentSectionId;
	private String privilege;
	
	public MbObjectPurposeParameterValues() {
		_parameterValuesSource = new DaoDataModel<PmoParameterValue>() {
			private static final long serialVersionUID = 6632734496385825815L;

			@Override
			protected PmoParameterValue[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new PmoParameterValue[0];
				try {
					setParameterValuesFilters();
					params.setFilters(parameterValueFilters.toArray(new Filter[parameterValueFilters.size()]));
					params.setPrivilege(getPrivilege());
					return _paymentOrdersDao.getObjectPurposeParameterValues(userSessionId, params);
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
					params.setPrivilege(getPrivilege());
					return _paymentOrdersDao.getObjectPurposeParameterValuesCount(userSessionId, params);
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
		parameterValueFilter = null;
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
			newParameterValue = getParameterValueFilter().clone();
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
			//update info relating param
			updateInfo();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newParameterValue = _activeParameterValue;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newParameterValue = _paymentOrdersDao.editObjectParameterValue(userSessionId, newParameterValue);
				_parameterValuesSource.replaceObject(_activeParameterValue, newParameterValue);
			} else {
				newParameterValue = _paymentOrdersDao.addObjectParameterValue(userSessionId, newParameterValue);
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
		if (getParameterValueFilter().getId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getParameterValueFilter().getId());
			filtersList.add(paramFilter);
		}
		if (getParameterValueFilter().getEntityType() != null && !getParameterValueFilter().getEntityType().isEmpty()) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getParameterValueFilter().getEntityType());
			filtersList.add(paramFilter);
		}
		if (getParameterValueFilter().getPurposeId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("purposeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getParameterValueFilter().getPurposeId());
			filtersList.add(paramFilter);
		}
		if (getParameterValueFilter().getObjectId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getParameterValueFilter().getObjectId());
			filtersList.add(paramFilter);
		}
		parameterValueFilters = filtersList;
	}

	public PmoParameterValue getParameterValueFilter() {
		if (parameterValueFilter == null)
			parameterValueFilter = new PmoParameterValue();
		return parameterValueFilter;
	}

	public void setParameterValueFilter(PmoParameterValue parameterValueFilter) {
		this.parameterValueFilter = parameterValueFilter;
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
	

	public List<SelectItem> getEntityTypes() {
		if (entityTypes == null) {
			entityTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.ENTITY_TYPES);
		}
		if (entityTypes == null)
			entityTypes = new ArrayList<SelectItem>();
		return entityTypes;
	}

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
	
	public List<SelectItem> getObjectParametersForCombo() {
		try {
			List<SelectItem> items = new ArrayList<SelectItem>();
			if (newParameterValue != null && newParameterValue.getPurposeId() != null) {
				Filter[] filters = new Filter[3];
				filters[0] = new Filter();
				filters[0].setElement("purposeId");
				filters[0].setValue(newParameterValue.getPurposeId());
				filters[1] = new Filter();
				filters[1].setElement("entityType");
				filters[1].setValue(newParameterValue.getEntityType());
				filters[2] = new Filter();
				filters[2].setElement("objectId");
				filters[2].setValue(newParameterValue.getObjectId());
		
				SelectionParams params = new SelectionParams();
				params.setFilters(filters);
				
				PmoParameter[] parameters = _paymentOrdersDao.getObjectParametersForCombo(userSessionId, params);
				items = new ArrayList<SelectItem>(parameters.length);
				for (PmoParameter param: parameters) {
					items.add(new SelectItem(param.getId(), param.getName()));
				}
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return new ArrayList<SelectItem>(0);
	}
	
	public void updateInfo() {
		if (newParameterValue.getPurpParamId() != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(newParameterValue.getPurpParamId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(curLang);
	
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			
			try {
				PmoPurposeParameter[] purposeParameters = _paymentOrdersDao.getPurposeParameters(userSessionId, params);
				if (purposeParameters != null && purposeParameters.length > 0) {
					newParameterValue.setDataType(purposeParameters[0].getDataType());
					newParameterValue.setLovId(purposeParameters[0].getLovId());
					newParameterValue.setLovName(purposeParameters[0].getLovName());
					
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		} else {
			newParameterValue.setDataType(null);
			newParameterValue.setLovId(null);
			newParameterValue.setLovName(null);
		}
		if (isNewMode()) {
			newParameterValue.setValue(null);
			newParameterValue.setValueD(null);
			newParameterValue.setValueN((BigDecimal)null);
			newParameterValue.setValueV(null);
			newParameterValue.setLovValue(null);
		}
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

	public String getPrivilege() {
		return privilege;
	}

	public void setPrivilege(String privilege) {
		this.privilege = privilege;
	}
}
