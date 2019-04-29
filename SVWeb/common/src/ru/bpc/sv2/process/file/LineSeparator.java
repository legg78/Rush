package ru.bpc.sv2.process.file;

import java.sql.SQLException;
import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;

public enum LineSeparator {

	OS_DEFINED("OS-defined", System.lineSeparator()), 
	UNIX("Unix", "\n"), 
	WINDOWS("Windows", "\r\n");

	private LineSeparator(String desc, String separator) {
		this.desc = desc;
		this.separator = separator;
	}

	private final String desc;
	private final String separator;
	private static final Map<String, LineSeparator> enums = new HashMap<String, LineSeparator>();

	static {
		for (LineSeparator ls : LineSeparator.values())
			enums.put(ls.toString(), ls);
	}

	@Override
	public String toString() {
		return desc;
	}

	public String getSeparator() {
		return separator;
	}

	public static LineSeparator fromString(String name) {
		return (name != null && enums.containsKey(name)) ? enums.get(name) : OS_DEFINED;
	}

	public static class LineSeparatorTypeHandler implements TypeHandlerCallback {
		@Override
		public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {
			if (parameter == null) {
				setter.setNull(Types.VARCHAR);
			} else {
				LineSeparator ls = (LineSeparator) parameter;
				setter.setString(ls.toString());
			}
		}

		@Override
		public Object getResult(ResultGetter getter) throws SQLException {
			return LineSeparator.fromString(getter.getString());
		}

		@Override
		public Object valueOf(String s) {
			return LineSeparator.fromString(s);
		}
	}
}