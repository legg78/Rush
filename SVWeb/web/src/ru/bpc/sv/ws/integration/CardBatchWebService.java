package ru.bpc.sv.ws.integration;

import org.apache.commons.lang3.StringUtils;
import org.apache.cxf.annotations.Policies;
import org.apache.cxf.annotations.Policy;
import org.apache.log4j.Logger;
import ru.bpc.sv.cardbatchws.*;
import ru.bpc.sv2.issuing.personalization.PersonalizationPrivConstants;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.logic.ws.CardBatchWsDao;
import ru.bpc.sv2.utils.ExceptionUtils;
import ru.bpc.sv2.utils.UserException;

import javax.annotation.Resource;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.WebServiceContext;
import java.security.Principal;

@SuppressWarnings("unused")
@WebService(name = "CardbatchWS", portName = "CardbatchSOAP", serviceName = "Cardbatch",
		targetNamespace = "http://bpc.ru/sv/cardbatchWS/", wsdlLocation = "META-INF/wsdl/cardbatchWS.wsdl")
@Policies({@Policy(uri = "ru/bpc/sv/ws/integration/ut.policy.xml")})
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
/* TODO: Below doesn't work in Websphere. Have to find a workaround
@com.sun.xml.ws.developer.SchemaValidation
*/
@XmlSeeAlso({ObjectFactory.class})
public class CardBatchWebService implements Cardbatch {
	private static final Logger logger = Logger.getLogger("ISSUING");

	@Resource
	protected WebServiceContext wsContext;

	@Override
	public int setBatchState(SetBatchStateRequestType request) throws CardbatchException {
		try {
			if (StringUtils.isBlank(request.getEventType()) && StringUtils.isBlank(request.getStateType()) ||
					!StringUtils.isBlank(request.getEventType()) && !StringUtils.isBlank(request.getStateType())) {
				throw new UserException("Either state_type or event_type (but not both) must be provided");
			}
			Principal userPrincipal = wsContext.getUserPrincipal();
			if (userPrincipal == null || userPrincipal.getName() == null) {
				throw new UserException("User is not specified in SOAP request");
			}
			String userName = userPrincipal.getName().toUpperCase();
			CardBatchWsDao cardBatchWs = new CardBatchWsDao();
			PersonalizationDao personalization = new PersonalizationDao();
			Long sessionId = cardBatchWs.registerSession(userName, PersonalizationPrivConstants.SET_PERSO_BATCH_STATUS_DELIVERED);
			personalization.changeBatchCardInstancesState(sessionId, request.getBatchId(), null, request.getStateType(), request.getEventType());
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FaultType type = new FaultType();
			type.setText(ExceptionUtils.getExceptionMessage(e));
			throw new CardbatchException("Error", type);
		}
		return 0;
	}
}
