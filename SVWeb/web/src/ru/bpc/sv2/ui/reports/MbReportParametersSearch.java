package ru.bpc.sv2.ui.reports;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.html.HtmlInputText;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.ReportParameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbReportParametersSearch")
public class MbReportParametersSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("REPORTS");

	private ReportsDao _reportsDao = new ReportsDao();

	

	private ReportParameter filter;
	private ReportParameter _activeParameter;
	private ReportParameter newParameter;
	private Map<String, ReportParameter> mergeParams;
	
	private final DaoDataModel<ReportParameter> _parametersSource;

	private final TableRowSelection<ReportParameter> _itemSelection;

	private ReportParameter parameterCopy;
	private BigDecimal maxNumber;
	
	private String oldLang;
	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;
	private ArrayList<SelectItem> dataTypes;
	
	public MbReportParametersSearch() {
		
		if (mergeParams != null) {
			mergeParams.clear();
		}
		maxNumber = (new BigDecimal("1.0E18")).subtract(new BigDecimal("1.0E-4"));
		
		_parametersSource = new DaoDataModel<ReportParameter>() {
			@Override
			protected ReportParameter[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ReportParameter[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					ReportParameter[] parameters = _reportsDao.getReportParameters(userSessionId, params);
					if (mergeParams != null && !mergeParams.isEmpty()) {
						for (ReportParameter param : parameters){
							ReportParameter paramTmp = mergeParams.get(param.getSystemName());
							if (paramTmp == null) {
								continue;
							}
							if (param.isChar()) {
								param.setValueV(paramTmp.getValueV());
							} else if (param.isNumber()) {
								param.setValueN(paramTmp.getValueN());
							} else if (param.isDate()) {
								param.setValueD(paramTmp.getValueD());
							}
						}
					}
					return parameters;
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ReportParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _reportsDao.getReportParametersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ReportParameter>(null, _parametersSource);
	}

	public DaoDataModel<ReportParameter> getParameters() {
		return _parametersSource;
	}
	
	public ReportParameter getActiveParameter() {
		return _activeParameter;
	}

	public void setActiveParameter(ReportParameter activeParameter) {
		_activeParameter = activeParameter;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeParameter == null && _parametersSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeParameter != null && _parametersSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeParameter.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeParameter = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_parametersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeParameter = (ReportParameter) _parametersSource.getRowData();
		selection.addKey(_activeParameter.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeParameter != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeParameter = _itemSelection.getSingleSelection();
		if (_activeParameter != null) {
			setInfo();
		}
	}

	public void setInfo() {
		// MbNameComponentsSearch compSearch =
		// (MbNameComponentsSearch)ManagedBeanWrapper.getManagedBean("MbNameComponentsSearch");
		// NameComponent componentFilter = new NameComponent();
		// componentFilter.setFormatId(_activeFormat.getId());
		// compSearch.setFilter(componentFilter);
		//		
		// NameBaseParam baseParamFilter = new NameBaseParam();
		// baseParamFilter.setEntityType(_activeFormat.getEntityType());
		// compSearch.setBaseParamFilter(baseParamFilter);
		// compSearch.setBaseValues(null);
		// compSearch.search();
	}

	public void search() {
		clearState();
		searching = true;
	}
	
	public void searchAndMerge() {
		clearState(false);
		searching = true;
	}

	public void clearFilter() {
		filter = new ReportParameter();
		clearState();
		searching = false;
	}

	public ReportParameter getFilter() {
		if (filter == null)
			filter = new ReportParameter();
		return filter;
	}

	public void setFilter(ReportParameter filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getReportId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("reportId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getReportId().toString());
			filters.add(paramFilter);
		}

		if (filter.getSystemName() != null && filter.getSystemName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("paramName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getSystemName().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newParameter = new ReportParameter();
		newParameter.setReportId(getFilter().getReportId());
		newParameter.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newParameter = (ReportParameter) _activeParameter.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newParameter = _activeParameter;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			if (isNewMode()) {
				newParameter = _reportsDao.addReportParameter(userSessionId, newParameter);
				_itemSelection.addNewObjectToList(newParameter);
			} else if (isEditMode()) {
				newParameter = _reportsDao.modifyReportParameter(userSessionId, newParameter);
				_parametersSource.replaceObject(_activeParameter, newParameter);
			}

			_activeParameter = newParameter;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_reportsDao.removeReportParameter(userSessionId, _activeParameter);
			_activeParameter = _itemSelection.removeObjectFromList(_activeParameter);
			if (_activeParameter == null) {
				clearState();
			} else {
				setInfo();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void synchronize() {
		try {
			_reportsDao.syncReportParameters(userSessionId, filter.getReportId());
			clearState();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void close() {
		curMode = VIEW_MODE;
	}

	public ReportParameter getNewParameter() {
		if (newParameter == null) {
			newParameter = new ReportParameter();
		}
		return newParameter;
	}

	public void setNewParameter(ReportParameter newParameter) {
		this.newParameter = newParameter;
	}

	public void clearState() {
		clearState(true);
	}
	
	public void clearState(boolean clearMerge) {
		_itemSelection.clearSelection();
		_activeParameter = null;
		_parametersSource.flushCache();
		if (clearMerge && mergeParams != null) {
			mergeParams.clear();
		}
		curLang = userLang;
	}

	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_parametersSource.flushCache();
	}
	
	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newParameter.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newParameter.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ReportParameter[] parameters = _reportsDao.getReportParameters(userSessionId, params);
			if (parameters != null && parameters.length > 0) {
				newParameter.setName(parameters[0].getName());
				newParameter.setDataType(parameters[0].getDataType());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancelEditLanguage() {
		newParameter.setLang(oldLang);
	}

	public Map<String, ReportParameter> getMergeParams() {
		return mergeParams;
	}

	public void setMergeParams(Map<String, ReportParameter> mergeParams) {
		this.mergeParams = mergeParams;
	}

	public List<SelectItem> getLovs() {
		if (getNewParameter().getDataType() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("DATA_TYPE", getNewParameter().getDataType());
		
		return getDictUtils().getLov(LovConstants.LOVS_LOV, params);
	}

	public List<SelectItem> getLovValues() {
		if (getNewParameter().getLovId() != null) {
			return getDictUtils().getLov(newParameter.getLovId());
		}
		return new ArrayList<SelectItem>(0);
	}
	
	public void disableLov() {
		if (getNewParameter().isDate()) {
			getNewParameter().setLovId(null);
		}
	}
	
	public void backupActiveParam() {
		if (_activeParameter != null) {
			try {
				parameterCopy = _activeParameter.clone();
			} catch (CloneNotSupportedException e) {
				parameterCopy = _activeParameter;
			}
		}
	}
	
	public void restoreActiveParam() {
		_activeParameter = parameterCopy;
	}

	public void validateBigDecimal(FacesContext context, UIComponent toValidate, Object value) {
		BigDecimal newValue;
		
		if (value instanceof BigDecimal) {
			newValue = (BigDecimal) value;
		} else if (value instanceof Double) {
			newValue = BigDecimal.valueOf((Double) value);
		} else if (value instanceof Long) {
			newValue = BigDecimal.valueOf((Long) value);
		} else {
			return;	// maybe some user defined data type
		}
		
		try {
			// checks if new value less then maximum allowed value and greater then mininum allowed value
			if (maxNumber.compareTo(newValue) == -1 || maxNumber.negate().compareTo(newValue) == 1) {
				((HtmlInputText) toValidate).setValid(false);

				// String label = ((HtmlInputText) toValidate).getLabel() != null ?
				// ((HtmlInputText) toValidate).getLabel() : ((HtmlInputText)
				// toValidate).getId();
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
						"value_mustbe_in_range", maxNumber.negate().toString(), maxNumber.toString());
				FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
				context.addMessage(toValidate.getClientId(context), message);
				return;
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
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
}
