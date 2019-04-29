package util.auxil;

import org.apache.log4j.Logger;

import javax.faces.context.FacesContext;
import javax.servlet.http.HttpSession;

public abstract class SessionWrapper {
	private static final Logger logger = Logger.getLogger("COM");

	public static String getUid() {
		try {
			return (String) getRequiredSession().getAttribute("uid");
		} catch (Exception e) {
			return null;
		}
	}

	public static void setUid(String uid) {
		try {
			getRequiredSession().setAttribute("uid", uid);
		} catch (Exception ignored) {
		}
	}

	public static String getField(String fieldname) {
		try {
			return (String) getRequiredSession().getAttribute(fieldname);
		} catch (Exception e) {
			return null;
		}
	}

	public static void setField(String fieldname, String value) {
		try {
			getRequiredSession().setAttribute(fieldname, value);
		} catch (Exception ignored) {
		}
	}

	public static Object getObjectField(String fieldname) {
		try {
			return getRequiredSession().getAttribute(fieldname);
		} catch (Exception e) {
			return null;
		}
	}

	public static void setObjectField(String fieldname, Object value) {
		try {
			getRequiredSession().setAttribute(fieldname, value);
		} catch (Exception ignored) {
		}
	}

	public static HttpSession getRequiredSession() {
		try {
			FacesContext context = FacesContext.getCurrentInstance();
			return (HttpSession) context.getExternalContext().getSession(false);
		} catch (Exception e) {
			throw new RuntimeException("HTTP session is not defined", e);
		}
	}

	public static HttpSession getSession() {
		try {
			FacesContext context = FacesContext.getCurrentInstance();
			return (HttpSession) context.getExternalContext().getSession(false);
		} catch (Exception e) {
			return null;
		}
	}

	public static String getUserSessionIdStr() {
		return getField("userSessionId");
	}

	public static long getRequiredUserSessionId() {
		String userSessionId = getUserSessionIdStr();
		if (userSessionId == null) {
			String message = "Could not get userSessionId";
			logger.error(message);
			throw new RuntimeException(message);
		}
		try {
			return Long.parseLong(userSessionId);
		} catch (NumberFormatException e) {
			logger.error("Could not parse userSessionId", e);
			throw e;
		}
	}
}
