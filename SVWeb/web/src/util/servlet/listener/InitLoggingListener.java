package util.servlet.listener;

import org.apache.log4j.xml.DOMConfigurator;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URL;
import java.util.Properties;

public class InitLoggingListener implements ServletContextListener {
	@Override
	public void contextDestroyed(ServletContextEvent sce) {
	}

	@Override
	public void contextInitialized(ServletContextEvent sce) {
		initLogs(sce.getServletContext());
	}

	private void initLogs(ServletContext ctx) {
		String userFile = ctx.getInitParameter(SystemConstants.EXTERNAL_PROPERTIES_FILE);
		Properties prop = new Properties();
		String logsPath = null;
		FileInputStream fis = null;
		if (userFile != null) {
			try {
				fis = new FileInputStream(userFile);
				prop.load(fis);
				logsPath = prop.getProperty(SystemConstants.LOGS_PATH);
			} catch (FileNotFoundException e) {
				System.out.println("WARNING: External properties file hasn't been found. Check your '" +
						SystemConstants.EXTERNAL_PROPERTIES_FILE + "' web.xml context parameter.");
			} catch (IOException e) {
				e.printStackTrace();
			} finally {
				if (fis != null) {
					try {
						fis.close();
					} catch (IOException ignored) {
					}
				}
			}
		} else {
			System.out.println("WARNING: web.xml context parameter '" + SystemConstants.EXTERNAL_PROPERTIES_FILE
					+ "' hasn't been found. Using default properties...");
		}

		if (logsPath == null) {
			System.out.println("Setting default logs path...");
			logsPath = "./sv_logs";
		} else {
			System.out.println("Logs are saved to: " + logsPath);
		}

		if (logsPath.endsWith("/")) {
			logsPath = logsPath.substring(0, logsPath.length() - 1);
		}

		System.setProperty("sv-logs-path", logsPath);

		// this file is always in class path unless someone changes build scripts or file name
		String file = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.LOG_CONFIG_FILE);
		if (file != null && !file.isEmpty()) {
			DOMConfigurator.configure(file);
		} else {
			URL log4jXML = Thread.currentThread().getContextClassLoader().getResource("log4jsv.xml");
			DOMConfigurator.configure(log4jXML);
		}
	}
}
