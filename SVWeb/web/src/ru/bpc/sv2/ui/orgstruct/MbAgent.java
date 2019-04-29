package ru.bpc.sv2.ui.orgstruct;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.component.table.AllNodesCollapsed;
import org.openfaces.component.table.DynamicNodeExpansionState;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OrgStructDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.orgstruct.AgentType;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.Customer;
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
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.products.MbCustomersBottom;
import ru.bpc.sv2.ui.settings.MbSettingParamsSearch;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbAgent")
public class MbAgent extends AbstractTreeBean<Agent> {
	private static final long serialVersionUID = -5207024570099387011L;

	private OrgStructDao _orgStructDao = new OrgStructDao();

	private Agent newNode;
	private Agent detailNode;

	private Institution[] institutionsArr;
	private ArrayList<SelectItem> institutionsList;
	private ArrayList<Agent> currentAgents;

	protected String tabName;
	private List<Agent> selectedNodeDatas;
	

	private MbAgentSess sessAgent;
	private Agent filter;
	private static final Logger logger = Logger.getLogger("ORG_STRUCTURE");

	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

	private String oldLang;
	private boolean saveAfterSearch;
	
	private String ctxItemEntityType;
	private ContextType ctxType;
	private boolean disabledInst;
	private String backLink;
	
	private Long parentId;
	private String privilege;
	
	public MbAgent() {
		pageLink = "orgStruct|agents";
		setExpandLevel(new DynamicNodeExpansionState(new AllNodesCollapsed()));

		
		sessAgent = (MbAgentSess) ManagedBeanWrapper.getManagedBean("MbAgentSess");
		tabName = "detailsTab";
		thisBackLink = "ost_agents";
	}

	@PostConstruct
	public void init() {
		setDefaultValues();

		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE;
			// if user came here from menu, we don't need to select previously
			// selected tab
//			sessAgent.setTabName(tabName);
//			clearBeansStates();
		} else {
			searching = true;
			nodePath = sessAgent.getNodePath();
			filter = sessAgent.getFilter();
			tabName = sessAgent.getTabName();
			
			if (nodePath != null) {
				expandTreeByNodePath();
			}
			if (sessAgent.isLoadImmediately()) {
				loadTree();
			}
			loadTab(tabName, true);
			FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
		}
		
		restoreFilter();
	}
	
	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbAgent");

		if (queueFilter==null)
			return;

		if (queueFilter.containsKey("instId")){
			getFilter().setInstId((Integer)queueFilter.get("instId"));
		}
		if (queueFilter.containsKey("backLink")){
			backLink=(String)queueFilter.get("backLink");
		}
		
		searchAgents();
		setSaveAfterSearch(true);
	}
	
	public String back() {
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect(backLink);
		return backLink;
	}
	
	public boolean isShowBackBtn() {
		return backLink == null ? false : (backLink.trim().length() > 0 ? true : false);
	}
	
	public Agent getNode() {
		if (currentNode == null) {
			currentNode = new Agent();
		}
		return currentNode;
	}

	public void setNode(Agent node) {
		try {
			if (node == null)
				return;
			
			boolean changeSelect = false;
			if (!node.getId().equals(getNode().getId())) {
				changeSelect = true;
			}
			
			this.currentNode = node;
			setInfo();
			
			if (changeSelect) {
				detailNode = (Agent) currentNode.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setInfo() {
		loadedTabs.clear();
		loadTab(getTabName(), false);
	}

	protected void loadTree() {
		try {
			coreItems = new ArrayList<Agent>();
			currentAgents = new ArrayList<Agent>();

			if (!searching)
				return;

			// if (instId == null) {
			// loadInstitutions();
			// }
			if (getFilter().getInstId() != null) {
				setFilters();
				SelectionParams params = new SelectionParams();
				params.setFilters(filters.toArray(new Filter[filters.size()]));
				params.setRowIndexEnd(-1);
				params.setStartWith(getParentId());
				params.setPrivilege(privilege);
				Agent[] agents = _orgStructDao.getAgentsTree(userSessionId, params);
				if (agents != null && agents.length > 0) {
					addNodes(0, coreItems, agents);
					fillCurrentAgents(coreItems);
					if (nodePath == null) {
						if (currentNode == null) {
							currentNode = coreItems.get(0);
							detailNode = (Agent) currentNode.clone();
							setNodePath(new TreePath(currentNode, null));
						} else {
							if (currentNode.getParentId() != null) {
								setNodePath(formNodePath(agents));
							} else {
								setNodePath(new TreePath(currentNode, null));
							}
						}
						setInfo();
					}
				}
				if (currentNode != null && !restoreBean) {
					if (!currentAgents.contains(currentNode)) {
						// in case we added item that doesn't fit filter conditions
						coreItems.add(currentNode);
						setNodePath(new TreePath(currentNode, null));
					} else {
						currentNode = findCurrentNode(coreItems);
						if (currentNode.getParentId() != null) {
							setNodePath(formNodePath(agents));
						} else {
							setNodePath(new TreePath(currentNode, null));
						}
					}
					setInfo();
				}
				restoreBean = false;
				treeLoaded = true;
			}
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	private Agent findCurrentNode(List<Agent> nodes) {
		Agent result = null;
		if (nodes != null) {
			for (Agent agent : nodes) {
				if (agent.getId().equals(currentNode.getId())) {
					result = agent;
					break;
				} else {
					result = findCurrentNode(agent.getChildren());
					if (result != null) break;
				}
			}
		} 
		return result;
	}
	
	private void fillCurrentAgents(List<Agent> agents) {
		for (Agent agent: agents) {
			currentAgents.add(agent);
			if (agent.isHasChildren()) {
				fillCurrentAgents(agent.getChildren());
			}
		}
	}

	private void addAgentToList(Agent agent) {
		currentAgents.add(agent);
	}

	private void removeAgentFromList(Agent agent) {
		for (Agent item: currentAgents) {
			if (agent.getId().equals(item.getId())) {
				currentAgents.remove(agent);
				break;
			}
		}
	}
	
	public List<Agent> getNodeChildren() {
		Agent agent = getAgent();
		if (agent == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			if (saveAfterSearch) {
				saveBean();
				FacesUtils.setSessionMapValue(thisBackLink, Boolean.TRUE);
				sessAgent.setLoadImmediately(true);
			}
			return coreItems;
		} else {
			return agent.getChildren();
		}
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("instId");
		paramFilter.setValue(filter.getInstId().toString());
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("agentType");
			paramFilter.setValue(filter.getType());
			filters.add(paramFilter);
		}

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getExternalNumber() != null && filter.getExternalNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("externalNumber");
			paramFilter.setValue(filter.getExternalNumber().toString());
			filters.add(paramFilter);
		}

	}

	public Agent getNewNode() {
		if (newNode == null) {
			newNode = new Agent();
		}
		return newNode;
	}

	public void setNewNode(Agent newNode) {
		this.newNode = newNode;
	}

	public void addAgent() {
        if (backLink != null && backLink.equals("ost_institutions")){
            setDisabledInst(true);
        }
		newNode = new Agent();
		if (currentNode != null) {
			newNode.setParentId(currentNode.getId());
		}
		newNode.setInstId(currentNode.getInstId() != null ? currentNode.getInstId() : filter
				.getInstId());
		newNode.setLang(userLang);
		curLang = newNode.getLang();
		curMode = NEW_MODE;
		// return "";
	}

	public void editAgent() {
        setDisabledInst(true);
        try {
			newNode = detailNode.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newNode = currentNode;
		}
		curMode = EDIT_MODE;
		// return "";
	}

	public void removeAgent() {
		try {
			_orgStructDao.removeAgent(userSessionId, currentNode);
			curMode = VIEW_MODE;

			deleteNodeFromTree(currentNode, coreItems);
			removeAgentFromList(currentNode);
			currentNode = null;
			detailNode = null;
			clearBeansStates();
			if (coreItems.size() > 0) {
				currentNode = coreItems.get(0);
				setNodePath(new TreePath(currentNode, null));
				setInfo();
				detailNode = (Agent) currentNode.clone();
			}
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newNode = _orgStructDao.addAgent(userSessionId, newNode);
				detailNode = (Agent) newNode.clone();
				if (newNode != null){
					if (!newNode.isDefault()) {
						addElementToTree(newNode);
						addAgentToList(currentNode);
						setInfo();
					} else {
						currentNode = newNode;
						searching = true;
						loadTree();
					}
				}
			} else {
				newNode = _orgStructDao.modifyAgent(userSessionId, newNode);
				detailNode = (Agent) newNode.clone();
				if (!userLang.equals(newNode.getLang())) {
					newNode = getNodeByLang(currentNode.getId(), userLang);
				}
				if (newNode.isDefault() == currentNode.isDefault()) {
					replaceCurrentNode(newNode);
					setInfo();
				} else {
					currentNode = newNode;
					loadTree();
				}
			}

			curMode = VIEW_MODE;
            setDisabledInst(false);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
		newNode = new Agent();
        setDisabledInst(false);
	}

	public void searchAgents() {
		curMode = VIEW_MODE;
		setSearching(true);
		sessAgent.setFilter(filter);
		clearBean();
		loadTree();
	}

	public void clearBean() {
		nodePath = null;
		currentNode = null;
		detailNode = null;
		coreItems = null;
		treeLoaded = false;
		disabledInst = false;
		loadedTabs.clear();
		clearBeansStates();
	}
	
	public void clearFilter() {
		curMode = VIEW_MODE;
		filter = null;
		searching = false;
		clearBean();
		setDefaultValues();
	}

	private void setDefaultValues() {
        setDisabledInst(false);
		Integer defaultInstId = userInstId;
		List<SelectItem> instList = getInstitutions();
		if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
			// instId from LOV is for some reason String 
			defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
		}
		getFilter().setInstId(defaultInstId);
	}

	public Agent getNodeByLang(Long id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id + "");
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setPrivilege(privilege);
		try {
			Agent[] agents = _orgStructDao.getAgentsList(userSessionId, params);
			if (agents != null && agents.length > 0) {
				return agents[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailNode = getNodeByLang(detailNode.getId(), curLang);
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newNode.getLang();
		Agent tmp = getNodeByLang(newNode.getId(), newNode.getLang());
		if (tmp != null) {
			newNode.setName(tmp.getName());
			newNode.setDescription(tmp.getDescription());
		}
	}

	public void cancelEditLanguage() {
		newNode.setLang(oldLang);
	}

	private Agent getAgent() {
		return (Agent) Faces.var("agent");
	}

	public boolean getNodeHasChildren() {
		Agent message = getAgent();
		return (message != null) && message.isHasChildren();
	}

	public void checkAgentType(FacesContext context, UIComponent component, Object value) {
		if (value == null) {
			FacesUtils.addMessageError(new Exception("Select agent type."));
		}
	}

	// public SelectItem[] getAgents() {
	// Agent[] agents = _orgStructDao.getAgents( userSessionId, instId, curLang,
	// false);
	// SelectItem[] items = new SelectItem[agents.length];
	// for (int i = 0; i < agents.length; i++) {
	// items[i] = new SelectItem(agents[i].getId(), agents[i].getShortDesc(),
	// agents[i].getFullDesc());
	// }
	// return items;
	// }

	public void close() {
		curMode = VIEW_MODE;
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		sessAgent.setNodePath(nodePath);
		this.nodePath = nodePath;
	}

	private void loadInstitutions() {
		try {
			institutionsArr = _orgStructDao.getInstitutions(userSessionId, null, curLang, true);
			// if (instId == null && institutions.length > 0) {
			// instId = institutions[0].getId();
			// }
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutionsList == null) {
			institutionsList = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutionsList == null)
			institutionsList = new ArrayList<SelectItem>();
		return institutionsList;
	}

	public HashMap<Long, String> getInstNames() {
		HashMap<Long, String> instNames = new HashMap<Long, String>();
		if (institutionsArr == null) {
			loadInstitutions();
		}
		for (Institution inst: institutionsArr) {
			instNames.put(inst.getId(), inst.getName());
		}
		return instNames;
	}

	public ArrayList<SelectItem> getParentAgents() {
		// as parent agent editing is forbidden we don't need to load
		// all agents from database 
		if (isEditMode()) {
			if (newNode.getParentId() == null) {
				return new ArrayList<SelectItem>(0);
			}
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(1);
			String name = getAgentsName(coreItems, newNode.getParentId());
			if (name != null) {
				items.add(new SelectItem(newNode.getParentId(), name));
			} else {
				items.add(new SelectItem(newNode.getParentId(), newNode.getParentId().toString()));
			}
			return items;
		}
		
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("instId");
		filters[1].setValue(getNewNode().getInstId());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setPrivilege(privilege);
		
		try {
			return getStruct(params);
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		return new ArrayList<SelectItem>(0);
	}
	
	public ArrayList<SelectItem> getParentAgentsFilter() {

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("instId");
		filters[1].setValue(getFilter().getInstId());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setPrivilege(privilege);
		
		try {
			return getStruct(params);
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		return new ArrayList<SelectItem>(0);
	}
	
	private ArrayList<SelectItem> getStruct(SelectionParams params){
		Agent[] agents = _orgStructDao.getAgentsTree(userSessionId, params);
		ArrayList<SelectItem> items = new ArrayList<SelectItem>(agents.length);

		for (Agent agent: agents) {
			String name = agent.getName();
			for (int i = 1; i < agent.getLevel(); i++) {
				name = "--" + name;
			}
			if (agent.getLevel() > 1)
				name = " " + name + " ";
			items.add(new SelectItem(agent.getId(), name));
		}
		return items;
	}

	private String getAgentsName(List<Agent> agents, Long agentId) {
		for (Agent agent: agents) {
			if (agent.getId().equals(agentId)) {
				return agent.getName();
			}
			if (agent.isHasChildren()) {
				String name = getAgentsName(agent.getChildren(), agentId);
				if (name != null) {
					return name;
				}
			}
		}
		return null; 
	}
	
	public ArrayList<SelectItem> getPossibleAgentTypes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		AgentType agentType = new AgentType();
		agentType.setInstId(getFilter().getInstId());

		// find type of selected parent object
		if (newNode.getParentId() != null) {
			for (Agent agent: getCurrentAgents()) {
				if (newNode.getParentId().equals(agent.getId())) {
					agentType.setType(agent.getType());
					break;
				}
			}
		}

		// get agent types by parent type
		// TODO try catch
		try {
			String[] types = _orgStructDao.getAgentTypesByParent(userSessionId, agentType);
			for (String type: types) {
				items.add(new SelectItem(type, getDictUtils().getAllArticlesDesc().get(type)));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		return items;
	}

	public ArrayList<SelectItem> getAgentTypes() {
		return getDictUtils().getArticles(DictNames.AGENT_TYPE, true, false);
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
		MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
				.getManagedBean("MbNotesSearch");
		notesSearch.clearFilter();
		MbGLAccountsSearch accountsBean = (MbGLAccountsSearch) ManagedBeanWrapper
				.getManagedBean("MbGLAccountsSearch");
		accountsBean.clearFilter();
		MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
				.getManagedBean("MbFlexFieldsDataSearch");
		flexible.clearFilter();
		MbSettingParamsSearch setParamsSearchBean = (MbSettingParamsSearch) ManagedBeanWrapper
				.getManagedBean("MbSettingParamsSearch");
		setParamsSearchBean.clearFilter();
		MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper.getManagedBean("MbAupSchemeObjects");
		schemeBean.fullCleanBean();
		MbCustomersBottom customersBottomBean = (MbCustomersBottom) ManagedBeanWrapper.getManagedBean("MbCustomersBottom");
		if(!customersBottomBean.isCtxAction()){
			customersBottomBean.clearFilter();
		}
	}

	public List<Agent> getSelectedNodeDatas() {
		return selectedNodeDatas;
	}

	public void setSelectedNodeDatas(List<Agent> selectedNodeDatas) {
		this.selectedNodeDatas = selectedNodeDatas;
	}

	public Agent getFilter() {
		if (filter == null) {
			filter = new Agent();
		}
		return filter;
	}

	public void setFilter(Agent filterAgent) {
		this.filter = filterAgent;
	}

	public void applyAgentType() {

	}

	public boolean isManagingNew() {
		if (curMode == NEW_MODE)
			return true;
		if (curMode == EDIT_MODE)
			return false;

		return true;
	}

	public ArrayList<Agent> getCurrentAgents() {
		if (currentAgents == null)
			currentAgents = new ArrayList<Agent>();
		return currentAgents;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		sessAgent.setTabName(tabName);
		this.tabName = tabName;

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName, false);
		
		if (tabName.equalsIgnoreCase("flexFieldsTab")) {
			MbFlexFieldsDataSearch bean = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("accountsTab")) {
			MbGLAccountsSearch bean = (MbGLAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbGLAccountsSearch");
			bean.keepTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("addressesTab")) {
			MbAddressesSearch bean = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("contactsTab")) {
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
		} else if (tabName.equalsIgnoreCase("notesTab")) {
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
		}
	}

	public String getSectionId() {
		return SectionIdConstants.STRUCT_ORG_AGENT;
	}
	
	private void loadTab(String tab, boolean restoreState) {
		if (tab == null)
			return;
		if (currentNode == null || currentNode.getId() == null) {
			needRerender = tab;
			return;
		}

		if (tab.equalsIgnoreCase("flexFieldsTab")) {
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(currentNode.getInstId());
			filterFlex.setEntityType(EntityNames.AGENT);
			filterFlex.setObjectId(currentNode.getId().longValue());
			flexible.setFilter(filterFlex);
			flexible.search();
		}
		if (tab.equalsIgnoreCase("accountsTab")) {
			MbGLAccountsSearch accountsBean = (MbGLAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbGLAccountsSearch");
			accountsBean.clearFilter();
			accountsBean.getFilter().setEntityType(EntityNames.AGENT);
			accountsBean.getFilter().setEntityId(currentNode.getId().toString());
			accountsBean.getFilter().setInstId(currentNode.getInstId());
			accountsBean.setBackLink(thisBackLink);
			accountsBean.search();
		}
		if (tab.equalsIgnoreCase("addressesTab")) {
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesSearch");
            addr.fullCleanBean();
            addr.getFilter().setEntityType(EntityNames.AGENT);
            addr.getFilter().setObjectId(currentNode.getId());
			addr.setCurLang(userLang);
			addr.search();
		}
		if (tab.equalsIgnoreCase("contactsTab")) {
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
					.getManagedBean("MbContactSearch");
			if (restoreState) {
				cont.restoreBean();
			} else {
				cont.fullCleanBean();
				cont.setBackLink(thisBackLink);
				cont.setObjectId(currentNode.getId().longValue());
				cont.setEntityType(EntityNames.AGENT);
			}
		}
		if (tab.equalsIgnoreCase("settingParamsTab")) {
			MbSettingParamsSearch setParamsSearchBean = (MbSettingParamsSearch) ManagedBeanWrapper
					.getManagedBean("MbSettingParamsSearch");
			SettingParam setParamFilter = new SettingParam();
			setParamFilter.setLevelValue(currentNode.getId().toString());
			setParamFilter.setParamLevel(LevelNames.AGENT);
			setParamsSearchBean.setFilter(setParamFilter);
			setParamsSearchBean.search();
		}
		if (tab.equalsIgnoreCase("notesTab")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.AGENT);
			filterNote.setObjectId(currentNode.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("SCHEMESTAB")) {
			MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper.getManagedBean("MbAupSchemeObjects");
			schemeBean.setObjectId(currentNode.getId().longValue());
			schemeBean.setDefaultEntityType(EntityNames.AGENT);
			schemeBean.setInstId(currentNode.getInstId());
			schemeBean.search();
		} else if (tab.equalsIgnoreCase("associationTab")){
			MbCustomersBottom customersBottomBean = (MbCustomersBottom) ManagedBeanWrapper.getManagedBean("MbCustomersBottom");
			Customer filter = customersBottomBean.getFilter();
			filter.setExtEntityType(EntityNames.AGENT);
			filter.setExtObjectId(currentNode.getId().longValue());
			customersBottomBean.search();		
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

	private void saveBean() {
		sessAgent.setFilter(filter);
		sessAgent.setNodePath(nodePath);
		sessAgent.setTabName(tabName);
	}

	public boolean isSaveAfterSearch() {
		return saveAfterSearch;
	}

	public void setSaveAfterSearch(boolean saveAfterSearch) {
		this.saveAfterSearch = saveAfterSearch;
	}
	
	@PreDestroy
	public void preDestroy() {
		System.out.println("predestroy...");
	}

	public Agent getDetailNode() {
		return detailNode;
	}

	public void setDetailNode(Agent detailNode) {
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
			if (EntityNames.AGENT.equals(ctxItemEntityType)) {
				map.put("id", currentNode.getId());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.AGENT);
	}

	public boolean isDisabledInst() {
		return disabledInst;
	}

	public void setDisabledInst(boolean disabledInst) {
		this.disabledInst = disabledInst;
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public void setPrivilege(String privilege) {
		this.privilege = privilege;
	}
}
