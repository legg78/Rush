package util.servlet.listener;

import org.apache.log4j.Logger;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.ui.session.UserSession;
import util.auxil.ManagedBeanWrapper;


import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
import java.util.HashMap;
import java.util.Map;

public class SessionListener implements HttpSessionListener {
	private static final Logger logger = Logger.getLogger("SYSTEM");
	private static final Map<String, HttpSession> sessions = new HashMap<String, HttpSession>();
	private static final Integer SEC_TO_MILLIS = 1000;

	private SettingsDao _settingsDao = new SettingsDao();

	public SessionListener() {
		super();
	}

	@Override
	public void sessionCreated(HttpSessionEvent se) {
		if (se != null) {
			add(se.getSession());
		}
	}

	@Override
	public void sessionDestroyed(HttpSessionEvent se) {
		HttpSession session = se.getSession();
		try {
			delete(session);
			UserSession usession;
			try {
				usession = (UserSession) session.getAttribute("usession");
			} catch (IllegalStateException e) {
				// session is already invalid, no need to deal with it
				return;
			}
			if (usession == null) {
				usession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
			}
			if (usession != null && usession.getUserName() != null) {
				usession.setSessionLastUse(usession.getUserName());
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		} finally {
			try {
				session.setAttribute("userSessionId", null);
			} catch (Exception e) {
				logger.error(e.getMessage(), e);
			}
		}
	}

    public static void add(HttpSession session) {
        if (session != null) {
            if (session.getAttribute("usession") != null) {
                session.setMaxInactiveInterval(((UserSession)session.getAttribute("usession")).getSessionTimeout() / SEC_TO_MILLIS);
            }
            if (session.getAttribute("userSessionId") != null) {
                sessions.put(session.getAttribute("userSessionId").toString(), session);
            }
        }
    }

	public static HttpSession find(String sessionId) {
		return sessions.get(sessionId);
	}

	public static void delete(HttpSession session) {
		if (session != null && session.getAttribute("userSessionId") != null) {
			sessions.remove(session.getAttribute("userSessionId").toString());
		}
	}
}
