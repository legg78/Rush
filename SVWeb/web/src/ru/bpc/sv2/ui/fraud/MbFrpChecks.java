package ru.bpc.sv2.ui.fraud;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.UIInput;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.faces.validator.ValidatorException;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.conditions.SqlConditionFormatter;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fraud.Check;
import ru.bpc.sv2.fraud.Matrix;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.FraudDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.ModParam;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbFrpChecks")
public class MbFrpChecks extends AbstractBean {
	private static final long serialVersionUID = 1792573326938276350L;

	private static final Logger logger = Logger.getLogger("FRAUD_PREVENTION");

	private final int CHECKS_SCALE = 1011;
	private final String MATRIX_CHECK = "CHTPMTRX";
	private final String EXPRESSION_CHECK = "CHTPEXPR";
	private final String COMBINED_CHECK = "CHTPEXMT";
	
	private final int PARAM_PARAM = 1;
	private final int ALERT_PARAM = 2;
	private final int MATRIX_PARAM = 4;
	private int parameterType = PARAM_PARAM; 
	
	private FraudDao _fraudDao = new FraudDao();

	private RulesDao _rulesDao = new RulesDao();
	
	private Check filter;
	private Check _activeCheck;
	private Check newCheck;

	private final DaoDataModel<Check> _checksSource;
	private final TableRowSelection<Check> _itemSelection;
	
	private Integer instId;
	
	private SqlConditionFormatter conditionFormatter;
	private Map<Integer, ModParam> paramsMap;
	private ModParam selectedParam;
	private Integer selectedParamId;
	private Integer selectedAlmaId;
	
	private static String COMPONENT_ID = "checksTable";
	private String tabName;
	private String parentSectionId;
	
	public MbFrpChecks() {
		_checksSource = new DaoDataModel<Check>() {
			private static final long serialVersionUID = -2989529516184962699L;

			@Override
			protected Check[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Check[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getChecks(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Check[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getChecksCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Check>(null, _checksSource);
	}

	public DaoDataModel<Check> getChecks() {
		return _checksSource;
	}

	public Check getActiveCheck() {
		return _activeCheck;
	}

	public void setActiveCheck(Check activeCheck) {
		_activeCheck = activeCheck;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeCheck == null && _checksSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCheck != null && _checksSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCheck.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCheck = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_checksSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCheck = (Check) _checksSource.getRowData();
		selection.addKey(_activeCheck.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCheck = _itemSelection.getSingleSelection();
		if (_activeCheck != null) {
			setBeans();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setBeans() {

	}

	public void clearBeansStates() {

	}

	public void fullCleanBean() {
		clearFilter();
	}
	
	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public Check getFilter() {
		if (filter == null) {
			filter = new Check();
		}
		return filter;
	}

	public void setFilter(Check filter) {
		this.filter = filter;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getCaseId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("caseId");
			paramFilter.setValue(filter.getCaseId());
			filters.add(paramFilter);
		}
		if (filter.getCheckType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("checkType");
			paramFilter.setValue(filter.getCheckType());
			filters.add(paramFilter);
		}
		if (filter.getAlertType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("alertType");
			paramFilter.setValue(filter.getAlertType());
			filters.add(paramFilter);
		}
		if (filter.getExpression() != null && filter.getExpression().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("expression");
			paramFilter.setValue(filter.getExpression().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getRiskScore() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("riskScore");
			paramFilter.setValue(filter.getRiskScore());
			filters.add(paramFilter);
		}
		if (filter.getRiskMatrixId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("riskMatrix");
			paramFilter.setValue(filter.getRiskMatrixId());
			filters.add(paramFilter);
		}
		if (filter.getLabel() != null && filter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setValue(filter.getLabel().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newCheck = new Check();
		newCheck.setCaseId(getFilter().getCaseId());
		newCheck.setLang(userLang);
		curMode = NEW_MODE;
		
		clearFormatter();
	}

	private void clearFormatter() {
		selectedParam = new ModParam();
		selectedParamId = null;
		selectedAlmaId = null;

		conditionFormatter = new SqlConditionFormatter();
	}
	
	public void edit() {
		try {
			newCheck = (Check) _activeCheck.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCheck = _activeCheck;
		}
		clearFormatter();
		curMode = EDIT_MODE;
	}

	public void save() {
		if (MATRIX_CHECK.equals(newCheck.getCheckType())) {
			newCheck.setExpression(null);
		} else if (EXPRESSION_CHECK.equals(newCheck.getCheckType())) {
			newCheck.setRiskMatrixId(null);
		}
		try {
			if (isNewMode()) {
				newCheck = _fraudDao.addCheck(userSessionId, newCheck);
				_itemSelection.addNewObjectToList(newCheck);
			} else if (isEditMode()) {
				newCheck = _fraudDao.modifyCheck(userSessionId, newCheck);
				_checksSource.replaceObject(_activeCheck, newCheck);
			}
			_activeCheck = newCheck;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_fraudDao.removeCheck(userSessionId, _activeCheck);
			_activeCheck = _itemSelection.removeObjectFromList(_activeCheck);

			if (_activeCheck == null) {
				clearState();
			} else {
				setBeans();
			}

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Check getNewCheck() {
		if (newCheck == null) {
			newCheck = new Check();
		}
		return newCheck;
	}

	public void setNewCheck(Check newCheck) {
		this.newCheck = newCheck;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeCheck = null;
		_checksSource.flushCache();

		clearBeansStates();
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public ArrayList<SelectItem> getCheckTypes() {
		return getDictUtils().getArticles(DictNames.CHECK_TYPE, false);
	}

	public ArrayList<SelectItem> getAlertTypes() {
		return getDictUtils().getArticles(DictNames.ALERT_TYPE, false);
	}
	
	public ArrayList<SelectItem> getRiskMatrices() {
		if (instId != null) {
			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("instId");
			filters[0].setValue(instId);
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(curLang);
			filters[2] = new Filter();
			filters[2].setElement("matrixType");
			filters[2].setValue("MTTPRISK");
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			
			try {
				Matrix[] matrices = _fraudDao.getMatrices(userSessionId, params);
				ArrayList<SelectItem> items = new ArrayList<SelectItem>(matrices.length);
				
				for (Matrix matrix: matrices) {
					items.add(new SelectItem(matrix.getId(), matrix.getLabel()));
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public ArrayList<SelectItem> getBooleanMatrices() {
		if (instId != null) {
			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("instId");
			filters[0].setValue(instId);
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(curLang);
			filters[2] = new Filter();
			filters[2].setElement("matrixType");
			filters[2].setValue("MTTPBOOL");
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			
			try {
				Matrix[] matrices = _fraudDao.getMatrices(userSessionId, params);
				ArrayList<SelectItem> items = new ArrayList<SelectItem>(matrices.length);
				
				for (Matrix matrix: matrices) {
					items.add(new SelectItem(matrix.getId(), matrix.getLabel()));
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public SqlConditionFormatter getConditionFormatter() {
		if (conditionFormatter == null)
			conditionFormatter = new SqlConditionFormatter();
		return conditionFormatter;
	}

	public void setConditionFormatter(SqlConditionFormatter conditionFormatter) {
		this.conditionFormatter = conditionFormatter;
	}

	public ArrayList<SelectItem> getParamsMap() {
		if (isParamParameter()) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("scaleId");
			filters[0].setValue(CHECKS_SCALE);
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(userLang);
	
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters);
	
			try {
				ModParam[] modParams = _rulesDao.getModParamsByScaleId(userSessionId,
						params);
				paramsMap = new HashMap<Integer, ModParam>(modParams.length);
				ArrayList<SelectItem> items = new ArrayList<SelectItem>(modParams.length + 1);
				for (ModParam modParam : modParams) {
					items.add(new SelectItem(modParam.getId(), modParam.getName()));
					paramsMap.put(modParam.getId(), modParam);
				}
				
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
				paramsMap = new HashMap<Integer, ModParam>(0);
			}
		} else if (isAlertParameter()) {
			return getAlerts();
		} else if (isMatrixParameter()) {
			return getBooleanMatrices();
		}

		return new ArrayList<SelectItem>(0);
	}

	public void applyParamToFormatter(ValueChangeEvent event) {
		Integer modParamId = (Integer) event.getNewValue();
		if (modParamId != null) {
			selectedParam = paramsMap.get(modParamId);
			conditionFormatter.setParamName(paramsMap.get(modParamId).getSystemName());
			conditionFormatter.setParamDataType(paramsMap.get(modParamId).getDataType());
		} else {
			conditionFormatter.setParamName(null);
			conditionFormatter.setParamDataType(null);
		}
	}

	/**
	 * Applies selected alert or matrix to formatter
	 * @param event
	 */
	public void applyAlmaToFormatter(ValueChangeEvent event) {
		Integer modParamId = (Integer) event.getNewValue();
		if (isMatrixParameter()){
			conditionFormatter.setParamName("MATRIX_" + modParamId);
		} else if (isAlertParameter()) {
			conditionFormatter.setParamName("ALERT_" + modParamId);
		} else {
			conditionFormatter.setParamName(null);
		}
		conditionFormatter.setParamDataType(null);
	}

	/**
	 * Validates parameter value on whether it's numeric when data type for this
	 * field is NUMBER.
	 * 
	 * @param context
	 * @param toValidate
	 *            - JSF's input component where parameter value is entered
	 * @param value
	 */
	public void validateParamValue(FacesContext context, UIComponent toValidate,
			Object value) {
		String paramValue = (String) value;

		if (selectedParam != null && DataTypes.NUMBER.equals(selectedParam.getDataType())) {
			try {
				Double.parseDouble(paramValue);
			} catch (NumberFormatException e) {
				((UIInput) toValidate).setValid(false);

				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
						"numeric_value");
				FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg,
						msg);
				context.addMessage(toValidate.getClientId(context), message);
				logger.error("", e);
				throw new ValidatorException(message);
			}
		}
	}

	public void addToCondition() {
		if (newCheck.getExpression() == null || newCheck.getExpression().equals("")) {
			conditionFormatter.setPrependCondition(false);
		} else {
			conditionFormatter.setPrependCondition(true);
		}
		String cond = "";
		if (isAlertParameter()) {
			if (conditionFormatter.getDepth() != null) {
				cond = conditionFormatter.getParamName() + "(" + conditionFormatter.getDepth() + ")";
				if (conditionFormatter.isPrependCondition()) {
					cond = " " + conditionFormatter.getOperation() + " " + cond;
				}
			}
		} else {
			if (isParamParameter() && conditionFormatter.getDepth() == null) 
				conditionFormatter.setDepth(1);
			cond = conditionFormatter.formCondition();
		}
		if (cond != null && cond.length() > 0) {
			newCheck.setExpression(newCheck.getExpression() + cond);
		}
		conditionFormatter.setValue(null);
	}

	public ModParam getSelectedParam() {
		if (selectedParam == null) {
			selectedParam = new ModParam();
		}
		return selectedParam;
	}

	public void setSelectedParam(ModParam selectedParam) {
		this.selectedParam = selectedParam;
	}

	public Integer getSelectedParamId() {
		return selectedParamId;
	}

	public void setSelectedParamId(Integer selectedParamId) {
		this.selectedParamId = selectedParamId;
		selectedParam = paramsMap.get(selectedParamId);
	}

	public List<SelectItem> getParamLovValues() {
		if (selectedParam.getLovId() != null)
			return getDictUtils().getLov(selectedParam.getLovId());
		else
			return new ArrayList<SelectItem>(0);
	}

	public boolean isMatrixNeeded() {
		return MATRIX_CHECK.equals(getNewCheck().getCheckType())
				|| COMBINED_CHECK.equals(getNewCheck().getCheckType());
	}

	public boolean isExpressionNeeded() {
		return EXPRESSION_CHECK.equals(getNewCheck().getCheckType())
				|| COMBINED_CHECK.equals(getNewCheck().getCheckType());
	}
	
	public ArrayList<SelectItem> getAlerts() {
		if (getFilter().getCaseId() != null) {
			ArrayList<Filter> filters = new ArrayList<Filter>();
			Filter filter = new Filter();
			filter.setElement("lang");
			filter.setValue(curLang);
			filters.add(filter);
			
			filter = new Filter();
			filter.setElement("caseId");
			filter.setValue(this.filter.getCaseId());
			filters.add(filter);
			
			if (getNewCheck().getId() != null) {
				filter = new Filter();
				filter.setElement("excludeIds");
				filter.setValue(_activeCheck.getId());
				filters.add(filter);
			}
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexEnd(Integer.MAX_VALUE);
			
			try {
				Check[] alerts = _fraudDao.getChecks(userSessionId, params);
				ArrayList<SelectItem> items = new ArrayList<SelectItem>(alerts.length);
				
				for (Check alert: alerts) {
					items.add(new SelectItem(alert.getId(), alert.getLabel()));
				}
				
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}
	
	public int getParameterTypeParam() {
		return PARAM_PARAM;
	}
	
	public int getParameterTypeAlert() {
		return ALERT_PARAM;
	}

	public int getParameterTypeMatrix() {
		return MATRIX_PARAM;
	}

	public int getParameterType() {
		return parameterType;
	}

	public void setParameterType(int parameterType) {
		this.parameterType = parameterType;
	}

	public boolean isParamParameter() {
		return parameterType == PARAM_PARAM;
	}

	public boolean isAlertParameter() {
		return parameterType == ALERT_PARAM;
	}

	public boolean isMatrixParameter() {
		return parameterType == MATRIX_PARAM;
	}
	
	public Integer getSelectedAlmaId() {
		return selectedAlmaId;
	}

	public void setSelectedAlmaId(Integer selectedAlmaId) {
		this.selectedAlmaId = selectedAlmaId;
	}

	public void changeParameterType(ValueChangeEvent event) {
		conditionFormatter.setValue(null);
		conditionFormatter.setDepth(null);
		selectedParam = null;
		selectedAlmaId = null;
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newCheck.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newCheck.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Check[] checks = _fraudDao.getChecks(userSessionId, params);
			if (checks != null && checks.length > 0) {
				newCheck = checks[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void generatePackage() {
		try {
			_fraudDao.generatePackage(userSessionId);
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
