package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;
import oracle.jdbc.OracleTypes;
import org.apache.log4j.Logger;
import ru.bpc.sv2.svng.AuthData;
import ru.bpc.sv2.svng.AuthDataRec;

import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AuthDataTypeHandler implements TypeHandlerCallback {
	private static final Logger classLogger = Logger.getLogger(AuthDataTypeHandler.class);

	@SuppressWarnings("unchecked")
	@Override
	public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {
		List<AuthDataRec> paramsAsArray = null;
		Statement stmt = setter.getPreparedStatement();
		Connection con = stmt.getConnection();

		if (parameter == null) {
			setter.setNull(OracleTypes.ARRAY, AuthOracleTypeNames.AUTH_DATA_TAB);
		} else if (parameter instanceof List) {
			paramsAsArray = new ArrayList<>();
			for(AuthData data: (List<AuthData>) parameter) {
				paramsAsArray.add(new AuthDataRec(data, con));
			}
		}

		if (paramsAsArray != null) {
			AuthDataRec[] paramsRecs = paramsAsArray.toArray(new AuthDataRec[paramsAsArray.size()]);
			parameter = DBUtils.createArray(AuthOracleTypeNames.AUTH_DATA_TAB, con, paramsRecs);
			setter.setObject(parameter);
		} else {
			classLogger.warn("AuthDataTypeHandler has not been used due to unspported type of passed argument \'parameter\'");
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
