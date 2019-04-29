package ru.bpc.sv2.utils;

public class SystemException extends Exception {

	private static final long serialVersionUID = 4575044522372477404L;

	public SystemException(String message) {
		super(message);
	}

	public SystemException(Throwable e) {
		this(e.getMessage(), e);
	}

	public SystemException(String message, Throwable cause) {
		super(message, cause);
	}
}

