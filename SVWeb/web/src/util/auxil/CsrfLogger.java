package util.auxil;

import java.io.Serializable;

import org.apache.log4j.Logger;
import org.owasp.csrfguard.log.ILogger;
import org.owasp.csrfguard.log.LogLevel;

public class CsrfLogger implements ILogger, Serializable {
	private static final long serialVersionUID = -7312082082465352769L;
	
	private static final Logger logger = Logger.getLogger("CSRF");

	@Override
	public void log(String arg0) {
		log(LogLevel.Info, arg0);
	}

	@Override
	public void log(Exception arg0) {
		log(LogLevel.Error, arg0);
	}

	@Override
	public void log(LogLevel arg0, String arg1) {
		switch (arg0) {
		case Debug:
			logger.debug(arg1);
			break;
		case Info:
			logger.info(arg1);
			break;
		case Trace:
			logger.trace(arg1);
			break;
		case Warning:
			logger.warn(arg1);
			break;
		case Error:
			logger.error(arg1);
			break;
		case Fatal:
			logger.fatal(arg1);
			break;
		}
	}

	@Override
	public void log(LogLevel arg0, Exception arg1) {
		switch (arg0) {
		case Debug:
			logger.debug("", arg1);
			break;
		case Info:
			logger.info("", arg1);
			break;
		case Trace:
			logger.trace("", arg1);
			break;
		case Warning:
			logger.warn("", arg1);
			break;
		case Error:
			logger.error("", arg1);
			break;
		case Fatal:
			logger.fatal("", arg1);
			break;
		}
	}

}
