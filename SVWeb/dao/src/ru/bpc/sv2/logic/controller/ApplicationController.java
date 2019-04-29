package ru.bpc.sv2.logic.controller;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.application.ApplicationElement;

import com.ibatis.sqlmap.client.SqlMapSession;

public class ApplicationController {
	
	public static Long getNextDataId(SqlMapSession ssn, Long applicationId)
	throws SQLException {
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("appId", applicationId);
		ssn.queryForObject("application.get-next-appl-data-id", params);				
		return Long.parseLong(params.get("dataId").toString());
	}
	
	public static Integer getStructureElement(SqlMapSession ssn, ApplicationElement el)
	throws SQLException {
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("elementId", el.getId());
		params.put("parentId", el.getParentId());
		Integer structId = (Integer)ssn.queryForObject("application.get-structure-id", params);				
		return structId;
	}
	
}
