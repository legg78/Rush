package ru.bpc.sv2.invocation;

import java.util.Map;

public interface IAuditableObject {
	String AUDIT_PARAM_OBJECT_ID = "_object_id";
	String AUDIT_PARAM_ENTITY_TYPE = "_entity_type";

	Map<String, Object> getAuditParameters();
}
