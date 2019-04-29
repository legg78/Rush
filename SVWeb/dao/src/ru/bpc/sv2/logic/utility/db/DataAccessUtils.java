package ru.bpc.sv2.logic.utility.db;

import java.sql.SQLException;

public final class DataAccessUtils {
	private DataAccessUtils() {
	}

	public static DataAccessException createException(Exception e) {
		while (e instanceof SQLException && e.getCause() instanceof Exception && e.getCause() != e)
			e = (Exception) e.getCause();
		return new DataAccessException(e.getMessage(), e);
	}
}
