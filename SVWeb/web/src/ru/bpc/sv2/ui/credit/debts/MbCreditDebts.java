package ru.bpc.sv2.ui.credit.debts;

import java.text.SimpleDateFormat;
import java.util.*;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.credit.CreditDebt;
import ru.bpc.sv2.credit.CreditDebtBalance;
import ru.bpc.sv2.credit.CreditDebtInterest;
import ru.bpc.sv2.credit.CreditDebtPayment;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.issuing.MbIssSelectObject;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbCreditDebts")
public class MbCreditDebts extends AbstractBean{
    private static final long serialVersionUID = -6075112717998547213L;

	private static final Logger logger = Logger.getLogger("CREDIT");

	private static final String INTERESTS_TAB = "INTERESTSTAB";
	private static final String PAYMENTS_TAB = "PAYMENTSTAB";
    private static final String BALANCES_TAB = "BALANCESTAB";

	private static String COMPONENT_ID = "1982:debtsTable";

	private CreditDao creditDao = new CreditDao();

	private ArrayList<SelectItem> institutions;
	private CreditDebt filter;
	private final DaoDataModel<CreditDebt> debtSource;
	
	private CreditDebt activeCreditDebt;
	private final TableRowSelection<CreditDebt> itemSelection;
	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String tabName;
	private String needRerender;
	private List<String> rerenderList;
	private Map<String, Object> paramMap;

	public MbCreditDebts(){
		pageLink = "credit|debts";
		debtSource = new DaoDataModel<CreditDebt>(){
			private static final long serialVersionUID = -8791928234327555044L;
			@Override
			protected CreditDebt[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new CreditDebt[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return creditDao.getDebtsCur(userSessionId, params, paramMap);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CreditDebt[0];
			}
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return creditDao.getDebtsCountCur( userSessionId, paramMap);
				} catch (Exception e){
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		
		itemSelection = new TableRowSelection<CreditDebt>(null, debtSource);
		tabName = "detailsTab";
	}

	@PostConstruct
	public void init() {
		setDefaultValues();	
	}
	
	private void setFilters(){
		CreditDebt debtFilter = getFilter();
		filters = new ArrayList<Filter>();
		Filter paramFilter = null;

		if (debtFilter.getId()!= null){
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(debtFilter.getId().toString());
			filters.add(paramFilter);
		}
		if (debtFilter.getInstId()!= null){
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(debtFilter.getInstId());
			filters.add(paramFilter);
		}
        if (filter.getAccountId() != null) {
            paramFilter = new Filter("ACCOUNT_ID", filter.getAccountId());
            filters.add(paramFilter);
        } else if (debtFilter.getAccountNumber()!= null && debtFilter.getAccountNumber().trim().length() > 0){
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_NUMBER");
			paramFilter.setCondition("=");
			paramFilter.setValue(debtFilter.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			if (((String)paramFilter.getValue()).indexOf("%") != -1 || debtFilter.getAccountNumber().indexOf("?") != -1) {
				paramFilter.setCondition("like");
			}
			filters.add(paramFilter);
		}
        if (filter.getCardId() != null) {
            paramFilter = new Filter("CARD_ID", filter.getCardId());
            filters.add(paramFilter);
        } else if (debtFilter.getCardNumber()!= null && debtFilter.getCardNumber().trim().length() > 0){
			paramFilter = new Filter();
			paramFilter.setElement("CARD_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(debtFilter.getCardNumber().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (debtFilter.getDateFrom()!= null){
			paramFilter = new Filter();
			paramFilter.setElement("DATE_FROM");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(debtFilter.getDateFrom());
			filters.add(paramFilter);
		}
		if (debtFilter.getDateTo()!= null){
			paramFilter = new Filter();
			paramFilter.setElement("DATE_TO");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(debtFilter.getDateTo());
			filters.add(paramFilter);
		}
		if (debtFilter.getOperationType()!= null){
			paramFilter = new Filter();
			paramFilter.setElement("OPER_TYPE");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(debtFilter.getOperationType());
			filters.add(paramFilter);
		}
		if (debtFilter.getStatus()!= null){
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(debtFilter.getStatus());
			filters.add(paramFilter);
		}
		if (debtFilter.getNew()!= null){
			paramFilter = new Filter();
			paramFilter.setElement("IS_NEW");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(debtFilter.getNew() ? 1 : 0);
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
        getParamMap().put("tab_name", "DEBT");
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}
	public ArrayList<SelectItem> getDebtStatuses() {
		return getDictUtils().getArticles(DictNames.DEBT_STATUS, false, false);
	}
	public ArrayList<SelectItem> getOperationTypes(){
		return getDictUtils().getArticles(DictNames.OPER_TYPE, false, false);
	}

	public List<SelectItem> getUnbilledList() {
		return getDictUtils().getLov(LovConstants.YES_NO_LIST);
	}

	public SimpleSelection getItemSelection(){
		if (activeCreditDebt == null && debtSource.getRowCount() > 0){
			setFirstRowActive();
		} else if (activeCreditDebt != null && debtSource.getRowCount() > 0){
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeCreditDebt.getModelId());
			itemSelection.setWrappedSelection(selection);
			activeCreditDebt = itemSelection.getSingleSelection();
		}
		return itemSelection.getWrappedSelection();
	}
	public void setItemSelection(SimpleSelection selection){
		itemSelection.setWrappedSelection(selection);
		activeCreditDebt = itemSelection.getSingleSelection();
		if (activeCreditDebt != null){
			setInfo();
		}
	}

	private void setFirstRowActive(){
		debtSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeCreditDebt = (CreditDebt)debtSource.getRowData();
		selection.addKey(activeCreditDebt.getModelId());
		itemSelection.setWrappedSelection(selection);
		if (activeCreditDebt != null) {
			setInfo();
		}
	}

	private void setInfo(){
		loadedTabs.clear();
		loadTab(getTabName());
	}
	private void loadTab(String tabName){
		if (tabName == null){
			return;
		}
		if (activeCreditDebt == null){
			return;
		}
		if (tabName.equalsIgnoreCase(PAYMENTS_TAB)){
			MbCreditDebtsPayments mbPayments = (MbCreditDebtsPayments) ManagedBeanWrapper
			.getManagedBean("MbCreditDebtsPayments");
			CreditDebtPayment paymentsFilter = new CreditDebtPayment();
			paymentsFilter.setDebtId(activeCreditDebt.getId());
			mbPayments.setFilter(paymentsFilter);
			mbPayments.search();

		} else if (tabName.equalsIgnoreCase(INTERESTS_TAB)) {
			MbCreditDebtsInterests mbInterests = (MbCreditDebtsInterests) ManagedBeanWrapper
					.getManagedBean("MbCreditDebtsInterests");
			CreditDebtInterest interestsFilter = new CreditDebtInterest();
			interestsFilter.setDebtId(activeCreditDebt.getId());
			mbInterests.setFilter(interestsFilter);
			mbInterests.search();

		} else if (tabName.equalsIgnoreCase(BALANCES_TAB)) {
            MbCreditDebtsBalances mbBalances = (MbCreditDebtsBalances) ManagedBeanWrapper
                    .getManagedBean("MbCreditDebtsBalances");
            CreditDebtBalance balancesFilter = new CreditDebtBalance();
            balancesFilter.setDebtId(activeCreditDebt.getId());
            mbBalances.setFilter(balancesFilter);
            mbBalances.search();
        }


		needRerender = tabName;
		loadedTabs.put(tabName, Boolean.TRUE);
	}

	public void search() {
        search(true);
	}

    public void search(boolean selectObject) {
        if (selectObject) {
            clearBean();
            paramMap = new HashMap<String, Object>();

            searching = false;
            MbIssSelectObject bean = ManagedBeanWrapper.getManagedBean(MbIssSelectObject.class);
            int size = bean.load(this);
            if (size > 1) {
                getRerenderList().clear();
                getRerenderList().add("searchBtn"); // need for open dialog
                getRerenderList().add(MbIssSelectObject.MODAL_ID);
            } else if(size == 0) {
                searching = true;
            }
        } else {
            searching = true;
        }
    }

    public boolean isNeedOpenSelectObjectDialog() {
        return getRerenderList().contains(MbIssSelectObject.MODAL_ID);
    }

	private void clearBean(){
		// search using new criteria
		debtSource.flushCache();
		clearDependencies();
		// reset selection
		itemSelection.clearSelection();
		activeCreditDebt = null;
        rerenderList = null;
	}

	public void clearFilter(){
		filter = null;
		setSearching(false);
		clearBean();
		clearDependencies();
		setDefaultValues();
	}

	private void clearDependencies(){
        MbCreditDebtsBalances mbBalances = (MbCreditDebtsBalances) ManagedBeanWrapper
        .getManagedBean("MbCreditDebtsBalances");
        mbBalances.clearFilter();

		MbCreditDebtsPayments mbPayments = (MbCreditDebtsPayments) ManagedBeanWrapper
		.getManagedBean("MbCreditDebtsPayments");
		mbPayments.clearFilter();

		MbCreditDebtsInterests mbInterests = (MbCreditDebtsInterests) ManagedBeanWrapper
		.getManagedBean("MbCreditDebtsInterests");
		mbInterests.clearFilter();
	}

	public void setTabName(String tabName){
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
		
		if (tabName.equalsIgnoreCase("interestsTab")) {

			MbCreditDebtsInterests bean = (MbCreditDebtsInterests) ManagedBeanWrapper
					.getManagedBean("MbCreditDebtsInterests");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));

		} else if (tabName.equalsIgnoreCase("paymentsTab")) {

			MbCreditDebtsPayments bean = (MbCreditDebtsPayments) ManagedBeanWrapper
					.getManagedBean("MbCreditDebtsPayments");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));

		} else if (tabName.equalsIgnoreCase("balancesTab")) {

            MbCreditDebtsBalances bean = (MbCreditDebtsBalances) ManagedBeanWrapper
                    .getManagedBean("MbCreditDebtsBalances");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }
	}
	
	public String getSectionId() {
		return SectionIdConstants.ISSUING_CREDIT_DEBT;
	}
	
	public boolean getSearching(){
		return searching;
	}
	public String getTabName(){
		return tabName;
	}
	public void setFilter(CreditDebt filter) {
		this.filter = filter;
	}

	public CreditDebt getFilter() {
		if (filter == null){
			filter = new CreditDebt();
		}
		return filter;
	}
	
	public DaoDataModel<CreditDebt> getDebts(){
		return debtSource;
	}
	public CreditDebt getActiveCreditDebt(){
		return activeCreditDebt;
	}
	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}
	public int getRowsNum(){
		return rowsNum;
	}

    public List<String> getRerenderList() {
        if (rerenderList == null) {
            rerenderList = new ArrayList<String>(Arrays.asList("debtsTable", "dsdebts", "pagesNum", getTabName()));
        }
        return rerenderList;
    }

	public List<String> getStoreTabRerenderList(){
		List<String> rerenderList = new ArrayList<String>();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		rerenderList.add(tabName);
		return rerenderList;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	private void setDefaultValues() {
		if (sectionFilterModeEdit) return;
		
		Integer defaultInstId = null;
		List<SelectItem> instList = getInstitutions();
		if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
			// instId from LOV is for some reason String 
			defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
		} else {
			defaultInstId = userInstId;
		}
		
		filter = new CreditDebt();
		Calendar today = Calendar.getInstance();
		today.set(Calendar.HOUR,0);
		today.set(Calendar.MINUTE,0);
		today.set(Calendar.SECOND,0);
		filter.setDateFrom(today.getTime());
		filter.setInstId(defaultInstId);
	}

	public Map<String, Object> getParamMap() {
		if (paramMap == null){
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(Map<String, Object> paramMap) {
		this.paramMap = paramMap;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new CreditDebt();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("accountNumber") != null) {
					filter.setAccountNumber(filterRec.get("accountNumber"));
				}
				if (filterRec.get("cardNumber") != null) {
					filter.setCardNumber(filterRec.get("cardNumber"));
				}
				String dbDateFormat = "dd.MM.yyyy";
				SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
				if (filterRec.get("dateFrom") != null) {
					filter.setDateFrom(df.parse(filterRec.get("dateFrom")));
				}
				if (filterRec.get("operationType") != null) {
					filter.setOperationType(filterRec.get("operationType"));
				}
				if (filterRec.get("dateTo") != null) {
					filter.setDateTo(df.parse(filterRec.get("dateTo")));
				}
				if (filterRec.get("status") != null) {
					filter.setStatus(filterRec.get("status"));
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
			if (filter.getAccountNumber() != null) {
				filterRec.put("accountNumber", filter.getAccountNumber());
			}
			if (filter.getCardNumber() != null) {
				filterRec.put("cardNumber", filter.getCardNumber());
			}
			String dbDateFormat = "dd.MM.yyyy";
			SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
			if (filter.getDateFrom() != null) {
				filterRec.put("dateFrom", df.format(filter.getDateFrom()));
			}
			if (filter.getOperationType() != null) {
				filterRec.put("operationType", filter.getOperationType());
			}
			if (filter.getDateTo() != null) {
				filterRec.put("dateTo", df.format(filter.getDateTo()));
			}
			if (filter.getStatus() != null) {
				filterRec.put("status", filter.getStatus());
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
