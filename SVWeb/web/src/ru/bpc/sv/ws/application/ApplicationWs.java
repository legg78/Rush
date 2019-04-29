package ru.bpc.sv.ws.application;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import ru.bpc.sv2.application.ApplicationFlow;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.WebServiceConstants;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.ws.ApplicationsWsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.AppElementsCache;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.UserException;

import javax.annotation.Resource;
import javax.servlet.ServletContext;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.soap.*;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamConstants;
import javax.xml.stream.XMLStreamReader;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import javax.xml.ws.Provider;
import javax.xml.ws.ServiceMode;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.WebServiceProvider;
import javax.xml.ws.handler.MessageContext;
import javax.xml.ws.soap.SOAPFaultException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;
import java.io.*;
import java.util.Properties;

@ServiceMode(value = javax.xml.ws.Service.Mode.PAYLOAD)
@WebServiceProvider(serviceName = "ApplicationService", portName = "Applications", targetNamespace = "http://bpc.ru/SVAP",
		wsdlLocation = "/META-INF/svap.wsdl")
public class ApplicationWs implements Provider<Source> {
	protected static final Logger logger = Logger.getLogger("SVAP");
	protected static final boolean traceXml = true;
	protected static final boolean traceTime = true;

	@Resource
	protected WebServiceContext wsContext;
	protected ApplicationsWsDao appWsDao;

	protected String userName;
	protected Long userSessionId;

	@Override
	public Source invoke(Source request) {
		Source src;
		StringWriter writer = null;
		ByteArrayInputStream requestXmlInputStream = null;
		InputStream xsltInputStream = null;
		AppElementsCache appCache;
		long timeBegin = System.currentTimeMillis();
		try {
			if (appWsDao == null) {
				appWsDao = new ApplicationsWsDao();
			}
			Number val = SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.SECURE_WEBSERVICES);
			Boolean secureWebservices = val != null && val.intValue() != 0;
			if (secureWebservices && !(this instanceof ApplicationWsSecure)) {
				throw new UserException("Webservice ApplicationService is not secure and cannot be accessed");
			}
			appCache = AppElementsCache.getInstance();

			writer = new StringWriter();
			Transformer trans = TransformerFactory.newInstance().newTransformer();
			trans.transform(request, new StreamResult(writer));
			String requestXml = writer.toString();
			writer.flush();
			writer.close();

			requestXmlInputStream = new ByteArrayInputStream(requestXml.getBytes("UTF-8"));

			DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = domFactory.newDocumentBuilder();
			Document doc = builder.parse(requestXmlInputStream);
			XPath xpath = XPathFactory.newInstance().newXPath();
			XPathExpression expr;
			expr = xpath.compile("/application/application_type");
			String appType = (String) expr.evaluate(doc, XPathConstants.STRING);
			if (appType == null) {
				throw new UserException("Application type is not provided");
			}
			expr = xpath.compile("/application/institution_id");
			Double result = (Double) expr.evaluate(doc, XPathConstants.NUMBER);
			Long instId = null;
			if (result != null && !result.isNaN()) {
				instId = result.longValue();
			}

			setupUserSession(appType, instId);

			expr = xpath.compile("/application/application_flow_id");
			result = (Double) expr.evaluate(doc, XPathConstants.NUMBER);

			if (traceXml) {
				logger.trace("WEB SERVICE: incoming XML: " + requestXml);
			}

			ApplicationFlow flow = appCache.getFlow(result.intValue());
			if (flow == null) {
				throw new Exception("Flow not found");
			}
			String xslt = flow.getXsltSource();
			String xsd = flow.getXsdSource();

			requestXmlInputStream.reset();
			Source xmlSource = new StreamSource(requestXmlInputStream);
			if (traceTime) {
				logger.trace("WEB SERVICE: Time prepare: " + (System.currentTimeMillis() - timeBegin));
			}

			if (xsd != null) {
				long validateBegin = System.currentTimeMillis();
				validate(xmlSource, xsd, false);
				requestXmlInputStream.reset();
				xmlSource = new StreamSource(requestXmlInputStream);
				if (traceTime) {
					logger.trace("WEB SERVICE: Time validate: " + (System.currentTimeMillis() - validateBegin));
				}
			}

			if (xslt != null) {
				long xsltBegin = System.currentTimeMillis();
				writer = new StringWriter();
				xsltInputStream = new ByteArrayInputStream(xslt.getBytes("UTF-8"));
				Source xsltSource = new StreamSource(xsltInputStream);
				trans = TransformerFactory.newInstance().newTransformer(xsltSource);
				trans.transform(xmlSource, new StreamResult(writer));
				requestXml = writer.toString();
				requestXmlInputStream = new ByteArrayInputStream(requestXml.getBytes("UTF-8"));
				writer.flush();
				writer.close();
				if (traceXml) {
					logger.trace("WEB SERVICE: transformed XML: " + requestXml);
				}
				if (traceTime) {
					logger.trace("WEB SERVICE: Time xslt: " + (System.currentTimeMillis() - xsltBegin));
				}
			}

			String resultXml;
			try {
				ApplicationsWsSaver appsWsSaver = new ApplicationsWsSaver();
				requestXmlInputStream = new ByteArrayInputStream(requestXml.getBytes("UTF-8"));
				appsWsSaver.setInputStream(requestXmlInputStream);
				appsWsSaver.setUserWS(userName);
				appsWsSaver.setSessionId(userSessionId);
				appsWsSaver.saveOne();
				resultXml = appsWsSaver.getXml();
			} catch (UserException e) {
				throw e;
			} catch (Exception e) {
				throw new Exception("Exception has occured on server", e);
			}

			src = new StreamSource(new ByteArrayInputStream(resultXml.getBytes("UTF-8")));

			doc = builder.parse(new ByteArrayInputStream(resultXml.getBytes("UTF-8")));
			expr = xpath.compile("//error");
			NodeList errorNodes = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);
			if (errorNodes != null) {
				for (int i = 0; i < errorNodes.getLength(); i++) {
					org.w3c.dom.Node errorNode = errorNodes.item(i);
					if (errorNode != null) {
						expr = xpath.compile("error_desc");
						String errorDesc = (String) expr.evaluate(errorNode, XPathConstants.STRING);
						expr = xpath.compile("error_code");
						String errorCode = (String) expr.evaluate(errorNode, XPathConstants.STRING);
						if ("EXTERNAL_APPL_NUMBER_IS_NOT_UNIQUE".equals(errorCode)) {
							// We skip this error because it's not actually an error.
							// Application will still be successfully processed
							// even if external application number is not unique
							continue;
						}
						if (StringUtils.isBlank(errorDesc) && StringUtils.isBlank(errorCode)) {
							errorDesc = "Unknown error has occurred during saving application.";
						}
						throw new UserException(errorDesc, errorCode, errorNode.cloneNode(true));
					}
				}
			}
		} catch (Exception e) {
			logger.error("", e);
			throw new SOAPFaultException(createFault(e));
		} finally {
			IOUtils.closeQuietly(writer);
			IOUtils.closeQuietly(requestXmlInputStream);
			IOUtils.closeQuietly(xsltInputStream);
			logger.trace("WEB SERVICE: Time total: " + (System.currentTimeMillis() - timeBegin));
		}
		return src;
	}

	protected void setupUserSession(String appType, Long instId) throws UserException {
		if (appWsDao == null) {
			appWsDao = new ApplicationsWsDao();
		}
		userName = getUserNameWS();
		userSessionId = appWsDao.registerSession(userName, null);
	}

	private SOAPFault createFault(Exception e) {
		SOAPFault soapFault = null;
		try {
			SOAPFactory factory = SOAPFactory.newInstance();
			Name qname = factory.createName("Server", "ns",
					"http://schemas.xmlsoap.org/soap/envelope/");
			soapFault = factory.createFault();
			soapFault.setFaultCode(qname);

			String message = e.getMessage();
			if (message != null && message.startsWith("ORA-")) {
				message = message.replaceFirst("ORA-\\d+: ", "");
				message = message.split("ORA-\\d+:")[0];
			}
			if (e instanceof UserException && ((UserException) e).isErrorCodeTextAvailable()) {
				Detail detail = soapFault.addDetail();

				Name name = factory.createName("details");
				DetailEntry entry = detail.addDetailEntry(name);
				entry.addTextNode(message);

				String code = ((UserException) e).getErrorCodeText();
				if (code != null && !code.isEmpty()) {
					code = convertCode(code);
				}
				soapFault.setFaultString(code);
			} else {
				soapFault.setFaultString(message);
			}
		} catch (SOAPException e1) {
			logger.error("", e1);
		}
		return soapFault;
	}

	private void validate(Source xmlSource, String xsd, boolean fromRetry) throws Exception {
		SAXException error = null;
		Source xsdSource = new StreamSource(new StringReader(xsd));
		SchemaFactory factory = SchemaFactory.newInstance("http://www.w3.org/2001/XMLSchema");
		Schema schema = factory.newSchema(xsdSource);
		Validator validator = schema.newValidator();
		try {
			validator.validate(xmlSource);
		} catch (SAXException ex) {
			error = ex;
			if (!fromRetry && ex instanceof SAXParseException) {
				if (xmlSource instanceof StreamSource) {
					((StreamSource) xmlSource).getInputStream().reset();
				}
				XMLInputFactory inputFactory = XMLInputFactory.newInstance();
				XMLStreamReader parser = inputFactory.createXMLStreamReader(xmlSource);
				while (parser.hasNext()) {
					int event = parser.next();
					if (event == XMLStreamConstants.START_ELEMENT) {
						if (parser.getLocalName().equals("application")) {
							String namespaceURI = parser.getNamespaceURI();
							//In the case incoming svap schema differs from XSD, replace XSD schema with incoming one
							//Incoming may be http://sv.bpc.in/SVAP/iss, but XSD has http://sv.bpc.in/SVAP
							logger.debug("SVAP application namespace URI: " + namespaceURI);
							final String svapUri = "http://sv.bpc.in/SVAP";
							if (xsd.contains(svapUri)) {
								logger.debug("Replacing namespace in xsd");
								xsd = StringUtils.replaceEach(xsd,
										new String[]{"'" + svapUri + "'", "\"" + svapUri + "\""},
										new String[]{"'" + namespaceURI + "'", "\"" + namespaceURI + "\""});
								if (xmlSource instanceof StreamSource) {
									((StreamSource) xmlSource).getInputStream().reset();
								}
								validate(xmlSource, xsd, true);
								error = null;
							}
						}
						break;
					}
				}
				parser.close();
			}
		}
		if (error != null) {
			logger.trace("WEB SERVICE: Error during validation: " + error.getMessage());
			throw new UserException("Error during validation: " + error.getMessage(), error);
		}
	}

	private String convertCode(String code) {
		try {
			CommonDao commonDao = new CommonDao();
			return commonDao.mapErrorCode(code);
		} catch (Exception e) {
			logger.error("", e);
			return code;
		}
	}

	private String getUserNameWS() {
		ServletContext servletContext = (ServletContext) wsContext.getMessageContext().get(MessageContext.SERVLET_CONTEXT);
		String userFile = servletContext.getInitParameter(SystemConstants.EXTERNAL_PROPERTIES_FILE);
		Properties prop = new Properties();
		String wsUserName = WebServiceConstants.WS_DEFAULT_CREDENTIALS;

		try {
			prop.load(new FileInputStream(userFile));
			wsUserName = prop.getProperty(WebServiceConstants.WS_USERNAME_PROPERTY);
		} catch (Exception e) {
			logger.error(e.getMessage());
			logger.trace("Using default credentials...");
		}
		return wsUserName;
	}
}
