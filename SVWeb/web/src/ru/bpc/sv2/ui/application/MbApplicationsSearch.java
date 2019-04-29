package ru.bpc.sv2.ui.application;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.application.*;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.ArrayConstants;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.process.ProcessTrace;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.application.wizard.MbAppWizAcmFlow;
import ru.bpc.sv2.ui.audit.MbUserSearchModal;
import ru.bpc.sv2.ui.campaigns.MbAppCampaignWizard;
import ru.bpc.sv2.ui.common.application.MbAppWizardFirstPage;
import ru.bpc.sv2.ui.common.application.MbWizard;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.orgstruct.InstitutionConstants;
import ru.bpc.sv2.ui.process.monitoring.MbProcessTrace;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;

@SuppressWarnings("unused")
@ViewScoped
@ManagedBean (name = "MbApplicationsSearch")
public class MbApplicationsSearch extends AbstractBean {
	private static final long serialVersionUID = -8302787353433607520L;

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String COMPONENT_ID = "mainTable";

	private ApplicationDao applicationDao = new ApplicationDao();

	private ProductsDao productsDao = new ProductsDao();

	public static final String ACQUIRING = "acquiring";
	public static final String ISSUING = "issuing";
	public static final String INSTITUTION = "institution";
	public static final String PAYMENT_ORDERS = "pmo";
	public static final String USER_MNG = "acm";
	public static final String ISS_PRODUCT = "iss_product";
	public static final String ACQ_PRODUCT = "acq_product";
	public static final String QUESTIONARY = "questionary";
	public static final String CAMPAIGN = "campaign";


	public static final String BUTTON_VIEW = "btn_view";
	public static final String BUTTON_ADD = "btn_add";
	public static final String BUTTON_MODIFY = "btn_edit";
	public static final String BUTTON_REMOVE = "btn_delete";
	public static final String BUTTON_PROCESS = "btn_process";
	public static final String BUTTON_WIZARD = "btn_wizard";
	public static final String BUTTON_APPROVE = "btn_approve";

	private String appType;
	private String module;
	private String pageName;

	private String selectedAppType;
	private Application activeApp;
	
	private Application filter;
	private Application newApplication;
	private List<Filter> filtersContract;
	private List<Filter> filtersCustomer;

	private MbApplication appBean;
	private MbWizard appWiz;
	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<Application> appSource;

	private final TableRowSelection<Application> itemSelection;

	private final DaoDataModel<Contract> contractsSource;
	private final TableRowSelection<Contract> contractsSelection;
	private boolean searchingContract;
	private Contract activeContract;
	private Contract filterContract;

	private final DaoDataModel<Customer> customersSource;
	private final TableRowSelection<Customer> customersSelection;
	private boolean searchingCustomer;
	private Customer activeCustomer;
	private Customer filterCustomer;

	private String timeZone;

	protected String tabName;
	private String needRerender;

	private String backLink;
	private boolean addNew = false;

	private final Map<String, String> appTypesMap;
	
	private List<SelectItem> allAppFlows;
	private List<String> warnAppStatuses = null;
	private Boolean showWarning = false;

	private String ctxItemEntityType;
	private ContextType ctxType;
	
	private boolean disabledCardNumber = false;
	private boolean disabledAccountNumber = false;
	private boolean disabledMerchantNumber = false;
	private boolean disabledTerminalNumber = false;

	private Integer userId;
	private String userName;

	private Integer roleId;
	private String roleName;

	private boolean showWizard = false;

	private Map<Long, Boolean> checkMap;
	private List<Application> selectedApps;

	private Map<String, Object> contractParamMaps;

	public MbApplicationsSearch() {
		checkMap = new HashMap<>();
		selectedApps = new ArrayList<>();
		tabName = "detailsTab";
		clearDisabledFields();
		appBean = ManagedBeanWrapper.getManagedBean("MbApplication");
		appWiz = ManagedBeanWrapper.getManagedBean("MbWizard");
		excludedIds = new HashSet<>();
		excludedIds.add("col_id");
		HashMap<String, String> map = new HashMap<String, String>();
		map.put(ApplicationConstants.TYPE_ACQUIRING, ACQUIRING);
		map.put(ApplicationConstants.TYPE_ACQ_PRODUCT, ACQ_PRODUCT);
		map.put(ApplicationConstants.TYPE_ISSUING, ISSUING);
		map.put(ApplicationConstants.TYPE_ISS_PRODUCT, ISS_PRODUCT);
		map.put(ApplicationConstants.TYPE_INSTITUTION, INSTITUTION);
		map.put(ApplicationConstants.TYPE_PAYMENT_ORDERS, PAYMENT_ORDERS);
		map.put(ApplicationConstants.TYPE_USER_MNG, USER_MNG);
		map.put(ApplicationConstants.TYPE_QUESTIONARY, QUESTIONARY);
		map.put(ApplicationConstants.TYPE_CAMPAIGNS, CAMPAIGN);
		appTypesMap = Collections.unmodifiableMap(map);

		DateFormat df = DateFormat.getInstance();
		df.setCalendar(Calendar.getInstance());
		timeZone = df.getTimeZone().getID();
		appType = getAppTypeFromRequest();

		appSource = new DaoDataListModel<Application>(logger, isIssuingType() || isAcquiringType()) {
			private static final long serialVersionUID = -5069770832576588790L;

			@Override
			protected List<Application> loadDaoListData(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setFilters(filters);
					this.setExcludeSortElements(isExcludedColumns());
					List<Application> apps = new ArrayList<Application>();
					if (isIssuingType()) {
						apps = applicationDao.getIssuingApplications(userSessionId, params);
					} else if (isIssProductType()) {
						apps = applicationDao.getIssProductApplications(userSessionId, params);
					} else if (isAcquiringType()) {
						apps = applicationDao.getAcquiringApplications(userSessionId, params);
					} else if (isAcqProductType()) {
						apps = applicationDao.getAcqProductApplications(userSessionId, params);
					} else if (isPMOType()) {
						apps = applicationDao.getPMOApplications(userSessionId, params);
					} else if (isACMType()) {
						apps = applicationDao.getACMApplications(userSessionId, params);
					} else if (isInstitutionType()) {
						apps = applicationDao.getInstitutionApplications(userSessionId, params);
					} else if (isQuestionaryType()) {
						apps = applicationDao.getQuestionaryApplications(userSessionId, params);
					} else if (isCampaignType()) {
						apps = applicationDao.getCampaignApplications(userSessionId, params);
					} else {
						apps = applicationDao.getApplications(userSessionId, params);
					}

					if (addNew) {
						activeApp = getApplicationById(activeApp.getId());
						if (activeApp != null) {
							boolean found = false;
							for (Application app : apps) {
								if (app.getId().equals(activeApp.getId())) {
									found = true;
									break;
								}
							}
							if (!found) {
								List<Application> appsNew = new ArrayList<Application>(apps.size() + 1);
								appsNew.add(activeApp);
								appsNew.addAll(apps);
								setDataSize(getDataSize() + 1);
								return appsNew;
							}
						}
						addNew = false;
						return apps;
					} else {
						return apps;
					}
				} else {
					if (activeApp != null) {
						List<Application> apps = new ArrayList<Application>(1);
						apps.add(activeApp);
						return apps;
					}
					return new ArrayList<Application>();
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setFilters(filters);
					this.setExcludeSortElements(isExcludedColumns());
					int result;
					if (isIssuingType()) {
						result = applicationDao.getIssuingApplicationsCount(userSessionId, params);
					} else if (isIssProductType()) {
						result = applicationDao.getIssProductApplicationsCount(userSessionId, params);
					} else if (isAcquiringType()) {
						result = applicationDao.getAcquiringApplicationsCount(userSessionId, params);
					} else if (isAcqProductType()) {
						result = applicationDao.getAcqProductApplicationsCount(userSessionId, params);
					} else if (isPMOType()) {
						result = applicationDao.getPMOApplicationsCount(userSessionId, params);
					} else if (isACMType()) {
						result = applicationDao.getACMApplicationsCount(userSessionId, params);
					} else if (isInstitutionType()) {
						result = applicationDao.getInstitutionApplicationsCount(userSessionId, params);
					} else if (isQuestionaryType()) {
						result = applicationDao.getQuestionaryApplicationsCount(userSessionId, params);
					} else if (isCampaignType()) {
						result = applicationDao.getCampaignApplicationsCount(userSessionId, params);
					} else {
						result = applicationDao.getApplicationsCount(userSessionId, params);
					}
					if(activeApp != null && result == 0) {
						activeApp = null;
					}
					return result;
				} else {
					if(activeApp != null) {
						activeApp = getApplicationById(activeApp.getId());
						if (activeApp != null) {
							return 1;
						}
					}
					return 0;
				}
			}
		};

		Menu menu = ManagedBeanWrapper.getManagedBean("menu");
		if (!menu.isKeepState() && (!appBean.isKeepState() || (!appWiz.isKeepState()))) {
			clearBeansState();
			searching = false;
		} else {
			menu.setKeepState(false);
			if (appBean.isKeepState()){
				appBean.setKeepState(false);
				activeApp = appBean.getActiveApp();
				searching = appBean.isSearching();
				filter = appBean.getFilter();
				pageNumber = appBean.getPageNumber();
				rowsNum = appBean.getRowsNum();
			} else{
				appWiz.setKeepState(false);
				activeApp = appWiz.getActiveApp();
				searching = appWiz.isSearching();
				filter = appWiz.getFilter();
				pageNumber = appWiz.getPageNumber();
				rowsNum = appWiz.getRowsNum();
			}
			
			backLink = (String) FacesUtils.getSessionMapValue("backLink");
			if (backLink != null) {
				FacesUtils.setSessionMapValue("backLink", null);
				FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
			}
			
			if ((appBean.isNewMode() || appWiz.idNewMod() )&& activeApp != null) {
				addNew = true;
			}
		}
		itemSelection = new TableRowSelection<Application>(null, appSource);

		contractsSource = new DaoDataModel<Contract>() {
			private static final long serialVersionUID = 3579410696277600900L;

			@Override
			protected Contract[] loadDaoData(SelectionParams params) {
				try {
					if (!isSearchingContract()) {
						return new Contract[0];
					}
					setFiltersContract();
					params.setFilters(filtersContract.toArray(new Filter[filtersContract.size()]));
					getContractParamMaps().put("param_tab", filtersContract.toArray(new Filter[filtersContract.size()]));
					getContractParamMaps().put("tab_name", "CONTRACT");
					return productsDao.getContractsCur(userSessionId, params, getContractParamMaps());
				} catch (DataAccessException ee) {
					setDataSize(0);
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				}
				return new Contract[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					if (!isSearchingContract()) {
						return 0;
					}
					setFiltersContract();
					params.setFilters(filtersContract.toArray(new Filter[filtersContract.size()]));
					getContractParamMaps().put("param_tab", filtersContract.toArray(new Filter[filtersContract.size()]));
					getContractParamMaps().put("tab_name", "CONTRACT");
					return productsDao.getContractsCurCount(userSessionId, params, getContractParamMaps());
				} catch (DataAccessException ee) {
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				}
				return 0;
			}
		};
		contractsSelection = new TableRowSelection<Contract>(null, contractsSource);

		customersSource = new DaoDataModel<Customer>() {
			private static final long serialVersionUID = -9039726972036114251L;

			@Override
			protected Customer[] loadDaoData(SelectionParams params) {
				if (!searchingCustomer) {
					return new Customer[0];
				}
				try {
					setFiltersCustomer();
					params.setFilters(filtersCustomer.toArray(new Filter[filtersCustomer.size()]));
					return productsDao.getCombinedCustomers(userSessionId, params, curLang);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new Customer[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searchingCustomer) {
					return 0;
				}
				try {
					setFiltersCustomer();
					params.setFilters(filtersCustomer.toArray(new Filter[filtersCustomer.size()]));
					return productsDao.getCombinedCustomersCount(userSessionId, params, curLang);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};
		customersSelection = new TableRowSelection<Customer>(null, customersSource);

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null && sectionId.equals(getSectionId())) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
		restoreFilter();
	}
	
	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbApplicationsSearch");

		if (queueFilter == null) {
			setDefaultValues();
			return;
		}
		if (queueFilter.get("filter") != null && queueFilter.get("filter") instanceof Application){
			filter = (Application)queueFilter.get("filter");
		}
		if (queueFilter.containsKey("merchantNumber")){
			getFilter().setMerchantNumber((String)queueFilter.get("merchantNumber"));
		}
		if (queueFilter.containsKey("terminalNumber")) {
			getFilter().setTerminalNumber((String)queueFilter.get("terminalNumber"));
		}
		if (queueFilter.containsKey("instId")){
			getFilter().setInstId((Integer)queueFilter.get("instId"));
		}
		if (queueFilter.containsKey("appDateFrom")){
			getFilter().setAppDateFrom((Date)queueFilter.get("appDateFrom"));
		}
		if (queueFilter.containsKey("accountNumber")){
			getFilter().setAccountNumber((String)queueFilter.get("accountNumber"));
		}
		if (queueFilter.containsKey("objectId")){
			getFilter().setObjectId((Long)queueFilter.get("objectId"));
		}
		if (queueFilter.containsKey("entityType")){
			getFilter().setEntityType((String)queueFilter.get("entityType"));
		}
		if (queueFilter.containsKey("cardNumber")){
			getFilter().setCardNumber((String)queueFilter.get("cardNumber"));
		}
		if (queueFilter.containsKey("appType")){
			setAppType((String)queueFilter.get("appType"));
		}
		if (queueFilter.containsKey("backLink")){
			backLink=(String)queueFilter.get("backLink");
		}
		if (queueFilter.containsKey("showWizard")){
			showWizard = true;
		}

		search();

		clearDisabledFields();
		setDisabledMerchantNumber(true);
	}

	public DaoDataModel<Application> getApplications() {
		return appSource;
	}

	public Application getActiveApp() {
		return activeApp;
	}

	public void setActiveApp(Application activeApp) {
		this.activeApp = activeApp;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (activeApp == null && appSource.getRowCount() > 0) {
				appSource.setRowIndex(0);
				activeApp = (Application) appSource.getRowData();
				if (activeApp != null) {
					SimpleSelection selection = new SimpleSelection();
					selection.addKey(activeApp.getModelId());
					itemSelection.setWrappedSelection(selection);
					appBean.setActiveApp(activeApp);
					setInfo();
				}
			} else if (activeApp != null && appSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(activeApp.getModelId());
				itemSelection.setWrappedSelection(selection);
				activeApp = itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeApp = itemSelection.getSingleSelection();
		appBean.setActiveApp(activeApp);
		setInfo();
	}
	
	public void setInfo() {
		if (activeApp != null) {
            if (tabName.equalsIgnoreCase("additionalTab")) {
                // get flexible data for this institution
                MbFlexFieldsDataSearch flexible = ManagedBeanWrapper.getManagedBean("MbFlexFieldsDataSearch");
                FlexFieldData filterFlex = new FlexFieldData();
                filterFlex.setInstId(activeApp.getInstId());
                filterFlex.setEntityType(EntityNames.APPLICATION);
                filterFlex.setObjectId(activeApp.getId());
                //set a filter for a child object

                if (activeApp.getObjectId() != null) {
                    FlexFieldData childFilterFlex = new FlexFieldData();
                    childFilterFlex.setInstId(activeApp.getInstId());
                    childFilterFlex.setEntityType(activeApp.getEntityType());
                    childFilterFlex.setObjectId(activeApp.getObjectId());
                    filterFlex.setChildEntityFilter(childFilterFlex);
                }

                flexible.setFilter(filterFlex);
                flexible.search();
            } else if(tabName.equals("errorsTab")){
				MbApplicationErrorsSearch errorsBean = ManagedBeanWrapper
						.getManagedBean("MbApplicationErrorsSearch");
				ApplicationElement filter = new ApplicationElement();
				filter.setAppId(activeApp.getId());
				errorsBean.setFilter(filter);
				errorsBean.search();
			}
			if(tabName.equals("notesTab")){
				MbNotesSearch notesSearch = ManagedBeanWrapper
						.getManagedBean("MbNotesSearch");
				ObjectNoteFilter filterNote = new ObjectNoteFilter();
				filterNote.setEntityType(EntityNames.APPLICATION);
				filterNote.setObjectId(activeApp.getId());
				notesSearch.setFilter(filterNote);
				notesSearch.search();
			}
			if(tabName.equals("historyTab")){
				MbApplicationHistory mbApplicationHistory = ManagedBeanWrapper
						.getManagedBean("MbApplicationHistory");
				ApplicationHistory applicationHistory = new ApplicationHistory();
				applicationHistory.setApplId(activeApp.getId());
				mbApplicationHistory.setFilter(applicationHistory);
				mbApplicationHistory.search();
			}
			if(tabName.equals("traceTab")){
				MbProcessTrace traceBean = ManagedBeanWrapper.getManagedBean("MbProcessTrace");
				traceBean.clearBean();
				ProcessTrace filterTrace = new ProcessTrace();
				filterTrace.setEntityType(EntityNames.APPLICATION);
				filterTrace.setObjectId(activeApp.getId());
				traceBean.setFilter(filterTrace);
				traceBean.search();
			}
			if(tabName.equals("linkedObjectsTab")){
	            MbApplicationLinkedObjects mbApplicationLinkedObjects = ManagedBeanWrapper
	                    .getManagedBean("MbApplicationLinkedObjects");
	            ApplicationLinkedObjects applicationLinkedObjects = new ApplicationLinkedObjects();
	            applicationLinkedObjects.setApplId(activeApp.getId());
	            mbApplicationLinkedObjects.setFilter(applicationLinkedObjects);
	            mbApplicationLinkedObjects.search();
			}
			if(tabName.equals("criteriaTab")){
				MbApplicationPriorityCriteria mbApplicationLinkedObjects = ManagedBeanWrapper
						.getManagedBean("MbApplicationPriorityCriteria");
				mbApplicationLinkedObjects.setApplicationId(activeApp.getId());
				mbApplicationLinkedObjects.search();
			}
			if(tabName.equals("priorityProductsTab")){
				MbApplicationPriorityProducts mbApplicationLinkedObjects = ManagedBeanWrapper
						.getManagedBean("MbApplicationPriorityProducts");
				mbApplicationLinkedObjects.setApplicationId(activeApp.getId());
				mbApplicationLinkedObjects.search();
			}
		}
	}

	public String getSelectedAppType() {
		return selectedAppType;
	}

	public void setSelectedAppType(String selectedAppType) {
		this.selectedAppType = selectedAppType;
	}

	public ArrayList<SelectItem> getAvailableRejectCodes() {
		return getDictUtils().getArticles(DictNames.AP_REJECT_CODES, true, false);
	}

	public ArrayList<SelectItem> getAvailableAppStatuses() {
		return getDictUtils().getArticles(DictNames.AP_STATUSES, true, false);
	}

	public ArrayList<SelectItem> getAvailableAppTypes() {
		return getDictUtils().getArticles(DictNames.AP_TYPES, true, false);
	}

	public List<SelectItem> getProducts() {
		if (getNewApplication().getInstId() == null ||
				getNewApplication().getCustomerType() == null) {
			return new ArrayList<SelectItem>();
		}
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getNewApplication().getInstId());
		paramMap.put("STATUS", ProductConstants.STATUS_ACTIVE_PRODUCT);
		paramMap.put("CUSTOMER_ENTITY_TYPE", getNewApplication().getCustomerType());
		try {
			if (isAcquiringType()) {
				return getDictUtils().getLov(LovConstants.ACQUIRING_PRODUCTS_CUST, paramMap);
			} else if (isIssuingType()) {
				return getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS_CUST, paramMap);
			} else if (isPMOType()) {//TODO: need LOV
				return getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS_CUST, paramMap);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<SelectItem>();
	}

	public Application getFilter() {
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			initFilterFromContext();
			backLink = (String) FacesUtils.getSessionMapValue("backLink");
			search();
			FacesUtils.setSessionMapValue("initFromContext", null);
		}

		if (filter == null) {
			filter = new Application();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Application filter) {
		this.filter = filter;
	}

	@Override
	public void setSearching(boolean searching) {
		this.searching = searching;
		appBean.setSearching(searching);
		appWiz.setSearching(searching);
	}

	public void search() {
		setSearching(true);
		itemSelection.clearSelection();
		selectedApps.clear();
		checkMap.clear();
		if (!addNew){
			activeApp = null;
		}
		appSource.flushCache();
		appBean.setFilter(filter);
		appWiz.setFilter(filter);
		clearBeansState();
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (appType != null) {
			String appTypes = "'" + appType + "'";
			if (isIssProductType() || isAcqProductType()) {
				appTypes = appTypes + ", '" + ApplicationConstants.TYPE_PRODUCT + "'";
			}
			filtersList.add(Filter.create("appl_types", appTypes));
		}
		if (getFilter().getId() != null) {
			filtersList.add(Filter.create("id", getFilter().getId()));
		}
		if (getFilter().getTerminalNumber() != null && !getFilter().getTerminalNumber().equals("")) {
			filtersList.add(Filter.create("terminal_number", getFilter().getTerminalNumber()));
		}
		if (getFilter().getCustomerNumber() != null && !getFilter().getCustomerNumber().equals("")) {
			filtersList.add(Filter.create("customer_number", Operator.like, Filter.mask(getFilter().getCustomerNumber(), false)));
		}
		if (getFilter().getMerchantNumber() != null && !getFilter().getMerchantNumber().equals("")) {
			filtersList.add(Filter.create("merchant_number", getFilter().getMerchantNumber()));
		}
		if (getFilter().getCardNumber() != null && !getFilter().getCardNumber().equals("")) {
			filtersList.add(Filter.create("card_number", Filter.mask(getFilter().getCardNumber(), false)));
		}
		if (getFilter().getInstId() != null) {
			filtersList.add(Filter.create("inst_id", getFilter().getInstId()));
		}
		if (getFilter().getRegDateFrom() != null) {
			filtersList.add(Filter.create("reg_date_from", getFilter().getRegDateFrom()));
		}
		if (getFilter().getRegDateTo() != null) {
			filtersList.add(Filter.create("reg_date_to", getFilter().getRegDateTo()));
		}
		if (getFilter().getStatus() != null && !getFilter().getStatus().equals("")) {
			filtersList.add(Filter.create("appl_status", getFilter().getStatus()));
		}
		if (getFilter().getFlowId() != null) {
			filtersList.add(Filter.create("flow_id", getFilter().getFlowId()));
		}
		if (getFilter().getApplNumber() != null && getFilter().getApplNumber().trim().length() > 0) {
			filtersList.add(Filter.create("appl_number", Filter.mask(getFilter().getApplNumber())));
		}
		if (getFilter().getAppDateFrom() != null) {
			filtersList.add(Filter.create("app_date_from", getFilter().getAppDateFrom()));
		}
		if (getFilter().getAppDateTo() != null) {
			filtersList.add(Filter.create("app_date_to", getFilter().getAppDateTo()));
		}
		if (getFilter().getContractNumber() != null && !getFilter().getContractNumber().trim().isEmpty()) {
			Filter paramFilter = Filter.create("contract_number", Filter.mask(getFilter().getContractNumber(), false));
			if (getFilter().getContractNumber().contains("*")){
				paramFilter.setCondition("like");
			} else {
				paramFilter.setCondition("=");
			}
			filtersList.add(paramFilter);
		}
		if (userName != null && !userName.equals("")) {
			filtersList.add(Filter.create("user_name", Operator.like, Filter.mask(userName, false)));
		}
		if (userId != null) {
			filtersList.add(Filter.create("user_id", userId));
		}
		if (roleName != null && !roleName.equals("")) {
			filtersList.add(Filter.create("role_name", Operator.like, Filter.mask(roleName, false)));
		}
		if (roleId != null) {
			filtersList.add(Filter.create("role_id", roleId.toString()));
		}
		if (getFilter().getObjectId() != null &&
			getFilter().getEntityType() != null &&
			!"".equalsIgnoreCase(getFilter().getEntityType())) {
			filtersList.add(Filter.create("object_id", getFilter().getObjectId()));
			filtersList.add(Filter.create("entity_type", getFilter().getEntityType()));
		}
		if (getFilter().getAccountNumber() != null && !getFilter().getAccountNumber().equals("")) {
			filtersList.add(Filter.create("account_number", getFilter().getAccountNumber()));
		}
		if (getFilter().getPrioritized() != null ) {
			filtersList.add(Filter.create("appl_prioritized", getFilter().getPrioritized() ? 1 : 0));
		}
		filtersList.add(Filter.create("lang", curLang));

		filters = filtersList;
	}

	public void setFiltersContract() {
		List<Filter> filtersList = new ArrayList<Filter>();
		Contract filter = getFilterContract();
		if (StringUtils.isNotEmpty(filter.getAccountNumber())) {
			filtersList.add(Filter.create("ACCOUNT_NUMBER", Operator.like, Filter.mask(filter.getAccountNumber())));
		}
		if (StringUtils.isNotEmpty(filter.getCardNumber())) {
			filtersList.add(Filter.create("CARD_NUMBER", Operator.like, Filter.mask(filter.getCardNumber())));
		}
		if (StringUtils.isNotEmpty(filter.getCustomerNumber())) {
			filtersList.add(Filter.create("CUSTOMER_NUMBER", Operator.like, Filter.mask(filter.getCustomerNumber())));
		}
		if (filter.getCustomerId() != null) {
			filtersList.add(Filter.create("CUSTOMER_ID", filter.getCustomerId().toString()));
		}
		if (StringUtils.isNotEmpty(filter.getContractNumber())) {
			filtersList.add(Filter.create("CONTRACT_NUMBER", Operator.like, Filter.mask(filter.getContractNumber())));
		}
		if (getNewApplication().getInstId() != null) {
			filtersList.add(Filter.create("INST_ID", filter.getInstId().toString()));
		}
		if (getNewApplication().getAgentId() != null) {
			filtersList.add(Filter.create("AGENT_ID", getNewApplication().getAgentId().toString()));
		}
		filtersList.add(Filter.create("LANG", curLang));
		if (isAcquiringType() || isAcqProductType()) {
			filtersList.add(Filter.create("PRODUCT_TYPE", ProductConstants.ACQUIRING_PRODUCT));
		} else {
			filtersList.add(Filter.create("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT));
		}

		filtersContract = filtersList;
	}

	public void clearFilter() {
		filter = null;
		clearBean();
		searching = false;
		clearSectionFilter();
		clearDisabledFields();
		addNew = false;
		setDefaultValues();
	}

	public void clearBean() {
		activeApp = null;
		itemSelection.clearSelection();
		appSource.flushCache();
		clearBeansState();
	}

	private void clearBeansState() {
		MbNotesSearch notesSearch = ManagedBeanWrapper.getManagedBean("MbNotesSearch");
		notesSearch.clearFilter();

		MbApplicationHistory mbApplicationHistory = ManagedBeanWrapper.getManagedBean("MbApplicationHistory");
		mbApplicationHistory.clearState();
		mbApplicationHistory.setFilter(null);

		MbProcessTrace traceBean = ManagedBeanWrapper.getManagedBean("MbProcessTrace");
		traceBean.clearFilter();

		MbApplicationErrorsSearch errBean = ManagedBeanWrapper.getManagedBean("MbApplicationErrorsSearch");
		errBean.clearFilter();

		MbApplicationLinkedObjects linkedBean = ManagedBeanWrapper.getManagedBean("MbApplicationLinkedObjects");
		linkedBean.clearFilter();
	}

	public void deleteApp() {
		try {
			logger.trace("Delete application with id [" + activeApp.getId() + "] because of pressing delete button!");
			applicationDao.deleteApplication(userSessionId, activeApp);
			activeApp = itemSelection.removeObjectFromList(activeApp);
			if (activeApp == null) {
				clearBean();
			} else {
				setInfo();
			}
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public String processApp(boolean hasOptionToForce) {
		if (!hasOptionToForce) {
			return doProcessApp(false);
		}
		return null;
	}

	public String doProcessApp(boolean doForce) {
		try {
			applicationDao.processApplication(userSessionId, activeApp.getId(), doForce);
			appSource.flushCache();
			setInfo();
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
		return null;
	}

	public String create() {
		appBean.setPageNumber(pageNumber);
		appBean.setRowsNum(rowsNum);
		newApplication = new Application();
		newApplication.setAppType(appType);
		newApplication.setInstId(userInstId);
		MbApplicationCreate appCreate = (MbApplicationCreate)ManagedBeanWrapper.getManagedBean("MbApplicationCreate");
		appCreate.clear();
		appCreate.setAppType(appType);
		if (appType == null) {
			appCreate.setShowAppType(true);
		}
		appCreate.setModule(module);
		appCreate.setThisBackLink(thisBackLink);
		appCreate.setNewApplication(newApplication);
		appCreate.onInstitutionChanged();
		return null;
	}

	public String createUser() {
		MbWizard appWiz = ManagedBeanWrapper.getManagedBean(MbWizard.class);
		appWiz.setAppType(appType);
		MbAppWizAcmFlow first = ManagedBeanWrapper.getManagedBean(MbAppWizAcmFlow.class);
		backLink = "applications|list_acm_apps";
		first.setBacklink(backLink);
		first.init();
		return null;
	}

	public String createInstitution() throws Exception {
		try {
			backLink = "applications|list_inst_apps";
			thisBackLink = backLink;

			newApplication = new Application();
			newApplication.setId(null);
			newApplication.setAppType(appType);
			newApplication.setFlowId(MbApplicationCreate.INST_APP_CREATE_FLOW_ID);
			newApplication.setInstId(userInstId);
			newApplication.setPrioritized(false);

			appBean.setCurMode(MbApplication.NEW_MODE);
			appBean.setPageNumber(pageNumber);
			appBean.setRowsNum(rowsNum);
			appBean.setActiveApp(newApplication);
			appBean.setBackLink(thisBackLink);
			appBean.setModule(appTypesMap.get(appType));
			appBean.setKeepState(true);

			appBean.getApplicationForEdit();
			appBean.fillTree();

			Menu menu = ManagedBeanWrapper.getManagedBean("menu");
			menu.setKeepState(true);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return "fail";
		}
		activeApp = newApplication;
		return "applications|edit";
	}

	public String createQuestionary() throws Exception {
		try {
			backLink = "applications|list_qstn_apps";
			thisBackLink = backLink;

			newApplication = new Application();
			newApplication.setId(null);
			newApplication.setAppType(appType);
			newApplication.setFlowId(MbApplicationCreate.QUESTIONARY_APP_CREATE_FLOW_ID);
			newApplication.setInstId(userInstId);
			newApplication.setPrioritized(false);

			appBean.setCurMode(MbApplication.NEW_MODE);
			appBean.setPageNumber(pageNumber);
			appBean.setRowsNum(rowsNum);
			appBean.setActiveApp(newApplication);
			appBean.setBackLink(thisBackLink);
			appBean.setModule(appTypesMap.get(appType));
			appBean.setKeepState(true);

			appBean.getApplicationForEdit();
			appBean.fillTree();

			Menu menu = ManagedBeanWrapper.getManagedBean("menu");
			menu.setKeepState(true);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return "fail";
		}
		activeApp = newApplication;
		return "applications|edit";
	}

	public String createCampaign() throws Exception {
		try {
			backLink = "applications|list_cmpn_apps";
			thisBackLink = backLink;

			MbAppCampaignWizard wizard = ManagedBeanWrapper.getManagedBean(MbAppCampaignWizard.class);
			wizard.init();
			wizard.setBacklink(backLink);
			wizard.setUserId(getUserId());
			wizard.setUserName(getUserName());
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return "fail";
		}
		return null;
	}

	public String createApp() {
		try {
			newApplication.setId(null);
			newApplication = applicationDao.createApplication(userSessionId, newApplication);
			appBean.setActiveApp(newApplication);
			appBean.setPageNumber(pageNumber);
			appBean.setRowsNum(rowsNum);
			appBean.setCurMode(MbApplication.NEW_MODE);
			appBean.getApplicationForEdit();
			appBean.setBackLink(thisBackLink);
			appBean.setModule(appTypesMap.get(appType));
			Menu menu = ManagedBeanWrapper.getManagedBean("menu");
			menu.setKeepState(true);
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
			return "fail";
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return "fail";
		}
		activeApp = newApplication;
		return "applications|edit";
	}

	public String editApplication() {
		try {
			appBean.setCurMode(MbApplication.EDIT_MODE); // Important! it must
			appBean.setPageNumber(pageNumber);
			appBean.setRowsNum(rowsNum);
			appBean.setActiveApp(activeApp);
			appBean.getApplicationForEdit();
			appBean.setBackLink(thisBackLink);
			appBean.setModule(appTypesMap.get(appType));
			appBean.setKeepState(true);
			Menu menu = ManagedBeanWrapper.getManagedBean("menu");
			menu.setKeepState(true);
		}catch (DataAccessException e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return thisBackLink;
		}
		catch (Exception e) {
			logger.error("", e);
			try {
				throw new UserException(e.getMessage());
			} catch (UserException ee) {
				ee.printStackTrace();
			}
		}
		activeApp = newApplication;
		return "applications|edit";
	}
	
	public String wizardApp(){
		appWiz.setAppType(appType);
		appWiz.setPageNumber(pageNumber);
		appWiz.setRowsNum(rowsNum);
		appWiz.setBackLink(thisBackLink);
		appWiz.setMod(NEW_MODE);
		MbAppWizardFirstPage fp = ManagedBeanWrapper.getManagedBean(MbAppWizardFirstPage.class);
		fp.init();
		Menu menu = ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);
		return "acquiring|applications|wizardApp";
	}

	public String viewApplication() {
		try {
			appBean.setPageNumber(pageNumber);
			appBean.setRowsNum(rowsNum);
			appBean.setActiveApp(activeApp);
			appBean.getApplicationForView();
			appBean.setBackLink(thisBackLink);
			appBean.setModule(appTypesMap.get(appType));
			appBean.setKeepState(true);
			Menu menu = ManagedBeanWrapper.getManagedBean("menu");
			menu.setKeepState(true);
			if (backLink != null) FacesUtils.setSessionMapValue("backLink", backLink);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return backLink;
		}
		activeApp = newApplication;
		return "applications|edit";
	}

	public Application getNewApplication() {
		if (newApplication == null) {
			newApplication = new Application();
		}
		return newApplication;
	}

	public void setNewApplication(Application newApplication) {
		this.newApplication = newApplication;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
			if (institutions == null) {
				institutions = new ArrayList<SelectItem>();
			}
		}
		return institutions;
	}

	public List<SelectItem> getAgents() {
		if (getNewApplication().getInstId() != null) {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("INSTITUTION_ID", getNewApplication().getInstId());
			return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
		}
		return new ArrayList<SelectItem>();
	}

	public ArrayList<SelectItem> getApplicationFlows() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			if (getNewApplication().getInstId() != null) {
				ArrayList<Filter> filtersFlow = new ArrayList<Filter>();
				filtersFlow.add(Filter.create("instId", getNewApplication().getInstId().toString()));
				filtersFlow.add(Filter.create("lang", curLang));
				filtersFlow.add(Filter.create("type", getNewApplication().getAppType()));
				params.setFilters(filtersFlow);

				ApplicationFlow[] flows = applicationDao.getApplicationFlows(userSessionId, params);
				for (ApplicationFlow flow : flows) {
					items.add(new SelectItem(flow.getId(), flow.getName(), flow.getDescription()));
				}
			}
		} catch (DataAccessException e) {
			logger.error("", e);
			if (e.getMessage() != null && !e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
				FacesUtils.addMessageError(e);
			}
		}
		return items;
	}
	
	public List<SelectItem> getAllApplicationFlows(){
		if (allAppFlows == null){
			allAppFlows = getDictUtils().getLov(LovConstants.APP_FLOWS);
		}
		return allAppFlows;
	}

	public String getAppType() {
		return appType;
	}

	public void setAppType(String appType) {
		if (ISSUING.equals(appType)) {
			this.appType = ApplicationConstants.TYPE_ISSUING;
			thisBackLink = ApplicationConstants.BACKLINK_ISS_APPLICATIONS;
		} else if (ISS_PRODUCT.equals(appType)) {
			this.appType = ApplicationConstants.TYPE_ISS_PRODUCT;
			thisBackLink = ApplicationConstants.BACKLINK_ISS_PRODUCTS;
		} else if (ACQUIRING.equals(appType)) {
			this.appType = ApplicationConstants.TYPE_ACQUIRING;
			thisBackLink = ApplicationConstants.BACKLINK_ACQ_APPLICATIONS;
		} else if (ACQ_PRODUCT.equals(appType)) {
			this.appType = ApplicationConstants.TYPE_ACQ_PRODUCT;
			thisBackLink = ApplicationConstants.BACKLINK_ACQ_PRODUCTS;
		}  else if (INSTITUTION.equals(appType)) {
			this.appType = ApplicationConstants.TYPE_INSTITUTION;
			thisBackLink = ApplicationConstants.BACKLINK_INSTITUTIONS;
			getFilter().setInstId(InstitutionConstants.UNDEFINED_INSTITUTION);
		} else if (PAYMENT_ORDERS.equals(appType)) {
			this.appType = ApplicationConstants.TYPE_PAYMENT_ORDERS;
			thisBackLink = ApplicationConstants.BACKLINK_PAYMENT_ORDERS;
		} else if (USER_MNG.equals(appType)) {
			this.appType = ApplicationConstants.TYPE_USER_MNG;
			thisBackLink = ApplicationConstants.BACKLINK_USER_MANAGEMENT;
		} else if (QUESTIONARY.equals(appType)) {
			this.appType = ApplicationConstants.TYPE_QUESTIONARY;
			thisBackLink = ApplicationConstants.BACKLINK_QUESTIONARY;
		} else if (CAMPAIGN.equals(appType)) {
			this.appType = ApplicationConstants.TYPE_CAMPAIGNS;
			thisBackLink = ApplicationConstants.BACKLINK_CAMPAIGNS;
		} else {
			this.appType = null;
			thisBackLink = ApplicationConstants.BACKLINK_APPLICATIONS;
		}
	}

	public String getPageName() {
		if (isIssuingType()) {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "issuing_apps");
		} else if (isIssProductType() || isAcqProductType()) {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "product_apps");
		} else if (isPMOType()) {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "pmo_apps");
		} else if (isInstitutionType()) {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "inst_apps");
		} else if (isAcquiringType()) {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "acquiring_apps");
		} else if (isQuestionaryType()) {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "questionary_apps");
		} else if (isCampaignType()) {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "campaigns_apps");
		} else {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "applications");
		}
		return pageName;
	}

	public boolean isIssuingType() {
		return ApplicationConstants.TYPE_ISSUING.equals(appType);
	}

	public boolean isIssProductType() {
		return ApplicationConstants.TYPE_ISS_PRODUCT.equals(appType);
	}

	public boolean isAcquiringType() {
		return ApplicationConstants.TYPE_ACQUIRING.equals(appType);
	}

	public boolean isAcqProductType() {
		return ApplicationConstants.TYPE_ACQ_PRODUCT.equals(appType);
	}

	public boolean isInstitutionType() {
		return ApplicationConstants.TYPE_INSTITUTION.equals(appType);
	}

	public boolean isPMOType() {
		return ApplicationConstants.TYPE_PAYMENT_ORDERS.equals(appType);
	}

	public boolean isACMType() {
		return ApplicationConstants.TYPE_USER_MNG.equals(appType);
	}

	public boolean isQuestionaryType() {
		return ApplicationConstants.TYPE_QUESTIONARY.equals(appType);
	}

	public boolean isCampaignType() {
		return ApplicationConstants.TYPE_CAMPAIGNS.equals(appType);
	}

	public boolean isAnyType() {
		return appType == null || appType.isEmpty();
	}

	public String getTimeZone() {
		return timeZone;
	}

	// ------- Contracts methods
	public DaoDataModel<Contract> getContracts() {
		return contractsSource;
	}

	public Contract getActiveContract() {
		return activeContract;
	}

	public void setActiveContract(Contract activeContract) {
		this.activeContract = activeContract;
	}

	public SimpleSelection getContractsSelection() {
		return itemSelection.getWrappedSelection();
	}

	public void setContractsSelection(SimpleSelection selection) {
		contractsSelection.setWrappedSelection(selection);
		activeContract = contractsSelection.getSingleSelection();
	}

	public boolean isSearchingContract() {
		return searchingContract;
	}

	public void setSearchingContract(boolean searchingContract) {
		this.searchingContract = searchingContract;
	}

	public Contract getFilterContract() {
		if (filterContract == null) {
			filterContract = new Contract();
		}
		return filterContract;
	}

	public void setFilterContract(Contract filterContract) {
		this.filterContract = filterContract;
	}

	public void searchContracts() {
		setSearchingContract(true);
		contractsSelection.clearSelection();
		activeContract = null;
		contractsSource.flushCache();
	}

	public void showContracts() {
		searchingContract = false;
		contractsSelection.clearSelection();
		activeContract = null;
		contractsSource.flushCache();
		filterContract = new Contract();
		filterContract.setInstId(getNewApplication().getInstId());
		filterContract.setAgentId(getNewApplication().getAgentId());
	}

	public void selectContract() {
		Contract selected = contractsSelection.getSingleSelection();
		getNewApplication().setContractId(selected.getId());
		getNewApplication().setContractNumber(selected.getContractNumber());
		if (getNewApplication().getCustomerId() == null) {
			getNewApplication().setCustomerId(selected.getCustomerId());
			getNewApplication().setCustomerNumber(selected.getCustomerNumber());
		}
		getNewApplication().setProductId(selected.getProductId());
	}

	// ------- Customers methods
	public DaoDataModel<Customer> getCustomers() {
		return customersSource;
	}

	public Customer getActiveCustomer() {
		return activeCustomer;
	}

	public void setActiveCustomer(Customer activeCustomer) {
		this.activeCustomer = activeCustomer;
	}

	public SimpleSelection getCustomersSelection() {
		return itemSelection.getWrappedSelection();
	}

	public void setCustomersSelection(SimpleSelection selection) {
		customersSelection.setWrappedSelection(selection);
		activeCustomer = customersSelection.getSingleSelection();
	}

	public boolean isSearchingCustomer() {
		return searchingCustomer;
	}

	public void setSearchingCustomer(boolean searchingCustomer) {
		this.searchingCustomer = searchingCustomer;
	}

	public Customer getFilterCustomer() {
		if (filterCustomer == null) {
			filterCustomer = new Customer();
		}
		return filterCustomer;
	}

	public void setFilterCustomer(Customer filterCustomer) {
		this.filterCustomer = filterCustomer;
	}

	public void searchCustomers() {
		setSearchingCustomer(true);
		customersSelection.clearSelection();
		activeCustomer = null;
		customersSource.flushCache();
	}

	public void showCustomers() {
		searchingCustomer = false;
		customersSelection.clearSelection();
		activeCustomer = null;
		customersSource.flushCache();
		filterCustomer = new Customer();
		filterCustomer.setInstId(getNewApplication().getInstId());
		if (isAcquiringType()) {
			filterCustomer.setEntityType(EntityNames.COMPANY);
		}
	}

	public void selectCustomer() {
		Customer selected = customersSelection.getSingleSelection();
		getNewApplication().setCustomerId(selected.getId());
		getNewApplication().setCustomerNumber(selected.getCustomerNumber());
	}

	public void setFiltersCustomer() {
		boolean searchCustomerByPerson = false;
		boolean searchCustomerByCompany = false;

		Customer filter = getFilterCustomer();
		filtersCustomer = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filtersCustomer.add(paramFilter);

		if (EntityNames.COMPANY.equals(filter.getEntityType())) {
			searchCustomerByCompany = true;
		} else if (EntityNames.PERSON.equals(filter.getEntityType())) {
			searchCustomerByPerson = true;
		}

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId().toString());
			filtersCustomer.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filtersCustomer.add(paramFilter);
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("customerNumber");
			paramFilter.setValue(filter.getCustomerNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filtersCustomer.add(paramFilter);
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("customerTypeId");
			paramFilter.setValue(filter.getCustomerNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filtersCustomer.add(paramFilter);
		}
		if (filter.getPerson().getFirstName() != null &&
				filter.getPerson().getFirstName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("personFirstName");
			paramFilter.setValue(filter.getPerson().getFirstName().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filtersCustomer.add(paramFilter);

			searchCustomerByPerson = true;
		}
		if (filter.getPerson().getSurname() != null &&
				filter.getPerson().getSurname().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("personSurname");
			paramFilter.setValue(filter.getPerson().getSurname().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filtersCustomer.add(paramFilter);

			searchCustomerByPerson = true;
		}

		if (filter.getCompany().getLabel() != null &&
				filter.getCompany().getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("companyName");
			paramFilter.setValue(filter.getCompany().getLabel().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filtersCustomer.add(paramFilter);

			searchCustomerByCompany = true;
		}

		if (searchCustomerByCompany && !searchCustomerByPerson) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(EntityNames.COMPANY);
			filtersCustomer.add(paramFilter);
		}

		if (!searchCustomerByCompany && searchCustomerByPerson) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(EntityNames.PERSON);
			filtersCustomer.add(paramFilter);
		}
	}

	public List<SelectItem> getCustomerTypes() {
		return getDictUtils().getLov(LovConstants.CUSTOMER_TYPES_COND);
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;

        if (tabName.equalsIgnoreCase("additionalTab")) {
            MbFlexFieldsDataSearch flexible = ManagedBeanWrapper.getManagedBean("MbFlexFieldsDataSearch");
            flexible.setTabName(tabName);
            flexible.setParentSectionId(getSectionId());
            flexible.setTableState(getSateFromDB(flexible.getComponentId()));
        } else if (tabName.equalsIgnoreCase("notesTab")) {
			MbNotesSearch bean = ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("historyTab")) {
			MbApplicationHistory bean = ManagedBeanWrapper
					.getManagedBean("MbApplicationHistory");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
			
		} else if (tabName.equalsIgnoreCase("traceTab")) {
			MbProcessTrace bean = ManagedBeanWrapper
					.getManagedBean("MbProcessTrace");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));

		} else if (tabName.equalsIgnoreCase("linkedObjectsTab")) {
            MbApplicationLinkedObjects bean = ManagedBeanWrapper
                    .getManagedBean("MbApplicationLinkedObjects");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));

        } else if (tabName.equalsIgnoreCase("criteriaTab")) {
			MbApplicationPriorityCriteria bean = ManagedBeanWrapper
					.getManagedBean("MbApplicationPriorityCriteria");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("priorityProductsTab")) {
			MbApplicationPriorityProducts bean = ManagedBeanWrapper
					.getManagedBean("MbApplicationPriorityProducts");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public void loadCurrentTab() {
		setInfo();
	}

	public String getSectionId() {
		if (isIssuingType()) {
			return SectionIdConstants.ISSUING_APPLICATION;
		} else if (isPMOType()) {
			return SectionIdConstants.PAYMENT_ORDERS_APPLICATION;
		} else if (isInstitutionType()) {
			return SectionIdConstants.INSTITUTION_APPLICATION;
		} else if (isAcqProductType()) {
			return SectionIdConstants.ACQUIRING_PRODUCT_APPLICATION;
		} else if (isIssProductType()) {
			return SectionIdConstants.ISSUING_PRODUCT_APPLICATION;
		} else if (isQuestionaryType()) {
			return SectionIdConstants.QUESTIONARY_APPLICATION;
		} else if (isCampaignType()) {
			return SectionIdConstants.CAMPAIGNS_APPLICATION;
		} else {
			return SectionIdConstants.ACQUIRING_APPLICATION;
		}
	}

	public List<String> getRerenderList() {
		List<String> rerenderList = new ArrayList<String>();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new Application();
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

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = ManagedBeanWrapper
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

	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		getFilter();
		filters = new ArrayList<Filter>();
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterRec.get("id") != null) {
			filter.setIdFilter((filterRec.get("id")));
		}
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("status") != null) {
			filter.setStatus(filterRec.get("status"));
		}
		if (filterRec.get("regDateFrom") != null) {
			filter.setRegDateFrom(df.parse(filterRec.get("regDateFrom")));
		}
		if (filterRec.get("regDateTo") != null) {
			filter.setRegDateTo(df.parse(filterRec.get("regDateTo")));
		}
		if (filterRec.get("appDateFrom") != null) {
			filter.setAppDateFrom(df.parse(filterRec.get("appDateFrom")));
		}
		if (filterRec.get("appDateTo") != null) {
			filter.setAppDateTo(df.parse(filterRec.get("appDateTo")));
		}
		if (filterRec.containsKey("flowId")) {
			filter.setFlowId(Integer.parseInt(filterRec.get("flowId")));
		}
		if (filterRec.get("customerNumber") != null){
			filter.setCustomerNumber(filterRec.get("customerNumber"));
		}
		if (filterRec.get("applNumber") != null){
			filter.setApplNumber(filterRec.get("applNumber"));
		}
		if (filterRec.get("accountNumber") != null){
			filter.setAccountNumber(filterRec.get("accountNumber"));
		}
		if (filterRec.get("contractNumber") != null){
			filter.setContractNumber(filterRec.get("contractNumber"));
		}
		if (filterRec.get("cardNumber") != null){
			filter.setCardNumber(filterRec.get("cardNumber"));
		}
	}

	private void setFilterRec(Map<String, String> filterRec) {
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filter.getIdFilter() != null) {
			filterRec.put("id", filter.getIdFilter());
		}
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getRejectCode() != null) {
			filterRec.put("rejectCode", filter.getRejectCode());
		}
		if (filter.getRegDateFrom() != null) {
			filterRec.put("regDateFrom", df.format(filter.getRegDateFrom()));
		}
		if (filter.getRegDateTo() != null) {
			filterRec.put("regDateTo", df.format(filter.getRegDateTo()));
		}
		if (filter.getAppDateFrom() != null) {
			filterRec.put("appDateFrom", df.format(filter.getAppDateFrom()));
		}
		if (filter.getAppDateTo() != null) {
			filterRec.put("appDateTo", df.format(filter.getAppDateTo()));
		}
		if (filter.getFlowId() != null) {
			filterRec.put("flowId", filter.getFlowId().toString());
		}
		if (filter.getStatus() != null && !filter.getStatus().equalsIgnoreCase("")){
			filterRec.put("status", filter.getStatus());
		}
		if (filter.getCustomerNumber() != null && !filter.getCustomerNumber().equalsIgnoreCase("")){
			filterRec.put("customerNumber", filter.getCustomerNumber());
		}
		if (filter.getApplNumber() != null && !filter.getApplNumber().equalsIgnoreCase("")){
			filterRec.put("applNumber", filter.getApplNumber());
		}
		if (filter.getAccountNumber() != null && !filter.getAccountNumber().equalsIgnoreCase("")){
			filterRec.put("accountNumber", filter.getAccountNumber());
		}
		if (filter.getContractNumber() != null && !filter.getContractNumber().equalsIgnoreCase("")){
			filterRec.put("contractNumber", filter.getCustomerNumber());
		}
		if (filter.getCardNumber() != null && !filter.getCardNumber().equalsIgnoreCase("")){
			filterRec.put("cardNumber", filter.getCardNumber());
		}

	}

	public String getComponentId() {
		return getSectionId() + ":" + COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public void createAppXml() {
		try {
			applicationDao.getXml(activeApp.getId());
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	/**
	 * Initializes bean's filter if bean has been accessed by context menu.
	 */
	private void initFilterFromContext() {
		if (FacesUtils.getSessionMapValue("APP_TYPE") != null) {
			appType = (String) FacesUtils.removeSessionMapValue("APP_TYPE");
		} else {
			appType = null; // in case it was somehow set before
		}

		filter = new Application();
		if (FacesUtils.getSessionMapValue("customerNumber") != null) {
			filter.setCustomerNumber((String) FacesUtils.getSessionMapValue("customerNumber"));
			FacesUtils.setSessionMapValue("customerNumber", null);
		}
		if (FacesUtils.getSessionMapValue("instId") != null) {
			filter.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
			FacesUtils.setSessionMapValue("instId", null);
		}
		if (FacesUtils.getSessionMapValue("instId") != null) {
			filter.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
			FacesUtils.setSessionMapValue("instId", null);
		}
	}

	public String back() {
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);  
		Menu mbMenu = ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect(backLink);
		return backLink;
	}

	public boolean isShowBackBtn() {
		return backLink != null && (backLink.trim().length() > 0);
	}

	/**
	 * <p>
	 * Gets and sets (if needed) actual application type if user moved from one application form to
	 * another because there are possible situations when user changed form (i.e. moved from
	 * acquiring applications to issuing) but the bean wasn't destroyed and application type
	 * remained the same. One needs to read this parameter from form by placing hidden input on its
	 * top.
	 * </p>
	 * 
	 */
	public String getAppTypeHidden() {
		Menu menu = ManagedBeanWrapper.getManagedBean("menu");
		if (this.appType == null || menu.isClicked()) {
			String appType = getAppTypeFromRequest();
			if (appType != null && this.appType != null && !appType.equals(this.appType)) {
				// if it's another applications form then we need to clear all form's data
				clearFilter();
			}
			this.appType = appType;
		}
		return appType;
	}

	private String getAppTypeFromRequest() {
		module = FacesUtils.getRequestParameter("appType");
		String appType;
		if (ISSUING.equals(module)) {
			appType = ApplicationConstants.TYPE_ISSUING;
			thisBackLink = ApplicationConstants.BACKLINK_ISS_APPLICATIONS;
		} else if (ISS_PRODUCT.equals(module)) {
			appType = ApplicationConstants.TYPE_ISS_PRODUCT;
			thisBackLink = ApplicationConstants.BACKLINK_ISS_PRODUCTS;
		} else if (ACQUIRING.equals(module)) {
			appType = ApplicationConstants.TYPE_ACQUIRING;
			thisBackLink = ApplicationConstants.BACKLINK_ACQ_APPLICATIONS;
		} else if (ACQ_PRODUCT.equals(module)) {
			appType = ApplicationConstants.TYPE_ACQ_PRODUCT;
			thisBackLink = ApplicationConstants.BACKLINK_ACQ_PRODUCTS;
		} else if (INSTITUTION.equals(module)) {
			appType = ApplicationConstants.TYPE_INSTITUTION;
			thisBackLink = ApplicationConstants.BACKLINK_INSTITUTIONS;
			getFilter().setInstId(InstitutionConstants.UNDEFINED_INSTITUTION);
		} else if (PAYMENT_ORDERS.equals(module)) {
			appType = ApplicationConstants.TYPE_PAYMENT_ORDERS;
			thisBackLink = ApplicationConstants.BACKLINK_PAYMENT_ORDERS;
		} else if (USER_MNG.equals(module)) {
			appType = ApplicationConstants.TYPE_USER_MNG;
			thisBackLink = ApplicationConstants.BACKLINK_USER_MANAGEMENT;
		} else if (QUESTIONARY.equals(module)) {
			appType = ApplicationConstants.TYPE_QUESTIONARY;
			thisBackLink = ApplicationConstants.BACKLINK_QUESTIONARY;
		} else if (CAMPAIGN.equals(module)) {
			appType = ApplicationConstants.TYPE_CAMPAIGNS;
			thisBackLink = ApplicationConstants.BACKLINK_CAMPAIGNS;
		} else if (FacesUtils.getSessionMapValue("APP_TYPE") != null) {
			appType = (String) FacesUtils.getSessionMapValue("APP_TYPE");
			if (ApplicationConstants.TYPE_ISSUING.equals(appType)) {
				thisBackLink = ApplicationConstants.BACKLINK_ISS_APPLICATIONS;
			} else if (ApplicationConstants.TYPE_ISS_PRODUCT.equals(appType)) {
				thisBackLink = ApplicationConstants.BACKLINK_ISS_PRODUCTS;
			} else if (ApplicationConstants.TYPE_ACQUIRING.equals(appType)) {
				thisBackLink = ApplicationConstants.BACKLINK_ACQ_APPLICATIONS;
			} else if (ApplicationConstants.TYPE_ACQ_PRODUCT.equals(appType)) {
				thisBackLink = ApplicationConstants.BACKLINK_ACQ_PRODUCTS;
			} else if (ApplicationConstants.TYPE_INSTITUTION.equals(appType)) {
				thisBackLink = ApplicationConstants.BACKLINK_INSTITUTIONS;
				getFilter().setInstId(InstitutionConstants.UNDEFINED_INSTITUTION);
			} else if (ApplicationConstants.TYPE_PAYMENT_ORDERS.equals(appType)) {
				thisBackLink = ApplicationConstants.BACKLINK_PAYMENT_ORDERS;
			} else if (ApplicationConstants.TYPE_USER_MNG.equals(appType)) {
				thisBackLink = ApplicationConstants.BACKLINK_USER_MANAGEMENT;
			} else if (ApplicationConstants.TYPE_QUESTIONARY.equals(appType)) {
				thisBackLink = ApplicationConstants.BACKLINK_QUESTIONARY;
			} else if (ApplicationConstants.TYPE_CAMPAIGNS.equals(appType)) {
				thisBackLink = ApplicationConstants.BACKLINK_CAMPAIGNS;
			} else {
				thisBackLink = ApplicationConstants.BACKLINK_APPLICATIONS;
			}
		} else {
			appType = null;
			thisBackLink = ApplicationConstants.BACKLINK_APPLICATIONS;
		}
		return appType;
	}

	public Application getApplicationById(Long appId) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", userLang);
		filters[1] = new Filter("id", appId);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			List<Application> apps = applicationDao.getApplications(userSessionId, params);
			if (apps != null && apps.size() > 0) {
				return apps.get(0);
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return null;
	}

	public ArrayList<SelectItem> getApplicationStatuses() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		if (activeApp == null) {
			return items;
		}
		try {
			if (activeApp.getStatus() == null || activeApp.getFlowId() == null) {
				return items;
			}
			List<ApplicationFlowTransition> statuses = applicationDao.getTransitionApplicationStatusesNoSucFail(userSessionId, activeApp);

			ApplicationFlowTransition activeStatus = activeApp.createTransition(getDictUtils().getAllArticlesDesc());
			items.add(new SelectItem(activeStatus.getAppStatusRejectCode(), activeStatus.getAppStatusRejectLabel()));

			for (ApplicationFlowTransition status : statuses) {
				if (!status.getAppStatusRejectCode().equals(activeStatus.getAppStatusRejectCode())){
					items.add(new SelectItem(status.getAppStatusRejectCode(), status.getAppStatusRejectLabel()));
				}
			}

		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
		return items;
	}
	
	public void changeStatus() {
		try {
			applicationDao.changeApplicationStatus(userSessionId, activeApp);
            Application updatedApp = getApplicationById(activeApp.getId());
            if(updatedApp != null) {
                appSource.replaceObject(activeApp, updatedApp);
            } else {
                appSource.removeObjectFromList(activeApp);
            }
            activeApp = updatedApp;
			setInfo();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public void cancelStatusChange() {
		activeApp.setNewStatus(activeApp.getStatus());
		activeApp.setRejectCode(activeApp.getOldRejectCode());
	}
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) return null;
		Map <String, Object> map = new HashMap<String, Object>();
		if (activeApp != null){
			if (EntityNames.APPLICATION.equals(ctxItemEntityType)) {
				map.put("id", activeApp.getId());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.APPLICATION);
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}
	
	public boolean isDisabledCardNumber() {
		return disabledCardNumber;
	}

	public void setDisabledCardNumber(boolean disabledCardNumber) {
		this.disabledCardNumber = disabledCardNumber;
	}

	public boolean isDisabledAccountNumber() {
		return disabledAccountNumber;
	}

	public void setDisabledAccountNumber(boolean disabledAccountNumber) {
		this.disabledAccountNumber = disabledAccountNumber;
	}

	public boolean isDisabledMerchantNumber() {
		return disabledMerchantNumber;
	}

	public void setDisabledMerchantNumber(boolean disabledMerchantNumber) {
		this.disabledMerchantNumber = disabledMerchantNumber;
	}

	public boolean isDisabledTerminalNumber() {
		return disabledTerminalNumber;
	}

	public void setDisabledTerminalNumber(boolean disabledTerminalNumber) {
		this.disabledTerminalNumber = disabledTerminalNumber;
	}

	public void clearDisabledFields(){
		disabledCardNumber = false;
		disabledAccountNumber = false;
		disabledMerchantNumber = false;
		disabledTerminalNumber = false;
	}

	public boolean isShowWizard(){
		return showWizard;
	}

	public Integer getUserId() {
		return userId;
	}

	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	@Override
	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public Integer getRoleId() {
		return roleId;
	}

	public void setRoleId(Integer roleId) {
		this.roleId = roleId;
	}

	public String getRoleName() {
		return roleName;
	}

	public void setRoleName(String roleName) {
		this.roleName = roleName;
	}

	public void initPanel() {
		logger.debug("init search user panel for flow change user");
	}

	public void selectUser() {
		MbUserSearchModal userBean = ManagedBeanWrapper
				.getManagedBean("MbUserSearchModal");
		User user = userBean.getActiveUser();
		userId = user.getId();
		userName = user.getName();
	}

	public Boolean getShowWarning() {
		if (warnAppStatuses == null) {
			warnAppStatuses = new ArrayList<String>();
			for (SelectItem item : getDictUtils().getArray(ArrayConstants.WARN_APPLICATION_STATUSES)) {
				if (item.getValue() != null) {
					warnAppStatuses.add(item.getValue().toString());
				}
			}
		}
		if (activeApp != null && activeApp.getNewStatus() != null) {
			showWarning = warnAppStatuses.contains(activeApp.getNewStatus());
		} else {
			showWarning = false;
		}
		return showWarning;
	}

	private void setDefaultValues() {
		Calendar today = Calendar.getInstance();
		today.set(Calendar.HOUR, 0);
		today.set(Calendar.MINUTE, 0);
		today.set(Calendar.SECOND, 0);
		getFilter().setAppDateFrom(today.getTime());
		if (isInstitutionType()) {
			getFilter().setInstId(InstitutionConstants.UNDEFINED_INSTITUTION);
		}
	}

	public List<SelectItem> getPriorityList() {
		return getDictUtils().getLov(LovConstants.YES_NO_LIST);
	}

	private String getPrivilegePrefix(int mode) {
		switch (mode) {
			case VIEW_MODE:       return "VIEW_";
			case CREATE_ADD_MODE: return "ADD_";
			case EDIT_MODE:       return "MODIFY_";
			case REMOVE_MODE:     return "REMOVE_";
			case PROCESS_MODE:    return "PROCESS_";
			case APPROVE_MODE:    return "APPROVE_";
		}
		return null;
	}

	private String getPrivilegeName(int mode) {
		if (isIssuingType()) {
			return getPrivilegePrefix(mode) + ApplicationPrivConstants.ISSUING_APPLICATION;
		} else if (isIssProductType()) {
			return getPrivilegePrefix(mode) + ApplicationPrivConstants.ISS_PRD_APPLICATION;
		} else if (isAcquiringType()) {
			return getPrivilegePrefix(mode) + ApplicationPrivConstants.ACQUIRING_APPLICATION;
		} else if (isAcqProductType()) {
			return getPrivilegePrefix(mode) + ApplicationPrivConstants.ACQ_PRD_APPLICATION;
		} else if (isInstitutionType()) {
			return getPrivilegePrefix(mode) + ApplicationPrivConstants.INSTITUTION_APPLICATION;
		} else if (isACMType()) {
			return getPrivilegePrefix(mode) + ApplicationPrivConstants.ACM_APPLICATION;
		} else if (isQuestionaryType()) {
			return getPrivilegePrefix(mode) + ApplicationPrivConstants.QUESTIONARY_APPLICATION;
		} else if (isCampaignType()) {
			return getPrivilegePrefix(mode) + ApplicationPrivConstants.CAMPAIGN_APPLICATION;
		}
		return null;
	}

	public boolean isRendered(String component) {
		Map<String, Boolean> role = ((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getInRole();
		if (appType == null) {
			appType = getAppTypeHidden();
		}
		if (BUTTON_VIEW.equals(component)) {
			return role.get(getPrivilegeName(VIEW_MODE));
		} else if (BUTTON_ADD.equals(component)) {
			if (isQuestionaryType()) {
				return false;
			}
			return role.get(getPrivilegeName(CREATE_ADD_MODE));
		} else if (BUTTON_MODIFY.equals(component)) {
			return role.get(getPrivilegeName(EDIT_MODE));
		} else if (BUTTON_REMOVE.equals(component)) {
			return role.get(getPrivilegeName(REMOVE_MODE));
		} else if (BUTTON_PROCESS.equals(component)) {
			return role.get(getPrivilegeName(PROCESS_MODE));
		} else if (BUTTON_WIZARD.equals(component)) {
			return false && role.get(getPrivilegeName(EDIT_MODE));
		} else if (BUTTON_APPROVE.equals(component)) {
			return role.get(getPrivilegeName(APPROVE_MODE));
		}
		return false;
	}

	public String action(String component) throws Exception {
		if (BUTTON_VIEW.equals(component)) {
			return viewApplication();
		} else if (BUTTON_ADD.equals(component)) {
			if (isInstitutionType()) {
				return createInstitution();
			} else if (isQuestionaryType()) {
				return createQuestionary();
			} else if (isCampaignType()) {
				return createCampaign();
			} else if (isACMType()) {
				return createUser();
			} else {
				return create();
			}
		} else if (BUTTON_MODIFY.equals(component)) {
			return editApplication();
		} else if (BUTTON_PROCESS.equals(component)) {
			Map<String, Boolean> role = ((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getInRole();
			return processApp(role.get(ApplicationPrivConstants.PROCESS_APPLICATION_FORCE));
		} else if (BUTTON_WIZARD.equals(component)) {
			return wizardApp();
		} else if (BUTTON_APPROVE.equals(component)) {
			approveApplications();
		}
		return null;
	}

	public String oncomplete() {
		if (isQuestionaryType()) {
			return "";
		} else if (isCampaignType()) {
			return "Richfaces.showModalPanel('appCampaignPanel', {top:200});";
		} else if (isInstitutionType() || isACMType()) {
			return "Richfaces.showModalPanel('appSelectFlowPanel');";
		} else {
			return "Richfaces.showModalPanel('appPanel', {top:50});";
		}
	}

    public void onSortablePreRenderTable() {
        if (appSource.isClearSortElement()) {
            onSortablePreRenderTable(appSource);
        }
    }

	public void onChangeAppSelect(Application app) {
		if (Boolean.FALSE.equals(checkMap.get(app.getId()))) {
			for (int i = 0; i < selectedApps.size(); i++) {
				if (selectedApps.get(i).getId().equals(app.getId())) {
					selectedApps.remove(i);
					break;
				}
			}
		} else {
			selectedApps.add(app);
		}
	}

	public Map<Long, Boolean> getCheckMap() {
		return checkMap;
	}

	public boolean isAnyApplicationSelected() {
		if(selectedApps != null && selectedApps.size() > 0)
			return true;
		return false;
	}

	public void approveApplications() {
		if(selectedApps != null && selectedApps.size() > 0) {
			try {
				applicationDao.approveApplications(userSessionId, selectedApps);
				search();
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
	}

	public Map<String, Object> getContractParamMaps() {
		if (contractParamMaps == null) {
			contractParamMaps = new HashMap<String, Object>();
		}
		return contractParamMaps;
	}

}
