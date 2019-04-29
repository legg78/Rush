package ru.bpc.sv2.logic.utility.db;

public class DataAccessException extends RuntimeException {
	public DataAccessException(String msg, Throwable e) {
		super(msg, e);
	}

	public DataAccessException(String msg) {
		super(msg);
	}

	public DataAccessException(Throwable e) {
		super(e);
	}
}
