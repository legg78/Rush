package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;

import java.sql.SQLException;

/**
 * Created by Gasanov on 17.10.2016.
 */
public class ApplicationEntityDataHandler implements TypeHandlerCallback {
    @Override
    public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {

    }

    @Override
    public Object getResult(ResultGetter getter) throws SQLException {
        return null;
    }

    @Override
    public Object valueOf(String s) {
        return null;
    }
}
