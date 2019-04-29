package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;
import oracle.jdbc.OracleTypes;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationRec;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ApplicationElementTypeHandler implements TypeHandlerCallback {

//	@SuppressWarnings("unchecked")
	public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {
		List<ApplicationRec> paramsAsArray = null;
		if (parameter == null) {
			setter.setNull(OracleTypes.ARRAY, AuthOracleTypeNames.APP_DATA_TAB);
		} else if (parameter instanceof ApplicationElement) {
			paramsAsArray = new ArrayList<ApplicationRec>(0);
			paramsAsArray.add(new ApplicationRec((ApplicationElement) parameter));

		} else if (parameter instanceof ApplicationElement[]) {
			paramsAsArray = new ArrayList<ApplicationRec>(0);

			for (ApplicationElement el : (ApplicationElement[]) parameter) {
				paramsAsArray.add(new ApplicationRec(el));
			}
		}
		if (paramsAsArray != null) {
			ApplicationRec[] paramsRecs = paramsAsArray.toArray(new ApplicationRec[paramsAsArray
					.size()]);

			Statement stmt = setter.getPreparedStatement();
			Connection con = stmt.getConnection();
			parameter = DBUtils.createArray(AuthOracleTypeNames.APP_DATA_TAB, con, paramsRecs);
			setter.setObject(parameter);
		}
	}

	public Object getResult(ResultGetter getter) throws SQLException {
		return null;
	}

	public Object valueOf(String arg0) {
		return null;
	}
}