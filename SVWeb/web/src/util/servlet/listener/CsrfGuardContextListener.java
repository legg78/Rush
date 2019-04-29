package util.servlet.listener;

import org.owasp.csrfguard.CsrfGuardServletContextListener;
import util.auxil.PrngProvider;

import javax.servlet.ServletContextEvent;
import java.security.Security;

public class CsrfGuardContextListener extends CsrfGuardServletContextListener {
	@Override
	public void contextInitialized(ServletContextEvent event) {
		Security.addProvider(new PrngProvider());
		super.contextInitialized(event);
	}
}
