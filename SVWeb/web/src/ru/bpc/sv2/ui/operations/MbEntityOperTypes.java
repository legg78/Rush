package ru.bpc.sv2.ui.operations;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.EntityOperType;
import ru.bpc.sv2.ui.reports.MbReportParametersSearch;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbEntityOperTypes")
public class MbEntityOperTypes extends AbstractBean {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	private static String COMPONENT_ID = "1744:entOperTypesTable";

	private OperationDao _operationsDao = new OperationDao();

	private String tabName;


	private EntityOperType filter;
	private EntityOperType _activeEntityOperType;
	private EntityOperType newEntityOperType;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<EntityOperType> _entityOperTypesSource;

	private final TableRowSelection<EntityOperType> _itemSelection;
	private final String BOO = "INVMBOOP";
	private SimpleSelection itemSeletionRestore;

	public MbEntityOperTypes() {
		tabName = "detailsTab";
		pageLink = "operations|entOperTypes";
		_entityOperTypesSource = new DaoDataModel<EntityOperType>() {
			@Override
			protected EntityOperType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new EntityOperType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getEntityOperTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new EntityOperType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getEntityOperTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<EntityOperType>(null, _entityOperTypesSource);
		restoreFilter();
	}

	private void restoreFilter() {
		HashMap<String, Object> queueFilter = getQueueFilter("MbEntityOperTypes");
		if (queueFilter == null)
			return;
		if (queueFilter.containsKey("inst")) {
			getFilter().setInstId((Integer) queueFilter.get("inst"));
		}
		if (queueFilter.containsKey("operType")) {
			getFilter().setOperType((String) queueFilter.get("operType"));
		}
		if (queueFilter.containsKey("selection")) {
			itemSeletionRestore = (SimpleSelection) queueFilter.get("selection");
		}
		if (queueFilter.containsKey("tabName")) {
			tabName = (String) queueFilter.get("tabName");
		}
		if (queueFilter.containsKey("searching")){
			setSearching((Boolean)queueFilter.get("searching"));
		}
		if (queueFilter.containsKey("objectId")){
			filter = new EntityOperType();
			getFilter().setId((Integer)queueFilter.get("objectId"));
		}
		search();

	}

	public HashMap<String, Object> getQueueFilter() {
		HashMap<String, Object> queueFilter = new HashMap<String, Object>();
		if (searching){
			if (filter.getInstId() != null) {
				queueFilter.put("inst", filter.getInstId());
			}
			if (filter.getOperType() != null) {
				queueFilter.put("operType", filter.getOperType());
			}
		} else {
			if (_activeEntityOperType != null){
				queueFilter.put("objectId", _activeEntityOperType.getId());
			}
		}
		queueFilter.put("searching", isSearching());


		queueFilter.put("tabName", tabName);
		SimpleSelection selection = new SimpleSelection();
		selection.addKey(_activeEntityOperType.getModelId());
		_itemSelection.setWrappedSelection(selection);
		queueFilter.put("selection", _itemSelection.getWrappedSelection());
		return queueFilter;
	}

	public DaoDataModel<EntityOperType> getEntityOperTypes() {
		return _entityOperTypesSource;
	}

	public EntityOperType getActiveEntityOperType() {
		return _activeEntityOperType;
	}

	public void setActiveEntityOperType(EntityOperType activeEntityOperType) {
		_activeEntityOperType = activeEntityOperType;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (itemSeletionRestore != null) {
				setItemSelection(itemSeletionRestore);
				itemSeletionRestore = null;
			} else if (_activeEntityOperType == null && _entityOperTypesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeEntityOperType != null && _entityOperTypesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeEntityOperType.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeEntityOperType = _itemSelection.getSingleSelection();
				setBeans();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_entityOperTypesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeEntityOperType = (EntityOperType) _entityOperTypesSource.getRowData();
		selection.addKey(_activeEntityOperType.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeEntityOperType = _itemSelection.getSingleSelection();
		if (_activeEntityOperType != null) {
			setBeans();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		setBeans();
	}

	public String getTabName() {
		return tabName;
	}

	public void setBeans() {
		if (_activeEntityOperType == null) {
			return;
		}

		if (tabName != null && tabName.equalsIgnoreCase("rolesTab")) {
			MbObjectRoles roles = (MbObjectRoles) ManagedBeanWrapper.getManagedBean("MbObjectRoles");
			roles.setObjectId(_activeEntityOperType.getId());
			roles.setEntityType("ENTT0096");
			roles.setBackLink(pageLink);
			roles.setParentQueueFilter(getQueueFilter());
			roles.setParentBean("MbEntityOperTypes");
			roles.search();
		}
	}

	public void clearBeansStates() {
		MbReportParametersSearch paramsSearch = (MbReportParametersSearch) ManagedBeanWrapper
				.getManagedBean("MbReportParametersSearch");
		paramsSearch.clearState();
		paramsSearch.setFilter(null);
		paramsSearch.setSearching(false);

		MbObjectRoles roles = (MbObjectRoles) ManagedBeanWrapper.getManagedBean("MbObjectRoles");
		roles.clearBean();
		roles.setObjectId(null);
		roles.setEntityType(null);
		roles.setSearching(false);
	}

	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public EntityOperType getFilter() {
		if (filter == null) {
			filter = new EntityOperType();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(EntityOperType filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getOperType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operType");
			paramFilter.setValue(filter.getOperType());
			filters.add(paramFilter);
		}
		if (filter.getInvokeMethod() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("invokeMethod");
			paramFilter.setValue(filter.getInvokeMethod());
			filters.add(paramFilter);
		}
		if (filter.getReasonLovId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("reasonLovId");
			paramFilter.setValue(filter.getReasonLovId());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newEntityOperType = new EntityOperType();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newEntityOperType = (EntityOperType) _activeEntityOperType.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newEntityOperType = _activeEntityOperType;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newEntityOperType = _operationsDao.addEntityOperType(userSessionId,
						newEntityOperType, userLang);
				_itemSelection.addNewObjectToList(newEntityOperType);
			} else if (isEditMode()) {
				newEntityOperType = _operationsDao.modifyEntityOperType(userSessionId,
						newEntityOperType, userLang);
				_entityOperTypesSource.replaceObject(_activeEntityOperType, newEntityOperType);
			}
			_activeEntityOperType = newEntityOperType;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_operationsDao.removeEntityOperType(userSessionId, _activeEntityOperType);
			_activeEntityOperType = _itemSelection.removeObjectFromList(_activeEntityOperType);

			if (_activeEntityOperType == null) {
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

	public EntityOperType getNewEntityOperType() {
		if (newEntityOperType == null) {
			newEntityOperType = new EntityOperType();
		}
		return newEntityOperType;
	}

	public void setNewEntityOperType(EntityOperType newEntityOperType) {
		this.newEntityOperType = newEntityOperType;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeEntityOperType = null;
		_entityOperTypesSource.flushCache();

		clearBeansStates();
	}

	public void changeLanguage(ValueChangeEvent checkGroup) {
		curLang = (String) checkGroup.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setValue(_activeEntityOperType.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			EntityOperType[] checkGroups = _operationsDao.getEntityOperTypes(userSessionId, params);
			if (checkGroups != null && checkGroups.length > 0) {
				_activeEntityOperType = checkGroups[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}

	public List<SelectItem> getObjectTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}

	public List<SelectItem> getClientIDTypes() {
		return getDictUtils().getLov(LovConstants.CLIENT_ID_TYPE_EXTENDED);
	}

	public ArrayList<SelectItem> getOperTypes() {
		return getDictUtils().getArticles(DictNames.OPER_TYPE, true);
	}

	public List<SelectItem> getInvokeMethods() {
		return getDictUtils().getLov(LovConstants.INVOKE_METHODS);
	}

	public List<SelectItem> getReasonLovIds() {
		return getDictUtils().getLovsList();
	}

	public List<SelectItem> getWizards() {
		return getDictUtils().getLov(LovConstants.OPR_WIZ_ENTITY_TYPE);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public boolean isBackOffice() {
		String method = getNewEntityOperType().getInvokeMethod();
		if (BOO.equalsIgnoreCase(method)) {
			return true;
		}
		return false;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new EntityOperType();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("operType") != null) {
					filter.setOperType(filterRec.get("operType"));
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
			if (filter.getOperType() != null) {
				filterRec.put("operType", filter.getOperType());
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

	public void onChangeEntityType(EntityOperType operType) {
		if (operType == null) {
			return;
		}

		operType.setEntityObjectType(null);
	}

	public List<SelectItem> getEntityObjectTypes() {
		if (getNewEntityOperType() == null || StringUtils.isEmpty(getNewEntityOperType().getEntityType())) {
			return null;
		}
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("ENTITY_TYPE", getNewEntityOperType().getEntityType());
		return getDictUtils().getLov(LovConstants.ENTITY_OBJECT_TYPES, params);
	}
}
