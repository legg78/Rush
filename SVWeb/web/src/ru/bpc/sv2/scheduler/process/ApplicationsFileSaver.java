package ru.bpc.sv2.scheduler.process;

import com.ibatis.sqlmap.client.SqlMapClient;
import com.ibatis.sqlmap.client.SqlMapSession;
import oracle.sql.ARRAY;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationRec;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.common.events.EventConstants;
import ru.bpc.sv2.common.events.RegisteredEvent;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.logic.utility.db.IbatisClient;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.utils.*;

import javax.sql.DataSource;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.*;
import java.io.*;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@SuppressWarnings("unused")
public class ApplicationsFileSaver extends AbstractFileSaver {
	private static final boolean trace = false;

	private static final String LANGUAGE_ATTRIBUTE = "language";
	private static final String PARAM_COMMIT_NUMBER = "COMMIT_NUMBER";
	public static final String SAVEPOINT_NAME = "APP_SAVER_SP";
	private Map<String, ApplicationElement> elementsMap;

	private int step = ApplicationConstants.DATA_SEQUENCE_STEP;

	private XPathExpression exprCurrentNode = null;

	private final String saverName = "ApplicationsFileSaver";
	private int THREAD_NUMBER = 1;
	private int COMMIT_NUMBER = 1;
	protected SqlMapClient sqlClient = IbatisClient.getInstance().getSqlClient();

	@Override
	public void save() throws Exception {
		setupTracelevel();

		if (fileAttributes.getParallelDegree() != null) {
			try {
				THREAD_NUMBER = fileAttributes.getParallelDegree();
				if (THREAD_NUMBER < 1) {THREAD_NUMBER = 1;}
			} catch (Exception e) {
				THREAD_NUMBER = 1;
			}
		}
		try {
			COMMIT_NUMBER = (Integer)getParams().get(PARAM_COMMIT_NUMBER);
		} catch (Exception e) {
			COMMIT_NUMBER = 1;
		}
		COMMIT_NUMBER = 100;
		ExecutorService executor = Executors.newFixedThreadPool(THREAD_NUMBER);

		ApplicationDao appDao = new ApplicationDao();

		ApplicationElement[] elements = appDao.getAllElements();

		elementsMap = new HashMap<String, ApplicationElement>();
		for (ApplicationElement el : elements) {
			elementsMap.put(el.getName(), el);
		}

		initXpath();

		long appBegin = System.currentTimeMillis();
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		DocumentBuilder db = dbf.newDocumentBuilder();
		Document doc = db.parse(inputStream);
		Document doc1;
		NodeList applications = doc.getDocumentElement().getChildNodes();
		int i = 0;

		if (applications instanceof Node
				&& ApplicationConstants.APPLICATION_MAIN_NODE.equalsIgnoreCase(((Node) applications).getNodeName())) {
			executor.execute(new ApplicationSaveTask((Node) applications));
			i++;
		} else {
			AppListArray[] appListArray = new AppListArray[THREAD_NUMBER];
			for (int s = 0; s < THREAD_NUMBER; s++) {
				appListArray[s] = new AppListArray();
			}
//			List<Node> applicationsList = new ArrayList<Node>();
			for (int s = 0; s < applications.getLength(); s++) {
				Node application = applications.item(s);
				if (!(application instanceof Element)) {
					continue;
				}
				String xml = nodeToString(application);
				doc1 = db.parse(new ByteArrayInputStream(xml.getBytes("UTF-8")));
				NodeList applicationNode = doc1.getDocumentElement().getChildNodes();
				if (applicationNode instanceof Node
						&& ApplicationConstants.APPLICATION_MAIN_NODE.equalsIgnoreCase(((Node) applicationNode).getNodeName())) {
					appListArray[i % THREAD_NUMBER].appToList((Node)applicationNode);
					i++;
//					applicationsList.add((Node)applicationNode);
				}

			}
			for (int s = 0; s < THREAD_NUMBER; s++) {
				executor.execute(new ApplicationSaveTask(appListArray[s].getApplications(), s));
			}

		}
		executor.shutdown();
		while (!executor.isTerminated()) {
			try {
				Thread.sleep(100L);
			} catch (InterruptedException ignored) {
			}
		}
		logger.info(saverName + ": " + i + " applications have been saved in "
				+ (System.currentTimeMillis() - appBegin) + " ms");
		loggerDB.info(new TraceLogInfo(sessionId, saverName + ": " + i + " applications have been saved in "
				+ (System.currentTimeMillis() - appBegin) + " ms"));
	}


	private void initXpath() throws XPathExpressionException {
		XPath xpath = XPathFactory.newInstance().newXPath();
		exprCurrentNode = xpath.compile(".");
	}

	private ApplicationElement getChildElement(ApplicationElement appTree, String childName, Integer innerId) {
		ApplicationElement tmpEl = appTree.getChildByName(childName, innerId);
		if (tmpEl == null) {
			tmpEl = new ApplicationElement();
			ApplicationElement el = elementsMap.get(childName);
			if (el != null) {
				el.clone(tmpEl);
			} else {
				tmpEl.setName(childName);
			}
			tmpEl.setInnerId(1);
		}

		return tmpEl;
	}

	private String getElementName(Element el) {
		String name = el.getTagName().toUpperCase();
		if (name.contains(":")) {
			// FIXME find a better solution
			name = name.split(":")[1];
		}
		return name;
	}

	private class ApplicationSaveTask implements Runnable {
		private Node application;
		private long currVal;
		private int count;
		private ApplicationDao appDao;

		private Map<String, Long> appIdsMap;
		private Map<Long, ApplicationElement> refElsMap;
		private Map<Long, String> refDataIdsMap;
		private Map<Long, String> documentsMap;
		private List<Long> documentsDataIdList;
		private Map<Long, String> edsMap;
		private Map<Long, String> svEdsMap;
		private List<Node> applicationsList;
		private int THREAD = 0;
		private Connection connection;
		private SqlMapSession ssn;

		public ApplicationSaveTask(Node application) {
			this.application = application;
		}
		public ApplicationSaveTask(List<Node> applicationsList, int THREAD) {
			this.applicationsList = applicationsList;
			this.THREAD = THREAD;
		}

		public void run() {

			try {
				getIbatisSession();
				appDao = new ApplicationDao();
				connection = JndiUtils.getConnection();
				connection.setAutoCommit(false);
				String userName = (String)getParams().get("USER_NAME");
				setContext(userName==null?"ADMIN":userName, sessionId, connection);
				ssn.setUserConnection(connection);

				if (application != null) {
					processApplication(application);
				} else if (applicationsList != null && applicationsList.size() > 0){
					int threadCount = 0;
					for (Node anApplicationsList : applicationsList) {
						threadCount++;
						application = anApplicationsList;
						processApplication(application);
						if (threadCount % COMMIT_NUMBER == 0) {
							//connection.commit();
							CallableStatement cstmt = null;
							try {
								cstmt = connection.prepareCall("COMMIT WRITE BATCH NOWAIT");
								cstmt.execute();
							}finally {
								DBUtils.close(cstmt);
							}
						}
					}
				}
			} catch (Throwable t) {
				try {
					if (connection != null) {
						connection.rollback();
					}
				} catch (SQLException e) {
					logger.error("", e);
				}
				logger.error("", t);
			} finally {
				if (connection!=null) {
					try {
						connection.commit();
						connection.close();
					} catch (SQLException e) {
						logger.error("", e);
					}
				}
			}
		}


		private void processApplication(Node application) {
			Long applicationId = null;
			List<ApplicationRec> appAsArray;
			Savepoint savepoint = null;
			try {
				savepoint = connection.setSavepoint(SAVEPOINT_NAME);

				if (appIdsMap == null) {
					appIdsMap = new HashMap<String, Long>();
				} else {
					appIdsMap.clear();
				}
				if (refDataIdsMap == null) {
					refDataIdsMap = new HashMap<Long, String>();
				} else {
					refDataIdsMap.clear();
				}
				if (refElsMap == null) {
					refElsMap = new HashMap<Long, ApplicationElement>();
				} else {
					refElsMap.clear();
				}
				if (documentsMap == null) {
					documentsMap = new HashMap<Long, String>(3);
				} else {
					documentsMap.clear();
				}
				if (edsMap == null) {
					edsMap = new HashMap<Long, String>(3);
				} else {
					edsMap.clear();
				}
				if (svEdsMap == null) {
					svEdsMap = new HashMap<Long, String>(3);
				} else {
					svEdsMap.clear();
				}
				if (documentsDataIdList == null) {
					documentsDataIdList = new ArrayList<Long>();
				} else {
					documentsDataIdList.clear();
				}

				long workBegin = System.currentTimeMillis();
				Application app = new Application();
				NodeList nodeList = application.getChildNodes();
				for (int s = 0; s < nodeList.getLength(); s++) {
					Node child = nodeList.item(s);
					if (!(child instanceof Element)) {
						continue;
					}
					Element el = (Element) child;
					String name = getElementName(el);
					if ("APPLICATION_TYPE".equals(name)) {
						String tmp = el.getFirstChild().getNodeValue();
						if (tmp != null) {
							app.setAppType(tmp);
						}
					} else if ("APPLICATION_NUMBER".equals(name)) {
						String tmp = el.getFirstChild().getNodeValue();
						if (tmp != null) {
							app.setApplNumber(tmp);
						}
					} else if ("APPLICATION_FLOW_ID".equals(name)) {
						String tmp = el.getFirstChild().getNodeValue();
						if (tmp != null) {
							app.setFlowId(Integer.parseInt(tmp));
						}
					} else if ("INSTITUTION_ID".equals(name)) {
						String tmp = el.getFirstChild().getNodeValue();
						if (tmp != null) {
							app.setInstId(Integer.parseInt(tmp));
							logger.trace("THREAD: " + THREAD + "; inst: " + app.getInstId());
						}
					} else if ("AGENT_ID".equals(name)) {
						String tmp = el.getFirstChild().getNodeValue();
						if (tmp != null) {
							app.setAgentId(Integer.parseInt(tmp));
						}
					} else if ("CUSTOMER_TYPE".equals(name)) {
						String tmp = el.getFirstChild().getNodeValue();
						if (tmp != null) {
							app.setCustomerType(tmp);
						}
					} else if ("APPLICATION_STATUS".equals(name)) {
						String tmp = el.getFirstChild().getNodeValue();
						if (tmp != null) {
							app.setStatus(tmp);
						}
					} else if ("CUSTOMER".equals(name)) {
						NodeList nodeList1 = el.getChildNodes();
						for (int s1 = 0; s1 < nodeList1.getLength(); s1++) {
							Node child1 = nodeList1.item(s1);
							if (!(child1 instanceof Element)) {
								continue;
							}
							Element el1 = (Element) child1;
							String name1 = getElementName(el1);
							if ("CUSTOMER_NUMBER".equals(name1)) {
								String tmp =  (el1.getFirstChild() != null) ? el1.getFirstChild().getNodeValue() : null;
								if (tmp != null)
									app.setCustomerNumber(tmp);
							} else if ("CONTRACT".equals(name1)) {
								NodeList nodeList2 = el1.getChildNodes();
								for (int s2 = 0; s2 < nodeList2.getLength(); s2++) {
									Node child2 = nodeList2.item(s2);
									if (!(child2 instanceof Element)) {
										continue;
									}
									Element el2 = (Element) child2;
									String name2 = getElementName(el2);
									if ("CONTRACT_TYPE".equals(name2)) {
										String tmp = el2.getFirstChild().getNodeValue();
										if (tmp != null) {
											app.setContractType(tmp);
										}
										break;
									}
								}
								break; //there is no need to search more, customer number already found if present
							}
						}
					}
				}
				logger.trace("THREAD: " + THREAD + "; " + saverName + ": get fields: " +
						(System.currentTimeMillis() - workBegin));

				long createBegin = System.currentTimeMillis();
				app.setSessionFileId(fileAttributes.getSessionId());

				createApplication(app);
				applicationId = app.getId();

				resetCount(applicationId);
				ApplicationElement tmpEl = elementsMap.get("APPLICATION");
				ApplicationElement appTree = tmpEl.clone();

				setDataAndParent(appTree, null, (Element)application, applicationId);
				appTree.setInnerId(1);

				logger.trace("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + ": create application: " +
						(System.currentTimeMillis() - createBegin));

				long createObjectTreeBegin = System.currentTimeMillis();
				appAsArray = new ArrayList<ApplicationRec>();
				createAppTree(application, appTree, appAsArray, applicationId);
				boolean error;
				try {
					error = !setObjectIds(applicationId);

					tmpEl = appTree.getChildByName("APPLICATION_ID", 1);
					if (tmpEl == null) {
						tmpEl = getChildElement(appTree, "APPLICATION_ID", 1);
						tmpEl.setValueN(BigDecimal.valueOf(app.getId()));
						Element appEl = null;
						for (int s = 0; s < nodeList.getLength(); s++) {
							Node child = nodeList.item(s);
							if (!(child instanceof Element)) {
								continue;
							}
							Element el = (Element) child;
							String name = getElementName(el);
							if ("APPLICATION_ID".equals(name)) {
								appEl = el;
								break;
							}
						}
						setDataAndParent(tmpEl, appTree, appEl, applicationId);
						appAsArray.add(new ApplicationRec(tmpEl));
					}

					logger.trace("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + ": build object tree: " +
							(System.currentTimeMillis() - createObjectTreeBegin));

					long saveDataBegin = System.currentTimeMillis();
					modifyApplicationData(appAsArray.toArray(new ApplicationRec[appAsArray.size()]), applicationId);
					saveDocuments();
					logger.trace("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + ": save data (form Oracle array): "
							+ (System.currentTimeMillis() - saveDataBegin));
				} catch (Exception e) {
					String msg = "THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName +
							": failed to process application: " + ExceptionUtils.getExceptionMessage(e);
					logger.error(msg);
					loggerDB.error(new TraceLogInfo(sessionId, msg, EntityNames.APPLICATION, applicationId));
					error = true;
				}

				if (error) {
					app.setNewStatus(ApplicationStatuses.PROCESSING_FAILED);
					ssn.update("application.modify-application", app);
					app.setStatus(ApplicationStatuses.PROCESSING_FAILED);
					RegisteredEvent event = formEvent(EventConstants.APPLICATION_PROCESSING_FAILED, app);
					ssn.update("events.register-event", event);
				}

				logger.trace("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + ": Total for application: "
						+ (System.currentTimeMillis() - workBegin));
				loggerDB.trace(new TraceLogInfo(sessionId, "THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName
						+ ": Total for application: " + (System.currentTimeMillis() - workBegin),
						EntityNames.APPLICATION, applicationId));

			} catch (Exception e) {
				logger.error("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + "; app: " + nodeToString(application), e);
				loggerDB.error(new TraceLogInfo(sessionId, "THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName
						+ ": ERROR: " + e.getMessage(),	EntityNames.APPLICATION, applicationId), e);
				try {
					if (savepoint != null) {
						connection.rollback(savepoint);
					}
				} catch (SQLException e1) {
					logger.error("", e1);
				}
			}
		}

		private RegisteredEvent formEvent(String eventType, Application app) {
			RegisteredEvent event = new RegisteredEvent();
			event.setEffectiveDate(new Date());
			event.setEventType(eventType);
			event.setEntityType(EntityNames.APPLICATION);
			event.setObjectId(app.getId());
			event.setInstId(app.getInstId());
			return event;
		}

		private void resetCount(Long applicationId) throws Exception {
			try {
				Map<String, Object> params = new HashMap<String, Object>();
				params.put("appId", applicationId);
				ssn.queryForObject("application.get-next-appl-data-id", params);
				currVal = Long.parseLong(params.get("dataId").toString());
				currVal = currVal - step;
				count = 1;
			} catch (Exception e) {
				String params = "currVal = " + currVal + "; count = " + count;
				logger.error("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + "; resetCount:" + params +";", e);
				loggerDB.error(new TraceLogInfo(sessionId, "THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName
						+ "; resetCount: " + params + ";" + e.getMessage(), EntityNames.APPLICATION, applicationId), e);
				throw e;
			}
		}

		private boolean setObjectIds(Long applicationId) throws Exception {
			String linkId = null;
			ApplicationElement el = null;
			Long linkDataId = null;
			boolean result = true;
			for (Long dataId : refDataIdsMap.keySet()) {
				try {
					linkId = refDataIdsMap.get(dataId);
					el = refElsMap.get(dataId);
					linkDataId = appIdsMap.get(linkId);
					if (el == null || linkDataId == null) {
						throw new Exception("Cannot find application element for ref=" + linkId);
					}
					if (dataId != null) {
						el.setValueN(BigDecimal.valueOf(linkDataId));
					}
				} catch (Exception e) {
					logger.error(e.getMessage());
					loggerDB.error(new TraceLogInfo(sessionId, e.getMessage()));
					String params = "dataId = " + dataId + "; linkId = " + linkId + "; linkDataId = " + linkDataId + "; el:" + (el == null ? null : el.getName());
					logger.error("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + "; setObjectIds: refDataIdsMap = " + refDataIdsMap.toString());
					logger.error("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + "; setObjectIds: refElsMap = " + refElsMap.toString());
					logger.error("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + "; setObjectIds: appIdsMap = " + appIdsMap.toString());
					logger.error("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + "; app : " + nodeToString(application));
					logger.error("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + "; setObjectIds:" + params + ";", e);
					loggerDB.error(new TraceLogInfo(sessionId, "THREAD: " + THREAD + "; " + saverName + "; setObjectIds:params.", EntityNames.APPLICATION, applicationId), e);
					result = false;
				}
			}
			return result;
		}

		protected void getIbatisSession() throws SystemException {
			try {
				ssn = sqlClient.openSession();
			} catch (Exception e) {
				throw new SystemException(e.getMessage());
			}
		}

		private void setContext(String userName, Long sessionId, Connection con) throws Exception {
			CallableStatement cstmt = null;
			try {
				cstmt = con.prepareCall("{ call com_ui_user_env_pkg.set_user_context( " +
						"  i_user_name  	=> ?" +
						", io_session_id	=> ?)}"
						);

				cstmt.setString(1, userName);
				cstmt.setLong(2, sessionId);
				cstmt.executeUpdate();
				con.commit();
			} catch (Exception e) {
				try {
					con.rollback();
				} catch (SQLException ignored) {}
				throw e;
			} finally {
				if (cstmt != null) {
					try {
						cstmt.close();
					} catch (SQLException ignored) {}
				}
			}

		}

		private void createApplication(Application app) throws Exception {
			try {
				Integer splitHash = null;
				if (app.getCustomerNumber() != null && app.getCustomerNumber().trim().length() > 0) {
					splitHash = (Integer)ssn.queryForObject("common.get-split-hash", app.getCustomerNumber());
				}
				app.setSplitHash(splitHash);
				ssn.insert("application.add-application", app);
			} catch (SQLException e) {
				if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
					throw new UserException(e.getCause().getMessage());
				} else {
					throw e;
				}
			}
		}

		private void modifyApplicationData(ApplicationRec[] appRecs, Long appId) throws Exception {
			CallableStatement cstmt = null;
			try {
				cstmt = connection.prepareCall("{ call app_ui_application_pkg.modify_application_data(?,?,?) }");
				cstmt.setLong(1, appId);
				ARRAY oracleApps = DBUtils.createArray(AuthOracleTypeNames.APP_DATA_TAB, connection, appRecs);
				cstmt.setArray(2, oracleApps);
				cstmt.setInt(3, 1);
				cstmt.execute();
			} catch (SQLException e) {
				if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
					throw new UserException(e.getCause().getMessage(), e);
				} else {
					throw e;
				}
			}finally {
				DBUtils.close(cstmt);
			}
		}

		private void setDataAndParent(ApplicationElement newEl, ApplicationElement parent, Element xmlElement,
				Long applicationId) throws Exception {
			if (count == step) {
				resetCount(applicationId);
			}
			newEl.setParent(parent);
			if (xmlElement != null) {
				if (newEl.getDataId() != null) {
					xmlElement.setAttribute("dataId", newEl.getDataId().toString());
				} else {
					String params = newEl.getName();
					logger.error("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + "; setDataAndParent:" + params +";");
				}
			}
			newEl.setDataId(currVal + count);
			if (parent != null) {
				newEl.setParentDataId(parent.getDataId());
			}
			count++;
		}

		private void createAppTree(Node application, ApplicationElement appTree,
				List<ApplicationRec> appAsArray, Long applicationId) throws Exception {

			try {
				appAsArray.add(new ApplicationRec(appTree));
				NodeList nodeList = application.getChildNodes();
				Map<String, Integer> innerMap = new HashMap<String, Integer>();

				for (int s = 0; s < nodeList.getLength(); s++) {

					Node child = nodeList.item(s);
					if (!(child instanceof Element)) {
						continue;
					}
					Element el = (Element) child;
					String name = getElementName(el);

					if ("DOCUMENT_CONTENTS".equals(name)) {
						String documentContents = (String) exprCurrentNode.evaluate(el, XPathConstants.STRING);
						documentsMap.put(appTree.getDataId(), documentContents);
						continue;
					}
					if ("CUSTOMER_EDS".equals(name)) {
						String eds = (String) exprCurrentNode.evaluate(el, XPathConstants.STRING);
						edsMap.put(appTree.getDataId(), eds);
						continue;
					}
					if ("SUPERVISOR_EDS".equals(name)) {
						String eds = (String) exprCurrentNode.evaluate(el, XPathConstants.STRING);
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

					setDataAndParent(newEl, appTree, el, applicationId);

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
								if (trace) {
									logger.trace("ApplicationWsSaver.createAppTree(): node name = " + el.getNodeName()
										+ ", dataType = " + newEl.getDataType() + "x" + elementsMap.get(name).getDataType()
										+ ", id = " + newEl.getId() + ", val = '" + val + "'");
								}
								if (newEl.isNumber()) {
									if (val != null && !val.equals("")) {
										newEl.setValueN(new BigDecimal(val));
									} else {
										newEl.setValueN((BigDecimal)null);
									}
								} else if (newEl.isDate()) {
									Date date = javax.xml.bind.DatatypeConverter.parseDate(
											el.getFirstChild().getNodeValue()).getTime();
									newEl.setValueD(date);
								} else if (newEl.isChar()) {
									newEl.setValueV(val);
								} else {
									newEl.setValueV(val);
								}
							} catch (Exception e) {
								String params = "Element = " + newEl.getName() + "; value = " + val;
								logger.error("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + "; Cannot set element value. Params: " + params, e);
								loggerDB.error(new TraceLogInfo(sessionId, "THREAD: " + THREAD + "; APP: " + applicationId + "; Cannot set element value:" + params + ". "+ e.getMessage(), EntityNames.APPLICATION, applicationId), e);
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

					createAppTree(child, newEl, appAsArray, applicationId);
				}
			} catch (Exception e) {
				logger.error("THREAD: " + THREAD + "; APP: " + applicationId + "; " + saverName + ";createObjectTree", e);
				loggerDB.error(new TraceLogInfo(sessionId, "THREAD: " + THREAD + "; APP: " + applicationId + ";createObjectTree. "+ e.getMessage(), EntityNames.APPLICATION, applicationId), e);
				throw e;
			}
		}

		private void saveDocuments() throws Exception {
			FileOutputStream fos = null;
			InputStream ins = null;
			if (documentsDataIdList == null || documentsDataIdList.size() == 0) {
				return;
			}

			List<byte[]> bytesList = new ArrayList<byte[]>();
			//TODO get rid of DAO
			List<String> savePaths = appDao.saveDocuments(userSessionId, documentsDataIdList, documentsMap,
					edsMap, svEdsMap, bytesList);
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
						try {
							if (fos != null)
								fos.close();
						} catch (IOException ignored) {
						}
						try {
							if (ins != null)
								ins.close();
						} catch (IOException ignored) {
						}
					}
				}
			}
		}
	}

	private String nodeToString(Node node) {
		StringWriter sw = new StringWriter();
		try {
			Transformer t = TransformerFactory.newInstance().newTransformer();
			t.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
			t.transform(new DOMSource(node), new StreamResult(sw));
		} catch (TransformerException te) {
			logger.error("Application parsing exception", te);
		}
		return sw.toString();
	}

	private class AppListArray {
		List<Node> applications;

		public List<Node> getApplications() {
			return applications;
		}

		public void setApplications(List<Node> applications) {
			this.applications = applications;
		}

		public void appToList(Node application) {
			if (applications == null) {
				applications = new ArrayList<Node>();
			}
			applications.add(application);
		}
	}
}
