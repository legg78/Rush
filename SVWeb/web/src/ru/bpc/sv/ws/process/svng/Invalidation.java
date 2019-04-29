package ru.bpc.sv.ws.process.svng;

import org.apache.log4j.Logger;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.CommonUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.UserException;

public class Invalidation {
	private Long sessionId;
	private EventsDao evensDao = new EventsDao();
	private boolean exception;
	protected static Logger logger = Logger.getLogger("PROCESSES");
	private String callbackAddress;
	
	public Invalidation(Long sessionId){
		this.sessionId = sessionId;
	}

	/**
	 * Send cancellation
	 * @param userName user that started process. Is necessary because cancellation may be called from another thread
	 *                 that does not have user context
	 */
	public void callCancel(String userName){
		try {
			if (isException()) {
				sendCancelation();
			}
		} catch (UserException e){
			logger.error("", e);
		}
		try {
			returnStatus(sessionId, userName);
		} catch (Exception e) {
			logger.error("", e);
		}
	}
	
	private void sendCancelation() throws UserException{
		try{
			logger.debug("sendCancelation...");
			SettingsCache settingParamsCache = SettingsCache.getInstance();
			WsClient client = new WsClient(settingParamsCache.getParameterStringValue(SettingsConstants.BPEL_URL), getCallbackAddress(), sessionId, null);
			client.cancel();
		}catch (Exception e){
			logger.error(e);
			throw new UserException(e);
		}
	}
	
	private void returnStatus(Long sessionId, String user) throws Exception{
		if (sessionId != null){
			evensDao = new EventsDao();
			evensDao.returnStatus(sessionId, user);
		}	
	}

	public boolean isException() {
		return exception;
	}

	public void setException(boolean exception) {
		this.exception = exception;
	}
	
	public String getCallbackAddress(){
		if(callbackAddress == null){
			callbackAddress = CommonUtils.getWsCallbackUrl(null);
		}
		return callbackAddress;
	}

	public void setCallbackAddress(String callbackAddress) {
		this.callbackAddress = callbackAddress;
	}

}
