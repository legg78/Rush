package ru.bpc.sv2.ui.products;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.acquiring.MbMerchantsBottom;
import ru.bpc.sv2.ui.acquiring.MbTerminal;
import ru.bpc.sv2.ui.acquiring.MbTerminalsBottom;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.crp.MbCrpDepartment;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.issuing.MbCardsBottomSearch;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ViewScoped
@ManagedBean (name = "MbContracts")
public class MbContracts extends AbstractBean {

	private static final long serialVersionUID = 4613276665743299212L;
	
	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private static String COMPONENT_ID = "contractsTable";

	private ProductsDao _productsDao = new ProductsDao();

	private Contract filter;
	private Contract newContract;
	
	private boolean searchByCustomer = false;

	private final DaoDataModel<Contract> _contractsSource;
	private final TableRowSelection<Contract> _itemSelection;
	private Contract _activeContract;

	protected String tabName;
	private ArrayList<SelectItem> institutions;
	private String backLink;

	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	protected String needRerender;
	private List<String> rerenderList;

    private Map<String, Object> paramMaps;

	private String custInfo;
	private MbContractsSess sessBean;
	
	private String ctxItemEntityType;
	private ContextType ctxType;

	private String parentSectionId;
	protected String pageLink = "products|contracts";

	public MbContracts() {
		pageLink = "products|contracts";
		tabName = "detailsTab";
//		thisBackLink = "products|contracts";
		sessBean = (MbContractsSess) ManagedBeanWrapper.getManagedBean("MbContractsSess");

		_contractsSource = new DaoDataModel<Contract>(true) {
			private static final long serialVersionUID = 7527494953916362383L;

			@Override
			protected Contract[] loadDaoData(SelectionParams params) {
				if (!searching || (searchByCustomer && getFilter().getCustomerId() == null)) {
					return new Contract[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
                    getParamMaps().put("param_tab", filters.toArray(new Filter[filters.size()]));
                    getParamMaps().put("tab_name", "CONTRACT");

					return _productsDao.getContractsCur(userSessionId, params, getParamMaps());
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new Contract[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || (searchByCustomer && getFilter().getCustomerId() == null)) {
					return 0;
				}
				int count = 0;
				int threshold = 300;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setThreshold(threshold);
                    getParamMaps().put("param_tab", filters.toArray(new Filter[filters.size()]));
                    getParamMaps().put("tab_name", "CONTRACT");
					count = _productsDao.getContractsCurCount(userSessionId, params, getParamMaps());
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
				if (count >= threshold) {
					FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "many_records"));
				}
				return count;
			}
		};

		_itemSelection = new TableRowSelection<Contract>(null, _contractsSource);

		restoreBean = (Boolean) FacesUtils.getSessionMapValue(pageLink);
		if (restoreBean != null && restoreBean) {
			restoreBean();
		}

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
	}

	public DaoDataModel<Contract> getContracts() {
		return _contractsSource;
	}

	public Contract getActiveContract() {
		return _activeContract;
	}

	public void setActiveContract(Contract activeContract) {
		_activeContract = activeContract;
	}

	public SimpleSelection getItemSelection() {
		if (_activeContract == null && _contractsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeContract != null && _contractsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeContract.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeContract = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeContract = _itemSelection.getSingleSelection();

		if (_activeContract != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_contractsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeContract = (Contract) _contractsSource.getRowData();
		selection.addKey(_activeContract.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		loadedTabs.clear();
		loadTab(getTabName());

		sessBean.setActiveContract(_activeContract);
		sessBean.setItemSelection(_itemSelection.getWrappedSelection());
		sessBean.setFilter(filter);
		sessBean.setPageNumber(pageNumber);
		sessBean.setRowsNum(rowsNum);
		sessBean.setTabName(tabName);
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_ID");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getCustomerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_ID");
			paramFilter.setValue(filter.getCustomerId());
			filters.add(paramFilter);
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_NUMBER");
			paramFilter.setValue(filter.getContractNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_NUMBER");
			paramFilter.setValue(filter.getCustomerNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			if (((String)paramFilter.getValue()).indexOf("%") != -1 || filter.getCustomerNumber().indexOf("?") != -1) {
				paramFilter.setCondition("like");
			}
			filters.add(paramFilter);
		}
		if (filter.getStartDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("START_DATE_FROM");
			paramFilter.setValue(filter.getStartDate());
			filters.add(paramFilter);
		}
		if (filter.getEndDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("START_DATE_TO");
			paramFilter.setValue(filter.getEndDate());
			filters.add(paramFilter);
		}
		if (filter.getProductId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("PRODUCT_ID");
			paramFilter.setValue(filter.getProductId());
			filters.add(paramFilter);
		}
		if (filter.getContractType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_TYPE");
			paramFilter.setValue(filter.getContractType());
			filters.add(paramFilter);
		}
	}

	public Contract getFilter() {
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			initFilterFromContext();
			search();
			FacesUtils.setSessionMapValue("initFromContext", null);
		}
		if (filter == null) {
			filter = new Contract();
			if (userInstId.intValue() != ApplicationConstants.DEFAULT_INSTITUTION) {
				filter.setInstId(userInstId);
			}
		}
		return filter;
	}

	public void setFilter(Contract filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		clearBean();
		clearSectionFilter();
		searching = false;
		searchByCustomer = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Contract getNewContract() {
		if (newContract == null) {
			newContract = new Contract();
		}
		return newContract;
	}

	public void setNewContract(Contract newContract) {
		this.newContract = newContract;
	}

	public void clearBean() {
		curLang = userLang;
		_contractsSource.flushCache();
		_itemSelection.clearSelection();
		_activeContract = null;
		clearBeans();
	}

	private void clearBeans() {
		MbCustomersDependent customer = (MbCustomersDependent) ManagedBeanWrapper
				.getManagedBean("MbCustomersDependent");
		customer.clearFilter();
		MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
				.getManagedBean("MbFlexFieldsDataSearch");
		flexible.setSearching(false);
		flexible.setFilter(null);
		MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
				.getManagedBean("MbCardsBottomSearch");
		cardsSearch.clearFilter();
		MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
				.getManagedBean("MbAccountsSearch");
		accsSearch.clearFilter();
		MbTerminal terminalsBean = (MbTerminal) ManagedBeanWrapper.getManagedBean("MbTerminal");
		terminalsBean.clearFilter(false);
		MbMerchantsBottom merchantsBean = (MbMerchantsBottom) ManagedBeanWrapper
				.getManagedBean("MbMerchantsBottom");
		merchantsBean.clearFilter();
		MbServiceObjects servicesBean = (MbServiceObjects) ManagedBeanWrapper
				.getManagedBean("MbServiceObjects");
		servicesBean.clearFilter();
		MbCrpDepartment mbCrpDepartment = (MbCrpDepartment) ManagedBeanWrapper
				.getManagedBean("MbCrpDepartment");
		mbCrpDepartment.setContractId(null);
		MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean("MbObjectAttributes");
		attrs.fullCleanBean();
		MbLimitCounters limitCountersBean = (MbLimitCounters) ManagedBeanWrapper
				.getManagedBean("MbLimitCounters");
		limitCountersBean.clearFilter();
		MbCycleCounters cycleCountersBean = (MbCycleCounters) ManagedBeanWrapper
				.getManagedBean("MbCycleCounters");
		cycleCountersBean.clearFilter();
	}

	public String getTabName() {
		return tabName;
	}

	public void keepTabName(String tabName) {
		this.tabName = tabName;
	}
	
	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		sessBean.setTabName(tabName);

//		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);
//
//		if (isLoadedCurrentTab == null) {
//			isLoadedCurrentTab = Boolean.FALSE;
//		}
//
//		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
//			return;
//		}
//
//		loadTab(tabName);
		if (tabName.equalsIgnoreCase("cardsTab")) {
			MbCardsBottomSearch bean = (MbCardsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbCardsBottomSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("additionalTab")) {
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			flexible.setTabName(tabName);
			flexible.setParentSectionId(getSectionId());
			flexible.setTableState(getSateFromDB(flexible.getComponentId()));
		} else if (tabName.equalsIgnoreCase("accountsTab")) {
			MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbAccountsSearch");
			accsSearch.setTabName(tabName);
			accsSearch.setParentSectionId(getSectionId());
			accsSearch.setTableState(getSateFromDB(accsSearch.getComponentId()));
		} else if (tabName.equalsIgnoreCase("terminalsTab")) {
			MbTerminalsBottom terminalsBean = (MbTerminalsBottom) ManagedBeanWrapper.getManagedBean("MbTerminalsBottom");
			terminalsBean.setTabName(tabName);
			terminalsBean.setParentSectionId(getSectionId());
			terminalsBean.setTableState(getSateFromDB(terminalsBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("merchantsTab")) {
			MbMerchantsBottom merchantsBean = (MbMerchantsBottom) ManagedBeanWrapper
					.getManagedBean("MbMerchantsBottom");
			merchantsBean.setTabName(tabName);
			merchantsBean.setParentSectionId(getSectionId());
			merchantsBean.setTableState(getSateFromDB(merchantsBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("servicesTab")) {
			MbServiceObjects servicesBean = (MbServiceObjects) ManagedBeanWrapper
					.getManagedBean("MbServiceObjects");
			servicesBean.setTabName(tabName);
			servicesBean.setParentSectionId(getSectionId());
			servicesBean.setTableState(getSateFromDB(servicesBean.getComponentId()));
		}  else if (tabName.equalsIgnoreCase("attributesTab")) {
			MbAttributeValues attrValueBean = (MbAttributeValues) ManagedBeanWrapper
					.getManagedBean("MbAttributeValues");
			attrValueBean.setTabName(tabName);
			attrValueBean.setParentSectionId(getSectionId());
			attrValueBean.setTableState(getSateFromDB(attrValueBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("limitCountersTab")) {
			MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCounters");
			limitCounters.setTabName(tabName);
			limitCounters.setParentSectionId(getSectionId());
			limitCounters.setTableState(getSateFromDB(limitCounters.getComponentId()));
		} else if (tabName.equalsIgnoreCase("cycleCountersTab")) {
			MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbCycleCounters");
			cycleCounters.setTabName(tabName);
			cycleCounters.setParentSectionId(getSectionId());
			cycleCounters.setTableState(getSateFromDB(cycleCounters.getComponentId()));
		} else if (tabName.equalsIgnoreCase("notesTab")) {
            MbNotesSearch bean = ManagedBeanWrapper
                    .getManagedBean("MbNotesSearch");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeContract == null || _activeContract.getId() == null)
			return;

		if (tab.equalsIgnoreCase("customerTab")) {
			MbCustomersDependent customer = (MbCustomersDependent) ManagedBeanWrapper
					.getManagedBean("MbCustomersDependent");
			customer
					.getCustomer(_activeContract.getCustomerId(), _activeContract.getCustomerType());
		} else if (tab.equalsIgnoreCase("additionalTab")) {
			// get flexible data for this institution
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(_activeContract.getInstId());
			filterFlex.setEntityType(EntityNames.CONTRACT);
			filterFlex.setObjectId(_activeContract.getId());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("cardsTab")) {
			MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbCardsBottomSearch");
			cardsSearch.clearFilter();
			cardsSearch.getFilter().setContractId(_activeContract.getId());
			cardsSearch.setSearchTabName("CONTRACT");
			cardsSearch.search();
		} else if (tab.equalsIgnoreCase("accountsTab")) {
			MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbAccountsSearch");
			accsSearch.clearFilter();
			accsSearch.getFilter().setCustomerId(_activeContract.getCustomerId());
			accsSearch.getFilter().setContractId(_activeContract.getId());
			accsSearch.setBackLink(pageLink);
			accsSearch.setTabsName("CONTRACT");
			accsSearch.setSearchByObject(false);
			accsSearch.search();
		} else if (tab.equalsIgnoreCase("terminalsTab")) {
			MbTerminalsBottom terminalsBean = (MbTerminalsBottom) ManagedBeanWrapper.getManagedBean("MbTerminalsBottom");
			terminalsBean.clearFilter();
			terminalsBean.getFilterTerm().setContractId(_activeContract.getId());
			terminalsBean.setSearchTabName("CONTRACT");
			terminalsBean.searchTerminal();
		} else if (tab.equalsIgnoreCase("merchantsTab")) {
			MbMerchantsBottom merchantsBean = (MbMerchantsBottom) ManagedBeanWrapper
					.getManagedBean("MbMerchantsBottom");
			merchantsBean.clearFilter();
			merchantsBean.getFilter().setContractId(_activeContract.getId());
			merchantsBean.setSearchTabName("CONTRACT");
			merchantsBean.search();
		} else if (tab.equalsIgnoreCase("servicesTab")) {
			MbServiceObjects servicesBean = (MbServiceObjects) ManagedBeanWrapper
					.getManagedBean("MbServiceObjects");
			servicesBean.clearFilter();
			servicesBean.getFilter().setContractId(_activeContract.getId());
			servicesBean.search();
		} else if (tab.equalsIgnoreCase("attributesTab")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			attrs.setObjectId(_activeContract.getId());
			attrs.setProductId(_activeContract.getProductId());
			attrs.setEntityType(EntityNames.CONTRACT);
			attrs.setInstId(_activeContract.getInstId());
			attrs.setProductType(_activeContract.getProductType());
		} else if (tab.equalsIgnoreCase("limitCountersTab")) {
			MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCounters");
			limitCounters.setFilter(null);
			limitCounters.getFilter().setObjectId(_activeContract.getId());
			limitCounters.getFilter().setInstId(_activeContract.getInstId());
			limitCounters.getFilter().setEntityType(EntityNames.CONTRACT);
			limitCounters.search();
		} else if (tab.equalsIgnoreCase("cycleCountersTab")) {
			MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbCycleCounters");
			cycleCounters.setFilter(null);
			cycleCounters.getFilter().setObjectId(_activeContract.getId());
			cycleCounters.getFilter().setInstId(_activeContract.getInstId());
			cycleCounters.getFilter().setEntityType(EntityNames.CONTRACT);
			cycleCounters.search();
		} else if(tabName.equals("notesTab")){
            MbNotesSearch notesSearch = ManagedBeanWrapper
                    .getManagedBean("MbNotesSearch");
            ObjectNoteFilter filterNote = new ObjectNoteFilter();
            filterNote.setEntityType(EntityNames.CONTRACT);
            filterNote.setObjectId(_activeContract.getId());
            notesSearch.setFilter(filterNote);
            notesSearch.search();
        }
		if (tab.equalsIgnoreCase("contractsTab")) {
			// MbObjectAttributes attrs = (MbObjectAttributes)
			// ManagedBeanWrapper.getManagedBean("MbObjectAttributes");
			// attrs.fullCleanBean();
			// attrs.setContractId(_activeContract.getId());
			// attrs.setEntityType(EntityNames.SERVICE);
			// attrs.setInstId(_activeContract.getInstId());
		}
		if (tab.equalsIgnoreCase("objectsTabs")) {
			// MbProductContracts pContracts =
			// (MbProductContracts) ManagedBeanWrapper.getManagedBean("MbProductContracts");
			// pContracts.clearFilter();
			// pContracts.getFilter().setContractId(_activeContract.getId());
			// pContracts.getFilter().setContractName(_activeContract.getLabel());
			// pContracts.search();
		}
		if (tab.equalsIgnoreCase("corporationsTab")) {
			MbCrpDepartment mbCrpDepartment = (MbCrpDepartment) ManagedBeanWrapper
					.getManagedBean("MbCrpDepartment");
			mbCrpDepartment.setContractId(_activeContract.getId());
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

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("CONTRACT_ID");
		filters[0].setValue(_activeContract.getId().toString());
		filters[1] = new Filter();
		filters[1].setElement("LANG");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
        getParamMaps().put("param_tab", filters);
        getParamMaps().put("tab_name", "CONTRACT");
		try {
			Contract[] types = _productsDao.getContractsCur(userSessionId, params, getParamMaps());
			if (types != null && types.length > 0) {
				_activeContract = types[0];
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

	public boolean isSearchByCustomer() {
		return searchByCustomer;
	}

	public void setSearchByCustomer(boolean searchByCustomer) {
		this.searchByCustomer = searchByCustomer;
	}

	public ArrayList<SelectItem> getProducts() {
		ArrayList<Filter> filters = new ArrayList<Filter>();
		Filter filter = new Filter();
		filter.setElement("lang");
		filter.setValue(curLang);
		filters.add(filter);

		if (getFilter().getInstId() != null) {
			filter = new Filter();
			filter.setElement("instId");
			filter.setValue(getFilter().getInstId());
			filters.add(filter);
		}
		if (getFilter().getContractType() != null) {
			filter = new Filter();
			filter.setElement("contractType");
			filter.setValue(getFilter().getContractType());
			filters.add(filter);
		}

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		try {
			Product[] products = _productsDao.getProducts(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(products.length);
			for (Product product : products) {
				String name = product.getName();
				for (int i = 1; i < product.getLevel(); i++) {
					name = " -- " + name;
				}
				items.add(new SelectItem(product.getId(), product.getId() + " - " + name));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		return new ArrayList<SelectItem>(0);
	}

	public List<SelectItem> getContractTypes() {
		return getDictUtils().getLov(LovConstants.LIST_CONTRACT_TYPES);
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new Contract();
				setFilterForm(filterRec);
				if (searchAutomatically)
					search();
			}

			sectionFilterModeEdit = true;

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("id") != null) {
			filter.setId(Long.valueOf(filterRec.get("id")));
		}
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("customerId") != null) {
			filter.setCustomerId(Long.valueOf(filterRec.get("customerNumber")));
		}
		if (filterRec.get("contractNumber") != null) {
			filter.setContractNumber(filterRec.get("contractNumber"));
		}
		if (filterRec.get("customerNumber") != null) {
			filter.setCustomerNumber(filterRec.get("customerNumber"));
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterRec.get("startDateFrom") != null) {
			filter.setStartDate(df.parse(filterRec.get("startDateFrom")));
		}
		if (filterRec.get("endDateTo") != null) {
			filter.setEndDate(df.parse(filterRec.get("endDateTo")));
		}
		if (filterRec.get("productId") != null) {
			filter.setProductId(Integer.valueOf(filterRec.get("productId")));
		}
		if (filterRec.get("contractType") != null) {
			filter.setContractType(filterRec.get("contractType"));
		}
		if (filterRec.get("custInfo") != null) {
			filter.setCustInfo(filterRec.get("custInfo"));
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

		if (filter.getId() != null) {
			filterRec.put("id", filter.getId().toString());
		}
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getCustomerId() != null) {
			filterRec.put("customerId", filter.getCustomerId().toString());
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			filterRec.put("contractNumber", filter.getContractNumber());
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			filterRec.put("customerNumber", filter.getCustomerNumber());
		}

		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filter.getStartDate() != null) {
			filterRec.put("startDateFrom", df.format(filter.getStartDate()));
		}

		if (filter.getEndDate() != null) {
			filterRec.put("endDateTo", df.format(filter.getEndDate()));
		}

		if (filter.getProductId() != null) {
			filterRec.put("productId", filter.getProductId().toString());
		}

		if (filter.getContractType() != null && filter.getContractType().trim().length() > 0) {
			filterRec.put("contractType", filter.getContractType());
		}

		if (filter.getCustInfo() != null && filter.getCustInfo().trim().length() > 0) {
			filterRec.put("custInfo", filter.getCustInfo());
		}
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}

	public String getSectionId() {
		return SectionIdConstants.CUSTOMER_CONTRACT;
	}

	public String getComponentId() {
		if (parentSectionId != null && tabName != null) {
			return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
		} else {
			return getSectionId() + ":" + COMPONENT_ID;
		}
	}

	public Logger getLogger() {
		return logger;
	}

	public void showCustomers() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		custBean.clearFilter();
		if (getFilter().getInstId() != null) {
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
		filter = new Contract();
		searchByCustomer=false;
		if (FacesUtils.getSessionMapValue("customerNumber") != null) {
			filter.setCustomerNumber((String) FacesUtils.getSessionMapValue("customerNumber"));
			filter.setCustInfo((String) FacesUtils.getSessionMapValue("customerNumber"));
			FacesUtils.setSessionMapValue("customerNumber", null);
		}
		if (FacesUtils.getSessionMapValue("instId") != null) {
			filter.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
			FacesUtils.setSessionMapValue("instId", null);
		}
		if (FacesUtils.getSessionMapValue("contractNumber") != null) {
			filter.setContractNumber((String) FacesUtils.getSessionMapValue("contractNumber"));
			FacesUtils.setSessionMapValue("contractNumber", null);
		}
	}

	public String back() {
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public boolean isShowBackBtn() {
		return backLink == null ? false : (backLink.trim().length() > 0 ? true : false);
	}

	public String getCustInfo() {
		return custInfo;
	}

	public void setCustInfo(String custInfo) {
		this.custInfo = custInfo;
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

	private void restoreBean() {
		tabName = sessBean.getTabName();
		_activeContract = sessBean.getActiveContract();
		rowsNum = sessBean.getRowsNum();
		pageNumber = sessBean.getPageNumber();
		filter = sessBean.getFilter();
		searching = true;

		loadTab(tabName);
		FacesUtils.setSessionMapValue(pageLink, Boolean.FALSE);
	}
	
	public String gotoContracts() {
		searchByCustomer = false;
		return "products|contracts";
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
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
		map.put("selfUrl", "products|contracts");
		if (_activeContract != null){
			if (EntityNames.CONTRACT.equals(ctxItemEntityType)) {
				map.put("instId", _activeContract.getInstId());
				map.put("customerNumber", _activeContract.getCustomerNumber());
				map.put("customerId", _activeContract.getCustomerId());
				map.put("contractNumber", _activeContract.getContractNumber());
				map.put("id", _activeContract.getId());
			}
			if (EntityNames.PRODUCT.equals(ctxItemEntityType)) {
				map.put("id", _activeContract.getProductId());
				map.put("instId", _activeContract.getInstId());
				map.put("objectType", _activeContract.getProductType());
				map.put("productType", _activeContract.getProductType());
				map.put("productName", _activeContract.getProductName());
				map.put("productNumber", _activeContract.getProductNumber());
			}
			if (EntityNames.CUSTOMER.equals(ctxItemEntityType)) {
				map.put("id", _activeContract.getCustomerId());
				map.put("instId", _activeContract.getInstId());
				map.put("customerNumber", _activeContract.getCustomerNumber());
				map.put("agentId", _activeContract.getAgentId());
				map.put("contractNumber", _activeContract.getContractNumber());
				
				ctxType.setParams(map);
			}
			if (EntityNames.INSTITUTION.equals(ctxItemEntityType)) {
				 map.put("id", _activeContract.getInstId());
				 map.put("instId", _activeContract.getInstId());
				ctxType.setParams(map);
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.CONTRACT);
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

    public void onSortablePreRenderTable() {
        onSortablePreRenderTable(_contractsSource);
    }

    public Map<String, Object> getParamMaps() {
        if (paramMaps == null) {
            paramMaps = new HashMap<String, Object>();
        }
        return paramMaps;
    }

    public void setParamMaps(Map<String, Object> paramMaps) {
        this.paramMaps = paramMaps;
    }
}
