package ru.bpc.sv2.common;

import java.math.BigDecimal;
import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import ru.bpc.sv2.utils.AuthOracleTypeNames;

public class CommonParamRec extends SQLDataRec {
	private String elementName;
	private String valueV;
	private BigDecimal valueN;
	private Date valueD;
	private String condition;

	public CommonParamRec(String elementName, Object value) {
		this.elementName = elementName;
		if (value instanceof Date) {
			valueD = (Date) value;
		} else if (value instanceof BigDecimal) {
			valueN = (BigDecimal) value;
		} else if (value instanceof Double) {
			valueN = BigDecimal.valueOf((Double) value);
		} else if (value instanceof Integer) {
			valueN = new BigDecimal((Integer) value);
		} else if (value instanceof Long) {
			valueN = BigDecimal.valueOf((Long) value);
		} else if (value instanceof Short) {
			valueN = BigDecimal.valueOf((Short) value);
		} else if (value instanceof Boolean) {
			valueN = BigDecimal.valueOf((((Boolean) value).booleanValue()) ? '1' : '0');
		} else {
			valueV = (value!=null)?value.toString():null;
		}
		this.condition = null;
	}

	public CommonParamRec(String elementName, Object value, String condition) {
		this.elementName = elementName;
		if (value instanceof Date) {
			valueD = (Date) value;
		} else if (value instanceof BigDecimal) {
			valueN = (BigDecimal) value;
		} else if (value instanceof Double) {
			valueN = BigDecimal.valueOf((Double) value);
		} else if (value instanceof Integer) {
			valueN = new BigDecimal((Integer) value);
		} else if (value instanceof Long) {
			valueN = BigDecimal.valueOf((Long) value);
		} else if (value instanceof Short) {
			valueN = BigDecimal.valueOf((Short) value);
		} else if (value instanceof Boolean) {
			valueN = BigDecimal.valueOf((((Boolean) value).booleanValue()) ? '1' : '0');
		} else {
			valueV = (String) value;
		}
		this.condition = condition;
	}

	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.COM_PARAM_MAP_REC;
	}

	public void writeSQL(SQLOutput stream) throws SQLException {
		// name 			varchar2,		1
		stream.writeString(elementName);
		// valueV			varchar2,		2
		writeValueV(stream, valueV);
		// valueN			number,			3
		writeValueN(stream, valueN);
		// valueD			date,			4
		writeValueT(stream, valueD);
		// condition		varchar2,		5
		writeValueV(stream, condition);
	}

	public String getElementName() {
		return elementName;
	}

	public String getValueV() {
		return valueV;
	}

	public BigDecimal getValueN() {
		return valueN;
	}

	public Date getValueD() {
		return valueD;
	}

	public String getCondition() {
		return condition;
	}
}