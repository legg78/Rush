package ru.bpc.sv2.process.file;

import ru.bpc.sv2.common.SQLDataRec;

import java.sql.SQLData;

import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;


public class SimpleFileRecNum extends SQLDataRec {
	private final Integer num;

	public SimpleFileRecNum(Integer num) {
		this.num = num;
	}

	@Override
	public String getSQLTypeName() throws SQLException {
		return "NUMBER";
	}
	@Override
	public void writeSQL( SQLOutput stream ) throws SQLException {
		writeValueN(stream, num);
	}
}