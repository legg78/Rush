package ru.bpc.sv2.ui.orgstruct;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.openfaces.component.table.*;
import org.openfaces.util.Faces;

import ru.bpc.sv2.accounts.AccountGL;
import ru.bpc.sv2.accounts.AccountPrivConstants;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.fraud.FraudPrivConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OrgStructDao;
import ru.bpc.sv2.net.NetPrivConstants;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.orgstruct.OrgStructPrivConstants;
import ru.bpc.sv2.pmo.PaymentOrderPrivConstants;
import ru.bpc.sv2.pmo.PmoTemplate;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.ProductPrivConstants;
import ru.bpc.sv2.settings.SettingParam;
import ru.bpc.sv2.ui.accounts.MbGLAccountsSearch;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContact;
import ru.bpc.sv2.ui.common.MbContactDataSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.fraud.MbFraudObjects;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.network.MbNetworkMembers;
import ru.bpc.sv2.ui.network.MbNetworks;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.pmo.MbPmoTemplates;
import ru.bpc.sv2.ui.products.MbCustomersBottom;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.settings.MbSettingParamsSearch;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbInstitution")
public class MbInstitution extends AbstractTreeBean<Institution> {
	/**
	 * 
	 */
	private static final long serialVersionUID = 3489892082211900309L;

	private OrgStructDao _orgStructDao = new OrgStructDao();

	private Institution newNode;
	private Institution detailNode;

	private Network network;

	protected String tabName;
	

	private MbInstSess sessInst;

	private List<Institution> selectedNodeDatas;
	private Institution filter;
	private static final Logger logger = Logger.getLogger("ORG_STRUCTURE");

	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

	private List<SelectItem> networks;
	private String oldLang;
	
	private String ctxItemEntityType;
	private ContextType ctxType;

	public MbInstitution() {
		pageLink = "orgStruct|institutions";
		tabName = "detailsTab";
		setExpandLevel(new DynamicNodeExpansionState(new AllNodesCollapsed()));
		thisBackLink = "ost_institutions";

		
		sessInst = (MbInstSess) ManagedBeanWrapper.getManagedBean("MbInstSess");

		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE;
		} else {
			tabName = sessInst.getTabName();
			nodePath = sessInst.getNodePath();
			filter = sessInst.getFilter();

			if (nodePath != null) {
				expandTreeByNodePath();
			}
			setInfo(true);
			searching = true;
			FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
		}
	}

	public Institution getNode() {
		if (currentNode == null) {
			currentNode = new Institution();
		}
		return currentNode;
	}

	public void setNode(Institution node) {
		try {
			if (node == null)
				return;
			boolean changeSelect = false;
			if (!node.getId().equals(getNode().getId())) {
				changeSelect = true;
			}
			this.currentNode = node;
	
			setInfo(false);
			if (changeSelect) {
				detailNode = (Institution) currentNode.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		filters.add(Filter.create("lang", userLang));

		if (StringUtils.isNotBlank(getFilter().getType())) {
			filters.add(Filter.create("type", getFilter().getType().trim()));
		}
		if (StringUtils.isNotBlank(getFilter().getName())) {
			filters.add(Filter.create("name", Filter.mask(getFilter().getName())));
		}
		if (StringUtils.isNotBlank(getFilter().getDescription())) {
			filters.add(Filter.create("description", Filter.mask(getFilter().getDescription())));
		}
		if (StringUtils.isNotBlank(getFilter().getIdFilter())) {
			filters.add(Filter.create("id", Filter.mask(getFilter().getIdFilter())));
		}
	}

	public void setInfo(boolean restoreState) {
		loadedTabs.clear();
		loadTab(getTabName(), restoreState);

		// get setting for this institution
		// MbSettings settingsBean =
		// (MbSettings)ManagedBeanWrapper.getManagedBean("MbSettings");
		// settingsBean.loadTreeFromOutside();

		// When it's called from constructor _orgStructDao isn't created yet.
		// network = _orgStructDao.getNetworkById( userSessionId,
		// currentNode.getNetworkId(), curLang);
	}

	protected void loadTree() {
		try {
			coreItems = new ArrayList<Institution>();
			if (!searching) {
				return;
			}
			setFilters();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexEnd(-1);
			Institution[] insts = _orgStructDao.getInstitutions(userSessionId, params, userLang,
					true);
			if (insts != null && insts.length > 0) {
				addNodes(0, coreItems, insts);
				if (nodePath == null) {
					if (currentNode == null) {
						currentNode = coreItems.get(0);
						setNodePath(new TreePath(currentNode, null));
						detailNode = (Institution) currentNode.clone();
					} else {
						if (currentNode.getParentId() != null) {
							setNodePath(formNodePath(insts));
						} else {
							setNodePath(new TreePath(currentNode, null));
						}
					}
					setInfo(false);
				}
			}
			if (currentNode != null && !coreItems.contains(currentNode)) {
				// when bean state was restored in constructor and selected node 
				// doesn't correspond to filter conditions we should add it to 
				// list manually 
				coreItems.add(currentNode);
			}
			treeLoaded = true;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public List<Institution> getNodeChildren() {
		Institution inst = getInstitution();
		if (inst == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return inst.getChildren();
		}
	}

	public Institution getNewNode() {
		if (newNode == null) {
			newNode = new Institution();
		}
		return newNode;
	}

	public void setNewNode(Institution newNode) {
		this.newNode = newNode;
	}

	public void addInstitution() {
		newNode = new Institution();
		newNode.setLang(userLang);
		curLang = newNode.getLang();
		// if (currentNode != null && currentNode.getId() != null) {
		// newNode.setParentId(currentNode.getId());
		// }
		curMode = NEW_MODE;
		// return "";
	}

	public void editInstitution() {
		try {
			newNode = detailNode.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newNode = currentNode;
		}
		curMode = EDIT_MODE;
		// return "";
	}

	public void removeInstitution() {
		try {
			_orgStructDao.removeInstitution(userSessionId, currentNode);

			curMode = VIEW_MODE;
			
			deleteNodeFromTree(currentNode, coreItems);
			currentNode = null;
			clearBeansStates();
			if (coreItems.size() > 0) {
				currentNode = coreItems.get(0);
				setNodePath(new TreePath(currentNode, null));
				setInfo(false);
				detailNode = (Institution) currentNode.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newNode = _orgStructDao.addInstitution(userSessionId, newNode);
				detailNode = (Institution) newNode.clone();
				addElementToTree(newNode);
			} else {
				newNode = _orgStructDao.modifyInstitution(userSessionId, newNode);
				detailNode = (Institution) newNode.clone();
				if (!userLang.equals(newNode.getLang())) {
					newNode = getNodeByLang(currentNode.getId(), userLang);
				}
				replaceCurrentNode(newNode);
			}

			setInfo(false);
			curMode = VIEW_MODE;
			MbNetworks beanNetwork = ManagedBeanWrapper.getManagedBean(MbNetworks.class);
			beanNetwork.clearInst();

			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public List<SelectItem> getTypes() {
		return getDictUtils().getArticles(DictNames.INSTITUTION_TYPES, true, false);
	}

	public List<SelectItem> getStatuses() {
		return getDictUtils().getLov(LovConstants.INSTITUTION_STATUSES);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailNode = getNodeByLang(detailNode.getId(), curLang);
	}
	
	public Institution getNodeByLang(Long id, String lang) {
		filters = new ArrayList<Filter>();
		filters.add(Filter.create("id", id.toString()));
		filters.add(Filter.create("lang", lang));
		SelectionParams params = new SelectionParams(filters);
		try {
			Institution[] insts = _orgStructDao.getInstitutions(userSessionId, params, curLang, false);
			if (insts != null && insts.length > 0) {
				return insts[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public Network getNetwork() {
		if (network == null)
			return new Network();
		return network;
	}

	private Institution getInstitution() {
		return (Institution) Faces.var("inst");
	}

	public boolean getNodeHasChildren() {
		Institution message = getInstitution();
		return (message != null) && message.isHasChildren();
	}
	
	public List<SelectItem> getInstitutions() {
		List<SelectItem> institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);
		
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		
		return institutions;
	}


	public void search() {
		curMode = VIEW_MODE;
		setSearching(true);
		sessInst.setFilter(filter);
		clearBean();
		loadTree();
	}

	public void clearBean() {
		nodePath = null;
		currentNode = null;
		detailNode = null;
		coreItems = null;
		treeLoaded = false;
		loadedTabs.clear();
		clearBeansStates();
	}
	
	public void close() {
		curMode = VIEW_MODE;
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		sessInst.setNodePath(nodePath);
		this.nodePath = nodePath;
	}

	public void clearBeansStates() {
		MbContact cont = (MbContact) ManagedBeanWrapper.getManagedBean("MbContact");
		cont.clearState();
		MbAddressesSearch addrSearch = (MbAddressesSearch) ManagedBeanWrapper
				.getManagedBean("MbAddressesSearch");
		addrSearch.fullCleanBean();
		MbContactSearch contSearch = (MbContactSearch) ManagedBeanWrapper
				.getManagedBean("MbContactSearch");
		contSearch.fullCleanBean();
		MbGLAccountsSearch accSearch = (MbGLAccountsSearch) ManagedBeanWrapper
				.getManagedBean("MbGLAccountsSearch");
		accSearch.clearFilter();
		MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
				.getManagedBean("MbNotesSearch");
		notesSearch.clearFilter();
		MbNetworkMembers networks = (MbNetworkMembers) ManagedBeanWrapper
			.getManagedBean("MbNetworkMembers");
		networks.fullCleanBean();
		MbSettingParamsSearch setParamsSearchBean = (MbSettingParamsSearch) ManagedBeanWrapper
				.getManagedBean("MbSettingParamsSearch");
		setParamsSearchBean.clearFilter();
		MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper.getManagedBean("MbAupSchemeObjects");
		schemeBean.fullCleanBean();
		MbCustomersBottom customersBottomBean = (MbCustomersBottom) ManagedBeanWrapper.getManagedBean("MbCustomersBottom");
		if(!customersBottomBean.isCtxAction()){
			customersBottomBean.clearFilter();
		}	
		MbAgent agents = (MbAgent) ManagedBeanWrapper
				.getManagedBean("MbAgent");
		agents.clearFilter();
		MbFraudObjects suiteObjectBean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
		suiteObjectBean.fullCleanBean();
		
	}

	public List<Institution> getSelectedNodeDatas() {
		return selectedNodeDatas;
	}

	public void setSelectedNodeDatas(List<Institution> selectedNodeDatas) {
		this.selectedNodeDatas = selectedNodeDatas;
	}

	public boolean isInSelectedList() {
		if (getSelectedNodeDatas().contains(currentNode))
			return true;
		return false;
	}

	public void instSelectionChange() {
		MbAgent agentBean = (MbAgent) ManagedBeanWrapper.getManagedBean("MbAgent");

		agentBean.getFilter().setInstId(currentNode.getId().intValue());
		agentBean.searchAgents();
	}

	public Object getTreeNodeKey() {
		Object node = Faces.var("inst");
		Long id = ((Institution) node).getId();
		return Arrays.asList(new Object[] { node.getClass(), id });
	}

	public Institution getFilter() {
		
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			initFilterFromContext();
			FacesUtils.setSessionMapValue("initFromContext", null);
//			backLink = (String) FacesUtils.getSessionMapValue("backLink");
			Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
			menu.setKeepState(false);
			search();

		}
		
		if (filter == null)
			filter = new Institution();
		return filter;
	}

	public void setFilter(Institution filter) {
		this.filter = filter;
	}
	
	private void initFilterFromContext() {
		filter = new Institution();
		if (FacesUtils.getSessionMapValue("instId") != null) {
			filter.setIdFilter((FacesUtils.getSessionMapValue("instId")).toString());
			FacesUtils.setSessionMapValue("instId", null);
		}
	}

	public void clearFilter() {
		curMode = VIEW_MODE;
		searching = false;
		filter = null;
		clearBean();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		sessInst.setTabName(tabName);
		this.tabName = tabName;

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName, false);
		
		if (tabName.equalsIgnoreCase("FLEXIBLEFIELDSTAB")) {
			// get flexible data for this institution
			MbFlexFieldsDataSearch bean = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("GLACCOUNTSTAB")) {
			// get GL accounts for this institution

			MbGLAccountsSearch bean = (MbGLAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbGLAccountsSearch");
			bean.keepTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("ADDRESSESTAB")) {
			// get addresses for this institution
			MbAddressesSearch bean = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("CONTACTSTAB")) {
			// get contacts for this institution
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
					.getManagedBean("MbContactSearch");
			cont.setTabName(tabName);
			cont.setParentSectionId(getSectionId());
			cont.setTableState(getSateFromDB(cont.getComponentId()));
			
			MbContactDataSearch contData = (MbContactDataSearch) ManagedBeanWrapper
					.getManagedBean("MbContactDataSearch");
			contData.setTabName(tabName);
			contData.setParentSectionId(getSectionId());
			contData.setTableState(getSateFromDB(contData.getComponentId()));
		} else if (tabName.equalsIgnoreCase("networksTab")) {
			MbNetworkMembers bean = (MbNetworkMembers) ManagedBeanWrapper
					.getManagedBean("MbNetworkMembers");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("NOTESTAB")) {
			MbNotesSearch bean = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("SCHEMESTAB")) {
			MbAupSchemeObjects bean = (MbAupSchemeObjects) ManagedBeanWrapper.getManagedBean("MbAupSchemeObjects");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("associationTab")){
			MbCustomersBottom bean = (MbCustomersBottom) ManagedBeanWrapper.getManagedBean("MbCustomersBottom");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));		
		} else if (tabName.equalsIgnoreCase("suitesTab")) {
			MbFraudObjects bean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("templatesTab")) {
			MbPmoTemplates bean = (MbPmoTemplates) ManagedBeanWrapper.getManagedBean("MbPmoTemplates");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public String getSectionId() {
		return SectionIdConstants.STRUCT_ORG_INST;
	}
	
	private void loadTab(String tab, boolean restoreState) {
		if (tab == null)
			return;
		if (currentNode == null || currentNode.getId() == null) {
			needRerender = tab;
			return;
		}

		if (tab.equalsIgnoreCase("GLACCOUNTSTAB")) {
			// get GL accounts for this institution

			MbGLAccountsSearch accountsBean = (MbGLAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbGLAccountsSearch");
			AccountGL filterAccount = new AccountGL();
			filterAccount.setEntityType(EntityNames.INSTITUTION);
			filterAccount.setEntityId(currentNode.getId().toString());
			filterAccount.setInstId(currentNode.getId().intValue());
			accountsBean.setFilter(filterAccount);
			accountsBean.setBackLink(thisBackLink);
			accountsBean.setPrivilege(AccountPrivConstants.VIEW_TAB_GL_ACCOUNT);
			accountsBean.search();
		} else if (tab.equalsIgnoreCase("ADDRESSESTAB")) {
			// get addresses for this institution
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesSearch");
            addr.fullCleanBean();
            addr.getFilter().setEntityType(EntityNames.INSTITUTION);
            addr.getFilter().setObjectId(currentNode.getId());
			addr.setCurLang(userLang);
			addr.search();
		} else if (tab.equalsIgnoreCase("CONTACTSTAB")) {
			// get contacts for this institution
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
					.getManagedBean("MbContactSearch");
			if (restoreState) {
				cont.restoreBean();
			} else {
				cont.fullCleanBean();
				cont.setBackLink(thisBackLink);
				cont.setObjectId(currentNode.getId().longValue());
				cont.setEntityType(EntityNames.INSTITUTION);
				cont.search();
			}
		} else if (tab.equalsIgnoreCase("FLEXIBLEFIELDSTAB")) {
			// get flexible data for this institution
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(currentNode.getId().intValue());
			filterFlex.setEntityType(EntityNames.INSTITUTION);
			filterFlex.setObjectId(currentNode.getId().longValue());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("SETTINGPARAMSTAB")) {
			// get setting params for this institution
			MbSettingParamsSearch setParamsSearchBean = (MbSettingParamsSearch) ManagedBeanWrapper
					.getManagedBean("MbSettingParamsSearch");
			SettingParam setParamFilter = new SettingParam();
			setParamFilter.setLevelValue(currentNode.getId().toString());
			setParamFilter.setParamLevel(LevelNames.INSTITUTION);
			setParamsSearchBean.setFilter(setParamFilter);
			setParamsSearchBean.search();
		} else if (tab.equalsIgnoreCase("NOTESTAB")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.INSTITUTION);
			filterNote.setObjectId(currentNode.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("networksTab")) {
			MbNetworkMembers networks = (MbNetworkMembers) ManagedBeanWrapper
					.getManagedBean("MbNetworkMembers");
			networks.fullCleanBean();
			networks.getFilter().setInstId(currentNode.getId().intValue()); 
			networks.setInstNetrowkId(currentNode.getNetworkId());
			networks.setShowNetworks(true);
			networks.setPrivilege(NetPrivConstants.VIEW_TAB_NETWORK_MEMBER);
			networks.search();
		} else if (tab.equalsIgnoreCase("SCHEMESTAB")) {
			MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper.getManagedBean("MbAupSchemeObjects");
			schemeBean.setObjectId(currentNode.getId().longValue());
			schemeBean.setDefaultEntityType(EntityNames.INSTITUTION);
			schemeBean.setInstId(currentNode.getId().intValue()); // Intitution's'ID is actually an integer
			schemeBean.search();
		} else if (tab.equalsIgnoreCase("associationTab")){
			MbCustomersBottom customersBottomBean = (MbCustomersBottom) ManagedBeanWrapper.getManagedBean("MbCustomersBottom");
			Customer filter = customersBottomBean.getFilter();
			filter.setExtEntityType(EntityNames.INSTITUTION);
			filter.setExtObjectId(currentNode.getId().longValue());
			customersBottomBean.setPrivilege(ProductPrivConstants.VIEW_TAB_CUSTOMERS);
			customersBottomBean.search();		
		} else if (tab.equalsIgnoreCase("agentsTab")){
			MbAgent mbAgents = (MbAgent) ManagedBeanWrapper
					.getManagedBean("MbAgent");
			Agent agent = mbAgents.getFilter();
			agent.setInstId(currentNode.getId().intValue());
			mbAgents.setFilter(agent);
			mbAgents.setPrivilege(OrgStructPrivConstants.VIEW_TAB_AGENT);
			mbAgents.searchAgents();
		} else if (tab.equalsIgnoreCase("suitesTab")) {
			MbFraudObjects fraudObjectsBean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
			fraudObjectsBean.setObjectId(currentNode.getId().longValue());
			fraudObjectsBean.setEntityType(EntityNames.INSTITUTION);
			fraudObjectsBean.setPrivilege(FraudPrivConstants.VIEW_TAB_SUITE);
			fraudObjectsBean.search();
		} else if (tab.equalsIgnoreCase("attributesTab")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			attrs.setObjectId(currentNode.getId());
			attrs.setEntityType(EntityNames.INSTITUTION);
			attrs.setInstId(currentNode.getId().intValue());
		} else if (tab.equalsIgnoreCase("templatesTab")) {
			MbPmoTemplates templatesBean = (MbPmoTemplates) ManagedBeanWrapper.getManagedBean("MbPmoTemplates");
			PmoTemplate templateFilter = new PmoTemplate();
			templateFilter.setInstId(currentNode.getId().intValue());
			templateFilter.setInstName(currentNode.getName());
			templateFilter.setEntityType(EntityNames.INSTITUTION);
			templateFilter.setObjectId(currentNode.getId());
			templatesBean.setTemplateFilter(templateFilter);
			templatesBean.setPrivilege(PaymentOrderPrivConstants.VIEW_TAB_PMO_TEMPLATE);
			templatesBean.search();
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
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}

	public List<SelectItem> getNetworks() {
		if (networks == null) {
			networks = getDictUtils().getLov(LovConstants.CARD_NETWORK);
		}
		return networks;
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newNode.getLang();
		Institution tmp = getNodeByLang(newNode.getId(), newNode.getLang());
		if (tmp != null) {
			newNode.setName(tmp.getName());
			newNode.setDescription(tmp.getDescription());
		}
	}

	public void cancelEditLanguage() {
		newNode.setLang(oldLang);
	}
	
	public String gotoAgents() {
/*		
		MbAgent aBean = (MbAgent) ManagedBeanWrapper.getManagedBean("MbAgent");
		aBean.getFilter().setInstId(currentNode.getId().intValue()); // get GL accounts for this institution
		aBean.searchAgents();
		aBean.setSaveAfterSearch(true);
		aBean.setDisabledInst(true);
*/		
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("instId", currentNode.getId().intValue());
		queueFilter.put("backLink", thisBackLink);
		
		
		addFilterToQueue("MbAgent", queueFilter);
		
		Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect("orgStruct|agents");
		return "showAgents";
	}

	public Institution getDetailNode() {
		return detailNode;
	}

	public void setDetailNode(Institution detailNode) {
		this.detailNode = detailNode;
	}
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) return null;
		Map <String, Object> map = new HashMap<String, Object>();
		if (currentNode != null){
			if (EntityNames.INSTITUTION.equals(ctxItemEntityType)) {
				map.put("id", currentNode.getId());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.INSTITUTION);
	}
	
	public void activate(){
		MbNetworkMembers members = (MbNetworkMembers) ManagedBeanWrapper
				.getManagedBean("MbNetworkMembers");
		members.setShowNetworks(true);
	}
	
}
