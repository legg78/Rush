package ru.bpc.sv2.utils;

import java.sql.Date;
import java.sql.SQLException;
import java.util.GregorianCalendar;

import javax.xml.datatype.DatatypeConstants;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;

public class SQLDateToXMLGregorianTypeHandler implements TypeHandlerCallback{

	@Override
	public void setParameter(ParameterSetter setter, Object parameter)
			throws SQLException {
	}

	@Override
	public Object getResult(ResultGetter getter) throws SQLException {
		XMLGregorianCalendar result=null;
		
		try {
			Date date=getter.getDate();
			GregorianCalendar c = new GregorianCalendar();
			c.setTime(date);
			result = DatatypeFactory.newInstance().newXMLGregorianCalendar(c);
			result.setTimezone(DatatypeConstants.FIELD_UNDEFINED);
		} catch (Exception e) {
		}
		return result;
	}

	@Override
	public Object valueOf(String s) {
		return null;
	}

}
