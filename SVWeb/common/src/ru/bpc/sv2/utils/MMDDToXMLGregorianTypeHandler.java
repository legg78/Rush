package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;

import javax.xml.datatype.DatatypeConstants;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import java.sql.Date;
import java.sql.SQLException;
import java.util.GregorianCalendar;

public class MMDDToXMLGregorianTypeHandler extends MMDDtoDateTypeHandler implements TypeHandlerCallback {
    @Override
    public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {}

    @Override
    public Object getResult(ResultGetter getter) throws SQLException {
        XMLGregorianCalendar result = null;
        try {
            Date date = (Date)super.getResult(getter);
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
