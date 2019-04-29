package ru.bpc.sv2.utils;

import java.sql.ResultSet;

import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.HashMap;

import ru.bpc.sv2.reports.QueryResult;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;

public class ResultSetHandlerCallback implements TypeHandlerCallback {

	public QueryResult getResult(ResultGetter getter) throws SQLException {

		QueryResult data = new QueryResult();
		ResultSet rs = getter.getResultSet();
		ResultSetMetaData metaData = rs.getMetaData();
		for (int i = 1; i <= metaData.getColumnCount(); i++) {
			data.getFieldNames().add(metaData.getColumnName(i));
		}

		// do while loop is used here since in iBatis, the resultset begins at the first record
		// unlike jdbc where the cursor is positioned before the first record.
		do {
			HashMap<String, String> hm = new HashMap<String, String>();
			for (int i = 1; i <= metaData.getColumnCount(); i++) {
				hm.put(metaData.getColumnName(i), rs.getString(i));
			}
			data.getFields().add(hm);
		} while (rs.next());

		return data;
	}

	public void setParameter(ParameterSetter arg0, Object arg1) {
		// Not Used
	}

	public Object valueOf(String arg0) {
		// Not Used
		return null;
	}

}