package ru.bpc.sv2.ui.common.wizard.callcenter.terminal;

import org.apache.log4j.Logger;
import org.ifxforum.xsd._1.*;
import ru.bpc.sv.svip.SVIP;
import ru.bpc.sv.svip.SVIP_Service;
import ru.bpc.sv.ws.handlers.soap.SOAPLoggingHandler;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import util.auxil.SessionWrapper;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.ws.Binding;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.handler.Handler;
import java.io.IOException;
import java.util.*;

public abstract class AbstractIFX implements CommonWizardStep{

	private static final String OBJECT_ID = "OBJECT_ID";
	public static final String TERMINAL = "TERMINAL";
	public static final String MERCHANT = "MERCHANT";
	public static final String CUSTOMER = "CUSTOMER";
	public static final String OPER_STATUS = "OPER_STATUS";	
	
	private AcquiringDao acquiringDao = new AcquiringDao();
	
	private ProductsDao productsDao = new ProductsDao();

	private CommonDao commonDao = new CommonDao();
	
	private Map<String, Object> context;
	protected long userSessionId;
	protected String curLang;
	private Long objectId;
	private Terminal terminal;
	private Merchant merchant;
	private Customer customer;
	private SVIP port;
	
	@Override
	public void init(Map<String, Object> context) {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = SessionWrapper.getField("language");
		reset();
		this.context = context;
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
		terminal = retriveTerminal(objectId);
		customer = retriveCustomer(terminal);
		merchant = retriveMerchant(terminal);		
	}

	protected void reset(){
		terminal = null;
		customer = null;
		merchant = null;
	}
	
	private Terminal retriveTerminal(Long terminalId){
		getLogger().trace("retriveTerminal...");
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
		getLogger().trace("retriveMerchant...");
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
		getLogger().trace("retriveCustomer...");
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
		getLogger().trace("release...");
		if (direction == Direction.FORWARD){
			AthAddRsType operStatus = doIFX();
			context.put(OPER_STATUS, operStatus);
			context.put(TERMINAL, terminal);
			context.put(MERCHANT, merchant);
			context.put(CUSTOMER, customer);
		}
		return context;
	}

	private AthAddRsType doIFX(){
		getLogger().trace("perform manual purchase...");
		IFXType ifx = new IFXType();
		AthAddRqType athAdd = new AthAddRqType();
		athAdd.setRqUID(UUID.randomUUID().toString());
		athAdd.setMsgRqHdr(getHeader());
		
		AthInfoType athInfo = prepareAuthInfo();
		athAdd.setAthInfo(athInfo);
		ifx.getAcctInqRqOrAcctModRqOrAcctRevRq().add(athAdd);
		IFXType respIFX = port.doIFX(ifx);
		List<?> respList = respIFX.getAcctInqRsOrAcctModRsOrAcctRevRs();
		AthAddRsType resp = (AthAddRsType)respList.get(0);
		getLogger().debug(String.format("Result of the executed operation: [statusCode: %s, severity: %s]", resp.getStatus().getStatusCode(), resp.getStatus().getSeverity()));
		return resp;
	}
	
	protected abstract AthInfoType prepareAuthInfo();
	
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
			getLogger().error("Cannot get date in xml format", e);
		}
		return header;
	}	
	
	@Override
	public boolean validate() {
		throw new UnsupportedOperationException("This method belongs to an abstract class. If you want to use it, please, override it in the subclass");
	}

	private void initWs() throws Exception {
		SVIP_Service service = new SVIP_Service();
		port = service.getSVIPSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, prepareFeLocation());
		Binding binding = bp.getBinding();
		@SuppressWarnings({ "rawtypes" })
		List<Handler> soapHandlersList = new ArrayList<Handler>();
		SOAPLoggingHandler soapHandler = new SOAPLoggingHandler();
		soapHandler.setLogger(getLogger());
		soapHandlersList.add(soapHandler);
		binding.getHandlerChain();
		binding.setHandlerChain(soapHandlersList);
	}	
	
	private String prepareFeLocation() throws IOException{
		String feLocation = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.FRONT_END_LOCATION);
		if (feLocation == null || feLocation.trim().length() == 0) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"sys_param_empty", SettingsConstants.FRONT_END_LOCATION);
			throw new IOException(msg);
		}
		feLocation = feLocation + ":" + 29324;
		getLogger().debug("Front-end location: " + feLocation);
		return feLocation;
	}	
	
	protected abstract Logger getLogger();
	
	public Terminal getTerminal(){
		return terminal;
	}
}
