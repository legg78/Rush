package ru.bpc.sv2.ui.services;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.xml.ws.BindingProvider;

import org.apache.log4j.Logger;

import ru.bpc.sv.pctlpeervisabase1.*;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@ManagedBean (name = "MbPCtlPeerVisaBase1WS")
public class MbPCtlPeerVisaBase1WS {
	private static final Logger logger = Logger.getLogger("COMMUNICATION");
	
	private SettingsDao _settingsDao = new SettingsDao();

	private Long userSessionId = null;
	private int hostId;
	private int deviceId;
	private String userLang;
	private DictUtils dictUtils;
	
	public MbPCtlPeerVisaBase1WS() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		userLang = SessionWrapper.getField("language");
		dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
	}

	public String getFeLocation() throws Exception {
		String feLocation;
		feLocation = _settingsDao.getParameterValueV(userSessionId,
				SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM, null);
		if (feLocation == null || feLocation.trim().length() == 0) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					SettingsConstants.FRONT_END_LOCATION);
			throw new Exception(msg);
		}
		Double port = _settingsDao.getParameterValueN(userSessionId,
				SettingsConstants.VISA_BASE1_WS_PORT, LevelNames.SYSTEM, null);
		if (port == null) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					SettingsConstants.VISA_BASE1_WS_PORT);
			throw new Exception(msg);
		}
		
		return feLocation + ":" + port.intValue();
	}
	
	private void handleResponse(int respCode) {
		if (respCode != 1) {
			String articleCode = String.valueOf(respCode);
			for (int i = articleCode.length(); i < DictNames.ARTICLE_CODE_LENGTH; i++) {
				articleCode = "0" + articleCode;
			}
			if (dictUtils == null || userLang == null) {
				FacesUtils.addMessageError(new Exception("Error code: " + articleCode));
			} else {
				FacesUtils.addMessageError(new Exception(dictUtils.getAllArticlesDescByLang().get(
						userLang).get(DictNames.RESPONSE_CODE + articleCode)));
			}
		}
	}

	/**
	 * <p>
	 * Sends Visa Base 1 "echo test" command to FE. Uses bean's internal
	 * <code>hostId</code> and <code>deviceId</code>, so if corresponding
	 * parameters aren't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void echoTest() {
		int respCode;
		try {
			respCode = echoTest(hostId, deviceId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int echoTest(int hostId) throws Exception {
		return echoTest(hostId, 0);
	}
	
	public int echoTest(int hostId, int deviceId) throws Exception {
		String feLocation = getFeLocation();
		
		ObjectFactory factory = new ObjectFactory();
		EchoTestType item = factory.createEchoTestType();
		item.setHostMemberID(hostId);
		item.setDeviceID(deviceId);
		
		PCtlPeerVISABASE1_Service service = new PCtlPeerVISABASE1_Service();
		PCtlPeerVISABASE1 port = service.getPCtlPeerVISABASE1SOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.echoTest(item);
	}

	/**
	 * <p>
	 * Sends Visa Base 1 "sign on" command to FE. Uses bean's internal
	 * <code>hostId</code> and <code>deviceId</code>, so if corresponding
	 * parameters aren't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void signOn() {
		int respCode;
		try {
			respCode = signOn(hostId, deviceId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int signOn(int hostId) throws Exception {
		return signOn(hostId, 0);
	}
	
	public int signOn(int hostId, int deviceId) throws Exception {
		String feLocation = getFeLocation();
		
		ObjectFactory factory = new ObjectFactory();
		SignOnType signOnType = factory.createSignOnType();
		signOnType.setHostMemberID(hostId);
		signOnType.setDeviceID(deviceId);
		
		PCtlPeerVISABASE1_Service service = new PCtlPeerVISABASE1_Service();
		PCtlPeerVISABASE1 port = service.getPCtlPeerVISABASE1SOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.signOn(signOnType);
	}

	/**
	 * <p>
	 * Sends Visa Base 1 "sign off" command to FE. Uses bean's internal
	 * <code>hostId</code> and <code>deviceId</code>, so if corresponding
	 * parameters aren't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void signOff() {
		int respCode;
		try {
			respCode = signOff(hostId, deviceId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int signOff(int hostId) throws Exception {
		return signOff(hostId, 0);
	}
	
	public int signOff(int hostId, int deviceId) throws Exception {
		String feLocation = getFeLocation();
		
		ObjectFactory factory = new ObjectFactory();
		SignOffType signOffType = factory.createSignOffType();
		signOffType.setHostMemberID(hostId);
		signOffType.setDeviceID(deviceId);
		
		PCtlPeerVISABASE1_Service service = new PCtlPeerVISABASE1_Service();
		PCtlPeerVISABASE1 port = service.getPCtlPeerVISABASE1SOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.signOff(signOffType);
	}
	
	/**
	 * <p>
	 * Sends Visa Base 1 "start advices trms" command to FE. Uses bean's internal
	 * <code>hostId</code> and <code>deviceId</code>, so if corresponding
	 * parameters aren't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void startAdvicesTrms() {
		int respCode;
		try {
			respCode = startAdvicesTrms(hostId, deviceId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int startAdvicesTrms(int hostId) throws Exception {
		return startAdvicesTrms(hostId, 0);
	}
	
	public int startAdvicesTrms(int hostId, int deviceId) throws Exception {
		String feLocation = getFeLocation();
		
		ObjectFactory factory = new ObjectFactory();
		StartAdvisesTrmsType item = factory.createStartAdvisesTrmsType();
		item.setHostMemberID(hostId);
		item.setDeviceID(deviceId);
		
		PCtlPeerVISABASE1_Service service = new PCtlPeerVISABASE1_Service();
		PCtlPeerVISABASE1 port = service.getPCtlPeerVISABASE1SOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.startAdvicesTrms(item);
	}

	/**
	 * <p>
	 * Sends Visa Base 1 "stop advices trms" command to FE. Uses bean's internal
	 * <code>hostId</code> and <code>deviceId</code>, so if corresponding
	 * parameters aren't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void stopAdvicesTrms() {
		int respCode;
		try {
			respCode = stopAdvicesTrms(hostId, deviceId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int stopAdvicesTrms(int hostId) throws Exception {
		return stopAdvicesTrms(hostId, 0);
	}
	
	public int stopAdvicesTrms(int hostId, int deviceId) throws Exception {
		String feLocation = getFeLocation();
		
		ObjectFactory factory = new ObjectFactory();
		StopAdvisesTrmsType item = factory.createStopAdvisesTrmsType();
		item.setHostMemberID(hostId);
		item.setDeviceID(deviceId);
		
		PCtlPeerVISABASE1_Service service = new PCtlPeerVISABASE1_Service();
		PCtlPeerVISABASE1 port = service.getPCtlPeerVISABASE1SOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.stopAdvicesTrms(item);
	}

	public int getHostId() {
		return hostId;
	}

	public void setHostId(int hostId) {
		this.hostId = hostId;
	}

	public int getDeviceId() {
		return deviceId;
	}

	public void setDeviceId(int deviceId) {
		this.deviceId = deviceId;
	}
}
