package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;
import oracle.jdbc.OracleTypes;
import org.apache.log4j.Logger;
import ru.bpc.sv2.svng.AuthTag;
import ru.bpc.sv2.svng.AuthTagRec;

import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AuthTagTypeHandler implements TypeHandlerCallback {
	private static final Logger classLogger = Logger.getLogger(AuthTagTypeHandler.class);

	@SuppressWarnings("unchecked")
	@Override
	public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {
		List<AuthTagRec> paramsAsArray = null;
		Statement stmt = setter.getPreparedStatement();
		Connection con = stmt.getConnection();

		if (parameter == null) {
			setter.setNull(OracleTypes.ARRAY, AuthOracleTypeNames.AUTH_TAG_TAB);
		} else if (parameter instanceof List) {
			paramsAsArray = new ArrayList<>();
			for(AuthTag tag: (List<AuthTag>) parameter) {
				paramsAsArray.add(new AuthTagRec(tag, con));
			}
		}

		if (paramsAsArray != null) {
			AuthTagRec[] paramsRecs = paramsAsArray.toArray(new AuthTagRec[paramsAsArray.size()]);
			parameter = DBUtils.createArray(AuthOracleTypeNames.AUTH_TAG_TAB, con, paramsRecs);
			setter.setObject(parameter);
		} else {
			classLogger.warn("AuthTagTypeHandler has not been used due to unspported type of passed argument \'parameter\'");
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
