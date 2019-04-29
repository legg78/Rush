package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class JulianDateTypeHandler implements TypeHandlerCallback {
    @Override
    public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {}

    @Override
    public Object getResult(ResultGetter getter) throws SQLException {
        Date date = null;
        try {
            String julian = getter.getString();
            if (julian != null) {
                switch(julian.trim().length()) {
                    case 4:
                        Calendar calendar = Calendar.getInstance();
                        int currentYear = calendar.get(Calendar.YEAR);
                        String year = Integer.valueOf(currentYear).toString().substring(0, 3);
                        date = new SimpleDateFormat("yyyyD").parse(year + julian);
                        calendar.setTime(date);

                        if (calendar.get(Calendar.YEAR) > currentYear) {
                            while (calendar.get(Calendar.YEAR) > currentYear) {
                                calendar.set(Calendar.YEAR, calendar.get(Calendar.YEAR)-10);
                            }
                            date = calendar.getTime();
                        }
                        break;
                    case 5:
                        date = new SimpleDateFormat("yyD").parse(julian);
                        break;
                    case 7:
                        date = new SimpleDateFormat("yyyyD").parse(julian);
                        break;
                }
            }
        } catch (Exception e) {}
        return date;
    }

    @Override
    public Object valueOf(String s) {
        return null;
    }
}
