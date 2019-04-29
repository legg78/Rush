package ru.bpc.sv.ws.application;

import org.apache.commons.lang3.StringUtils;
import org.apache.cxf.annotations.Policies;
import org.apache.cxf.annotations.Policy;
import ru.bpc.sv2.application.ApplicationPrivConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.utils.UserException;

import javax.xml.transform.Source;
import javax.xml.ws.Provider;
import javax.xml.ws.ServiceMode;
import javax.xml.ws.WebServiceProvider;
import java.security.Principal;

@SuppressWarnings("unused")
@ServiceMode(value = javax.xml.ws.Service.Mode.PAYLOAD)
@WebServiceProvider(serviceName = "ApplicationServiceSecure", portName = "ApplicationsSecure", targetNamespace = "http://bpc.ru/SVAP",
		wsdlLocation = "/META-INF/svap.wsdl")
@Policies({@Policy(uri = "ru/bpc/sv/ws/integration/ut.policy.xml")})
public class ApplicationWsSecure extends ApplicationWs implements Provider<Source> {
	@Override
	public Source invoke(Source request) {
		return super.invoke(request);
	}

	protected void setupUserSession(String appType, Long instId) throws UserException {
		String role = null;
		if (appType.equals(ApplicationConstants.TYPE_ISSUING)) {
			role = ApplicationPrivConstants.ADD_ISSUING_APPLICATION;
		} else if (appType.equals(ApplicationConstants.TYPE_ACQUIRING)) {
			role = ApplicationPrivConstants.ADD_ACQUIRING_APPLICATION;
		} else if (appType.equals(ApplicationConstants.TYPE_USER_MNG)) {
			role = ApplicationPrivConstants.ADD_ACM_APPLICATION;
		} else if (appType.equals(ApplicationConstants.TYPE_ISS_PRODUCT)) {
			role = ApplicationPrivConstants.ADD_ISS_PRD_APPLICATION;
		} else if (appType.equals(ApplicationConstants.TYPE_ACQ_PRODUCT)) {
			role = ApplicationPrivConstants.ADD_ACQ_PRD_APPLICATION;
		} else if (appType.equals(ApplicationConstants.TYPE_DISPUTES)) {
			role = ApplicationPrivConstants.ADD_DISPUTE_APPLICATIONS;
		} else if (appType.equals(ApplicationConstants.TYPE_INSTITUTION)) {
			role = ApplicationPrivConstants.ADD_INSTITUTION_APPLICATION;
		} else {
			logger.warn("Unsupported application type [" + appType + "] is used");
		}

		Principal userPrincipal = wsContext.getUserPrincipal();
		if (userPrincipal == null || StringUtils.isBlank(userPrincipal.getName())) {
			throw new UserException("User is not specified in SOAP request");
		}
		userName = userPrincipal.getName().toUpperCase();
		userSessionId = appWsDao.registerSession(userName, role);

		if (instId != null && !appWsDao.isUserInInst(userSessionId, userName, instId)) {
			throw new UserException(String.format("User %s cannot create applications for institution %d", userName, instId));
		}
	}
}
