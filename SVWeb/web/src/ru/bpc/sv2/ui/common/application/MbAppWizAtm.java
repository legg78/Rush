package ru.bpc.sv2.ui.common.application;

import org.ajax4jsf.model.KeepAlive;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.products.Service;
import ru.bpc.sv2.products.ServiceType;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.KeyLabelItem;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static ru.bpc.sv2.utils.AppStructureUtils.*;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbAppWizAtm")
public class MbAppWizAtm extends AbstractBean implements AppWizStep {
	private String page = "/pages/common/application/appWizAtm.jspx";
	private static final String ADD_TERMINAL = "ADD_ATM";
	private static final String ADD_ENCRYPTION = "ADD_ENCRYPTION";
	private static final String ATM_TYPE = "TRMT0002";
	private static final String DONT_CONNECT = "Don't connect";
	private Boolean serviceTypeValid;
	private Boolean accountValid;
	private String bind;
	private String unbind;
	private ApplicationWizardContext appWizCtx;
	private List<SelectItem>  bindAcc;
	private List<SelectItem>  unbindAcc;
	private boolean lock;
	private Boolean addressTypeLocked = true;
	private Account activeAcc;
	private Map<ApplicationElement, List<SelectItem>> terminalToAcc;
	private Map<ApplicationElement, List<SelectItem>> terminalToUnbindAcc;
	private ApplicationElement applicationRoot;
	private Map <ApplicationElement, List<ApplicationElement>> linkedMap;
	private DictUtils dictUtils;
	private Map<String,Service> terminalToService;
	private Map<Integer, ProductAttribute> attributesMap;
	private String language;
	private String userLanguage;
	private Long userSessionId;
	private int instId;
	private Map<Integer, ApplicationFlowFilter> applicationFilters;
	private ApplicationElement contractElement;
	private ApplicationElement customerElement;
	private List<ApplicationElement> accountElements;
	private Long productId;
	private List<ServiceType> serviceTypes;
	private List<Account> accountsList;
	private List<ApplicationElement> terminalElements;
	private List<ApplicationElement> merchantElements;
	private List<MenuTreeItem> leftMenu = null;
	private MenuTreeItem node;
	private TreePath nodePath;
	private MenuTreeItem newTerminalsGroup;
	private Map<String, ApplicationElement> fieldMap;
	private List<Service> services;
	private String selectedService;
	private Map <String, List<SelectItem>>lovMap;
	private List <SelectItem> servicesRadio;
	private List<ApplicationElement> encryptionElements;
	private Map <ApplicationElement, 
		Map<ApplicationElement, List<SelectItem>>> merchantToTermBind;
	private Map <ApplicationElement, 
		Map<ApplicationElement, List<SelectItem>>> merchantToTermUnbind;
	private boolean mainLock = true;
	
	ProductsDao productDao = new ProductsDao();
	ApplicationDao applicationDao = new ApplicationDao();
	AccountsDao accountDao = new AccountsDao();
	AcquiringDao _acquireDao = new AcquiringDao();

	@Override
	public ApplicationWizardContext release() {
		clearObjectAttr();
		releaseTerminals();
		releaseAccounts();
		customerElement = null;
		node = null;
		nodePath = null;
		dictUtils = null;
		appWizCtx.setLinkedMap(linkedMap);
		appWizCtx.setApplicationRoot(applicationRoot);
		applicationRoot = null;
		return appWizCtx;
	}
	
	private void releaseTerminals(){
		try {
			createServices();
		} catch (Exception e) {
		}
	}
	
	private void releaseAccounts(){
		for (int a = 0; a < merchantElements.size(); a++){
			ApplicationElement merchant = merchantElements.get(a);
			terminalElements = merchantElements.get(a).getChildrenByName(AppElements.TERMINAL);
			terminalToAcc = merchantToTermBind.get(merchant);
			if (terminalToAcc == null){
				continue;
			}
			List<SelectItem> listAccs = new ArrayList<SelectItem>();
			for (int i = 0; i < terminalElements.size(); i++){
				listAccs = terminalToAcc.get(terminalElements.get(i));
				if (listAccs != null){
					for (int j = 0; j < listAccs.size(); j++){
						Account acc = getAcc(listAccs.get(j).getLabel());
						ApplicationElement accEl = accExist(acc.getAccountNumber()); 
						if (accEl == null){
							try {
								createAcc(acc, terminalElements.get(i));				
							} catch (UserException e) {
								e.printStackTrace();
							}
						} else {
							
							try {
								ApplicationElement accountObj = new ApplicationElement();
								accountObj = addBl("ACCOUNT_OBJECT", accEl);
								fillAccountObjectBlock(accountObj, terminalElements.get(i), true);
							} catch (UserException e) {
								e.printStackTrace();
							}
						}
					}
				}
			}
		}
	}
	
	private Account getAcc(String accountNumber){
		for (int i = 0; i<accountsList.size(); i++){
			if(accountsList.get(i).getAccountNumber().equals(accountNumber)){
				return accountsList.get(i); 
			}
		}
		for (int i = 0; i<accountElements.size(); i++){
			
			String currenAccountNumber = accountElements.get(i).
					getChildByName("ACCOUNT_NUMBER", 1).getValueV();
			if (currenAccountNumber.equals(accountNumber)){
				Account acc = new Account();
				acc.setAccountNumber(currenAccountNumber);
				acc.setAccountType(accountElements.get(i).
						getChildByName("ACCOUNT_TYPE", 1).getValueV());
				acc.setCurrency(accountElements.get(i).
					getChildByName("CURRENCY", 1).getValueV());
				return acc;
			}
		}
		return null;
	}
	
	private ApplicationElement accExist(String accountNumber){
		for (int i = 0; i<accountElements.size(); i++){
			String currenAccountNumber = accountElements.get(i).
					getChildByName("ACCOUNT_NUMBER", 1).getValueV();
			if (currenAccountNumber.equals(accountNumber)){
				return accountElements.get(i);
			}
		}
		return null;
	}	
	
	private void createAcc(Account acc, ApplicationElement card) throws UserException{
		ApplicationElement accEl = new ApplicationElement(); 
				accEl = addBl(AppElements.ACCOUNT, contractElement);
		for (int i = 0; i < accEl.getChildren().size(); i++){
			if (accEl.getChildren().get(i).getName().equalsIgnoreCase("ACCOUNT_NUMBER")){
				accEl.getChildren().get(i).setValueV(acc.getAccountNumber());
			} else if(accEl.getChildren().get(i).getName().equalsIgnoreCase("ACCOUNT_TYPE")){
				accEl.getChildren().get(i).setValueV(acc.getAccountType());
			}  else if(accEl.getChildren().get(i).getName().equalsIgnoreCase("CURRENCY")){
				accEl.getChildren().get(i).setValueV(acc.getCurrency());
			}
		}
		ApplicationElement accountObj = addBl("ACCOUNT_OBJECT", accEl);
		fillAccountObjectBlock(accountObj, card, true);
	}
	
	private void fillAccountObjectBlock(ApplicationElement accountObjectBlock,
			ApplicationElement linkBlock, boolean isChecked){
		long flag = isChecked ? 1 : 0;
		accountObjectBlock.getChildByName("ACCOUNT_LINK_FLAG", 1).setValueN(
				BigDecimal.valueOf(flag));
		accountObjectBlock.setValueN(BigDecimal.valueOf(linkBlock.hashCode()));
		accountObjectBlock.setValueText(linkBlock.getBlockName());
		accountObjectBlock.setFake(true);
		List <ApplicationElement> listObjects = linkedMap.get(linkBlock);
		if (listObjects == null){
			listObjects = new ArrayList<ApplicationElement>();
		}
		listObjects.add(accountObjectBlock);
		linkedMap.put(linkBlock, listObjects);
	}
	
	public void deleteTerminal(){
		int id = ((MenuTreeItem)nodePath.
				getParentPath().getValue()).getInnerId() - 1;
		if (checkMinLimit(merchantElements.get(id))) return;
		revomeService(id);
		restructServices(id);
		removeElementFromApp(merchantElements.get(id), AppElements.TERMINAL, node.getInnerId());
		leftMenu.get(id).getItems().remove(node.getInnerId()-1);
		resetSelection(node, id);
		resetInnerId(merchantElements.get(id).
				getChildrenByName(AppElements.TERMINAL));
		createMenu();
		prepareDetailsFields();
	}
	
	private boolean checkMinLimit(ApplicationElement element){
		List <ApplicationElement> terminal = element.getChildrenByName(AppElements.TERMINAL);
		boolean result = (terminal.size() > 1);
		if (!result){
			FacesUtils.addMessageError("Cannot delete an element. The minimum limit is reached.");
		}
		return !result;
	}
	
	private void restructServices(int id){
		List <ApplicationElement>terminals = merchantElements.get(id).getChildrenByName(AppElements.TERMINAL);
		for (int i = node.getInnerId()-1; i < terminals.size() - 1; i++){
			for (ServiceType servType: serviceTypes){
				ApplicationElement oldTerminal = terminals.get(i);
				ApplicationElement terminal = terminals.get(i + 1);
				StringBuffer str = new StringBuffer();
				StringBuffer oldStr = new StringBuffer();
				str.append(getElemLabel(merchantElements.get(id), AppElements.MERCHANT));
				oldStr.append(str);
				str.append(getElemLabel(terminal, AppElements.TERMINAL))
				   .append(servType.getLabel());
				oldStr.append(getElemLabel(oldTerminal, AppElements.TERMINAL))
					  .append(servType.getLabel());
				String key = str.toString();
				String oldKey = oldStr.toString();
				terminalToService.remove(oldKey);
				if (terminalToService.containsKey(key)){
					Service serv = terminalToService.get(key);
					terminalToService.put(oldKey, serv);
				}
			}
		}
	}
	
	private void resetSelection(MenuTreeItem targetParen, int merchantId){
		int id = targetParen.getInnerId() - 1;
		if (id > 0){
			nodePath = new TreePath(leftMenu.get(merchantId).getItems().
					get(node.getInnerId()-2), null);
			node = leftMenu.get(merchantId).getItems().get(node.getInnerId()-2);
		} else {
			nodePath = new TreePath(leftMenu.get(merchantId).getItems().
					get(node.getInnerId()), null);
			node = leftMenu.get(merchantId).getItems().get(node.getInnerId());
		}
		
	}
	
	private void revomeService(int id){
		ApplicationElement merchant = merchantElements.get(id);
		ApplicationElement terminal = merchant 
				.getChildrenByName(
				AppElements.TERMINAL).get(node.getInnerId()-1);
		String merchantName = getElemLabel(merchant, AppElements.MERCHANT);
		for (ServiceType serviceType: serviceTypes){
			StringBuffer str = new StringBuffer();
			str.append(merchantName)
				.append(getElemLabel(terminal, AppElements.TERMINAL))
				.append(serviceType.getLabel());
			String key = str.toString();
			terminalToService.remove(key);
		}
		
	}
	
	private void createServices() throws Exception{
		for (int i = 0; i < merchantElements.size(); i++){
			terminalElements = merchantElements.get(i)
					.getChildrenByName(AppElements.TERMINAL);
			for (ApplicationElement terminal: terminalElements){
				for (ServiceType servType: serviceTypes){
					StringBuffer str = new StringBuffer();
					str.append(getElemLabel(merchantElements.get(i), AppElements.MERCHANT))
					   .append(getElemLabel(terminal, AppElements.TERMINAL))
					   .append(servType.getLabel());
					String key = str.toString();
					Service service = terminalToService.get(key);
					if(service != null){
						serviceToTerminal(service, terminal);
					}
				}
			}
		}
	}
	
	public String getBind() {
		if (bind != null){
			return (bind);
		} else {
			return new String();
		}
	}
	
	public String getLanguage(){
		return language;
	}
	
	public void setLanguage(String language){
		this.language = language;
	}

	public void setBind(String bind) {
		this.bind = bind;
		if (bind != null){
			activeAcc = getAcc(bind);
			setUnbind(null);
		}
	}

	public String getUnbind() {
		if (unbind != null){
			return (unbind);
		}else{
			return new String();
		}
	}

	public void setUnbind(String unbind) {
		this.unbind = unbind;
		if (unbind != null){
			activeAcc = getAcc(unbind);
			setBind(null);
		}
	}
	
	public Account getActiveAcc() {
		return activeAcc;
	}

	public void setActiveAcc(Account activeAcc) {
		this.activeAcc = activeAcc;
	}

	@Override
	public void init(ApplicationWizardContext ctx) {
		setServiceTypeValid(true);
		setAccountValid(true);
		lock = false;
		bind = new String("");
		unbind = new String("");
		appWizCtx = ctx;
		activeAcc = new Account();
		merchantToTermBind = new HashMap<ApplicationElement, 
				Map<ApplicationElement,List<SelectItem>>>();
		merchantToTermUnbind = new HashMap<ApplicationElement, 
				Map<ApplicationElement,List<SelectItem>>>();
		terminalToAcc = new HashMap<ApplicationElement, List<SelectItem>>();
		terminalToUnbindAcc = new HashMap<ApplicationElement, List<SelectItem>>();
		this.applicationRoot = ctx.getApplicationRoot();
		linkedMap = ctx.getLinkedMap();
		dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
		terminalToService = new HashMap<String, Service>();
		language = userLanguage = SessionWrapper.getField("language");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		ctx.setStepPage(page);
		instId = ((BigDecimal) applicationRoot.getChildByName("INSTITUTION_ID", 1).getValue()).intValue();
		applicationFilters = ctx.getApplicationFilters();
		customerElement = applicationRoot.retrive(AppElements.CUSTOMER);
		contractElement =  customerElement.retrive(AppElements.CONTRACT);
		accountElements = contractElement.getChildrenByName(AppElements.ACCOUNT);
		productId = ((BigDecimal) contractElement.getChildByName("PRODUCT_ID", 1).getValue()).longValue();
		getAccounts();
		fillServiceTypes();
		merchantElements = contractElement.getChildrenByName(AppElements.MERCHANT);
		for (int i = 0; i < merchantElements.size(); i++){
			terminalElements = merchantElements.get(i).getChildrenByName(AppElements.TERMINAL);
			if ( terminalElements.size() == 0){
				try {
					ApplicationElement terminal =
							addBl(AppElements.TERMINAL, merchantElements.get(i));
					terminal.getChildByName(AppElements.TERMINAL_TYPE, 1).setValueV(ATM_TYPE);
					addBl(AppElements.ENCRYPTION, terminal);
					addBl(AppElements.ATM_TERMINAL, terminal);
				} catch (UserException e) {
					}
			}
		}
		createMenu();
		prepareDetailsFields();
		
	}
	
	private void createMenu(){
		MenuTreeItem merchantsGroup = new MenuTreeItem();
		MenuTreeItem terminalsGroup;
		leftMenu = new ArrayList<MenuTreeItem>();
		for (int j = 0; j < merchantElements.size(); j++){
			StringBuffer merchantLabel = new StringBuffer(
					merchantElements.get(j).getShortDesc());
			merchantLabel.append(" - ");
			if (merchantElements.get(j).getChildByName(
					AppElements.MERCHANT_NUMBER, 1).getValueV() != null
					&&
				!merchantElements.get(j).getChildByName(
					AppElements.MERCHANT_NUMBER, 1).getValueV().equals("")){
				merchantLabel.append(merchantElements.get(j).
					getChildByName(AppElements.MERCHANT_NUMBER, 1).
						getValueV());
			}else {
				merchantLabel.append((merchantElements.
						get(j).getInnerId()));
			}
			merchantsGroup = new MenuTreeItem(
					merchantLabel.toString(),
					AppElements.MERCHANT,
					merchantElements.get(j).getInnerId());
			terminalElements = merchantElements.get(j).
					getChildrenByName(AppElements.TERMINAL);
			for (int i = 0; i < terminalElements.size(); i++){
				StringBuffer nodeLabel = new StringBuffer();
				if ((terminalElements.get(i)
						.getChildByName(AppElements.TERMINAL_NUMBER, 1)
							.getValueV() != null) &&
					(!terminalElements.get(i)
						.getChildByName(AppElements.TERMINAL_NUMBER, 1)
							.getValueV().equals(""))){
					nodeLabel.append(terminalElements.get(i).getShortDesc())
						.append(" - ")
						.append(terminalElements.get(i)
							.getChildByName(AppElements.TERMINAL_NUMBER, 1).getValueV());

				} else {
					nodeLabel.append(terminalElements.get(i).getShortDesc())
					.append(" - ")
					.append(terminalElements.get(i).getInnerId());
				}
				terminalsGroup = new MenuTreeItem(nodeLabel.toString(),
					AppElements.TERMINAL,
					terminalElements.get(i).getInnerId());

				if (serviceTypes != null){
					for (int b = 0; b < serviceTypes.size(); b++){
						MenuTreeItem serviceTypeItem = new MenuTreeItem
								( serviceTypes.get(b).getLabel(), AppElements.SERVICE_TYPE,
										b);
						terminalsGroup.getItems().add(serviceTypeItem);
					}
				}

				MenuTreeItem accountsItem = new MenuTreeItem(AppElements.ACCOUNT, AppElements.ACCOUNT, 1);
				MenuTreeItem addressesItem = new MenuTreeItem(AppElements.ADDRESS, AppElements.ADDRESS, 1);
				MenuTreeItem cassetteItem = new MenuTreeItem(AppElements.CASSETTE, AppElements.CASSETTE, 1);
				terminalsGroup.getItems().add(accountsItem);
				terminalsGroup.getItems().add(addressesItem);
				terminalsGroup.getItems().add(cassetteItem);
				encryptionElements = terminalElements.get(i).getChildrenByName(AppElements.ENCRYPTION);
				for (int n = 0; n < encryptionElements.size(); n++){
					StringBuffer encrLabel = new StringBuffer();
					if (encryptionElements.get(n).
							getChildByName(AppElements.ENCRYPTION_KEY, 1).
							getValueV() != null
							&&
							!encryptionElements.get(n).
							getChildByName(AppElements.ENCRYPTION_KEY, 1)
							.getValueV().equals("")){
						encrLabel.append(encryptionElements.get(n).getShortDesc())
								 .append(" - ")
								 .append(encryptionElements.get(n).
											getChildByName(AppElements.ENCRYPTION_KEY, 1).
											getValueV());
					}else{
						encrLabel.append(encryptionElements.get(n).getShortDesc())
						 .append(" - ")
						 .append(encryptionElements.get(n).getInnerId());
					}
					MenuTreeItem encriptionItem = new MenuTreeItem(
							encrLabel.toString(), AppElements.ENCRYPTION, encryptionElements.get(n).getInnerId());
					if ((n + 1) == encryptionElements.size()){
						encriptionItem.getItems().add(new MenuTreeItem("add new encryption", ADD_ENCRYPTION, 1));
					}
					terminalsGroup.getItems().add(encriptionItem);
				}
				merchantsGroup.getItems().add(terminalsGroup);

			}
			newTerminalsGroup = new MenuTreeItem("Add new atm", ADD_TERMINAL);
			merchantsGroup.getItems().add(newTerminalsGroup);
			leftMenu.add(merchantsGroup);
		}
		
		node = merchantsGroup.getItems().get(0);
		TreePath merchantPath = new TreePath(
			merchantsGroup.getItems().get(0), new TreePath(merchantsGroup, null));		
		nodePath = merchantPath;
	}
	
	public void prepareDetailsFields(){
		if (node != null) {
			prepareFieldMap();
			prepareLovMap();
		}
	}
	
	public void updateTerminalLabel(){
		node = (MenuTreeItem)nodePath.getValue();
		String number = fieldMap.get(AppElements.TERMINAL_NUMBER).getValueV();
		if (number != null && !number.equals("")){
			int id = ((MenuTreeItem)nodePath.getParentPath().getValue())
					.getInnerId() - 1;
			terminalElements = merchantElements.get(id).getChildrenByName(AppElements.TERMINAL);
			ApplicationElement terminal = terminalElements.get(node.getInnerId() -1 );
			StringBuffer label = new StringBuffer();
			for (ServiceType serv:serviceTypes){
				label = new StringBuffer();
				label.append(getElemLabel(merchantElements.get(id), AppElements.MERCHANT))
					 .append(node.getLabel())
					 .append(serv.getLabel());
				String key = label.toString();
				if (terminalToService.containsKey(key)){
					Service service = terminalToService.get(key);
					terminalToService.remove(key);
					label = new StringBuffer();
					label.append(getElemLabel(merchantElements.get(id), AppElements.MERCHANT))
						.append(terminal.getShortDesc())
						.append(" - ")
						.append(number)
						.append(serv.getLabel());
					key = label.toString();
					terminalToService.put(key, service);
				}
			}
			
			label = new StringBuffer();
			label.append(terminal.getShortDesc())
				.append(" - ")
				.append(number);
			((MenuTreeItem)nodePath.getValue()).setLabel(label.toString());
			node = (MenuTreeItem)nodePath.getValue(); 
			
		}
	}
	
	public Map<String, List<SelectItem>> getLovMap(){
		return lovMap;
	}
	
	public Map<String, ApplicationElement> getFieldMap(){
		return fieldMap;
	}
	
	public void addNewAtm(){
		clearObjectAttr();
		int merchantId = ((MenuTreeItem)nodePath.getParentPath()
				.getValue()).getInnerId() - 1;
		MenuTreeItem terminalGroup = new MenuTreeItem();
		ApplicationElement newTerminal = new ApplicationElement();
		try {
			newTerminal = addBl(AppElements.TERMINAL, merchantElements.get(merchantId));
			newTerminal.getChildByName(AppElements.TERMINAL_TYPE, 1).setValueV(ATM_TYPE);
			addBl(AppElements.ATM_TERMINAL, newTerminal);
		} catch (UserException e) {
			e.printStackTrace();
		}
		if (newTerminal != null){	
			terminalGroup = new MenuTreeItem(newTerminal.getShortDesc() + " - " 
					+ newTerminal.getInnerId().toString(), AppElements.TERMINAL, 
					newTerminal.getInnerId());
			if (serviceTypes != null){
				for (int b = 0; b < serviceTypes.size(); b++){
					MenuTreeItem serviceTypeItem = new MenuTreeItem
							( serviceTypes.get(b).getLabel(), AppElements.SERVICE_TYPE,
									b);
					terminalGroup.getItems().add(serviceTypeItem);
				}
			}
			ApplicationElement encrEl = new ApplicationElement();
			try {
				encrEl = addBl(AppElements.ENCRYPTION, newTerminal);
			} catch (UserException e) {
				e.printStackTrace();
			}
			MenuTreeItem accountsItem = new MenuTreeItem(AppElements.ACCOUNT, AppElements.ACCOUNT, 1);
			MenuTreeItem addressesItem = new MenuTreeItem(AppElements.ADDRESS, AppElements.ADDRESS, 1);
			MenuTreeItem cassetteItem = new MenuTreeItem(AppElements.CASSETTE, AppElements.CASSETTE, 1);
			StringBuffer encrLabel = new StringBuffer();
			encrLabel.append(encrEl.getShortDesc())
			 .append(" - ")
			 .append(encrEl.getInnerId());
			MenuTreeItem encriptionItem = new MenuTreeItem(encrLabel.toString(), AppElements.ENCRYPTION, 1);
			terminalGroup.getItems().add(accountsItem);
			terminalGroup.getItems().add(addressesItem);
			terminalGroup.getItems().add(cassetteItem);
			encriptionItem.getItems().add(new MenuTreeItem("add new encryption", ADD_ENCRYPTION, 1));
			terminalGroup.getItems().add(encriptionItem);
			leftMenu.get(merchantId).getItems().remove(
					leftMenu.get(merchantId).getItems().size() - 1);
			leftMenu.get(merchantId).getItems().add(terminalGroup);
			leftMenu.get(merchantId).getItems().add(newTerminalsGroup);
			node = terminalGroup;
			MenuTreeItem merchantItem = (MenuTreeItem)(nodePath.
					getParentPath().getValue());
			TreePath terminalPath = new TreePath(terminalGroup,
					new TreePath(merchantItem, null));		
			nodePath = terminalPath;
			terminalElements = merchantElements.get(merchantId).getChildrenByName(AppElements.TERMINAL); 
			prepareDetailsFields();
		}
	}
	
	public boolean isLock() {
		return lock;
	}

	public void setLock(boolean lock) {
		this.lock = lock;
	}
	
	public void addEncryption(){
		MenuTreeItem encryptionItem = (MenuTreeItem)(nodePath.getParentPath().getValue());
		MenuTreeItem terminalItem = (MenuTreeItem)(nodePath.getParentPath().getParentPath().getValue());
		MenuTreeItem merchantItem = (MenuTreeItem)(nodePath.
				getParentPath().getParentPath().getParentPath().getValue());
		int idMerchant = ((MenuTreeItem)
				(nodePath.getParentPath().getParentPath().getParentPath().getValue())).getInnerId() - 1;
		terminalElements = merchantElements.get(idMerchant).getChildrenByName(AppElements.TERMINAL);
		ApplicationElement terminal =  terminalElements.get(terminalItem.innerId - 1);
		if (checkMaxEncr(encryptionItem, terminal)){
			FacesUtils.addMessageError("Cannot add an element. The maximum limit is reached.");
			return;
		}
		ApplicationElement newEncr = null;
		try {
			newEncr = addBl(AppElements.ENCRYPTION, terminal);
		} catch (UserException e) {
			e.printStackTrace();
		}
		if (newEncr != null){
			encryptionItem.getItems().remove(0);
			StringBuffer str = new StringBuffer();
			str.append(newEncr.getShortDesc())
			   .append(" - ")
			   .append(newEncr.getInnerId());
			MenuTreeItem newEncItem = new MenuTreeItem(
					str.toString(), AppElements.ENCRYPTION, newEncr.getInnerId());
			newEncItem.getItems().add(new MenuTreeItem("add new encryption", ADD_ENCRYPTION, 1));
			terminalItem.getItems().add(newEncItem);
			nodePath = new TreePath(newEncItem, 
					new TreePath(terminalItem, 
							new TreePath(merchantItem, null)));
			node = newEncItem;
			prepareDetailsFields();
		}
	}
	
	private boolean checkMaxEncr(MenuTreeItem encryptionItem, ApplicationElement terminal){
		int countEncr = terminal.getChildByName(AppElements.ENCRYPTION, 0).getMaxCount();
		if (countEncr == (encryptionItem.getInnerId())){
			return true;
		}else{
			return false;
		}
	}
	
	public  List<SelectItem> getServicesRadio(){
		if (services != null){
			if (checkMandatory()){
			servicesRadio = new ArrayList<SelectItem>(services.size());
			} else{
				servicesRadio = new ArrayList<SelectItem>(services.size() + 1);
				servicesRadio.add(new SelectItem("-1", DONT_CONNECT));
			}
			for(Service value : services){
				servicesRadio.add(new SelectItem(value.getId().toString(), value.getLabel()));
			}
		return servicesRadio;
		}else return null;
	}
	
	public void updateAttr(){
		clearObjectAttr();
		int merchantId = ((MenuTreeItem)nodePath.getParentPath()
				.getParentPath().getValue()).getInnerId() - 1;
		StringBuffer label = new StringBuffer();
		label.append(getElemLabel(merchantElements.get(merchantId), AppElements.MERCHANT))
		   .append(((MenuTreeItem)nodePath.getParentPath().getValue()).getLabel())
		   .append(node.getLabel());
		String key = label.toString();
    	if (terminalToService.containsKey(key)){
    		terminalToService.remove(key);
    	}
		if ((selectedService != null) &&
				(Integer.parseInt(selectedService) > 0)){
			terminalToService.put(key, getService(selectedService));
			prepareAttr(getService());
		}else {
			terminalToService.put(key, null);
		}
	}
	
	private Service getService(String id){
		for (Service service:services){
			if (service.getId().toString().equalsIgnoreCase(id)) 
				return service;
		}
		return null;
	}
	
	private boolean checkMandatory(){
		for (Service service: services){
			List<Filter> filters = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("serviceId");
			paramFilter.setValue(service.getId());
			filters.add(paramFilter);
			
			paramFilter = new Filter();
			paramFilter.setElement("productId");
			paramFilter.setValue(productId);
			filters.add(paramFilter);
			
			SelectionParams params = new SelectionParams();
			params.setRowIndexStart(0);		
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			
			int count = productDao.getProductServiceMinCount(userSessionId, params);
			if (count > 0){
				return true;
			}
		}
		return false;
	}
	
	public void deleteEncr(){
		MenuTreeItem deleteItem = (MenuTreeItem)(nodePath.getValue());
		MenuTreeItem parentItem = (MenuTreeItem)(nodePath.getParentPath().getValue());
		if (checkMinCount(terminalElements.get(parentItem.getInnerId()-1),
				deleteItem.getName(), deleteItem.getInnerId())){
			return;
		}
		List<ApplicationElement> encrList = terminalElements.get(parentItem.getInnerId()-1).
			getChildrenByName(deleteItem.getName());
		removeElementFromApp(terminalElements.get(parentItem.getInnerId()-1),
							 AppElements.ENCRYPTION, deleteItem.getInnerId());
		resetInnerId(encrList);
		int deletedIndex = serviceTypes.size() 
				+ 1 + deleteItem.getInnerId();
		parentItem.getItems().remove(deletedIndex);
		Boolean haveCh = false;
		for(MenuTreeItem ch:parentItem.getItems()){
			if (ch.getItems() != null &&
					ch.getItems().size() > 0){
				haveCh = true;
				break;
			}
		}
		if (!haveCh){
			MenuTreeItem lastItem =	parentItem.
				getItems().get(parentItem.
						getItems().size() -1 );
			lastItem.getItems().add(new MenuTreeItem("add new encryption", ADD_ENCRYPTION, 1));
		}
	}
	
	private void resetInnerId(List <ApplicationElement>items){
		int count = 1;
		for(ApplicationElement item: items){
			item.setInnerId(count++);
		}
	}
	
	private void removeElementFromApp(ApplicationElement parent, String targetName, int innerId){
		ApplicationElement elementToDelete = retrive(parent, targetName, innerId);
		delete(elementToDelete, parent);
	}
	
	private boolean checkMinCount(ApplicationElement element, String name, int id){
		int sizeElem = element
			.getChildrenByName(name).size();
		int minCount = element.
			getChildByName(name, id).getMinCount();
		if ( minCount > (sizeElem -1)){
			FacesUtils.addMessageError("Cannot delete an element. The minimum limit is reached.");
			return true;
		}
		return false;
	}
	
	private void prepareFieldMap(){
		fieldMap = new HashMap<String, ApplicationElement>();
		
		if (AppElements.TERMINAL.equalsIgnoreCase(node.getName())){
			int id = ((MenuTreeItem)nodePath.getParentPath().
					getValue()).getInnerId() - 1;
			terminalElements = merchantElements.get(id).getChildrenByName(AppElements.TERMINAL);
			ApplicationElement terminal = terminalElements.get(node.getInnerId() - 1);
			for (int i = 0; i < terminal.getChildren().size(); i++){
				ApplicationElement terminalCh = terminal.getChildren().get(i);
				//if ((acc.getInfo() != null) && (acc.getInfo())){
				if((terminalCh.getName().equalsIgnoreCase(AppElements.TERMINAL_NUMBER))||
						(terminalCh.getName().equalsIgnoreCase(AppElements.TERMINAL_TYPE))){
					fieldMap.put(terminalCh.getName(), terminalCh);
				} else{if (terminalCh.getName().equalsIgnoreCase(AppElements.ATM_TERMINAL)){
					prepareAtmFields(terminalCh);
					}
				}
			}
			
		} else if (AppElements.SERVICE_TYPE.equalsIgnoreCase(node.getName())){
			int id = ((MenuTreeItem)nodePath.getParentPath().
					getParentPath().getValue()).getInnerId() - 1;
			ArrayList<Filter>filters = getServiceFilter(
					serviceTypes.get(node.getInnerId()).getId());
			String keyMerchant = getElemLabel(merchantElements.get(id), AppElements.MERCHANT);
			services = getServices(filters);
			StringBuffer label = new StringBuffer(keyMerchant);
			label.append(((MenuTreeItem)nodePath.getParentPath().getValue()).getLabel())
			   .append(node.getLabel());
			String key = label.toString();
			if (!terminalToService.containsKey(key)){
				selectedService = null;
				clearObjectAttr();
			}else{
				Service selected = terminalToService.get(key);
				if (selected == null){
					selectedService = "-1";
				}else{
					selectedService = String.valueOf(selected.getId());
				}
				if (!selectedService.equalsIgnoreCase("-1") ){
					prepareAttr(getService());
				}else{
					clearObjectAttr();
				}
			}
		} else if (AppElements.ADDRESS.equalsIgnoreCase(node.getName())){
			fildAddress();
		} else if (AppElements.ACCOUNT.equalsIgnoreCase(node.getName())){
			bindAcc = new ArrayList<SelectItem>();
			unbindAcc = new ArrayList<SelectItem>();
			fillAccsList();
		} else if (AppElements.CASSETTE.equalsIgnoreCase(node.getName())){
			int id = ((MenuTreeItem)nodePath.getParentPath().
					getParentPath().getValue()).getInnerId() - 1;
			int idTerminal = ((MenuTreeItem)nodePath.getParentPath().
					getValue()).getInnerId();
			ApplicationElement term = merchantElements.get(id)
					.getChildByName(AppElements.TERMINAL, idTerminal)
					.getChildByName(AppElements.ATM_TERMINAL, 1);
			fieldMap.put(term.getChildByName(AppElements.CASSETTE_COUNT, 1).getName(),
					term.getChildByName(AppElements.CASSETTE_COUNT, 1));
		} else if (AppElements.ENCRYPTION.equalsIgnoreCase(node.getName())){
			int id = ((MenuTreeItem)nodePath.getParentPath().
					getParentPath().getValue()).getInnerId() - 1;
			int idTerminal = ((MenuTreeItem)nodePath.getParentPath().
					getValue()).getInnerId() - 1;
			terminalElements = merchantElements.get(id).getChildrenByName(AppElements.TERMINAL);
			encryptionElements = terminalElements.get(idTerminal)
					.getChildrenByName(AppElements.ENCRYPTION);
			ApplicationElement encr = encryptionElements.get(node.getInnerId() - 1);
			for(ApplicationElement ch : encr.getChildren()){
				if (ch.getName().equalsIgnoreCase(AppElements.ENCRYPTION_KEY_LENGTH) ||
						ch.getName().equalsIgnoreCase(AppElements.ENCRYPTION_KEY_TYPE) ||
						ch.getName().equalsIgnoreCase(AppElements.ENCRYPTION_KEY)){
					fieldMap.put(ch.getName(), ch);
				}
			} 
		}
	}
	
	public void doUnbind(){
		for(int j = 0; j < bindAcc.size(); j++ ){
			if (bindAcc.get(j).getValue().equals(unbind)){
				unbindAcc.add(bindAcc.get(j));
				bindAcc.remove(j);
				break;
			}
		}
		unbind = new String("");
	}
	
	public void doBind(){
		for(int j = 0; j < unbindAcc.size(); j++ ){
			if (unbindAcc.get(j).getValue().equals(bind)){
				bindAcc.add(unbindAcc.get(j));
				unbindAcc.remove(j);
				break;
			}
		}
		bind = new String("");
	}
	
	private void prepareAtmFields(ApplicationElement terminal){
		for (ApplicationElement children: terminal.getChildren()){
			if (children.getInnerId() == 0){
				continue;
			}
			if (children.getName().equalsIgnoreCase("ATM_TYPE") ||
					children.getName().equalsIgnoreCase("ATM_TYPE") ){
				fieldMap.put(children.getName(), children);
			}
		}
	}
	
	private String getElemLabel(ApplicationElement element, String name){
		StringBuffer str = new StringBuffer(element.getShortDesc());
		str.append(" - ");
		StringBuffer strName = new StringBuffer(name);
		strName.append("_NUMBER");
		if (element.getChildByName(strName.toString(),
				1).getValueV() != null 
				&&
			!element.getChildByName(strName.toString(),
					1).getValueV().equals("")){
			str.append(element.getChildByName(strName.toString(),
					1).getValueV());
		}else{
			str.append(element.getChildByName(strName.toString(),
					1).getInnerId());
		}
		return str.toString();
	}
	
	private void clearObjectAttr(){
		@SuppressWarnings("deprecation")
		MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean("MbObjectAttributes");
		attrs.fullCleanBean();
	}
	
	@SuppressWarnings("deprecation")
	private void prepareAttr(Service service){
		MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean("MbObjectAttributes");
		attrs.fullCleanBean();
		attrs.setServiceId(service.getId());
		attrs.setEntityType(EntityNames.SERVICE);
		attrs.setInstId(instId);
		attrs.setProductType(service.getProductType());
	}	
	
	private Service getService(){
		Service result = null;
		for (int i = 0; i<services.size(); i++){
			int idService = services.get(i).getId().intValue();
			int idSelected = Integer.parseInt(selectedService);
			if (idService == idSelected){
				return services.get(i); 
			}
				
		}
		return result;
	}
	
	private ArrayList<Filter> getServiceFilter(int serviceTypeId){
		ArrayList<Filter> filters = new ArrayList<Filter>();
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLanguage);
		filters.add(f);
		f = new Filter("serviceTypeId", serviceTypeId);
		filters.add(f);
		f = new Filter("instId", instId);
		filters.add(f);
		return filters;
	}
	
	private List<Service> getServices(ArrayList<Filter> filters){
		SelectionParams params = new SelectionParams();
		params.setRowIndexStart(0);		
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		return Arrays.asList(productDao.getServicesByTerminalProduct(userSessionId, params));
	}
	
	private void fildAddress(){
		int idMerchant = ((MenuTreeItem)nodePath.getParentPath()
				.getParentPath().getValue()).getInnerId() - 1;
		int terminalInnert = ((MenuTreeItem)nodePath.getParentPath()
				.getValue()).getInnerId();
		ApplicationElement terminal = merchantElements.get(idMerchant)
				.getChildByName(AppElements.TERMINAL, terminalInnert);
		List<ApplicationElement>  addresses = terminal.getChildrenByName(AppElements.ADDRESS);
		if ((addresses == null) ||
				addresses.size() == 0){
			try {
				ApplicationElement newAddress = addBl(AppElements.ADDRESS, terminal);
				newAddress.getChildByName(AppElements.ADDRESS_TYPE, 1).setValueV("ADTPBSNA");
				addresses.add(newAddress);
			} catch (UserException e) {
			}
		}
		for (ApplicationElement address:addresses){
			for (ApplicationElement childrenEl: address.getChildren()){
				if ((!childrenEl.isComplex()) && 
						(!childrenEl.getName().equalsIgnoreCase(AppElements.COMMAND))){
					fieldMap.put(childrenEl.getName(), childrenEl);
				} else if(childrenEl.getName().equalsIgnoreCase(AppElements.ADDRESS_NAME)){
					prepareAddressName(childrenEl);
				}
			}
		}
	}
	
	private void prepareAddressName(ApplicationElement addressName){
		if (addressName.getInnerId() > 0){
		List<ApplicationElement> childrens = addressName.getChildren();
			for (ApplicationElement ch: childrens){
				fieldMap.put(ch.getName(), ch);
			}
		}
	}
	
	private void fillAccsList(){
		boolean removed = false;
		List<Account> newAcc = new ArrayList<Account>();
		int idMerchant = ((MenuTreeItem)nodePath.getParentPath().
				getParentPath().getValue()).getInnerId() - 1;
		int terminalInner = ((MenuTreeItem)nodePath.getParentPath().getValue()).getInnerId();
		ApplicationElement merchant = merchantElements.get(idMerchant);
		ApplicationElement currentTerminal = merchant
				.getChildByName(AppElements.TERMINAL, terminalInner);
		terminalToAcc = merchantToTermBind.get(merchant);
		terminalToUnbindAcc = merchantToTermUnbind.get(merchant);
		if (terminalToAcc != null && terminalToUnbindAcc != null){
			bindAcc = terminalToAcc.get(currentTerminal);
			unbindAcc = terminalToUnbindAcc.get(currentTerminal);
			if ((bindAcc != null) && 
					(unbindAcc != null)){
				return;
			}
		}
		terminalToAcc = new HashMap<ApplicationElement, List<SelectItem>>();
		terminalToUnbindAcc = new HashMap<ApplicationElement, List<SelectItem>>();
		bindAcc = new ArrayList<SelectItem>();
		unbindAcc = new ArrayList<SelectItem>();
		newAcc.addAll(accountsList);
		for(int i = 0; i< accountElements.size(); i++){
			List<ApplicationElement> object = accountElements.get(i).
					getChildrenByName("ACCOUNT_OBJECT");
			for(int j = 0; j<object.size(); j++){
				BigDecimal dataId = new BigDecimal(currentTerminal.getDataId());
				if (object.get(j).getValueN().compareTo(dataId) == 0){
					removeAcc(newAcc, accountElements.get(i));
					removed = true;
				}
			}
			if (!removed){
				String accNumb = accountElements.get(i).
						getChildByName("ACCOUNT_NUMBER", 1).getValueV();
				unbindAcc.add(new SelectItem(accNumb,accNumb));
			} else{
				removed = false;
			}
		}
		for (int i = 0; i<newAcc.size(); i++){
			unbindAcc.add(new SelectItem(newAcc.get(i).getAccountNumber(),
					newAcc.get(i).getAccountNumber()));
		}
		terminalToAcc.put(currentTerminal, bindAcc);
		terminalToUnbindAcc.put(currentTerminal, unbindAcc);
		merchantToTermBind.put(merchant, terminalToAcc);
		merchantToTermUnbind.put(merchant, terminalToUnbindAcc);
	}
	
	private void removeAcc(List<Account>listAcc, ApplicationElement account){
		for (int i = 0; i < listAcc.size(); i++){
			if (listAcc.get(i).getAccountNumber().equalsIgnoreCase(
					account.getChildByName("ACCOUNT_NUMBER", 1).getValueText())){
				bindAcc.add(new SelectItem(listAcc.get(i).getAccountNumber(),
						listAcc.get(i).getAccountNumber()));
				listAcc.remove(i);
				return;
			}
		}
	}
	
	public String getDetailsPage(){
		String result = SystemConstants.EMPTY_PAGE; 
		if (node != null){
			if (AppElements.TERMINAL.equals(node.getName())){
				result = "/pages/common/application/person/atmDetails.jspx";
			} else if (AppElements.SERVICE_TYPE.equals(node.getName())){
				result = "/pages/common/application/person/serviceTypeDetails.jspx";
			} else if (AppElements.ACCOUNT.equals(node.getName())){
				result = "/pages/common/application/person/accountCardDetails.jspx";
			} else if (AppElements.ADDRESS.equals(node.getName())){
				result = "/pages/common/application/person/addressDetails.jspx";
			} else if (AppElements.ENCRYPTION.equals(node.getName())){
				result = "/pages/common/application/person/encryptionDetails.jspx";
			} else if (AppElements.CASSETTE.equals(node.getName())){
				result = "/pages/common/application/person/cassetteDetails.jspx";
			} 
		}
		return result;
	}
	
	private void prepareLovMap(){
		lovMap = new HashMap<String, List<SelectItem>>();
		for (ApplicationElement element: fieldMap.values()){
			if(element.getLovId() != null){
					lovMap.put(element.getName(), 
							dictUtils.getLov(element.getLovId()));
			}
		}
	}
	
	private ApplicationElement addBl(String name, 
			ApplicationElement parent)throws UserException {
		ApplicationElement result = new ApplicationElement();
		try {
			result = instance(parent, name);
		} catch (IllegalArgumentException e) {
			throw new UserException(e);
		}
		Integer instId = applicationRoot.retrive(AppElements.INSTITUTION_ID).getValueN()
				.intValue();
		Application appStub = new Application();
		appStub.setInstId(instId);
		applicationDao.fillRootChilds(userSessionId, instId, result, applicationFilters);
		applicationDao.applyDependencesWhenAdd(userSessionId, appStub, result,
				applicationFilters);
		return result;
	}
	
	private void fillServiceTypes(){
		ArrayList<Filter> filter = setFilters();
		SelectionParams params = new SelectionParams();
		params.setRowIndexStart(0);		
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filter.toArray(new Filter[filter.size()]));
		int count = productDao.getServiceTypeByProductCount(userSessionId, params);
		if (count > 0){
			serviceTypes = Arrays.asList(productDao.getServiceTypeByProduct(userSessionId, params));
		} else {
			serviceTypes = new ArrayList<ServiceType>();
		}
	}
	
	private void serviceToTerminal(Service service, ApplicationElement terminal) throws Exception{
		ApplicationElement serviceBlock = null;
		try {
			serviceBlock = addBl(AppElements.SERVICE, contractElement);
		} catch (UserException e) {}
		if (serviceBlock == null){
			throw new Exception("Cannot add service!");
		}

		fillServiceBlock(service.getId(), serviceBlock);

		ApplicationElement serviceObjectBlock = null;
		serviceObjectBlock = addBl(AppElements.SERVICE_OBJECT, serviceBlock);
		if (serviceObjectBlock == null) {
			throw new Exception("Cannot add service object!");
		}

		fillServiceObjectBlock(service, serviceObjectBlock, terminal);
	}
	
	private void fillServiceBlock(Integer serviceId,
			ApplicationElement serviceBlock) throws Exception {
		if (serviceBlock.getLovId() != null) {
			KeyLabelItem[] lov = dictUtils.getLovItems(serviceBlock.getLovId()
					.intValue());
			serviceBlock.setLov(lov);
		}
		serviceBlock.setValueN(new BigDecimal(serviceId));
	}
	
	private void fillServiceObjectBlock(Service service,
			ApplicationElement serviceObjectBlock, ApplicationElement linkBlock)
			throws Exception {
		serviceObjectBlock.setValueN(BigDecimal.valueOf(linkBlock.hashCode()));
		serviceObjectBlock.setFake(true);
		serviceObjectBlock.setValueText(linkBlock.getBlockName());
		List <ApplicationElement> listObjects = linkedMap.get(linkBlock);
		if (listObjects == null){
			listObjects = new ArrayList<ApplicationElement>();
		}
		listObjects.add(serviceObjectBlock);
		linkedMap.put(linkBlock, listObjects);
			serviceObjectBlock.getChildByName(AppElements.START_DATE, 1).setValueD(
					new Date());
			ProductAttribute[] attrs = getAttribServise(service.getId()
					.intValue());
			for (ProductAttribute attr : attrs) {
				if (ProductAttribute.DEF_LEVEL_OBJECT
						.equals(attr.getDefLevel())) {
					addAttribute(attr.getId(), serviceObjectBlock, true);
				}
			}
	}
	
	public void addAttribute(Integer attrId, ApplicationElement parent,
			boolean wizard) throws Exception {
		if (attributesMap == null) {
			throw new Exception("Cannot get attribute parameters from DB");
		}
		ProductAttribute attr = attributesMap.get(attrId);
		if (attr == null) {
			throw new Exception("Cannot get attribute parameters from cache");
		}
		ApplicationElement attrBlock = null;

		if (attr.isChar()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_CHAR, parent);
		} else if (attr.isNumber()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_NUMBER, parent);
		} else if (attr.isDate()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_DATE, parent);
		} else if (attr.isCycle()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_CYCLE, parent);
		} else if (attr.isLimit()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_LIMIT, parent);
		} else if (attr.isFee()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_FEE, parent);
		}
		if (attrBlock == null) {
			throw new Exception("Cannot add attribute");
		}
		if (attr.getLovId() != null) {
			setAttributeLov(attr, attrBlock);
		}
		attrBlock.setValueN(new BigDecimal(attrId));
		attrBlock.setValueText(attr.getLabel());
		attrBlock.setFake(true);
		attrBlock.setWizard(wizard);
	}
	
	private void setAttributeLov(ProductAttribute attr, ApplicationElement attrBlock) {
		KeyLabelItem[] lov = dictUtils.getLovItems(attr.getLovId().intValue());
		ApplicationElement attributeValueEl = null;
		if (attr.isChar()) {
			attributeValueEl = attrBlock.getChildByName(AppElements.ATTRIBUTE_VALUE_CHAR, 1);
		} else if (attr.isNumber()) {
			attributeValueEl = attrBlock.getChildByName(AppElements.ATTRIBUTE_VALUE_NUM, 1);
		} else if (attr.isDate()) {
			attributeValueEl = attrBlock.getChildByName(AppElements.ATTRIBUTE_VALUE_DATE, 1);
		}

		if (attributeValueEl != null) {
			attributeValueEl.setLovId(attr.getLovId().intValue());
			attributeValueEl.setLov(lov);
		}
	}
	
	private ProductAttribute[] getAttribServise(int serviceId){
		if (serviceId > 0){
			SelectionParams params = new SelectionParams();
			List<Filter> filters = setFilterForAttr();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexStart(0);
			params.setRowIndexEnd(Integer.MAX_VALUE);
	    	ProductAttribute[] attrs = null;
	    	attrs = productDao.getServiceAttributes(userSessionId, params);
	    	if (attributesMap == null) {
				attributesMap = new HashMap<Integer, ProductAttribute>();
			}
	    	
	    	for (ProductAttribute attr : attrs) {
				attributesMap.put(attr.getId(), attr);
			}
	    	return attrs;
		}
		return null;
	}
	
	private List <Filter> setFilterForAttr(){
		List<Filter> filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("instId");
		paramFilter.setValue(instId);
		filters.add(paramFilter);
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(language);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("entityType");
		paramFilter.setValue(EntityNames.SERVICE);
		filters.add(paramFilter);
			

		paramFilter = new Filter();
		paramFilter.setElement("serviceId");
		paramFilter.setValue(selectedService);
		filters.add(paramFilter);
		
		return filters;
	}
	
	private ArrayList<Filter> setFilters(){
		ArrayList<Filter> result = new ArrayList<Filter>(3);
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLanguage);
		result.add(f);
		f = new Filter();
		f.setElement("productId");
		f.setValue(productId);
		result.add(f);
		f = new Filter();
		f.setElement("entityType");
		f = new Filter("entityType", "ENTTTRMN");
		result.add(f);
		return result;
	}
	
	public Boolean getServiceTypeValid() {
		return serviceTypeValid;
	}

	public void setServiceTypeValid(Boolean serviceTypeValid) {
		this.serviceTypeValid = serviceTypeValid;
	}
	
	public Boolean getAccountValid() {
		return accountValid;
	}

	public void setAccountValid(Boolean accountValid) {
		this.accountValid = accountValid;
	}
	
	public String getSelectedService() {
		return selectedService;
	}

	public void setSelectedService(String selectedService) {
		this.selectedService = selectedService;
	}
	
	public int getUnbindAccsize(){
		return unbindAcc.size();
	}
	
	public int getBindAccsize(){
		return bindAcc.size();
	}
	
	private void getAccounts(){
		ArrayList<Filter> filter = new ArrayList<Filter>();
		Filter f = new Filter();
		
		f = new Filter("productId", productId);			
		filter.add(f);
		
		f = new Filter("lang",language);
		filter.add(f);
		
		SelectionParams params = new SelectionParams();
		params.setRowIndexStart(0);		
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filter.toArray(new Filter[filter.size()]));
		int count = accountDao.getAcqAccountsCount(userSessionId, params);
		if (count > 0){
			accountsList = Arrays.asList(accountDao.getIssAccounts(userSessionId, params));
			
		} else {
			accountsList = new ArrayList<Account>();
		}
	}
	
	public List<MenuTreeItem> getNodeChildren(){
		MenuTreeItem treeNode = treeNode();
		if (treeNode == null){
			return leftMenu;
		} else {
			return treeNode.getItems();
		}
	}
	
	public boolean getNodeHasChildren(){
		MenuTreeItem treeNode = treeNode();
		return !treeNode.getItems().isEmpty();
	}
	public MenuTreeItem treeNode(){
		return (MenuTreeItem) Faces.var("item");
	}
	
	public List<SelectItem> getBindAcc() {
		return bindAcc;
	}

	public void setBindAcc(List<SelectItem> bindAcc) {
		this.bindAcc = bindAcc;
	}

	public List<SelectItem> getUnbindAcc() {
		return unbindAcc;
	}

	public void setUnbindAcc(List<SelectItem> unbindAcc) {
		this.unbindAcc = unbindAcc;
	}
	
	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}
	
	public TreePath getNodePath(){
		return nodePath;
	}
	
	public Boolean getAddressTypeLocked() {
		return addressTypeLocked;
	}

	public void setAddressTypeLocked(Boolean addressTypeLocked) {
		this.addressTypeLocked = addressTypeLocked;
	}
	
	public MenuTreeItem getNode(){
		return node;
	}
	
	public void setNode(MenuTreeItem node){
		this.node = node;
	}

	@Override
	public boolean validate() {
		boolean valid = true;
		valid = validateTerminals();
		return valid;
	}
	
	private boolean validateTerminals(){
		boolean mainValid = true;
		boolean valid;
		boolean validTree;
		
		for (int i = 0; i < merchantElements.size(); i++){
			List <ApplicationElement>
				terminals = merchantElements.get(i).getChildrenByName(AppElements.TERMINAL);
		
			for (ApplicationElement terminal: terminals){
				validTree = true;
				for (int j = 0; j < terminal.getChildren().size(); j++){
					valid = true;
					ApplicationElement terminalCh = terminal.getChildren().get(j);
					if (terminalCh.getInnerId() == 0){
						continue;
					}
					//if ((accCh.getInfo() != null) 
						//	&& (acc.getInfo())
						//	&& (acc.isRequired())){
						if(((terminalCh.getName().equalsIgnoreCase(AppElements.TERMINAL_NUMBER)||
								terminalCh.getName().equalsIgnoreCase(AppElements.TERMINAL_TYPE)) && 
									(terminalCh.isRequired()))){
							 valid &= terminalCh.validate();
							 mainValid &= valid;
							 terminalCh.setValid(valid);
							 validTree &= valid;
						} else if (terminalCh.getName().equalsIgnoreCase(AppElements.ENCRYPTION)){
							validateEncr(terminalCh, terminal, merchantElements.get(i));
						} else if (terminalCh.getName().equalsIgnoreCase(AppElements.ATM_TERMINAL)){
							mainValid &= validateAtm(
									terminalCh, terminal, merchantElements.get(i));
						}
						
				}
				leftMenu.get(i).getItems().
					get(terminal.getInnerId()-1).setValid(validTree);
				mainValid &= checkService(terminal, merchantElements.get(i));
				mainValid &= checkAccount(terminal, merchantElements.get(i));
				mainValid &= checkAddresses(terminal, merchantElements.get(i));
			}
		}
		return mainValid;
	}
	
	private boolean validateAtm(ApplicationElement atm, 
			ApplicationElement terminal,
			ApplicationElement merchant){
		boolean mainValid = true;
		for (ApplicationElement ch:atm.getChildren()){
			if (ch.getName().equalsIgnoreCase(ATM_TYPE) &&
					ch.isRequired()){
				boolean valid = ch.validate();
				ch.setValid(valid);
				mainValid &= valid;
			}else if (ch.getName().equalsIgnoreCase(AppElements.CASSETTE_COUNT) &&
					ch.isRequired()){
				boolean cassetteValid = ch.validate();
				ch.setValid(cassetteValid);
				leftMenu.get(merchant.getInnerId() - 1)
						.getItems().get(terminal.getInnerId() - 1)
						.getItems().get(serviceTypes.size() + 1 + ch.getInnerId())
						.setValid(cassetteValid);
			}
		}
		
		return mainValid;
	}
	
	private void validateEncr(ApplicationElement encrEl, 
			ApplicationElement terminal,
			ApplicationElement merchant){
		Boolean mainValid = true;
		Boolean valid;
		for(int i = 0; i < encrEl.getChildren().size(); i++){
			ApplicationElement encChild = encrEl.getChildren().get(i);
			if (encChild.getName().equalsIgnoreCase(AppElements.ENCRYPTION_KEY_LENGTH) ||
					encChild.getName().equalsIgnoreCase(AppElements.ENCRYPTION_KEY_TYPE)){
				valid = encChild.validate();
				mainValid &= valid;
				encChild.setValid(valid);
			}
		}
		leftMenu.get(merchant.getInnerId() - 1).getItems()
				.get(terminal.getInnerId() - 1).getItems()
				.get(serviceTypes.size() + 2 + encrEl.getInnerId()).setValid(mainValid);
	}
	
	private boolean checkService(ApplicationElement terminal, 
			ApplicationElement merchant){
		boolean mainValid = true;
		for (int i = 0; i < serviceTypes.size(); i++){
			boolean valid;
			StringBuffer str = new StringBuffer();
			str.append(getElemLabel(merchant, AppElements.MERCHANT));
			if ((terminal.getChildByName(AppElements.TERMINAL_NUMBER, 1)
					.getValueV() != null) && 
				(!terminal.getChildByName(AppElements.TERMINAL_NUMBER, 1)
					.getValueV().equals(""))){
				str.append(terminal.getShortDesc()).append(" - ")
					.append(terminal.getChildByName(AppElements.TERMINAL_NUMBER, 1)
						.getValueV())
					.append(serviceTypes.get(i).getLabel());
			} else{
				str.append(terminal.getShortDesc()).append(" - ")
				.append(terminal.getInnerId())
				.append(serviceTypes.get(i).getLabel());
			}
			String key = str.toString();
			valid = terminalToService.containsKey(key);			
			mainValid &= valid;
			leftMenu.get(merchant.getInnerId()-1).getItems()
				.get(terminal.getInnerId()-1).getItems()
				.get(i).setValid(valid);
		}
		return mainValid;
	}
	
	private boolean checkAddresses(ApplicationElement terminal,
			ApplicationElement merchant){
		boolean mainValid = true;
		ApplicationElement address = terminal.getChildByName(AppElements.ADDRESS, 1);
		if (address == null){
			try {
				address = addBl(AppElements.ADDRESS, terminal);
				address.
					getChildByName(AppElements.ADDRESS_TYPE, 1).
					setValueV("ADTPBSNA");
				mainValid = false;
			} catch (UserException e) {
			}
		}
		for (ApplicationElement addressEl: address.getChildren()){
			if(address.getName().endsWith(AppElements.ADDRESS_NAME)){
				mainValid &= checkAddressName(addressEl);
			}else if (addressEl.isRequired()){
				boolean valid;
				valid = addressEl.validate();
				addressEl.setValid(valid);
				mainValid &= valid;
			}
				
		}
		leftMenu.get(merchant.getInnerId()-1).getItems()
				.get(terminal.getInnerId()-1).getItems().
				get(serviceTypes.size() + 1).setValid(mainValid);
		return mainValid;
	}
	
	private boolean checkAddressName(ApplicationElement address){
		boolean mainValid = true;
		for(ApplicationElement addressName: address.getChildrenByName(AppElements.ADDRESS_NAME)){
			boolean valid;
			if (addressName.isRequired()){
				valid = addressName.validate();
				addressName.setValid(valid);
				mainValid &= valid;
			}
		}
		
		return mainValid;
	}
	
	private boolean checkAccount(ApplicationElement terminal,
			ApplicationElement merchant){
		terminalToAcc = merchantToTermBind.get(merchant);
		boolean mainValid = true;
		if (terminalToAcc == null){
			mainValid = false;
		}else{
			List<SelectItem> accs = terminalToAcc.get(terminal);
			if (accs == null || accs.size() == 0){
				mainValid = false;
			}
		}	
		leftMenu.get(merchant.getInnerId() - 1).getItems()
			.get(terminal.getInnerId()-1).getItems()
			.get(serviceTypes.size()).setValid(mainValid);
		setAccountValid(mainValid);
		return mainValid;
	}

	@Override
	public boolean checkKeyModifications() {
		// TODO Auto-generated method stub
		return false;
	}
	
	public static class MenuTreeItem{
		private String label;
		private String name;
		private int innerId = 0;
		private String modelId;
		private boolean valid = true;
		private List<MenuTreeItem> items;
		private String cssClass;
		
		public MenuTreeItem(){
			
		}
		
		public MenuTreeItem(String name, Integer innerId){
			this(null, name, innerId);
		}	
		
		public MenuTreeItem(String label, String name){
			this(label, name, 0);
		}
		
		public MenuTreeItem(String label, String name, int innerId){
			this.label = label;
			this.name = name;
			this.innerId = innerId;
		}
		
		public MenuTreeItem(String label, String name, String cssClass){
			this(label, name, 0);
			this.cssClass = cssClass;
		}
		
		public String getLabel() {
			return label;
		}
		
		public void setLabel(String label) {
			this.label = label;
		}
		
		public String getName() {
			return name;
		}
		
		public void setName(String name) {
			this.name = name;
		}
		
		public boolean isValid() {
			return valid;
		}

		public void setValid(boolean valid) {
			this.valid = valid;
		}
		
		public List<MenuTreeItem> getItems() {
			if (items == null){
				items = new ArrayList<MenuTreeItem>();
			}
			return items;
		}
		
		public void setItems(List<MenuTreeItem> items) {
			this.items = items;
		}
		public int getInnerId() {
			return innerId;
		}

		public void setInnerId(int innerId) {
			this.innerId = innerId;
			updateModelId();
		}
		
		private void updateModelId(){
			modelId = name + innerId;
		}
		
		public int getModelId(){
			if (modelId == null){
				updateModelId();
			}
			return modelId.hashCode();
		}
		
		public String getCssClass() {
			return cssClass;
		}

		public void setCssClass(String cssClass) {
			this.cssClass = cssClass;
		}
		
	}

	@Override
	public boolean getLock() {
		return mainLock;
	}
	
		@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}

}
