package ru.bpc.sv2.scheduler.process;

import ru.bpc.sv.ws.application.handlers.AppStageProcessor;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationRec;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ws.ApplicationsWsDao;
import ru.bpc.sv2.process.btrt.BTRTMapping;
import ru.bpc.sv2.process.btrt.NodeItem;
import ru.bpc.sv2.scheduler.process.converter.BTRTConverter;
import ru.bpc.sv2.scheduler.process.converter.BTRTUtils;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.AppElementsCache;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class AppOARFileSaver extends AbstractFileSaver {
	
	private static final boolean trace = true;
	
	private ApplicationDao appDao;
	private ApplicationsWsDao appWsDao;
	
	private static final String CUSTOMER_PERSON_TYPE = "ENTTPERS";
	private static final String CUSTOMER_COMPANY_TYPE = "ENTTCOMP";
	
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
	private String appXml;
	private long timeBegin;
	
	private int institutionID;
	private String appDate;
	private String appNumber;
	private String sequenceAccount;
	private String sequenceCard;
	
	public void save() throws SQLException, Exception {
		setupTracelevel();
		appDao = new ApplicationDao();
		appWsDao = new ApplicationsWsDao();
		
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
		
		long readBTRTBegin = System.currentTimeMillis();
		BTRTConverter btrtReader = new BTRTConverter();
		btrtReader.setAppDao(appDao);
		btrtReader.setUserSessionId(userSessionId);
		List<NodeItem> nodeItems = btrtReader.readData(inputStream);
		if (trace) {
			logger.trace("BTRT Reading. Time (ms): " +
					(System.currentTimeMillis() - readBTRTBegin));
		}
		//remove the first and the last - they're the header and trailer
		getGeneralInfo(nodeItems.remove(0));
		nodeItems.remove(nodeItems.size() - 1);
		for (NodeItem nodeItem : nodeItems) {
			if (BTRTMapping.APP_FILE_PROCESSING_RESPONSE.getCode().equals(nodeItem.getName())) {
				//process error session log
				processFFFF33(nodeItem);
			} else {
				//create application for each nodeItem
				createApplication(nodeItem);
			}
		}
		
		if (trace) {
			logger.trace("BTRT File Saver, Total Time. Time (ms): " +
					(System.currentTimeMillis() - timeBegin));
		}
	}
	
	private void processFFFF33(NodeItem ffff33) {
		if (trace) {
			loggerDB.debug(new TraceLogInfo(sessionId, "Cannot load app. Error:"));
			NodeItem ff8050 = ffff33.getChildren().get(1);
			for (NodeItem child : ff8050.getChildren()) {
				BTRTMapping codeToName = BTRTMapping.get(child.getName());
				if (BTRTMapping.FILE_PROCESSING_RESULT_MSG.equals(codeToName)) {
					loggerDB.debug(new TraceLogInfo(sessionId, "-----File processing result message: " + child.getData()));
				}
				
				if (BTRTMapping.ORIGINAL_FILE_NAME.equals(codeToName)) {
					loggerDB.debug(new TraceLogInfo(sessionId, "-----Original file name: " + child.getData()));
				}
				
				if (BTRTMapping.FILE_PROCESSING_DATE.equals(codeToName)) {
					loggerDB.debug(new TraceLogInfo(sessionId, "-----File processing date: " + child.getData()));
				}
				
				if (BTRTMapping.FILE_PROCESSING_RESULT_CODE.equals(codeToName)) {
					loggerDB.debug(new TraceLogInfo(sessionId, "-----File processing result code: " + child.getData()));
				}
				
				if (BTRTMapping.FILE_REFERENCE_NUMBER.equals(codeToName)) {
					loggerDB.debug(new TraceLogInfo(sessionId, "-----File reference number: " + child.getData()));
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
//			if (BTRTMapping.AGENT_ID.equals(codeToName)) {
//				agentID = Integer.parseInt(node.getData());
//			}
			if (BTRTMapping.APPLICATION_DATE.equals(codeToName)) {
				appDate = node.getData();
			}
		}
	}
	
	private Long createApplication(NodeItem application) throws SQLException, Exception {
		long appBegin = System.currentTimeMillis();;
		long workBegin = appBegin;
		
		appIdsMap.clear();
		refElsMap.clear();
		refDataIdsMap.clear();
		
		List<ApplicationRec> appAsArray = null;
		try {
			Application app = getApplicationInfo(application);
			
			//find original app by applNumber
			Application originApp = checkOriginalAppByApplNumber(appNumber);
			if (originApp == null) {
				//process session error log
				if (trace) {
					loggerDB.debug(new TraceLogInfo(sessionId, "Cannot find original app of external app with application number: " + appNumber));
				}
				return null;
			} else {
				if (trace) {
					loggerDB.debug(new TraceLogInfo(sessionId, "Found original app with id: " + originApp.getId() + " of external app with application number: " + appNumber));
				}
			}
			app.setAgentId(originApp.getAgentId());
			app.setAppType(originApp.getAppType());
			
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
				logger.trace("APP: " + applicationId + "; Create application. Time (ms): " +
						(System.currentTimeMillis() - workBegin));
				loggerDB.debug(new TraceLogInfo(sessionId, "Create application with id: " + applicationId + " of external app with application number: " + appNumber));
			}

			long createObjectTreeBegin = System.currentTimeMillis();
			appAsArray = new ArrayList<ApplicationRec>();
			
			createAppTree(application, appTree, appAsArray);
			setObjectIds(appTree);

			if (trace) {
				logger.trace("APP: " + applicationId + "; Build object tree. Time (ms): " +
						(System.currentTimeMillis() - createObjectTreeBegin));
			}

			tmpEl = appTree.getChildByName("APPLICATION_ID", 1);
			if (tmpEl == null) {
				tmpEl = getChildElement(appTree, "APPLICATION_ID", 1);
				tmpEl.setValueN(BigDecimal.valueOf(app.getId()));
				setDataAndParent(tmpEl, appTree);
				appAsArray.add(new ApplicationRec(tmpEl));
			}

			long saveDataBegin = System.currentTimeMillis();
			appWsDao.modifyApplicationData(userSessionId, appAsArray
					.toArray(new ApplicationRec[appAsArray.size()]), applicationId);
			if (trace) {
				logger.trace("APP: " + applicationId +
						"; Save data (form Oracle array). Time (ms): " +
						(System.currentTimeMillis() - saveDataBegin));
			}

			long processBegin = System.currentTimeMillis();
			try {
				AppStageProcessor appStageProcessor = new AppStageProcessor(app);
				appStageProcessor.setSessionId(userSessionId);
				appStageProcessor.process();
			} catch (Exception e) {
				logger.error("APP: " + applicationId +
						"; Errors in handlers chain. Application ID = " +
						applicationId, e);
			}

			if (trace) {
				logger.trace("APP: " + applicationId + "; Handlers chain time. Time (ms): " +
						(System.currentTimeMillis() - processBegin));
			}
			
			long getXmlBegin = System.currentTimeMillis();
			appXml = appWsDao.getXml(userSessionId, applicationId);
			if (trace) {
				logger.trace("APP: " + applicationId + "; Time get xml. Time (ms): " +
						(System.currentTimeMillis() - getXmlBegin));
				
				logger.trace("APP: " + applicationId + "; Convert BTRT application. Time (ms): " +
						(System.currentTimeMillis() - appBegin));
				
			}

			return applicationId;
		} finally {
			if (appAsArray != null) {
				appAsArray.clear();
			}
		}
	}
	
	private Application checkOriginalAppByApplNumber(String applNumber) {
		SelectionParams params = new SelectionParams();
		ArrayList<Filter> filters = new ArrayList<Filter>();
		filters.add(Filter.create("appl_number", applNumber));
		filters.add(Filter.create("lang", "LANGENG"));
		params.setFilters(filters);
		List<Application> apps = appDao.getApplications(userSessionId, params);
		if (apps == null || apps.size() == 0) {
			return null;
		}
		return apps.get(0);
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
				for(ApplicationElement child : el.getChildren()) {
					if (BTRTMapping.ACCOUNT_OBJECT.toString().equals(child.getName())) {
						child.setValueN(BigDecimal.valueOf(link.getDataId()));
					}
				}
			}
		}
	}
	
	private void createAppTree(NodeItem application, ApplicationElement appTree,
			List<ApplicationRec> appAsArray) throws Exception {
		if (application.getName().equals(BTRTMapping.SEQUENCE.getCode()) 
				|| application.getName().equals(BTRTMapping.VERSION.getCode())) 
			return;
		
		if (!BLACK_CODES.contains(application.getName())) {
			appAsArray.add(new ApplicationRec(appTree));
		}
		List<NodeItem> nodeList = application.getChildren();
		Map<String, Integer> innerMap = new HashMap<String, Integer>();

		for (NodeItem child : nodeList) {

			String name = BTRTMapping.get(child.getName()).toString();
			
			ApplicationElement newEl = new ApplicationElement();
			try {
				if (BTRTMapping.REFERENCE.getCode().equals(child.getName())) {
					setRefBlock(child);
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

			createAppTree(child, newEl, appAsArray);
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

	private Application getApplicationInfo(NodeItem appNode) {
		Application app = new Application();
		List<NodeItem> nodeList = appNode.getChildren();
		
		//TODO: hard coding product ID, flow ID, contract type, customer type
//		NodeItem productID = new NodeItem(BTRTMapping.PRODUCT_ID.getCode(), "1");
//		nodeList.add(1, productID);
//		NodeItem flowID = new NodeItem(BTRTMapping.APPLICATION_FLOW_ID.getCode(), "1");
//		nodeList.add(1, flowID);
//		NodeItem contractType = new NodeItem(BTRTMapping.CONTRACT_TYPE.getCode(), "CNTPPRCR");
//		nodeList.add(1, contractType);
		NodeItem customerType = new NodeItem(BTRTMapping.CUSTOMER_TYPE.getCode(), CUSTOMER_COMPANY_TYPE);
		nodeList.add(1, customerType);
		NodeItem applicationDate = new NodeItem(BTRTMapping.APPLICATION_DATE.getCode(), appDate);
		nodeList.add(1, applicationDate);
		
		for(NodeItem node : nodeList) {
			BTRTMapping codeToName = BTRTMapping.get(node.getName());
			if (BTRTMapping.ORIGIN_APPL_NUMBER.equals(codeToName)) {
//				app.setApplNumber(node.getData());
				appNumber = node.getData();
			}
			if (BTRTMapping.APPLICATION_TYPE.equals(codeToName)) {
				app.setAppType(node.getData());
			}
//			if (BTRTMapping.APPLICATION_FLOW_ID.equals(codeToName)) {
//				app.setFlowId(Integer.parseInt(node.getData()));
//			}
//			if (BTRTMapping.PRODUCT_ID.equals(codeToName)) {
//				app.setProductId(Integer.parseInt(appNode.getSubDatas().get(BTRTConverter.PRODUCT_ID)));
//			}
//			if (BTRTMapping.CONTRACT_TYPE.equals(codeToName)) {
//				app.setContractType(node.getData());
//			}
			if (BTRTMapping.CUSTOMER_TYPE.equals(codeToName)) {
				app.setCustomerType(node.getData());
			}
//			if (BTRTMapping.APPLICATION_STATUS.equals(codeToName)) {
//				app.setStatus(BTRTUtils.STATUS_PROCESSED_BY_EXT_SYS);
//			}
		}
		app.setProductId(Integer.parseInt(appNode.getSubDatas().get(BTRTConverter.PRODUCT_ID)));
		app.setStatus(BTRTUtils.STATUS_PROCESSED_BY_EXT_SYS);
		app.setInstId(institutionID);

		app.setSessionFileId(-1L);
		return app;
	}
	
	public String getAppXml() {
		return appXml;
	}

	public long getTimeBegin() {
		return timeBegin;
	}
	
}
