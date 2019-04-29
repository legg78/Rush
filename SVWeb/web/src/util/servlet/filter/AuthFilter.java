package util.servlet.filter;

import com.bpcbt.svng.auth.AuthParamsHolder;
import org.apache.log4j.Logger;
import ru.bpc.sv2.acm.AcmPrivConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.logic.utility.db.UserContextHolder;
import ru.bpc.sv2.security.CertificateAuthException;
import ru.bpc.sv2.security.X509Utils;
import ru.bpc.sv2.ui.session.UserSession;

import javax.security.auth.login.AccountExpiredException;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.nio.file.attribute.UserPrincipalNotFoundException;

/**
 * Servlet Filter implementation class AuthFilter
 */
public class AuthFilter implements Filter {

	public static final String WELCOME_PAGE = "/pages/data.jsf";
	FilterConfig config = null;
	ServletContext servletContext = null;

	private static final Logger logger = Logger.getLogger("SYSTEM");

	/**
	 * Default constructor.
	 */
	public AuthFilter() {
		super();
	}

	/**
	 * @see Filter#destroy()
	 */
	public void destroy() {
	}

	/**
	 * @see Filter#doFilter(ServletRequest, ServletResponse, FilterChain)
	 */
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException,
			ServletException {
		HttpServletRequest httpRequest = (HttpServletRequest) request;
		HttpServletResponse httpResponse = (HttpServletResponse) response;
		HttpSession session = httpRequest.getSession();

		if (httpRequest.getUserPrincipal() == null) {
			UserContextHolder.setUserName(null);
			if (AuthParamsHolder.isUseSso()) {
				chain.doFilter(request, response);
				return;
			}
		} else {
			UserContextHolder.setUserName(httpRequest.getUserPrincipal().getName());
		}

		if (session.getAttribute("userSessionId") == null) {
			// uid is null. Try to obtain it. If Exception then redirect
			String userName = null;
			try {
				userName = httpRequest.getUserPrincipal().getName();
				X509Utils.checkCertificateIfNecessary(httpRequest, userName);
				RolesDao rolesDao = new RolesDao();

				Long userSessionId = rolesDao.setInitialUserContext(
						(Long) session.getAttribute(UserSession.USER_SESSION_ID_INITIAL),
						request.getRemoteAddr(),
						userName,
						AcmPrivConstants.LOGIN);

				session.setAttribute("userSessionId", userSessionId.toString());
				session.removeAttribute(UserSession.USER_SESSION_ID_INITIAL);

				try {
					if (rolesDao.checkPasswordExpired(userName)) {
						throw new AccountExpiredException();
					}
				} catch (AccountExpiredException e) {
					throw e;
				} catch (Exception e) {
					try {
						if (rolesDao.getUserIdByName(userName) == null) {
							throw new UserPrincipalNotFoundException("Could not find user");
						}
						logger.trace("User exist, password is configured outside the DB");
					} catch (Exception ee) {
						logger.warn("Could not check user password expiration: " + ee.getMessage());
					}
				}

				httpResponse.setHeader("Cache-Control", "no-cache");
				if (!httpRequest.getRequestURI().contains(WELCOME_PAGE)) {
					httpResponse.sendRedirect(httpRequest.getContextPath() + WELCOME_PAGE);
				}
				logger.debug("User " + userName + " logged in from IP " + request.getRemoteAddr());
			} catch (AccountExpiredException e) {
				httpRequest.getSession().setAttribute(SystemConstants.SERVLET_ERROR_EXCEPTION, e);
				httpResponse.sendRedirect(httpRequest.getContextPath() + "/error.jsf");
				return;
			} catch (Exception e) {
				httpResponse.setHeader("Cache-Control", "no-cache");
				if (e instanceof CertificateAuthException ||
						(e.getMessage() != null && e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR))) {
					httpRequest.getSession().setAttribute(UserSession.ATTR_LOGIN_EXCEPTION,
							(UserContextHolder.getUserName() != null ? UserContextHolder.getUserName() : "") + UserSession.USER_HAS_NO_LOGIN_PRIV_SUFFIX);
					httpResponse.sendRedirect(httpRequest.getContextPath() + "/error.jsf");
					return;
				} else if (!httpRequest.getRequestURI().contains(WELCOME_PAGE)) {
					if (userName != null) {
						logger.error(e.getMessage(), e);
					}
					UserSession.logout(httpRequest, httpResponse, true);
					return;
				}
				if (userName != null) {
					logger.error(e.getMessage(), e);
				}
			}
			chain.doFilter(request, response);
		} else {
			chain.doFilter(request, response);
		}
	}

	/**
	 * @see Filter#init(FilterConfig)
	 */
	public void init(FilterConfig fc) throws ServletException {
		config = fc;
		servletContext = config.getServletContext();
	}

}
