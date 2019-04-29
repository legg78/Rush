package ru.bpc.sv2.scheduler.process;
import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.commons.vfs.FileObject;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import ru.bpc.sv.ws.application.handlers.AppStageProcessor;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationRec;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ws.ApplicationsWsDao;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.process.btrt.BTRTMapping;
import ru.bpc.sv2.process.btrt.NodeItem;
import ru.bpc.sv2.scheduler.process.converter.BTRTConverter;
import ru.bpc.sv2.scheduler.process.converter.FileConverter;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.AppElementsCache;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import javax.annotation.Resource;
import javax.xml.ws.WebServiceContext;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @deprecated I don't sure whether this FileSaver may be used for some tasks or not. 
 * All the tasks for converting BTRT <-> SV2 applications are done by BTRTSaver. Probably some 
 * legacy processes may use this saver, so i'm just going to leave this here.
 */
public class AppBTRTFileSaver implements FileSaver {
	FileConverter converter 			= null;
	Connection con						= null;
	ProcessFileAttribute fileAttributes = null;
	FileObject fileObject 				= null;
	InputStream inputStream 			= null;

	private Integer traceLevel;
	private Integer traceLimit;
	private Integer traceThreadNumber;

	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static final boolean trace = true;
	
	private ApplicationDao appDao;
	private ApplicationsWsDao appWsDao;
	
	@Resource
	private WebServiceContext wsContext;
	
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
//	private Map<Long, String> documentsMap;;
//	private Map<Long, String> edsMap;
	private Map<String, ApplicationElement> elementsMap;
	private Long applicationId;
	private Long sessionId;
	private String appXml;
	private long timeBegin;
	
	private int institutionID;
	private int agentID; 
	private String appDate;
	
	public void save() throws SQLException, Exception {
		setupTracelevel();

		appDao = new ApplicationDao();
		appWsDao = new ApplicationsWsDao();

		appIdsMap = new HashMap<String, ApplicationElement>();
		refDataIdsMap = new HashMap<Long, String>();
		refElsMap = new HashMap<Long, ApplicationElement>();
//		documentsMap = new HashMap<Long, String.>(3);
//		edsMap = new HashMap<Long, String>(3);
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
		List<NodeItem> nodeItems = btrtReader.readData(inputStream);
//		List<NodeItem> nodeItems = btrtReader.testData();
		if (trace) {
			logger.trace("BTRT Reading. Time (ms): " +
					(System.currentTimeMillis() - readBTRTBegin));
		}
		//remove the first and the last - they're the header and trailer
		getGeneralInfo(nodeItems.remove(0));
		nodeItems.remove(nodeItems.size() - 1);
		for (NodeItem nodeItem : nodeItems) {
			//create application for each nodeItem
			createApplication(nodeItem);
		}
		
		if (trace) {
			logger.trace("BTRT File Saver, Total Time. Time (ms): " +
					(System.currentTimeMillis() - timeBegin));
		}
	}

	private Level getTraceLevel(int dbLevel) {
		switch (dbLevel) {
			case 6: return Level.TRACE;
			case 5: return Level.INFO;
			case 4: return Level.WARN;
			case 3: return Level.ERROR;
			case 2: return Level.FATAL;
			case 1: return Level.OFF;
			default: return Level.INFO;
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
	
	private Long createApplication(NodeItem application) throws SQLException, Exception {
		long appBegin = System.currentTimeMillis();;
		long workBegin = appBegin;
		
		appIdsMap.clear();
		refElsMap.clear();
		refDataIdsMap.clear();
		
		List<ApplicationRec> appAsArray = null;
		try {
			Application app = getApplicationInfo(application);
			
			sessionId = appWsDao.registerSession(null, null);
			if (trace) {
				logger.trace("Register session. Time (ms): " +
						(System.currentTimeMillis() - workBegin));
			}
			workBegin = System.currentTimeMillis();
			appWsDao.createApplication(sessionId, app);
			applicationId = app.getId();

			resetCount();
			ApplicationElement tmpEl = elementsMap.get("APPLICATION");
			ApplicationElement appTree = tmpEl.clone();
			setDataAndParent(appTree, null);
			appTree.setInnerId(1);

			if (trace) {
				logger.trace("APP: " + applicationId + "; Create application. Time (ms): " +
						(System.currentTimeMillis() - workBegin));
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
			appWsDao.modifyApplicationData(sessionId, appAsArray
					.toArray(new ApplicationRec[appAsArray.size()]), applicationId);
//			saveDocuments();
			if (trace) {
				logger.trace("APP: " + applicationId +
						"; Save data (form Oracle array). Time (ms): " +
						(System.currentTimeMillis() - saveDataBegin));
			}

			long processBegin = System.currentTimeMillis();
			try {
//				inputStream.reset();
//				AppStageProcessor appStageProcessor = new AppStageProcessor(app, doc);
				AppStageProcessor appStageProcessor = new AppStageProcessor(app);
				appStageProcessor.setSessionId(sessionId);
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
			appXml = appWsDao.getXml(sessionId, applicationId);
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
				el.setValueN(BigDecimal.valueOf(link.getDataId()));
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
					logger.error("", e);
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
			int refId = Integer.parseInt(refData.substring(0, 4));
			int sourceId = Integer.parseInt(refData.substring(4));
			ApplicationElement source = appIdsMap.get(String.valueOf(sourceId));
			refElsMap.put(source.getDataId(), source);
			refDataIdsMap.put(source.getDataId(), String.valueOf(refId));
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
		NodeItem productID = new NodeItem(BTRTMapping.PRODUCT_ID.getCode(), "1");
		nodeList.add(1, productID);
		NodeItem flowID = new NodeItem(BTRTMapping.APPLICATION_FLOW_ID.getCode(), "1");
		nodeList.add(1, flowID);
		NodeItem contractType = new NodeItem(BTRTMapping.CONTRACT_TYPE.getCode(), "CNTPPRCR");
		nodeList.add(1, contractType);
		NodeItem customerType = new NodeItem(BTRTMapping.CUSTOMER_TYPE.getCode(), "ENTTPERS");
		nodeList.add(1, customerType);
		NodeItem applicationDate = new NodeItem(BTRTMapping.APPLICATION_DATE.getCode(), appDate);
		nodeList.add(1, applicationDate);
		
		for(NodeItem node : nodeList) {
			BTRTMapping codeToName = BTRTMapping.get(node.getName());
//			if (Attribute.APPLICATION_ID.equals(codeToName)) {
//				app.setId(Long.parseLong(node.getData()));
//			}
			if (BTRTMapping.APPLICATION_TYPE.equals(codeToName)) {
				app.setAppType(node.getData());
			}
//			if (Attribute.RECORD_NUMBER.equals(codeToName)) {
//				app.setApplNumber(node.getData());
//			}
			if (BTRTMapping.APPLICATION_FLOW_ID.equals(codeToName)) {
				app.setFlowId(Integer.parseInt(node.getData()));
			}
			if (BTRTMapping.PRODUCT_ID.equals(codeToName)) {
				app.setProductId(Integer.parseInt(node.getData()));
			}
			if (BTRTMapping.CONTRACT_TYPE.equals(codeToName)) {
				app.setContractType(node.getData());
			}
			if (BTRTMapping.CUSTOMER_TYPE.equals(codeToName)) {
				app.setCustomerType(node.getData());
			}
			if (BTRTMapping.APPLICATION_STATUS.equals(codeToName)) {
				app.setStatus(node.getData());
			}
		}
		app.setInstId(institutionID);
		app.setAgentId(agentID);
		app.setSessionFileId(-1L);
		return app;
	}
	
	public FileConverter getConverter() {
		return converter;
	}

	public void setConverter(FileConverter converter) {
		this.converter = converter;
	}

	public Connection getConnection() {
		return con;
	}

	public void setConnection(Connection con) {
		this.con = con;
	}

	public ProcessFileAttribute getFileAttributes() {
		return fileAttributes;
	}

	public void setFileAttributes(ProcessFileAttribute fileAttributes) {
		this.fileAttributes = fileAttributes;
	}

	public FileObject getFileObject() {
		return fileObject;
	}

	public void setFileObject(FileObject fileObject) {
		this.fileObject = fileObject;
	}

	public InputStream getInputStream() {
		return inputStream;
	}

	public void setInputStream(InputStream inputStream) {
		this.inputStream = inputStream;
	}

	public void setSsn(SqlMapSession ssn) {}

	@Override
	public void setTraceLevel(Integer traceLevel) {
		this.traceLevel = traceLevel;
	}

	@Override
	public void setTraceLimit(Integer traceLimit) {
		this.traceLimit = traceLimit;
	}

	@Override
	public void setTraceThreadNumber(Integer traceThreadNumber) {
		this.traceThreadNumber = traceThreadNumber;
	}

	@Override
	public void setThreadNum(int threadNum) {
	}
	
	@Override
	public void setParams(Map<String, Object> params){
	}

	@Override
	public Map<String, Object> getOutParams() {
		return null;
	}

	public String getAppXml() {
		return appXml;
	}

	public long getTimeBegin() {
		return timeBegin;
	}

	@Override
	public void setUserSessionId(Long userSessionId) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setSessionId(Long sessionId) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setUserName(String userName) {
		// TODO Auto-generated method stub
	}

	@Override
	public boolean isRequiredInFiles() {
		return true;
	}

	@Override
	public boolean isRequiredOutFiles() {
		// TODO Auto-generated method stub
		return true;
	}

	@Override
	public void setProcess(ProcessBO proc) {
		// TODO Auto-generated method stub
		
	}

	private void setupTracelevel() {
		Integer level = traceLevel;
		if (level == null) {
			level = SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.TRACE_LEVEL).intValue();
		}
		logger.setLevel(getTraceLevel(level));
	}
}
