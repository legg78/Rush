package ru.bpc.sv2.process.filereader;

public class ItemReaderException extends Exception {

	private static final long serialVersionUID = -7924633985487456823L;

	public ItemReaderException() {
		super();
	}

	@SuppressWarnings("Since15")
	public ItemReaderException(String message, Throwable cause,
	                           boolean enableSuppression, boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
	}

	public ItemReaderException(String message, Throwable cause) {
		super(message, cause);
	}

	public ItemReaderException(String message) {
		super(message);
	}

	public ItemReaderException(Throwable cause) {
		super(cause);
	}
}
