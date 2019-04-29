package ru.bpc.sv2.ui.services;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.Holder;

import org.apache.log4j.Logger;

import ru.bpc.sv.pctlpeerncr.*;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@ManagedBean (name = "MbPCtlPeerNcrWS")
public class MbPCtlPeerNcrWS {
	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private SettingsDao _settingsDao = new SettingsDao();

	private Long userSessionId = null;
	private int terminalId;
	private String forced;
	private String screen;
	private String dateTime;
	private String userLang;
	private DictUtils dictUtils;

	public MbPCtlPeerNcrWS() {
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
		Double port = _settingsDao.getParameterValueN(userSessionId, SettingsConstants.NCR_WS_PORT,
				LevelNames.SYSTEM, null);
		if (port == null) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					SettingsConstants.NCR_WS_PORT);
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
	 * Sends NCR "change encryption key" command to FE. Uses bean's internal
	 * <code>terminalId</code>, so if corresponding parameter isn't set the
	 * command won't be completed. Response is handled automatically inside the
	 * method. To handle response manually use methods that return response
	 * code.
	 * </p>
	 */
	public void changeEncryptionKey() {
		int respCode;
		try {
			respCode = changeEncryptionKey(terminalId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int changeEncryptionKey(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		EncryptionKeyChangeType item = factory.createEncryptionKeyChangeType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.encryptionKeyChange(item);
	}

	/**
	 * <p>
	 * Sends NCR "go in service" command to FE. Uses bean's internal
	 * <code>terminalId</code> and <code>forced</code>, so if corresponding
	 * parameters aren't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void goInService() {
		int respCode;
		try {
			respCode = goInService(terminalId, forced); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int goInService(int terminalId) throws Exception {
		return goInService(terminalId, null);
	}

	public int goInService(int terminalId, String forced) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		GoInServiceType item = factory.createGoInServiceType();
		item.setTerminalID(terminalId);
		item.setForced(forced);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.goInService(item);
	}

	/**
	 * <p>
	 * Sends NCR "go out of service" command to FE. Uses bean's internal
	 * <code>terminalId</code>, <code>forced</code> and <code>screen</code>, so
	 * if corresponding parameters aren't set the command won't be completed.
	 * Response is handled automatically inside the method. To handle response
	 * manually use methods that return response code.
	 * </p>
	 */
	public void goOutOfService() {
		int respCode;
		try {
			respCode = goOutOfService(terminalId, forced, screen); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int goOutOfService(int terminalId) throws Exception {
		return goOutOfService(terminalId, null, null);
	}

	public int goOutOfService(int terminalId, String forced) throws Exception {
		return goOutOfService(terminalId, forced, null);
	}

	public int goOutOfService(int terminalId, String forced, String screen) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		GoOutOfServiceType item = factory.createGoOutOfServiceType();
		item.setTerminalID(terminalId);
		item.setForced(forced);
		item.setScreen(screen);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.goOutOfService(item);
	}

	/**
	 * <p>
	 * Sends NCR "load config ID" command to FE. Uses bean's internal
	 * <code>terminalId</code>, so if corresponding parameter isn't set the
	 * command won't be completed. Response is handled automatically inside the
	 * method. To handle response manually use methods that return response
	 * code.
	 * </p>
	 */
	public void loadConfigID() {
		int respCode;
		try {
			respCode = loadConfigID(terminalId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int loadConfigID(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		LoadConfigIDType item = factory.createLoadConfigIDType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadConfigID(item);
	}

	/**
	 * <p>
	 * Sends NCR "load config" command to FE. Uses bean's internal
	 * <code>terminalId</code>, so if corresponding parameter isn't set the
	 * command won't be completed. Response is handled automatically inside the
	 * method. To handle response manually use methods that return response
	 * code.
	 * </p>
	 */
	public void loadConfig() {
		int respCode;
		try {
			respCode = loadConfigID(terminalId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int loadConfig(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		LoadConfigType item = factory.createLoadConfigType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadConfig(item);
	}

	/**
	 * <p>
	 * Sends NCR "load date and time" command to FE. Uses bean's internal
	 * <code>terminalId</code> and <code>dateTime</code>, so if corresponding
	 * parameters aren't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void loadDateAndTime() {
		int respCode;
		try {
			respCode = loadDateAndTime(terminalId, dateTime); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int loadDateAndTime(int terminalId, String dateTime) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		LoadDateAndTimeType item = factory.createLoadDateAndTimeType();
		item.setTerminalID(terminalId);
		item.setDatetime(dateTime);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadDateAndTime(item);
	}

	/**
	 * <p>
	 * Sends NCR "load enchanced config" command to FE. Uses bean's internal
	 * <code>terminalId</code>, so if corresponding parameter isn't set the
	 * command won't be completed. Response is handled automatically inside the
	 * method. To handle response manually use methods that return response
	 * code.
	 * </p>
	 */
	public void loadEnchancedConfig() {
		int respCode;
		try {
			respCode = loadEnchancedConfig(terminalId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int loadEnchancedConfig(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		LoadEnchancedConfigType item = factory.createLoadEnchancedConfigType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadEnchancedConfig(item);
	}

	/**
	 * <p>
	 * Sends NCR "load fit data" command to FE. Uses bean's internal
	 * <code>terminalId</code>, so if corresponding parameter isn't set the
	 * command won't be completed. Response is handled automatically inside the
	 * method. To handle response manually use methods that return response
	 * code.
	 * </p>
	 */
	public void loadFitData() {
		int respCode;
		try {
			respCode = loadFitData(terminalId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int loadFitData(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		LoadFitDataType item = factory.createLoadFitDataType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadFitData(item);
	}

	/**
	 * <p>
	 * Sends NCR "load ICC currency data objects table " command to FE. Uses
	 * bean's internal <code>terminalId</code>, so if corresponding parameter
	 * isn't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void loadICCCurrencyDataObjectsTable() {
		int respCode;
		try {
			respCode = loadICCCurrencyDataObjectsTable(terminalId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int loadICCCurrencyDataObjectsTable(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		LoadICCCurrencyDataObjectsTableType item = factory
				.createLoadICCCurrencyDataObjectsTableType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadICCCurrencyDataObjectsTable(item);
	}

	/**
	 * <p>
	 * Sends NCR "load ICC language support table " command to FE. Uses bean's
	 * internal <code>terminalId</code>, so if corresponding parameter isn't set
	 * the command won't be completed. Response is handled automatically inside
	 * the method. To handle response manually use methods that return response
	 * code.
	 * </p>
	 */
	public void loadICCLanguageSupportTable() {
		int respCode;
		try {
			respCode = loadICCLanguageSupportTable(terminalId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int loadICCLanguageSupportTable(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		LoadICCLanguageSupportTableType item = factory.createLoadICCLanguageSupportTableType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadICCLanguageSupportTable(item);
	}

	/**
	 * <p>
	 * Sends NCR "load ICC terminal acceptable AIDs table" command to FE. Uses
	 * bean's internal <code>terminalId</code>, so if corresponding parameter
	 * isn't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void loadICCTerminalAcceptableAIDsTable() {
		int respCode;
		try {
			respCode = loadICCTerminalAcceptableAIDsTable(terminalId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int loadICCTerminalAcceptableAIDsTable(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		LoadICCTerminalAcceptableAIDsTableType item = factory
				.createLoadICCTerminalAcceptableAIDsTableType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadICCTerminalAcceptableAIDsTable(item);
	}

	/**
	 * <p>
	 * Sends NCR "load ICC terminal data objects table" command to FE. Uses
	 * bean's internal <code>terminalId</code>, so if corresponding parameter
	 * isn't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void loadICCTerminalDataObjectsTable() {
		int respCode;
		try {
			respCode = loadICCTerminalDataObjectsTable(terminalId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int loadICCTerminalDataObjectsTable(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		LoadICCTerminalDataObjectsTableType item = factory
				.createLoadICCTerminalDataObjectsTableType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadICCTerminalDataObjectsTable(item);
	}

	/**
	 * <p>
	 * Sends NCR "load ICC transaction data objects table" command to FE. Uses
	 * bean's internal <code>terminalId</code>, so if corresponding parameter
	 * isn't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void loadICCTransactionDataObjectsTable() {
		int respCode;
		try {
			respCode = loadICCTransactionDataObjectsTable(terminalId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int loadICCTransactionDataObjectsTable(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		LoadICCTransactionDataObjectsTableType item = factory
				.createLoadICCTransactionDataObjectsTableType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadICCTransactionDataObjectsTable(item);
	}

	/**
	 * <p>
	 * Sends NCR "load MAC selection" command to FE. Uses bean's internal
	 * <code>terminalId</code>, so if corresponding parameter isn't set the
	 * command won't be completed. Response is handled automatically inside the
	 * method. To handle response manually use methods that return response
	 * code.
	 * </p>
	 */
	public void loadMACSelection() {
		int respCode;
		try {
			respCode = loadMACSelection(terminalId); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int loadMACSelection(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		LoadMACSelectionType item = factory.createLoadMACSelectionType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadMACSelection(item);
	}

	public int loadScreenData(int terminalId, List<String> screens, String keyboardLayout)
			throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();

		ScreensList screensList = factory.createScreensList();
		for (String screen : screens) {
			screensList.getScreen().add(screen);
		}
		LoadScreenDataType item = factory.createLoadScreenDataType();
		item.setTerminalID(terminalId);
		item.setScreensList(screensList);
		item.setKeyboardLayout(keyboardLayout);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadScreenData(item);
	}

	public int loadStateTable(int terminalId, List<String> states) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();

		StatesList statesList = factory.createStatesList();
		for (String state : states) {
			statesList.getState().add(state);
		}
		LoadStateTableType item = factory.createLoadStateTableType();
		item.setTerminalID(terminalId);
		item.setStatesList(statesList);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		return port.loadStateTable(item);
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendConfigID(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
		port.sendConfigID(terminalId, respCode, data);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respCode.value);
		result.put("data", data.value);

		return result;
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendConfigInfo(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
		port.sendConfigInfo(terminalId, respCode, data);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respCode.value);
		result.put("data", data.value);

		return result;
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendDateAndTimeInfo(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		ObjectFactory factory = new ObjectFactory();
		SendDateTimeInfoType item = factory.createSendDateTimeInfoType();
		item.setTerminalID(terminalId);

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		ResponseType respType = port.sendDateAndTimeInfo(item);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respType.getRespCode());
		result.put("data", respType.getData());

		return result;
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendEnhancedConfig(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
		port.sendEnhancedConfig(terminalId, respCode, data);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respCode.value);
		result.put("data", data.value);

		return result;
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendHardwareConfig(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
		port.sendHardwareConfig(terminalId, respCode, data);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respCode.value);
		result.put("data", data.value);

		return result;
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendHardwareFitness(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
		port.sendHardwareFitness(terminalId, respCode, data);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respCode.value);
		result.put("data", data.value);

		return result;
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendLocalConfigOptionDigits(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
		port.sendLocalConfigOptionDigits(terminalId, respCode, data);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respCode.value);
		result.put("data", data.value);

		return result;
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendNoteDefinitions(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
		port.sendNoteDefinitions(terminalId, respCode, data);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respCode.value);
		result.put("data", data.value);

		return result;
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendSensorStatus(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
		port.sendSensorStatus(terminalId, respCode, data);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respCode.value);
		result.put("data", data.value);

		return result;
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendSoftwareIDAndReleaseNumber(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
		port.sendSoftwareIDAndReleaseNumber(terminalId, respCode, data);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respCode.value);
		result.put("data", data.value);

		return result;
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendSuppliesStatus(int terminalId) throws Exception {
		String feLocation = getFeLocation();

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
		port.sendSuppliesStatus(terminalId, respCode, data);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respCode.value);
		result.put("data", data.value);

		return result;
	}

	/**
	 * @return map with the following keys: "responseCode" of type
	 *         <code>Integer</code> and "data" of type <code>String</code>
	 * @throws Exception
	 */
	public Map<String, Object> sendSupplyCounters(int terminalId, String extension)
			throws Exception {
		String feLocation = getFeLocation();

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);

		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
		port.sendSupplyCounters(terminalId, extension, respCode, data);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("responseCode", respCode.value);
		result.put("data", data.value);

		return result;
	}
}
