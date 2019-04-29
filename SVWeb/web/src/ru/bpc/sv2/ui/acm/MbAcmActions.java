package ru.bpc.sv2.ui.acm;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.acm.AcmActionGroup;
import ru.bpc.sv2.administrative.roles.Privilege;
import ru.bpc.sv2.common.MenuNode;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccessManagementDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.RolesDao;
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
@ManagedBean (name = "MbAcmActions")
public class MbAcmActions extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	public static final String CONTEXT_ACTION = "CACM0001";
	
	private AccessManagementDao _acmDao = new AccessManagementDao();

	private CommonDao _commonDao = new CommonDao();

	private RolesDao _rolesDao = new RolesDao();
	
	private AcmAction filter;
	private AcmAction newAcmAction;
	private AcmAction detailAcmAction;

	private final DaoDataModel<AcmAction> _acmActionsSource;
	private final TableRowSelection<AcmAction> _itemSelection;
	private AcmAction _activeAcmAction;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> actionGroups;
	private ArrayList<SelectItem> entityTypes;
	private ArrayList<SelectItem> lovs;

	private Integer groupId;
	
	private static String COMPONENT_ID = "actionValuesTable";
	private String tabName;
	private String parentSectionId;

	public MbAcmActions() {
		
		pageLink = "acm|actions";
		tabName = "detailsTab";
		_acmActionsSource = new DaoDataModel<AcmAction>() {
			@Override
			protected AcmAction[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AcmAction[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acmDao.getAcmActions(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new AcmAction[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acmDao.getAcmActionsCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<AcmAction>(null, _acmActionsSource);
	}

	public DaoDataModel<AcmAction> getAcmActions() {
		return _acmActionsSource;
	}

	public AcmAction getActiveAcmAction() {
		return _activeAcmAction;
	}

	public void setActiveAcmAction(AcmAction activeAcmAction) {
		_activeAcmAction = activeAcmAction;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeAcmAction == null && _acmActionsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeAcmAction != null && _acmActionsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeAcmAction.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeAcmAction = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeAcmAction.getId())) {
				changeSelect = true;
			}
			_activeAcmAction = _itemSelection.getSingleSelection();
	
			if (_activeAcmAction != null) {
				setBeans();
				if (changeSelect) {
					detailAcmAction = (AcmAction) _activeAcmAction.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_acmActionsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAcmAction = (AcmAction) _acmActionsSource.getRowData();
		selection.addKey(_activeAcmAction.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
		detailAcmAction = (AcmAction) _activeAcmAction.clone();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbAcmActionValues values = (MbAcmActionValues) ManagedBeanWrapper.getManagedBean("MbAcmActionValues");
		values.fullCleanBean();
		values.getFilter().setActionId(_activeAcmAction.getId());
		values.setSectionId(_activeAcmAction.getSectionId());
		values.search();
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (groupId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("groupId");
			paramFilter.setValue(groupId);
			filters.add(paramFilter);
		}
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getCallMode() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("callMode");
			paramFilter.setValue(filter.getCallMode());
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getSectionId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("sectionId");
			paramFilter.setValue(filter.getSectionId());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
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

	public AcmAction getFilter() {
		if (filter == null) {
			filter = new AcmAction();
			// TODO: 9999?
			filter.setInstId(userInstId);
		}
		return filter;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new AcmAction();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("entityType") != null) {
					filter.setEntityType(filterRec.get("entityType"));
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
			if (filter.getEntityType() != null) {
				filterRec.put("entityType", filter.getEntityType());
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

	public void setFilter(AcmAction filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		clearBean();

		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void add() {
		newAcmAction = new AcmAction();
		newAcmAction.setLang(userLang);
		curLang = newAcmAction.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newAcmAction = (AcmAction) detailAcmAction.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_acmDao.removeAcmAction(userSessionId, _activeAcmAction);

			_activeAcmAction = _itemSelection.removeObjectFromList(_activeAcmAction);
			if (_activeAcmAction == null) {
				clearBean();
			} else {
				setBeans();
				detailAcmAction = (AcmAction) _activeAcmAction.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			// we can't reload only edited object as changing isDefault flag 
			// can lead to changing of another object too
			
			if (isNewMode()) {
				newAcmAction = _acmDao.addAcmAction(userSessionId, newAcmAction);
				detailAcmAction = (AcmAction) newAcmAction.clone();
				_itemSelection.addNewObjectToList(newAcmAction);
			} else {
				newAcmAction = _acmDao.modifyAcmAction(userSessionId, newAcmAction);
				detailAcmAction = (AcmAction) newAcmAction.clone();
				//adjust newProvider according userLang
				if (!userLang.equals(newAcmAction.getLang())) {
					newAcmAction = getNodeByLang(_activeAcmAction.getId(), userLang);
				}
				_acmActionsSource.replaceObject(_activeAcmAction, newAcmAction);
			}
			_activeAcmAction = newAcmAction;
			curMode = VIEW_MODE;
			setBeans();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public AcmAction getNewAcmAction() {
		if (newAcmAction == null) {
			newAcmAction = new AcmAction();
		}
		return newAcmAction;
	}

	public void setNewAcmAction(AcmAction newAcmAction) {
		this.newAcmAction = newAcmAction;
	}

	public Integer getGroupId() {
		return groupId;
	}

	public void setGroupId(Integer groupId) {
		this.groupId = groupId;
	}

	public void clearBean() {
		curLang = userLang;
		_acmActionsSource.flushCache();
		_itemSelection.clearSelection();
		_activeAcmAction = null;
		detailAcmAction = null;
		clearBeans();
	}

	private void clearBeans() {
		MbAcmActionValues values = (MbAcmActionValues) ManagedBeanWrapper.getManagedBean("MbAcmActionValues");
		values.fullCleanBean();
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailAcmAction = getNodeByLang(detailAcmAction.getId(), curLang);
	}
	
	public AcmAction getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id);
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			AcmAction[] types = _acmDao.getAcmActions(userSessionId, params);
			if (types != null && types.length > 0) {
				return types[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getActionGroups() {
		if(actionGroups == null){
			actionGroups = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.ACM_ACTION_GROUPS);
		}
		if(actionGroups == null){
			actionGroups = new ArrayList<SelectItem>();
		}
		return actionGroups;
	}

	public List<SelectItem> getCallModes() {
		return getDictUtils().getArticles(DictNames.CALL_MODES, false);
	}

	public List<SelectItem> getEntityTypes() {
		if(entityTypes == null){
			entityTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.ENTITY_TYPES);
		}
		if(entityTypes == null){
			entityTypes = new ArrayList<SelectItem>();
		}
		return entityTypes;
	}

	public List<SelectItem> getSections() {
		try {
			MenuNode[] sections;
			if (CONTEXT_ACTION.equals(newAcmAction.getCallMode())) {
				sections = _commonDao.getModalWindows(userSessionId);
			} else {
				sections = _commonDao.getMenuLight(userSessionId);
			}
			List<SelectItem> items = new ArrayList<SelectItem>(sections.length);
			int dashes = 0;
			String name = "";
			for (MenuNode section: sections) {
				name = section.getName();
				dashes = name.length() - name.trim().length();
				name = name.trim();
				for (int i = 3; i < dashes; i++) {
					name = "-" + name;
				}

				// dashes = 3 only for first level sections that are usually not pages
				items.add(new SelectItem(section.getId(), name, "", section.isFolder()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return new ArrayList<SelectItem>(0);
	}

	public List<SelectItem> getPrivileges() {
		try {
			Privilege[] privs = _rolesDao.getPrivsForCombo(userSessionId);
			List<SelectItem> items = new ArrayList<SelectItem>(privs.length);
			for (Privilege priv: privs) {
				items.add(new SelectItem(priv.getId(), priv.getShortDesc()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return new ArrayList<SelectItem>(0);
	}
	
	public List<SelectItem> getPrivObjects() {
		return new ArrayList<SelectItem>(0);
	}
	
	public void confirmEditLanguage() {
		curLang = newAcmAction.getLang();
		AcmAction tmp = getNodeByLang(newAcmAction.getId(), newAcmAction.getLang());
		if (tmp != null) {
			newAcmAction.setLabel(tmp.getLabel());
			newAcmAction.setDescription(tmp.getDescription());
		}
	}

	public Logger getLogger() {
		return logger;
	}

	public void changeGroup(ValueChangeEvent event) {
		Integer newGroupId = (Integer) event.getNewValue();
		if (newGroupId != null) {
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(newGroupId);
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			try {
				AcmActionGroup[] groups = _acmDao.getAcmActionGroups(userSessionId, params);
				if (groups.length > 0) {
					getNewAcmAction().setEntityType(groups[0].getEntityType());
				}
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
			}
		} else {
			getNewAcmAction().setEntityType(null);
		}
	}
	
	public List<SelectItem> getObjectTypes() {
		if (getNewAcmAction().getObjectTypeLovId() != null) {
			return getDictUtils().getLov(getNewAcmAction().getObjectTypeLovId());
		}
		return new ArrayList<SelectItem>(0);
	}

	public AcmAction getDetailAcmAction() {
		return detailAcmAction;
	}

	public void setDetailAcmAction(AcmAction detailAcmAction) {
		this.detailAcmAction = detailAcmAction;
	}

	public String getComponentId() {
		if (parentSectionId != null && tabName != null) {
			return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
		} else {
			return "2023:acmActionsTable";
		}
	}

	public void setTabName(String tabName) {
			this.tabName = tabName;
			if (tabName.equalsIgnoreCase("VALUESTAB")) {
				MbAcmActionValues actionValueBean = (MbAcmActionValues) ManagedBeanWrapper.getManagedBean("MbAcmActionValues");
				actionValueBean.setTabName(tabName);
				actionValueBean.setParentSectionId(getSectionId());
				actionValueBean.setTableState(getSateFromDB(actionValueBean.getComponentId()));
			}
	}

	public String getTabName() {
		return tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
	public String getSectionId() {
		return SectionIdConstants.ISSUING_CARD;
	}
	
	public List<SelectItem> getLovs(){
		if(lovs == null){
			lovs = (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.LOVS_LOV_ENTITIES);
		}
		if(lovs == null){
			lovs =  new ArrayList<SelectItem>();
		}
		return lovs;
	}

}
