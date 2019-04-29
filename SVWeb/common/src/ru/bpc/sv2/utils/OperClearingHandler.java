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

/**
 * Created by Gasanov on 15.08.2016.
 */
public class OperClearingHandler implements TypeHandlerCallback {
    private static final Logger classLogger = Logger.getLogger(OperClearingHandler.class);

    @Override
    public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {
        List<CommonParamRec> paramsAsArray = null;
        if (parameter == null) {
            setter.setNull(OracleTypes.ARRAY, AuthOracleTypeNames.T_OPER_CLEARING_TAB);
        } else if (parameter instanceof Map<?, ?>) {
            paramsAsArray = new ArrayList<CommonParamRec>(0);
            for (String elementName : ((Map<String, Object>) parameter).keySet()) {
                paramsAsArray.add(new CommonParamRec(elementName, ((Map<String, Object>) parameter)
                        .get(elementName)));
            }

        } else if (parameter instanceof Filter[]) {
            paramsAsArray = new ArrayList<CommonParamRec>(0);
            for (Filter filter : (Filter[]) parameter) {
                CommonParamRec paramRec = new CommonParamRec(filter.getElement(),
                        filter.getValue(), filter.getConditionRealValue());
                paramsAsArray.add(paramRec);
            }
        } else if (parameter instanceof SortElement[]) {
            paramsAsArray = new ArrayList<CommonParamRec>(0);
            for (SortElement sort : (SortElement[]) parameter) {
                CommonParamRec paramRec = new CommonParamRec(sort.getProperty(),
                        sort.getDirection().toString());
                paramsAsArray.add(paramRec);
            }
        }
        if (paramsAsArray != null) {
            CommonParamRec[] paramsRecs = paramsAsArray.toArray(new CommonParamRec[paramsAsArray
                    .size()]);

            Statement stmt = setter.getPreparedStatement();
            Connection con = stmt.getConnection();
            parameter = DBUtils.createStruct(AuthOracleTypeNames.T_OPER_CLEARING_TAB, con, paramsRecs);
            setter.setObject(parameter);
        } else {
            classLogger.warn("CommonParamTypeHandler has not been used due to unspported type of passed argument \'parameter\'");
        }
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
