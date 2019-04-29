package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;
import org.apache.log4j.Logger;

import javax.xml.transform.Result;
import java.sql.ResultSet;
import java.sql.SQLException;

public class VarcharToBooleanTypeHandler implements TypeHandlerCallback {
    private static final Logger logger = Logger.getLogger(CommonParamTypeHandler.class);

    @Override
    public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {}

    @Override
    public Object getResult(ResultGetter getter) throws SQLException {
        Boolean out = null;
        try {
            if (getter.getString() != null && !getter.getString().isEmpty()) {
                return (Double.parseDouble(getter.getString()) > 0);
            } else return null;
        } catch (Exception e) {
            logger.warn("Failed to parse VARCHAR2 to Boolean", e);
        }
        return out;
    }

    @Override
    public Object valueOf(String s) {
        return null;
    }
}
