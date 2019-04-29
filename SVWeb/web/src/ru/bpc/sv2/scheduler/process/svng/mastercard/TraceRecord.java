package ru.bpc.sv2.scheduler.process.svng.mastercard;

import org.apache.commons.beanutils.BeanUtils;

import java.util.ArrayList;
import java.util.List;

class TraceRecord {
	protected String entityType;
	protected TraceLevelType level;
	protected String message;
	protected Long objectId;

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public TraceLevelType getLevel() {
		return level;
	}

	public void setLevel(TraceLevelType level) {
		this.level = level;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public static TraceRecord toTraceRecord(com.bpcbt.svng.mastercard.ws.mpe.trace.TraceRecord obj) {
		return toTraceRecord((Object) obj);
	}

	public static TraceRecord toTraceRecord(com.bpcbt.svng.mastercard.ws.auth.trace.TraceRecord obj) {
		return toTraceRecord((Object) obj);
	}

	public static TraceRecord toTraceRecord(com.bpcbt.svng.mastercard.ws.ipm.generate.trace.TraceRecord obj) {
		return toTraceRecord((Object) obj);
	}

	public static TraceRecord toTraceRecord(com.bpcbt.svng.mastercard.ws.ipm.load.trace.TraceRecord obj) {
		return toTraceRecord((Object) obj);
	}

	public static TraceRecord toTraceRecord(com.bpcbt.svng.mastercard.ws.ipm.save.trace.TraceRecord obj) {
		return toTraceRecord((Object) obj);
	}

	private static TraceRecord toTraceRecord(Object obj) {
		if (obj == null) {
			return null;
		}
		TraceRecord result = new TraceRecord();
		try {
			BeanUtils.copyProperties(result, obj);
		} catch (Exception e) {
			throw new RuntimeException(e.getMessage(), e);
		}
		return result;
	}

	public static List<TraceRecord> toTraceRecords(List<?> obj) {
		if (obj == null) {
			return null;
		}
		List<TraceRecord> result = new ArrayList<TraceRecord>();
		for (Object o : obj) {
			result.add(toTraceRecord(obj));
		}
		return result;
	}
}

enum TraceLevelType {

	OFF,
	FATAL,
	ERROR,
	WARN,
	INFO,
	DEBUG,
	ALL;

	public String value() {
		return name();
	}

	public static TraceLevelType fromValue(String v) {
		return valueOf(v);
	}
}