package ru.bpc.sv2.schedule;

public class CronFormatException extends Exception {
	private static final long serialVersionUID = 1L;

	public CronFormatException() {
		super();
	}
	
	public CronFormatException(String s) {
		super(s);
	}
	
	public CronFormatException(Throwable th) {
		super(th);
	}
}
