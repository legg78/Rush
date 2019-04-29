package ru.bpc.sv2.ui.utils;

import org.apache.log4j.Logger;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.ui.error.MbErrorUtils;
import util.auxil.ManagedBeanWrapper;

import javax.el.ELContext;
import javax.el.MethodExpression;
import javax.el.ValueExpression;
import javax.faces.application.FacesMessage;
import javax.faces.component.ContextCallback;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.management.RuntimeMBeanException;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.MessageFormat;
import java.util.Enumeration;
import java.util.List;
import java.util.ResourceBundle;

public class FacesUtils {
	private static final Logger logger = Logger.getLogger("COM");

	public static void addSystemError(Throwable e) {
		if (getRequiredFacesContext() != null) {
			MbErrorUtils mbErrorUtils = (MbErrorUtils) ManagedBeanWrapper.getManagedBean("MbErrorUtils");
			FacesMessage error = new FacesMessage(FacesMessage.SEVERITY_FATAL, e.getMessage(), "");
			getRequiredFacesContext().addMessage(null, error);
			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);
			e.printStackTrace(pw);
			pw.close();
			try {
				sw.close();
			} catch (IOException e1) {
				e1.printStackTrace();
			}
			mbErrorUtils.setDetailsForError(sw.toString());
		}
	}

	/**
	 * Add info message to FacesContext to display it
	 *
	 * @param message
	 */
	public static void addMessageInfo(String message) {
		if (message != null && getRequiredFacesContext() != null) {
			FacesMessage error = new FacesMessage(FacesMessage.SEVERITY_INFO, message, message);
			getRequiredFacesContext().addMessage(null, error);
		}
	}

	/**
	 * Add error message to FacesContext to display it
	 *
	 * @param thr
	 */
	public static void addMessageError(Exception thr) {
		addErrorExceptionMessage(null, thr);
		/*
		if ( thr == null )
		{
			return;
		}
		thr.printStackTrace();
		
		// TODO: some exceptions contain full stack trace in their message property.
		// It's essential to either change them with one standard message 
		// or just to shorten them in some way.
		String message = thr.getMessage();
		if (message != null && message.startsWith("ORA-")) {
			message = message.replaceFirst("ORA-\\d+: ","");
			message = message.split("ORA-\\d+:")[0];
		}
		FacesContext.getCurrentInstance().addMessage( null, new FacesMessage( FacesMessage.SEVERITY_ERROR, message, message ) );
		*/
	}

	public static void addMessageError(String msg) {
		addMessageError(null, msg);
	}

	public static void addMessageError(String id, String msg) {
		if (getRequiredFacesContext() != null) {
			FacesMessage error = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			getRequiredFacesContext().addMessage(id, error);
		}
	}

	/**
	 * Gets <code>bundle</cone>'s message using current user's locale settings
	 *
	 * @param bundle - bundle in which message is stored
	 * @param key    - key for wanted message
	 * @param args   - arguments to set into message
	 * @return - message in user's language
	 */
	public static String getMessage(String bundle, String key, Object... args) {
		ResourceBundle messages = ResourceBundle.getBundle(bundle, LocaleContextHolder.getLocale());
		String msg = messages.getString(key);
		if (args != null && args.length > 0) {
			MessageFormat mf = new MessageFormat(msg);
			msg = mf.format(args);
		}
		return msg;
	}

	public static String formatMessage(String msg, Object... args) {
		MessageFormat mf = new MessageFormat(msg);
		return mf.format(args);
	}

	/**
	 * Gets parameter from request. Useless for ordinary JSF's forwards.
	 *
	 * @param name - parameter name.
	 * @return parameter value taken from request.
	 */
	public static String getRequestParameter(String name) {
		return getRequiredFacesContext().getExternalContext().getRequestParameterMap().get(name);
	}

	/**
	 * Adds message from exception to FacesContext message queue with 'ERROR'
	 * severity
	 *
	 * @param exc info source exception. If null, then nothing happens
	 */
	public static void addErrorExceptionMessage(String id, Exception exc) {
		if (exc != null && getRequiredFacesContext() != null) {
			String message = getMessage(exc);
			FacesMessage error = new FacesMessage(FacesMessage.SEVERITY_ERROR, message, "");
			FacesContext currentInstance = getRequiredFacesContext();
			if (!containsError(currentInstance.getMessageList(), error)) {
				currentInstance.addMessage(id, error);
			}
		}
	}

	private static FacesContext getRequiredFacesContext() {
		FacesContext facesContext = FacesContext.getCurrentInstance();
		if (facesContext == null)
			logger.warn("FacesUtils: No FacesContext defined for the current thread");
		return facesContext;
	}

	private static boolean containsError(List<FacesMessage> errors, FacesMessage checkedError){
		for (FacesMessage error :errors){
			if (error.getSummary() != null &&
					error.getDetail() != null &&
					error.getSummary().equalsIgnoreCase(checkedError.getSummary()) &&
					error.getDetail().equalsIgnoreCase(checkedError.getDetail())){
				return  true;
			}
		}
		return false;
	}

	public static void addErrorExceptionMessage(Exception exc) {
		addErrorExceptionMessage(null, exc);
	}

	public static void addErrorExceptionMessage(String exc) {
		if (exc != null && getRequiredFacesContext() != null) {
			FacesMessage error = new FacesMessage(FacesMessage.SEVERITY_ERROR, exc, "");
			getRequiredFacesContext().addMessage(null, error);
		}
	}

	public static void addInfoMessage(String exc) {
		if (exc != null && getRequiredFacesContext() != null) {
			FacesMessage error = new FacesMessage(FacesMessage.SEVERITY_INFO, exc, "");
			getRequiredFacesContext().addMessage(null, error);
		}
	}

	public static void addWarningMessage(String exc) {
		if (exc != null && getRequiredFacesContext() != null) {
			FacesMessage error = new FacesMessage(FacesMessage.SEVERITY_WARN, exc, "");
			getRequiredFacesContext().addMessage(null, error);
		}
	}

	public static String getMessage(Throwable th) {
		if (th != null) {
			th = getCause(th);
			String message = (th.getMessage() == null) ? th.getClass().getName() : th.getMessage();
			if (message != null && message.startsWith("ORA-")) {
				message = message.replaceFirst("ORA-\\d+: ", "");
//				message = message.split("ORA-\\d+:")[0];
				message = message.split("\\n")[0];
			}
			return message;
		}
		return null;
	}

	public static Throwable getCause(Throwable th) {
		Throwable thCause = th;

		while (th != null) {
			thCause = th;
			if (thCause instanceof org.omg.CORBA.portable.UnknownException) {
				th = ((org.omg.CORBA.portable.UnknownException) thCause).originalEx;
			} else if (thCause instanceof RuntimeMBeanException) {
				th = ((RuntimeMBeanException) thCause).getTargetException();
			} else {
				th = thCause.getCause();
			}
		}

		return thCause;
	}

	public static MethodExpression getActionExpression(String action) {
		FacesContext ctx = getRequiredFacesContext();
		return ctx.getApplication().getExpressionFactory()
				.createMethodExpression(ctx.getELContext(), action, null, new Class<?>[0]);
	}

	@SuppressWarnings("unchecked")
	public static <T> T getValueExpression(String value, Class<T> clazz) {
		FacesContext ctx = getRequiredFacesContext();
		ELContext etx = ctx.getELContext();
		ValueExpression valueExpression = ctx.getApplication().getExpressionFactory().createValueExpression(etx, value, clazz);
		return (T) valueExpression.getValue(etx);
	}

	public static URL getResource(String path) throws MalformedURLException {
		ServletContext sc = (ServletContext) getRequiredFacesContext().getExternalContext().getContext();
		return sc.getResource(path);
	}

	/**
	 * <p>Gets object from session map by its <code>key</code>.</p>
	 *
	 * @param key
	 * @return
	 */
	public static Object getSessionMapValue(String key) {
		return getRequiredFacesContext().getExternalContext().getSessionMap().get(key);
	}

	/**
	 * <p>Stores value into session map.</p>
	 *
	 * @param key
	 * @param value
	 */
	public static void setSessionMapValue(String key, Object value) {
		getRequiredFacesContext().getExternalContext().getSessionMap().put(key, value);
	}

	/**
	 * <p>Removes mapping of object from session map by its <code>key</code>.</p>
	 *
	 * @param key
	 * @return
	 */
	public static Object removeSessionMapValue(String key) {
		return getRequiredFacesContext().getExternalContext().getSessionMap().remove(key);
	}

	/**
	 * <p>
	 * Gets mapping of object from session map by its <code>key</code> and
	 * deletes it (equivalent to <code>removeSessionMapValue</code>, added for
	 * better readability).
	 * </p>
	 *
	 * @param key
	 * @return
	 */
	public static Object extractSessionMapValue(String key) {
		return getRequiredFacesContext().getExternalContext().getSessionMap().remove(key);
	}

	/**
	 * Returns the value of the specified variable in the current expression
	 * context. This method returns the same value as would be returned by the
	 * #{varName} expression and is an easy way to get variable value in a
	 * backing bean if you can't write the value expression on your page
	 * directly and need to implement a more complex logic in the backing bean.
	 *
	 * @param varName variable name
	 * @return variable value
	 * @throws ClassCastException if the variable value is not of the expected type
	 * @author Dmitry Pikhulya
	 * @see http://www.openfaces.org
	 */
	public static Object var(String varName) {
		FacesContext context = getRequiredFacesContext();
		ELContext elContext = context.getELContext();
		return elContext.getELResolver().getValue(elContext, null, varName);
	}

	/**
	 * Searches the current facesContext view root for a component with provided clientId
	 *
	 * @param clientId clientId to look for
	 * @return found UIComponent, null if not found
	 */
	public static UIComponent findComponent(String clientId) {
		final UIComponent[] found = new UIComponent[]{null};
		try {
			getRequiredFacesContext().getViewRoot().invokeOnComponent(getRequiredFacesContext(), clientId, new ContextCallback() {
				@Override
				public void invokeContextCallback(FacesContext context, UIComponent target) {
					found[0] = target;
				}
			});
		} catch(Exception e){
			logger.debug("component " + clientId + " isn't found");
		}
		return found[0];
	}

	public static StringBuilder dumpFacesContext(FacesContext context, StringBuilder buf) {
		if (buf == null) {
			buf = new StringBuilder();
		}
		if (context != null) {
			buf.append("View: ").append(context.getViewRoot() != null ? context.getViewRoot().getViewId() : null).append("; ");
			if (context.getExternalContext() != null && context.getExternalContext().getRequest() instanceof HttpServletRequest) {
				HttpServletRequest req = (HttpServletRequest) context.getExternalContext().getRequest();
				buf.append("URL: ").append(req.getRequestURI()).append("; ");
				buf.append("\nRequest parameters: ");
				for (String name : req.getParameterMap().keySet()) {
					buf.append(name).append(": ").append(req.getParameter(name)).append("; ");
				}
				buf.append("\nRequest attributes: ");
				Enumeration<String> attributeNames = req.getAttributeNames();
				while (attributeNames.hasMoreElements()) {
					String name = attributeNames.nextElement();
					buf.append(name).append(": ").append(req.getAttribute(name)).append("; ");
				}
			}
		}
		return buf;
	}
}
