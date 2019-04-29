package org.apache.cxf.spring.boot.autoconfigure;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.HashMap;
import java.util.Map;

// This is a "hack" to override original CxfProperties class and to remove @Validated annotation
// as it fails to work in Weblogic and no workaround has been found yet
@ConfigurationProperties("cxf")
public class CxfProperties {

	/**
	 * Path that serves as the base URI for the services.
	 */
	private String path = "/services";

	private final Servlet servlet = new Servlet();

	public String getPath() {
		return this.path;
	}

	public void setPath(String path) {
		this.path = path;
	}

	public Servlet getServlet() {
		return this.servlet;
	}

	public static class Servlet {

		/**
		 * Servlet init parameters to pass to Apache CXF.
		 */
		private Map<String, String> init = new HashMap<>();

		/**
		 * Load on startup priority of the Apache CXF servlet.
		 */
		private int loadOnStartup = -1;

		public Map<String, String> getInit() {
			return this.init;
		}

		public void setInit(Map<String, String> init) {
			this.init = init;
		}

		public int getLoadOnStartup() {
			return this.loadOnStartup;
		}

		public void setLoadOnStartup(int loadOnStartup) {
			this.loadOnStartup = loadOnStartup;
		}

	}

	public CxfProperties() {
		super();
	}
}
