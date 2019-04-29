package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.HashMap;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbWzAccDetails")
public class MbWzAccDetails {
	private static final Logger classLogger = Logger.getLogger(MbWzAccDetails.class);

	private AccountsDao accountsDao = new AccountsDao();

	private ProductsDao productsDao = new ProductsDao();

	private Customer customer;
	private Account account;
	private String curLang;
	private long userSessionId;

	public void init(Long accountId) {
		classLogger.trace("init...");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = SessionWrapper.getField("language");
		account = accountById(accountId);
		if (account != null)
			customer = customerByAccount(account);
	}

	private Account accountById(Long id) {
		classLogger.trace("accountById...");
		Account result = null;
		SelectionParams sp = SelectionParams.build("id", id);
		Account[] accounts = accountsDao.getAccounts(userSessionId, sp);
		if (accounts.length != 0) {
			result = accounts[0];
		} else
			FacesUtils.addErrorExceptionMessage(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acc", "account_not_found") + ": " + id);
		return result;
	}

	private Customer customerByAccount(Account acc) {
		classLogger.trace("customerByAccount...");
		Customer result;
		SelectionParams sp = SelectionParams.build("ACCOUNT_NUMBER", account.getAccountNumber(), "LANG", curLang, "INST_ID", account.getInstId());
		sp.setSortElement();
		Customer[] customers = productsDao.getCombinedCustomersProc(userSessionId, sp, "ACCOUNT");
		if (customers.length != 0) {
			result = customers[0];
		} else {
			throw new IllegalStateException("Customer for account number:" + acc.getAccountNumber() + " is not found!");
		}
		Contract contract;
		sp = SelectionParams.build("CONTRACT_NUMBER", result.getContractNumber(), "LANG", curLang);
		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", sp.getFilters());
		paramsMap.put("tab_name", "CONTRACT");
		Contract[] contracts = productsDao.getContractsCur(userSessionId, sp, paramsMap);
		if (contracts.length > 0) {
			contract = contracts[0];
			result.setContract(contract);
		} else {
			throw new IllegalStateException("Contract with number:" + result.getContractNumber() + " is not found!");
		}
		return result;
	}

	public Customer getCustomer() {
		return customer;
	}

	public Account getAccount() {
		return account;
	}
}
