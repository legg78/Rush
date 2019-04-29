package ru.bpc.sv2.security;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import java.security.cert.X509Certificate;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class X509Utils {
	private static final Logger logger = Logger.getLogger("SECURITY");
	private static final String DEFAULT_SUBJECT_DN_PATTERN = "CN=(.*?)(?:,|$)";
	private static Pattern subjectDnPattern;
	private static String subjectDnPatternStr;
	private static AuthScheme globalAuthScheme;

	public static AuthScheme getEffectiveAuthScheme(String username) {
		if (globalAuthScheme == null) {
			String val = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.AUTH_SCHEME);
			if (StringUtils.isBlank(val)) {
				globalAuthScheme = AuthScheme.ATHSPASS;
			} else {
				try {
					globalAuthScheme = AuthScheme.valueOf(val);
				} catch (Exception e) {
					logger.error(String.format("Unsupported %s:%s", SettingsConstants.AUTH_SCHEME, val), e);
					globalAuthScheme = AuthScheme.ATHSPASS;
				}
			}
		}
		AuthScheme userAuthScheme = null;
		if (username != null) {
			UsersDao usersDao = new UsersDao();
			String authSchemeStr = usersDao.getUserAuthScheme(null, username);
			try {
				userAuthScheme = AuthScheme.valueOf(authSchemeStr);
			} catch (Exception ignored) {
			}
			if (userAuthScheme != null) {
				return userAuthScheme;
			}
		}
		return globalAuthScheme;
	}

	public static void checkCertificateIfNecessary(HttpServletRequest request, String currentUsername) throws CertificateAuthException {
		if (getEffectiveAuthScheme(currentUsername) == AuthScheme.ATHSPASS) {
			return;
		}
		X509Certificate[] certs = (X509Certificate[]) request
				.getAttribute("javax.servlet.request.X509Certificate");

		if (certs != null && certs.length > 0) {
			if (logger.isDebugEnabled()) {
				logger.debug("X.509 client authentication certificate:" + certs[0]);
			}
			String userName = extractPrincipal(certs[0]);
			if (currentUsername == null || userName.equalsIgnoreCase(currentUsername)) {
				return;
			} else {
				logger.error(String.format("User logged in [%s] does not correspond to certificate principal [%s]", currentUsername, userName));
			}
		}

		try {
			request.logout();
		} catch (ServletException e) {
			logger.error(e.getMessage(), e);
		}
		throw new CertificateAuthException("No client certificate found in request");
	}

	private static String extractPrincipal(X509Certificate clientCert) throws CertificateAuthException {
		String pattern = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.AUTH_SUBJECT_DN_PATERN);
		if (subjectDnPatternStr == null || !subjectDnPatternStr.equals(pattern)) {
			subjectDnPattern = null;
			try {
				subjectDnPatternStr = pattern;
				subjectDnPattern = Pattern.compile(pattern);
			} catch (Exception e) {
				logger.error("Cannot compile SUBJECT_DN_PATTERN setting value:" + pattern);
			}
			if (subjectDnPattern == null) {
				subjectDnPatternStr = DEFAULT_SUBJECT_DN_PATTERN;
				subjectDnPattern = Pattern.compile(subjectDnPatternStr);
			}
			logger.debug("Subject DN pattern:" + subjectDnPattern);
		}
		String subjectDN = clientCert.getSubjectDN().getName();
		if (logger.isDebugEnabled()) {
			logger.debug("Subject DN is '" + subjectDN + "'");
		}

		Matcher matcher = subjectDnPattern.matcher(subjectDN);

		if (!matcher.find()) {
			throw new CertificateAuthException("No matching pattern was found in subject DN:" + subjectDN);
		}

		if (matcher.groupCount() != 1) {
			throw new CertificateAuthException("Regular expression must contain a single group:" + subjectDnPattern);
		}

		String username = matcher.group(1);

		logger.debug("Extracted Principal name is '" + username + "'");

		return username;
	}
}
