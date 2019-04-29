package ru.bpc.sv2.ui.rules;

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
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.ModParam;
import ru.bpc.sv2.rules.ModScale;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbModifiers")
public class MbModifiers extends AbstractBean {
	private static final long serialVersionUID = 5074651410423935966L;

	private static final Logger logger = Logger.getLogger("RULES");

	private RulesDao _rulesDao = new RulesDao();
	
	private Modifier modifierFilter;
	private Modifier _activeModifier;
	private Modifier newModifier;
	private SqlConditionFormatter conditionFormatter;

	private ModScale modScale;
	private Map<Integer, ModParam> paramsMap;
	private ModParam selectedParam;
	private Integer selectedParamId;
	
	private static String COMPONENT_ID = "modsTable";
	private String tabName;
	private String parentSectionId;

	private final DaoDataModel<Modifier> _modifierSource;

	private final TableRowSelection<Modifier> _itemSelection;

	public MbModifiers() {
		_modifierSource = new DaoDataModel<Modifier>() {
			private static final long serialVersionUID = -3965531223031124319L;

			@Override
			protected Modifier[] loadDaoData(SelectionParams params) {
				if (modScale == null || !searching) {
					return new Modifier[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getModifiers(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Modifier[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (modScale == null || !searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getModifiersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Modifier>(null, _modifierSource);
	}

	public DaoDataModel<Modifier> getModifiers() {
		return _modifierSource;
	}

	public Modifier getActiveModifier() {
		return _activeModifier;
	}

	public void setActiveModifier(Modifier activeModifier) {
		_activeModifier = activeModifier;
	}

	public SimpleSelection getItemSelection() {
		if (_activeModifier == null && _modifierSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeModifier != null && _modifierSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeModifier.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeModifier = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeModifier = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_modifierSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeModifier = (Modifier) _modifierSource.getRowData();
		selection.addKey(_activeModifier.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeModifier != null) {
			// setInfo();
		}
	}

	public void search() {
		clearState();
		setSearching(true);
	}

	public Modifier getFilter() {
		if (modifierFilter == null)
			modifierFilter = new Modifier();
		return modifierFilter;
	}

	public void setFilter(Modifier filter) {
		this.modifierFilter = filter;
	}

	private void setFilters() {
		modifierFilter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (modScale.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("scaleId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(modScale.getId().toString());
			filters.add(paramFilter);
		}

		if (modifierFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(modifierFilter.getId().toString());
			filters.add(paramFilter);
		}

		if (modifierFilter.getName() != null
				&& modifierFilter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(modifierFilter.getName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (modifierFilter.getDescription() != null
				&& modifierFilter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(modifierFilter.getDescription().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (modifierFilter.getCondition() != null
				&& modifierFilter.getCondition().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("condition");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(modifierFilter.getCondition().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

	}

	public void add() {
		curMode = NEW_MODE;

		newModifier = new Modifier();
		newModifier.setScaleId(modScale.getId());
		newModifier.setLang(userLang);
		selectedParam = new ModParam();
		selectedParamId = null;

		conditionFormatter = null;
		getConditionFormatter();
	}

	public void edit() {
		curMode = EDIT_MODE;

		newModifier = (Modifier) _activeModifier.clone();
		
		selectedParam = new ModParam();
		selectedParamId = null;
		conditionFormatter = null;
		getConditionFormatter();
	}

	public void save() {
		try {
			if (isEditMode()) {
				_rulesDao.modifyModifier(userSessionId, newModifier);
				if (!curLang.equals(newModifier.getLang())) {
					newModifier = getNodeByLang(_activeModifier.getId(), curLang);
				}
				_modifierSource.replaceObject(_activeModifier, newModifier);
			} else {
				_rulesDao.addModifier(userSessionId, newModifier);
				_itemSelection.addNewObjectToList(newModifier);
			}
			_activeModifier = newModifier;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul",
					"modifier_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_rulesDao.deleteModifier(userSessionId, _activeModifier);
			
			_activeModifier = _itemSelection.removeObjectFromList(_activeModifier);
			if (_activeModifier == null) {
				clearState();
			}
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul",
					"modifier_deleted"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void close() {
		curMode = VIEW_MODE;
	}

	public Modifier getNewModifier() {
		if (newModifier == null) {
			newModifier = new Modifier();
		}
		return newModifier;
	}

	public void setNewModifier(Modifier newModifier) {
		this.newModifier = newModifier;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeModifier = null;
		_modifierSource.flushCache();
		curLang = userLang;
	}

	public void fullCleanBean() {
		clearState();
		modScale = null;
	}
	
	public ModScale getModScale() {
		return modScale;
	}

	public void setModScale(ModScale modScale) {
		this.modScale = modScale;
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
		if (modScale != null) {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);
			List<Filter> filters = new ArrayList<Filter>();

			Filter filter = new Filter();
			filter.setElement("scaleId");
			filter.setOp(Operator.eq);
			filter.setValue(modScale.getId().toString());
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
		} else {
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
		if (newModifier.getCondition() == null || newModifier.getCondition().equals("")) {
			newModifier.setCondition("");	// just to be sure it's not null
			conditionFormatter.setPrependCondition(false);
		} else {
			conditionFormatter.setPrependCondition(true);
		}
		String cond = conditionFormatter.formCondition();
		if (cond != null && cond.length() > 0) {
			newModifier.setCondition(newModifier.getCondition() + cond);
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

	public void changeLang(ValueChangeEvent event) {

	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_modifierSource.flushCache();
	}
	
	public void confirmEditLanguage() {
//		curLang = newModifier.getLang();
		Modifier tmp = getNodeByLang(newModifier.getId(), newModifier.getLang());
		if (tmp != null) {
			newModifier.setName(tmp.getName());
			newModifier.setDescription(tmp.getDescription());
		}
	}
	
	public Modifier getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id.toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Modifier[] modifiers = _rulesDao.getModifiers(userSessionId, params);
			if (modifiers != null && modifiers.length > 0) {
				return modifiers[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void view() {
		curMode = VIEW_MODE;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
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
