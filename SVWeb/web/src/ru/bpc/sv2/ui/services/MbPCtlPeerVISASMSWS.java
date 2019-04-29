package ru.bpc.sv2.ui.services;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.xml.ws.BindingProvider;

import org.apache.log4j.Logger;

import ru.bpc.sv.pctlpeervisasms.FeeCollectFundsDisbType;
import ru.bpc.sv.pctlpeervisasms.ObjectFactory;
import ru.bpc.sv.pctlpeervisasms.AdjustType;
import ru.bpc.sv.pctlpeervisasms.NetMgmtType;
import ru.bpc.sv.pctlpeervisasms.PCtlPeerVISASMS;
import ru.bpc.sv.pctlpeervisasms.PCtlPeerVISASMS_Service;
import ru.bpc.sv.pctlpeervisasms.SendRepresentment;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.net.NetDevice;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


@RequestScoped
@ManagedBean (name = "MbPCtlPeerVISASMSWS")
public class MbPCtlPeerVISASMSWS {
	
	private SettingsDao _settingsDao = new SettingsDao();
	private NetworkDao _networkDao = new NetworkDao();

	private Long userSessionId = null;
	private int hostId;
	private int deviceId;
	private int acqMemberId;
	private Integer networkId;
	private String userLang;
	private Integer authId;
	private String contactName; 
	private  String contactPhone;
	private String messageText;
	private String reasonCode;
	private  String amount;
	private int hostMemberId;
	private String cardNo;
	private int currency;
	private String docIndicator;
	private DictUtils dictUtils;
	private static final Logger logger = Logger.getLogger("COMMUNICATION");
	private static Integer NETWORK_ID_CONST = 2;
	/*This parameter corresponds to field 63.1 of VISASMS protocol. 
	 * Nowdays there are only 2 types of networks supported: 
	 * 0002 (Visa, International usage)
	 * 0004 (Visa Plus, USA usage). 
	 * My opinion, that we should send 0002 as default and 0004 as 
	 * custom mode in projects where it will needed
	*/
	public MbPCtlPeerVISASMSWS(){
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		setUserLang(SessionWrapper.getField("language"));
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
				SettingsConstants.VISA_SMS_WS_PORT, LevelNames.SYSTEM, null);
		if (port == null) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					SettingsConstants.VISA_SMS_WS_PORT);
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
	 * Sends Visa Sms "echo test" command to FE. Uses bean's internal
	 * <code>hostId</code> and <code>deviceId</code>, so if corresponding
	 * parameters aren't set the command won't be completed. Response is handled
	 * automatically inside the method. To handle response manually use methods
	 * that return response code.
	 * </p>
	 */
	public void echoTest() {
		int respCode;
		try {
			respCode = echoTest(hostId, deviceId, String.format("%04d", NETWORK_ID_CONST)); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}

	public int echoTest(int hostId) throws Exception {
		return echoTest(hostId, 0, String.format("%04d", NETWORK_ID_CONST));
	}
	
	public int echoTest(int hostId, int deviceId, String networkId) throws Exception {
		NetMgmtType parameters = prepareParams(hostId, deviceId, networkId);
		PCtlPeerVISASMS port  = preparePort();
		
		return port.echoTest(parameters);
	}
	
	public int signOn(int hostId, int deviceId, String networkId) throws Exception {
		NetMgmtType parameters = prepareParams(hostId, deviceId, networkId);
		PCtlPeerVISASMS port  = preparePort();
		
		return port.signOn(parameters);
	}
	
	public int signOn(int hostId) throws Exception {
		return signOn(hostId, 0, null);
	}
	
	/**
	 * <p>
	 * Sends Visa Sms "sign on" command to FE. Uses bean's internal
	 * <code>hostId</code>, <code>deviceId</code> and <code>netwodkId</code>,
	 *  so if corresponding parameters aren't set the command won't 
	 *  be completed. Response is handled automatically inside the method.
	 *  To handle response manually use methods that return response code.
	 * </p>
	 */
	public void signOn() {
		int respCode;
		try {
			respCode = signOn(hostId, deviceId, String.format("%04d", NETWORK_ID_CONST)); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}
	/**
	 * <p>
	 * Sends Visa Sms "sign off" command to FE. Uses bean's internal
	 * <code>hostId</code>, <code>deviceId</code> and <code>netwodkId</code>,
	 * so if corresponding parameters aren't set the command won't
	 *  be completed. Response is handled automatically inside the method.
	 *  To handle response manually use methods that return response code.
	 * </p>
	 */
	public void signOff() {
		int respCode;
		try {
			respCode = signOff(hostId, deviceId, String.format("%04d", NETWORK_ID_CONST)); // 1 - good
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		handleResponse(respCode);
	}
	
	public int signOff(int hostId, int deviceId, String networkId) throws Exception{
		NetMgmtType parameters = prepareParams(hostId, deviceId, networkId);
		PCtlPeerVISASMS port  = preparePort();
		
		return port.signOff(parameters);
	}
	
	public int signOff(int hostId) throws Exception{
		return signOff(hostId, 0, null);
	}
	
	public int startAdvicesTrms(int hostId, int deviceId, String networkId) throws Exception{
		NetMgmtType parameters = prepareParams(hostId, deviceId, networkId);
		PCtlPeerVISASMS port  = preparePort();
		return port.startAdvicesTrms(parameters);
	}
	
	public int startAdvicesTrms(int hostId) throws Exception{
		return startAdvicesTrms(hostId, 0, null);
	}
	
	public void startAdvicesTrms(){
		int respCode;
		try{
			respCode = startAdvicesTrms(hostId, deviceId, String.format("%04d", NETWORK_ID_CONST));
		}catch (Exception e){
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}
		handleResponse(respCode);
	}
	
	public int stopAdvicesTrms(int hostId, int deviceId, String networkId) throws Exception{
		NetMgmtType parameters = prepareParams(hostId, deviceId, networkId);
		PCtlPeerVISASMS port  = preparePort();
		return port.stopAdvicesTrms(parameters);
	}
	
	public int stopAdvicesTrms(int hostId) throws Exception{
		return stopAdvicesTrms(hostId, 0, null);
	}
	
	public void stopAdvicesTrms(){
		int respCode;
		try{
			respCode = stopAdvicesTrms(hostId, deviceId, String.format("%04d", NETWORK_ID_CONST));
		}catch (Exception e){
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}
		handleResponse(respCode);
	}
	
	
	/*
	 * <xsd:element name="reasonCode">
        <xsd:simpleType>
        	<xsd:restriction base="xsd:string">
        		<xsd:enumeration value="2001"></xsd:enumeration>
        		<xsd:enumeration value="2002"></xsd:enumeration>
        		<xsd:enumeration value="2004"></xsd:enumeration>
        		<xsd:enumeration value="2013"></xsd:enumeration>
        		<xsd:enumeration value="2015"></xsd:enumeration>
        		<xsd:enumeration value="2102"></xsd:enumeration>
        		<xsd:enumeration value="2108"></xsd:enumeration>
        	</xsd:restriction>
        </xsd:simpleType>
	</xsd:element>
	 */
	public void sendCreditAdjustment(){
		int respCode;
		try{
			respCode = sendCreditAdjustment(authId, contactName,
					contactPhone, messageText, reasonCode, amount);
		}
			catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
				return;
			}

			handleResponse(respCode);
	}
	
	public int sendCreditAdjustment(Integer authId, String contactName, 
		String contactPhone, String messageText, String reasonCode,
		String amount) throws Exception{
		
		PCtlPeerVISASMS port  = preparePort();
		AdjustType parameters = prepareAdjustType(authId.toString(), contactName, 
				contactPhone, messageText, reasonCode, amount);
		return port.sendCreditAdjustment(parameters);
	}
	
	public int sendCreditAdjustment(Integer authId) throws Exception{
			return sendCreditAdjustment(authId, null, 
					null, null, null, null);
		}
	
	public void sendDebitAdjustment(){
		int respCode;
		try{
			respCode = sendDebitAdjustment(authId, contactName,
					contactPhone, messageText, reasonCode, amount);
		}catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
				return;
			}

			handleResponse(respCode);
	}
	
	public int sendDebitAdjustment(Integer authId, String contactName, 
			String contactPhone, String messageText, String reasonCode,
			String amount) throws Exception{
			
			PCtlPeerVISASMS port  = preparePort();
			AdjustType parameters = prepareAdjustType(authId.toString(), contactName, 
					contactPhone, messageText, reasonCode, amount);
			
			return port.sendDebitAdjustment(parameters);
	}
	
	public int sendDebitAdjustment(Integer authId) throws Exception{
			
			return sendDebitAdjustment(authId, null, 
					null, null, null, null);
	}
	
	/*
	 * <xsd:element name="reasonCode">
			<xsd:simpleType>
				<xsd:restriction base="xsd:string">
					<xsd:enumeration value="0100"></xsd:enumeration>
					<xsd:enumeration value="0110"></xsd:enumeration>
					<xsd:enumeration value="0130"></xsd:enumeration>
					<xsd:enumeration value="0140"></xsd:enumeration>
					<xsd:enumeration value="0150"></xsd:enumeration>
					<xsd:enumeration value="0170"></xsd:enumeration>
					<xsd:enumeration value="0200"></xsd:enumeration>
					<xsd:enumeration value="0210"></xsd:enumeration>
					<xsd:enumeration value="0220"></xsd:enumeration>
					<xsd:enumeration value="0230"></xsd:enumeration>
					<xsd:enumeration value="0240"></xsd:enumeration>
					<xsd:enumeration value="0250"></xsd:enumeration>
					<xsd:enumeration value="0350"></xsd:enumeration>
					<xsd:enumeration value="5010"></xsd:enumeration>
					<xsd:enumeration value="5020"></xsd:enumeration>
					<xsd:enumeration value="5040"></xsd:enumeration>
					<xsd:enumeration value="5080"></xsd:enumeration>
					<xsd:enumeration value="5140"></xsd:enumeration>
					<xsd:enumeration value="5150"></xsd:enumeration>
					<xsd:enumeration value="5185"></xsd:enumeration>
					<xsd:enumeration value="5190"></xsd:enumeration>
					<xsd:enumeration value="5195"></xsd:enumeration>
					<xsd:enumeration value="5290"></xsd:enumeration>
					<xsd:enumeration value="5300"></xsd:enumeration>
					<xsd:enumeration value="5310"></xsd:enumeration>
					<xsd:enumeration value="5320"></xsd:enumeration>
				</xsd:restriction>
			</xsd:simpleType>
		</xsd:element>
	 */
	
	public int sendFeeCollection(int hostMemberId, int acqMemberId, int deviceId,
			String networkId, String amount, int currency, String reasonCode, 
			String messageText,	String cardNo) throws Exception{
		PCtlPeerVISASMS port  = preparePort();
		FeeCollectFundsDisbType parameters = 
				prepareFeeCollectFundsDisbType(hostMemberId, acqMemberId, deviceId,
						networkId, amount, currency, reasonCode, 
						messageText, cardNo);
		return port.sendFeeCollection(parameters);
	}
	public int sendFeeCollection(int hostMemberId) throws Exception{
		return sendFeeCollection(hostMemberId, 0, 0, null, null, 0, null, null, null);
	}
	
	public void sendFeeCollection(){
		int respCode;
		try{
			respCode = sendFeeCollection(hostMemberId, acqMemberId, deviceId, 
					String.format("%04d", NETWORK_ID_CONST), amount, currency, reasonCode, messageText, 
					cardNo);
		}catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}
		handleResponse(respCode);
	}
	
	public int sendFundsDisbursement(int hostMemberId, int acqMemberId, int deviceId,
			String networkId, String amount, int currency, String reasonCode, 
			String messageText,	String cardNo) throws Exception{
		PCtlPeerVISASMS port  = preparePort();
		FeeCollectFundsDisbType parameters = 
				prepareFeeCollectFundsDisbType(hostMemberId, acqMemberId, deviceId,
						networkId, amount, currency, reasonCode, 
						messageText, cardNo);
		return port.sendFundsDisbursement(parameters);
	}
	
	public int sendFundsDisbursement(int hostMemberId) throws Exception{
		
		return sendFundsDisbursement(hostMemberId, 0, 0, null, null, 0, null, null, null);
	}
	
	public void sendFundsDisbursement(){
		int respCode;
		try{
			respCode = sendFundsDisbursement(hostMemberId, acqMemberId, deviceId, 
					String.format("%04d", NETWORK_ID_CONST), amount, currency, reasonCode, messageText, 
					cardNo);
		}catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}
		handleResponse(respCode);
	}
	
	public int sendRepresentment(Integer authId,
			String contactName, String contactPhone, String messageText,
			String docIndicator)throws Exception{
		PCtlPeerVISASMS port  = preparePort();
		
		SendRepresentment parameters = prepareSendRepresentment(authId.toString(),
				contactName, contactPhone, messageText, docIndicator);
		return port.sendRepresentment(parameters);
	}
	
	public int sendRepresentment(Integer authId)throws Exception{
		
		return sendRepresentment(authId, null, null, null, null);
	}
	
	public void sendRepresentment(){
		int respCode;
		try{
			respCode = sendRepresentment(authId, contactName, 
					contactPhone, messageText, docIndicator);
		}catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}
		handleResponse(respCode);
	}
	
	private SendRepresentment prepareSendRepresentment(String authId,
			String contactName, String contactPhone, String messageText,
			String docIndicator){
		ObjectFactory factory = new ObjectFactory();
		SendRepresentment params = factory.createSendRepresentment();
		params.setAuthId(authId);
		params.setContactName(contactName);
		params.setContactPhone(contactPhone);
		params.setDocIndicator(docIndicator);
		params.setMessageText(messageText);
		return params;
	}
	
	private FeeCollectFundsDisbType prepareFeeCollectFundsDisbType(
			int hostMemberId, int acqMemberId, int deviceId, String networkId,
			String amount, int currency, String reasonCode, String messageText,
			String cardNo){
		ObjectFactory factory = new ObjectFactory();
		FeeCollectFundsDisbType params = factory.createFeeCollectFundsDisbType();
		params.setAcqMemberID(acqMemberId);
		params.setAmount(amount);
		params.setCardNo(cardNo);
		params.setCurrency(currency);
		params.setDeviceID(prepareDeviceId(hostId));
		params.setHostMemberID(hostMemberId);
		params.setMessageText(messageText);
		params.setNetworkID(String.format("%04d", NETWORK_ID_CONST));
		params.setReasonCode(reasonCode);
		
		return params;
	}
	
	private NetMgmtType prepareParams(int hostId, int deviceId, String networkId){
		ObjectFactory factory = new ObjectFactory();
		NetMgmtType parameters = factory.createNetMgmtType();
		if (deviceId == 0){
			deviceId = prepareDeviceId(hostId);
		}
		parameters.setDeviceID(deviceId);
		parameters.setHostMemberID(hostId);
		parameters.setNetworkID(networkId);
		return parameters;
		
	}
	
	private int prepareDeviceId(int hostId){
		List<Filter>filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter = new Filter();
		paramFilter.setElement("hostMemberId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(hostId);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		SelectionParams params = new SelectionParams();
		params.setRowIndexStart(Integer.MIN_VALUE);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		NetDevice[] devices = _networkDao.getNetDevices(userSessionId, params);
		if (devices.length > 0){
			return devices[0].getId();
		}
		return 0;
	}
	
	
	/*
	 * <xsd:element name="reasonCode">
              <xsd:simpleType>
              	<xsd:restriction base="xsd:string">
              		<xsd:enumeration value="2001"></xsd:enumeration>
              		<xsd:enumeration value="2002"></xsd:enumeration>
              		<xsd:enumeration value="2004"></xsd:enumeration>
              		<xsd:enumeration value="2013"></xsd:enumeration>
              		<xsd:enumeration value="2015"></xsd:enumeration>
              		<xsd:enumeration value="2102"></xsd:enumeration>
              		<xsd:enumeration value="2108"></xsd:enumeration>
              	</xsd:restriction>
              </xsd:simpleType>
		</xsd:element>
	 */
	private AdjustType prepareAdjustType(String authId, String contactName, 
			String contactPhone, String messageText, String reasonCode,
			String amount){
		ObjectFactory factory = new ObjectFactory();
		AdjustType param = factory.createAdjustType();
		param.setAmount(amount);
		param.setAuthId(authId);
		param.setContactName(contactName);
		param.setContactPhone(contactPhone);
		param.setMessageText(messageText);
		param.setReasonCode(reasonCode);
		return param;
	}
	
	private PCtlPeerVISASMS preparePort( ) throws Exception{
		String feLocation = getFeLocation();
		
		PCtlPeerVISASMS_Service service = new PCtlPeerVISASMS_Service();
		PCtlPeerVISASMS port  = service.getPCtlPeerVISASMSSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
		return port;
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

	public String getUserLang() {
		return userLang;
	}

	public void setUserLang(String userLang) {
		this.userLang = userLang;
	}

	public int getAcqMemberId() {
		return acqMemberId;
	}

	public void setAcqMemberId(int acqMemberId) {
		this.acqMemberId = acqMemberId;
	}
	
	public Integer getNetworkId() {
		return networkId;
	}

	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}

	public Integer getAuthId() {
		return authId;
	}

	public void setAuthId(Integer authId) {
		this.authId = authId;
	}

	public String getContactName() {
		return contactName;
	}

	public void setContactName(String contactName) {
		this.contactName = contactName;
	}

	public String getContactPhone() {
		return contactPhone;
	}

	public void setContactPhone(String contactPhone) {
		this.contactPhone = contactPhone;
	}

	public String getReasonCode() {
		return reasonCode;
	}

	public void setReasonCode(String reasonCode) {
		this.reasonCode = reasonCode;
	}

	public String getMessageText() {
		return messageText;
	}

	public void setMessageText(String messageText) {
		this.messageText = messageText;
	}

	public String getAmount() {
		return amount;
	}

	public void setAmount(String amount) {
		this.amount = amount;
	}


	public int getHostMemberId() {
		return hostMemberId;
	}


	public void setHostMemberId(int hostMemberId) {
		this.hostMemberId = hostMemberId;
	}


	public String getCardNo() {
		return cardNo;
	}


	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}


	public int getCurrency() {
		return currency;
	}


	public void setCurrency(int currency) {
		this.currency = currency;
	}


	public String getDocIndicator() {
		return docIndicator;
	}

	/*
	 * <xsd:enumeration value="0"></xsd:enumeration>
	 * <xsd:enumeration value="1"></xsd:enumeration>
	 * <xsd:enumeration value="2"></xsd:enumeration>
	 * <xsd:enumeration value="3"></xsd:enumeration>
	 * <xsd:enumeration value="4"></xsd:enumeration>
	 * <xsd:enumeration value="Z"></xsd:enumeration>
	 */
	public void setDocIndicator(String docIndicator) {
		this.docIndicator = docIndicator;
	}
	
}
