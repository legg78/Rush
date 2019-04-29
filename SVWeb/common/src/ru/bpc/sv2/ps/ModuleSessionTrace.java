package ru.bpc.sv2.ps;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.sql.Timestamp;

public class ModuleSessionTrace implements Serializable, ModelIdentifiable {
	private String id;
	private Timestamp eventDate;
	private String logLevel;
	private String logger;
	private String message;

	public String getLogger() {
		return logger;
	}

	public void setLogger(String logger) {
		this.logger = logger;
	}

	public Timestamp getEventDate() {
		return eventDate;
	}

	public void setEventDate(Timestamp eventDate) {
		this.eventDate = eventDate;
	}

	public String getLogLevel() {
		return logLevel;
	}

	public void setLogLevel(String logLevel) {
		this.logLevel = logLevel;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	@Override
	public Object getModelId() {
		return id;
	}
}
