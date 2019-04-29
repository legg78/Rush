package ru.bpc.sv2.utils;

import java.util.ArrayList;
import java.util.List;

public abstract class ExceptionUtils {
	private ExceptionUtils() {
	}

	public static String getExceptionMessage(Throwable e) {
		StringBuilder result = new StringBuilder();
		List<Throwable> visited = new ArrayList<Throwable>();
		while (e != null && !visited.contains(e)) {
			visited.add(e);
			String msg = processOracleMessage(e.getLocalizedMessage());
			if (msg != null && result.indexOf(msg) < 0) {
				if (result.length() > 0)
					result.append(";  ");
				result.append(msg);
			}
			e = e.getCause();
		}
		return result.toString();
	}

	private static String processOracleMessage(String message) {
		if (message != null && message.startsWith("ORA-")) {
			message = message.replaceFirst("ORA-\\d+: ", "");
			message = message.split("ORA-\\d+:")[0];
		}
		return message;
	}
}
