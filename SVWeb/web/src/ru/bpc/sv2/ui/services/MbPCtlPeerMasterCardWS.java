package ru.bpc.sv2.ui.services;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.xml.ws.BindingProvider;

import org.apache.log4j.Logger;

import ru.bpc.sv.pctlpeermastercard.*;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@ManagedBean (name = "MbPCtlPeerMasterCardWS")
public class MbPCtlPeerMasterCardWS {
	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private SettingsDao _settingsDao = new SettingsDao();

	private Long userSessionId = null;
	private int hostId;
	private int deviceId;
	private String groupId;
	private String panPrefix;
	private String securityCode;
	private String userLang;
	private DictUtils dictUtils;

	public MbPCtlPeerMasterCardWS() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		userLang = SessionWrapper.getField("language");
		dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
	}

	public String getFeLocation() throws Exception {
		String feLocation = _settingsDao.getParameterValueV(userSessionId,
				SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM, null);
		if (feLocation == null || feLocation.trim().length() == 0) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					SettingsConstants.FRONT_END_LOCATION);
			throw new Exception(msg);
		}
		Double port = _settingsDao.getParameterValueN(userSessionId,
				SettingsConstants.MASTERCARD_WS_PORT, LevelNames.SYSTEM, null);
		if (port == null) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					SettingsConstants.MASTERCARD_WS_PORT);
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
	 * Sends command to FE to activate Mastercard related host. Uses bean's
	 * internal <code>hostId</code> and <code>deviceId</code>, so if
	 * corresponding parameters aren't set the command won't be completed.
	 * Response is handled automatically inside the method. To handle response
	 * manually use methods that return response code.
	 * </p>
	 */
	public void activateHost() {
		int respCode;
		try {
			respCode = activateHost(hostId, deviceId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int activateHost(int hostId) throws Exception {
		return activateHost(hostId, 0, null);
	}

	public int activateHost(int hostId, int deviceId) throws Exception {
		return activateHost(hostId, deviceId, null);
	}

	public int activateHost(int hostId, int deviceId, String groupId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		HostSessionActivationType item = factory.createHostSessionActivationType();
		item.setHostMemberID(hostId);
		item.setGroupID(groupId);
		item.setDeviceID(deviceId);

		PCtlPeerMasterCard_Service service = new PCtlPeerMasterCard_Service();
		PCtlPeerMasterCard port = service.getPCtlPeerMasterCardSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.hostSessionActivation(item);
	}

	/**
	 * <p>
	 * Sends command to FE to deactivate Mastercard related host. Uses bean's
	 * internal <code>hostId</code>, <code>deviceId</code> and
	 * <code>groupId</code>, so if corresponding parameters aren't set the
	 * command won't be completed. Response is handled automatically inside the
	 * method. To handle response manually use methods that return response
	 * code.
	 * </p>
	 */
	public void deactivateHost() {
		int respCode;
		try {
			respCode = deactivateHost(hostId, deviceId, groupId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int deactivateHost(int hostId) throws Exception {
		return deactivateHost(hostId, 0, null);
	}

	public int deactivateHost(int hostId, int deviceId) throws Exception {
		return deactivateHost(hostId, deviceId, null);
	}

	public int deactivateHost(int hostId, int deviceId, String groupId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		HostSessionDeactivationType item = factory.createHostSessionDeactivationType();
		item.setHostMemberID(hostId);
		item.setGroupID(groupId);
		item.setDeviceID(deviceId);

		PCtlPeerMasterCard_Service service = new PCtlPeerMasterCard_Service();
		PCtlPeerMasterCard port = service.getPCtlPeerMasterCardSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.hostSessionDeactivation(item);
	}

	/**
	 * <p>
	 * Sends Mastercard "sign on" command to FE. Uses bean's internal
	 * <code>hostId</code>, <code>deviceId</code>, <code>groupId</code>,
	 * <code>panPrefix</code> and <code>securityCode</code>, so if corresponding
	 * parameters aren't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void signOn() {
		int respCode;
		try {
			respCode = signOn(hostId, deviceId, groupId, panPrefix, securityCode); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int signOn(int hostId) throws Exception {
		return signOn(hostId, 0, null, null, null);
	}

	public int signOn(int hostId, int deviceId, String groupId, String panPrefix,
			String securityCode) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		SignOnType signOnType = factory.createSignOnType();
		signOnType.setHostMemberID(hostId);
		signOnType.setDeviceID(deviceId);
		signOnType.setGroupID(groupId);
		signOnType.setPANPrefix(panPrefix);
		signOnType.setSecurityCode((securityCode==null)?"":securityCode);

		PCtlPeerMasterCard_Service service = new PCtlPeerMasterCard_Service();
		PCtlPeerMasterCard port = service.getPCtlPeerMasterCardSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.signOn(signOnType);
	}

	/**
	 * <p>
	 * Sends Mastercard "sign off" command to FE. Uses bean's internal
	 * <code>hostId</code>, <code>deviceId</code>, <code>groupId</code>,
	 * <code>panPrefix</code> and <code>securityCode</code>, so if corresponding
	 * parameters aren't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void signOff() {
		int respCode;
		try {
			respCode = signOff(hostId, deviceId, groupId, panPrefix, securityCode); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int signOff(int hostId) throws Exception {
		return signOff(hostId, 0, null, null, null);
	}

	public int signOff(int hostId, int deviceId, String groupId, String panPrefix,
			String securityCode) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		SignOffType signOffType = factory.createSignOffType();
		signOffType.setHostMemberID(hostId);
		signOffType.setDeviceID(deviceId);
		signOffType.setGroupID(groupId);
		signOffType.setPANPrefix(panPrefix);
		signOffType.setSecurityCode((securityCode==null)?"":securityCode);

		PCtlPeerMasterCard_Service service = new PCtlPeerMasterCard_Service();
		PCtlPeerMasterCard port = service.getPCtlPeerMasterCardSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.signOff(signOffType);
	}

	/**
	 * <p>
	 * Sends Mastercard "connection status" command to FE. Uses bean's internal
	 * <code>hostId</code>, <code>deviceId</code> and <code>groupId</code>, so
	 * if corresponding parameters aren't set the command won't be completed.
	 * Response is handled automatically inside the method. To handle response
	 * manually use methods that return response code.
	 * </p>
	 */
	public void connectionStatus() {
		int respCode;
		try {
			respCode = connectionStatus(hostId, deviceId, groupId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int connectionStatus(int hostId) throws Exception {
		return connectionStatus(hostId, 0, null);
	}

	public int connectionStatus(int hostId, int deviceId) throws Exception {
		return connectionStatus(hostId, deviceId, null);
	}

	public int connectionStatus(int hostId, int deviceId, String groupId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		NetworkConnectionStatus connectionStatus = factory.createNetworkConnectionStatus();
		connectionStatus.setHostMemberID(hostId);
		connectionStatus.setDeviceID(deviceId);
		connectionStatus.setGroupID(groupId);

		PCtlPeerMasterCard_Service service = new PCtlPeerMasterCard_Service();
		PCtlPeerMasterCard port = service.getPCtlPeerMasterCardSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.networkConnectionStatus(connectionStatus);
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

	public String getGroupId() {
		return groupId;
	}

	public void setGroupId(String groupId) {
		this.groupId = groupId;
	}

	public String getPanPrefix() {
		return panPrefix;
	}

	public void setPanPrefix(String panPrefix) {
		this.panPrefix = panPrefix;
	}

	public String getSecurityCode() {
		return securityCode;
	}

	public void setSecurityCode(String securityCode) {
		this.securityCode = securityCode;
	}
}
