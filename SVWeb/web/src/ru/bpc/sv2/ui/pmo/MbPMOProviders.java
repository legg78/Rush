package ru.bpc.sv2.ui.pmo;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.pmo.PmoHost;
import ru.bpc.sv2.pmo.PmoProvider;
import ru.bpc.sv2.pmo.PmoPurpose;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.products.MbCustomersBottom;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

/**
 * Manage Bean for List PMO Providers page.
 */
@ViewScoped
@ManagedBean (name = "MbPMOProviders")
public class MbPMOProviders extends AbstractTreeBean<PmoProvider> {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private static String COMPONENT_ID = "2142:mainTable";

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private PmoProvider newProvider;
	private PmoProvider detailProvider;

	private PmoProvider providerFilter;
	private ArrayList<SelectItem> institutions;

	private boolean selectMode;
	private String tabName;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	List<String> rerenderList;
	private String needRerender;

	public MbPMOProviders() {
		
		pageLink = "pmo|providers";
		tabName = "detailsTab";
		
		if (nodePath != null) {
			currentNode = (PmoProvider) nodePath.getValue();

			ArrayList<TreePath> nodesToExpand = new ArrayList<TreePath>();
			nodesToExpand.add(nodePath);
			TreePath parent = nodePath.getParentPath();
			while (parent != null) {
				nodesToExpand.add(0, parent);
				parent = parent.getParentPath();
			}

			parent = null;
			for (TreePath path : nodesToExpand) {
				// actually curPath is useless, it's introduced only for
				// better readability :)
				TreePath curPath = new TreePath(((Institution) path.getValue()).getId(), parent);
//				expandLevel.setNodeExpanded(curPath, true);
				parent = curPath;
			}
			setInfo();
		}
	}
	
	@PostConstruct
	public void init() {
		setDefaultValues();
	}
	
	@Override
	protected void loadTree() {
		coreItems = new ArrayList<PmoProvider>();
		if (!isSearching()) {
			return;
		}

		try {
			setFilters();
			SelectionParams params = new SelectionParams(filters);
			List<PmoProvider> providerList = _paymentOrdersDao.getProviders(userSessionId, params);
			coreItems = new ArrayList<PmoProvider>();

			if (providerList != null && !providerList.isEmpty()) {
				PmoProvider[] providers = providerList.toArray(new PmoProvider[providerList.size()]);
				addNodes(0, coreItems, providers);
				if (nodePath == null) {
					if (currentNode == null) {
						currentNode = coreItems.get(0);
						detailProvider = (PmoProvider) currentNode.clone();
						setNodePath(new TreePath(currentNode, null));
					} else {
						if (currentNode.getParentId() != null) {
							setNodePath(formNodePath(providers));
						} else {
							setNodePath(new TreePath(currentNode, null));
						}
						setInfo();
					}
				}
			}
			if (currentNode != null && !coreItems.contains(currentNode)) {
				coreItems.add(currentNode);
			}
			treeLoaded = true;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public List<PmoProvider> getNodeChildren() {
		PmoProvider actionGroup = getAcmActionGroup();
		if (actionGroup == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return actionGroup.getChildren();
		}
	}

	private PmoProvider getAcmActionGroup() {
		return (PmoProvider) Faces.var("actionProvider");
	}

	public boolean getNodeHasChildren() {
		PmoProvider message = getAcmActionGroup();
		return (message != null) && message.isHasChildren();
	}

	@Override
	public TreePath getNodePath() {
		return nodePath;
	}

	@Override
	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public PmoProvider getNode() {
		if (currentNode == null) {
			currentNode = new PmoProvider();
		}
		return currentNode;
	}

	public void setNode(PmoProvider node) {
		try {
			curLang = userLang;
			if (node == null) {
				return;
			}
			boolean changeSelect = false;
			if (node !=null && !node.getId().equals(currentNode.getId())) {
				changeSelect = true;
			}
			this.currentNode = node;
			setInfo();
			if (changeSelect) {
				detailProvider = (PmoProvider) currentNode.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void setDefaultValues() {
		if (sectionFilterModeEdit) {
			return;
		}
		providerFilter = new PmoProvider();
	}

	public void search() {
		clearBean();
		clearBeansStates();
		curMode = VIEW_MODE;
		nodePath = null;
		currentNode = null;
		setSearching(true);
		loadTree();
		loadTab(getTabName());
	}

	public void clearBeansStates() {
		MbServicesForProvider purposeSearch = ManagedBeanWrapper.getManagedBean(MbServicesForProvider.class);
		purposeSearch.clearFilter();
		purposeSearch.search();

		MbPmoHostsSearch hostSearch = ManagedBeanWrapper.getManagedBean(MbPmoHostsSearch.class);
		hostSearch.clearFilter();
		hostSearch.search();

		MbCustomersBottom customerBottomBean = ManagedBeanWrapper.getManagedBean(MbCustomersBottom.class);
		customerBottomBean.clearFilter();
	}

	public void clearFilter() {
		providerFilter = null;
		clearBean();
		clearBeansStates();
	}

	public void clearBean() {
		detailProvider = null;
		loadedTabs.clear();
		coreItems = null;
		nodePath = null;
		currentNode = null;
		treeLoaded = false;
		clearBeansStates();
	}

	public void add() {
		newProvider = new PmoProvider();
		newProvider.setLang(userLang);
		newProvider.setInstId(SystemConstants.DEFAULT_INSTITUTION);
		curLang = newProvider.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newProvider = (PmoProvider) detailProvider.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newProvider = _paymentOrdersDao.editProvider(userSessionId, newProvider);
				detailProvider = (PmoProvider) newProvider.clone();
				if (!userLang.equals(newProvider.getLang())) {
					newProvider = getNodeByLang(currentNode.getId(), userLang);
				}
				replaceCurrentNode(newProvider);
			} else {
				newProvider = _paymentOrdersDao.addProvider(userSessionId, newProvider);
				detailProvider = (PmoProvider) newProvider.clone();
				addElementToTree(newProvider);
			}
			replaceCurrentNode(newProvider);
			setInfo();
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);

		}
	}

	public void delete() {
		try {
			_paymentOrdersDao.removeProvider(userSessionId, currentNode);
			FacesUtils.addMessageInfo("provider (id = " + currentNode.getId() + ") has been deleted.");

			deleteNodeFromTree(currentNode, coreItems);
			currentNode = null;
			detailProvider = null;
			clearBeansStates();
			if (coreItems.size() > 0) {
				currentNode = coreItems.get(0);
				setNodePath(new TreePath(currentNode, null));
				setInfo();
				detailProvider = (PmoProvider) currentNode.clone();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		filters.add(Filter.create("lang", userLang));

		if (getProviderFilter().getId() != null) {
			filters.add(Filter.create("id", getProviderFilter().getId()));
		}
		if (StringUtils.isNotBlank(getProviderFilter().getLabel())) {
			filters.add(Filter.create("label", Operator.like, Filter.mask(getProviderFilter().getLabel())));
		}
		if (StringUtils.isNotBlank(getProviderFilter().getRegionCode())) {
			filters.add(Filter.create("regionCode", getProviderFilter().getRegionCode()));
		}
		if (getProviderFilter().getInstId() != null) {
			filters.add(Filter.create("instId", getProviderFilter().getInstId()));
		}
	}

	public PmoProvider getProviderFilter() {
		if (providerFilter == null)
			providerFilter = new PmoProvider();
		return providerFilter;
	}

	public void setProviderFilter(PmoProvider providerFilter) {
		this.providerFilter = providerFilter;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public PmoProvider getNewProvider() {
		return newProvider;
	}

	public void setNewProvider(PmoProvider newProvider) {
		this.newProvider = newProvider;
	}

	public PmoProvider getNodeByLang(Long id, String lang) {
		try {
			List<Filter> localFilters = new ArrayList<Filter>(2);
			localFilters.add(Filter.create("id", id.toString()));
			localFilters.add(Filter.create("lang", lang));

			SelectionParams params = new SelectionParams(localFilters);
			List<PmoProvider> providers = _paymentOrdersDao.getProviders(userSessionId, params);
			if (providers != null && !providers.isEmpty()) {
				return providers.get(0);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailProvider = getNodeByLang(detailProvider.getId(), curLang);
	}

	public void confirmEditLanguage() {
		curLang = newProvider.getLang();
		PmoProvider tmp = getNodeByLang(newProvider.getId(), newProvider.getLang());
		if (tmp != null) {
			newProvider.setLabel(tmp.getLabel());
			newProvider.setDescription(tmp.getDescription());
		}
	}

	public void setInfo() {
		loadedTabs.clear();
		loadTab(getTabName());
	}

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
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

		if (tabName.equalsIgnoreCase("hostsTab")) {
			MbPmoHostsSearch bean = ManagedBeanWrapper.getManagedBean(MbPmoHostsSearch.class);
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("servicesTab")) {
			MbServicesForProvider bean = ManagedBeanWrapper.getManagedBean(MbServicesForProvider.class);
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));

			MbPMOParameters bean1 = ManagedBeanWrapper.getManagedBean(MbPMOParameters.class);
			bean1.setTabName(tabName);
			bean1.setParentSectionId(getSectionId());
			bean1.setTableState(getSateFromDB(bean1.getComponentId()));
		} else if (tabName.equalsIgnoreCase("associationTab")) {
			MbCustomersBottom bean = ManagedBeanWrapper.getManagedBean(MbCustomersBottom.class);
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public String getSectionId() {
		return SectionIdConstants.PAYMENT_ORDER_PROVIDER;
	}
	
	private void loadTab(String tab) {
		if (tab == null || currentNode == null || currentNode.getId() == null) {
			return;
		}

		if (tab.equalsIgnoreCase("hostsTab")) {
			MbPmoHostsSearch hostSearch = ManagedBeanWrapper.getManagedBean(MbPmoHostsSearch.class);
			PmoHost hostFilter = new PmoHost();
			hostFilter.setProviderId(Integer.valueOf(currentNode.getId().intValue()));
			hostFilter.setProviderName(currentNode.getLabel());
			hostSearch.setHostFilter(hostFilter);
			hostSearch.search();
		} else if (tab.equalsIgnoreCase("servicesTab")) {
			MbServicesForProvider serviceSearch = ManagedBeanWrapper.getManagedBean(MbServicesForProvider.class);
			PmoPurpose serviceFilter = new PmoPurpose();
			serviceFilter.setProviderId(currentNode.getId().intValue());
			serviceFilter.setInstId(currentNode.getInstId());
			serviceSearch.setPurposeFilter(serviceFilter);
			serviceSearch.search();
		} else if (tab.equalsIgnoreCase("associationTab")){
			MbCustomersBottom customersBottomBean = ManagedBeanWrapper.getManagedBean(MbCustomersBottom.class);
			Customer filter = customersBottomBean.getFilter();
			filter.setInstId(currentNode.getInstId());
			filter.setExtEntityType(EntityNames.PAYMENT_PROVIDER);
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
		rerenderList.add(tabName);
		return rerenderList;
	}

    public Comparator<Object> getNameComparator() {
        return new Comparator<Object>() {
            @Override
            public int compare(Object o10, Object o20) {
                if (o10 instanceof String && o20 instanceof String){
                    String o1=(String)o10;
                    String o2=(String)o20;
                    if (o1 == null || o1.equals(""))
                        return -1;
                    if (o2 == null || o2.equals(""))
                        return 1;
                    return o1.toUpperCase().compareTo(o2.toUpperCase());
                }
                return 0;
            }
        };
    }

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public PmoProvider getDetailProvider() {
		return detailProvider;
	}

	public void setDetailProvider(PmoProvider detailProvider) {
		this.detailProvider = detailProvider;
	}
	
	public List<SelectItem> getGroups() {
			return getDictUtils().getLov(LovConstants.GROUP_PROVIDERS);
	}
	
	public List<SelectItem> getSrcProviders() {
		return getDictUtils().getLov(LovConstants.PAYMENT_ORDER_PROVIDERS);
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
			if (institutions == null) {
				institutions = new ArrayList<SelectItem>();
			}
		}
		return institutions;
	}
}
