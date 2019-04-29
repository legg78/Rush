package ru.bpc.sv2.system;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;

import javax.servlet.ServletContext;
import java.io.IOException;
import java.io.InputStream;
import java.util.jar.Manifest;

public abstract class AppVersion {
	private final static String BUILD_VERSION = "ru.bpc.sv.web.BUILD_VERSION";
	private final static String REVISION_PATH = "/META-INF/MANIFEST.MF";
	private final static String REVISION_KEY = "Implementation-Build";
	private final static String BUILD_BRANCH = "Build-Branch";
	private static final Logger logger = Logger.getLogger("SYSTEM");
	private static String appVersion = null;

	private AppVersion() {
	}

	public static String getVersion() {
		return appVersion;
	}

	public static void initializeRevision(ServletContext servletContext) {
		String version = servletContext.getInitParameter(BUILD_VERSION);
		boolean revisionNotExist = true;
		InputStream is = null;

		if (version != null && version.length() > 0) {
			revisionNotExist = version.indexOf('#') < 0;
			logger.info("BUILD_VERSION = " + version);
		}
		if (revisionNotExist) {
			try {
				is = servletContext.getResourceAsStream(REVISION_PATH);

				Manifest mf = new Manifest(is);
				String revision = mf.getMainAttributes().getValue(REVISION_KEY);

				if (revision == null || revision.equals("-1")) {
					revision = mf.getMainAttributes().getValue(BUILD_BRANCH);
				}

				if (revision != null && revision.length() > 0) {
					if (version != null && version.length() > 0) {
						version += "#" + revision;
					} else {
						version = revision;
					}
					logger.info("REVISION_NUMBER = " + revision);
					appVersion = revision;
				}
			} catch (IOException ignored) {
			} finally {
				IOUtils.closeQuietly(is);
			}
		}
		version = (version == null) ? "unknow" : version;
		servletContext.setAttribute(BUILD_VERSION, version);
	}
}
