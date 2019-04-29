package ru.bpc.sv2.ui.common.wizard.callcenter;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;

import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.Balance;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import util.auxil.SessionWrapper;

/**
 * "Result" step for "Balance" operation.
 * Work with any entities.
 * Accepts the following keys:
 * - ENTITY_TYPE
 * - OBJECT_ID 
 */
@ViewScoped
@ManagedBean (name = "MbBalanceRS")
public class MbBalanceRS implements CommonWizardStep{
	private static final Logger classLogger = Logger.getLogger(MbChangeLimitAmountRS.class);
	private static final String PAGE_CARD = "/pages/common/wizard/callcenter/balanceRS.jspx";
	private static final String PAGE_ACCOUNT = "/pages/common/wizard/callcenter/accBalanceRS.jspx";
	private static final String PAGE_BASE = "/pages/common/wizard/callcenter/balanceRsBase.jspx";
	private static final String OBJECT_ID = "OBJECT_ID";
	private static final String ENTITY_TYPE = "ENTITY_TYPE";
	
	private AccountsDao accountsDao = new AccountsDao();
	
	private Map<String, Object> context;
	private String entityType;
	private Long objectId;
	private Account account;
	private long userSessionId;
	private Balance[] balances;
	private List<BalanceRecord> balanceRecords;
	private String curLang;
	
	public class BalanceRecord {
		private final boolean isAccount;
		private final boolean isBalance;
		private Account account;
		private Balance balance;
		private List<BalanceRecord> children;
		
		public BalanceRecord(Account account){
			this.account = account;
			isAccount = true;
			isBalance = !isAccount;
		}
		public BalanceRecord(Balance balance){
			this.balance = balance;
			isBalance = true;
			isAccount = !isBalance;
		}
		public Account getAccount() {
			return account;
		}
		public Balance getBalance() {
			return balance;
		}
		public boolean getIsBalance(){
			return isBalance;
		}
		public boolean getIsAccount(){
			return isAccount;
		}
		public List<BalanceRecord> getChildren() {
			if (children == null){
				children = new LinkedList<BalanceRecord>();
			}
			return children;
		}
		public void setChildren(List<BalanceRecord> children) {
			this.children = children;
		}
		public Long getId(){
			if (isBalance){
				return balance.getId();
			} else {
				return account.getId();
			}
		}
		public String getNumber(){
			if (isBalance){
				if (balance.getBalanceNumber() != null){
					return balance.getBalanceNumber(); 
				} else {
					return balance.getBalanceType();
				}
				
			} else {
				return account.getAccountNumber();
			}
		}
	}
	
	
	@Override
	public void init(Map<String, Object> context) {
		classLogger.trace("init...");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = SessionWrapper.getField("language");		
		this.context = context;
		if (context.containsKey(ENTITY_TYPE)){
			entityType = (String) context.get(ENTITY_TYPE);
		} else {
			throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
		}
		if (context.containsKey(OBJECT_ID)){
			objectId = (Long) context.get(OBJECT_ID);
		} else {
			throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
		}
		
		if (EntityNames.CARD.equals(entityType)){
			context.put(MbCommonWizard.PAGE, PAGE_CARD);
		} else if (EntityNames.ACCOUNT.equals(entityType)){
			context.put(MbCommonWizard.PAGE, PAGE_ACCOUNT);
		} else {
			context.put(MbCommonWizard.PAGE, PAGE_BASE);
		}
		
		context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
		Account[] accounts = findAccounts();		
		prepareBalanceRecords(accounts);
		account = new Account();
	}

	private void prepareBalanceRecords(Account[] accounts){
		balanceRecords = new LinkedList<BalanceRecord>();
		for (Account account : accounts){
			BalanceRecord brAcc = new BalanceRecord(account);
			balanceRecords.add(brAcc);
			Balance[] balances = balancesByAccount(account);
			for (Balance balance : balances){
				BalanceRecord brBl = new BalanceRecord(balance);
				brAcc.getChildren().add(brBl);
			}
		}
	}
	
	private Balance[] balancesByAccount(Account account){
		SelectionParams sp = SelectionParams.build("accountId", account.getId());
		Balance[] result = accountsDao.getBalances(userSessionId, sp);
		return result;
	}
	
	private Account[] findAccounts(){
		classLogger.trace("findAccount...");
		Account[] result = null;
		if (EntityNames.ACCOUNT.equals(entityType)){
			SelectionParams sp = SelectionParams.build("id", objectId, "lang", curLang);
			result = accountsDao.getAccounts(userSessionId, sp);
		} else {
			SelectionParams sp = SelectionParams.build("entityType", entityType,
					"objectId", objectId, "lang", curLang);
			result = accountsDao.getAccountsByObject(userSessionId, sp);
		}
		return result;
	}
	
	public Balance[] getBalances(){
		return balances;
	}
	
	@Override
	public Map<String, Object> release(Direction direction) {
		classLogger.trace("findAccount...");
		return context;
	}

	@Override
	public boolean validate() {
		throw new UnsupportedOperationException();
	}

	public List<BalanceRecord> getNodeChildren(){
		BalanceRecord parent = balanceNode();
		if (parent == null){
			return balanceRecords;
		} else {
			return parent.getChildren();
		}
	}
	
	private BalanceRecord balanceNode(){
		return (BalanceRecord) Faces.var("balanceRec");
	}
	
	public boolean getNodeHasChildren(){
		BalanceRecord node = balanceNode();
		return (node.getChildren() != null && node.getChildren().size() != 0);
	}
	
	public Account getAccount() {
		return account;
	}

	public void setAccount(Account account) {
		this.account = account;
	}

}
