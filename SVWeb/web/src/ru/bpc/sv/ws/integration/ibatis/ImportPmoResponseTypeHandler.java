package ru.bpc.sv.ws.integration.ibatis;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;
import oracle.jdbc.OracleTypes;
import org.apache.log4j.Logger;
import ru.bpc.sv.svxp.pmo.ImportOrderResponse;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ImportPmoResponseTypeHandler implements TypeHandlerCallback {
    private static final Logger classLogger = Logger.getLogger(ImportPmoResponseTypeHandler.class);

    @SuppressWarnings("unchecked")
	@Override
	public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {
		List<ImportPmoResponseRec> paramsAsArray = null;
		if (parameter == null) {
			setter.setNull(OracleTypes.ARRAY, AuthOracleTypeNames.PMO_RESPONSE_TAB);
			return;
		}

		if (parameter instanceof List<?>) {
            paramsAsArray = convertOrderResponseToRec((List<ImportOrderResponse>) parameter);
		}

        if (paramsAsArray != null) {
	        ImportPmoResponseRec[] paramsRecs = paramsAsArray.toArray(new ImportPmoResponseRec[paramsAsArray.size()]);
            Statement stmt = setter.getPreparedStatement();
            Connection con = stmt.getConnection();
            parameter = DBUtils.createArray(AuthOracleTypeNames.PMO_RESPONSE_TAB, con, paramsRecs);
            setter.setObject(parameter);
        } else {
            classLogger.warn("TranslationTextTypeHandler has not been used due to unspported type of passed argument \'parameter\'");
        }
	}

	private List<ImportPmoResponseRec> convertOrderResponseToRec(List<ImportOrderResponse> list) {
		List<ImportPmoResponseRec> result = new ArrayList<ImportPmoResponseRec>();
		for(ImportOrderResponse order: list) {
			result.add(ImportPmoResponseRec.createByOrderResponse(order));
	    }
	    return result;
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
