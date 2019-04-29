package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.reconciliation.export.atm.ReconciliationATM;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.SystemException;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class RegisterReconciliationATMJdbc {
    public static final int BATCH_SIZE = 1000;
    public static final int PARAMS_SIZE = 5;

    private static final Logger logger = Logger.getLogger(RegisterReconciliationATMJdbc.class);

    private static final String SQL_REGISTER_OPERATION = "{call rcn_prc_import_pkg.process_atm_batch(" +
                                                        "      i_oper_tab   => ? " +
                                                        "    , i_param_tab  => ? )}";

    private static final String SQL_SET_SESSION_FILE_ID = "{call prc_api_file_pkg.set_session_file_id(" +
                                                         "      i_sess_file_id => ? )}";

    public static final String SQL_SET_USER_CONTEXT = "{ call com_ui_user_env_pkg.set_user_context( " +
            "       i_user_name   => ?" +
            "     , io_session_id => ?" +
            "     , i_ip_address  => ? )}";


    private List<ReconciliationATMRec> operations;
    private List<CommonParamRec> options;
    protected Connection con;

    public RegisterReconciliationATMJdbc(Map<String, Object> params, Connection con) throws SystemException, SQLException {
        this.con = con;
        operations = new ArrayList<>();
        options = new ArrayList<>();
    }

    public void insert(ReconciliationATM reconciliation) throws Exception {
        if (null != reconciliation)
            operations.add(new ReconciliationATMRec(reconciliation, con));

        if (operations.size() >= BATCH_SIZE) {
            execute();
        }
    }

    public void setSessionFileId(Long sessionId) throws Exception {
        if (sessionId != null) {
            CallableStatement cstmt = null;
            try {
                cstmt = con.prepareCall(SQL_SET_SESSION_FILE_ID);
                cstmt.setLong(1, sessionId);
                cstmt.execute();
            } catch (Exception e) {
                logger.error(e);
                throw e;
            } finally {
                if(cstmt != null) {
                    try {
                        cstmt.close();
                    } catch (SQLException e) {
                        logger.error(e);
                    }
                }
            }
        }
    }

    public void flush() throws Exception {
        execute();
    }

    public void execute() throws Exception {
        CallableStatement cstmt = null;
        try {
            ArrayDescriptor oper_tab = ArrayDescriptor.createDescriptor(AuthOracleTypeNames.RCN_ATM_RECON_MSG_TAB, con);
            ArrayDescriptor param_tab = ArrayDescriptor.createDescriptor(AuthOracleTypeNames.COM_PARAM_MAP_TAB, con);

            cstmt = con.prepareCall(SQL_REGISTER_OPERATION);
            cstmt.setArray(1, new ARRAY(oper_tab, con, getReconciliationATMArray()));
            cstmt.setObject(2, new ARRAY(param_tab, con, getParamsRecs()));
            cstmt.execute();

            operations.clear();
        } catch (Exception e) {
            logger.error(e);
            throw e;
        } finally {
            if(cstmt != null) {
                try {
                    cstmt.close();
                } catch (SQLException e) {
                    logger.error(e);
                }
            }
        }
    }

    private ReconciliationATMRec[] getReconciliationATMArray() {
        return operations.toArray(new ReconciliationATMRec[operations.size()]);
    }

    private CommonParamRec[] getParamsRecs() {
        return options.toArray(new CommonParamRec[options.size()]);
    }

}
