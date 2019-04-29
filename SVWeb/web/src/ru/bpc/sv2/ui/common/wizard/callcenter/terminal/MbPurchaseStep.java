package ru.bpc.sv2.ui.common.wizard.callcenter.terminal;

import org.apache.log4j.Logger;
import org.ifxforum.xsd._1.*;
import ru.bpc.sv.svip.SVIP;
import ru.bpc.sv.svip.SVIP_Service;
import ru.bpc.sv.ws.handlers.soap.SOAPLoggingHandler;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.ws.Binding;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.handler.Handler;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbPurchaseStep")
public class MbPurchaseStep implements CommonWizardStep{

	private static final Logger logger = Logger.getLogger(MbPurchaseStep.class);
	
	private static final String PAGE = "/pages/common/wizard/callcenter/terminal/purchaseStep.jspx";
	private static final String OBJECT_ID = "OBJECT_ID";
	public static final String TERMINAL = "TERMINAL";
	public static final String MERCHANT = "MERCHANT";
	public static final String CUSTOMER = "CUSTOMER";
	public static final String FAULT_STRING = "FAULT_STRING";
	
	private AcquiringDao acquiringDao = new AcquiringDao();
	
	private ProductsDao productsDao = new ProductsDao();

	private CommonDao commonDao = new CommonDao();
	
	private Map<String, Object> context;	
	
	private Long objectId;
	private Terminal terminal;
	private Merchant merchant;
	private Customer customer;
	private long userSessionId;
	private String curLang;
	private String currency;
	private String cardNumber;
	private BigDecimal amount;
	
	private SVIP port;
	
	public MbPurchaseStep(){
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = SessionWrapper.getField("language");
	}
	
	@Override
	public void init(Map<String, Object> context) {
		logger.trace("init...");
		reset();
		this.context = context;
		context.put(MbCommonWizard.PAGE, PAGE);
		if (context.containsKey(OBJECT_ID)){
			objectId = (Long)context.get(OBJECT_ID);
		} else {
			throw new IllegalStateException("OBJECT_ID is not defined in wizard context");
		}
		try {
			initWs();
		} catch (Exception e) {
			throw new IllegalStateException("Could not initialize SVIP Port");
		}
		setTerminal(retriveTerminal(objectId));
		setCustomer(retriveCustomer(terminal));
		setMerchant(retriveMerchant(terminal));
	}

	private void reset(){
		cardNumber = null;
		amount = null; 
		currency = null;
	}
	
	private Terminal retriveTerminal(Long terminalId){
		logger.trace("retriveTerminal...");
		Terminal result;
		SelectionParams sp = SelectionParams.build("id", terminalId);
		Terminal[] terminals = acquiringDao.getTerminals(userSessionId, sp);
		if (terminals.length > 0){
			result = terminals[0];
		} else {
			throw new IllegalStateException("Terminal with ID:" + terminalId + " is not found!");
		}
		return result;
	}
	
	private Merchant retriveMerchant(Terminal terminal){
		logger.trace("retriveMerchant...");
		Merchant result;
		SelectionParams sp = SelectionParams.build("id", terminal.getMerchantId());
		Merchant[] merchants = acquiringDao.getMerchantsList(userSessionId, sp);
		if (merchants.length > 0){
			result = merchants[0];
		} else {
			throw new IllegalStateException("Merchant with ID:" + terminal.getMerchantId() + " is not found!");
		}
		return result;
	}
	
	private Customer retriveCustomer(Terminal terminal){
		logger.trace("retriveCustomer...");
		Customer result;
		SelectionParams sp = SelectionParams.build("id", terminal.getCustomerId(), "lang", curLang);
		Customer[] customers = productsDao.getCompanyCustomers(userSessionId, sp, curLang);
		if (customers.length > 0){
			result = customers[0];
		} else {
			throw new IllegalStateException("Customer with id:" + terminal.getCustomerId() + " is not found!");
		}		
		return result;
	}

	@Override
	public Map<String, Object> release(Direction direction) {
		logger.trace("release...");
		if (direction == Direction.FORWARD){
			try{
				AthAddRsType operStatus=doIFX();
				context.put(WizardConstants.OPER_STATUS, operStatus);
			}catch(Exception e){
				context.put(FAULT_STRING, e.getMessage());
			}
			context.put(TERMINAL, terminal);
			context.put(MERCHANT, merchant);
			context.put(CUSTOMER, customer);
		}
		return context;
	}

	private MsgRqHdrType getHeader() {
		MsgRqHdrType header = new MsgRqHdrType();
		ContextRqHdrType contextRqHdr = new ContextRqHdrType();
		NetworkTrnDataType networkTrnData = new NetworkTrnDataType();
		networkTrnData.setNetworkOwner("Branch");
		networkTrnData.setTerminalIdent(terminal.getTerminalNumber());
		networkTrnData.setMerchNum(merchant.getMerchantNumber());
		contextRqHdr.setNetworkTrnData(networkTrnData);	
		try {
			GregorianCalendar cal = new GregorianCalendar();
			cal.setTime(new Date());			
			contextRqHdr.setClientDt(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			header.setContextRqHdr(contextRqHdr);
		} catch (DatatypeConfigurationException e) {
			logger.error("Cannot get date in xml format", e);
		}
		return header;
	}
	
	private AthAddRsType doIFX() throws Exception{
		logger.trace("perform manual purchase...");
		IFXType ifx = new IFXType();
		AthAddRqType athAdd = new AthAddRqType();
		athAdd.setRqUID(UUID.randomUUID().toString());
		athAdd.setMsgRqHdr(getHeader());
		
		AthInfoType athInfo = new AthInfoType();
		athInfo.setAthType("Purchase");
		
		CompositeCurAmtType compositeCurAmtType = new CompositeCurAmtType();
		compositeCurAmtType.setCompositeCurAmtType("Debit");
		CurAmtType curAmtType = new CurAmtType();
		curAmtType.setAmt(amount);
		CurCodeType curCode = new CurCodeType();
		String currencyShort = CurrencyCache.getInstance().getCurrencyShortNamesMap().get(currency);
		curCode.setCurCodeValue(currencyShort);
		curAmtType.setCurCode(curCode);
		compositeCurAmtType.setCurAmt(curAmtType);		
		athInfo.getCompositeCurAmt().add(compositeCurAmtType);
		CardKeysType cardKeys = new CardKeysType();
		cardKeys.setCardNum(cardNumber);
		AcctKeysType acctKeys = new AcctKeysType();
		acctKeys.setCardKeys(cardKeys);
		athInfo.setAcctKeys(acctKeys);
		athInfo.setDebitCredit("Debit");
		athInfo.setPreAthInd("0");
		athAdd.setAthInfo(athInfo);
		ifx.getAcctInqRqOrAcctModRqOrAcctRevRq().add(athAdd);
		IFXType respIFX=null;
		try{
			respIFX = port.doIFX(ifx);
		}catch(javax.xml.ws.soap.SOAPFaultException e){
			String faultString=e.getFault().getFaultString();
			if (e.getFault().hasDetail()){
				faultString+=": "+e.getFault().getDetail().getFirstChild().getFirstChild().getNodeValue();
			}
			throw new Exception(faultString);
		}
		List<?> respList = respIFX.getAcctInqRsOrAcctModRsOrAcctRevRs();
		AthAddRsType resp = (AthAddRsType)respList.get(0);
		logger.debug(String.format("Result of the executed operation: [statusCode: %s, severity: %s]", resp.getStatus().getStatusCode(), resp.getStatus().getSeverity()));
		return resp;
	}
	
	private void initWs() throws Exception {
		SVIP_Service service = new SVIP_Service();
		port = service.getSVIPSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, prepareFeLocation());
		Binding binding = bp.getBinding();
		@SuppressWarnings("unchecked")
		List<Handler> soapHandlersList = new ArrayList<Handler>();
		SOAPLoggingHandler soapHandler = new SOAPLoggingHandler();
		soapHandler.setLogger(logger);
		soapHandlersList.add(soapHandler);
		binding.getHandlerChain();
		binding.setHandlerChain(soapHandlersList);
	}
	
	private String prepareFeLocation() throws IOException{
		String feLocation = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.FRONT_END_LOCATION);
		String port = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.SVIP_PORT);
		if (feLocation == null || feLocation.trim().length() == 0) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"sys_param_empty", SettingsConstants.FRONT_END_LOCATION);
			throw new IOException(msg);
		}
		if (port == null || port.trim().length() == 0) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"sys_param_empty", SettingsConstants.SVIP_PORT);
			throw new IOException(msg);
		}
		feLocation = feLocation + ":" + port;
		logger.debug("Front-end location: " + feLocation);
		return feLocation;
	}
	
	@Override
	public boolean validate() {
		logger.trace("validate...");
		return false;
	}

	public Terminal getTerminal() {
		return terminal;
	}

	public void setTerminal(Terminal terminal) {
		this.terminal = terminal;
	}

	public Customer getCustomer() {
		return customer;
	}

	public void setCustomer(Customer customer) {
		this.customer = customer;
	}

	public Merchant getMerchant() {
		return merchant;
	}

	public void setMerchant(Merchant merchant) {
		this.merchant = merchant;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public String getCardNumber() {
		return cardNumber;
	}

	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}
	
	public List<SelectItem> getCurrencies(){
		return CurrencyCache.getInstance().getAllCurrencies(curLang);
	}
}
