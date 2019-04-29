package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.constants.schedule.PosBatchSqlRequests;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.operations.OperationPrivConstants;
import ru.bpc.sv2.operations.PosBatch;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.UserException;


import java.sql.*;
import java.util.List;
import java.util.Map;

@SuppressWarnings ("unchecked")
public class PosBatchDao extends IbatisAware {
    private static final Logger logger = Logger.getLogger("PROCESSES");

    private Long getNewId(PreparedStatement statement) throws SQLException {
        statement.execute();
        ResultSet set = statement.getResultSet();
        set.next();
        Long id = set.getLong(1);
        set.close();
        statement.close();
        return id;
    }

    private void apply(PreparedStatement statement, Connection connect) throws SQLException {
        statement.execute();
        statement.close();
        connect.commit();
    }


    public Long insertFile(Connection connect, Map<String, Object> params) throws UserException {
        Long id = null;
        try {
            PreparedStatement statement = connect.prepareStatement(PosBatchSqlRequests.FILE_SEQ);
            id = getNewId(statement);

            statement = connect.prepareStatement(PosBatchSqlRequests.FILE_INSERT);
            statement.setString(1, id.toString());
            statement.setString(2, params.get("session_id").toString());
            statement.setString(3, params.get("proc_date").toString());
            statement.setString(4, params.get("file_type").toString());
            statement.setString(5, params.get("header_record_type").toString());
            statement.setString(6, params.get("header_record_number").toString());
            statement.setString(7, params.get("inst_id").toString());
            statement.setString(8, params.get("creation_date").toString());
            statement.setString(9, params.get("creation_time").toString());
            statement.setString(10, params.get("batch_version").toString());

            apply(statement, connect);
        } catch (SQLException e) {
            logger.debug(e.getCause().getMessage(), e);
            throw new UserException(e.getCause().getMessage(), e);
        }
        return id;
    }


    public void updateFile(Connection connect, Map<String, Object> params) throws UserException {
        try {
            PreparedStatement statement = connect.prepareStatement(PosBatchSqlRequests.FILE_UPDATE);

            statement.setString(1, params.get("trailer_record_type").toString());
            statement.setString(2, params.get("trailer_record_number").toString());
            statement.setString(3, params.get("total_batch_number").toString());
            statement.setString(4, params.get("id").toString());

            apply(statement, connect);
        } catch (SQLException e) {
            logger.debug(e.getCause().getMessage(), e);
            throw new UserException(e.getCause().getMessage(), e);
        }
    }


    public Long insertBlock(Connection connect, Map<String, Object> params) throws UserException {
        Long id = null;
        try {
            PreparedStatement statement = connect.prepareStatement(PosBatchSqlRequests.BLOCK_SEQ);
            id = getNewId(statement);

            statement = connect.prepareStatement(PosBatchSqlRequests.BLOCK_INSERT);
            statement.setString(1, id.toString());
            statement.setString(2, params.get("batch_file_id").toString());
            statement.setString(3, params.get("header_record_type").toString());
            statement.setString(4, params.get("header_record_number").toString());
            statement.setString(5, params.get("header_batch_reference").toString());
            statement.setString(6, params.get("creation_date").toString());
            statement.setString(7, params.get("creation_time").toString());
            statement.setString(8, params.get("header_batch_amount").toString());
            statement.setString(9, params.get("header_debit_credit").toString());
            statement.setString(10, params.get("header_merchant_id").toString());
            statement.setString(11, params.get("header_terminal_id").toString());
            statement.setString(12, params.get("mcc").toString());

            apply(statement, connect);
        } catch (SQLException e) {
            logger.debug(e.getCause().getMessage(), e);
            throw new UserException(e.getCause().getMessage(), e);
        }
        return id;
    }


    public void updateBlock(Connection connect, Map<String, Object> params) throws UserException {
        try {
            PreparedStatement statement = connect.prepareStatement(PosBatchSqlRequests.BLOCK_UPDATE);
            statement.setString(1, params.get("trailer_record_type").toString());
            statement.setString(2, params.get("trailer_record_number").toString());
            statement.setString(3, params.get("trailer_batch_reference").toString());
            statement.setString(4, params.get("trailer_merchant_id").toString());
            statement.setString(5, params.get("trailer_terminal_id").toString());
            statement.setString(6, params.get("trailer_batch_amount").toString());
            statement.setString(7, params.get("trailer_debit_credit").toString());
            statement.setString(8, params.get("number_records").toString());
            statement.setString(9, params.get("id").toString());

            apply(statement, connect);
        } catch (SQLException e) {
            logger.debug(e.getCause().getMessage(), e);
            throw new UserException(e.getCause().getMessage(), e);
        }
    }


    public void insertDetail(Connection connect, List<Map<String, Object>> lines) throws UserException {
        try {
            CallableStatement seq = connect.prepareCall(PosBatchSqlRequests.GET_ID_BEGIN +
                                                        lines.size() +
                                                        PosBatchSqlRequests.GET_ID_END );
            seq.registerOutParameter(1, Types.NUMERIC);
            seq.execute();
            Long id = (Long)seq.getLong(1) - lines.size();
            seq.close();
            PreparedStatement statement = connect.prepareStatement(PosBatchSqlRequests.DETAIL_INSERT);
            for (Map<String, Object> params : lines) {
                statement.setString(1, (++id).toString());
                statement.setString(2, params.get("batch_block_id").toString());
                statement.setString(3, params.get("record_type").toString());
                statement.setString(4, params.get("record_number").toString());
                statement.setString(5, params.get("voucher_number").toString());
                statement.setString(6, params.get("card_number").toString());
                statement.setString(7, params.get("card_member_number").toString());
                statement.setString(8, params.get("card_expir_date").toString());
                statement.setString(9, params.get("trans_amount").toString());
                statement.setString(10, params.get("trans_currency").toString());
                statement.setString(11, params.get("debit_credit").toString());
                statement.setString(12, params.get("trans_date").toString());
                statement.setString(13, params.get("trans_time").toString());
                statement.setString(14, params.get("auth_code").toString());
                statement.setString(15, params.get("trans_type").toString());
                statement.setString(16, params.get("utrnno").toString());
                statement.setString(17, params.get("is_reversal").toString());
                statement.setString(18, params.get("auth_utrnno").toString());
                statement.setString(19, params.get("pos_data_code").toString());
                statement.setString(20, params.get("retrieval_reference_number").toString());
                statement.setString(21, params.get("trace_number").toString());
                statement.setString(22, params.get("network_id").toString());
                statement.setString(23, params.get("acq_inst_id").toString());
                statement.setString(24, params.get("trans_status").toString());
                statement.setString(25, params.get("add_data").toString());
                statement.setString(26, params.get("emv_data").toString());
                statement.setString(27, params.get("service_id").toString());
                if (params.get("payment_details") != null) {
                    statement.setString(28, params.get("payment_details").toString());
                    statement.setString(29, params.get("service_provider_id").toString());
                    statement.setString(30, params.get("unique_number_payment").toString());
                    statement.setString(31, params.get("add_amounts").toString());
                    statement.setString(32, params.get("svfe_trace_number").toString());
                } else {
                    statement.setString(28, "");
                    statement.setString(29, "");
                    statement.setString(30, "");
                    statement.setString(31, "");
                    statement.setString(32, "");
                }
                statement.addBatch();
            }
            statement.executeBatch();
            statement.close();
            connect.commit();
        } catch (SQLException e) {
            logger.debug(e.getCause().getMessage(), e);
            throw new UserException(e.getCause().getMessage(), e);
        }
    }

    @SuppressWarnings("unchecked")
    public PosBatch[] getPosBatches(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_POS_BATCH, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, OperationPrivConstants.VIEW_POS_BATCH);
            List<PosBatch> posBatches = ssn.queryForList("operations.get-pos-batches", convertQueryParams(
                    params, limitation));
            return posBatches.toArray(new PosBatch[posBatches.size()]);
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }
}
