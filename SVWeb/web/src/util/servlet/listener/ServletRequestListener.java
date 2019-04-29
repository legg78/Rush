package util.servlet.listener;

import org.apache.log4j.Logger;
import ru.bpc.sv2.ui.utils.LocaleContextHolder;
import ru.bpc.sv2.ui.utils.RequestContextHolder;

import javax.servlet.ServletRequestEvent;
import javax.servlet.http.HttpServletRequest;

public class ServletRequestListener implements javax.servlet.ServletRequestListener {
	private static final Logger logger = Logger.getLogger("SYSTEM");

	public void requestInitialized(ServletRequestEvent requestEvent) {
		if (!(requestEvent.getServletRequest() instanceof HttpServletRequest)) {
			logger.error("Request is not an HttpServletRequest: " + requestEvent.getServletRequest());
		} else {
			HttpServletRequest request = (HttpServletRequest) requestEvent.getServletRequest();
			LocaleContextHolder.setLocale(request.getLocale());
			RequestContextHolder.setRequest(request);
		}
	}

	public void requestDestroyed(ServletRequestEvent requestEvent) {
		LocaleContextHolder.setLocale(null);
		RequestContextHolder.reset();
	}
}
