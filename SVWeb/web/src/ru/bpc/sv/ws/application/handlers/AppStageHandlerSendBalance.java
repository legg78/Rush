package ru.bpc.sv.ws.application.handlers;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.UUID;

import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.ws.Binding;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.handler.Handler;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;

import org.apache.log4j.Logger;
import org.ifxforum.xsd._1.AcctIdentType;
import org.ifxforum.xsd._1.AcctKeysType;
import org.ifxforum.xsd._1.AcctRefType;
import org.ifxforum.xsd._1.CPPDataType;
import org.ifxforum.xsd._1.ContextRqHdrType;
import org.ifxforum.xsd._1.CurAmtType;
import org.ifxforum.xsd._1.CurCodeType;
import org.ifxforum.xsd._1.DebtorDataType;
import org.ifxforum.xsd._1.IFXType;
import org.ifxforum.xsd._1.IssuedIdentType;
import org.ifxforum.xsd._1.MsgRqHdrType;
import org.ifxforum.xsd._1.NetworkTrnDataType;
import org.ifxforum.xsd._1.OrgDataType;
import org.ifxforum.xsd._1.OrgNameType;
import org.ifxforum.xsd._1.PersonDataType;
import org.ifxforum.xsd._1.PersonNameType;
import org.ifxforum.xsd._1.PmtAddRqType;
import org.ifxforum.xsd._1.PmtAddRsType;
import org.ifxforum.xsd._1.PmtInfoType;
import org.ifxforum.xsd._1.PmtInstructionType;
import org.ifxforum.xsd._1.RefDataType;
import org.ifxforum.xsd._1.XferAddRqType;
import org.ifxforum.xsd._1.XferAddRsType;
import org.ifxforum.xsd._1.XferInfoType;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import ru.bpc.sv.svip.SVIP;
import ru.bpc.sv.svip.SVIP_Service;
import ru.bpc.sv.ws.handlers.soap.SOAPLoggingHandler;
import ru.bpc.sv2.application.ApplicationFlowStage;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.svip.SvipConstants;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

public class AppStageHandlerSendBalance extends AppStageHandler {

	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");
	private static final Logger logger = Logger.getLogger("SVAP");
	private static final String HANDLER_NAME = "AppStageHandlerSendBalance";

	private static final String PURPOSE_TRANSFER_TO_PERSON = "10000001";
	private static final String PURPOSE_TRANSFER_TO_ORG = "10000002";
	private static final String PURPOSE_P2P = "10000003";
//	private static final String PURPOSE_TRANSFER_TO_UNREG_CMS = "50000001";
//	private static final String PURPOSE_TRANSFER_TO_REG_CMS = "50000002";
	
	private static final String SYSTEM_TERMINAL_NUMBER = "SYSTEM_TERMINAL_NUMBER";
	private static final String ELEMENT_PAYMENT_ORDER = "PAYMENT_ORDER";

	public void process() {
		String errorMessage = null;
		Long purposeDataId = null;
		try {
			SettingsCache settingParamsCache = SettingsCache.getInstance();
			long processBegin = System.currentTimeMillis();
			setStageResult(ApplicationFlowStage.STAGE_RESULT_SUCCESS);
			String feLocation = settingParamsCache
					.getParameterStringValue(SettingsConstants.FRONT_END_LOCATION);
			if (feLocation == null || feLocation.trim().length() == 0) {
				logger.trace(HANDLER_NAME +
						": FE location parameter not defined! Finish handler with code 0020");
				loggerDB.trace(new TraceLogInfo(getSessionId(), HANDLER_NAME +
						": FE location parameter not defined! Finish handler with code 0020",
						EntityNames.APPLICATION, getApplicationId()));
				setStageResult(ApplicationFlowStage.STAGE_RESULT_FAIL);
				return;
			}
			/*
			 * BigDecimal wsPort = settingParamsCache
			 * .getParameterNumberValue(SettingsConstants.SVIP_WS_PORT); if (wsPort == null) {
			 * logger.trace(HANDLER_NAME +
			 * ": FE SVIP port parameter not defined! Finish handler with code 0020");
			 * setStageResult(ApplicationFlowStage.STAGE_RESULT_FAIL); return; }
			 * 
			 * feLocation = feLocation + ":" + wsPort.intValue();
			 */
			feLocation = feLocation + ":" + 29324;
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
			Date currentDate = new Date();

			SVIP_Service service = new SVIP_Service();
			SVIP port = service.getSVIPSOAP();
			BindingProvider bp = (BindingProvider) port;
			bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
			Binding binding = bp.getBinding();
			@SuppressWarnings("unchecked")
			List<Handler> soapHandlersList = new ArrayList<Handler>();
			SOAPLoggingHandler soapHandler = new SOAPLoggingHandler();
			soapHandler.setLogger(logger);
			soapHandlersList.add(soapHandler);
			binding.getHandlerChain();
			binding.setHandlerChain(soapHandlersList);
			CurrencyCache curCache = CurrencyCache.getInstance();

			XPath xpath = XPathFactory.newInstance().newXPath();
			XPathExpression expr = xpath.compile("/application/customer/customer_number");

			expr = xpath.compile("/application/customer/contract[1]/account[1]/account_number");
			String accountNumber = (String) expr.evaluate(getApplicationDoc(),
					XPathConstants.STRING);

			expr = xpath.compile("/application/institution_id");
			Integer instId = ((Double) expr.evaluate(getApplicationDoc(), XPathConstants.NUMBER))
					.intValue();

			expr = xpath.compile("/application/customer/contract[1]/account[1]/payment_order[1]");
			Node paymentOrderNode = (Node) expr.evaluate(getApplicationDoc(), XPathConstants.NODE);

			if (paymentOrderNode == null) {
				setStageResult(ApplicationFlowStage.STAGE_RESULT_SUCCESS);
				return;
			}
			expr = xpath.compile("payment_purpose_id");
			String purposeId = (String) expr.evaluate(paymentOrderNode, XPathConstants.STRING);

			if (purposeId == null || "".equals(purposeId)) {
				setStageResult(ApplicationFlowStage.STAGE_RESULT_SUCCESS);
				return;
			}
			expr = xpath.compile("@dataId");
			String purposeDataIdAttr = (String) expr.evaluate(paymentOrderNode,
					XPathConstants.STRING);
			if (purposeDataIdAttr != null) {
				purposeDataId = Long.parseLong(purposeDataIdAttr);
			}

			expr = xpath.compile("payment_amount");
			Double payAmount = (Double) expr.evaluate(paymentOrderNode, XPathConstants.NUMBER);

			expr = xpath.compile("currency");
			String rqCurrencyNum = (String) expr.evaluate(paymentOrderNode, XPathConstants.STRING);

			BigDecimal rqAmount = null;
			boolean isEmptyAmount = false;
			if (payAmount == null || payAmount.isNaN() || rqCurrencyNum == null ||
					rqCurrencyNum.equals("")) {
				isEmptyAmount = true;
				rqAmount = new BigDecimal(0);
				rqCurrencyNum = "643";
			} else {
				if (payAmount != null && !payAmount.isNaN()) {
					rqAmount = new BigDecimal(payAmount);
				}
			}

			MsgRqHdrType msgRqHdr = new MsgRqHdrType();
			ContextRqHdrType contextRqHdr = new ContextRqHdrType();
			NetworkTrnDataType networkTrnData = new NetworkTrnDataType();
			networkTrnData.setNetworkOwner("Branch");
			String terminalNumber = settingParamsCache.getInstParameterStringValue(instId,
					SYSTEM_TERMINAL_NUMBER);
			networkTrnData.setTerminalIdent(terminalNumber);
			contextRqHdr.setNetworkTrnData(networkTrnData);
			
			GregorianCalendar cal = new GregorianCalendar();
			cal.setTime(currentDate);
			contextRqHdr.setClientDt(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			
			msgRqHdr.setContextRqHdr(contextRqHdr);

			AcctRefType fromAcctRef = new AcctRefType();
			AcctKeysType acctKeys = new AcctKeysType();
			AcctIdentType acctIdent = new AcctIdentType();
			acctIdent.setAcctIdentType(SvipConstants.ifxAcctIdentTypeAcctNum);
			acctIdent.setAcctIdentValue(accountNumber);
			acctKeys.setAcctIdent(acctIdent);
			fromAcctRef.setAcctKeys(acctKeys);

			CurAmtType curAmt = new CurAmtType();
			CurCodeType curCode = new CurCodeType();
			curCode.setCurCodeValue(curCache.getCurrencyShortNamesMap().get(rqCurrencyNum));
			curAmt.setCurCode(curCode);
			curAmt.setAmt(rqAmount);

			List<RefDataType> refDataList = new ArrayList<RefDataType>();
			RefDataType refData = null;
			//TODO Remove?
			if (!PURPOSE_P2P.equals(purposeId)) {
				refData = new RefDataType();
				refData.setRefType("PurposeSpecific");
				refData.setRefIdent(purposeId);
				refDataList.add(refData);
			}
			refData = new RefDataType();
			refData.setRefType("AmountCalculation");
			if (isEmptyAmount) {
				refData.setRefIdent("OALG0020");
			} else {
				refData.setRefIdent("OALG0010");
			}
			refDataList.add(refData);

			IFXType ifx = new IFXType();
			String uuid = UUID.randomUUID().toString();

			expr = xpath.compile("payment_parameter");
			XPathExpression exprParamName = xpath.compile("payment_parameter_name");
			XPathExpression exprParamValue = xpath.compile("payment_parameter_value");
			NodeList paramsNodes = (NodeList) expr.evaluate(paymentOrderNode,
					XPathConstants.NODESET);

			if (PURPOSE_P2P.equals(purposeId)) {
				String toAcctIdentType = null;
				String toAcctIdentValue = null;

				for (int i = 0; i < paramsNodes.getLength(); i++) {
					Node paramNode = paramsNodes.item(i);
					String paramName = (String) exprParamName.evaluate(paramNode,
							XPathConstants.STRING);
					String paramValue = (String) exprParamValue.evaluate(paramNode,
							XPathConstants.STRING);
					if (SvipConstants.bpcPmoRecipientIdentType.equals(paramName)) {
						toAcctIdentType = paramValue;
					} else if (SvipConstants.bpcPmoRecipientIdentValue.equals(paramName)) {
						toAcctIdentValue = paramValue;
					}
				}

				AcctRefType toAcctRef = new AcctRefType();
				AcctKeysType toAcctKeys = new AcctKeysType();
				AcctIdentType toAcctIdent = new AcctIdentType();
				toAcctIdent.setAcctIdentType(SvipConstants.clientIdTypesReverseMap
						.get(toAcctIdentType));
				toAcctIdent.setAcctIdentValue(toAcctIdentValue);
				toAcctKeys.setAcctIdent(toAcctIdent);
				toAcctRef.setAcctKeys(toAcctKeys);

				XferInfoType xferInfo = new XferInfoType();
				xferInfo.setFromAcctRef(fromAcctRef);
				xferInfo.setToAcctRef(toAcctRef);
				xferInfo.setCurAmt(curAmt);
				xferInfo.getRefData().addAll(refDataList);
				xferInfo.setCategory("GuaranteedPeer");
				XferAddRqType xferAddRq = new XferAddRqType();
				xferAddRq.setMsgRqHdr(msgRqHdr);
				xferAddRq.setRqUID(uuid);
				xferAddRq.setXferInfo(xferInfo);
				ifx.getAcctInqRqOrAcctModRqOrAcctRevRq().add(xferAddRq);
			} else {
				List<IssuedIdentType> params = null;
				CPPDataType cppData = new CPPDataType();
				if (PURPOSE_TRANSFER_TO_PERSON.equals(purposeId)) {
					PersonDataType personData = new PersonDataType();
					cppData.setPersonData(personData);
					params = personData.getIssuedIdent();
				} else if (PURPOSE_TRANSFER_TO_ORG.equals(purposeId)) {
					OrgDataType orgData = new OrgDataType();
					cppData.setOrgData(orgData);
					params = orgData.getIssuedIdent();
				} else {
					OrgDataType orgData = new OrgDataType();
					cppData.setOrgData(orgData);
					params = orgData.getIssuedIdent();
				}
				String payerName = null;
				String legalName = null;
				String memo = null;

				for (int i = 0; i < paramsNodes.getLength(); i++) {
					Node paramNode = paramsNodes.item(i);
					String paramName = (String) exprParamName.evaluate(paramNode,
							XPathConstants.STRING);
					String paramValue = (String) exprParamValue.evaluate(paramNode,
							XPathConstants.STRING);
					if (SvipConstants.bpcPmoPayerName.equals(paramName)) {
						payerName = paramValue;
					} else if (SvipConstants.bpcPmoRecipientName.equals(paramName)) {
						legalName = paramValue;
						if (cppData.getOrgData() != null) {
							OrgNameType orgName = new OrgNameType();
							orgName.setLegalName(legalName);
							cppData.getOrgData().getOrgName().add(orgName);
						}
					} else if (SvipConstants.bpcPmoMemo.equals(paramName)) {
						memo = paramValue;
					} else {
						IssuedIdentType param = new IssuedIdentType();
						String svipParamName = SvipConstants.pmoParamsMap.get(paramName);
						if (svipParamName != null && !"".equals(svipParamName)) {
							param.setIssuedIdentType(svipParamName);
							param.setIssuedIdentValue(paramValue);
							params.add(param);
						} else {
							logger.trace("Parameter " + paramName +
									"not found in map for SVIP params");
							loggerDB.trace(new TraceLogInfo(getSessionId(), "Parameter " + paramName +
									"not found in map for SVIP params", EntityNames.APPLICATION, getApplicationId()));
						}
					}
				}

				DebtorDataType debtorData = new DebtorDataType();
				PersonDataType personData = new PersonDataType();
				PersonNameType personName = new PersonNameType();
				personName.setFullName(payerName);
				personData.getPersonName().add(personName);
				debtorData.setPersonData(personData);

				PmtInstructionType pmtInstruction = new PmtInstructionType();
				pmtInstruction.setPmtMethod("Electronic");
				pmtInstruction.setFromAcctRef(fromAcctRef);
				pmtInstruction.setMemo(memo);
				pmtInstruction.getRefData().addAll(refDataList);

				PmtInfoType pmtInfo = new PmtInfoType();
				pmtInfo.setCurAmt(curAmt);
				pmtInfo.setCPPData(cppData);
				pmtInfo.setDebtorData(debtorData);
				pmtInfo.setPmtInstruction(pmtInstruction);
				GregorianCalendar calendar = new GregorianCalendar();
				calendar.setTime(currentDate);
				XMLGregorianCalendar dateXmlGregorian = DatatypeFactory.newInstance()
						.newXMLGregorianCalendar(calendar);
				pmtInfo.setPrcDt(dateXmlGregorian);

				PmtAddRqType pmtAddRq = new PmtAddRqType();
				pmtAddRq.setPmtInfo(pmtInfo);
				pmtAddRq.setRqUID(uuid);
				pmtAddRq.setMsgRqHdr(msgRqHdr);
				ifx.getAcctInqRqOrAcctModRqOrAcctRevRq().add(pmtAddRq); // TODO: kinda strange method, needs to be checked 
			}
			logger.trace(HANDLER_NAME + ": Prepare data for SVIP:" +
					(System.currentTimeMillis() - processBegin));
			loggerDB.trace(new TraceLogInfo(getSessionId(), HANDLER_NAME + ": Prepare data for SVIP:" +
					(System.currentTimeMillis() - processBegin), EntityNames.APPLICATION, getApplicationId()));
			processBegin = System.currentTimeMillis();
			IFXType svipResp = port.doIFX(ifx);
			logger.trace(HANDLER_NAME + ": Invoke SVIP:" +
					(System.currentTimeMillis() - processBegin));
			loggerDB.trace(new TraceLogInfo(getSessionId(), HANDLER_NAME + ": Invoke SVIP:" +
					(System.currentTimeMillis() - processBegin), EntityNames.APPLICATION, getApplicationId()));
			List<?> resps = svipResp.getAcctInqRsOrAcctModRsOrAcctRevRs(); // TODO: kinda strange method, needs to be checked
			Object resp = resps.get(0);
			int rqStatusCode = 100;
			String statusCode = null;
			String authId = null;
			if (resp instanceof PmtAddRsType) {
				rqStatusCode = ((PmtAddRsType) resp).getStatus().getStatusCode();
				statusCode = ((PmtAddRsType) resp).getPmtStatusRec().getPmtStatus()
						.getPmtStatusCode();
				authId = ((PmtAddRsType) resp).getPmtStatusRec().getPmtId();
			} else if (resp instanceof XferAddRsType) {
				rqStatusCode = ((XferAddRsType) resp).getStatus().getStatusCode();
				statusCode = ((XferAddRsType) resp).getXferStatusRec().getXferStatus()
						.getXferStatusCode();
				authId = ((XferAddRsType) resp).getXferStatusRec().getXferId();
			}
			String comment = "SVIP request status: " + rqStatusCode + "; auth status: " +
					statusCode;
			if (authId != null) {
				comment += "; auth ID: " + authId;
			}
			logger.trace(HANDLER_NAME + ": " + comment);
			loggerDB.trace(new TraceLogInfo(getSessionId(), HANDLER_NAME + ": " + comment,
					EntityNames.APPLICATION, getApplicationId()));

			setStageResultComment(comment);
			if (rqStatusCode == 0) {
				if (SvipConstants.ifxXferStatusCodePosted.equals(statusCode)) {
					setStageResult(ApplicationFlowStage.STAGE_RESULT_SUCCESS);
				} else {
					setStageResult(ApplicationFlowStage.STAGE_RESULT_FAIL);
					addError(purposeDataId, ELEMENT_PAYMENT_ORDER, null, comment, null);
				}
			} else {
				setStageResult(ApplicationFlowStage.STAGE_RESULT_FAIL);
				addError(purposeDataId, ELEMENT_PAYMENT_ORDER, null, comment, null);
			}
			return;
		} catch (Exception e) {
			logger.error(HANDLER_NAME + " error", e);
			loggerDB.error(new TraceLogInfo(getSessionId(), e.getMessage(), EntityNames.APPLICATION, getApplicationId()), e);
			setStageResult(ApplicationFlowStage.STAGE_RESULT_FAIL);
			errorMessage = "Server error during processing stage";
			addError(purposeDataId, ELEMENT_PAYMENT_ORDER, null, errorMessage, null);
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
