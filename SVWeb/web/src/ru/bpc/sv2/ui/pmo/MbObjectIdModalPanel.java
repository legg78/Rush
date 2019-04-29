package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.application.ContractObject;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean(name="MbObjectIdModalPanel")
public class MbObjectIdModalPanel extends AbstractBean{
	private String entityType;
	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	private ProductsDao _productsDao = new ProductsDao();
	private AccountsDao _accountsDao = new AccountsDao();
	private IssuingDao _issuingDao = new IssuingDao();
	private AcquiringDao _acquiringDao = new AcquiringDao();

	private final TableRowSelection<Account> _accountsSelection;
	private Account _activeAccount;
	private Card _activeCard;
	private Customer _activeCustomer;
	private Terminal _activeTerminal;
	private Merchant _activeMerchant;
	private Integer instId;
	private Long customerId;
	private String customerNumber;
	private final TableRowSelection<Card> _cardsSelection;
	private final TableRowSelection<Customer> _customersSelection;
	private final TableRowSelection<Terminal> _terminalsSelection;
	private final TableRowSelection<Merchant> _merchantsSelection;

	private ContractObject filter;
	private DaoDataModel<Account> _accountsSource;
	private DaoDataModel<Card> _cardsSource;
	private DaoDataModel<Customer> _customersSource;
	private DaoDataModel<Terminal> _terminalsSource;
	private DaoDataModel<Merchant> _merchantsSource;

	private List<SelectItem> institutions;

	private HashMap<String, Object> paramMap;

	public MbObjectIdModalPanel(){
		_accountsSource = new DaoDataModel<Account>() {
			
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int count = 0;
				try {
					if (isSearching() && isAccount()) {
						setFilters();
						count = _accountsDao.getAccountsCountCur(userSessionId, getParamMap());
					}
				}catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}	
				return count;
			}
			
			@Override
			protected Account[] loadDaoData(SelectionParams params) {
				 Account[] result = new Account[0];
				if (isSearching() && isAccount()) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));					
						result = _accountsDao.getAccountsCur(userSessionId, params, paramMap);
					} catch (Exception e) {
						FacesUtils.addMessageError(e);
						setDataSize(0);
						logger.error("", e);
					}
				}
				
				return result;
			}
		};
		_accountsSelection = new TableRowSelection<Account>(null, _accountsSource);
		
		_cardsSource = new DaoDataModel<Card>() {
			
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int count = 0;
				if  (isSearching() && isCard()){
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						count = _issuingDao.getCardsCurCount(userSessionId, params, getParamMap());
					} catch (Exception e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return count;
			}
			
			@Override
			protected Card[] loadDaoData(SelectionParams params) {
				Card[] result = new Card[0];
					if (isSearching() && isCard()){
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						result = _issuingDao.getCardsCur(userSessionId, params, getParamMap());
					} catch (Exception e) {
						FacesUtils.addMessageError(e);
						setDataSize(0);
						logger.error("", e);
					}
				}
				return result;
			}
		};
		_cardsSelection = new TableRowSelection<Card>(null, _cardsSource);
		
		_customersSource = new DaoDataModel<Customer>() {
			
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (isSearching() && isCustomer()){
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						result = _productsDao.getCombinedCustomersCountProc(userSessionId, params,
								 "CUSTOMER");
					} catch (Exception e) {
						logger.error("", e);
						FacesUtils.addMessageError(e);
						return result;
					}
				}
				return result;
			}
			
			@Override
			protected Customer[] loadDaoData(SelectionParams params) {
				Customer []result = new Customer[0]; 
				if (isSearching() && isCustomer()){
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						result = _productsDao.getCombinedCustomersProc(userSessionId,
								params, "CUSTOMER");
					} catch (Exception e) {
						logger.error("", e);
						FacesUtils.addMessageError(e);
					}
				}
				return result;
			}
		};
		_customersSelection = new TableRowSelection<Customer>(null, _customersSource);

		_terminalsSource = new DaoDataModel<Terminal>() {

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int count = 0;
				try {
					if (isSearching() && isTerminal()) {
						setFilters();
						count =  _acquiringDao.getTerminalsCountCur(userSessionId, getParamMap());
					}
				}catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return count;
			}

			@Override
			protected Terminal[] loadDaoData(SelectionParams params) {
				Terminal[] result = new Terminal[0];
				if (isSearching() && isTerminal()) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						result = _acquiringDao.getTerminalsCur(userSessionId, params, paramMap);
					} catch (Exception e) {
						FacesUtils.addMessageError(e);
						setDataSize(0);
						logger.error("", e);
					}
				}

				return result;
			}
		};
		_terminalsSelection = new TableRowSelection<Terminal>(null, _terminalsSource);



		_merchantsSource = new DaoDataModel<Merchant>() {

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int count = 0;
				try {
					if (isSearching() && isMerchant()) {
						setFilters();
						count = _acquiringDao.getMerchantsCurCount(userSessionId, getParamMap());
					}
				}catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return count;
			}

			@Override
			protected Merchant[] loadDaoData(SelectionParams params) {
				Merchant[] result = new Merchant[0];
				if (isSearching() && isMerchant()) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						result = _acquiringDao.getMerchantsCur(userSessionId, params, paramMap);
					} catch (Exception e) {
						FacesUtils.addMessageError(e);
						setDataSize(0);
						logger.error("", e);
					}
				}

				return result;
			}
		};
		_merchantsSelection = new TableRowSelection<Merchant>(null, _merchantsSource);
	}
		
	private void setFilters(){
		filters = new ArrayList<Filter>();
		getFilter();
		if(instId != null){
			filters.add(new Filter("INST_ID", instId));
		}
		
		if (customerId != null && !isCustomer()){
			filters.add(new Filter("CUSTOMER_ID", customerId));
		}else if (customerId != null && isCustomer()){
			filters.add(new Filter("ID", customerId));
		}
		filters.add(Filter.create("LANG", userLang));
		if (isAccount()){
			if (StringUtils.isNotBlank(filter.getNumber())){
				filters.add(Filter.create("ACCOUNT_NUMBER", Filter.mask(filter.getNumber())));
			}
			getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
	        getParamMap().put("tab_name", "ACCOUNT");
		} else if (isCard()){
			if (StringUtils.isNotBlank(filter.getNumber())){
				filters.add(Filter.create("CARD_NUMBER", Filter.mask(filter.getNumber())));
			}
			getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
			getParamMap().put("tab_name", "CARD");
		} else if (isCustomer()){
			if (StringUtils.isNotBlank(filter.getNumber())){
				filters.add(Filter.create("CUSTOMER_NUMBER", Filter.mask(filter.getNumber())));
			}
		} else if (isTerminal()){
			if (StringUtils.isNotBlank(filter.getNumber())){
				filters.add(Filter.create("TERMINAL_NUMBER", Filter.mask(filter.getNumber())));
			}
			getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
			getParamMap().put("tab_name", "TERMINAL");
		} else if (isMerchant()) {
			if (StringUtils.isNotBlank(filter.getNumber())){
				filters.add(Filter.create("MERCHANT_NUMBER", Filter.mask(filter.getNumber(), false)));
			}
			getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
			getParamMap().put("tab_name", "MERCHANT");
		}
		
	}
	
	public DaoDataModel<Account> getAccounts(){
		return _accountsSource;
	}
	
	public DaoDataModel<Card> getCards(){
		return _cardsSource;
	}
	
	public DaoDataModel<Customer> getCustomers(){
		return _customersSource;
	}

	public DaoDataModel<Terminal> getTerminals(){
		return _terminalsSource;
	}

	public DaoDataModel<Merchant> getMerchants(){
		return _merchantsSource;
	}


	@Override
	public void clearFilter() {
		filters = new ArrayList<Filter>();
		entityType = null;
		filter =  new ContractObject();
	}
	
	public void search() {
		clearState();
		paramMap = new HashMap<String, Object>();
		searching = true;
	}
	
	public void clearState() {
		_accountsSelection.clearSelection();
		_activeAccount = null;
		_accountsSource.flushCache();
		_cardsSelection.clearSelection();
		_activeCard = null;
		_cardsSource.flushCache();
		_customersSelection.clearSelection();
		_activeCustomer = null;
		_customersSource.flushCache();
		_terminalsSelection.clearSelection();
		_activeTerminal = null;
		_terminalsSource.flushCache();
		_merchantsSelection.clearSelection();
		_activeMerchant = null;
		_merchantsSource.flushCache();
		curLang = userLang;
	}
	
	public String getEntityType() {
		return entityType;
	}
	
	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}
	
	public boolean isCustomer(){
		return EntityNames.CUSTOMER.equalsIgnoreCase(getEntityType());
	}
	
	public boolean isAccount(){
		return EntityNames.ACCOUNT.equalsIgnoreCase(getEntityType());
	}
	
	public boolean isCard(){
		return EntityNames.CARD.equalsIgnoreCase(getEntityType());
	}

	public boolean isTerminal(){
		return EntityNames.TERMINAL.equalsIgnoreCase(getEntityType());
	}

	public boolean isMerchant(){
		return EntityNames.MERCHANT.equalsIgnoreCase(getEntityType());
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

	public ContractObject getFilter() {
		if (filter == null){
			filter = new ContractObject();
		}
		return filter;
	}
	
	public Account getActiveAccount() {
		return _activeAccount;
	}
	
	public void setActiveAccount(Account activeAccount) {
		_activeAccount = activeAccount;
	}

	public void setFilter(ContractObject filter) {
		this.filter = filter;
	}
	
	public SimpleSelection getAccountSelection() {
		try {
			if (_activeAccount == null && _accountsSource.getRowCount() > 0) {
				setFirstAccountRowActive();
			} else if (_activeAccount != null && _accountsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeAccount.getModelId());
				_accountsSelection.setWrappedSelection(selection);
				_activeAccount = _accountsSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _accountsSelection.getWrappedSelection();
	}

	public void setFirstAccountRowActive() {
		_accountsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAccount = (Account) _accountsSource.getRowData();
		selection.addKey(_activeAccount.getModelId());
		_accountsSelection.setWrappedSelection(selection);
		
	}

	public void setAccountSelection(SimpleSelection selection) {
		_accountsSelection.setWrappedSelection(selection);
		_activeAccount = _accountsSelection.getSingleSelection();
	}
	
	


	
	
	
	public Card getActiveCard() {
		return _activeCard;
	}
	
	public void setActiveCard(Card activeCard) {
		_activeCard = activeCard;
	}
	
	public SimpleSelection getCardSelection() {
		try {
			if (_activeCard == null && _cardsSource.getRowCount() > 0) {
				setFirstCardRowActive();
			} else if (_activeCard != null && _cardsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCard.getModelId());
				_cardsSelection.setWrappedSelection(selection);
				_activeCard = _cardsSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _cardsSelection.getWrappedSelection();
	}

	public void setFirstCardRowActive() {
		_cardsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCard = (Card) _cardsSource.getRowData();
		selection.addKey(_activeCard.getModelId());
		_cardsSelection.setWrappedSelection(selection);
		
	}

	public void setCardSelection(SimpleSelection selection) {
		_cardsSelection.setWrappedSelection(selection);
		_activeCard = _cardsSelection.getSingleSelection();
	}
	
	
	
	
	
	
	
	public Customer getActiveCustomer() {
		return _activeCustomer;
	}
	
	public void setActiveCustomer(Customer activeCustomer) {
		_activeCustomer = activeCustomer;
	}
	
	public SimpleSelection getCustomerSelection() {
		try {
			if (_activeCustomer == null && _customersSource.getRowCount() > 0) {
				setFirstCustomerRowActive();
			} else if (_activeCustomer != null && _customersSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCustomer.getModelId());
				_customersSelection.setWrappedSelection(selection);
				_activeCustomer = _customersSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _customersSelection.getWrappedSelection();
	}

	public void setFirstCustomerRowActive() {
		_customersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCustomer = (Customer) _customersSource.getRowData();
		selection.addKey(_activeCustomer.getModelId());
		_customersSelection.setWrappedSelection(selection);
		
	}

	public void setCustomerSelection(SimpleSelection selection) {
		_customersSelection.setWrappedSelection(selection);
		_activeCustomer = _customersSelection.getSingleSelection();
	}



	public Terminal getActiveTerminal() {
		return _activeTerminal;
	}

	public void setActiveTerminal(Terminal activeTerminal) {
		_activeTerminal = activeTerminal;
	}

	public SimpleSelection getTerminalSelection() {
		try {
			if (_activeTerminal == null && _terminalsSource.getRowCount() > 0) {
				setFirstTerminalRowActive();
			} else if (_activeTerminal != null && _terminalsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeTerminal.getModelId());
				_terminalsSelection.setWrappedSelection(selection);
				_activeTerminal = _terminalsSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _terminalsSelection.getWrappedSelection();
	}

	public void setFirstTerminalRowActive() {
		_terminalsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTerminal = (Terminal) _terminalsSource.getRowData();
		selection.addKey(_activeTerminal.getModelId());
		_terminalsSelection.setWrappedSelection(selection);

	}

	public void setTerminalSelection(SimpleSelection selection) {
		_terminalsSelection.setWrappedSelection(selection);
		_activeTerminal = _terminalsSelection.getSingleSelection();
	}





	public Merchant getActiveMerchant() {
		return _activeMerchant;
	}

	public void setActiveMerchant(Merchant activeMerchant) {
		_activeMerchant = activeMerchant;
	}

	public SimpleSelection getMerchantSelection() {
		try {
			if (_activeMerchant == null && _merchantsSource.getRowCount() > 0) {
				setFirstMerchantRowActive();
			} else if (_activeMerchant != null && _merchantsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeMerchant.getModelId());
				_merchantsSelection.setWrappedSelection(selection);
				_activeMerchant = _merchantsSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _merchantsSelection.getWrappedSelection();
	}

	public void setFirstMerchantRowActive() {
		_merchantsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeMerchant = (Merchant) _merchantsSource.getRowData();
		selection.addKey(_activeMerchant.getModelId());
		_merchantsSelection.setWrappedSelection(selection);

	}

	public void setMerchantSelection(SimpleSelection selection) {
		_merchantsSelection.setWrappedSelection(selection);
		_activeMerchant = _merchantsSelection.getSingleSelection();
	}




	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}
	
	public void cancel(){
		clearState();
	}

	public Long getCustomerId() {
		return customerId;
	}

	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	public String getCustomerNumber() {
		return customerNumber;
	}

	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}

	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		return institutions;
	}
	
}
