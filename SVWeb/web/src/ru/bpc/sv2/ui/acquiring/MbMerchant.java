package ru.bpc.sv2.ui.acquiring;


import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.datamanagement.*;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContact;
import ru.bpc.sv2.ui.common.MbContactDataSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.products.MbAttributeValues;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.reports.MbEntityObjectInfoBottom;
import ru.bpc.sv2.ui.reports.MbReportsBottom;
import ru.bpc.sv2.ui.session.StoreFilter;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.FilterFactory;
import ru.bpc.sv2.ui.utils.RequestContextHolder;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import javax.xml.ws.BindingProvider;
import java.net.SocketTimeoutException;
import java.net.UnknownHostException;
import java.text.ParseException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ViewScoped
@ManagedBean (name = "MbMerchant")
public class MbMerchant extends AbstractTreeBean<Merchant> {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ACQUIRING");
	private static Integer DEFAULT_INST = 9999;

	private AcquiringDao _acquireDao = new AcquiringDao();
	private EventsDao _eventsDao = new EventsDao();
	private ProductsDao _productsDao = new ProductsDao();

	protected Merchant currentNode; // node we are working with

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> merchantStatuses;
	private ArrayList<SelectItem> merchantTypes;
	private ArrayList<Merchant> coreItems;
	private TreePath nodePath;

	private Merchant filter;

	protected String tabName;
	private HashMap<String, Object> paramMap;
	private boolean treeLoaded = false;
	
	protected MbMerchantSess sessMerchant;

	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	protected String needRerender;
	private List<String> rerenderList;

	private String backLink;
	private List<Terminal> reloadResult;
	
	private ContextType ctxType;
	private String ctxItemEntityType;

	public MbMerchant() {
		pageLink = "acquiring|merchants";
		tabName = "detailsTab";
		thisBackLink = "acquiring|merchants";

		sessMerchant = (MbMerchantSess) ManagedBeanWrapper.getManagedBean("MbMerchantSess");
		sessMerchant.setTabName(tabName);

//		setDefaultValues();
		
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean != null && restoreBean) {
			restoreState();
			FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
		}

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
	}

	public Merchant getNode() {
		if (currentNode == null) {
			currentNode = new Merchant();
		}
		return currentNode;
	}

	public void setNode(Merchant node) {
		if (node == null)
			return;
		this.currentNode = node;
		setBeans();
	}

	private void setBeans() {
		loadedTabs.clear();
		loadTab(getTabName());
	}

	private int addNodes(int startIndex, ArrayList<Merchant> branches, Merchant[] merchants) {
		// int counter = 1;
		int i;
		int level = merchants[startIndex].getLevel();

		for (i = startIndex; i < merchants.length; i++) {
			if (merchants[i].getLevel() != level) {
				break;
			}
			branches.add(merchants[i]);
			if ((i + 1) != merchants.length && merchants[i + 1].getLevel() > level) {
				merchants[i].setChildren(new ArrayList<Merchant>());
				i = addNodes(i + 1, merchants[i].getChildren(), merchants);
			}
			// counter++;
		}
		return i - 1;
	}

	protected void loadTree() {
		if (!searching)
			return;

		Merchant[] merchants = null;
		coreItems = new ArrayList<Merchant>();
		try {
			setFilters();

			SelectionParams params = new SelectionParams();
			params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
			getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
	        getParamMap().put("tab_name", "MERCHANT");
			if (_acquireDao == null) {
				_acquireDao = new AcquiringDao();
			}
			
			int count = 0;
			int threshold = 1000;
			params.setThreshold(threshold);
			count = _acquireDao.getMerchantsCurCount(userSessionId, paramMap);
			if (count >= threshold){
				count = 0;
				throw new DataAccessException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "many_records"));
			}
			merchants = _acquireDao.getMerchantsCur(userSessionId, params, paramMap);

			if (merchants != null && merchants.length > 0) {
				count = addNodes(0, coreItems, merchants);
				if (nodePath == null) {
					if (currentNode == null) {
						currentNode = coreItems.get(0);
						setNodePath(new TreePath(currentNode, null));
					} else {
						if (currentNode.getParentId() != null) {
							setNodePath(formNodePath(merchants));
						} else {
							setNodePath(new TreePath(currentNode, null));
						}
					}
				}
				setBeans();
			}
			
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		} finally {
			if (merchants == null)
				merchants = new Merchant[0];
		}
		treeLoaded = true;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>(2);

		// main filters, used in any merchants search
		Filter paramFilter = null;

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getStatus());
			filters.add(paramFilter);
		}

		if (filter.getMerchantType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_TYPE");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getMerchantType());
			filters.add(paramFilter);
		}

		if (filter.getMerchantNumber() != null && filter.getMerchantNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_NUMBER");
			paramFilter.setValue(filter.getMerchantNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_NUMBER");
			paramFilter.setValue(filter.getCustomerNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getCompanyName() != null && filter.getCompanyName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("COMPANY_NAME");
			paramFilter.setValue(filter.getCompanyName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getId() != null){
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_ID");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		
	}

	public List<Merchant> getNodeChildren() {
		Merchant merchant = getMerchant();
		if (merchant == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return merchant.getChildren();
		}
	}

	public void cancel() {
	}

	public void searchMerchants() {
		nodePath = null;
		currentNode = null;
		loadedTabs.clear();
		clearBeansStates();
		setSearching(true);
		loadTree();
	}

	public void changeLanguage(ValueChangeEvent event) {
		String lang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];

		filters[0] = new Filter();
		filters[0].setElement("MERCHANT_ID");
		filters[0].setValue(currentNode.getId());
		filters[1] = new Filter();
		filters[1].setElement("LANG");
		filters[1].setValue(lang);
		getParamMap().put("param_tab", filters);
        getParamMap().put("tab_name", "MERCHANT");

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Merchant[] merchants = _acquireDao.getMerchantsCur(userSessionId, params, paramMap);
			if (merchants != null && merchants.length > 0) {
				currentNode = merchants[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}

	}

	private Merchant getMerchant() {
		return (Merchant) Faces.var("merchant");
	}

	public boolean getNodeHasChildren() {
		Merchant message = getMerchant();
		return (message != null) && message.isHasChildren();
	}

	public void close() {
	}

	public void clearFilter() {
		nodePath = null;
		currentNode = null;
		loadedTabs.clear();
		clearBeansStates();
		coreItems = null;
		treeLoaded = false;
		searching = false;
		filter = null;
		clearSectionFilter();
		setDefaultValues();
	}

	private void setDefaultValues() {
		Integer defaultInstId = userInstId;
		List<SelectItem> instList = getInstitutions();
		if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
			// instId from LOV is for some reason String 
			defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
		}
		getFilter().setInstId(defaultInstId);
	}
	
	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		sessMerchant.setNodePath(nodePath);
		this.nodePath = nodePath;
	}

	public Merchant getFilter() {
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			initFilterFromContext();
			backLink = (String) FacesUtils.getSessionMapValue("backLink");
			FacesUtils.setSessionMapValue("initFromContext", null);
			searchMerchants();
		}
		if (filter == null) {
			filter = new Merchant();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Merchant filter) {
		this.filter = filter;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getMerchantTypes() {
		if(merchantTypes == null){
			merchantTypes = getDictUtils().getArticles(DictNames.MERCHANT_TYPE, false, false);
		}
		if(merchantTypes == null){
			merchantTypes = new ArrayList<SelectItem>();
		}
		return merchantTypes;
	}

	public void clearBeansStates() {
		MbContact contractBean = (MbContact) ManagedBeanWrapper.getManagedBean(MbContact.class);
		contractBean.clearState();

		MbAddressesSearch addrSearchBean = ManagedBeanWrapper.getManagedBean(MbAddressesSearch.class);
		addrSearchBean.fullCleanBean();

		MbContactSearch contSearchBean = ManagedBeanWrapper.getManagedBean(MbContactSearch.class);
		contSearchBean.fullCleanBean();

		MbNotesSearch notesBean = ManagedBeanWrapper.getManagedBean(MbNotesSearch.class);
		notesBean.clearFilter();

		MbCustomersDependent custBean = ManagedBeanWrapper.getManagedBean(MbCustomersDependent.class);
		custBean.clearBean();

		MbAupSchemeObjects schemeBean = ManagedBeanWrapper.getManagedBean(MbAupSchemeObjects.class);
		schemeBean.fullCleanBean();

		MbLimitCounters limitCountersBean = ManagedBeanWrapper.getManagedBean(MbLimitCounters.class);
		limitCountersBean.clearFilter();

		MbCycleCounters cycleCountersBean = ManagedBeanWrapper.getManagedBean(MbCycleCounters.class);
		cycleCountersBean.clearFilter();

		MbTerminalsBottom terminalBean = ManagedBeanWrapper.getManagedBean(MbTerminalsBottom.class);
		terminalBean.clearFilter();
        
		MbReportsBottom reportsBean = ManagedBeanWrapper.getManagedBean(MbReportsBottom.class);
		reportsBean.clearFilter();

		MbMerchantCards cardsBean = ManagedBeanWrapper.getManagedBean(MbMerchantCards.class);
		cardsBean.clearFilter();

		MbEntityObjectInfoBottom infoBean = ManagedBeanWrapper.getManagedBean(MbEntityObjectInfoBottom.class);
		infoBean.clearFilter();
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
		paramMap = new HashMap<String, Object>();
		sessMerchant.setSearching(searching);
	}
	
	public String toTerminals() {
		sessMerchant.setSearching(true);
		sessMerchant.setFilter(filter);
		StoreFilter storeFilter = getStoreFilter();
		
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("instId", filter.getInstId());
		queueFilter.put("status", filter.getStatus());
		queueFilter.put("merchantType", filter.getMerchantType());
		queueFilter.put("merchantNumber", filter.getMerchantNumber());
		queueFilter.put("customerNumber", filter.getCustomerNumber());
		queueFilter.put("companyName", filter.getCompanyName());
		addFilterToQueue("MbMerchant", queueFilter);
		
		queueFilter.clear();
		queueFilter.put("merchantNumber", currentNode.getMerchantNumber());
		queueFilter.put("instId", currentNode.getInstId());
		queueFilter.put("backLink", thisBackLink);

		
		addFilterToQueue("MbTerminal", queueFilter);
		return "terminals";
	}

	public String toApplications() {
		try {
			HashMap<String,Object> queueFilter = new HashMap<String,Object>();
			queueFilter.put("instId", filter.getInstId());
			queueFilter.put("status", filter.getStatus());
			queueFilter.put("merchantType", filter.getMerchantType());
			queueFilter.put("merchantNumber", filter.getMerchantNumber());
			queueFilter.put("customerNumber", filter.getCustomerNumber());
			queueFilter.put("companyName", filter.getCompanyName());
			addFilterToQueue("MbMerchant", queueFilter);
			
			queueFilter.clear();
			queueFilter.put("merchantNumber", currentNode.getMerchantNumber());
			queueFilter.put("instId", currentNode.getInstId());
			queueFilter.put("objectId", currentNode.getId());
			queueFilter.put("entityType", EntityNames.MERCHANT);
			queueFilter.put("backLink", thisBackLink);

			addFilterToQueue("MbApplicationsSearch", queueFilter);
			
			Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
			mbMenu.externalSelect("applications|list_acq_apps");
			
			return "acquiring|applications|list_apps";
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return "";
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		sessMerchant.setTabName(tabName);
		this.tabName = tabName;

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName);
		
		if (tabName.toUpperCase().equals("FLEXFIELDSTAB")) {
			MbFlexFieldsDataSearch bean = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.toUpperCase().equals("ACCOUNTSTAB")) {
			MbAccountsSearch bean = (MbAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbAccountsSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.toUpperCase().equals("ADDRESSESTAB")) {
			MbAddressesSearch bean = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.toUpperCase().equals("CONTACTSTAB")) {
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
		} else if (tabName.equalsIgnoreCase("attrsTab")) {
			MbAttributeValues bean = (MbAttributeValues) ManagedBeanWrapper
					.getManagedBean("MbAttributeValues");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.toUpperCase().equals("NOTESTAB")) {
			MbNotesSearch bean = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("limitCountersTab")) {
			MbLimitCounters bean = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCounters");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("cycleCountersTab")) {
			MbCycleCounters bean = (MbCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbCycleCounters");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("SCHEMESTAB")) {
			MbAupSchemeObjects bean = (MbAupSchemeObjects) ManagedBeanWrapper
					.getManagedBean("MbAupSchemeObjects");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));

		}else if (tabName.equalsIgnoreCase("TERMINALSTAB")) {
            MbTerminalsBottom bean = (MbTerminalsBottom) ManagedBeanWrapper
                    .getManagedBean("MbTerminalsBottom");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }
	}

	private void loadTab(String tab) {
		if (tab == null || currentNode == null || currentNode.getId() == null) {
			return;
		}
		if (tab.equalsIgnoreCase("detailsTab")) {
			String reason = _eventsDao.getStatusReason(userSessionId, currentNode.getId(), EntityNames.MERCHANT);
			currentNode.setStatusReason(reason);
		} else if (tab.toUpperCase().equals("ACCOUNTSTAB")) {
			MbAccountsSearch accountsBean = ManagedBeanWrapper.getManagedBean(MbAccountsSearch.class);
			accountsBean.clearFilter();
			accountsBean.getFilter().setEntityType(EntityNames.MERCHANT);
			accountsBean.getFilter().setObjectId(currentNode.getId().longValue());
			accountsBean.getFilter().setInstId(currentNode.getInstId());
			accountsBean.setSearchByObject(true);
			accountsBean.setBackLink(thisBackLink);
			accountsBean.setParticipantType("ACQ");
			accountsBean.search();
		} else if (tab.toUpperCase().equals("NOTESTAB")) {
			MbNotesSearch notesSearch = ManagedBeanWrapper.getManagedBean(MbNotesSearch.class);
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.MERCHANT);
			filterNote.setObjectId(currentNode.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.toUpperCase().equals("CONTACTSTAB")) {
			MbContactSearch cont = ManagedBeanWrapper.getManagedBean(MbContactSearch.class);
			cont.setBackLink("acq_merchants");
			cont.setObjectId(currentNode.getId().longValue());
			cont.setEntityType(EntityNames.MERCHANT);
			cont.setActiveContact(null);
			cont.search();
		} else if (tab.toUpperCase().equals("ADDRESSESTAB")) {
			MbAddressesSearch addr = ManagedBeanWrapper.getManagedBean(MbAddressesSearch.class);
			addr.fullCleanBean();
            addr.getFilter().setEntityType(EntityNames.MERCHANT);
            addr.getFilter().setObjectId(currentNode.getId());
			addr.setCurLang(userLang);
            addr.search();
		} else if (tab.toUpperCase().equals("FLEXFIELDSTAB")) {
			MbFlexFieldsDataSearch flexible = ManagedBeanWrapper.getManagedBean(MbFlexFieldsDataSearch.class);
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(currentNode.getInstId());
			filterFlex.setEntityType(EntityNames.MERCHANT);
			filterFlex.setObjectId(currentNode.getId().longValue());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("attrsTab")) {
			MbObjectAttributes attrs = ManagedBeanWrapper.getManagedBean(MbObjectAttributes.class);
			attrs.fullCleanBean();
			attrs.setObjectId(currentNode.getId().longValue());
			attrs.setProductId(currentNode.getProductId());
			attrs.setEntityType(EntityNames.MERCHANT);
			attrs.setInstId(currentNode.getInstId());
			attrs.setProductType(currentNode.getProductType());
		} else if (tab.equalsIgnoreCase("limitCountersTab")) {
			MbLimitCounters limitCounters = ManagedBeanWrapper.getManagedBean(MbLimitCounters.class);
			limitCounters.setFilter(null);
			limitCounters.getFilter().setObjectId(currentNode.getId().longValue());
			limitCounters.getFilter().setInstId(currentNode.getInstId());
			limitCounters.getFilter().setEntityType(EntityNames.MERCHANT);
			limitCounters.search();
		} else if (tab.equalsIgnoreCase("cycleCountersTab")) {
			MbCycleCounters cycleCounters = ManagedBeanWrapper.getManagedBean(MbCycleCounters.class);
			cycleCounters.setFilter(null);
			cycleCounters.getFilter().setObjectId(currentNode.getId().longValue());
			cycleCounters.getFilter().setInstId(currentNode.getInstId());
			cycleCounters.getFilter().setEntityType(EntityNames.MERCHANT);
			cycleCounters.search();
		} else if (tab.equalsIgnoreCase("customerTab")) {
			MbCustomersDependent custBean = ManagedBeanWrapper.getManagedBean(MbCustomersDependent.class);
			custBean.getCustomer(currentNode.getCustomerId(), currentNode.getCustomerType());
		} else if (tab.equalsIgnoreCase("SCHEMESTAB")) {
			MbAupSchemeObjects schemeBean = ManagedBeanWrapper.getManagedBean(MbAupSchemeObjects.class);
			schemeBean.setObjectId(currentNode.getId().longValue());
			schemeBean.setInstId(currentNode.getInstId());
			schemeBean.setDefaultEntityType(EntityNames.MERCHANT);
			schemeBean.search();
		} else if (tab.equalsIgnoreCase("TERMINALSTAB")) {
			MbTerminalsBottom bean = ManagedBeanWrapper.getManagedBean(MbTerminalsBottom.class);
			bean.setFilterTerm(null);
			bean.setAccountId(null);
			bean.getFilterTerm().setMerchantId(currentNode.getId().intValue());
			bean.setSearchTabName("MERCHANT");
			bean.searchTerminal();
		} else if (tab.equalsIgnoreCase("reportTab")){
			MbReportsBottom reportsBean = ManagedBeanWrapper.getManagedBean(MbReportsBottom.class);
			reportsBean.setEntityType(EntityNames.TERMINAL);
			reportsBean.setObjectType(currentNode.getMerchantType());
			reportsBean.setObjectId(currentNode.getId());
			reportsBean.search();
		} else if (tab.equalsIgnoreCase("cardsTab")){
			MbMerchantCards bean = ManagedBeanWrapper.getManagedBean(MbMerchantCards.class);
			bean.getFilter().setMerchantId(currentNode.getId());
			bean.search();
		} else if (tab.equalsIgnoreCase("info")){
			MbEntityObjectInfoBottom infoBean = ManagedBeanWrapper.getManagedBean(MbEntityObjectInfoBottom.class);
			infoBean.setEntityType(EntityNames.TERMINAL);
			infoBean.setObjectType(currentNode.getMerchantType());
			infoBean.setObjectId(currentNode.getId());
			infoBean.search();
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

	public ArrayList<SelectItem> getMerchantStatuses() {
		if (merchantStatuses == null){
			merchantStatuses = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.MERCHANT_STATUSES);
		}
		if (merchantStatuses == null)
			merchantStatuses = new ArrayList<SelectItem>();
		return merchantStatuses;
	}

	public void restoreState() {
		searching = sessMerchant.isSearching();
		nodePath = sessMerchant.getNodePath();
		tabName = sessMerchant.getTabName();
		filter = sessMerchant.getFilter();

		if (nodePath != null) {
			currentNode = (Merchant) nodePath.getValue();
		}
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new Merchant();
				setFilterForm(filterRec);
				if (searchAutomatically)
					searchMerchants();
			}

			sectionFilterModeEdit = true;

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("status") != null) {
			filter.setStatus(filterRec.get("status"));
		}
		if (filterRec.get("merchantType") != null) {
			filter.setMerchantType(filterRec.get("merchantType"));
		}
		if (filterRec.get("merchantNumber") != null) {
			filter.setMerchantNumber(filterRec.get("merchantNumber"));
		}
		if (filterRec.get("customerNumber") != null) {
			filter.setCustomerNumber(filterRec.get("customerNumber"));
		}
		if (filterRec.get("custInfo") != null) {
			filter.setCustInfo(filterRec.get("custInfo"));
		}
		if (filterRec.get("companyName") != null) {
			filter.setCompanyName(filterRec.get("companyName"));
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			setFilterRec(filterRec);

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

	private void setFilterRec(Map<String, String> filterRec) {

		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getStatus() != null && filter.getStatus().trim().length() > 0) {
			filterRec.put("status", filter.getStatus());
		}
		if (filter.getMerchantType() != null && filter.getMerchantType().trim().length() > 0) {
			filterRec.put("merchantType", filter.getMerchantType());
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			filterRec.put("customerNumber", filter.getCustomerNumber());
		}
		if (filter.getCustInfo() != null && filter.getCustInfo().trim().length() > 0) {
			filterRec.put("custInfo", filter.getCustInfo());
		}
		if (filter.getMerchantNumber() != null && filter.getMerchantNumber().trim().length() > 0) {
			filterRec.put("merchantNumber", filter.getMerchantNumber());
		}
		if (filter.getCompanyName() != null && filter.getCompanyName().trim().length() > 0) {
			filterRec.put("companyName", filter.getCompanyName());
		}
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}

	public String getSectionId() {
		return SectionIdConstants.ACQUIRING_MERCHANT;
	}

	public void showCustomers() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		custBean.clearFilter();
		if ((getFilter().getInstId() != null)   && (!getFilter().getInstId().equals(DEFAULT_INST))) {
			custBean.setBlockInstId(true);
			custBean.setDefaultInstId(getFilter().getInstId());
		} else {
			custBean.setBlockInstId(false);
		}
	}

	public void selectCustomer() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		Customer selected = custBean.getActiveCustomer();
		if (selected != null) {
			getFilter().setCustomerNumber(selected.getCustomerNumber());
			getFilter().setCustomerId(selected.getId());
			getFilter().setCustInfo(selected.getName());
			getFilter().setInstId(custBean.getFilter().getInstId());
		}
	}

	/**
	 * Initializes bean's filter if bean has been accessed by context menu.
	 */
	private void initFilterFromContext() {
		filter = new Merchant();
		if (FacesUtils.getSessionMapValue("customerNumber") != null) {
			filter.setCustomerNumber((String) FacesUtils.getSessionMapValue("customerNumber"));
			filter.setCustInfo((String) FacesUtils.getSessionMapValue("customerNumber"));
			FacesUtils.setSessionMapValue("customerNumber", null);
		}
		if (FacesUtils.getSessionMapValue("instId") != null) {
			filter.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
			FacesUtils.setSessionMapValue("instId", null);
		}
		if (FacesUtils.getSessionMapValue("merchantNumber") != null) {
			filter.setMerchantNumber((String) FacesUtils.getSessionMapValue("merchantNumber"));
			FacesUtils.setSessionMapValue("merchantNumber", null);
		}
	}

	public String back() {
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public boolean isShowBackBtn() {
		return backLink == null ? false : (backLink.trim().length() > 0 ? true : false);
	}

	public void displayCustInfo() {

		if (getFilter().getCustInfo() == null || "".equals(getFilter().getCustInfo())) {
			getFilter().setCustomerNumber(null);
			getFilter().setCustomerId(null);
			return;
		}

		// process wildcard
		Pattern p = Pattern.compile("\\*|%|\\?");
		Matcher m = p.matcher(getFilter().getCustInfo());
		if (m.find() || getFilter().getInstId() == null) {
			getFilter().setCustomerNumber(getFilter().getCustInfo());
			return;
		}

		// search and redisplay
		Filter[] filters = new Filter[3];
		filters[0] = new Filter("LANG", curLang);
		filters[1] = new Filter("INST_ID", getFilter().getInstId());
		filters[2] = new Filter("CUSTOMER_NUMBER", getFilter().getCustInfo());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Customer[] cust = _productsDao.getCombinedCustomersProc(userSessionId, params,
					"CUSTOMER");
			if (cust != null && cust.length > 0) {
				getFilter().setCustInfo(cust[0].getName());
				getFilter().setCustomerNumber(cust[0].getCustomerNumber());
				getFilter().setCustomerId(cust[0].getId());
			} else {
				getFilter().setCustomerNumber(getFilter().getCustInfo());
				getFilter().setCustomerId(null);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void reload() {
		try {
			List<Terminal> terminals = getTerminals(getNode().getId().intValue());
			
			if (terminals.size() == 0) {
				return;
			}

			String feLocation = settingsDao.getParameterValueV(userSessionId,
					SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM, null);
			if (feLocation == null || feLocation.trim().length() == 0) {
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
						"sys_param_empty", SettingsConstants.FRONT_END_LOCATION);
				FacesUtils.addErrorExceptionMessage(msg);
				return;
			}
			Double wsPort = settingsDao.getParameterValueN(userSessionId,
					SettingsConstants.UPDATE_CACHE_WS_PORT, LevelNames.SYSTEM, null);
			if (wsPort == null) {
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
						"sys_param_empty", SettingsConstants.UPDATE_CACHE_WS_PORT);
				FacesUtils.addErrorExceptionMessage(msg);
			}
			feLocation = feLocation + ":" + wsPort.intValue();

			ObjectFactory of = new ObjectFactory();
			SyncronizeRqType syncronizeRqType = of.createSyncronizeRqType();
			List<EntityObjType> listEnityObjType = syncronizeRqType.getEntityObj();

			for (Terminal terminal : terminals) {
				EntityObjType entityObj = of.createEntityObjType();
				entityObj.setObjId(terminal.getId().toString());
				entityObj.setObjSeq(terminal.getSeqNum());
				listEnityObjType.add(entityObj);
			}
			syncronizeRqType.setEntityType(EntityNames.TERMINAL);

			DataManagement_Service service = new DataManagement_Service();
			DataManagement port = service.getDataManagementSOAP();
			BindingProvider bp = (BindingProvider) port;
			bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
			bp.getRequestContext().put("javax.xml.ws.client.connectionTimeout", SystemConstants.FE_TIMEOUT);
			bp.getRequestContext().put("javax.xml.ws.client.receiveTimeout", SystemConstants.FE_TIMEOUT);
			
			SyncronizeRsType rsType = null;
			try {
				rsType = port.syncronize(syncronizeRqType);
			} catch (Exception e) {
				String msg = null;
				if (e.getCause() instanceof UnknownHostException){
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "unknown_host", e.getCause().getMessage()) + ".";
				} else if (e.getCause() instanceof SocketTimeoutException){
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "web_service_timeout");
				} else {
					msg = e.getMessage();
				}
				msg += ". " + FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "check_front_end_settings");
				FacesUtils.addErrorExceptionMessage(msg);
				logger.error("", e);
				return;
			}
			List<EntityObjStatusType> objStatusTypes = rsType.getEntityObjStatus();

			for (int i = 0; i < terminals.size(); i++) {
				Terminal terminal = terminals.get(i);
				EntityObjStatusType objStatusType = objStatusTypes.get(i);
				terminal.setFerrNo(objStatusType.getFerrno());
			}

			setReloadResult(terminals);

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public List<Terminal> getReloadResult() {
		return reloadResult;
	}

	public void setReloadResult(List<Terminal> reloadResult) {
		this.reloadResult = reloadResult;
	}
	
	private List<Terminal> getTerminals(Integer merchantId) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", curLang);
		filters[1] = new Filter("merchantId", merchantId);
		
		SelectionParams params = new SelectionParams(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		try {
			Terminal[] terminals = _acquireDao.getTerminals(userSessionId, params);
			return Arrays.asList(terminals);
		} catch (Exception e) {
			logger.error("", e);
		}
		return new ArrayList<Terminal>(0);
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
		
		if (currentNode != null) {
			if (EntityNames.MERCHANT.equals(ctxItemEntityType)) {
				 map.put("id", currentNode.getId());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}

	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.MERCHANT);
	}

	public HashMap<String, Object> getParamMap() {
		if (paramMap == null){
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(HashMap<String, Object> paramMap) {
		this.paramMap = paramMap;
	}
}
