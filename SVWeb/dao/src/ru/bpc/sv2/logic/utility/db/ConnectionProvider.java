package ru.bpc.sv2.logic.utility.db;

import org.apache.log4j.Logger;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.utils.AppServerUtils;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * This class is primarily a workaround for WebSphere which throws "Illegal attempt to enlist multiple 1PC XAResources"
 * error when there is attempt to open Ibatis sesson when other session is already oppened.
 * This class provides connection manager that enforces use of single connection for current thread.
 */
class ConnectionProvider {
	private static final Logger systemLogger = Logger.getLogger("SYSTEM");
	private final ThreadLocal<MConnection> connection = new ThreadLocal<MConnection>();
	final static Map<MConnection, String> requestedConnections = new HashMap<MConnection, String>();


	Connection getConnection() throws SQLException {
		if (!AppServerUtils.isWebsphere()) {
			return JndiUtils.getConnection();
		} else {
			MConnection con = connection.get();
			if (con != null && !con.isClosed())
				con.requested();
			else {
				con = new MConnection(JndiUtils.getConnection(), connection);
				connection.set(con);
			}
			return con;
		}
	}

	private static class MConnection extends ConnectionWrapper {
		private final ThreadLocal<MConnection> connection;
		private int requestCount = 0;

		public MConnection(Connection target, ThreadLocal<MConnection> connection) {
			super(target);
			this.connection = connection;
			requested();
		}

		private void requested() {
			requestCount++;
			requestedConnections.put(this, "Thread " + Thread.currentThread().getId() + "(" + Thread.currentThread().getName() + ")");
		}

		private void returned() throws SQLException {
			requestCount--;
			if (requestCount <= 0) {
				if (requestCount < 0)
					systemLogger.error("Connection was returned more than requested");
				connection.set(null);
				requestedConnections.remove(this);
				super.close();
			}
		}

		@Override
		public void close() throws SQLException {
			returned();
		}
	}
}
