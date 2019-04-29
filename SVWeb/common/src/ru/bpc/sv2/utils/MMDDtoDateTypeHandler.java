package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;

import javax.xml.datatype.DatatypeConstants;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import java.util.Date;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.GregorianCalendar;

public class MMDDtoDateTypeHandler implements TypeHandlerCallback {
    @Override
    public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {}

    @Override
    public Object getResult(ResultGetter getter) throws SQLException {
        Date date = null;
        try {
            String mmdd = getter.getString();
            if (mmdd != null && mmdd.trim().length() >= 4) {
                Calendar calendar = Calendar.getInstance();
                Integer month = Integer.valueOf(mmdd.substring(0, 2)) - 1;
                calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(mmdd.substring(2)));
                if (month.intValue() > calendar.get(Calendar.MONTH)) {
                    calendar.set(Calendar.YEAR, calendar.get(Calendar.YEAR) - 1);
                }
                calendar.set(Calendar.MONTH, month);
                date = calendar.getTime();
            }
        } catch (Exception e) {}
        return date;
    }

    @Override
    public Object valueOf(String s) {
        return null;
    }
}
