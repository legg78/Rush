package ru.bpc.sv.ws.application.handlers;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationError;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ws.ApplicationsWsDao;
import ru.bpc.sv2.trace.TraceLogInfo;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;
import java.util.Map;

public abstract class AppStageHandler {

	private long applicationId;
	private Application application;
	private String applicationXml;
	private String stageResult;
	private String stageResultComment;
	private Document applicationDoc;
	private long sessionId;
	private String name;
	private boolean reloadApplication;
	protected Map<String, Object> params; 
	
	protected final int step = ApplicationConstants.DATA_SEQUENCE_STEP;
	protected int count;
	protected long currVal;

	protected XPathExpression exprData = null;
	protected XPath xpath = null;

	protected AppStageHandler() {
		xpath = XPathFactory.newInstance().newXPath();
	}
	
	public void process() {
		
	}

	public long getApplicationId() {
		return applicationId;
	}

	public void setApplicationId(long applicationId) {
		this.applicationId = applicationId;
	}

	public String getFinalStage() {
		return null;
	}
	
	public String getStageResult() {
		return stageResult;
	}

	public void setStageResult(String stageResult) {
		this.stageResult = stageResult;
	}

	public String getApplicationXml() {
		return applicationXml;
	}

	public void setApplicationXml(String applicationXml) {
		this.applicationXml = applicationXml;
	}

	public long getSessionId() {
		return sessionId;
	}

	public void setSessionId(long sessionId) {
		this.sessionId = sessionId;
	}

	public Document getApplicationDoc() {
		return applicationDoc;
	}

	public void setApplicationDoc(Document applicationDoc) {
		this.applicationDoc = applicationDoc;
	}

	public String getStageResultComment() {
		return stageResultComment;
	}

	public void setStageResultComment(String stageResultComment) {
		this.stageResultComment = stageResultComment;
	}

	public String getName() {
		return name;
	}
	
	protected void addError(Long parentDataId, String elementName, String code, String message,
			String details) {
		if (parentDataId == null) {
			return;
		}
		try {
			ApplicationsWsDao appWsDao = new ApplicationsWsDao();
			
			ApplicationError applicationError = new ApplicationError();
			applicationError.setApplicationId(getApplicationId());
			applicationError.setElementName(elementName);
			applicationError.setParentDataId(parentDataId);
			if (code == null) {
				code = "STAGE_ERROR";
			}
			applicationError.setCode(code);
			applicationError.setMessage(message);
			applicationError.setDetails(details);

			if (parentDataId == 0) {
				appWsDao.addCommonErrorToApplication(getSessionId(), applicationError);
			} else {
			appWsDao.addErrorToApplication(getSessionId(), applicationError);
			}
		} catch (Exception e) {
			getLogger().error("APP: " + getApplicationId(), e);
			getLoggerDB().error(new TraceLogInfo(getSessionId(), e.getMessage(), EntityNames.APPLICATION, getApplicationId()), e);
		}
	}
	
	protected abstract Logger getLogger();
	protected abstract Logger getLoggerDB();

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public long getCurrVal() {
		return currVal;
	}

	public void setCurrVal(long currVal) {
		this.currVal = currVal;
	}
	
	protected void resetCount() throws Exception {
		ApplicationDao appDao = new ApplicationDao();
		currVal = appDao.getNextDataId(applicationId) - step;
		count = 1;
	}
	
	protected Long getElementDataId(Node node) throws Exception {
		Long orderDataId = null;
		if (exprData == null) {
			exprData = xpath.compile("@dataId");
		}
		String orderDataIdAttr = (String) exprData.evaluate(node, XPathConstants.STRING);
		if (orderDataIdAttr != null) {
			orderDataId = Long.parseLong(orderDataIdAttr);
		}
		return orderDataId;
	}

	public Application getApplication() {
		return application;
	}

	public void setApplication(Application application) {
		this.application = application;
	}

	public boolean isReloadApplication() {
		return reloadApplication;
	}

	public void setReloadApplication(boolean reloadApplication) {
		this.reloadApplication = reloadApplication;
	}

	public Map<String, Object> getParams() {
		return params;
	}

	public void setParams(Map<String, Object> params) {
		this.params = params;
	}
	
}
