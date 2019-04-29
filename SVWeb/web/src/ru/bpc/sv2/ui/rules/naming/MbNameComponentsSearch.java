package ru.bpc.sv2.ui.rules.naming;

import java.util.ArrayList;

import java.util.List;


import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.rules.naming.ComponentProperty;
import ru.bpc.sv2.rules.naming.NameBaseParam;
import ru.bpc.sv2.rules.naming.NameComponent;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbNameComponentsSearch")
public class MbNameComponentsSearch extends AbstractBean {
	private static final long serialVersionUID = 6525061994287434502L;

	private static final Logger logger = Logger.getLogger("RULES");

	private final String VALUE_TYPE_CONSTANT = "BVTPCNST";
	private final String VALUE_TYPE_PARAMETER = "BVTPPRMT";
	private final String VALUE_TYPE_INDEX = "BVTPINDX";
	private final String VALUE_TYPE_ARRAY = "BVTPARRY";
	
	private RulesDao _rulesDao = new RulesDao();

	private boolean showPropsTable;

	private NameComponent filter;
	private NameBaseParam baseParamFilter;
	private NameComponent _activeComponent;
	private NameComponent newComponent;

	private String backLink;
	private boolean selectMode;
	private MbNameComponentPropertiesSearch propSearch;
	private final DaoDataModel<NameComponent> _componentsSource;

	private final TableRowSelection<NameComponent> _itemSelection;
	
	private ArrayList<SelectItem> parameterBaseValues;
	private ArrayList<SelectItem> arrayBaseValues;
	
	private static String COMPONENT_ID = "componentsTable";
	private String tabName;
	private String parentSectionId;

	public MbNameComponentsSearch() {
		propSearch = (MbNameComponentPropertiesSearch) ManagedBeanWrapper
				.getManagedBean("MbNameComponentPropertiesSearch");
		_componentsSource = new DaoDataModel<NameComponent>() {
			private static final long serialVersionUID = -4652029894304995897L;

			@Override
			protected NameComponent[] loadDaoData(SelectionParams params) {
				try {
					if (!searching || getFilter().getFormatId() == null) {
						return new NameComponent[0];
					}
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getNameComponents(userSessionId, params);
				} catch (DataAccessException ee) {
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
					return new NameComponent[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					if (!searching || getFilter().getFormatId() == null) {
						return 0;
					}
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getNameComponentsCount(userSessionId, params);
				} catch (DataAccessException ee) {
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<NameComponent>(null, _componentsSource);
	}

	public DaoDataModel<NameComponent> getComponents() {
		return _componentsSource;
	}

	public NameComponent getActiveComponent() {
		return _activeComponent;
	}

	public void setActiveComponent(NameComponent activeComponent) {
		_activeComponent = activeComponent;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeComponent == null && _componentsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeComponent != null && _componentsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeComponent.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeComponent = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeComponent = _itemSelection.getSingleSelection();
		if (_activeComponent != null) {
			setInfo();
		}
	}

	public void setFirstRowActive() {
		_componentsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeComponent = (NameComponent) _componentsSource.getRowData();
		selection.addKey(_activeComponent.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeComponent != null) {
			setInfo();
		}
	}

	public void setInfo() {
		ComponentProperty propertyFilter = new ComponentProperty();
		propertyFilter.setComponentId(_activeComponent.getId());
		propertyFilter.setEntityType(getBaseParamFilter().getEntityType());
		propSearch.setFilter(propertyFilter);
		propSearch.setStoredProperties(null);
		propSearch.setDontSave(false);
		propSearch.search();
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new NameComponent();
		clearState();
		searching = false;
	}

	public NameComponent getFilter() {
		if (filter == null)
			filter = new NameComponent();
		return filter;
	}

	public void setFilter(NameComponent filter) {
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
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		if (filter.getFormatId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("formatId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getFormatId().toString());
			filters.add(paramFilter);
		}

	}

	public void add() {
		newComponent = new NameComponent();
		newComponent.setTransformationType("TSFTNOTR");
		newComponent.setFormatId(getFilter().getFormatId());
		ComponentProperty propFilter = new ComponentProperty();
		propFilter.setEntityType(getBaseParamFilter().getEntityType());
		propFilter.setComponentId(-1);
		propSearch.setCurMode(MbNameComponentPropertiesSearch.NEW_MODE);
		propSearch.setFilter(propFilter);
		propSearch.fullCleanBean();
		propSearch.setDontSave(true);
		propSearch.setSearching(true);
		propSearch.search();
		showPropsTable();

		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newComponent = (NameComponent) _activeComponent.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newComponent = _activeComponent;
		}
		// ComponentProperty propFilter = new ComponentProperty();
		// propFilter.setEntityType(getBaseParamFilter().getEntityType());
		propSearch.setCurMode(MbNameComponentPropertiesSearch.EDIT_MODE);
		propSearch.setDontSave(true);
		showPropsTable();
		// propSearch.search();
		curMode = EDIT_MODE;
	}

	private boolean showPropsTable() {
		showPropsTable = false;
		// to find out whether we should show properties table or not
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("entityType");
			filters[0].setValue(getBaseParamFilter().getEntityType());
			params.setFilters(filters);
			ComponentProperty[] props = _rulesDao.getNameComponentPropertiesValues(userSessionId,
					params);
			if (props.length > 0) {
				showPropsTable = true;
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return showPropsTable;
	}

	public void view() {

	}

	public void save() {
		try {
			List<ComponentProperty> props = null;

			if (isEditMode()) {
				props = propSearch.getProperties().getActivePage();
			} else if (isNewMode()) {
				props = propSearch.getStoredProperties();
			}
			if (props != null) {
				for (ComponentProperty prop: props) {
					if (prop.getValue() == null || prop.getValue().trim().length() == 0) {
						throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul",
								"not_all_properties_are_filled"));
					}
				}
			}
			newComponent = _rulesDao.syncNameComponentAndProperties(userSessionId, newComponent,
					props);
			if (isEditMode()) {
				_componentsSource.replaceObject(_activeComponent, newComponent);
			} else {
				_itemSelection.addNewObjectToList(newComponent);
			}
			_activeComponent = newComponent;
			propSearch.setCurMode(MbNameComponentPropertiesSearch.VIEW_MODE);
			curMode = VIEW_MODE;

			setInfo();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_rulesDao.deleteNameComponent(userSessionId, _activeComponent);
			_activeComponent = _itemSelection.removeObjectFromList(_activeComponent);
			if (_activeComponent == null) {
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

	public void close() {
		propSearch.setCurMode(MbNameComponentPropertiesSearch.VIEW_MODE);
		curMode = VIEW_MODE;
	}

	public NameComponent getNewComponent() {
		if (newComponent == null) {
			newComponent = new NameComponent();
		}
		return newComponent;
	}

	public void setNewComponent(NameComponent newComponent) {
		this.newComponent = newComponent;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeComponent = null;
		_componentsSource.flushCache();
		parameterBaseValues = null;
		arrayBaseValues = null;
	}

	public ArrayList<SelectItem> getPadTypes() {
		return getDictUtils().getArticles(DictNames.PAD_TYPES, true, false);
	}

	public ArrayList<SelectItem> getBaseValueTypes() {
		return getDictUtils().getArticles(DictNames.BASE_VALUE_TYPES, true, false);
	}

	public ArrayList<SelectItem> getTransformationTypes() {
		return getDictUtils().getArticles(DictNames.TRANSFORMATION_TYPES, false, false);
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public ArrayList<SelectItem> getBaseValues() {
		ArrayList<SelectItem> result = null;
		if (isArrayValue()){
			if (arrayBaseValues == null){
				arrayBaseValues = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.FUNCTION_OF_ARRAY_PARAM);
			}
			result = arrayBaseValues;
		} else if (isParameterValue()){
			if (parameterBaseValues == null){
				ArrayList<SelectItem> items = new ArrayList<SelectItem>();
				try {
					SelectionParams params = new SelectionParams();
					List<Filter> filtersBaseParams = new ArrayList<Filter>();

					Filter paramFilter = new Filter();
					paramFilter.setElement("entityType");
					paramFilter.setOp(Operator.eq);
					paramFilter.setValue(getBaseParamFilter().getEntityType());
					filtersBaseParams.add(paramFilter);

					paramFilter = new Filter();
					paramFilter.setElement("lang");
					paramFilter.setOp(Operator.eq);
					paramFilter.setValue(SessionWrapper.getField("language"));
					filtersBaseParams.add(paramFilter);

					params.setFilters(filtersBaseParams.toArray(new Filter[filtersBaseParams.size()]));
					params.setRowIndexEnd(-1);

					NameBaseParam[] values = _rulesDao.getNameBaseParams(userSessionId, params);
					for (NameBaseParam value: values) {
						items.add(new SelectItem(value.getName(), value.getName(), value
								.getDescription()));
					}
					parameterBaseValues = items;
				} catch (Exception e) {
					logger.error("", e);
					if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
						FacesUtils.addMessageError(e);
					}
				} 
			}
			result = parameterBaseValues;
		}
		if (result == null){
			result = new ArrayList<SelectItem>();
		}
		return result;
	}

	public NameBaseParam getBaseParamFilter() {
		return baseParamFilter;
	}

	public void setBaseParamFilter(NameBaseParam baseParamFilter) {
		this.baseParamFilter = baseParamFilter;
	}

	public void changeValueType() {
		getNewComponent().setBaseValue(null);
	}

	public boolean isShowPropsTable() {
		return showPropsTable;
	}

	public void setShowPropsTable(boolean showPropsTable) {
		this.showPropsTable = showPropsTable;
	}
	
	public boolean isConstantValue() {
		return VALUE_TYPE_CONSTANT.equals(getNewComponent().getBaseValueType());
	}

	public boolean isParameterValue() {
		return VALUE_TYPE_PARAMETER.equals(getNewComponent().getBaseValueType());
	}
	
	public boolean isIndexValue(){
		return VALUE_TYPE_INDEX.equals(getNewComponent().getBaseValueType());
	}
	
	public boolean isArrayValue(){
		return VALUE_TYPE_ARRAY.equals(getNewComponent().getBaseValueType());
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
