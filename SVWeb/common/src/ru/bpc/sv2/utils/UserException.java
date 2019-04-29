package ru.bpc.sv2.utils;

public class UserException extends Exception {

	public static final int FATAL_ERROR = 20999;
	public static final int ERROR = 20001;

	private static final long serialVersionUID = 4575044522372477404L;

	private int errorCode = FATAL_ERROR;

	private String errorCodeText;
	private Object details;
	private boolean errorCodeTextAvailable;

	public UserException(String message) {
		super(message);
	}

	public UserException(Throwable t) {
		super(t);
	}

	public UserException(String message, int errorCode, Throwable cause) {
		super(message, cause);
		this.errorCode = errorCode;
	}

	public UserException(String message, String errorCodeText, Object details) {
		super(message);
		this.errorCodeText = errorCodeText;
		this.details = details;
		this.errorCodeTextAvailable = true;
	}

	public UserException(String message, Throwable cause) {
		super(message, cause);
	}

	public int getErrorCode() {
		return errorCode;
	}

	public String getErrorCodeText() {
		return errorCodeText;
	}

	public Object getDetails() {
		return details;
	}

	public void setDetails(Object details) {
		this.details = details;
	}

	public boolean isErrorCodeTextAvailable() {
		return errorCodeTextAvailable;
	}

}
