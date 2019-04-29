package ru.bpc.sv2.ui.services;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.xml.ws.BindingProvider;

import org.apache.log4j.Logger;

import ru.bpc.sv.pctlpeerway4.*;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@ManagedBean (name = "MbPCtlPeerWay4WS")
public class MbPCtlPeerWay4WS {
	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private SettingsDao _settingsDao = new SettingsDao();

	private Long userSessionId = null;
	private int hostId;
	private int deviceId;
	private String userLang;
	private DictUtils dictUtils;
	
	public MbPCtlPeerWay4WS() {
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
				SettingsConstants.WAY4_WS_PORT, LevelNames.SYSTEM, null);
		if (port == null) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					SettingsConstants.WAY4_WS_PORT);
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
	 * Sends Way 4 "echo test" command to FE. Uses bean's internal
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
		
		PCtlPeerWAY4_Service service = new PCtlPeerWAY4_Service();
		PCtlPeerWAY4 port = service.getPCtlPeerWAY4SOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.echoTest(item);
	}

	/**
	 * <p>
	 * Sends Way 4 "sign in" command to FE. Uses bean's internal
	 * <code>hostId</code> and <code>deviceId</code>, so if corresponding
	 * parameters aren't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void signIn() {
		int respCode;
		try {
			respCode = signIn(hostId, deviceId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int signIn(int hostId) throws Exception {
		return signIn(hostId, 0);
	}
	
	public int signIn(int hostId, int deviceId) throws Exception {
		String feLocation = getFeLocation();
		
		ObjectFactory factory = new ObjectFactory();
		SignInType signInType = factory.createSignInType();
		signInType.setHostMemberID(hostId);
		signInType.setDeviceID(deviceId);
		
		PCtlPeerWAY4_Service service = new PCtlPeerWAY4_Service();
		PCtlPeerWAY4 port = service.getPCtlPeerWAY4SOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.signIn(signInType);
	}

	/**
	 * <p>
	 * Sends Way 4 "sign off" command to FE. Uses bean's internal
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

		PCtlPeerWAY4_Service service = new PCtlPeerWAY4_Service();
		PCtlPeerWAY4 port = service.getPCtlPeerWAY4SOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.signOff(signOffType);
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
