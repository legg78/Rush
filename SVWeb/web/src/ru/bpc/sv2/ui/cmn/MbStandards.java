package ru.bpc.sv2.ui.cmn;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.component.table.ExpansionState;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.cmn.CmnStandard;
import ru.bpc.sv2.cmn.CmnVersion;
import ru.bpc.sv2.constants.ArrayConstants;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsStandardSearch;
import ru.bpc.sv2.ui.network.MbMsgTypeMaps;
import ru.bpc.sv2.ui.network.MbOperTypeMaps;
import ru.bpc.sv2.ui.pmo.MbPmoPurposeFormatter;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "MbStandards")
public class MbStandards extends AbstractTreeBean<CmnStandard> {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private CommunicationDao _cmnDao = new CommunicationDao();

	private CmnStandard standardFilter;
	private CmnStandard newNode;
	
	private List<CmnStandard> versionsList;

	private String tabName;
	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;
	private ExpansionState expandLevel;
	private boolean standardIsShown;
	private MbCmnVersions versionsBean;
	
	public MbStandards() {
		pageLink = "cmn|standards";
		versionsBean = (MbCmnVersions) ManagedBeanWrapper.getManagedBean("MbCmnVersions");
	}

	public CmnStandard getNode() {
		return currentNode;
	}

	public void setNode(CmnStandard node) {
		if (node == null)
			return;

		this.currentNode = node;
		standardIsShown = EntityNames.STANDARD.equals(this.currentNode.getEntityType());
		if (!standardIsShown) {
			CmnVersion version = new CmnVersion();
			version.setId(node.getId());
			
			versionsBean.setActiveVersion(currentNode.getVersion());
		}
		setBeans();
	}

	public void setBeans() {
		loadedTabs.clear();
		loadTab(getTabName());
	}

	public void search() {
		nodePath = null;
		currentNode = null;
		setSearching(true);
		clearBean();
		loadTree();
	}

	public void clearFilter() {
		clearBean();
		standardFilter = new CmnStandard();
		searching = false;
	}

	public void setFilters() {
		standardFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (standardFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(standardFilter.getId() + "%");
			filters.add(paramFilter);
		}
		if (standardFilter.getAppPlugin() != null &&
				standardFilter.getAppPlugin().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("appPlugin");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(standardFilter.getAppPlugin().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (standardFilter.getLabel() != null && standardFilter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(standardFilter.getLabel().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (standardFilter.getStandardType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("standardType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(standardFilter.getStandardType());
			filters.add(paramFilter);
		}
	}

	protected void loadTree() {
		try {
			coreItems = new ArrayList<CmnStandard>();

			if (!searching)
				return;

			setFilters();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			CmnStandard[] items = _cmnDao.getStandardsTree(userSessionId, params, userLang);
			if (items != null && items.length > 0) {
				addNodes(0, coreItems, items);
				if (nodePath == null) {
					if (currentNode == null) {
						setNode(coreItems.get(0));
						setNodePath(new TreePath(currentNode, null));
					} else {
						if (currentNode.getParentId() != null) {
							setNodePath(formNodePath(items));
						} else {
							setNodePath(new TreePath(currentNode, null));
						}
					}
					setBeans();
				}
			}
			/*
			if (currentNode != null && !coreItems.contains(currentNode)) {
				// when bean state was restored in constructor and selected node
				// doesn't correspond to filter conditions we should add it to
				// list manually
				coreItems.add(currentNode);
			}*/
			treeLoaded = true;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public List<CmnStandard> getNodeChildren() {
		CmnStandard node = getStandard();
		if (node == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return node.getChildren();
		}
	}

	private CmnStandard getStandard() {
		return (CmnStandard) Faces.var("standard");
	}

	public boolean getNodeHasChildren() {
		CmnStandard node = getStandard();
		return (node != null) &&  node.isHasChildren();
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public CmnStandard getNewNode() {
		if (newNode == null) {
			newNode = new CmnStandard();
		}
		return newNode;
	}

	public void setNewNode(CmnStandard newNode) {
		this.newNode = newNode;
	}

	public void add() {
		newNode = new CmnStandard();
		newNode.setLang(userLang);
		newNode.setEntityType(EntityNames.STANDARD);
		curMode = NEW_MODE;
	}

	public void addVersion() {
		newNode = new CmnStandard();
		newNode.setLang(curLang);
		newNode.setEntityType(EntityNames.STANDARD_VERSION);
		newNode.setParentId(currentNode.getParentId() == null ? currentNode.getId() : currentNode
				.getParentId());

		MbCmnVersions versionBean = (MbCmnVersions) ManagedBeanWrapper
				.getManagedBean("MbCmnVersions");
		versionBean.add();
		versionBean.setNewVersion(newNode.getVersion());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newNode = (CmnStandard) currentNode.clone();
		} catch (CloneNotSupportedException e) {
			newNode = currentNode;
		}
		curMode = EDIT_MODE;
	}

	public void editVersion() {
		newNode = new CmnStandard();
		newNode.setEntityType(EntityNames.STANDARD_VERSION);

//		versionsBean.setActiveVersion(currentNode.getVersion());
		versionsBean.edit();
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			if (EntityNames.STANDARD.equals(currentNode.getEntityType())) {
				_cmnDao.deleteCommStandard(userSessionId, currentNode);
			} else if (EntityNames.STANDARD_VERSION.equals(currentNode.getEntityType())) {
				_cmnDao.deleteCmnVersion(userSessionId, currentNode.getVersion());
			}

			deleteNodeFromTree(currentNode, coreItems);
			currentNode = null;
			clearBeansStates();
			if (coreItems.size() > 0) {
				currentNode = coreItems.get(0);
				setNodePath(new TreePath(currentNode, null));
				setBeans();
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				if (EntityNames.STANDARD.equals(newNode.getEntityType())) {
					newNode = _cmnDao.addCommStandard(userSessionId, newNode);
				} else if (EntityNames.STANDARD_VERSION.equals(newNode.getEntityType())) {
					MbCmnVersions versionBean = (MbCmnVersions) ManagedBeanWrapper
							.getManagedBean("MbCmnVersions");
					newNode.setVersion(_cmnDao.addCmnVersion(userSessionId, versionBean
							.getNewVersion()));
				}
				addElementToTree(newNode);
				versionsBean.setActiveVersion(newNode.getVersion());
			} else {
				if (EntityNames.STANDARD.equals(newNode.getEntityType())) {
					newNode = _cmnDao.editCommStandard(userSessionId, newNode);
				} else if (EntityNames.STANDARD_VERSION.equals(newNode.getEntityType())) {
					MbCmnVersions versionBean = (MbCmnVersions) ManagedBeanWrapper
							.getManagedBean("MbCmnVersions");
					newNode.setVersion(_cmnDao.editCmnVersion(userSessionId, versionBean
							.getNewVersion()));
				}
				replaceCurrentNode(newNode);
				versionsBean.setActiveVersion(newNode.getVersion());
			}

			MbRespCodesMappings respCodes = (MbRespCodesMappings) ManagedBeanWrapper
					.getManagedBean("MbRespCodesMappings");
			respCodes.resetStandards();

			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void moveVersionUpReload() {
		try {
			_cmnDao.moveVersionUp(userSessionId, currentNode.getVersion());
			nodePath = null;
			loadTree();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}
	
	public void moveVersionDownReload() {
		try {
			_cmnDao.moveVersionDown(userSessionId, currentNode.getVersion());
			nodePath = null;
			loadTree();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public CmnStandard getFilter() {
		if (standardFilter == null) {
			standardFilter = new CmnStandard();
		}
		return standardFilter;
	}

	public void setFilter(CmnStandard standardFilter) {
		this.standardFilter = standardFilter;
	}

	public void clearBean() {
		currentNode = null;
		nodePath = null;
		coreItems = null;
		treeLoaded = false;
		curLang = userLang;

		clearBeansStates();
	}

	private void clearBeansStates() {
		MbCmnParameters paramsBean = (MbCmnParameters) ManagedBeanWrapper
				.getManagedBean("MbCmnParameters");
		paramsBean.clearBean();
		paramsBean.setStandardId(null);

		MbRespCodesMappings respCodes = (MbRespCodesMappings) ManagedBeanWrapper
				.getManagedBean("MbRespCodesMappings");
		respCodes.clearFilter();

		MbCmnStandardKeyTypeMaps mbCmnStandardKeyTypeMaps = (MbCmnStandardKeyTypeMaps) ManagedBeanWrapper
				.getManagedBean("MbCmnStandardKeyTypeMaps");
		mbCmnStandardKeyTypeMaps.clearBean();
		mbCmnStandardKeyTypeMaps.setStandardId(null);
		
		MbCmnParamValues mbCmnParamValues = (MbCmnParamValues) ManagedBeanWrapper.getManagedBean("MbCmnParamValues");
		mbCmnParamValues.clearBean();
		mbCmnParamValues.fullCleanBean();

		MbOperTypeMaps operTypeMapsBean = (MbOperTypeMaps) ManagedBeanWrapper.getManagedBean("MbOperTypeMaps");
		operTypeMapsBean.clearFilter();

		MbMsgTypeMaps msgTypeMapsBean = (MbMsgTypeMaps) ManagedBeanWrapper.getManagedBean("MbMsgTypeMaps");
		msgTypeMapsBean.clearFilter();
		
		MbObjectStandardVersions standardVersions = (MbObjectStandardVersions) ManagedBeanWrapper
				.getManagedBean(MbObjectStandardVersions.class);
		standardVersions.clearFilter();
		
		MbObjectStandards objectStandards = (MbObjectStandards)ManagedBeanWrapper
				.getManagedBean(MbObjectStandards.class);
		objectStandards.clearFilter();
		
		MbPmoPurposeFormatter pmoPurposeFormatter = (MbPmoPurposeFormatter) ManagedBeanWrapper
				.getManagedBean(MbPmoPurposeFormatter.class);
		pmoPurposeFormatter.setStandardId(null);
		pmoPurposeFormatter.clearFilter();
	}

	public ArrayList<SelectItem> getAppPlugins() {
		return getDictUtils().getArticles(DictNames.APPLICATION_PLUGIN, true, false);
	}

	public List<SelectItem> getCmnLovs() {

		List<SelectItem> result = getDictUtils().getArray(ArrayConstants.RESPONSE_CODES);
		return result;

	}

	public List<SelectItem> getKeyTypesLovs() {
		return getDictUtils().getLov(LovConstants.LOVS_LOV);
	}

	public ArrayList<SelectItem> getStandardTypes() {
		return getDictUtils().getArticles(DictNames.CMN_STANDARD_TYPE, true, false);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(currentNode.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			if (EntityNames.STANDARD.equals(newNode.getEntityType())) {
				CmnStandard[] standards = _cmnDao.getCommStandards(userSessionId, params);
				if (standards != null && standards.length > 0) {
					currentNode = standards[0];
				}
			} else if (EntityNames.STANDARD_VERSION.equals(newNode.getEntityType())) {
				CmnVersion[] versions = _cmnDao.getCmnVersions(userSessionId, params);
				if (versions != null && versions.length > 0) {
					currentNode.setVersion(versions[0]);
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newNode.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newNode.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			if (EntityNames.STANDARD.equals(newNode.getEntityType())) {
				CmnStandard[] standards = _cmnDao.getCommStandards(userSessionId, params);
				if (standards != null && standards.length > 0) {
					newNode = standards[0];
				}
			} else if (EntityNames.STANDARD_VERSION.equals(newNode.getEntityType())) {
				CmnVersion[] versions = _cmnDao.getCmnVersions(userSessionId, params);
				if (versions != null && versions.length > 0) {
					newNode.setVersion(versions[0]);
				}
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
		needRerender = null;
		this.tabName = tabName;

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName);
		
		if (tabName.equalsIgnoreCase("paramsTab")) {
			if(isStandard()){
				MbCmnParameters paramsBean = (MbCmnParameters) ManagedBeanWrapper
						.getManagedBean("MbCmnParameters");
				paramsBean.setTabName(tabName);
				paramsBean.setParentSectionId(getSectionId());
				paramsBean.setTableState(getSateFromDB(paramsBean.getComponentId()));
			} else if (isStandardVersion()) {
				MbCmnParamValues values = (MbCmnParamValues) ManagedBeanWrapper
						.getManagedBean("MbCmnParamValues");
				values.setTabName(tabName);
				values.setParentSectionId(getSectionId());
				values.setTableState(getSateFromDB(values.getComponentId()));
			}
		} else if (tabName.equalsIgnoreCase("respCodesTab")) {
			MbRespCodesMappings respCodes = (MbRespCodesMappings) ManagedBeanWrapper
					.getManagedBean("MbRespCodesMappings");
			respCodes.setTabName(tabName);
			respCodes.setParentSectionId(getSectionId());
			respCodes.setTableState(getSateFromDB(respCodes.getComponentId()));
		} else if (tabName.equalsIgnoreCase("standardKeyTypeMapTab")) {
			MbCmnStandardKeyTypeMaps mbCmnStandardKeyTypeMaps = (MbCmnStandardKeyTypeMaps) ManagedBeanWrapper
					.getManagedBean("MbCmnStandardKeyTypeMaps");
			mbCmnStandardKeyTypeMaps.setTabName(tabName);
			mbCmnStandardKeyTypeMaps.setParentSectionId(getSectionId());
			mbCmnStandardKeyTypeMaps.setTableState(getSateFromDB(mbCmnStandardKeyTypeMaps.getComponentId()));
		} else if ((tabName.equalsIgnoreCase("standardVersionObjectsTab"))||
					(tabName.equals("standardObjectsTab"))) {
			if (currentNode != null && EntityNames.STANDARD_VERSION.equals(currentNode.getEntityType())) {
				MbObjectStandardVersions values = (MbObjectStandardVersions) ManagedBeanWrapper
						.getManagedBean("MbObjectStandardVersions");
				values.setTabName(tabName);
				values.setParentSectionId(getSectionId());
				values.setTableState(getSateFromDB(values.getComponentId()));
			} else {
				MbObjectStandards values = (MbObjectStandards) ManagedBeanWrapper
						.getManagedBean("MbObjectStandards");
				values.setTabName(tabName);
				values.setParentSectionId(getSectionId());
				values.setTableState(getSateFromDB(values.getComponentId()));
			}
		} else if (tabName.equalsIgnoreCase("paymentFormattersTab")) {
			MbPmoPurposeFormatter mbPmoPurposeFormatter = (MbPmoPurposeFormatter) ManagedBeanWrapper
					.getManagedBean("MbPmoPurposeFormatter");
			mbPmoPurposeFormatter.setTabName(tabName);
			mbPmoPurposeFormatter.setParentSectionId(getSectionId());
			mbPmoPurposeFormatter.setTableState(getSateFromDB(mbPmoPurposeFormatter.getComponentId()));
		} else if (tabName.equalsIgnoreCase("operTypeMapsTab")) {
			MbOperTypeMaps operTypeMapsBean = (MbOperTypeMaps) ManagedBeanWrapper.getManagedBean("MbOperTypeMaps");
			operTypeMapsBean.setTabName(tabName);
			operTypeMapsBean.setParentSectionId(getSectionId());
			operTypeMapsBean.setTableState(getSateFromDB(operTypeMapsBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("msgTypeMapsTab")) {
			MbMsgTypeMaps msgTypeMapsBean = (MbMsgTypeMaps) ManagedBeanWrapper.getManagedBean("MbMsgTypeMaps");
			msgTypeMapsBean.setTabName(tabName);
			msgTypeMapsBean.setParentSectionId(getSectionId());
			msgTypeMapsBean.setTableState(getSateFromDB(msgTypeMapsBean.getComponentId()));
		}
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (currentNode == null || currentNode.getId() == null)
			return;

		if (tab.equalsIgnoreCase("paramsTab")) {
			if(isStandard()){
				MbCmnParameters paramsBean = (MbCmnParameters) ManagedBeanWrapper
						.getManagedBean("MbCmnParameters");
				paramsBean.fullCleanBean();
				paramsBean.setStandardId(currentNode.getId());
				paramsBean.setStandardType(currentNode.getStandardType());
				paramsBean.search();
			} else if (isStandardVersion()){
				MbCmnParamValues values = (MbCmnParamValues) ManagedBeanWrapper
						.getManagedBean("MbCmnParamValues");
				values.fullCleanBean();
				values.setStandardId(currentNode.getParentId() == null ? null : currentNode.getParentId().intValue()); // CmnStandard's ID is actually an integer
				values.setVersionId(currentNode.getId().intValue()); // CmnStandard's ID is actually an integer
				values.setObjectId(currentNode.getId());
				values.setValuesEntityType(EntityNames.STANDARD_VERSION);
				values.search();
			}
		} else if (tab.equalsIgnoreCase("respCodesTab")) {
			MbRespCodesMappings respCodes = (MbRespCodesMappings) ManagedBeanWrapper
					.getManagedBean("MbRespCodesMappings");
			respCodes.clearFilter();
			respCodes.getFilter().setStandardId(currentNode.getId());
			respCodes.setStandardName(currentNode.getLabel());
			respCodes.setMainForm(false);
			respCodes.search();
		} else if (tab.equalsIgnoreCase("standardKeyTypeMapTab")) {
			MbCmnStandardKeyTypeMaps mbCmnStandardKeyTypeMaps = (MbCmnStandardKeyTypeMaps) ManagedBeanWrapper
					.getManagedBean("MbCmnStandardKeyTypeMaps");
			mbCmnStandardKeyTypeMaps.setStandardKeyTypesLovId(currentNode.getKeyTypeLovId());
			mbCmnStandardKeyTypeMaps.setStandardId(currentNode.getId().intValue()); // CmnStandard's ID is actually an integer
			mbCmnStandardKeyTypeMaps.search();
		} else if ((tab.equalsIgnoreCase("standardVersionObjectsTab"))||
					(tab.equals("standardObjectsTab"))) {
			if (EntityNames.STANDARD_VERSION.equals(currentNode.getEntityType())) {
				MbObjectStandardVersions values = (MbObjectStandardVersions) ManagedBeanWrapper
						.getManagedBean("MbObjectStandardVersions");
				values.fullCleanBean();
				values.getFilter().setVersionId(currentNode.getId().intValue()); // CmnStandard's ID is actually an integer
				values.search();
			} else {
				MbObjectStandards values = (MbObjectStandards) ManagedBeanWrapper
						.getManagedBean("MbObjectStandards");
				values.fullCleanBean();
				values.getFilter().setStandardId(currentNode.getId().intValue()); // CmnStandard's ID is actually an integer
				values.getFilter().setStandardType(currentNode.getStandardType());
				values.search();
			}
		} else if (tab.equalsIgnoreCase("paymentFormattersTab")) {
			MbPmoPurposeFormatter mbPmoPurposeFormatter = (MbPmoPurposeFormatter) ManagedBeanWrapper
					.getManagedBean("MbPmoPurposeFormatter");
			Integer standardId = null;
			Integer versionId = null;
			if (standardIsShown) {
				standardId = currentNode.getId().intValue(); // CmnStandard's ID is actually an integer
			} else {
				standardId = currentNode.getParentId().intValue(); // CmnStandard's ID is actually an integer
				versionId = currentNode.getId().intValue(); // CmnStandard's ID is actually an integer
			}
			mbPmoPurposeFormatter.setStandardId(standardId);
			mbPmoPurposeFormatter.setVersionId(versionId);
		} else if (tab.equalsIgnoreCase("operTypeMapsTab")) {
			MbOperTypeMaps operTypeMapsBean = (MbOperTypeMaps) ManagedBeanWrapper.getManagedBean("MbOperTypeMaps");
			operTypeMapsBean.clearFilter();
			if (standardIsShown) {
				operTypeMapsBean.getFilter().setStandardId(currentNode.getId());
			} else {
				operTypeMapsBean.getFilter().setStandardId(currentNode.getParentId());
			}
			operTypeMapsBean.search();
		} else if (tab.equalsIgnoreCase("msgTypeMapsTab")) {
			MbMsgTypeMaps msgTypeMapsBean = (MbMsgTypeMaps) ManagedBeanWrapper.getManagedBean("MbMsgTypeMaps");
			msgTypeMapsBean.clearFilter();
			if (standardIsShown) {
				msgTypeMapsBean.getFilter().setStandardId(currentNode.getId());
			} else {
				msgTypeMapsBean.getFilter().setStandardId(currentNode.getParentId());
			}
			msgTypeMapsBean.search();
		} else if (tab.equalsIgnoreCase("flexFieldsTab")) {
			MbFlexFieldsStandardSearch bean = ManagedBeanWrapper.getManagedBean(MbFlexFieldsStandardSearch.class);
			bean.clearFilter();
			bean.setHideButtons(false);
			bean.getFilter().setEntityType(EntityNames.STANDARD);
			if (currentNode.getParentId() != null) {
				bean.getFilter().setStandardId(currentNode.getParentId().intValue());
			} else if (currentNode.getId() != null) {
				bean.getFilter().setStandardId(currentNode.getId().intValue());
			} else {
				bean.getFilter().setStandardId(null);
			}
			bean.search();
		}

		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add(tabName);
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}

	public ExpansionState getExpandLevel() {
		return expandLevel;
	}

	public void setExpandLevel(ExpansionState expandLevel) {
		this.expandLevel = expandLevel;
	}

	public boolean isStandard() {
		return currentNode == null ? true : EntityNames.STANDARD
				.equals(currentNode.getEntityType());
	}

	public boolean isStandardVersion() {
		return currentNode == null ? false : EntityNames.STANDARD_VERSION.equals(currentNode
				.getEntityType());
	}

	public boolean isStandardIsShown() {
		return standardIsShown;
	}
	
	public void prepareReorder() {
		if (versionsList == null) {
			versionsList = new ArrayList<CmnStandard>();			
		} else {
			versionsList.clear();
		}
		for (CmnStandard vers : currentNode.getChildren()) {
			versionsList.add(vers);
		}
	}
	
	public List<CmnStandard> getStandardVersionsList() {
		return versionsList;
	}
	
	public void setStandardVersionsList(List<CmnStandard> standardVersionsList) {
		this.versionsList = standardVersionsList;
	}
	
	private Collection<CmnStandard> reorderSelection;

	
	public Collection<CmnStandard> getReorderSelection() {
		return reorderSelection;
	}

	public void setReorderSelection(Collection<CmnStandard> reorderSelection) {
		this.reorderSelection = reorderSelection;
	}

	public void moveVersionUp() {
		try {
			for (CmnStandard vers : reorderSelection) {
				_cmnDao.moveVersionUp(userSessionId, vers.getVersion());
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}
	
	public void moveVersionDown() {
		try {
			for (CmnStandard vers : reorderSelection) {
				_cmnDao.moveVersionDown(userSessionId, vers.getVersion());
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}
	
	public void reload() {
		loadTree();
	}
	
	public String getSectionId() {
		return SectionIdConstants.ADMIN_COMMU_STANDARD;
	}

	@Override
	protected boolean addElementToParent(CmnStandard element, List<CmnStandard> tree, TreePath path) {
		for (CmnStandard item: tree) {
			if (EntityNames.STANDARD.equals(item.getEntityType()) && item.getId().equals(element.getParentId())) {
				if (!item.isHasChildren()) {
					item.setChildren(new ArrayList<CmnStandard>());
				}
				currentNode = element;
				item.getChildren().add(0, currentNode);
				setNodePath(new TreePath(currentNode, new TreePath(item, path)));
				return true;
			}
			if (item.isHasChildren()
					&& addElementToParent(element, item.getChildren(), new TreePath(item, path))) {
				return true;
			}
		}
		return false;
	}
}
