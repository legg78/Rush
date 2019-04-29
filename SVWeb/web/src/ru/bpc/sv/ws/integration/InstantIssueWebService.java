package ru.bpc.sv.ws.integration;

import com.bpcbt.sv.camel.converters.CrefConverter;
import com.bpcbt.sv.camel.converters.DbalConverter;
import org.apache.commons.lang3.StringUtils;
import org.apache.cxf.annotations.Policies;
import org.apache.cxf.annotations.Policy;
import org.apache.log4j.Logger;
import org.springframework.util.CollectionUtils;
import ru.bpc.sv.instantissuews.*;
import ru.bpc.sv.svxp.card_info.CardsInfo;
import ru.bpc.sv.svxp.cardsecure.CardType;
import ru.bpc.sv.ws.cup.utils.XmlUtils;
import ru.bpc.sv2.issuing.CardData;
import ru.bpc.sv2.issuing.CardInfoXml;
import ru.bpc.sv2.issuing.CardSecurityData;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.logic.utility.db.UserContextHolder;
import ru.bpc.sv2.scheduler.process.svng.AbstractFeUnloadFileSaver;
import ru.bpc.sv2.utils.ExceptionUtils;
import ru.bpc.sv2.utils.UserException;

import javax.annotation.Resource;
import javax.jws.HandlerChain;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.WebServiceContext;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.security.Principal;

@SuppressWarnings("unused")
@WebService(name = "InstantIssueWS", portName = "InstantIssueSOAP", serviceName = "InstantIssue",
		targetNamespace = "http://bpc.ru/sv/instantissueWS/", wsdlLocation = "META-INF/wsdl/instantissueWS.wsdl")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@Policies({@Policy(uri = "ru/bpc/sv/ws/integration/ut.policy.xml")})
@XmlSeeAlso({ObjectFactory.class})
@HandlerChain(file = "./handler/instant_issue_handler.xml")
public class InstantIssueWebService implements InstantIssue {
	private static final Logger logger = Logger.getLogger("ISSUING");

	@Resource
	protected WebServiceContext wsContext;

	@Override
	public GetCardInfoResponseType getCardInfo(GetCardInfoRequestType request) throws InstantIssueException {
		try {
			Long sessionId = setupSession();
			IssuingDao issuingDao = new IssuingDao();
			PersonalizationDao personalization = new PersonalizationDao();
			CardInfoXml cardInfoXml = issuingDao.getCardInfoXml(sessionId, request.getApplId(), request.isIncludeLimits(), request.getLang());
			GetCardInfoResponseType result = new GetCardInfoResponseType();
			result.setBatchId(cardInfoXml.getBatchId());

			if (StringUtils.isNotBlank(cardInfoXml.getXml())) {
				CardsInfo cardsInfo = (CardsInfo) XmlUtils.toXMLObject(cardInfoXml.getXml(), CardsInfo.class);
				if (!CollectionUtils.isEmpty(cardsInfo.getCardInfo())) {
					result.setCardInfo(cardsInfo.getCardInfo().get(0));
				}
			}
			return result;
		} catch (Exception e) {
			throw createFault(e);
		} finally {
			UserContextHolder.setUserName(null);
		}
	}

	@Override
	public int processIBGData(CardType request) throws InstantIssueException {
		try {
			Long sessionId = setupSession();
			PersonalizationDao personalization = new PersonalizationDao();
			IssuingDao issuingDao = new IssuingDao();
			CardSecurityData data = new CardSecurityData();
			data.setCardId(request.getCardId());
			if (request.getCardId() == null && StringUtils.isNotBlank(request.getCardUid())) {
				data.setCardId(issuingDao.getCardIdByUid(sessionId, request.getCardUid()));
			}
			data.setCardNumber(request.getCardNumber());
			data.setExpirationDate(request.getExpirationDate() != null ? request.getExpirationDate().toGregorianCalendar().getTime() : null);
			data.setCardSequentalNumber(request.getCardSequentalNumber());
			data.setCardInstanceId(request.getCardInstanceId());
			data.setState(request.getState() != null ? request.getState().value() : null);
			data.setIssueDate(request.getIssueDate() != null ? request.getIssueDate().toGregorianCalendar().getTime() : null);
			ru.bpc.sv.svxp.cardsecure.CardSecurityType secr = request.getCardSecurity();
			if (secr != null) {
				data.setPvv(secr.getPVV());
				data.setPinOffset(secr.getPINOffset());
				data.setPinBlock(secr.getPINBlock());
				data.setKeyIndex(secr.getKeyIndex());
				data.setPinBlockFormat(secr.getPINBlockFormat() != null ? secr.getPINBlockFormat().value() : null);
			}
			personalization.changeCardSecurityData(sessionId, data);
			return 0;
		} catch (Exception e) {
			throw createFault(e);
		} finally {
			UserContextHolder.setUserName(null);
		}
	}

	@Override
	public UnloadCardDataResponseType unloadCardData(UnloadCardDataRequestType request) throws InstantIssueException {
		try {
			Long sessionId = setupSession();
			IssuingDao issuingDao = new IssuingDao();
			long cardId = request.getCardId() != null ? request.getCardId() : issuingDao.getCardIdByUid(sessionId, request.getCardUid());
			CardData cardData = issuingDao.getCardData(sessionId, cardId, request.isIncludeLimits(), request.isIncludeService(), request.getLang());

			UnloadCardDataResponseType result = new UnloadCardDataResponseType();

			AbstractFeUnloadFileSaver.setupConverterConfigPath(null);

			CrefConverter cref = new CrefConverter();
			ByteArrayInputStream bais = new ByteArrayInputStream(cardData.getCardXml().getBytes());
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			cref.convert(bais, baos);
			result.setCardInfo(baos.toString());

			DbalConverter dbal = new DbalConverter();
			bais = new ByteArrayInputStream(cardData.getAccountXml().getBytes());
			baos.reset();
			dbal.convert(bais, baos);
			result.setAccountInfo(baos.toString());

			return result;
		} catch (Exception e) {
			throw createFault(e);
		} finally {
			UserContextHolder.setUserName(null);
		}
	}

	private long setupSession() throws Exception {
		Principal userPrincipal = wsContext.getUserPrincipal();
		if (userPrincipal == null || userPrincipal.getName() == null) {
			throw new UserException("User is not specified in SOAP request");
		}
		String userName = userPrincipal.getName().toUpperCase();
		UserContextHolder.setUserName(userName);
		RolesDao rolesDao = new RolesDao();
		return rolesDao.setInitialUserContext(null, userName, null);
	}

	private InstantIssueException createFault(Exception e) {
		logger.error(e.getMessage(), e);
		FaultType type = new FaultType();
		type.setText(ExceptionUtils.getExceptionMessage(e));
		return new InstantIssueException("Error", type);
	}
}
