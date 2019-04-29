package ru.bpc.sv2.ui.accounts;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.AccountPrivConstants;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.operations.MbOperationsBottom;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbAccountsSearch")
public class MbAccountsSearch extends AbstractBean {
	private static final long serialVersionUID = -9159203349268654667L;

	private static final Logger logger = Logger.getLogger("ACCOUNTING");

	private AccountsDao _accountsDao = new AccountsDao();

	private Account filter;
	private String backLink;
	private Customer accountCustomer;

	private Account _activeAccount;
	private final DaoDataModel<Account> _accountsSource;
	private final TableRowSelection<Account> _itemSelection;

	private boolean searchByObject = true;
	
	private ContextType ctxType;
	private String ctxItemEntityType;

	private static String COMPONENT_ID = "accountsTable";
	private String tabName;
	private String parentSectionId;
	private String privilege;
	private Map<String, Object> paramsMap;
	private String participantType;
	private String tabsName;
	private ArrayList<SelectItem> accountStatuses;

	public MbAccountsSearch() {
		tabsName = null;
		beanEntityType = EntityNames.ACCOUNT;
		_accountsSource = new DaoDataModel<Account>() {
			private static final long serialVersionUID = 7506648445762931473L;

			@Override
			protected Account[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Account[0];
				}
				if (getFilter().getObjectId() == null && searchByObject)
					return new Account[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setPrivilege(getPrivilege());
					return _accountsDao.getAccountsCur(userSessionId, params, getParamsMap());
				} catch (Exception e) {
					setDataSize(0);
					logger.error(e.getMessage(), e);
					FacesUtils.addMessageError(e);
				}
				return new Account[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				if (getFilter().getObjectId() == null && searchByObject)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setPrivilege(getPrivilege());
					return _accountsDao.getAccountsCountCur(userSessionId, getParamsMap());
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error(e.getMessage(), e);
				}
				return 0;
			}
		};
		_itemSelection = new TableRowSelection<Account>(null, _accountsSource);
		accountStatuses = getDictUtils().getArticles(DictNames.ACCOUNT_STATUS, false, false);
	}

	public DaoDataModel<Account> getAccounts() {
		return _accountsSource;
	}

	public Account getActiveAccount() {
		return _activeAccount;
	}

	public void setActiveAccount(Account activeAccount) {
		_activeAccount = activeAccount;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeAccount == null && _accountsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeAccount != null && _accountsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeAccount.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeAccount = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_accountsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAccount = (Account) _accountsSource.getRowData();
		selection.addKey(_activeAccount.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeAccount != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeAccount = _itemSelection.getSingleSelection();
		if (_activeAccount != null) {
			setInfo();
		}
	}

	public void setInfo() {
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void view() {

	}

	public void close() {

	}

	public void setFilters() {
		
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getAccountNumber() != null && filter.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_NUMBER");
			paramFilter.setValue(filter.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (getFilter().getEntityType() != null && !getFilter().getEntityType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("ENTITY_TYPE");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getEntityType());
			filters.add(paramFilter);
		}
		if (getFilter().getObjectId() != null && !getFilter().getObjectId().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("OBJECT_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getObjectId().toString());
			filters.add(paramFilter);
		}
		if (getFilter().getInstId() != null && !getFilter().getInstId().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getInstId());
			filters.add(paramFilter);
		}
		if (getFilter().getAccountType() != null && !getFilter().getAccountType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_TYPE");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getAccountType());
			filters.add(paramFilter);
		}
		if (getFilter().getStatus() != null && !getFilter().getStatus().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getStatus());
			filters.add(paramFilter);
		}
		if (getFilter().getCurrency() != null && !getFilter().getCurrency().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("CURRENCY");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getCurrency());
			filters.add(paramFilter);
		}
		if (getFilter().getCustomerId() != null){
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_ID");
			paramFilter.setValue(getFilter().getCustomerId());
			filters.add(paramFilter);
		}
		if (getFilter().getContractId() != null){
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_ID");
			paramFilter.setValue(getFilter().getContractId());
			filters.add(paramFilter);
		}
		if (getFilter().getCustomerNumber() != null &&
				getFilter().getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_NUMBER");
			paramFilter.setValue(filter.getCustomerNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (getFilter().getContractNumber() != null 
				&& !getFilter().getContractNumber().trim().isEmpty()){
			String contractNumber = getFilter().getContractNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_");
			filters.add(new Filter("CONTRACT_NUMBER", contractNumber));
		}
		if (getParticipantType() != null) {
			paramFilter = new Filter();
			
			filters.add(new Filter("PARTICIPANT_MODE",
					getParticipantType()));
		}
		getParamsMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
		if (tabsName != null){
			getParamsMap().put("tab_name", tabsName);
		}else{
			getParamsMap().put("tab_name", "ACCOUNT");
		}	
	}

	public Account getFilter() {
		if (filter == null)
			filter = new Account();
		return filter;
	}

	public void setFilter(Account filter) {
		this.filter = filter;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public ArrayList<SelectItem> getAccountStatuses() {
		return accountStatuses;
	}

	public void clearState() {
		_activeAccount = null;
		_itemSelection.clearSelection();
		_accountsSource.flushCache();
	}

	public Customer getAccountCustomer() {
		if (_activeAccount != null
				&& (accountCustomer == null || accountCustomer.getId()==null || !accountCustomer.getId().equals(
						_activeAccount.getCustomerId()))) {
			MbCustomersDependent customerBean = (MbCustomersDependent) ManagedBeanWrapper
					.getManagedBean("MbCustomersDependent");
			customerBean.getParams().setPrivilege(getPrivilege());
			accountCustomer = customerBean.getCustomer(_activeAccount.getCustomerId());
		}
		return accountCustomer;
	}

	public void clearFilter() {
		filter = new Account();
		clearState();
		searching = false;
	}

	public boolean isSearchByObject() {
		return searchByObject;
	}

	public void setSearchByObject(boolean searchByObject) {
		this.searchByObject = searchByObject;
	}

	public void addAdjustment() {
		MbOperationsBottom operBean = (MbOperationsBottom) ManagedBeanWrapper
				.getManagedBean("MbOperationsBottom");

		operBean.fullCleanBean();
		operBean.getAdjustmentFilter().setAccountNumber(_activeAccount.getAccountNumber());
		operBean.getAdjustmentFilter().setAcqInstId(_activeAccount.getInstId());
		operBean.getAdjustmentFilter().setSplitHash(_activeAccount.getSplitHash());
		operBean.getAdjustmentFilter().setOperationCurrency(_activeAccount.getCurrency());
		operBean.addAdjustment();
	}
	
	public String gotoAccounts() {
		String entity = getFilter().getEntityType();
		
		MbAccountsAllSearch accAllBean = (MbAccountsAllSearch) ManagedBeanWrapper.getManagedBean("MbAccountsAllSearch");
		accAllBean.getFilter().setAccountNumber(_activeAccount.getAccountNumber());
		accAllBean.getFilter().setInstId(null);
		accAllBean.setBackLink(backLink);
		accAllBean.setSearching(true);
		if (_activeAccount.getProductType() != null) {
			if (ProductConstants.ACQUIRING_PRODUCT.equals(_activeAccount.getProductType())) {
				accAllBean.setModule(ModuleNames.ACQUIRING);
				return "acquiring|accounts";
			} else if (ProductConstants.ISSUING_PRODUCT.equals(_activeAccount.getProductType())) {
				accAllBean.setModule(ModuleNames.ISSUING);
				return "issuing|accounts";
			} else if (ProductConstants.INSTITUTION_PRODUCT.equals(_activeAccount.getProductType())) {
				MbGLAccountsSearch glAccBean = (MbGLAccountsSearch) ManagedBeanWrapper.getManagedBean("MbGLAccountsSearch");
				glAccBean.clearFilter();
				glAccBean.getFilter().setAccountNumber(_activeAccount.getAccountNumber());
				glAccBean.getFilter().setInstId(null);
				glAccBean.setBackLink(backLink);
				glAccBean.setSearching(true);
				return "accounts|gl";
			}
		} else {
			if (EntityNames.MERCHANT.equals(entity) || EntityNames.TERMINAL.equals(entity)
					|| EntityNames.COMPANY.equals(entity)) {
				accAllBean.setModule(ModuleNames.ACQUIRING);
				return "acquiring|accounts";
			} else if (EntityNames.CARD.equals(entity) || EntityNames.PERSON.equals(entity)
					|| EntityNames.CUSTOMER.equals(entity) || EntityNames.UNDEFINED.equals(entity)) {
				accAllBean.setModule(ModuleNames.ISSUING);
				return "issuing|accounts";
			}
		}
		
		return "none";
	}
	
	public String getModule() {
		String entity = getFilter().getEntityType();
		if (EntityNames.MERCHANT.equals(entity) || EntityNames.TERMINAL.equals(entity)) {
			return "ACQ";
		} else if (EntityNames.CARD.equals(entity)) {
			return "ISS";
		} else if (EntityNames.CUSTOMER.equals(entity)) {
			return "ISS";
		}		
		
		return "none";
	}

	public Account loadAccount() {
		_activeAccount = null;

		setFilters();
		SelectionParams params = new SelectionParams();
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		
		try {
			Account[] accounts = _accountsDao.getAccounts(userSessionId, params);
			if (accounts.length > 0) {
				_activeAccount = accounts[0];
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _activeAccount;
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

		if (_activeAccount != null){
			if (EntityNames.ACCOUNT.equals(ctxItemEntityType)) {
				map.put("id", _activeAccount.getId());
				map.put("objectType", getObjectType(_activeAccount.getProductType()));
				map.put("instId", _activeAccount.getInstId());
				map.put("customerNumber", _activeAccount.getCustomerNumber());
				map.put("accountNumber", _activeAccount.getAccountNumber());
				if ("PRDT0100".equals(_activeAccount.getProductType())) {
					map.put("module", ModuleNames.ISSUING);
				} else if ("PRDT0200".equals(_activeAccount.getProductType())) {
					map.put("module", ModuleNames.ACQUIRING);
				}
			}
			if (EntityNames.CONTRACT.equals(ctxItemEntityType)) {
				map.put("id", _activeAccount.getContractId());
				map.put("instId", _activeAccount.getInstId());
				map.put("customerNumber", _activeAccount.getCustomerNumber());
				map.put("contractNumber", _activeAccount.getContractNumber());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return true;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
	public String getObjectType(String type){
		if(type == null) return null;
		if (type.equals("PRDT0100")) return "ACTP0100";
		if (type.equals("PRDT0200")) return "ACTP0200";
		return null;
	}
	
	public List<SelectItem> getAllAccountTypes() {
		 if (getFilter().getInstId() == null) {
			 return new ArrayList<SelectItem>();
		 }
		 Map<String, Object> paramMap = new HashMap<String, Object>();
		 paramMap.put("INSTITUTION_ID", getFilter().getInstId());
		 return getDictUtils().getLov(LovConstants.ACCOUNT_TYPES, paramMap);
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeAccount.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			Account[] accounts = _accountsDao.getAccounts(userSessionId, params);
			if (accounts != null && accounts.length > 0) {
				_activeAccount = accounts[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getPrivilege() {
		if(privilege == null){
			privilege = AccountPrivConstants.VIEW_ACCOUNT;
		}
		return privilege;
	}

	public void setPrivilege(String privilege) {
		this.privilege = privilege;
	}

	public Map<String, Object> getParamsMap() {
		if (paramsMap == null){
			paramsMap = new HashMap<String, Object>();
		}
		return paramsMap;
	}

	public void setParamsMap(Map<String, Object> paramsMap) {
		this.paramsMap = paramsMap;
	}

	public String getParticipantType() {
		return participantType;
	}

	public void setParticipantType(String participantType) {
		this.participantType = participantType;
	}

	public String getTabsName() {
		return tabsName;
	}

	public void setTabsName(String tabsName) {
		this.tabsName = tabsName;
	}
}
