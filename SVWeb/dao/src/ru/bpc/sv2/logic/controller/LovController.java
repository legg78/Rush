package ru.bpc.sv2.logic.controller;

import com.ibatis.sqlmap.client.SqlMapSession;
import ru.bpc.sv2.utils.KeyLabelItem;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LovController
{
	@SuppressWarnings( "unchecked" )
	public static KeyLabelItem[] getLov(SqlMapSession ssn, Integer lovId) 
	throws SQLException {
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("ref", "");
			map.put("lov_id", lovId);			
			List<KeyLabelItem> lst = ssn.queryForList("common.get-lov", map);
			return lst.toArray(new KeyLabelItem[lst.size()]);	
	}
	
	@SuppressWarnings( "unchecked" )
	public static KeyLabelItem[] getLovStyleIcon(SqlMapSession ssn, Integer lovId) 
	throws SQLException {
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("ref", "");
			map.put("lov_id", lovId);			
			List<KeyLabelItem> lst = ssn.queryForList("common.get-lov-style-icon", map);
			return lst.toArray(new KeyLabelItem[lst.size()]);	
	}
	
	@SuppressWarnings( "unchecked" )
	public static KeyLabelItem[] getArray(SqlMapSession ssn, Integer arrayId) 
	throws SQLException {
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("ref", "");
			map.put("lov_id", arrayId);			
			List<KeyLabelItem> lst = ssn.queryForList("common.get-array", map);
			lst.add(0, new KeyLabelItem());
			return lst.toArray(new KeyLabelItem[lst.size()]);	
	}
	
	public static String getLovValue(SqlMapSession ssn, Object key, Integer lovId,  Map<String, Object> params) 
	throws SQLException {
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("lov_id", lovId);
			map.put("key", key);	
			map.put("value", "");
			map.put("params", params);
			ssn.update("common.get-lov-value", map);
			String value = (String)map.get("value");
			return value;	
	}

	public static KeyLabelItem[] getLov(SqlMapSession ssn,
										Integer lovId,
										Map<String, Object> params,
										List<String> paramsWhereClause) throws SQLException, Exception {
		return getLov(ssn, lovId, params, paramsWhereClause, null);
	}
	
	@SuppressWarnings( "unchecked" )
	public static KeyLabelItem[] getLov(SqlMapSession ssn,
										Integer lovId,
										Map<String, Object> params,
										List<String> paramsWhereClause, String appearance) throws SQLException, Exception {
		String whereClause = null;
		if (paramsWhereClause != null) {
			for (String where : paramsWhereClause) {
				if (whereClause == null) {
					whereClause = where;
				} else {
					whereClause += " AND " + where;
				}
			}
		}
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("ref", "");
		map.put("lov_id", lovId);
		map.put("params", params);
		map.put("whereClause", whereClause);
		map.put("appearance", appearance);
		List<KeyLabelItem> lst = ssn.queryForList("common.get-param-lov", map);
		return lst.toArray(new KeyLabelItem[lst.size()]);
	}
	
	
}
