package ru.bpc.sv2.ui.error;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.ui.utils.RequestContextHolder;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.context.FacesContext;
import javax.security.auth.login.AccountExpiredException;
import javax.security.auth.login.LoginException;
import javax.servlet.http.HttpServletRequest;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Map;

@RequestScoped
@ManagedBean (name ="MbErrorUtils")
public class MbErrorUtils {
	
	private static final Logger logger = Logger.getLogger("SYSTEM");
	private boolean showErrorDetails = false;
	private String detailsForError;
	
	public String getStackTrace(){
		FacesContext context = FacesContext.getCurrentInstance();
		Map<String,Object> request = context.getExternalContext().getRequestMap();
		Throwable ex = (Throwable) request.get("javax.servlet.error.exception");
		logger.error("", ex);
		StringWriter sw = new StringWriter();
		PrintWriter pw = new PrintWriter(sw);
		fillStackTrace(ex, pw);
		return sw.toString();
	}

	private static void fillStackTrace(Throwable t, PrintWriter p){
		if (t == null)
			return;
		t.printStackTrace(p);
	}

	public String getDetailsForError() {
		return detailsForError;
	}

	public void setDetailsForError(String detailsForError) {
		this.detailsForError = detailsForError;
	}

	public boolean isPasswordExpiredErrorHappened() {
		boolean result = false;
		HttpServletRequest request = RequestContextHolder.getRequest();
		if (request != null) {
			Object ex = request.getSession().getAttribute(SystemConstants.SERVLET_ERROR_EXCEPTION);
			if (ex instanceof AccountExpiredException) {
				result = true;
			} else if (ex instanceof LoginException) {
				final String errorCode = "ORA-20017";
				String msg = ((LoginException) ex).getMessage();
				if (msg != null && msg.contains(errorCode)) {
					result = true;
				}
			}
		}
		return result;
	}

	public boolean isShowErrorDetails() {
		return showErrorDetails;
	}

	public void setShowErrorDetails(boolean showErrorDetails) {
		this.showErrorDetails = showErrorDetails;
	}
}