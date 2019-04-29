package ru.bpc.sv2.logic.controller;

import com.ibatis.sqlmap.client.SqlMapSession;
import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.logic.utility.db.DataAccessUtils;
import ru.bpc.sv2.logic.utility.db.IbatisAware;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class CommonController extends IbatisAware {

	public static Person getPersonById(SqlMapSession ssn, Long personId, String lang) {

		try {
			Person person = new Person();
			person.setPersonId(personId);
			person.setLang(lang);

			return (Person) ssn.queryForObject("common.get-person-by-id", person);
		} catch (SQLException e) {
			throw DataAccessUtils.createException(e);
		}
	}

	public static String getLimitationByPriv(SqlMapSession ssn, String privName) throws SQLException {
		try {
			Map<String, String> map = new HashMap<String, String>();
			map.put("limitation", null);
			map.put("privName", privName);

			ssn.update("acm.get-limitation", map);
			return map.get("limitation");
		} catch (SQLException e) {
			throw DataAccessUtils.createException(e);
		}
	}

	public static void checkFilterLimitation(SqlMapSession ssn, String privName, Filter[] filters) throws SQLException {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("priv_name", privName);
		map.put("param_tab", filters);

		ssn.update("acm.check-filter-limitation", map);
	}
}
