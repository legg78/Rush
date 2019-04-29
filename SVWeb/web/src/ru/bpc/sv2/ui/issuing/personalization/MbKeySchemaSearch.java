package ru.bpc.sv2.ui.issuing.personalization;

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

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.personalization.KeySchema;
import ru.bpc.sv2.issuing.personalization.KeySchemaEntity;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbKeySchemaSearch")
public class MbKeySchemaSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PERSONALIZATION");

	private static String COMPONENT_ID = "1374:keySchemaTable";

	private PersonalizationDao _personalizationDao = new PersonalizationDao();

	

	private KeySchema filter;
	private KeySchema _activeKeySchema;
	private KeySchema newKeySchema;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<KeySchema> _keySchemasSource;

	private final TableRowSelection<KeySchema> _itemSelection;

	private String oldLang;
	
	private String tabName;
	
	public MbKeySchemaSearch() {
		pageLink = "issuing|perso|keySchema";

		_keySchemasSource = new DaoDataModel<KeySchema>() {
			@Override
			protected KeySchema[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new KeySchema[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getKeySchemas(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new KeySchema[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getKeySchemasCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<KeySchema>(null, _keySchemasSource);
		tabName = "detailsTab";
	}

	public DaoDataModel<KeySchema> getKeySchemas() {
		return _keySchemasSource;
	}

	public KeySchema getActiveKeySchema() {
		return _activeKeySchema;
	}

	public void setActiveKeySchema(KeySchema activeKeySchema) {
		_activeKeySchema = activeKeySchema;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeKeySchema == null && _keySchemasSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeKeySchema != null && _keySchemasSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeKeySchema.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeKeySchema = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_keySchemasSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeKeySchema = (KeySchema) _keySchemasSource.getRowData();
		selection.addKey(_activeKeySchema.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeKeySchema != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeKeySchema = _itemSelection.getSingleSelection();
		if (_activeKeySchema != null) {
			setInfo();
		}
	}

	public void setInfo() {
		MbKeySchemaEntitySearch entitySearch = (MbKeySchemaEntitySearch) ManagedBeanWrapper
				.getManagedBean("MbKeySchemaEntitySearch");
		KeySchemaEntity entityFilter = new KeySchemaEntity();
		entityFilter.setKeySchemaId(_activeKeySchema.getId());
		entitySearch.setFilter(entityFilter);
		entitySearch.search();
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
	}

	public KeySchema getFilter() {
		if (filter == null) {
			filter = new KeySchema();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(KeySchema filter) {
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

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
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
		newKeySchema = new KeySchema();
		newKeySchema.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newKeySchema = (KeySchema) _activeKeySchema.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newKeySchema = _activeKeySchema;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			if (isNewMode()) {
				newKeySchema = _personalizationDao.addKeySchema(userSessionId, newKeySchema);
				_itemSelection.addNewObjectToList(newKeySchema);
			} else if (isEditMode()) {
				newKeySchema = _personalizationDao.modifyKeySchema(userSessionId, newKeySchema);
				_keySchemasSource.replaceObject(_activeKeySchema, newKeySchema);
			}

			_activeKeySchema = newKeySchema;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_personalizationDao.deleteKeySchema(userSessionId, _activeKeySchema);

			_activeKeySchema = _itemSelection.removeObjectFromList(_activeKeySchema);
			if (_activeKeySchema == null) {
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
		curMode = VIEW_MODE;
	}

	public KeySchema getNewKeySchema() {
		if (newKeySchema == null) {
			newKeySchema = new KeySchema();
		}
		return newKeySchema;
	}

	public void setNewKeySchema(KeySchema newKeySchema) {
		this.newKeySchema = newKeySchema;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeKeySchema = null;
		_keySchemasSource.flushCache();
		curLang = userLang;
		clearBeansStates();
	}

	private void clearBeansStates() {
		MbKeySchemaEntitySearch entitiesSearch = (MbKeySchemaEntitySearch) ManagedBeanWrapper
				.getManagedBean("MbKeySchemaEntitySearch");
		entitiesSearch.clearState();
		entitiesSearch.setFilter(null);
		entitiesSearch.setSearching(false);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeKeySchema.getId().toString());
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
			KeySchema[] schemas = _personalizationDao.getKeySchemas(userSessionId, params);
			if (schemas != null && schemas.length > 0) {
				_activeKeySchema = schemas[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newKeySchema.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newKeySchema.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			KeySchema[] items = _personalizationDao.getKeySchemas(userSessionId, params);
			if (items != null && items.length > 0) {
				newKeySchema.setName(items[0].getName());
				newKeySchema.setDescription(items[0].getDescription());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void cancelEditLanguage() {
		newKeySchema.setLang(oldLang);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		if (tabName.equalsIgnoreCase("entitiesTab")) {
			MbKeySchemaEntitySearch bean = (MbKeySchemaEntitySearch) ManagedBeanWrapper
					.getManagedBean("MbKeySchemaEntitySearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.ISSUING_PERSO_KEY_SCHEMA;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new KeySchema();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("name") != null) {
					filter.setName(filterRec.get("name"));
				}
				if (filterRec.get("description") != null) {
					filter.setDescription(filterRec.get("description"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			if (filter.getInstId() != null) {
				filterRec.put("instId", filter.getInstId().toString());
			}
			if (filter.getName() != null) {
				filterRec.put("name", filter.getName());
			}
			if (filter.getDescription() != null) {
				filterRec.put("description", filter.getDescription());
			}
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}
