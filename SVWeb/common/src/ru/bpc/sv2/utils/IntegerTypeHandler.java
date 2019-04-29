package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;
import org.apache.log4j.Logger;

import java.sql.SQLException;

public class IntegerTypeHandler implements TypeHandlerCallback {
    private static final Logger logger = Logger.getLogger(IntegerTypeHandler.class);

    @Override
    public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {}

    @Override
    public Object getResult(ResultGetter getter) throws SQLException {
        Integer out = null;
        try {
            if (getter.getBigDecimal() != null) {
                out = getter.getBigDecimal().intValueExact();
            } else if (getter.getString() != null && !getter.getString().trim().isEmpty()) {
                out = Integer.valueOf(getter.getString().trim());
            } else {
                out = getter.getInt();
            }
        } catch (Exception e) {
            logger.warn("Failed to parse NUMERIC to Integer", e);
        }
        return out;
    }

    @Override
    public Object valueOf(String s) {
        return null;
    }
}
