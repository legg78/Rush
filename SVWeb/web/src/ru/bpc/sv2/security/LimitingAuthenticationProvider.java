package ru.bpc.sv2.security;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.ProviderNotFoundException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.ldap.authentication.LdapAuthenticationProvider;
import org.springframework.security.web.authentication.WebAuthenticationDetails;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.RequestContextHolder;

public class LimitingAuthenticationProvider implements AuthenticationProvider {
	private final static Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private static final String DEFAULT_IP_ADDRESS = "undefined";

	private static final String LOGIN_OK_STATUS = "UASTOKAY";
	private static final String LOGING_FAILED_STATUS = "UAST403";
	private static final String USER_LOCKED_STATUS = "UASTLOCK";

	private final UserService userService;
	private final AuthenticationProvider provider;

	public LimitingAuthenticationProvider(UserService userService,
	                                      AuthenticationProvider provider) {
		this.userService = userService;
		this.provider = provider;
	}

	@Override
	public Authentication authenticate(Authentication authentication) throws AuthenticationException {
		String userName = authentication.getPrincipal() == null ? "NONE_PROVIDED" : authentication.getName();

		try {
			String providerType = (provider instanceof LdapAuthenticationProvider ? "ldap" : "dao");
			logger.debug("Authentication attempt for user: " + userName + " (" + providerType + ")");
			String ipAddress = getIpAddress(authentication);

			Integer id = userService.retrieveUserId(userName);
			Long sessionId = userService.startSession(id, ipAddress);

			if (provider == null) {
				throw new ProviderNotFoundException("Provider is empty");
			}

			return authenticate(provider, authentication, id, sessionId);
		} catch (AuthenticationException ae) {
			logger.warn("Could not authenticate user: " + userName, ae);
			throw ae;
		}
	}

	private Authentication authenticate(AuthenticationProvider provider, Authentication authentication, Integer id, Long sessionId) throws AuthenticationException {
		AuthenticationException ae = null;
		String status;
		String ipAddress = getIpAddress(authentication);;
		try {
			authentication = provider.authenticate(authentication);
			status = userService.reportLogin(id, sessionId, ipAddress, LOGIN_OK_STATUS);
		} catch (UsernameNotFoundException unffe) {
			logger.error(unffe);
			ae = unffe;
			status = userService.reportLogin(id, sessionId, ipAddress, LOGING_FAILED_STATUS);
		} catch (BadCredentialsException bce) {
			logger.error(bce);
			ae = bce;
			status = userService.reportLogin(id, sessionId, ipAddress, LOGING_FAILED_STATUS);
		}

		if (LOGIN_OK_STATUS.equals(status)) {
			RequestContextHolder.getRequest().getSession().setAttribute(UserSession.USER_SESSION_ID_INITIAL, sessionId);
			return (authentication);
		} else if (USER_LOCKED_STATUS.equals(status)) {
			RequestContextHolder.getRequest().setAttribute(UserSession.ATTR_LOCKOUT_FLAG, "true");
			throw new BadCredentialsException("User is locked out");
		} else {
			throw ae;
		}
	}

	@Override
	public boolean supports(Class<?> authentication) {
		return UsernamePasswordAuthenticationToken.class.isAssignableFrom(authentication);
	}


	private String getIpAddress(Authentication authentication) {
		WebAuthenticationDetails details = (WebAuthenticationDetails) authentication.getDetails();
		String ipAddress = details.getRemoteAddress();
		if (StringUtils.isEmpty(ipAddress)) ipAddress = DEFAULT_IP_ADDRESS;
		return ipAddress;
	}
}
