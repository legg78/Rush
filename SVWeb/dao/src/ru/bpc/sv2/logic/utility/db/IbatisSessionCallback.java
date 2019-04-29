package ru.bpc.sv2.logic.utility.db;

import com.ibatis.sqlmap.client.SqlMapSession;

public interface IbatisSessionCallback<R> {
	R doInSession(SqlMapSession ssn) throws Exception;
}
