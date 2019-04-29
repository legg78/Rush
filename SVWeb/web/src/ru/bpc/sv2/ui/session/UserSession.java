package ru.bpc.sv2.ui.session;

import com.bpcbt.svng.auth.AuthParamsHolder;
import com.bpcbt.svng.auth.context.AuthContext;
import org.ajax4jsf.renderkit.RendererUtils;
import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.acm.AcmPrivConstants;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.logic.WidgetsDao;
import ru.bpc.sv2.logic.utility.db.UserContextHolder;
import ru.bpc.sv2.security.CertificateAuthException;
import ru.bpc.sv2.security.X509Utils;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.system.MbSystemInfo;
import ru.bpc.sv2.ui.dashboard.MbDashboard;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.RequestContextHolder;
import ru.bpc.sv2.ui.utils.Separators;
import ru.bpc.sv2.widget.Dashboard;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;
import util.servlet.listener.SessionListener;


import javax.faces.application.FacesMessage;
import javax.faces.application.FacesMessage.Severity;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.UIMessage;
import javax.faces.component.visit.VisitCallback;
import javax.faces.component.visit.VisitContext;
import javax.faces.component.visit.VisitResult;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.*;

@SuppressWarnings("UnusedDeclaration")
@SessionScoped
@ManagedBean(name = "usession")
public class UserSession implements Serializable {

	private static final long serialVersionUID = 1L;
	public static final String USER_IS_LOCKED_SUFFIX = " user is locked, try again later.";
	public static final String USER_HAS_NO_LOGIN_PRIV_SUFFIX = " user has no privilege to login.";
	public static final String MSG_INCORRECT_LOGIN = "You have entered an incorrect username/password.";
	public static final String ATTR_LOGIN_EXCEPTION = "LoginException";
	public static final String ATTR_LOCKOUT_FLAG = "UserLockout";
    public static final String USER_SESSION_ID_INITIAL = "userSessionIdInitial";
	private static final Integer ONE_MINUTE = 1;
	private static final Integer MIN_TO_MILLIS = 60000;
	private static final Integer SESSION_EXPIRE_DELTA_MILLIS = 10000;


	private UsersDao _usersDao = new UsersDao();
	private CommonDao _commonDao = new CommonDao();
	private WidgetsDao widgetsDao = new WidgetsDao();
	private SettingsDao _settingsDao = new SettingsDao();

	private static final RoleProxy _rolesProxy = new RoleProxy();

	private String userLanguage;
	private Integer userInst;
	private Integer userAgent;
	private String datePattern;
	private String fullDatePattern;
	private String fullDatePatternSeconds;
	private String fullDatePatternMilliseconds;
	private String userName;
	private String articleFormat;
	private String URLHelp;
	private String groupSeparator;

	private User user;

	private String errorDetails;

	private Dashboard[] userDashboards;
	private Integer dashboardId;

	private HashMap<String, Locale> locales = null;
	private Locale currentLocale;

	private static final Logger logger = Logger.getLogger("COMMON");

	private Long userSessionId = null;
	private transient DictUtils dictUtils;

	private Boolean blockCouncurrentSessions = null;
	private Integer sessionTimeout = null;

	public UserSession() {
		String attr = SessionWrapper.getUserSessionIdStr();
		if (attr != null && !attr.trim().isEmpty()) {
			userSessionId = Long.parseLong(attr);
		}
		loadDefaultLanguages();
	}

	private void loadLocales() {
		List<SelectItem> langs = getDictUtils().getArticles(DictNames.LANGUAGES);
		HashMap<String, Locale> locales = new HashMap<String, Locale>(langs.size());

		Filter[] filters = new Filter[2];
		filters[0] = new Filter("convId", SystemConstants.ARRAY_LOCALE_CONVERSION);
		filters[1] = new Filter();
		filters[1].setElement("inValue");
		SelectionParams params = new SelectionParams(filters);
		for (SelectItem lang : langs) {
			filters[1].setValue(lang.getValue());
			String isoLang;
			try {
				isoLang = _commonDao.getArrayOutElement(userSessionId, params);
			} catch (Exception e) {
				String msg = "ERROR: couldn't load system languages, previously loaded languages will be used...";
				logger.error(msg, e);
				loadDefaultLanguages();
				break;
			}
			if (isoLang == null) {
				// if there's no conversion from current language to ISO language we'll try
				// to use first two letters of current language
				isoLang = ((String) lang.getValue()).substring(4, 6).toLowerCase();
			}
			locales.put((String) lang.getValue(), new Locale(isoLang, isoLang.toUpperCase()));
		}
		this.locales = locales;
	}

	private void loadDefaultLanguages() {
		locales = new HashMap<String, Locale>(2);
		locales.put(SystemConstants.ENGLISH_LANGUAGE, Locale.US);
		locales.put(SystemConstants.RUSSIAN_LANGUAGE, new Locale("ru", "RU"));
	}

	public boolean isNoErrorResponse() {
		Severity maxSeverity = FacesContext.getCurrentInstance().getMaximumSeverity();
		return (maxSeverity == null || maxSeverity == FacesMessage.SEVERITY_INFO);
	}

	public boolean isUnrenderedMessagesExist() {
		FacesContext context = FacesContext.getCurrentInstance();
		final String flag = "javax.faces.visit.SKIP_ITERATION";
		Object savedFlag = context.getAttributes().get(flag);
		boolean hasUnrenderedMessages = false;
		try {
			// Setting flag to prevent iteration over rows (for components that have rows) before iterating
			// over children. Iterating over rows in visitTree call can cause exceptions for some components
			context.getAttributes().put(flag, true);
			// Iterating over validation messages
			for (Iterator<String> i = context.getClientIdsWithMessages(); i.hasNext(); ) {
				String clientId = i.next();
				if (clientId == null) {
					// General message, not bound to specific component
					hasUnrenderedMessages = true;
					break;
				}
				final UIComponent component = FacesUtils.findComponent(clientId); // Validated component
				if (component == null) {
					hasUnrenderedMessages = true;
					break;
				}
				final UIComponent[] messageComponent = new UIComponent[1];
				// Travesing component tree to find message component for current validation message
				context.getViewRoot().visitTree(VisitContext.createVisitContext(context), new VisitCallback() {
					@Override
					public VisitResult visit(VisitContext context, UIComponent target) {
						if (target instanceof UIMessage) {
							String forId = ((UIMessage) target).getFor();
							// Check if current message component is suitable for validated component
							if (forId != null &&
									(forId.equals(component.getId()) || forId.endsWith(":" + component.getId()))) {
								UIComponent messageFor =
										RendererUtils.getInstance().findComponentFor(target, component.getId());
								if (messageFor == component) {
									messageComponent[0] = messageFor;
									return VisitResult.COMPLETE;
								}
							}
						}
						return VisitResult.ACCEPT;
					}
				});
				if (messageComponent[0] == null) {
					hasUnrenderedMessages = true;
					break;
				}
			}
		} finally {
			if (savedFlag != null) {
				context.getAttributes().put(flag, savedFlag);
			} else {
				context.getAttributes().remove(flag);
			}
		}
		return hasUnrenderedMessages;
	}

	public String checkLogout() {
		MbSystemInfo systemInfoBean = ManagedBeanWrapper
				.getManagedBean("MbSystemInfo");
		if (!systemInfoBean.isConfigStand() || !getInRole().containsKey("VIEW_CONFIG_FILES") || !getInRole().containsKey("VIEW_SESSION_FILE")) {
			logout();
		} else {
			systemInfoBean.saveConfig();
		}
		return null;
	}

	// Checks if certificate is presented, if necessary
	public String getCheckCertificate() throws IOException {
		HttpServletRequest request = RequestContextHolder.getRequest();
		HttpServletResponse response = RequestContextHolder.getResponse();
		try {
			X509Utils.checkCertificateIfNecessary(request, null);
		} catch (CertificateAuthException e) {
			request.getSession().setAttribute(UserSession.ATTR_LOGIN_EXCEPTION,
					(UserContextHolder.getUserName() != null ? UserContextHolder.getUserName() : "") + UserSession.USER_HAS_NO_LOGIN_PRIV_SUFFIX);
			response.sendRedirect(request.getContextPath() + "/error.jsf");
		}
		return "";
	}

	// Checks if user is logged and logout if necessary
	public String getCheckLoggedUserBeforeLogin() {
		if (getUserName() != null) {
			try {
				if (!getInRole().get("SV_AUTHED") || !getInRole().get(AcmPrivConstants.LOGIN))
					logout();
				else {
					ExternalContext ectx = FacesContext.getCurrentInstance().getExternalContext();
					ectx.redirect(ectx.getRequestContextPath() + "/");
				}
			} catch (IOException e) {
				logger.error(e.getMessage(), e);
				logout();
			}
		}
		return "";
	}

	public String logout() {
		ExternalContext ectx = FacesContext.getCurrentInstance().getExternalContext();
		logout((HttpServletRequest) ectx.getRequest(), (HttpServletResponse) ectx.getResponse(), true);
		return null;
	}

	public static void logout(HttpServletRequest request, HttpServletResponse response, boolean sendRedirect) {
		logger.debug("Logout: " + request.getRemoteUser());
		if (AuthParamsHolder.isUseSso()) {
			try {
				response.sendRedirect(request.getContextPath() + "/logout");
			} catch (Exception ex) {
				logger.error("error on logout", ex);
			}

		} else {
			try {
				if (sendRedirect && response != null) {
					ExternalContext externalContext = FacesContext.getCurrentInstance() != null ? FacesContext.getCurrentInstance().getExternalContext() : null;
					if (MbSystemInfo.websphere()) {
						String url = request.getContextPath() + "/ibm_security_logout?logoutExitPage=" + request.getContextPath();
						if (externalContext != null) {
							externalContext.redirect(url);
						} else {
							response.sendRedirect(url);
						}
					} else {
						invalidateSession(request);
						if (externalContext != null) {
							externalContext.redirect(request.getContextPath() + "/");
						} else {
							response.sendRedirect(request.getContextPath() + "/");
						}
						requestLogout(request);
					}
				}
				if (!sendRedirect) {
					if (!MbSystemInfo.websphere()) {
						invalidateSession(request);
					}
					requestLogout(request);
				}
			} catch (IOException e) {
				logger.error("", e);
			}
		}
	}

	private static void requestLogout(HttpServletRequest request) {
		try {
			request.logout();
		} catch (Throwable ignored) {
		}
	}

	private static void invalidateSession(HttpServletRequest request) {
		try {
			request.getSession().invalidate();
		} catch (Throwable ignored) {
		}
	}

	public Map<String, Boolean> getInRole() {
		return _rolesProxy;
	}

	public String getUserName() {
		if (userName == null) {
			FacesContext context = FacesContext.getCurrentInstance();
			if (context != null) {
				String remoteUser = context.getExternalContext().getRemoteUser();
				userName = remoteUser != null ? remoteUser.toUpperCase() : null;
			}
		}

		return userName;
	}

	public boolean isUserLogged() {
		return !StringUtils.isBlank(getUserName());
	}

	public String getUserLanguage() {
		return userLanguage;
	}

	public void setUserLanguage(String userLanguage) {
		this.userLanguage = userLanguage;
	}

	public void flushUserLang() {
		this.userLanguage = _usersDao.getUserLanguage(getUserSessionId());
		SessionWrapper.setObjectField("language", userLanguage);
		FacesContext context = FacesContext.getCurrentInstance();
		loadLocales();
		currentLocale = locales.get(userLanguage);
		context.getViewRoot().setLocale(currentLocale);
	}

	public Locale getCurrentLocale() {
		if (currentLocale == null) {
			if (RequestContextHolder.getRequest() != null) {
				currentLocale = RequestContextHolder.getRequest().getLocale();
			}
			if (currentLocale == null && locales != null && !locales.isEmpty()) {
				return locales.get(SystemConstants.ENGLISH_LANGUAGE);
			}
		}
		return currentLocale;
	}

	public void flushUserInst() {
		this.userInst = _usersDao.getUserDefaultInst(userSessionId);
		SessionWrapper.setObjectField("defaultInst", userInst);
	}

	public boolean isRootUser() {
		boolean rootUser;
		try {
			rootUser = _usersDao.getRootUser(userSessionId);
		} catch (Exception e) {
			rootUser = false;
			logger.error("", e);
		}
		return rootUser;
	}

	public Integer getUserInst() {
		return userInst;
	}

	public void setUserInst(Integer userInst) {
		this.userInst = userInst;
	}

	public void flushUserDatePattern() {
		this.datePattern = _usersDao.getUserDatePattern(userSessionId);
		// this.timePattern = _usersDao.getUserTimePattern(userSessionId);
	}

	public String getDatePattern() {
		return datePattern;
	}

	public void setDatePattern(String datePattern) {
		this.datePattern = datePattern;
	}

	public String getFullDatePattern() {
		if (fullDatePattern == null) {
			fullDatePattern = datePattern + " " + DatePatterns.TIME_PATTERN;
		}
		return fullDatePattern;
	}

	public void setFullDatePattern(String fullDatePattern) {
		this.fullDatePattern = fullDatePattern;
	}

	public String getExpDatePattern() {
		return DatePatterns.EXP_DATE_PATTERN;
	}

	public String getFullExpDatePattern() {
		return DatePatterns.FULL_EXP_DATE_PATTERN;
	}

	public String getFullDatePatternSeconds() {
		if (fullDatePatternSeconds == null) {
			fullDatePatternSeconds = datePattern + " " + DatePatterns.TIME_SECONDS_PATTERN;
		}
		return fullDatePatternSeconds;
	}

	public String getFullDatePatternMilliseconds() {
		if (fullDatePatternMilliseconds == null) {
			fullDatePatternMilliseconds = datePattern + " " + DatePatterns.TIME_MILLISECONDS_PATTERN;
		}
		return fullDatePatternMilliseconds;
	}

	public void setSessionLastUse(String userName) {
		try {
			_usersDao.setSessionLastUse(userSessionId, userName);
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public User getUser() {
		if (user == null && userSessionId != null) {
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("name");
			filters[0].setValue(getUserName());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			user = _usersDao.getCurrentUserInfo(userSessionId, params);
		}
		return user;
	}

	public void loadErrorDetails() {
		try {
			errorDetails = _commonDao.getErrorDetais(userSessionId);
		} catch (Exception e) {
			logger.error("", e);
			errorDetails = "Cannot get error details.";
		}
	}

	public void clearErrorDetails() {
		errorDetails = null;
	}

	public String getErrorDetails() {
		loadErrorDetails();
		return errorDetails;
	}

	public Dashboard[] getUserDashboards() {
		if (userDashboards == null) {
			if (getUser() == null)
				return new Dashboard[0];
			String curLang = SessionWrapper.getField("language");
			Filter[] filters = new Filter[2];
			filters[0] = new Filter("userId", getUser().getId());
			filters[1] = new Filter("lang", curLang);
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			params.setRowIndexEnd(-1);
			try {
				userDashboards = widgetsDao.getDashboardsInfo(userSessionId, params);
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				//			logger.error("", e);
			}
			return new Dashboard[0];
		}
		return userDashboards;
	}

	public void resetDashboards() {
		userDashboards = null;
	}

	public String viewDashboard() {
		MbDashboard dashboardBean = ManagedBeanWrapper
				.getManagedBean("MbDashboard");
		if (!ObjectUtils.equals(dashboardBean.getCurrentDashboardId(), dashboardId)) {
			dashboardBean.setCurrentDashboardId(dashboardId);
			dashboardBean.updateCurrentDashboard();
		}
		return "acm_dashboard";
	}

	public String viewDefaultDashboard() {
		for (Dashboard dashboard : userDashboards) {
			dashboardId = dashboard.getId();
			if (dashboard.isDefaultDashboard()) {
				break;
			}
		}
		MbDashboard dashboardBean = ManagedBeanWrapper
				.getManagedBean("MbDashboard");
		if (!ObjectUtils.equals(dashboardBean.getCurrentDashboardId(), dashboardId)) {
			dashboardBean.setCurrentDashboardId(dashboardId);
			dashboardBean.updateCurrentDashboard();
		}
		return "acm_dashboard";
	}

	public Integer getDashboardId() {
		return dashboardId;
	}

	public void setDashboardId(Integer dashboardId) {
		this.dashboardId = dashboardId;
	}

	public int getSessionTimeout() {
		if (sessionTimeout == null) {
			try {
				Integer timeoutParam = _settingsDao.getParameterValueN(null, SettingsConstants.SESSION_TIMEOUT,
						LevelNames.SYSTEM, null).intValue();
				sessionTimeout = timeoutParam * MIN_TO_MILLIS; // from paramter
			} catch (Exception e) {
				logger.debug("Failed to get parameter " + SettingsConstants.SESSION_TIMEOUT, e);
				ExternalContext ectx = FacesContext.getCurrentInstance().getExternalContext();
				HttpSession session = (HttpSession) (ectx.getSession(false));
				if (session != null) {
					sessionTimeout = (session.getMaxInactiveInterval() + ONE_MINUTE) * MIN_TO_MILLIS; // from web.xml
				} else {
					sessionTimeout = 0;
				}
			}
		}
		return sessionTimeout;
	}

	private static class RoleProxy implements Map<String, Boolean> {

		@Override
		public void clear() {
		}

		@Override
		public boolean containsKey(Object key) {
			return get(key);
		}

		@Override
		public boolean containsValue(Object value) {
			return false;
		}

		@Override
		public Set<java.util.Map.Entry<String, Boolean>> entrySet() {
			//noinspection ConstantConditions
			return null;
		}

		@Override
		public Boolean get(Object key) {
			if (AuthParamsHolder.isUseSso()) {
				return key instanceof String && AuthContext.getInstance().hasAppPrivilege((String) key);
			}
			return key instanceof String &&
					FacesContext.getCurrentInstance().getExternalContext().isUserInRole((String) key);
		}

		@Override
		public boolean isEmpty() {
			return false;
		}

		@Override
		public Set<String> keySet() {
			//noinspection ConstantConditions
			return null;
		}

		@Override
		public Boolean put(String key, Boolean value) {
			return Boolean.FALSE;
		}

		@Override
		public void putAll(Map<? extends String, ? extends Boolean> m) {
		}

		@Override
		public Boolean remove(Object key) {
			return Boolean.FALSE;
		}

		@Override
		public int size() {
			return 0;
		}

		@Override
		public Collection<Boolean> values() {
			//noinspection ConstantConditions
			return null;
		}
	}

	public boolean getSeverityFatal() {
		FacesMessage.Severity svt = FacesContext.getCurrentInstance().getMaximumSeverity();
		return FacesMessage.SEVERITY_FATAL.equals(svt);
	}

	public boolean getSeverityError() {
		FacesMessage.Severity svt = FacesContext.getCurrentInstance().getMaximumSeverity();
		return FacesMessage.SEVERITY_ERROR.equals(svt);
	}

	public boolean getSeverityWarning() {
		FacesMessage.Severity svt = FacesContext.getCurrentInstance().getMaximumSeverity();
		return FacesMessage.SEVERITY_WARN.equals(svt);
	}

	public String getArticleFormat() {
		return articleFormat;
	}

	public void setArticleFormat(String articleFormat) {
		this.articleFormat = articleFormat;
	}

	public void flushArticleFormat() {
		articleFormat = _usersDao.getUserArticleFormat(userSessionId);
		SessionWrapper.setObjectField("articleFormat", articleFormat);
	}

	public String getGroupSeparator() {
		return groupSeparator;
	}

	public void setGroupSeparator(String groupSeparator) {
		this.groupSeparator = groupSeparator;
	}

	public void flushGroupSeparator() {
		groupSeparator = Separators.getSeparators().get(_usersDao.getGroupSeparator(userSessionId)).getSeparator();
	}

	public Integer getUserAgent() {
		return userAgent;
	}

	public void setUserAgent(Integer userAgent) {
		this.userAgent = userAgent;
	}

	public void flushUserAgent() {
		userAgent = _usersDao.getUserDefaultAgent(userSessionId);
		SessionWrapper.setObjectField("defaultAgent", userAgent);
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}

	public String getURLHelp() {
		if (URLHelp == null) {
			URLHelp = _settingsDao.getParameterValueV(null,
					SettingsConstants.URL_HELP, LevelNames.SYSTEM, null);
			if (URLHelp != null && !URLHelp.startsWith("http:") && !URLHelp.startsWith("/")) {
				URLHelp = "/" + URLHelp;
			}
		}
		return URLHelp;
	}

	public Date getOpenSttlDate() {
		try {
			Integer inst = userInst;
			if (inst == null) {
				inst = SystemConstants.DEFAULT_INSTITUTION;
			}
			return _commonDao.getOpenSttlDate(inst);
		} catch (Exception e) {
			return null;
		}
	}

	/* Override login error if user was locked */
	public String getLoginFailedDesc() {
		String loginFailedDesc = MSG_INCORRECT_LOGIN;

		MbSystemInfo mbSystemInfo = ManagedBeanWrapper.getManagedBean("MbSystemInfo");

		HttpServletRequest request = RequestContextHolder.getRequest();
		if (request != null) {
			String attr = (String) request.getAttribute(ATTR_LOGIN_EXCEPTION);
			HttpSession session = request.getSession();
			if (attr == null && session != null) {
				attr = (String) session.getAttribute(ATTR_LOGIN_EXCEPTION);
				session.removeAttribute(ATTR_LOGIN_EXCEPTION);
			}
			if (attr != null)
				loginFailedDesc = attr;
			String username = request.getParameter("j_username");
            boolean userActive = true;
			if (username != null) {
				try {
					try {
						userActive = _usersDao.isUserActive(username);
					} catch (Exception ignored) {
					}
				} catch (Exception e) {
					logger.error("", e);
				}
			}

            String lockoutFlag = (String) request.getAttribute(ATTR_LOCKOUT_FLAG);
            if (StringUtils.isNotEmpty(lockoutFlag)) {
                userActive = !"true".equals(lockoutFlag);
            }
            if (!userActive) {
                loginFailedDesc = (username != null ? username : "") + USER_IS_LOCKED_SUFFIX;
            }
		}
		return loginFailedDesc;
	}

	public String logoutOnErrorPage() {
		logout(RequestContextHolder.getRequest(), null, false);
		return null;
	}

	private Boolean getBlockCouncurrentSessions() {
		if (blockCouncurrentSessions == null) {
			try {
				blockCouncurrentSessions = !_settingsDao.getParameterValueN(null, SettingsConstants.BLOCK_USER_SESSIONS,
						LevelNames.SYSTEM, null).equals(0.0);
			} catch (Exception e) {
				logger.debug("Failed to get parameter " + SettingsConstants.BLOCK_USER_SESSIONS, e);
				blockCouncurrentSessions = Boolean.FALSE;
			}
		}
		return blockCouncurrentSessions;
	}

	private Long getUserSessionId() {
		if (userSessionId == null) {
			String attr = SessionWrapper.getUserSessionIdStr();
			if (attr != null && !attr.trim().isEmpty()) {
				userSessionId = Long.parseLong(attr);
			}
		}

		if (getBlockCouncurrentSessions()) {
			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("name");
			filters[0].setValue(getUserName());
			filters[1] = new Filter();
			filters[1].setElement("end_time");
			Long endTime = System.currentTimeMillis() - getSessionTimeout();
			filters[1].setValue(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(endTime));
			filters[2] = new Filter();
			filters[2].setElement("user_session_id");
			filters[2].setValue(userSessionId);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			Long[] sessions = _usersDao.getActiveSessionsIdByUser(userSessionId, params);
			for (Long session : sessions) {
				HttpSession sess = SessionListener.find(session.toString());
				if (sess != null) {
					sess.invalidate();
				}
			}
		}
		SessionListener.add(SessionWrapper.getSession());
		return userSessionId;
	}

	public Integer getSessionExpire() {
		return getSessionTimeout() + SESSION_EXPIRE_DELTA_MILLIS;
	}
}
