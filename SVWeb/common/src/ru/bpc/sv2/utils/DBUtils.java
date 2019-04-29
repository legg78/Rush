package ru.bpc.sv2.utils;

import oracle.jdbc.OracleConnection;
import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import oracle.sql.STRUCT;
import oracle.sql.StructDescriptor;
import org.apache.log4j.Logger;

import java.lang.reflect.Method;
import java.sql.*;

public class DBUtils {
	private static final Logger logger = Logger.getLogger("SYSTEM");

	public static Connection getNativeConnection(Connection con) {
		try {
			try {
				// Trying to unwrap to Oracle native connection
				con = con.unwrap(OracleConnection.class);
			} catch (Exception e) {
				if (AppServerUtils.isWebsphere()) {
					Class<?> clazz = Class.forName("com.ibm.websphere.rsadapter.WSCallHelper");
					Method method = clazz.getMethod("getNativeConnection", Object.class);
					return (Connection) method.invoke(null, con);
				}
				return con;
			}
			return con;
		} catch (Exception e) {
			String message = "Cannot get connection: " + e.getMessage();
			logger.error(message, e);
			throw new RuntimeException(message, e);
		}
	}

	public static void close(Connection con) {
		if (con == null) {
			return;
		}

		try {
			con.close();
		} catch (SQLException ignored) {
		}
	}

	public static void close(Statement stmt) {
		if (stmt == null) {
			return;
		}

		try {
			stmt.close();
		} catch (SQLException ignored) {
		}
	}

	public static void close(ResultSet resultSet) {
		if (resultSet == null) {
			return;
		}

		try {
			resultSet.close();
		} catch (SQLException ignored) {
		}
	}

	public static ARRAY createArray(String typeName, Connection con, Object[] arrayData) throws SQLException {
		con = DBUtils.getNativeConnection(con);
		ArrayDescriptor descriptor = ArrayDescriptor.createDescriptor(typeName, con);
		return new ARRAY(descriptor, con, arrayData);
	}

	public static STRUCT createStruct(String typeName, Connection con, Object[] structData) throws SQLException {
		con = DBUtils.getNativeConnection(con);
		StructDescriptor descriptor = StructDescriptor.createDescriptor(typeName, con);
		return new STRUCT(descriptor, con, structData);
	}
}
