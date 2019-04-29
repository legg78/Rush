package ru.bpc.sv2.process.file;

import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;

import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;


public class SimpleFileRec extends SQLDataRec {
	private final String str;

	public SimpleFileRec(String str) {
		this.str = str;
	}

	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.PRC_SESSION_FILE_RAW_REC;
	}

	@Override
	public void writeSQL(SQLOutput stream) throws SQLException {
		writeValueV(stream, str);
	}

	@Override
	public String toString() {
		try {
			return getSQLTypeName() + ": " + str;
		} catch (SQLException ignored) {
		}
		return super.toString();
	}
}