package ru.bpc.sv2.security;

import org.apache.log4j.Logger;
import org.apache.wss4j.common.ext.WSSecurityException;
import org.apache.wss4j.dom.handler.RequestData;
import org.apache.wss4j.dom.validate.Credential;
import org.apache.wss4j.dom.validate.Validator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.WebAuthenticationDetails;
import org.springframework.util.StringUtils;
import ru.bpc.sv2.ui.utils.RequestContextHolder;

public class WSUsernameTokenValidator implements Validator {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	@Autowired
	private AuthenticationManager authenticationManager;

	@Override
	public Credential validate(Credential credential, RequestData data) throws WSSecurityException {
		String username = credential.getUsernametoken().getName();
		String password = credential.getUsernametoken().getPassword();
		if (!StringUtils.hasText(username) || !StringUtils.hasText(password)) {
			logger.error("Username or password is not provided");
			throw new WSSecurityException(WSSecurityException.ErrorCode.FAILED_AUTHENTICATION);
		}
		Authentication token = new UsernamePasswordAuthenticationToken(username, password);
		try {
			WebAuthenticationDetails wad = new WebAuthenticationDetails(RequestContextHolder.getRequest());
			((UsernamePasswordAuthenticationToken) token).setDetails(wad);
			token = authenticationManager.authenticate(token);
		} catch (AuthenticationException e) {
			logger.error(e.getMessage(), e);
		}
		if (!token.isAuthenticated()) {
			throw new WSSecurityException(WSSecurityException.ErrorCode.FAILED_AUTHENTICATION);
		}
		return credential;
	}
}
