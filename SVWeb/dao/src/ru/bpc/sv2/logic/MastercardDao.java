package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.utils.AuditParamUtil;

import java.io.Serializable;
import java.sql.SQLException;
import org.apache.log4j.Logger;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.ps.mastercard.*;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.util.ArrayList;
import java.util.List;

import static ru.bpc.sv2.ps.mastercard.MasterPrivConstants.*;

public class MastercardDao extends AbstractDao {
    private static final Logger logger = Logger.getLogger("MCW");
    private static final String sqlMap = "mastercard";

    @Override
    protected Logger getLogger() {
        return logger;
    }
    @Override
    protected String getSqlMap() {
        return sqlMap;
    }

    public List<MasterFinMessage> getFinancialMessages(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_MASTER_FIN_MESSAGES, "get-mastercard-fin-messages");
    }

    public int getFinancialMessagesCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, VIEW_MASTER_FIN_MESSAGES, "get-mastercard-fin-messages-count");
    }

    public List<MasterFinMessageAddendum> getMasterFinMessageAddendum(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_MASTER_FIN_MESSAGES, "get-mastercard-fin-messages-addendum");
    }

    public int getMasterFinMessageAddendumCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, VIEW_MASTER_FIN_MESSAGES, "get-mastercard-fin-messages-addendum-count");
    }

    public List<McwReject> getMcwRejects(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, "get-mcw-rejects");
    }

    public int getMcwRejectsCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, "get-mcw-rejects-count");
    }

    public List<McwRejectCode> getMcwRejectCodes(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, "get-mcw-reject-codes");
    }

    public int getMcwRejectCodesCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, "get-mcw-reject-codes-count");
    }

    public MasterFinMessage modifyFinMessage(Long userSessionId, MasterFinMessage message) {
        MasterFinMessage tmp = update(userSessionId, message, VIEW_MASTER_FIN_MESSAGES, "modify-fin-message");
        List<Filter> filters = new ArrayList<Filter>(2);
        filters.add(Filter.create("id", tmp.getId()));
        filters.add(Filter.create("lang", tmp.getLang()));
        SelectionParams params = new SelectionParams(filters);
        Object out = getObjects(userSessionId, params, VIEW_MASTER_FIN_MESSAGES, "get-mastercard-fin-messages");
        return (out != null) ? (((List<MasterFinMessage>)out).size() > 0) ? ((List<MasterFinMessage>)out).get(0) : message : message;
    }

    public List<MasterFile> getFiles(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_MASTERCARD_FILES, "get-mastercard-files");
    }

    public int getFilesCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, VIEW_MASTERCARD_FILES, "get-mastercard-files-count");
    }

    public List<MasterFinMessage> getMasterFileFinMessages(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_MASTER_FIN_MESSAGES, "get-mastercard-fin-messages");
    }

    public int getMasterFileFinMessagesCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, VIEW_MASTER_FIN_MESSAGES, "get-mastercard-fin-messages-count");
    }

    public List<AbuFile> getAbuFiles(Long userSessionId, final SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_MC_ABU_FILES, "get-mc-abu-files");
    }

    public int getAbuFilesCount(Long userSessionId, final SelectionParams params) {
        return getCount(userSessionId, params, VIEW_MC_ABU_FILES, "get-mc-abu-files-count");
    }

    public List<AbuFileMessage> getAbuFileMessages(Long userSessionId, final SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_MC_ABU_FILES, "get-mc-abu-file-messages");
    }

    public int getAbuFileMessagesCount(Long userSessionId, final SelectionParams params) {
        return getCount(userSessionId, params, VIEW_MC_ABU_FILES, "get-mc-abu-file-messages-count");
    }

    public List<AbuAcqMessage> getAbuAcqMessages(Long userSessionId, final SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_MC_ABU_ACQ_MESSAGES, "get-mc-abu-acq-messages");
    }

    public int getAbuAcqMessagesCount(Long userSessionId, final SelectionParams params) {
        return getCount(userSessionId, params, VIEW_MC_ABU_ACQ_MESSAGES, "get-mc-abu-acq-messages-count");
    }

    public List<AbuIssMessage> getAbuIssMessages(Long userSessionId, final SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_MC_ABU_ISS_MESSAGES, "get-mc-abu-iss-messages");
    }

    public int getAbuIssMessagesCount(Long userSessionId, final SelectionParams params) {
        return getCount(userSessionId, params, VIEW_MC_ABU_ISS_MESSAGES, "get-mc-abu-iss-messages-count");
    }
}
