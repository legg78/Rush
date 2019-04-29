package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;
import oracle.jdbc.OracleTypes;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.common.TranslationTextRec;

import java.math.BigDecimal;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

public class TranslationTextTypeHandler implements TypeHandlerCallback {
    private static final Logger classLogger = Logger.getLogger(TranslationTextTypeHandler.class);

    @SuppressWarnings("unchecked")
	@Override
	public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {
		List <TranslationTextRec> paramsAsArray = null;
		if (parameter == null) {
			setter.setNull(OracleTypes.ARRAY, AuthOracleTypeNames.COM_TRANSLATION_TEXT_TAB);
		} else if (parameter instanceof List<?>) {
            paramsAsArray = (List<TranslationTextRec>) parameter;
		}

        if (paramsAsArray != null) {
            TranslationTextRec[] paramsRecs = paramsAsArray.toArray(new TranslationTextRec[paramsAsArray.size()]);
            Statement stmt = setter.getPreparedStatement();
            Connection con = stmt.getConnection();
            parameter = DBUtils.createArray(AuthOracleTypeNames.COM_TRANSLATION_TEXT_TAB, con, paramsRecs);
            setter.setObject(parameter);
        } else {
            classLogger.warn("TranslationTextTypeHandler has not been used due to unspported type of passed argument \'parameter\'");
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
