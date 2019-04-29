package ru.bpc.sv.ws.application.handlers;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;

import org.apache.log4j.Logger;
import org.w3c.dom.Node;

import ru.bpc.sv2.application.ApplicationFlowStage;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.trace.TraceLogInfo;

public class AppStageHandlerStubError extends AppStageHandler {
	private static final String ELEMENT_PAYMENT_ORDER = "PAYMENT_ORDER";
	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");
	private static final Logger logger = Logger.getLogger("SVAP");
	private static final String HANDLER_NAME = "AppStageHandlerStubError";

	public void process() {
		setStageResult(ApplicationFlowStage.STAGE_RESULT_FAIL);

		try {
			XPath xpath = XPathFactory.newInstance().newXPath();
			XPathExpression expr = xpath.compile("/application/account_branch/account/payment_order[1]");
			Node paymentOrderNode = (Node) expr.evaluate(getApplicationDoc(), XPathConstants.NODE);
			
			expr = xpath.compile("@dataId");
			String purposeDataIdAttr = (String) expr.evaluate(paymentOrderNode, XPathConstants.STRING);
			Long purposeDataId = null;
			if (purposeDataIdAttr != null) {
				purposeDataId = Long.parseLong(purposeDataIdAttr);
			}
			addError(purposeDataId, ELEMENT_PAYMENT_ORDER, "CA_FAILED", "SIGNATURE IS WRONG", null);
		} catch (Exception e) {
		} finally { 
			if (AppStageProcessor.traceTime) {
				logger.trace("APPLICATION STAGE PROCESSOR: handler " + HANDLER_NAME + "; result = " +
						getStageResult());
				loggerDB.trace(new TraceLogInfo(getSessionId(), "APPLICATION STAGE PROCESSOR: handler " +
						HANDLER_NAME + "; result = " + getStageResult(), EntityNames.APPLICATION, getApplicationId()));
			}
		}
	}
	
	@Override
	protected Logger getLogger() {
		return logger;
	}
	
	@Override
	protected Logger getLoggerDB() {
		return loggerDB;
	}
	
}
