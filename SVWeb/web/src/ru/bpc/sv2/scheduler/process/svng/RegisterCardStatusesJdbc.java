package ru.bpc.sv2.scheduler.process.svng;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.utils.SystemException;

import java.io.StringReader;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class RegisterCardStatusesJdbc {
    private static final Logger logger = Logger.getLogger("PROCESSES");
    private static final String CARD_STATUSES_ROOT_BEGIN = "<?xml version='1.0' encoding='UTF-8'?>\n" +
                                                           "<card_statuses xmlns=\"http://sv.bpc.in/SVXP\">\n";
    private static final String CARD_STATUSES_ROOT_END = "</card_statuses>\n";
    private static final String SQL_WRITE_FILE = "{call prc_api_file_pkg.put_file(i_sess_file_id => ?" +
                                                 "                              , i_clob_content => ?)}";
    private static final String SQL_CLOSE_FILE = "{call prc_api_file_pkg.close_file(i_sess_file_id => ?" +
                                                 "                                , i_status => ?)}";
    private static final String SQL_SET_FILE_ID = "{call prc_api_file_pkg.set_session_file_id(i_sess_file_id => ?)}";

    protected Connection con = null;
    private CommonDao commonDao;
    private Map<String, Object> params;
    private List<String> cards = new ArrayList<String>();
    private Long fileSessionId;

    public RegisterCardStatusesJdbc(Map<String, Object> params, Connection con) throws SystemException, SQLException {
        this.params = params;
        this.con = con;
        init();
    }

    public void insert(List<String> rows) throws Exception {
        for(String row : rows) {
            cards.add(new String(row));
        }
    }

    public void flush() throws Exception {
        if (cards.size() >= 0) {
            execute();
        }
    }

    public void setSessionFileId(ProcessFileAttribute file) throws Exception {
        if (file != null) {
            fileSessionId = file.getSessionId();
            CallableStatement cstmt = null;
            try {
                cstmt = con.prepareCall(SQL_SET_FILE_ID);
                cstmt.setLong(1, fileSessionId);
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

    public void execute() throws Exception {
        CallableStatement statement = null;
        try {
            statement = con.prepareCall(SQL_WRITE_FILE);
            statement.setLong(1, fileSessionId);
            StringBuilder clob = new StringBuilder();
            clob.append(CARD_STATUSES_ROOT_BEGIN);
            for (String card : cards) {
                clob.append(card);
                clob.append("\n");
            }
            clob.append(CARD_STATUSES_ROOT_END);
            statement.setClob(2, new StringReader(clob.toString()));
            statement.execute();
            statement.close();

            statement = con.prepareCall(SQL_CLOSE_FILE);
            statement.setLong(1, fileSessionId);
            statement.setString(2, ProcessConstants.FILE_STATUS_ACCEPTED);
            statement.execute();
            statement.close();

            con.commit();
            cards.clear();
        } catch (Exception e) {
            logger.error(e);
            throw e;
        } finally {
            if(statement != null && !statement.isClosed()) {
                try {
                    statement.close();
                } catch (SQLException e) {
                    logger.error(e);
                }
            }
        }
    }

    public void init() throws SystemException, SQLException {
        commonDao = new CommonDao();
    }
}
