package ru.bpc.sv2.logic.utility;

import org.apache.log4j.Logger;
import ru.bpc.sv2.logic.utility.db.IbatisClient;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

public final class JndiUtils {
	public final static String JNDI_NAME = "jdbc/SVWeb";
	protected static Logger logger = Logger.getLogger("SYSTEM");
	private static volatile InitialContext sharedInitialContext;

	private JndiUtils() {
	}

	/**
	 * Use this method to get a shared synchronized version of InitialContext that was created in main web app server thread
	 * Some application servers do not provide complete InitialContext for unmanaged threads, i.e. threads that were created by
	 * user. This shared version would allow such threads to access full version of InitialContext.
	 *
	 * @return shared InitialContext
	 */
	public static InitialContext getInitialContext() {
		if (sharedInitialContext != null) {
			return sharedInitialContext;
		}
		synchronized (JndiUtils.class) {
			try {
				if (sharedInitialContext == null) {
					sharedInitialContext = new SynchronizedInitialContext(new InitialContext());
					IbatisClient.getInstance();
				}
			} catch (NamingException e) {
				logger.error("Could not initialize shared InitialContext: " + e.getMessage());
				throw new RuntimeException(e.getMessage(), e);
			}
		}
		return sharedInitialContext;
	}


	public static DataSource getDataSource() {
		try {
			return (DataSource) getInitialContext().lookup(JNDI_NAME);
		} catch (NamingException e) {
			logger.error("Couldn't establish connection with datasource \"" + JNDI_NAME +"\"", e);
		}
		return null;
	}

	public static Connection getConnection() throws SQLException {
		return getDataSource().getConnection();
	}
}
