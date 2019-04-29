package ru.bpc.sv2.ui.common.wizard.callcenter;

import java.util.HashMap;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;

import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbAccDetailsStep")
public class MbAccDetailsStep implements CommonWizardStep{

	private static final Logger logger = Logger.getLogger(MbAccDetailsStep.class);
	private static final String PAGE = "/pages/common/wizard/callcenter/accDetailsStep.jspx";
	private static final String OBJECT_ID = "OBJECT_ID";
	public static final String ACCOUNT = "ACCOUNT";
	public static final String CUSTOMER = "CUSTOMER";
	public static final String ENTITY_TYPE = "ENTITY_TYPE";
	
	private AccountsDao accountsDao = new AccountsDao();
	
	private ProductsDao productsDao = new ProductsDao();
	
	private Map<String, Object> context;
	private Long objectId;
	private Account account;
	private long userSessionId;
	private String curLang;
	private Customer customer;
	
	public MbAccDetailsStep(){
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = SessionWrapper.getField("language");
	}
	
	@Override
	public void init(Map<String, Object> context) {
		logger.trace("init...");
		this.context = context;
		context.put(MbCommonWizard.PAGE, PAGE);
		if (context.containsKey(OBJECT_ID)){
			objectId = (Long)context.get(OBJECT_ID);
		} else {
			throw new IllegalStateException(OBJECT_ID +" is not defined in wizard context");
		}
		account = accountById(objectId);
		customer = customerByAccount(account);
	}

	private Account accountById(Long id){
		logger.trace("accountById...");
		Account result = null;
		SelectionParams sp = SelectionParams.build("id", id);
		Account[] accounts = accountsDao.getAccounts(userSessionId, sp);
		if (accounts.length != 0){
			result = accounts[0];
		}
		return result;
	}
	
	private Customer customerByAccount(Account acc){
		logger.trace("customerByAccount...");
		Customer result;
		//SelectionParams sp = SelectionParams.build("accountNumber", acc.getAccountNumber());
		SelectionParams sp = SelectionParams.build("ACCOUNT_NUMBER", account.getAccountNumber(), "LANG", curLang, "INST_ID", account.getInstId());
		sp.setSortElement(new SortElement[0]);
		Customer[] customers = productsDao.getCombinedCustomersProc(userSessionId, sp, "ACCOUNT");
		//Customer[] customers = productsDao.getAccountCustomers(userSessionId, sp, curLang);
		if (customers.length != 0){
			result = customers[0];
		} else {
			throw new IllegalStateException("Customer for account number:" + acc.getAccountNumber() + " is not found!");
		}
		Contract contract = null;
		sp = SelectionParams.build("CONTRACT_NUMBER", result.getContractNumber(), "LANG", curLang);
		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", sp.getFilters());
		paramsMap.put("tab_name", "CONTRACT");
		Contract[] contracts = productsDao.getContractsCur(userSessionId, sp, paramsMap);
		if (contracts.length > 0){
			contract = contracts[0];
			result.setContract(contract);
		} else {
			throw new IllegalStateException("Contract with number:" + result.getContractNumber() + " is not found!");
		}
		return result;
	}
	
	@Override
	public Map<String, Object> release(Direction direction) {
		logger.trace("release...");
		context.put(ACCOUNT, account);
		context.put(CUSTOMER, customer);
		context.put(ENTITY_TYPE, EntityNames.ACCOUNT);
		return context;
	}

	@Override
	public boolean validate() {
		logger.trace("validate...");
		return true;
	}

	public Account getAccount() {
		return account;
	}

	public void setAccount(Account account) {
		this.account = account;
	}

	public Customer getCustomer() {
		return customer;
	}

	public void setCustomer(Customer customer) {
		this.customer = customer;
	}

}
