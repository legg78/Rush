package ru.bpc.sv2.utils;

import ru.bpc.sv2.constants.SystemConstants;

import java.sql.SQLException;

public class InsufficientPrivilegesException extends SQLException {
	private final String privName;

	public InsufficientPrivilegesException(String privName) {
		super(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR + ": " + privName);
		this.privName = privName;
	}

	public String getPrivName() {
		return privName;
	}
}
