package ru.bpc.sv2.ui.utils;

import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Holder class to expose the web request in the form of a thread-bound object. The request will be inherited
 * by any child threads spawned by the current thread
 */
public class RequestContextHolder {
	private static final ThreadLocal<HttpServletRequest> requestHolder =
			new InheritableThreadLocal<HttpServletRequest>();
	private static final ThreadLocal<HttpServletResponse> responseHolder =
			new InheritableThreadLocal<HttpServletResponse>();

	public static HttpServletRequest getRequest() {
		FacesContext facesContext = FacesContext.getCurrentInstance();
		if (facesContext != null) {
			ExternalContext externalContext = facesContext.getExternalContext();
			if (externalContext != null) {
				HttpServletRequest request = (HttpServletRequest) externalContext.getRequest();
				if (request != null)
					return request;
			}
		}
		return requestHolder.get();
	}

	public static HttpServletResponse getResponse() {
		FacesContext facesContext = FacesContext.getCurrentInstance();
		if (facesContext != null) {
			ExternalContext externalContext = facesContext.getExternalContext();
			if (externalContext != null) {
				HttpServletResponse response = (HttpServletResponse) externalContext.getResponse();
				if (response != null)
					return response;
			}
		}
		return responseHolder.get();
	}

	public static void setRequest(HttpServletRequest request) {
		if (request == null)
			requestHolder.remove();
		else
			requestHolder.set(request);
	}

	public static void setResponse(HttpServletResponse response) {
		if (response == null)
			responseHolder.remove();
		else
			responseHolder.set(response);
	}

	public static void reset() {
		setRequest(null);
		setResponse(null);
	}
}
