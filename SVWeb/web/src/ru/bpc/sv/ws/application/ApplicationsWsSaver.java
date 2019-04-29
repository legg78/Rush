package ru.bpc.sv.ws.application;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import ru.bpc.sv.ws.application.handlers.AppStageProcessor;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationRec;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ws.ApplicationsWsDao;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.utils.UserException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;
import java.io.ByteArrayInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.math.BigDecimal;
import java.util.*;

public class ApplicationsWsSaver {
	private static final Logger logger = Logger.getLogger("SVAP");
	private static final Logger loggerDB = Logger.getLogger("PROCESSES_DB");
	private static final boolean trace = true;

	private Document doc = null;
	private InputStream inputStream = null;

	private ApplicationDao appDao;
	private ApplicationsWsDao appWsDao;

	private static final String LANGUAGE_ATTRIBUTE = "language";

	private long currVal;
	private int step = ApplicationConstants.DATA_SEQUENCE_STEP;
	private int count;
	private Map<String, Long> appIdsMap;
	private Map<Long, ApplicationElement> refElsMap;
	private Map<Long, String> refDataIdsMap;
	private Map<Long, String> documentsMap;
	private List<Long> documentsDataIdList;
	private Map<Long, String> edsMap;
	private Map<Long, String> svEdsMap;
	private Map<String, ApplicationElement> elementsMap;
	private Long applicationId;
	private Long sessionId;
	private String appXml;
	private String userWS;

	private void setObjectIds(ApplicationElement appTree) throws Exception {
		for (Long dataId : refDataIdsMap.keySet()) {
			String linkId = refDataIdsMap.get(dataId);
			ApplicationElement el = refElsMap.get(dataId);
			Long linkDataId = appIdsMap.get(linkId);
			if (el == null || linkDataId == null) {
				throw new UserException("Cannot find application element for ref=" + linkId);
			}
			if (dataId != null) {
				el.setValueN(BigDecimal.valueOf(linkDataId));
			}
		}
	}

	public Long saveOne() throws Exception {
		appDao = new ApplicationDao();
		appWsDao = new ApplicationsWsDao();

		appIdsMap = new HashMap<String, Long>();
		refDataIdsMap = new HashMap<Long, String>();
		refElsMap = new HashMap<Long, ApplicationElement>();
		documentsMap = new HashMap<Long, String>(3);
		edsMap = new HashMap<Long, String>(3);
		svEdsMap = new HashMap<Long, String>(3);
		documentsDataIdList = new ArrayList<Long>();
		long elementsBegin = System.currentTimeMillis();
		if (sessionId == null) {
			sessionId = appWsDao.registerSession(userWS, null);
		}

		ApplicationElement[] elements = appDao.getAllElements();

		elementsMap = new HashMap<String, ApplicationElement>();
		for (ApplicationElement el : elements) {
			elementsMap.put(el.getName(), el);
		}
		if (trace) {
			logger.trace("WEB SERVICE: get elements list: " +
					(System.currentTimeMillis() - elementsBegin));
			loggerDB.trace(new TraceLogInfo(sessionId, "WEB SERVICE: get elements list: " +
					(System.currentTimeMillis() - elementsBegin), EntityNames.APPLICATION, applicationId, userWS));
		}

		long workBegin;
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		DocumentBuilder db = dbf.newDocumentBuilder();
		Document doc = db.parse(inputStream);
		Element application = doc.getDocumentElement();

		appIdsMap.clear();
		refElsMap.clear();
		if (application == null) {
			throw new Exception("Root element in SOAP body is not an application");
		}

		/*
		 * // Filling elements which are not included in the application with system data tmpEl =
		 * getChildElement(appTree, "APPLICATION_ID", 1); tmpEl.setDataId(currVal + count);
		 * tmpEl.setParent(appTree); tmpEl.setParentDataId(appTree.getDataId());
		 * appTree.getChildren().add(tmpEl); count++;
		 */
		List<ApplicationRec> appAsArray = null;
		try {
			workBegin = System.currentTimeMillis();
			XPath xpath = XPathFactory.newInstance().newXPath();
			XPathExpression expr;
			Double result;

			Application app = new Application();
			expr = xpath.compile("/application/application_id");
			result = (Double) expr.evaluate(doc, XPathConstants.NUMBER);
			if (result != null && !result.isNaN()) {
				app.setId(result.longValue());
			}

			expr = xpath.compile("/application/application_type");
			app.setAppType((String) expr.evaluate(doc, XPathConstants.STRING));

			expr = xpath.compile("/application/application_number");
			app.setApplNumber((String) expr.evaluate(doc, XPathConstants.STRING));

			expr = xpath.compile("/application/application_flow_id");
			result = (Double) expr.evaluate(doc, XPathConstants.NUMBER);
			if (result != null && !result.isNaN()) {
				app.setFlowId(result.intValue());
			}

			expr = xpath.compile("/application/institution_id");
			result = (Double) expr.evaluate(doc, XPathConstants.NUMBER);
			if (result != null && !result.isNaN()) {
				app.setInstId(result.intValue());
			}

			expr = xpath.compile("/application/agent_id");
			result = (Double) expr.evaluate(doc, XPathConstants.NUMBER);
			if (result != null && !result.isNaN()) {
				app.setAgentId(result.intValue());
			}

			expr = xpath.compile("/application/product_id");
			result = (Double) expr.evaluate(doc, XPathConstants.NUMBER);
			if (result != null && !result.isNaN()) {
				app.setProductId(result.intValue());
			}

			expr = xpath.compile("/application/appl_prioritized");
			app.setPrioritized((Boolean) expr.evaluate(doc, XPathConstants.BOOLEAN));

			expr = xpath.compile("/application/contract_type");
			app.setContractType((String) expr.evaluate(doc, XPathConstants.STRING));

			expr = xpath.compile("/application/customer_type");
			String customerType = (String) expr.evaluate(doc, XPathConstants.STRING);
			if(customerType.equals("ENTTCOMP")){
				expr = xpath.compile("/application/customer/person/command");
				if(expr != null && !((String) expr.evaluate(doc, XPathConstants.STRING)).isEmpty()) {
					throw new UserException("The message with customer type \"company\" contains a block \"person\"");
				}
			}else if(customerType.equals("ENTTPERS")){
				expr = xpath.compile("/application/customer/company/command");
				if(expr != null && !((String) expr.evaluate(doc, XPathConstants.STRING)).isEmpty()) {
					throw new UserException("The message with customer type \"person\" contains a block \"company\"");
				}
			}

			app.setCustomerType(customerType);

			expr = xpath.compile("/application/application_status");
			app.setStatus((String) expr.evaluate(doc, XPathConstants.STRING));
			if (trace) {
				logger.trace("WEB SERVICE: get fields via xpath: " +
						(System.currentTimeMillis() - workBegin));
				loggerDB.trace(new TraceLogInfo(sessionId, "WEB SERVICE: get fields via xpath: " +
						(System.currentTimeMillis() - workBegin), EntityNames.APPLICATION, applicationId, userWS));
			}
			workBegin = System.currentTimeMillis();
			app.setSessionFileId(-1L);

			if (trace) {
				logger.trace("WEB SERVICE: register session: " +
						(System.currentTimeMillis() - workBegin));
				loggerDB.trace(new TraceLogInfo(sessionId, "WEB SERVICE: register session: " +
						(System.currentTimeMillis() - workBegin), EntityNames.APPLICATION, applicationId, userWS));
			}

			resetCount();
			ApplicationElement tmpEl = elementsMap.get("APPLICATION");
			ApplicationElement appTree = tmpEl.clone();
			expr = xpath.compile("/application");
			Element el = (Element) expr.evaluate(doc, XPathConstants.NODE);
			setDataAndParent(appTree, null, el);
			appTree.setInnerId(1);


			long createObjectTreeBegin = System.currentTimeMillis();
			appAsArray = new ArrayList<ApplicationRec>();
			createAppTree(application, appTree, appAsArray);
			setObjectIds(appTree);

			if (trace) {
				logger.trace("APP: " + applicationId + "; WEB SERVICE: build object tree: " +
						(System.currentTimeMillis() - createObjectTreeBegin));
				loggerDB.trace(new TraceLogInfo(sessionId, "APP: " + applicationId + "; WEB SERVICE: build object tree: " +
						(System.currentTimeMillis() - createObjectTreeBegin), EntityNames.APPLICATION, applicationId, userWS));
			}

			workBegin = System.currentTimeMillis();
			appWsDao.createApplication(sessionId, app, userWS);
			applicationId = app.getId();

			if (trace) {
				logger.trace("APP: " + applicationId + "; WEB SERVICE: create application: " +
						(System.currentTimeMillis() - workBegin));
				loggerDB.trace(new TraceLogInfo(sessionId, "APP: " + applicationId + "; WEB SERVICE: create application: " +
						(System.currentTimeMillis() - workBegin), EntityNames.APPLICATION, applicationId, userWS));
			}

			tmpEl = appTree.getChildByName("APPLICATION_ID", 1);
			if (tmpEl == null) {
				tmpEl = getChildElement(appTree, "APPLICATION_ID", 1);
				tmpEl.setValueN(BigDecimal.valueOf(app.getId()));
				expr = xpath.compile("/application/application_id");
				el = (Element) expr.evaluate(doc, XPathConstants.NODE);
				setDataAndParent(tmpEl, appTree, el);
				appAsArray.add(new ApplicationRec(tmpEl));
			}

			long saveDataBegin = System.currentTimeMillis();
			appWsDao.modifyApplicationData(sessionId, appAsArray
					.toArray(new ApplicationRec[appAsArray.size()]), applicationId, userWS);
			saveDocuments();
			if (trace) {
				logger.trace("APP: " + applicationId +
						"; WEB SERVICE: save data (form Oracle array): " +
						(System.currentTimeMillis() - saveDataBegin));
				loggerDB.trace(new TraceLogInfo(sessionId, "APP: " + applicationId +
						"; WEB SERVICE: save data (form Oracle array): " +
						(System.currentTimeMillis() - saveDataBegin), EntityNames.APPLICATION, applicationId, userWS));
			}

			long processBegin = System.currentTimeMillis();
			try {
				inputStream.reset();
				AppStageProcessor appStageProcessor = new AppStageProcessor(app, doc);
				appStageProcessor.setSessionId(sessionId);
				appStageProcessor.setCount(count);
				appStageProcessor.setCurrVal(currVal);
				appStageProcessor.setUserName(userWS);
				appStageProcessor.process();
			} catch (Exception e) {
				logger.error("APP: " + applicationId +
						"; WEB SERVICE: Errors in handlers chain. Application ID = " +
						applicationId, e);
				loggerDB.error(new TraceLogInfo(sessionId, "WEB SERVICE: Errors in handlers chain. Application ID = " +
						applicationId, EntityNames.APPLICATION, applicationId, userWS), e);
			}

			if (trace) {
				logger.trace("APP: " + applicationId + "; WEB SERVICE: handlers chain time: " +
						(System.currentTimeMillis() - processBegin));
				loggerDB.trace(new TraceLogInfo(sessionId, "APP: " + applicationId + "; WEB SERVICE: handlers chain time: " +
						(System.currentTimeMillis() - processBegin), EntityNames.APPLICATION, applicationId, userWS));
			}
			long getXmlBegin = System.currentTimeMillis();
			appXml = appWsDao.getXml(sessionId, applicationId, userWS);
			if (trace) {
				logger.trace("APP: " + applicationId + "; WEB SERVICE: WS Saver: Time get xml: " +
						(System.currentTimeMillis() - getXmlBegin));
				loggerDB.trace(new TraceLogInfo(sessionId, "APP: " + applicationId + "; WEB SERVICE: WS Saver: Time get xml: " +
						(System.currentTimeMillis() - getXmlBegin), EntityNames.APPLICATION, applicationId, userWS));
			}

			return applicationId;
		} finally {
			if (appAsArray != null) {
				appAsArray.clear();
			}
		}
	}
	@SuppressWarnings("ConstantConditions")
	private void createAppTree(Node application, ApplicationElement appTree, List<ApplicationRec> appAsArray) throws Exception {
		appAsArray.add(new ApplicationRec(appTree));
		NodeList nodeList = application.getChildNodes();
		Map<String, Integer> innerMap = new HashMap<String, Integer>();
		XPath xpath = XPathFactory.newInstance().newXPath();
		XPathExpression expr;
		expr = xpath.compile(".");

		for (int s = 0; s < nodeList.getLength(); s++) {

			Node child = nodeList.item(s);
			if (!(child instanceof Element)) {
				continue;
			}
			Element el = (Element) nodeList.item(s);
			String name = el.getTagName().toUpperCase();
			if (name.contains(":")) {
				// FIXME find a better solution
				name = name.split(":")[1];
			}
			if ("DOCUMENT_CONTENTS".equals(name)) {
				String documentContents = (String) expr.evaluate(el, XPathConstants.STRING);
				documentsMap.put(appTree.getDataId(), documentContents);
				continue;
			}
			if ("CUSTOMER_EDS".equals(name)) {
				String eds = (String) expr.evaluate(el, XPathConstants.STRING);
				edsMap.put(appTree.getDataId(), eds);
				continue;
			}
			if ("SUPERVISOR_EDS".equals(name)) {
				String eds = (String) expr.evaluate(el, XPathConstants.STRING);
				svEdsMap.put(appTree.getDataId(), eds);
				continue;
			}
			ApplicationElement newEl;
			try {
				ApplicationElement tmpEl = elementsMap.get(name);
				newEl = tmpEl.clone();
			} catch (Exception e1) {
				throw new Exception("Cannot find element \'" + name + "\'");
			}

			setDataAndParent(newEl, appTree, el);

			el.setAttribute("dataId", newEl.getDataId().toString());
			if ("DOCUMENT".equals(name)) {
				documentsDataIdList.add(newEl.getDataId());
			}

			String lang = el.getAttribute(LANGUAGE_ATTRIBUTE);
			if (lang != null) {
				newEl.setMultiLang(true);
				newEl.setValueLang(lang);
			} else {
				newEl.setMultiLang(false);
			}

			if (el.hasAttribute("id")) {
				String id = el.getAttribute("id");
				if (id != null && !id.equals("")) {
					appIdsMap.put(id, newEl.getDataId());
					// Value represents unique ID of xml element in application. Must be
					// replaced by real dataID later
				}
			}

			if (el.hasAttribute("ref_id")) {
				String refId = el.getAttribute("ref_id");
				if (refId != null && !refId.equals("")) {
					refElsMap.put(newEl.getDataId(), newEl);
					refDataIdsMap.put(newEl.getDataId(), refId);
				}
			}

			if (el.getFirstChild() != null || el.hasAttribute("value")) {
				String val;
				boolean isValue = true;
				if (newEl.isComplex()) {
					val = el.getAttribute("value");
					if (val != null && !val.equals("")) {
						if ("ACCOUNT_OBJECT".equals(newEl.getName()) ||
								"SERVICE_OBJECT".equals(newEl.getName())) {
							refElsMap.put(newEl.getDataId(), newEl);
							refDataIdsMap.put(newEl.getDataId(), val);
							// Value represents reference to the unique ID of xml element in
							// application (card, account, customer etc.)
							// Must be replaced by real dataID later
							isValue = false;
						}
					}
				} else {
					val = el.getFirstChild().getNodeValue();
				}
				if (isValue) {
					try {
						logger.trace("ApplicationWsSaver.createAppTree(): node name = " + el.getNodeName()
								+ ", dataType = " + newEl.getDataType() + "x" + elementsMap.get(name).getDataType()
								+ ", id = " + newEl.getId() + ", val = '" + val + "'");
						if ("FLEXIBLE_FIELD_VALUE".equals(el.getNodeName().toUpperCase())) {
							NodeList flex = el.getParentNode().getChildNodes();
							if (flex != null) {
								for (int i = 0; i < flex.getLength(); i++) {
									Node node = flex.item(i);
									if (node != null && node instanceof Element) {
										if ("FLEXIBLE_FIELD_NAME".equals(node.getNodeName().toUpperCase())) {
											String fieldName = node.getFirstChild().getNodeValue();
											newEl.setDataType(appDao.getFlexFieldTypeByName(sessionId, fieldName));
											break;
										}
									}
								}
							}
						}
						if (newEl.isNumber()) {
							if (val != null && !val.equals("")) {
								newEl.setValueN(new BigDecimal(val));
							} else {
								newEl.setValueN((BigDecimal)null);
							}
						} else if (newEl.isDate()) {
							Date date = javax.xml.bind.DatatypeConverter.parseDate(el.getFirstChild().getNodeValue()).getTime();
							newEl.setValueD(date);
						} else if (newEl.isChar()) {
							newEl.setValueV(val);
						} else {
							newEl.setValueV(val);
						}
					} catch (Exception e) {
						logger.error("", e);
						loggerDB.error(new TraceLogInfo(sessionId, e.getMessage(), EntityNames.APPLICATION, applicationId, userWS), e);
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

	private void resetCount() throws Exception {
		currVal = appDao.getNextDataId(applicationId);
		currVal = currVal - step;
		count = 1;
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
				tmpEl = new ApplicationElement();
				tmpEl.setName(childName);
			}
			tmpEl.setInnerId(1);
		}

		return tmpEl;
	}

	public Document getDoc() {
		return doc;
	}

	public void setDoc(Document doc) {
		this.doc = doc;
	}

	public InputStream getInputStream() {
		return inputStream;
	}

	public void setInputStream(InputStream inputStream) {
		this.inputStream = inputStream;
	}

	private void setDataAndParent(ApplicationElement newEl, ApplicationElement parent, Element xmlElement) throws Exception {
		if (count == step) {
			// need more dataIds from sequence
			resetCount();
		}
		newEl.setParent(parent);
		if (xmlElement != null) {
			xmlElement.setAttribute("dataId", newEl.getDataId().toString());
		}
		newEl.setDataId(currVal + count);
		if (parent != null) {
			newEl.setParentDataId(parent.getDataId());
		}
		count++;
	}

	public String getXml() {
		return appXml;
	}

	private void saveDocuments() throws Exception {
		FileOutputStream fos = null;
		InputStream ins = null;
		if (documentsDataIdList == null) {
			return;
		}
		
		List<byte[]> bytesList = new ArrayList<byte[]>();
		List<String> savePaths = appWsDao.saveDocuments(sessionId, documentsDataIdList, documentsMap,
				edsMap, svEdsMap, bytesList, userWS);
		int savePathsSize = savePaths.size();
		for (int i = 0; i < savePathsSize; i++) {
			String savePath = savePaths.get(i);
			byte[] decodedBytes = bytesList.get(i);
			if (savePath != null) {
				try {
					ins = new ByteArrayInputStream(decodedBytes);
					fos = new FileOutputStream(savePath);
					byte[] buf = new byte[1024];
					int len;
					while ((len = ins.read(buf)) > 0) {
						fos.write(buf, 0, len);
					}
					fos.flush();
				} finally {
					IOUtils.closeQuietly(fos);
					IOUtils.closeQuietly(ins);
				}
			}
		}
	}

	public void setUserWS(String userWS) {
		this.userWS = userWS;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}
}
