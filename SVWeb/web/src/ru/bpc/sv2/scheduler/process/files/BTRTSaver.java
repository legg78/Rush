package ru.bpc.sv2.scheduler.process.files;

import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.AccountConstants;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationRec;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.logic.ws.ApplicationsWsDao;
import ru.bpc.sv2.process.btrt.BTRTMapping;
import ru.bpc.sv2.process.btrt.NodeItem;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.products.ProductService;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.scheduler.process.converter.BTRTUtils;
import ru.bpc.sv2.scheduler.process.external.btrt.BTRTReader;
import ru.bpc.sv2.scheduler.process.external.btrt.BTRTWriter;
import ru.bpc.sv2.scheduler.process.utils.FlatFileSaver;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.AppElementsCache;
import ru.bpc.sv2.utils.AppStructureUtils;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;
import util.auxil.SessionWrapper;

import java.io.*;
import java.math.BigDecimal;
import java.nio.charset.Charset;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.*;


/**
 * How it works:</br>
 * 1) Saver makes a copy of the source file. 
 * 2) The original source file is read by BTRTConverter and transformed into object tree. 
 * 3) Also BTRTConverter rebuild a structure of BTRT object tree - from BTRT structure to SV2 structure.
 * 4) Saver registers a new application record, build SV2 application tree from prepared BTRT tree and performs post-processing 
 * of SV2 application.
 * 6) Saver append a temporary tag that contains application ID of SV2 application in the copy of the original file
 * 7) Saver stores the copy in DB as INGOING_FILE. This file will be processed by BTRTProcessor. 
 */
public class BTRTSaver extends AbstractFileSaver {
	private static final boolean trace = true;
	
	private ApplicationDao appDao;
	private ApplicationsWsDao appWsDao;
	private ProductsDao productsDao;
	private AccountsDao accountsDao;
	private SettingsDao settingsDao;
	private IssuingDao issuingDao;
	
	private static final String CUSTOMER_PERSON_TYPE = "ENTTPERS";
	private static final String CUSTOMER_COMPANY_TYPE = "ENTTCOMP";
	private static final int DEFAULT_ISS_APPLICATION_FLOW = 3;
	private static final int CHANGE_CLIENT_FLOW = 1004;
	private static final int OPEN_ADDITIONAL_SERVICE_FLOW = 1005;
	
	private List<String> LINK_BLOCK_CODES = new ArrayList<String>(){{
		add(BTRTMapping.LINK_ACCOUNT_WITH_CARD.getCode());
		add(BTRTMapping.LINK_CARD_WITH_ADDITIONAL_SERVICE.getCode());
		add(BTRTMapping.LINK_CARD_WITH_ACCOUNT.getCode());
		add(BTRTMapping.LINK_ACCOUNT_WITH_ADDITIONAL_SERVICE.getCode());
		add(BTRTMapping.LINK_UNIPAGO_RETAILER_WITH_DISTRIBUTOR.getCode());
		add(BTRTMapping.LINK_CARD_WITH_CARD.getCode());
		add(BTRTMapping.MOVE_SERVICE_FROM_ACC_TO_ACC.getCode());
	}};
	
	private List<String> BLACK_CODES = new ArrayList<String>(){{
		// link block codes
		add(BTRTMapping.REFERENCE.getCode());
		add(BTRTMapping.LINK_ACCOUNT_WITH_CARD.getCode());
		add(BTRTMapping.LINK_CARD_WITH_ADDITIONAL_SERVICE.getCode());
		add(BTRTMapping.LINK_CARD_WITH_ACCOUNT.getCode());
		add(BTRTMapping.LINK_ACCOUNT_WITH_ADDITIONAL_SERVICE.getCode());
		add(BTRTMapping.LINK_UNIPAGO_RETAILER_WITH_DISTRIBUTOR.getCode());
		add(BTRTMapping.LINK_CARD_WITH_CARD.getCode());
		add(BTRTMapping.MOVE_SERVICE_FROM_ACC_TO_ACC.getCode());
	}};

	
	private long currVal;
	private int step = ApplicationConstants.DATA_SEQUENCE_STEP;
	private int count;
	private Map<String, ApplicationElement> appIdsMap;
	private Map<Long, ApplicationElement> refElsMap;
	private Map<Long, String> refDataIdsMap;
	private Map<String, ApplicationElement> elementsMap;
	private Long applicationId;
	private Long processSessionId;
	private String appXml;
	private long timeBegin;
	
	private int institutionID;
	private int agentID;
	private String appDate;
	private String appNumber;
	private String sequenceAccount;
	private String sequenceCard;
	
	private List<NodeItem> customerServices;
	private List<NodeItem> cardholderServices;
	private List<NodeItem> cardServices;
	private List<NodeItem> accountServices;
	
	private String language;
	private boolean ignoreAccount;
	
	public void save() throws SQLException, Exception {
		setupTracelevel();
		language = SessionWrapper.getField("language"); // try to get user's language
		
		appDao = new ApplicationDao();
		appWsDao = new ApplicationsWsDao();
		productsDao = new ProductsDao();
		accountsDao = new AccountsDao();
		issuingDao = new IssuingDao();
		
		if (language == null) {
			// if there's no user session and hence no user language then get system language
			settingsDao = new SettingsDao();
			language = settingsDao.getParameterValueV(null, SettingsConstants.LANGUAGE, LevelNames.SYSTEM, null);
		}
		
		ignoreAccount = false;
				
		customerServices = new ArrayList<NodeItem>();
		cardholderServices = new ArrayList<NodeItem>();
		cardServices = new ArrayList<NodeItem>();
		accountServices = new ArrayList<NodeItem>();
		
		appIdsMap = new HashMap<String, ApplicationElement>();
		refDataIdsMap = new HashMap<Long, String>();
		refElsMap = new HashMap<Long, ApplicationElement>();
		timeBegin = System.currentTimeMillis();
		AppElementsCache appCache = AppElementsCache.getInstance();
		elementsMap = appCache.getElementsMap();
		if (elementsMap == null) {
			ApplicationElement[] elements = appDao.getAllElements();

			elementsMap = new HashMap<String, ApplicationElement>();
			for (ApplicationElement el : elements) {
				elementsMap.put(el.getName(), el);
			}
			if (trace) {
				logger.trace("Get elements list. Time (ms): " +
						(System.currentTimeMillis() - timeBegin));
			}
		}
		
		// Creates a list of BTRT applications with original BTRT structure. 
		List<String> lines = streamToLines(inputStream); 
		inputStream = linesToStream(lines);
		List<NodeItem> srcBtrtApps = new ArrayList<NodeItem>();
		// Skips the first and the last elements: HEADER and FOOTTER
		for (int i=1; i<lines.size() - 1; i++){
			String line = lines.get(i);
			BTRTReader reader = new BTRTReader(line);
			try{
				NodeItem btrtApp = reader.read();
				srcBtrtApps.add(btrtApp);
			}catch(StringIndexOutOfBoundsException e){
				throw new UserException("Error reading is not the correct format. Row " + (i+1));
			}
		}
		
		
		long readBTRTBegin = System.currentTimeMillis();
		BTRTConverter btrtReader = new BTRTConverter();
		btrtReader.setAppDao(appDao);
		btrtReader.setProductsDao(productsDao);

		// TODO: userSessionId can be NULL if process was started by scheduler: we need to remove it or replace it with
		// something
		btrtReader.setUserSessionId(userSessionId);
		if (fileAttributes.getCharacterSet() != null && !fileAttributes.getCharacterSet().isEmpty()){
			btrtReader.setCharSetName(fileAttributes.getCharacterSet());
		}
		List<NodeItem> nodeItems = btrtReader.readData(inputStream);
		Set<Integer> unparsedApps = btrtReader.getUnparsedApps();
		if (trace) {
			logger.trace("BTRT Reading. Time (ms): " +
					(System.currentTimeMillis() - readBTRTBegin));
		}
		//remove the first and the last - they're the header and trailer
		getGeneralInfo(nodeItems.remove(0));
		nodeItems.remove(nodeItems.size() - 1);
		
		int i = 0;
		for (int j=0; j<nodeItems.size(); j++){
			NodeItem prpApp = nodeItems.get(j);
			NodeItem oglApp = srcBtrtApps.get(j);
			if (BTRTMapping.APP_FILE_PROCESSING_RESPONSE.getCode().equals(prpApp.getName())) {
				//process error session log
				processFFFF33(prpApp);
			} else {
				boolean isParsedOk = true;
				if (unparsedApps != null && unparsedApps.contains(j+1)) {
					isParsedOk = false;
				}
				//create application for each nodeItem
				Long appId = createApplication(prpApp, oglApp, isParsedOk, j);
				
				// Change application ID of the original BTRT application
				NodeItem srcBtrtApp = srcBtrtApps.get(i++);
				if(appId == null){
					continue;
				}
				setupAppId(srcBtrtApp, appId);
			}
		}
		
		StringBuilder sb = new StringBuilder();
		sb.append(lines.get(0));
		sb.append("\n");
		for (NodeItem srcBtrtApp : srcBtrtApps){
			String updLine = nodeItemToLine(srcBtrtApp);
			sb.append(updLine);
			sb.append("\n");
		}
		sb.append(lines.get(lines.size() - 1));
		String updBtrtFile = sb.toString();
		
		storeFile(updBtrtFile);
		
		if (trace) {
			logger.trace("BTRT File Saver, Total Time. Time (ms): " +
					(System.currentTimeMillis() - timeBegin));
		}
	}

	private void storeFile(List<String> applications, List<Integer> idList){
		FlatFileSaver saver = new FlatFileSaver();
		saver.setConnection(con);
		saver.setFileSessionId(fileAttributes.getSessionId());
		saver.setLines(applications);
	}
	
	private void storeFile(String content) throws SystemException{
		CallableStatement cstmt = null;
		try {
			cstmt = con.prepareCall("{call prc_api_file_pkg.put_file(?,?)}");
			cstmt.setLong(1, fileAttributes.getSessionId());
			cstmt.setObject(2, content);
			cstmt.execute();
			
		} catch (SQLException e) {
			logger.error(e);
			throw new SystemException(e);
		} finally {
			if (cstmt != null) try {cstmt.close();} catch (Exception e) {}
		}
	}
	
	private String nodeItemToLine(NodeItem appRoot){
		Charset charset = Charset.forName(fileAttributes.getCharacterSet());
		BTRTWriter writer = new BTRTWriter(appRoot);
		ByteArrayOutputStream baos = null;
		OutputStreamWriter osw = null;
		try {
			baos = new ByteArrayOutputStream();
			osw = new OutputStreamWriter(baos, charset);
			writer.write(osw);
		} catch (IOException e) {
			logger.error(e);
			return "";
		} finally {
			if (osw != null) try {osw.close();} catch (Exception e) {}
		}
		
		byte[] resultSrc = baos.toByteArray();
		String result = new String(resultSrc, charset);
		return result;
	}
	
	private void setupAppId(NodeItem appRoot, Long appId){
		NodeItem mainBlock = appRoot.child(BTRTMapping.MAIN_BLOCK.getCode());
		if (mainBlock == null) return;
		// This is crutch in fact. We need to bind original BTRT application with an application stored in SV2 DB, and we need
		// to do it fast. The correct solution would be to place this binding in app_object table. 
		NodeItem extApplicationid = new NodeItem("DF8888", appId.toString());
		mainBlock.getChildren().add(extApplicationid);
		/*
		NodeItem applicationId = mainBlock.child(BTRTMapping.APPLICATION_ID.getCode());
		if (applicationId == null){
			applicationId = new NodeItem(BTRTMapping.APPLICATION_ID.getCode(), null);
		}
		applicationId.setData(appId.toString());
		*/
	}
	
	private List<String> streamToLines(InputStream is) throws SystemException{
		Charset charset = Charset.forName(fileAttributes.getCharacterSet());
		InputStreamReader isr = new InputStreamReader(is, charset);
		BufferedReader br = new BufferedReader(isr);
		String line = null;
		List<String> result = new ArrayList<String>();
		try {
			while ((line = br.readLine()) != null){
				result.add(line);
			}
		} catch (IOException e){
			logger.error(e);
			throw new SystemException(e);
		} finally {
			if (br != null){ 
				try {br.close();} catch (Exception e){}
			}
		}
		return result;
	}
	
	private InputStream linesToStream(List<String> lines){
		Charset charset = Charset.forName(fileAttributes.getCharacterSet());
		StringBuilder sb = new StringBuilder();
		for (String line : lines){
			sb.append(line);
			sb.append("\n");
		}
		String conjunctedLines = sb.toString();
		ByteArrayInputStream bim = new ByteArrayInputStream(conjunctedLines.getBytes(charset));
		return bim;
	}
	
	private void processFFFF33(NodeItem ffff33) {
		if (trace) {
			loggerDB.debug(new TraceLogInfo(processSessionId, "Cannot load app. Error:"));
			NodeItem ff8050 = ffff33.getChildren().get(1);
			for (NodeItem child : ff8050.getChildren()) {
				BTRTMapping codeToName = BTRTMapping.get(child.getName());
				if (BTRTMapping.FILE_PROCESSING_RESULT_MSG.equals(codeToName)) {
					loggerDB.debug(new TraceLogInfo(processSessionId, "-----File processing result message: " + child.getData()));
				}
				
				if (BTRTMapping.ORIGINAL_FILE_NAME.equals(codeToName)) {
					loggerDB.debug(new TraceLogInfo(processSessionId, "-----Original file name: " + child.getData()));
				}
				
				if (BTRTMapping.FILE_PROCESSING_DATE.equals(codeToName)) {
					loggerDB.debug(new TraceLogInfo(processSessionId, "-----File processing date: " + child.getData()));
				}
				
				if (BTRTMapping.FILE_PROCESSING_RESULT_CODE.equals(codeToName)) {
					loggerDB.debug(new TraceLogInfo(processSessionId, "-----File processing result code: " + child.getData()));
				}
				
				if (BTRTMapping.FILE_REFERENCE_NUMBER.equals(codeToName)) {
					loggerDB.debug(new TraceLogInfo(processSessionId, "-----File reference number: " + child.getData()));
				}
			}
		}
	}
	
	private void getGeneralInfo(NodeItem firstNode) {
		List<NodeItem> nodeList = firstNode.getChildren();
		NodeItem headerBlock = nodeList.get(1);
		for (NodeItem node : headerBlock.getChildren()) {
			BTRTMapping codeToName = BTRTMapping.get(node.getName());
			if (BTRTMapping.INSTITUTION_ID.equals(codeToName)) {
				institutionID = Integer.parseInt(node.getData());
			}
			if (BTRTMapping.AGENT_ID.equals(codeToName)) {
				agentID = Integer.parseInt(node.getData());
			}
			if (BTRTMapping.APPLICATION_DATE.equals(codeToName)) {
				appDate = node.getData();
			}
		}
	}
	
	private Long createApplication(NodeItem preparedApp, NodeItem originalApp, boolean isParsedOk,
								   int fileLine) throws SQLException, Exception {
		long appBegin = System.currentTimeMillis();
		long workBegin = appBegin;
		
		appIdsMap.clear();
		refElsMap.clear();
		refDataIdsMap.clear();

		Application app = null;
		String appTypeData = null;
		try {
			NodeItem apType = preparedApp.child(BTRTMapping.APPLICATION_TYPE.getCode());		
			appTypeData = apType.getData(); // appType = BTRTXX (where XX is numeric text)

			app = getApplicationInfo(preparedApp, isParsedOk);
			
			if (trace) {
				logger.trace("Register session. Time (ms): " +
						(System.currentTimeMillis() - workBegin));
			}
			workBegin = System.currentTimeMillis();
			appWsDao.createApplication(userSessionId, app);
			applicationId = app.getId();

			resetCount();
			ApplicationElement tmpEl = elementsMap.get("APPLICATION");
			ApplicationElement appTree = tmpEl.clone();
			setDataAndParent(appTree, null);
			appTree.setInnerId(1);

			if (trace) {
				String msg = "APP: " + applicationId + "; external application number: " + appNumber
						+ "; external application type: " + appTypeData + "; Create application. Time (ms): "
						+ (System.currentTimeMillis() - workBegin);
				logger.trace(msg);
				loggerDB.debug(new TraceLogInfo(processSessionId, msg));
			}

			long createObjectTreeBegin = System.currentTimeMillis();
			
			createAppTree(preparedApp, appTree);
			
			postProcessAppTree(app, appTree, originalApp);
			
			List<ApplicationRec> appAsArray = appToRecList(appTree);
			
			if (trace) {
				logger.trace("APP: " + applicationId + "; Build object tree. Time (ms): " +
						(System.currentTimeMillis() - createObjectTreeBegin));
			}

			long saveDataBegin = System.currentTimeMillis();
			appWsDao.modifyApplicationData(userSessionId, appAsArray
					.toArray(new ApplicationRec[appAsArray.size()]), applicationId);
			if (trace) {
				logger.trace("APP: " + applicationId +
						"; Save data (form Oracle array). Time (ms): " +
						(System.currentTimeMillis() - saveDataBegin));
			}

			AppStructureUtils.print(appTree);

		} catch (Exception e) {
			if (app != null && applicationId != null) {
				String msg = "APP: " + applicationId + "; external application number: " + appNumber
						+ "; external application type: " + appTypeData + " "
						+ "Error on line " + (fileLine  + 2) + " "
						+ e.getMessage();
				logger.error(msg);
				loggerDB.error(new TraceLogInfo(processSessionId, msg));
				appDao.deleteApplication(userSessionId, app);
			}else{
				logger.error(e.getMessage());
				loggerDB.error(new TraceLogInfo(processSessionId, e.getMessage()));
			}

		}
		return applicationId;
	}
	
	private List<ApplicationRec> appToRecList(ApplicationElement application){
		List<ApplicationRec> recList = new ArrayList<ApplicationRec>();
		class AppToRecListConverter{
			public void appToRecList(ApplicationElement application, List<ApplicationRec> recList){
				recList.add(new ApplicationRec(application));
				if (application.isHasChildren()){
					for (ApplicationElement child : application.getChildren()){
						appToRecList(child, recList);
					}
				}
			}
		}
		AppToRecListConverter converter = new AppToRecListConverter();
		converter.appToRecList(application, recList);
		return recList;
	}
	/*
	 * First time the work of BTRTSaver + BTRTConverter is based on the fact, 
	 * that the structures of BTRT and SV2 applications are very similar - so, 
	 * all we need to convert BTRT structure to SV2 it's just move a couple of 
	 * elements to new positions. But, in practice it have turned out that BTRT 
	 * application has a set of tags and structures that have not analogs in 
	 * SV2 application, but must be processed - and visa versa. First time, 
	 * i'm trying to solve this problem by including pseudo-tags in processed 
	 * BTRT application. This pseudo-tags cannot be converted into SV2 application 
	 * elements, but can be handled by my code and processed the way i want. 
	 * Now i've come to conclusion that is the wrong way, because lead to additional 
	 * confusion in the code. So, i decided to pass the original BTRT application 
	 * into postProcess() method and use it every time i need to access to 
	 * specific data of BTRT application.
	 */
	private void postProcessAppTree(Application app, ApplicationElement appTree, NodeItem originalApp) throws Exception{
		ApplicationElement applicationType = appTree.retrive(AppElements.APPLICATION_TYPE);
		String appTypeValue = applicationType.getValueV();
		
		int btrtNumber = decodeBTRTType(appTypeValue);
		
		// BTRT application structure doesn't have FLOW_ID element. We need to create one. 
		ApplicationElement flowId = installElement(AppElements.APPLICATION_FLOW_ID, appTree);
		flowId.set(app.getFlowId());
		
		// BTRT application structure doesn't have INSTITUTION_ID element. We need to create one. 
		ApplicationElement instId = installElement(AppElements.INSTITUTION_ID, appTree);
		instId.set(app.getInstId());
		
		// BTRT application structure doesn't have AGENT_ID element. We need to create one. 
		ApplicationElement agentId = installElement(AppElements.AGENT_ID, appTree);
		agentId.set(app.getAgentId());

		// Application structure must have APPLICATION_STATUS block
		ApplicationElement applicationStatus = installElement(AppElements.APPLICATION_STATUS, appTree);
		applicationStatus.set(ApplicationStatuses.AWAITING_PROCESSING);
		
		// CUSTOMER_NUMBER element may not be presented. If customer block isn't presented, we have to create one
		ApplicationElement customer = appTree.tryRetrive(AppElements.CUSTOMER);
		ApplicationElement customerNumber = customer.tryRetrive(AppElements.CUSTOMER_NUMBER);
		if (customerNumber == null ){
			Random random = new Random();
			int customerNumberValue = random.nextInt();
			customerNumber = installElement(AppElements.CUSTOMER_NUMBER, appTree);
			customerNumber.set(customerNumberValue);
		}

		// If value of CUSTOMER_NUMBER is null, that means we have to define a new customer, 
		// i.e. new PERSON, ADDRESS and CONTACT blocks.
		if (customerNumber.getValueV() == null || customerNumber.getValueV().isEmpty()){
			ApplicationElement person = customer.tryRetrive(AppElements.CONTRACT,
															AppElements.CARD,
															AppElements.CARDHOLDER,
															AppElements.PERSON);
			if (person != null){
				person = person.clone();
				setDataAndParentRec(person, customer);
				customer.getChildren().add(person);
			}
			
			ApplicationElement address = customer.tryRetrive(AppElements.CONTRACT,
					AppElements.CARD,
					AppElements.CARDHOLDER,
					AppElements.ADDRESS);
			if (address != null){
				address = address.clone();
				setDataAndParentRec(address, customer);
				customer.getChildren().add(address);
			}
			
			ApplicationElement contact = customer.tryRetrive(AppElements.CONTRACT,
					AppElements.CARD,
					AppElements.CARDHOLDER,
					AppElements.CONTACT);
			if (contact != null){
				contact = contact.clone();
				setDataAndParentRec(contact, customer);
				customer.getChildren().add(contact);
			}
		}		
		
		ApplicationElement customerCategory = customer.tryRetrive(AppElements.CUSTOMER_CATEGORY);
		if (customerCategory != null) {
			if (BTRTMapping.VIP_CODE_VIP.equals(customerCategory.getValue())) {
				customerCategory.set(ApplicationConstants.CUSTOMER_CATEGORY_PRIVILEGED);
			} else {
				customerCategory.set(ApplicationConstants.CUSTOMER_CATEGORY_ORDINARY);
			}
		}
		
		// BTRT application structure doesn't have CUSTOMER_RELATION element. Create one using default value. 
		ApplicationElement customerRelation = installElement(AppElements.CUSTOMER_RELATION, appTree);
		customerRelation.set(ApplicationConstants.CUSTOMER_RELATION_EXTERNAL);
		
		// BTRT application structure doesn't have CONTRACT_TYPE element. We need to create one.
		Product product = productsDao.getProductById(userSessionId, app.getProductId(), language);
		if (product == null) throw new UserException(String.format("Product [%d] is not found", app.getProductId()));
		ApplicationElement contract = customer.tryRetrive(AppElements.CONTRACT);
		ApplicationElement contractType = installElement(AppElements.CONTRACT_TYPE, contract);
		contractType.set(product.getContractType());

		// APPLICATION_ID may contain irrelevant value. We need to update it.
		ApplicationElement applicationId = appTree.tryRetrive(AppElements.APPLICATION_ID);
		if (applicationId == null){
			applicationId = getChildElement(appTree, AppElements.APPLICATION_ID, 1);
			applicationId.setInnerId(1);
			setDataAndParent(applicationId, appTree);
			appTree.getChildren().add(applicationId);
		}
		applicationId.set(app.getId());
		
		// CONTACT elements may not contain CONTACT_TYPE and PREFERRED_LANG elements. 
		List<ApplicationElement> contacts = collectAll(appTree, AppElements.CONTACT);
		for (ApplicationElement contact : contacts){
			if (contact.getInnerId() == 0) continue;
			
			ApplicationElement contactType = contact.tryRetrive(AppElements.CONTACT_TYPE);
			if (contactType == null){
				contactType = installElement(AppElements.CONTACT_TYPE, contact);
				contactType.set("CNTTPRMC");
			}
			
			ApplicationElement preferredLanguage = contact.tryRetrive(AppElements.PREFERRED_LANG);
			if (preferredLanguage == null){
				preferredLanguage = installElement(AppElements.PREFERRED_LANG, contact);
				preferredLanguage.set(language);
			}			
			
			// CONTACT doesn't have COMMAND element. Let's add it
			ApplicationElement contactCommand = installElement(AppElements.COMMAND, contact);
			contactCommand.set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
		}

		// If ACCOUNT blocks are presented in CONTRACT, we have to add ACCOUNT_LINK_FLAG elements to ACCOUNT_OBJECT elements
		List<ApplicationElement> accounts = contract.getChildrenByName(AppElements.ACCOUNT);
		for (ApplicationElement account : accounts){
			/*
			ApplicationElement accountObject = account.retrive(AppElements.ACCOUNT_OBJECT);
			ApplicationElement accountLinkFlag = installElement(AppElements.ACCOUNT_LINK_FLAG, accountObject);
			accountLinkFlag.set(1);
			*/
			// ACCOUNT blocks don't have COMMAND block. Let's add it.
			ApplicationElement accountCommand = installElement(AppElements.COMMAND, account);
			if (ignoreAccount) {
				accountCommand.set(ApplicationConstants.COMMAND_IGNORE);
			} else {
				accountCommand.set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
			}
			
			ApplicationElement accountStatus = account.tryRetrive(AppElements.ACCOUNT_STATUS);
			if (accountStatus != null) {
				if (BTRTMapping.ACCOUNT_STATUS_CLOSED.getCode().equals(accountStatus.getValue())) {
					accountStatus.set(AccountConstants.ACCOUNT_STATUS_CLOSED);
				} else {
					// we don't have other statuses yet
					accountStatus.set(AccountConstants.ACCOUNT_STATUS_ACTIVE);
				}
			}
			
		}
		
		// This piece of code performed searching of a contract in DB by account's number. 
		// Now this functionality is useless, because we can find the contract by a customer.
		// We do it a couple of lines below.
		
		/*
		boolean contractExists = false;
		*/
		/*boolean sameProduct = false;*/
		/*
		// If we want to create a new customer, account or card (BTRT 01-08 application) the new contract
		// will be created. In other case we trying to find an existiong contract (by account). If one is presented
		// - use its number and start date.
		if (btrtNumber > 8){
			if (!accounts.isEmpty()) {
				// suppose that all accounts either exist or not and belong to one contract
				ApplicationElement accNumElement = accounts.get(0).tryRetrive(AppElements.ACCOUNT_NUMBER);
				
				if (accNumElement != null) {
					// Search the contract of the passed account.
					Contract contractObject = contractByAccount(accNumElement.getValueV());
					contractExists = contractObject != null;
					if (contractExists){
						setupContractElement(contractObject, contract);
						
						// If we already have a created account/customer/cardholder that belongs to a contract with product ID=1
						// and want to create a new card using this account/customer/cardholder and product ID=2, we need to 
						// create a new contract. In other case we use the old contract.				
						
						// Integer actualProductId = contract.tryRetrive(AppElements.PRODUCT_ID).getValueN().intValue();
						// Integer oldProductid = contractObject.getProductId();
						// sameProduct = actualProductId.equals(oldProductid);
						
					}
				}
			}
		}
		*/
		
		// CUSTOMER block doesn't have COMMAND block. Let's add it.
		ApplicationElement customerCommand = installElement(AppElements.COMMAND, customer);
		if (btrtNumber == 2 || btrtNumber == 3 || btrtNumber == 30) {
			customerCommand.set(ApplicationConstants.COMMAND_EXCEPT_OR_UPDATE);		
		} else {
			customerCommand.set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
		}

		// CARD blocks don't have COMMAND block. Let's add it.
		List<ApplicationElement> cards = contract.getChildrenByName(AppElements.CARD);
		String command;
		if (btrtNumber == 15) {
			command = ApplicationConstants.COMMAND_EXCEPT_OR_UPDATE;
		} else if (btrtNumber == 30) {
			command = ApplicationConstants.COMMAND_IGNORE;
		} else {
			command = ApplicationConstants.COMMAND_CREATE_OR_UPDATE;
		}
		for (ApplicationElement card : cards){
			ApplicationElement cardCommand = installElement(AppElements.COMMAND, card);
			cardCommand.set(command);
		}
		
		// PERSON and IDENTITY_CARD blocks might not have COMMAND block. We need to check and add it if necessary.
		List<ApplicationElement> persons = collectAll(appTree, AppElements.PERSON);
		for (ApplicationElement person : persons){
			if (person.getInnerId().equals(0)) continue;
			ApplicationElement personCommand = person.tryRetrive(AppElements.COMMAND);
			if (personCommand == null){
				personCommand = installElement(AppElements.COMMAND, person);
			}
			if (btrtNumber == 1 || btrtNumber == 2 || btrtNumber == 5 || btrtNumber == 6) {
				personCommand.set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
			} else if (btrtNumber == 30) {
				personCommand.set(ApplicationConstants.COMMAND_EXCEPT_OR_UPDATE);
			} else {
				// person is identified by cardholder 
				personCommand.set(ApplicationConstants.COMMAND_IGNORE);
			}
			
			ApplicationElement identityCard = person.tryRetrive(AppElements.IDENTITY_CARD);
			if (identityCard != null){
				ApplicationElement identityCommand = identityCard.tryRetrive(AppElements.COMMAND);
				if (identityCommand == null){
					identityCommand = installElement(AppElements.COMMAND, identityCard);
					// In BTRT01 and BTRT02 we cannot change IDENTITY_CARD. Probably this is fairly for all the types 
					// of applications. But now i cannot confidently say that - future issue. TODO: ask BACK about.
					// UPDATE: confidence is growing
					if (btrtNumber == 1 || btrtNumber == 2 || btrtNumber == 5 || btrtNumber == 6) {
						identityCommand.set(ApplicationConstants.COMMAND_CREATE_OR_PROCEED);
					} else if (btrtNumber == 30) {
						identityCommand.set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
					} else {
						identityCommand.set(ApplicationConstants.COMMAND_IGNORE);
					}
				}
			}
		}
		
		// ADDRESS elements may have wrong values in their COMMAND elements. We need to fix them. 
		List<ApplicationElement> addresses = collectAll(appTree, AppElements.ADDRESS);
		for (ApplicationElement address : addresses){
			ApplicationElement addressCommand = address.tryRetrive(AppElements.COMMAND);
			if (addressCommand == null){
				addressCommand = installElement(AppElements.COMMAND, address);
			}
			addressCommand.set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
		}
		
		// If we process BTRT03 it means that cardholder person already exists. In this case we must 
		// replace command for its IDENTITY_CARD to COMMAND_CREATE_OR_PROCEED.
		if (btrtNumber == 3){
			List<ApplicationElement> cardholders = collectAll(contract, AppElements.CARDHOLDER);
			for (ApplicationElement cardholder : cardholders){
				ApplicationElement cardholderCommand = cardholder.tryRetrive(AppElements.COMMAND);
				if (cardholderCommand == null) {
					cardholderCommand = installElement(AppElements.COMMAND, cardholder);
				}
				cardholderCommand.set(ApplicationConstants.COMMAND_EXCEPT_OR_UPDATE);
				
				ApplicationElement identityCommand = cardholder.retrive(AppElements.PERSON,
						AppElements.IDENTITY_CARD, AppElements.COMMAND);
				identityCommand.set(ApplicationConstants.COMMAND_CREATE_OR_PROCEED);
			}
		}
		
		// If we process BTRT05 and CUSTOMER doesn't contain COMPANY element, we must create it.
		if (btrtNumber >= 5){
			ApplicationElement company = customer.tryRetrive(AppElements.COMPANY);
			if (company != null){
				ApplicationElement companyName = company.tryRetrive(AppElements.COMPANY_NAME);
				if (companyName != null){
					String companyNameValue = companyName.getValueV();
					companyName.setValueV(null);
					ApplicationElement embossedName = installElement(AppElements.EMBOSSED_NAME, company);
					embossedName.set(companyNameValue);
					ApplicationElement companyShortName = installElement(AppElements.COMPANY_SHORT_NAME, companyName);
					companyShortName.set(companyNameValue);
				}
				
				ApplicationElement companyCommand = installElement(AppElements.COMMAND, company);
				companyCommand.set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
			}
		}
		
		
		/* 
		BTRT application don't contain services definitions. We need to define them by ourselves
		
		Resolve services on the contract. Firstly we obtain services that are defined for the contract.
		Then we obtain all the services belong to the product and iterate through them. If a service is 
		mandatory, we check whether the contract already contains this service. If doesn't, we check
		whether the service is suitable for any objects that presented in the contract. Then if we come to
		conclusion that the service can be useful for some object, we define it in the application.
		*/
		Map<String, Integer> innerMap = new HashMap<String, Integer>();
		// actually we don't have enough information in BTRT15 to include any services
		if (btrtNumber != 15) {
			List<ApplicationElement> definedServices = contract.getChildrenByName(AppElements.SERVICE);
			SelectionParams sp = SelectionParams.build("productId", app.getProductId(), "lang", language);
			ProductService[] services = productsDao.getProductServices(userSessionId, sp);
			innerMap.put(AppElements.SERVICE, definedServices.size());
			
			for (ProductService service : services) {
				if (service.isMandatory()) {
					int i = 0;
					boolean found = false;
					for (i = 0; i < definedServices.size(); i++) {
						ApplicationElement defSrvEl = definedServices.get(i);
						Integer defSrvId = defSrvEl.getValueN().intValue();
						if (defSrvId != null && defSrvId.equals(service.getServiceId())) {
							found = true;
							break;
						}
					}
					if (found) {
						definedServices.remove(i);
					} else {
						List<ApplicationElement> objects = null;
						if (EntityNames.CARD.equals(service.getEntityType())) {
							objects = cards;
						} else if (EntityNames.ACCOUNT.equals(service.getEntityType())) {
							objects = accounts;
						} else if (EntityNames.CUSTOMER.equals(service.getEntityType())) {
							objects = new ArrayList<ApplicationElement>();
							objects.add(customer);
						}
						if (objects == null)
							continue;
						for (ApplicationElement object : objects) {
							ApplicationElement objectCommand = object.tryRetrive(AppElements.COMMAND);
							String commandValue = objectCommand.getValueV();
							if (objectCommand != null
									&& !ApplicationConstants.COMMAND_CREATE_OR_UPDATE.equals(commandValue)
									&& !ApplicationConstants.COMMAND_EXCEPT_OR_UPDATE.equals(commandValue))
								continue;
	
							ApplicationElement serviceNode = installElement(AppElements.SERVICE, contract);
							serviceNode.set(service.getServiceId());
							setInnerId(serviceNode, innerMap);
							
							Long dataId = object.getDataId();
							ApplicationElement serviceObject = installElement(AppElements.SERVICE_OBJECT, serviceNode);
							serviceObject.set(dataId);
						}
					}
				}
			}
		}


		
		// If an application type is BTRT30 or 35, we must define the contract the customer belongs to.
		// We already have customer_id, so we just find the contract by customer and setup it to a new element. 
		if (btrtNumber == 30) {
			installContractNumber(customerNumber, contract);
			modifyCardServices(contract, btrtNumber, innerMap);
		
		} else if (btrtNumber == 35){
			// implemented in handleBTRT35()
		} else {
			// BTRT application structure doesn't have START_DATE element for CONTRACT. We need to create one.
			ApplicationElement startDate = installElement(AppElements.START_DATE, contract);
			startDate.set(new Date());
			
			// CONTRACT block doesn't have COMMAND block. Let's add it.
			ApplicationElement contractCommand = installElement(AppElements.COMMAND, contract);
			contractCommand.set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
		}
		
		if (btrtNumber == 35){
			handleBTRT35(app, appTree, originalApp);
		}
		
		// If an application has type BTRT15, that means that we must specify seq number for the card we want to change a status of.
		if (btrtNumber == 15){
			//TODO app process of account status change
			installContractNumber(customerNumber, contract);
			
//			ApplicationElement card = contract.retrive(AppElements.CARD);
//			ApplicationElement cardNumber = card.retrive(AppElements.CARD_NUMBER);
//			String cardNumberVal = cardNumber.getValueV();
//			int maxSeq = retriveMaxCardSeqNumber(cardNumberVal);
//			ApplicationElement cardSeqNumber = installElement(AppElements.SEQUENTIAL_NUMBER, card);
//			cardSeqNumber.set(maxSeq);
		} 

		// try to retrieve existing cardholder number
		ApplicationElement cardholder = contract.tryRetrive(AppElements.CARD,
				AppElements.CARDHOLDER);
		ApplicationElement person = null;
		if (cardholder != null){
			person = cardholder.tryRetrive(AppElements.PERSON);	
		}
		ApplicationElement idNumber = null;
		if (person != null){
			// cardholder number is kept inside PERSON element (see BTRTConverter) 
			idNumber = person.tryRetrive(AppElements.CARDHOLDER_NUMBER);
		}
		if (idNumber != null){
			person.getChildren().remove(idNumber);
			idNumber.setParent(null);
			ApplicationElement cardholderNumber = installElement(AppElements.CARDHOLDER_NUMBER, cardholder);
			cardholderNumber.set(idNumber.getValueV());
		}
		
		// APPLICATION_TYPE element has a value like 'BTRTXX'. We need to correct it:
		applicationType.set(app.getAppType());
		setObjectIds(appTree);
		
	}
	
	private void handleBTRT35(Application app, ApplicationElement appTree, NodeItem originalApp) throws Exception{
		ApplicationElement customer = appTree.tryRetrive(AppElements.CUSTOMER);
		ApplicationElement contract = customer.tryRetrive(AppElements.CONTRACT);
		ApplicationElement card = contract.retrive(AppElements.CARD);
		List<ApplicationElement> definedServices = contract.getChildrenByName(AppElements.SERVICE);
		ApplicationElement cardholder = card.retrive(AppElements.CARDHOLDER);
		
		// Install SMS-notification service for BTRT35.
		Long SMS_NOTIFY_SRV = 50000078L;
		ApplicationElement serviceNode = installElement(AppElements.SERVICE, contract);
		serviceNode.set(SMS_NOTIFY_SRV);
		serviceNode.setInnerId(definedServices.size() + 1);
		Long dataId = card.getDataId();
		ApplicationElement serviceObject = installElement(AppElements.SERVICE_OBJECT, serviceNode);
		serviceObject.set(dataId);
		
		// Check what action we actually need to do: add or remove a service
		NodeItem addSrv = originalApp.child(BTRTMapping.ADDITIONAL_SERVICE_BLOCK);
		NodeItem srvData = addSrv.child(BTRTMapping.SERVICE_DATA_BLOCK);
		NodeItem srvActFlag = srvData.child(BTRTMapping.SERVICE_ACTION_FLAG);
		String action = srvActFlag.getData();
		
		String ENABLE = "SRAF1";
		String CANCEL = "SRAF2";
		String UPDATE = "SRAF3";
		
		if (CANCEL.equals(action)){
			ApplicationElement endDate = installElement(AppElements.END_DATE, serviceObject);
			endDate.set(new Date());
		}
		
		// CUSTOMER block have COMMAND block without value. Let's add it.
		ApplicationElement cstCmd = customer.retrive(AppElements.COMMAND);
		cstCmd.set(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);		
		
		// All CARD blocks have COMMAND blocks without values.
		ApplicationElement cardCmd = card.retrive(AppElements.COMMAND);
		cardCmd.set(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		
		// For BTRT35 we need to use card's contract. So we search this contract and use it's contractNumber
		String cardNumber = card.tryRetrive(AppElements.CARD_NUMBER).getValueV();
		if (cardNumber != null){
			Contract contractObject = contractByCard(cardNumber);
			if (contractObject != null){
				setupContractElement(contractObject, contract);
				ApplicationElement contractCommand = installElement(AppElements.COMMAND, contract);
				contractCommand.set(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);						
			}
		}
		
		String command = null;
		// If BTRT35 define mobile phone number we must define it as CONTACT for CARDHOLDER
		if (CANCEL.equals(action)){
			command = ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED;
		} else {
			command = ApplicationConstants.COMMAND_CREATE_OR_UPDATE;
		}
		
		NodeItem smsSrv = addSrv.child(BTRTMapping.SMS_SERVICE_BLOCK);
		NodeItem mblPhone = smsSrv.child(BTRTMapping.MOBILE_PHONE);
		
		String mobilePhone = mblPhone.getData();
		ApplicationElement contact = installElement(AppElements.CONTACT, cardholder);
		ApplicationElement cntCmd = installElement(AppElements.COMMAND, contact);
		cntCmd.set(command);
		ApplicationElement cntType = installElement(AppElements.CONTACT_TYPE, contact);
		cntType.set("CNTTNTFC");
		ApplicationElement cntData = installElement(AppElements.CONTACT_DATA, contact);
		ApplicationElement cntMethod = installElement(AppElements.COMMUN_METHOD, cntData);
		cntMethod.set("CMNM0001");
		ApplicationElement cntAddress = installElement(AppElements.COMMUN_ADDRESS, cntData);
		cntAddress.set(mobilePhone);
	}

	private boolean installContractNumberByAccountNumber(String accountNumber, ApplicationElement contract)
			throws Exception {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", language);
		filters[1] = new Filter("accountNumber", accountNumber);
		filters[1].setCondition("=");
		
		SelectionParams params = new SelectionParams(filters);
		
		Account[] accounts = accountsDao.getAccounts(userSessionId, params);
		
		if (accounts.length == 0) {
			return false; 
		}
		Long contractId= accounts[0].getContractId();

		params = SelectionParams.build("CONTRACT_ID", contractId, "LANG", language);
		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", params.getFilters());
		paramsMap.put("tab_name", "CONTRACT");
		Contract[] contracts = productsDao.getContractsCur(userSessionId, params, paramsMap);
		if (contracts.length < 1){
			String errorMessage = String.format("Contract with contract ID '%s' not found ", contractId.toString());
			throw new IllegalArgumentException(errorMessage);
		}
		Contract contractObject = contracts[0];
		String contractNumberValue = contractObject.getContractNumber();
		
		ApplicationElement contractNumber = installElement(AppElements.CONTRACT_NUMBER, contract);
		contractNumber.set(contractNumberValue);
		
		ApplicationElement startDate = installElement(AppElements.START_DATE, contract);
		startDate.set(contractObject.getStartDate());
		
		return true;
	}
	
	private void setupContractElement(Contract contractObject, ApplicationElement contractElement) throws Exception{
		String contractNumberValue = contractObject.getContractNumber();
		
		ApplicationElement contractNumber = installElement(AppElements.CONTRACT_NUMBER, contractElement);
		contractNumber.set(contractNumberValue);
		
		ApplicationElement startDate = installElement(AppElements.START_DATE, contractElement);
		startDate.set(contractObject.getStartDate());
	}
	
	private Contract contractByCard(String cardNumber){
		Contract result = null;
		List<Filter> filters = new ArrayList<Filter>();
		filters.add(new Filter("lang", language));
		Filter f = new Filter("cardNumber", cardNumber);
		f.setCondition("=");
		filters.add(f);
		SelectionParams sp = new SelectionParams(filters);
		Card[] cards = issuingDao.getCards(userSessionId, sp);
		if (cards.length == 0){
			return result;
		}
		Long contractId = cards[0].getContractId();
		sp = SelectionParams.build("CONTRACT_ID", contractId, "LANG", language);
		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", sp.getFilters());
		paramsMap.put("tab_name", "CONTRACT");
		Contract[] contracts = productsDao.getContractsCur(userSessionId, sp, paramsMap);
		if (contracts.length != 0){
			result = contracts[0];
		}
		return result;
	}
	
	private Contract contractByAccount(String accountNumber){
		Contract result = null;
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", language);
		filters[1] = new Filter("accountNumber", accountNumber);
		filters[1].setCondition("=");
		
		SelectionParams params = new SelectionParams(filters);
		
		Account[] accounts = accountsDao.getAccounts(userSessionId, params);
		
		if (accounts.length == 0) {
			return result; 
		}
		Long contractId= accounts[0].getContractId();

		params = SelectionParams.build("CONTRACT_ID", contractId, "LANG", language);
		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", params.getFilters());
		paramsMap.put("tab_name", "CONTRACT");
		Contract[] contracts = productsDao.getContractsCur(userSessionId, params, paramsMap);
		if (contracts.length != 0){
			result = contracts[0];
		}
		return result;		
	}
	

	private void installContractNumber(ApplicationElement customerNumber, ApplicationElement contract) throws Exception {
		SelectionParams sp;
		String customerNumberValue = customerNumber.getValueV();
		sp = SelectionParams.build("customerNumber", customerNumberValue);
		Customer[] customers = productsDao.getCustomersLight(userSessionId, sp, language);
		if (customers.length < 1) {
			String errorMessage = String.format("Customer with customer number '%s' not found ", customerNumberValue);
			throw new IllegalArgumentException(errorMessage); 
		}
		Customer customerObject = customers[0];
		Long contractId= customerObject.getContractId();

		sp = SelectionParams.build("CONTRACT_ID", contractId, "LANG", language);
		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", sp.getFilters());
		paramsMap.put("tab_name", "CONTRACT");
		Contract[] contracts = productsDao.getContractsCur(userSessionId, sp, paramsMap);
		if (contracts.length < 1){
			String errorMessage = String.format("Contract with contract ID '%s' not found ", contractId.toString());
			throw new IllegalArgumentException(errorMessage);
		}
		Contract contractObject = contracts[0];
		String contractNumberValue = contractObject.getContractNumber();
		
		ApplicationElement contractNumber = installElement(AppElements.CONTRACT_NUMBER, contract);
		contractNumber.set(contractNumberValue);
		
		ApplicationElement startDate = installElement(AppElements.START_DATE, contract);
		startDate.set(contractObject.getStartDate());
		
		// if we're here than the contract exists and we need to use it
		ApplicationElement contractCommand = contract.tryRetrive(AppElements.COMMAND);
		if (contractCommand == null) {
			contractCommand = installElement(AppElements.COMMAND, contract);
		}
		contractCommand.set(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
	}
	
	private void setInnerId(ApplicationElement element, Map<String, Integer> innerMap) {
		Integer innerId = innerMap.get(element.getName());
		if (innerId == null) {
			innerId = 1;
		} else {
			innerId++;
		}
		innerMap.put(element.getName(), innerId);
		element.setInnerId(innerId);
	}
	
	private int retriveMaxCardSeqNumber(String cardNumber){
		String query = 
		"select max(ci.seq_number) from iss_card_instance ci" +
		" left join iss_ui_card_vw c" + 
		" on ci.card_id = c.id" + 
		" where c.card_number = ?";
		
		PreparedStatement stmt = null;
		ResultSet rs = null;
		int result = 1;
		try {
			stmt = con.prepareStatement(query);
			stmt.setString(1, cardNumber);
			rs = stmt.executeQuery();
			if (rs.next()){
				result = rs.getInt(1);
			}
		} catch (SQLException e) {
			logger.error(e);
		} finally {
			if (stmt != null) try {stmt.close();} catch (SQLException e) {}
		}
		return result;
	}
	
	private int decodeBTRTType(String btrtType){
		String btrtNumberStr = btrtType.substring(4);
		int btrtNumber = -1; 
		try {
			btrtNumber = Integer.decode(btrtNumberStr);
		} catch (NumberFormatException e){
			logger.error(e);
		}
		return btrtNumber;
	}
	
	private ApplicationElement installElement(String childName, ApplicationElement parent) throws Exception{
		ApplicationElement child = elementsMap.get(childName);
		child = child.clone();
		child.setInnerId(1);
		setDataAndParent(child, parent);
		parent.getChildren().add(child);
		return child;
	}
	
	/**
	 * Performs ApplicationElement::getChildrenByName recursively 
	 */
	private List<ApplicationElement> collectAll(ApplicationElement parent, String elementName){
		List<ApplicationElement> result = parent.getChildrenByName(elementName);
		for (ApplicationElement child : parent.getChildren()){
			List<ApplicationElement> childResult = collectAll(child, elementName);
			result.addAll(childResult);
		}
		return result;
	}
	
	/**
	 * It's similar to setDataAndParent, but performs the task recursively
	 */
	private void setDataAndParentRec(ApplicationElement target, ApplicationElement parent) throws Exception{
		setDataAndParent(target, parent);
		if (target.isHasChildren()){
			for (ApplicationElement child : target.getChildren()){
				setDataAndParentRec(child, target);
			}
		}
	}
	
	private ApplicationElement getChildElement(ApplicationElement appTree, String childName,
			Integer innerId) {
		ApplicationElement tmpEl = appTree.getChildByName(childName, innerId);
		if (tmpEl == null) {
			ApplicationElement el = elementsMap.get(childName);
			if (el != null) {
				try {
					tmpEl = el.clone();
				} catch (CloneNotSupportedException e) {
					logger.warn("", e);
					tmpEl = new ApplicationElement();
				}
			} else {
				if (tmpEl == null) {
					tmpEl = new ApplicationElement();
				}
				tmpEl.setName(childName);
			}
			tmpEl.setInnerId(1);
		}

		return tmpEl;
	}
	
	private void setObjectIds(ApplicationElement appTree) throws Exception {
		for (Long dataId : refDataIdsMap.keySet()) {
			String linkId = refDataIdsMap.get(dataId);
			ApplicationElement el = refElsMap.get(dataId);
			ApplicationElement link = appIdsMap.get(linkId);
			if (link != null) {
				if (AppElements.ACCOUNT.equals(el.getName())){
					ApplicationElement accountObject = installElement(AppElements.ACCOUNT_OBJECT, el);
					accountObject.set(link.getDataId());
					ApplicationElement accountLinkFlag = installElement(AppElements.ACCOUNT_LINK_FLAG, accountObject);
					accountLinkFlag.set(1);
				}
			}
		}
	}
	
	private void createAppTree(NodeItem application, ApplicationElement appTree/*,
			List<ApplicationRec> appAsArray*/) throws Exception {
		if (application.getName().equals(BTRTMapping.SEQUENCE.getCode()) 
				|| application.getName().equals(BTRTMapping.VERSION.getCode())) 
			return;
		/*
		if (!BLACK_CODES.contains(application.getName())) {
			appAsArray.add(new ApplicationRec(appTree));
		}
		*/
		List<NodeItem> nodeList = application.getChildren();
		Map<String, Integer> innerMap = new HashMap<String, Integer>();

		for (NodeItem child : nodeList) {
			
			BTRTMapping nodeName = BTRTMapping.get(child.getName());
			if (nodeName == null) continue;
			String name = nodeName.toString();
			
			ApplicationElement newEl = new ApplicationElement();
			try {
				if (BTRTMapping.REFERENCE.getCode().equals(child.getName())) {
					setRefBlock(child);
				}
				if (BTRTMapping.ADDITIONAL_SERVICE_BLOCK.getCode().equals(child.getName())) {
					addServiceBlock(child);
				}
				ApplicationElement tmpEl = elementsMap.get(name);
				newEl = tmpEl.clone();
			} catch (Exception e1) {
				logger.trace("Cannot find element \'" + child.getName() + "-" + name + "\'");
				//TODO: temporarily coding - fixed later
				continue;
			}

			setDataAndParent(newEl, appTree);

//			if (BTRTMapping.LANGUAGE_CODE.toString().equals(name)) {
//				newEl.setMultiLang(true);
//				newEl.setValueLang(child.getData());
//			}
			if (child.getLang() != null) {
				newEl.setMultiLang(true);
				newEl.setValueLang(child.getLang());
			}
			
			String id = getSequence(child);
			if (id != null && !id.equals("")) {
				appIdsMap.put(id, newEl);
				
				if (BTRTMapping.ACCOUNT.getCode().equals(child.getName())) {
					sequenceAccount = id;
				}
				
				if (BTRTMapping.CARD.getCode().equals(child.getName())) {
					sequenceCard = id;
				}
			}

			if (child.getData() != null) {
				String val = child.getData();
				
				try {
					if (newEl.isNumber()) {
						if (val != null && !val.equals("")) {
							newEl.setValueN(new BigDecimal(val));
						} else {
							newEl.setValueN((BigDecimal)null);
						}
					} else if (newEl.isDate()) {
						String format = BTRTMapping.get(child.getName()).getValue();
						SimpleDateFormat sdf = new SimpleDateFormat(format);
						newEl.setValueD(sdf.parse(val));
					} else if (newEl.isChar()) {
						newEl.setValueV(val);
					} else {
						newEl.setValueV(val);
					}
				} catch (Exception e) {
					System.out.println("Error with " + newEl.getName());
					logger.error("Error with " + newEl.getName(), e);
				}
			} else {
				if (BTRTMapping.SERVICE_OBJECT.toString().equals(newEl.getName())) {
					if (child.getSubDatas().get(BTRTConverter.ACCOUNT_TYPE) != null) {
						//this is service element -> set link to account block
						ApplicationElement accountElement = appIdsMap.get(sequenceAccount);
						newEl.setValueN(BigDecimal.valueOf(accountElement.getDataId()));
					}
					if (child.getSubDatas().get(BTRTConverter.CARD_TYPE_ID) != null) {
						//this is service element -> set link to account block
						ApplicationElement cardElement = appIdsMap.get(sequenceCard);
						newEl.setValueN(BigDecimal.valueOf(cardElement.getDataId()));
					}
				}
			}
			Integer innerId = innerMap.get(name);
			if (innerId == null) {
				innerId = 1;
			} else {
				innerId++;
			}
			innerMap.put(name, innerId);
			newEl.setInnerId(innerId);
			appTree.getChildren().add(newEl);

			createAppTree(child, newEl/*, appAsArray*/);
		}
	}
	
	private void setRefBlock(NodeItem refNode) {
		List<NodeItem> childList = refNode.getChildren();
		for (NodeItem item : childList) {
			if (LINK_BLOCK_CODES.contains(item.getName())) {
				setRefInformation(item.getData());
			}
		}
	}
	
	private void setRefInformation(String refData) {
		try {
			String refId = refData.substring(0, 4);
			String sourceId = refData.substring(4);
			refId = refId.replaceFirst("^0+(?!$)", "");
			sourceId = sourceId.replaceFirst("^0+(?!$)", "");
			ApplicationElement source = appIdsMap.get(sourceId);
			refElsMap.put(source.getDataId(), source);
			refDataIdsMap.put(source.getDataId(), refId);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private String getSequence(NodeItem child) {
		List<NodeItem> nodeList = child.getChildren();
		if (nodeList != null && !nodeList.isEmpty() && nodeList.get(0) != null) {
			return nodeList.get(0).getData();
		}
		return null;
	}
	
	private void resetCount() throws Exception {
		try {
			currVal = appDao.getNextDataId(applicationId);
			currVal = currVal - step;
			count = 1;
		} catch (Exception e) {
			throw e;
		} finally {

		}
	}
	
	private void setDataAndParent(ApplicationElement newEl, ApplicationElement parent) throws Exception {
		if (count == step) {
			// need more dataIds from sequence
			resetCount();
		}
		newEl.setParent(parent);
		newEl.setDataId(currVal + count);
		if (parent != null) {
			newEl.setParentDataId(parent.getDataId());
		}
		count++;
	}

	private Application getApplicationInfo(NodeItem appNode, boolean isParsedOk) {
		Application app = new Application();
		List<NodeItem> nodeList = appNode.getChildren();
		
		NodeItem applicationIdNode = appNode.child(BTRTMapping.APPLICATION_ID.getCode());
		String applicationIdStr = applicationIdNode.getData();
		Long applicationId = Long.parseLong(applicationIdStr);
		app.setApplNumber(applicationIdStr);
		
		//NodeItem customerType = new NodeItem(BTRTMapping.CUSTOMER_TYPE.getCode(), CUSTOMER_COMPANY_TYPE);
		//nodeList.add(1, customerType);
		NodeItem applicationDate = new NodeItem(BTRTMapping.APPLICATION_DATE.getCode(), appDate);
		nodeList.add(1, applicationDate);
		
		NodeItem apType = appNode.child(BTRTMapping.APPLICATION_TYPE.getCode());		
		String appTypeData = apType.getData(); // appType = BTRTXX (where XX is numeric text)
		int num = decodeBTRTType(appTypeData);

		if (0 <= num && num <= 50){
			appTypeData = ApplicationConstants.TYPE_ISSUING;
			if (num < 5){
				NodeItem customerType = new NodeItem(BTRTMapping.CUSTOMER_TYPE.getCode(), CUSTOMER_PERSON_TYPE);
				nodeList.add(1, customerType);
			} else if (num <= 8){
				NodeItem customerType = new NodeItem(BTRTMapping.CUSTOMER_TYPE.getCode(), CUSTOMER_COMPANY_TYPE);
				nodeList.add(1, customerType);
			}
		} else if (num >= 50){
			appTypeData = ApplicationConstants.TYPE_ACQUIRING;
		}
		app.setAppType(appTypeData);
		
		if (num == 0x0D){
			app.setFlowId(CHANGE_CLIENT_FLOW);
		} else if (num == 35) {
			app.setFlowId(OPEN_ADDITIONAL_SERVICE_FLOW);
		} else {
			app.setFlowId(DEFAULT_ISS_APPLICATION_FLOW);
		}
		
		for(NodeItem node : nodeList) {
			BTRTMapping codeToName = BTRTMapping.get(node.getName());
			if (BTRTMapping.ORIGIN_APPL_NUMBER.equals(codeToName)) {
//				app.setApplNumber(node.getData());
				appNumber = node.getData();
			} /*else if (BTRTMapping.APPLICATION_TYPE.equals(codeToName)) {
				String appType = node.getData(); // appType = BTRTXX (where XX is numeric text)
				String numStr = appType.substring(4); // get XX only
				int num = -1;
				try {
					num = Integer.parseInt(numStr); // and parse it
				} catch (NumberFormatException e){
					
				}
				if (0 <= num && num <= 50){
					appType = ApplicationConstants.TYPE_ISSUING;
					if (num < 5){
						customerType.setData(CUSTOMER_PERSON_TYPE);
					} else {
						customerType.setData(CUSTOMER_COMPANY_TYPE);
					}
				} else if (num >= 50){
					appType = ApplicationConstants.TYPE_ACQUIRING;
				}
				app.setAppType(appType);				
			}*/
//			if (BTRTMapping.APPLICATION_FLOW_ID.equals(codeToName)) {
//				app.setFlowId(Integer.parseInt(node.getData()));
//			}
			else if (BTRTMapping.PRODUCT_ID.equals(codeToName)) {
				app.setProductId(Integer.parseInt(appNode.getSubDatas().get(BTRTConverter.PRODUCT_ID)));
			}
//			if (BTRTMapping.CONTRACT_TYPE.equals(codeToName)) {
//				app.setContractType(node.getData());
//			}
			else if (BTRTMapping.CUSTOMER_TYPE.equals(codeToName)) {
				app.setCustomerType(node.getData());
			}
//			if (BTRTMapping.APPLICATION_STATUS.equals(codeToName)) {
//				app.setStatus(BTRTUtils.STATUS_PROCESSED_BY_EXT_SYS);
//			}
		}
		String productIdStr = appNode.getSubDatas().get(BTRTConverter.PRODUCT_ID);
		if (productIdStr != null && !productIdStr.isEmpty()){
			app.setProductId(Integer.parseInt(productIdStr));
		}
		app.setStatus(isParsedOk ? BTRTUtils.STATUS_PROCESSED_BY_EXT_SYS : ApplicationStatuses.PROCESSING_FAILED);
		app.setInstId(institutionID);
		app.setAgentId(agentID);
		
		app.setSessionFileId(fileAttributes.getSessionId());
		return app;
	}
	
	public String getAppXml() {
		return appXml;
	}

	public long getTimeBegin() {
		return timeBegin;
	}
	
	/**
	 * This method works with assumption that only one service is defined inside <code>serviceBlock</code>.
	 */
	private void addServiceBlock(NodeItem serviceBlock) {
		for (NodeItem block : serviceBlock.getChildren()) {
			if (block.getChildren() == null) {
				continue;
			}
			
			for (NodeItem innerBlock : block.getChildren()) {
				if (BTRTMapping.SERVICE_LINK_LEVEL.getCode().equals(innerBlock.getName())) {
					if (BTRTMapping.CARD_SERVICE_LINK_LEVEL.getCode().equals(innerBlock.getData())) {
						cardServices.add(serviceBlock);
						
						// it was stated that we won't have card service together with some other services in one
						// application and it's better to ignore account when card service is attached
						ignoreAccount = true; 
						return;
					}
				}
			}
		}
	}
	
	/**
	 * This method assumes that we have only one card in the application and that 
	 * SERVICE_DATA_BLOCK (FF4C) always comes before all other optional blocks and
	 * a lot of other things, that will work only in one case: if everything 
	 * corresponds to the sample application i worked with.
	 */
	private void modifyCardServices(ApplicationElement contract, int btrtNumber, Map<String, Integer> innerMap) throws Exception {
		if (cardServices.isEmpty()) {
			return;
		}
		
		ApplicationElement card = contract.retrive(AppElements.CARD);
		
		for (NodeItem service : cardServices) {
			ApplicationElement serviceNode = installElement(AppElements.SERVICE, contract);
			ApplicationElement serviceObjectNode = installElement(AppElements.SERVICE_OBJECT, serviceNode);
			serviceObjectNode.set(card.getDataId());
			
			String actionFlag = null;
			
			for (NodeItem node : service.getChildren()) {
				if (node.getChildren() == null) {
					continue;
				}
				
				for (NodeItem child : node.getChildren()) {
					if (BTRTMapping.SERVICE_ID.getCode().equals(child.getName())) {
						serviceNode.set(Integer.parseInt(child.getData()));
						setInnerId(serviceNode, innerMap);
					} else if (BTRTMapping.START_DATE.getCode().equals(child.getName())) {
						ApplicationElement startDate = installElement(AppElements.START_DATE, serviceObjectNode);
						
						String format = BTRTMapping.get(child.getName()).getValue();
						SimpleDateFormat sdf = new SimpleDateFormat(format);
						startDate.set(sdf.parse(child.getData()));
					} else if (BTRTMapping.SERVICE_ACTION_FLAG.getCode().equals(child.getName())) {
						ApplicationElement commandObject = installElement(AppElements.COMMAND, serviceObjectNode);
						actionFlag = child.getData();
						
						if (BTRTMapping.SERVICE_ACTION_FLAG_ADD.getCode().equals(actionFlag)
								|| BTRTMapping.SERVICE_ACTION_FLAG_UPDATE.getCode().equals(actionFlag)) {
							commandObject.set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
						} else if (BTRTMapping.SERVICE_ACTION_FLAG_REMOVE.getCode().equals(actionFlag)) {
							commandObject.set(ApplicationConstants.COMMAND_PROCEED_OR_REMOVE);
						} else {
							throw new Exception("ERROR: Unknown service action flag for additional service block.");
						}
					} else if (BTRTMapping.MOBILE_PHONE.getCode().equals(child.getName())) {
						// i hope we always have cardholder
						ApplicationElement cardholder = contract.tryRetrive(AppElements.CARD,
								AppElements.CARDHOLDER);
						ApplicationElement cardholderCommand = cardholder.tryRetrive(AppElements.COMMAND); 
								
						if (cardholderCommand == null) {
							cardholderCommand = installElement(AppElements.COMMAND, cardholder);
						}
						
						if (btrtNumber == 35) {
							cardholderCommand.set(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
						} else {
							cardholderCommand.set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
						}
						// always create new contact
						ApplicationElement contact = installElement(AppElements.CONTACT, cardholder);
						ApplicationElement commandObject = installElement(AppElements.COMMAND, contact);
						
						if (BTRTMapping.SERVICE_ACTION_FLAG_ADD.getCode().equals(actionFlag)
								|| BTRTMapping.SERVICE_ACTION_FLAG_UPDATE.getCode().equals(actionFlag)) {
							commandObject.set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
						} else if (BTRTMapping.SERVICE_ACTION_FLAG_REMOVE.getCode().equals(actionFlag)) {
							commandObject.set(ApplicationConstants.COMMAND_PROCEED_OR_REMOVE);
						} else {
							// shouldn't be here
							throw new Exception("ERROR: Unknown service action flag for additional service block.");
						}
						
						ApplicationElement contactType = installElement(AppElements.CONTACT_TYPE, contact);
						if (btrtNumber == 35) {
							contactType.set("CNTTNTFC"); // contact for notification
						} else {
							contactType.set("CNTTPRMC");
						}
						
						ApplicationElement contactData = installElement(AppElements.CONTACT_DATA, contact);
						ApplicationElement commMethod = installElement(AppElements.COMMUN_METHOD, contactData);
						commMethod.set("CMNM0001");
						ApplicationElement commAddress = installElement(AppElements.COMMUN_ADDRESS, contactData);
						commAddress.set(child.getData());
					}
				}
			}
		}
	}
}
