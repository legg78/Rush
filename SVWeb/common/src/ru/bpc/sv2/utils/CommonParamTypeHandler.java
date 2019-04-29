package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;
import oracle.jdbc.OracleTypes;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SortElement;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class CommonParamTypeHandler implements TypeHandlerCallback {

	private static final Logger classLogger = Logger.getLogger(CommonParamTypeHandler.class);
	
	@SuppressWarnings("unchecked")
	public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {
		List<CommonParamRec> paramsAsArray = null;
		if (parameter == null) {
			setter.setNull(OracleTypes.ARRAY, AuthOracleTypeNames.COM_PARAM_MAP_TAB);
		} else if (parameter instanceof Map<?, ?>) {
			paramsAsArray = new ArrayList<CommonParamRec>(0);
			for (String elementName : ((Map<String, Object>) parameter).keySet()) {
				paramsAsArray.add(new CommonParamRec(elementName, ((Map<String, Object>) parameter).get(elementName)));
			}
		} else if (parameter instanceof Filter[]) {
			paramsAsArray = new ArrayList<CommonParamRec>(0);
			for (Filter filter : (Filter[]) parameter) {
				CommonParamRec paramRec = new CommonParamRec(filter.getElement(), filter.getValue(), filter.getConditionRealValue());
				paramsAsArray.add(paramRec);
			}
		} else if (parameter instanceof SortElement[]) {
			paramsAsArray = new ArrayList<CommonParamRec>(0);
			for (SortElement sort : (SortElement[]) parameter) {
				CommonParamRec paramRec = new CommonParamRec(sort.getProperty(), sort.getDirection().toString());
				paramsAsArray.add(paramRec);
			}
		} else if (parameter instanceof List<?>) {
			paramsAsArray = new ArrayList<CommonParamRec>(0);
			for (Object object : (List<Object>)parameter) {
				if (object instanceof Filter) {
					CommonParamRec paramRec = new CommonParamRec(((Filter)object).getElement(),
																 ((Filter)object).getValue(),
																 ((Filter)object).getConditionRealValue());
					paramsAsArray.add(paramRec);
				} else if (object instanceof SortElement) {
					CommonParamRec paramRec = new CommonParamRec(((SortElement)object).getProperty(),
																 ((SortElement)object).getDirection().toString());
					paramsAsArray.add(paramRec);
				}
			}
		}
		if (paramsAsArray != null) {
			CommonParamRec[] paramsRecs = paramsAsArray.toArray(new CommonParamRec[paramsAsArray.size()]);
			Statement stmt = setter.getPreparedStatement();
			Connection con = stmt.getConnection();
			parameter = DBUtils.createArray(AuthOracleTypeNames.COM_PARAM_MAP_TAB, con, paramsRecs);
			setter.setObject(parameter);
		} else {
			classLogger.warn("CommonParamTypeHandler has not been used due to unspported type of passed argument \'parameter\'");
		}
	}

	public Object getResult(ResultGetter getter) throws SQLException {
		return null;
	}

	public Object valueOf(String arg0) {
		return null;
	}
}