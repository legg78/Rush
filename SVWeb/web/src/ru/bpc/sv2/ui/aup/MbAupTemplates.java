package ru.bpc.sv2.ui.aup;

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

import ru.bpc.sv2.aup.AuthTemplate;
import ru.bpc.sv2.conditions.SqlConditionFormatter;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AuthProcessingDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.ModParam;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbAupTemplates")
public class MbAupTemplates extends AbstractBean {

	private static final long serialVersionUID = 5639558575239550678L;

	private static final Logger logger = Logger.getLogger("AUTH_PROCESSING");

	private static String COMPONENT_ID = "1863:templatesTable";

	private static final int SCALE_ID = 1005;

	private AuthProcessingDao _aupDao = new AuthProcessingDao();
	private RulesDao _rulesDao = new RulesDao();

	private List<Filter> filters;
	private AuthTemplate filter;
	private AuthTemplate newTemplate;
	private AuthTemplate detailTemplate;

	private SqlConditionFormatter conditionFormatter;
	private Map<Integer, ModParam> paramsMap;
	private ModParam selectedParam;
	private Integer selectedParamId;

	private final DaoDataModel<AuthTemplate> _templatesSource;
	private final TableRowSelection<AuthTemplate> _itemSelection;
	private AuthTemplate _activeTemplate;
	private String tabName;
	private String oldLang;

	public MbAupTemplates() {
		pageLink = "aup|templates";
		_templatesSource = new DaoDataModel<AuthTemplate>() {
			private static final long serialVersionUID = -5348098907645693203L;

			@Override
			protected AuthTemplate[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AuthTemplate[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _aupDao.getTemplates(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AuthTemplate[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _aupDao.getTemplatesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AuthTemplate>(null, _templatesSource);
	}

	public DaoDataModel<AuthTemplate> getTemplates() {
		return _templatesSource;
	}

	public AuthTemplate getActiveTemplate() {
		return _activeTemplate;
	}

	public void setActiveTemplate(AuthTemplate activeTemplate) {
		_activeTemplate = activeTemplate;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeTemplate == null && _templatesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeTemplate != null && _templatesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeTemplate.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeTemplate = _itemSelection.getSingleSelection();
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeTemplate.getId())) {
				changeSelect = true;
			}
			_activeTemplate = _itemSelection.getSingleSelection();
	
			if (_activeTemplate != null) {
				setBeans();
				if (changeSelect) {
					detailTemplate = (AuthTemplate) _activeTemplate.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_templatesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTemplate = (AuthTemplate) _templatesSource.getRowData();
		selection.addKey(_activeTemplate.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeTemplate != null) {
			setBeans();
			detailTemplate = (AuthTemplate) _activeTemplate.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void search() {
		curLang = userLang;
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new AuthTemplate();
		searching = false;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
			        .replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getTemplType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("templType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getTemplType());
			filters.add(paramFilter);
		}

		if (filter.getRespCode() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("respCode");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getRespCode());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newTemplate = new AuthTemplate();
		newTemplate.setLang(userLang);
		curLang = newTemplate.getLang();
		newTemplate.setScaleId(SCALE_ID);

		if (filter.getModId() != null) {
			newTemplate.setModId(filter.getModId());
		}
		curMode = NEW_MODE;

		selectedParam = new ModParam();
		selectedParamId = null;

		conditionFormatter = null;
		getConditionFormatter();
	}

	public void edit() {
		try {
			newTemplate = (AuthTemplate) detailTemplate.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_aupDao.deleteTemplate(userSessionId, _activeTemplate);

			_activeTemplate = _itemSelection.removeObjectFromList(_activeTemplate);
			if (_activeTemplate == null) {
				clearBean();
			} else {
				setBeans();
				detailTemplate = (AuthTemplate) _activeTemplate.clone();
			}
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Aup",
			        "template_deleted"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isEditMode()) {
				newTemplate = _aupDao.editTemplate(userSessionId, newTemplate);
				detailTemplate = (AuthTemplate) newTemplate.clone();
				//adjust newProvider according userLang
				if (!userLang.equals(newTemplate.getLang())) {
					newTemplate = getNodeByLang(_activeTemplate.getId(), userLang);
				}
				_templatesSource.replaceObject(_activeTemplate, newTemplate);
			} else {
				newTemplate = _aupDao.addTemplate(userSessionId, newTemplate);
				detailTemplate = (AuthTemplate) newTemplate.clone();
				_itemSelection.addNewObjectToList(newTemplate);
			}
			_activeTemplate = newTemplate;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Aup",
			        "template_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public AuthTemplate getFilter() {
		if (filter == null) {
			filter = new AuthTemplate();
		}
		return filter;
	}

	public void setFilter(AuthTemplate filter) {
		this.filter = filter;
	}

	public AuthTemplate getNewTemplate() {
		if (newTemplate == null) {
			newTemplate = new AuthTemplate();
		}
		return newTemplate;
	}

	public void setNewTemplate(AuthTemplate newTemplate) {
		this.newTemplate = newTemplate;
	}

	public void clearBean() {
		_templatesSource.flushCache();
		_itemSelection.clearSelection();
		_activeTemplate = null;
		detailTemplate = null;
		// clear dependent bean
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public ArrayList<SelectItem> getTemplateTypes() {
		return getDictUtils().getArticles(DictNames.TEMPLATE_TYPE, false, true);
	}

	public List<SelectItem> getResponseCodes() {
		return getDictUtils().getLov(LovConstants.RESPONSE_CODES);
	}

	public SqlConditionFormatter getConditionFormatter() {
		if (conditionFormatter == null) {
			conditionFormatter = new SqlConditionFormatter();
			conditionFormatter.setParameterPrefix(":");
		}
		return conditionFormatter;
	}

	public void setConditionFormatter(SqlConditionFormatter conditionFormatter) {
		this.conditionFormatter = conditionFormatter;
	}

	public ArrayList<SelectItem> getParamsMap() {
		ArrayList<SelectItem> items;
		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		List<Filter> filters = new ArrayList<Filter>();

		Filter filter = new Filter();
		filter.setElement("scaleId");
		filter.setOp(Operator.eq);
		filter.setValue(SCALE_ID);
		filters.add(filter);

		filter = new Filter();
		filter.setElement("lang");
		filter.setOp(Operator.eq);
		filter.setValue(userLang);
		filters.add(filter);

		params.setFilters(filters.toArray(new Filter[filters.size()]));

		try {
			ModParam[] modParams = _rulesDao.getModParamsByScaleId(userSessionId,
			            params);
			paramsMap = new HashMap<Integer, ModParam>(modParams.length);
			items = new ArrayList<SelectItem>(modParams.length + 1);
			items.add(new SelectItem(""));
			for (ModParam modParam : modParams) {
				items.add(new SelectItem(modParam.getId(), modParam.getName()));
				paramsMap.put(modParam.getId(), modParam);
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			paramsMap = new HashMap<Integer, ModParam>(0);
			items = new ArrayList<SelectItem>(0);
		}

		return items;
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
	 * Validates parameter value on whether it's numeric when data type for this
	 * field is NUMBER.
	 * 
	 * @param context
	 * @param toValidate
	 *            - JSF's input component where parameter value is entered
	 * @param value
	 */
	public void validateParamValue(FacesContext context, UIComponent toValidate,
	                               Object value)
	{
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
		if (newTemplate.getCondition() == null || newTemplate.getCondition().equals("")) {
			conditionFormatter.setPrependCondition(false);
		} else {
			conditionFormatter.setPrependCondition(true);
		}
		String cond = conditionFormatter.formCondition();
		if (cond != null && cond.length() > 0) {
			newTemplate.setCondition(newTemplate.getCondition() + cond);
		}
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
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailTemplate = getNodeByLang(detailTemplate.getId(), curLang);
	}
	
	public AuthTemplate getNodeByLang(Integer id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(String.valueOf(id));
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			AuthTemplate[] templates = _aupDao.getTemplates(userSessionId, params);
			if (templates != null && templates.length > 0) {
				return templates[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newTemplate.getLang();
		AuthTemplate tmp = getNodeByLang(newTemplate.getId(), newTemplate.getLang());
		if (tmp != null) {
			newTemplate.setName(tmp.getName());
			newTemplate.setDescription(tmp.getDescription());
		}
	}

	public void cancelEditLanguage() {
		newTemplate.setLang(oldLang);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public AuthTemplate getDetailTemplate() {
		return detailTemplate;
	}

	public void setDetailTemplate(AuthTemplate detailTemplate) {
		this.detailTemplate = detailTemplate;
	}
	
	public boolean isTemplTypePositive(){
		if (newTemplate != null){
			if ("AUTM0001".equalsIgnoreCase(newTemplate.getTemplType())){
				return true;
			}else{
				return false;
			}
		}else {
			return false;
		}
	}

}
