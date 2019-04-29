package ru.bpc.sv2.ui.common.flexible;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.FlexField;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbFlexFieldsSearch")
public class MbFlexFieldsSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "1250:fieldsTable";

	private CommonDao _commonDao = new CommonDao();

	private FlexField filter;
	private FlexField _activeFlexField;
	private FlexField newFlexField;

	private String backLink;
	private ArrayList<SelectItem> institutions;
	private List<SelectItem> objectTypes;

	private final DaoDataModel<FlexField> _flexFieldsSource;

	private final TableRowSelection<FlexField> _itemSelection;
	private ArrayList<SelectItem> dataTypes;

	protected String tabName;

	public MbFlexFieldsSearch() {
        tabName = "detailsTab";
		pageLink = "common|flexible_fields";
		_flexFieldsSource = new DaoDataModel<FlexField>() {
			@Override
			protected FlexField[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new FlexField[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getFlexFields(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new FlexField[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getFlexFieldsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<FlexField>(null, _flexFieldsSource);
	}

	public DaoDataModel<FlexField> getFlexFields() {
		return _flexFieldsSource;
	}

	public FlexField getActiveFlexField() {
		return _activeFlexField;
	}

	public void setActiveFlexField(FlexField flexField) {
		_activeFlexField = flexField;
	}

	public SimpleSelection getItemSelection() {
		if (_activeFlexField == null && _flexFieldsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeFlexField != null && _flexFieldsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeFlexField.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeFlexField = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_flexFieldsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeFlexField = (FlexField) _flexFieldsSource.getRowData();
		selection.addKey(_activeFlexField.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeFlexField != null) {
            setBeans();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeFlexField = _itemSelection.getSingleSelection();
		if (_activeFlexField != null) {
            setBeans();
		}
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

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getEntityType() != null && filter.getEntityType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getObjectType() != null && filter.getObjectType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("objectType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getObjectType());
			filters.add(paramFilter);
		}
		if (filter.getSystemName() != null && filter.getSystemName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("systemName");
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
		if (filter.getDataType() != null && filter.getDataType().trim().length() > 0){
			paramFilter = new Filter();
			paramFilter.setElement("dataType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getDataType());
			filters.add(paramFilter);
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void add() {
		newFlexField = new FlexField();
		newFlexField.setLang(userLang);
		newFlexField.setDataType("DTTPCHAR");
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newFlexField = (FlexField) _activeFlexField.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newFlexField = _activeFlexField;
		}
		newFlexField.setLang(curLang);
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newFlexField = _commonDao.updateFlexField(userSessionId, newFlexField, curLang);
				_flexFieldsSource.replaceObject(_activeFlexField, newFlexField);
			} else if (isNewMode()) {
				newFlexField = _commonDao.createFlexField(userSessionId, newFlexField);
				_itemSelection.addNewObjectToList(newFlexField);
			}

			_activeFlexField = newFlexField;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_commonDao.deleteFlexField(userSessionId, _activeFlexField);
			_activeFlexField = _itemSelection.removeObjectFromList(_activeFlexField);

			if (_activeFlexField == null) {
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

	public void close() {
		curMode = VIEW_MODE;
	}

	public FlexField getNewFlexField() {
		if (newFlexField == null) {
			newFlexField = new FlexField();
		}
		return newFlexField;
	}

	public void FlexField(FlexField newFlexField) {
		this.newFlexField = newFlexField;
	}

	public void clearFilter() {
		filter = new FlexField();
		clearState();
        clearBeanState();
		searching = false;
	}
	
	public void clearState() {
		_itemSelection.clearSelection();
		_activeFlexField = null;
		_flexFieldsSource.flushCache();
	}

	public void clearBeanState() {
        MbFlexFieldUsagesSearch usage = ManagedBeanWrapper.getManagedBean(MbFlexFieldUsagesSearch.class);
        usage.clearFilter();
    }

	private void setBeans() {
        loadTab(getTabName());
	}

	public String select() {
		MbFlexFields flexFieldBean = (MbFlexFields) ManagedBeanWrapper
				.getManagedBean("MbFlexFields");
		flexFieldBean.setActiveFlexField(_activeFlexField);
		return backLink;
	}

	public String cancelSelect() {
		MbFlexFields flexFieldBean = (MbFlexFields) ManagedBeanWrapper
				.getManagedBean("MbFlexFields");
		flexFieldBean.setActiveFlexField(null);
		return backLink;
	}

	public FlexField getFilter() {
		if (filter == null)
			filter = new FlexField();
		return filter;
	}

	public void setFilter(FlexField filter) {
		this.filter = filter;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getEntityTypesNoEmpty() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}

	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeFlexField.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			FlexField[] flexFields = _commonDao.getFlexFields(userSessionId, params);
			if (flexFields != null && flexFields.length > 0) {
				_activeFlexField = flexFields[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public List<SelectItem> getLovs() {
		if (getNewFlexField().getDataType() == null) {
			return new ArrayList<SelectItem>(0);
		}

		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("DATA_TYPE", getNewFlexField().getDataType());
		return getDictUtils().getLov(LovConstants.LOVS_LOV, params);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public void disableLov() {
		if (getNewFlexField().isDate()) {
			getNewFlexField().setLovId(null);
		}
	}
	
	public List<SelectItem> getLovValues() {
		if (newFlexField == null || newFlexField.getLovId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getDictUtils().getLov(newFlexField.getLovId()); 
	}

	public List<SelectItem> getObjectTypes() {
		if (objectTypes == null){
			objectTypes = getDictUtils().getLov(LovConstants.OBJECT_TYPES);
					
		}
		return objectTypes;
	}

	public void setObjectTypes(ArrayList<SelectItem> objectTypes) {
		this.objectTypes = objectTypes;
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newFlexField.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newFlexField.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			FlexField[] items = _commonDao.getFlexFields(userSessionId, params);
			if (items != null && items.length > 0) {
				newFlexField.setName(items[0].getName());
				newFlexField.setDescription(items[0].getDescription());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

    public String getTabName() {
        return tabName;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void loadCurrentTab() {
        loadTab(tabName);
    }

    private void loadTab(String tab) {
		if (tab != null) {
			try {
				if (tab.equalsIgnoreCase("detailsTab")) {
					/* nothing to do */
				} else if (tab.equalsIgnoreCase("usageTab")) {
					MbFlexFieldUsagesSearch bean = ManagedBeanWrapper.getManagedBean(MbFlexFieldUsagesSearch.class);
					if (bean != null) {
						bean.clearFilter();
						if (_activeFlexField != null) {
							bean.setFieldId(_activeFlexField.getId());
							bean.getFilter().setFieldId(_activeFlexField.getId());
							bean.search();
						}
					}
				} else if (tab.equalsIgnoreCase("standardsTab")) {
					MbFlexFieldsStandardSearch bean = ManagedBeanWrapper.getManagedBean(MbFlexFieldsStandardSearch.class);
					if (bean != null) {
						bean.clearFilter();
						bean.setHideButtons(true);
						bean.getFilter().setEntityType(EntityNames.FLEXIBLE_FIELD);
						if (_activeFlexField != null) {
							bean.getFilter().setFieldId(_activeFlexField.getId().longValue());
							bean.search();
						}
					}
				}
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
			}
		}
	}
}
