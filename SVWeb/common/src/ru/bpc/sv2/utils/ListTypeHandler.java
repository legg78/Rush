package ru.bpc.sv2.utils;

import java.math.BigDecimal;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import oracle.jdbc.OracleTypes;
import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;

public class ListTypeHandler implements TypeHandlerCallback{
	@SuppressWarnings("unchecked")
	@Override
	public void setParameter(ParameterSetter setter, Object parameter)
			throws SQLException {
		List <Integer> paramsAsArray = null;
		List <Object> paramsObjAsArray = null;
        Boolean isLongArray = false;
		if (parameter == null) {
			setter.setNull(OracleTypes.ARRAY, AuthOracleTypeNames.PRC_SESSION_FILE_RECNUM_TAB);
		} else if (parameter instanceof Integer){
			paramsAsArray = new ArrayList<Integer>(1);
			paramsAsArray.add((Integer)parameter);
		} else if (parameter instanceof Integer[]){
			paramsAsArray = new ArrayList<Integer>(((Integer[])parameter).length);
			Collections.addAll(paramsAsArray, (Integer[]) parameter);
		}else if (parameter instanceof Long[] || parameter instanceof BigDecimal[]) {
            isLongArray = true;

        }else if (parameter instanceof List<?>){
			paramsAsArray = new ArrayList<Integer>();
			paramsAsArray.addAll((List<Integer>)parameter);
		} else if (parameter instanceof Object[]){
			paramsObjAsArray = new ArrayList<Object>(((Object[])parameter).length);
			Collections.addAll(paramsObjAsArray, (Object[]) parameter);
		}

        if(isLongArray) {
            Statement stmt = setter.getPreparedStatement();
            Connection con = stmt.getConnection();
            parameter = DBUtils.createArray(AuthOracleTypeNames.PRC_SESSION_FILE_RECNUM_TAB, con, (Object[]) parameter);
            setter.setObject(parameter);

        }else if (paramsAsArray != null) {
			Integer[] paramsRecs = paramsAsArray.toArray(new Integer[paramsAsArray
			                                                   					.size()]);
			Statement stmt = setter.getPreparedStatement();
			Connection con = stmt.getConnection();
			parameter = DBUtils.createArray(AuthOracleTypeNames.PRC_SESSION_FILE_RECNUM_TAB, con, paramsRecs);
			setter.setObject(parameter);
		} else if (paramsObjAsArray != null) {
			String[] paramsRecs = paramsObjAsArray.toArray(new String[paramsObjAsArray.size()]);
			Statement stmt = setter.getPreparedStatement();
			Connection con = stmt.getConnection();
			parameter = DBUtils.createArray(AuthOracleTypeNames.DICT_TAB_TPT, con, paramsRecs);
			setter.setObject(parameter);
		}
	}

	@Override
	public Object getResult(ResultGetter getter) throws SQLException {
		Array a = getter.getArray();
		if (a != null) {
			return a.getArray();
		}
		else {
			return null;
		}
	}

	@Override
	public Object valueOf(String s) {
		return null;
	}

}
