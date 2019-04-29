package ru.bpc.sv2.scheduler.process.svng;

import org.apache.log4j.Logger;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.utils.SystemException;

import javax.xml.bind.DatatypeConverter;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.util.Map;

public abstract class RegisterLoadJdbc {
    public static final int BATCH_SIZE = 1000;
    public static final int PARAMS_SIZE = 5;
    protected static final Logger logger = Logger.getLogger("PROCESSES");

    public static final String SQL_SET_SESSION_FILE_ID = "{call prc_api_file_pkg.set_session_file_id(" +
                                                         "      i_sess_file_id => ? )}";

    public static final String SQL_SET_USER_CONTEXT = "{ call com_ui_user_env_pkg.set_user_context( " +
                                                      "       i_user_name   => ?" +
                                                      "     , io_session_id => ?" +
                                                      "     , i_ip_address  => ? )}";

    protected Connection connect;

    public RegisterLoadJdbc(Map<String, Object> params, Connection connect) throws SystemException {
        this.connect = connect;
    }

    public void setSessionFileId(Long sessionId) throws Exception {
        if (sessionId != null) {
            CallableStatement cstmt = null;
            try {
                cstmt = connect.prepareCall(SQL_SET_SESSION_FILE_ID);
                cstmt.setLong(1, sessionId);
                cstmt.execute();
            } finally {
                DBUtils.close(cstmt);
            }
        }
    }

    public void flush() throws Exception {}

    public void execute() throws Exception {}

    protected Object getConvertedValue(Object value) {
        if (value instanceof String) {
            try {
                BigDecimal tmp = new BigDecimal((String)value);
                try {
                    return Integer.valueOf((String)value);
                } catch (Exception e) {
                    try {
                        return Long.valueOf((String)value);
                    } catch (Exception e1) {
                        return tmp;
                    }
                }
            } catch (Exception e) {
                try {
                    return DatatypeConverter.parseDateTime((String)value).getTime();
                } catch (Exception ignored) {}
            }
        }
        return value;
    }
}
