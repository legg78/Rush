package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;
import oracle.jdbc.OracleTypes;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.UserDataRec;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.orgstruct.Institution;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.constants.application.ApplicationConstants;

public class UserDataTypeHandler implements TypeHandlerCallback {
    private static final Logger logger = Logger.getLogger(UserDataTypeHandler.class);

    @Override
    @SuppressWarnings("unchecked")
    public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {
        List<UserDataRec> dataAsArray = null;
        if (parameter == null) {
            setter.setNull(OracleTypes.ARRAY, AuthOracleTypeNames.ACM_USER_DATA_TAB);
        } else if (parameter instanceof List<?>) {
            dataAsArray = new ArrayList<UserDataRec>(0);
            for (Object object : (List<Object>)parameter) {
                if (object instanceof Institution) {
                    Institution inst = (Institution)object;
                    UserDataRec rec = new UserDataRec(inst.getUserId(),
                                                      inst.getId().intValue(),
                                                      inst.isAssignedToUser() ? ApplicationConstants.COMMAND_CREATE_OR_PROCEED
                                                                              : ApplicationConstants.COMMAND_PROCEED_OR_REMOVE,
                                                      inst.isEntirelyForUser(),
                                                      inst.isDefaultForUser());
                    dataAsArray.add(rec);
                } else if (object instanceof Agent) {
                    Agent agent = (Agent)object;
                    UserDataRec rec = new UserDataRec(agent.getUserId(),
                                                      agent.getId(),
                                                      agent.isAssignedToUser() ? ApplicationConstants.COMMAND_CREATE_OR_PROCEED
                                                                               : ApplicationConstants.COMMAND_PROCEED_OR_REMOVE,
                                                      agent.isDefaultForUser());
                    dataAsArray.add(rec);
                }
            }
        }

        if (dataAsArray != null) {
            UserDataRec[] paramsRecs = dataAsArray.toArray(new UserDataRec[dataAsArray.size()]);
            Connection connection = setter.getPreparedStatement().getConnection();
            setter.setObject(DBUtils.createArray(AuthOracleTypeNames.ACM_USER_DATA_TAB, connection, paramsRecs));
        } else {
            logger.error("UserDataTypeHandler has not been used due to unspported type of passed argument \'parameter\'");
        }
    }

    @Override
    public Object getResult(ResultGetter resultGetter) throws SQLException {
        return null;
    }
    @Override
    public Object valueOf(String s) {
        return null;
    }
}
