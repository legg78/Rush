package ru.bpc.sv2.scheduler.process.svng;

import oracle.jdbc.internal.OracleTypes;
import oracle.sql.ARRAY;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.svng.AuthDataRec;
import ru.bpc.sv2.svng.AuthTag;
import ru.bpc.sv2.svng.AuthTagRec;
import ru.bpc.sv2.svng.ClearingOperation;
import ru.bpc.sv2.svng.OperClearingRec;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.utils.SystemException;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

/**
 * Created by Gasanov on 22.08.2016.
 */
public class RegisterOperationJdbc {
    private static final Logger logger = Logger.getLogger("PROCESSES");

    private static final String SQL_REG_OPERATION_IMPORT_CLEAR_PAN = "I_IMPORT_CLEAR_PAN";
	private static final String SQL_REG_OPERATION_OPER_STATUS = "I_OPER_STATUS";
	private static final String SQL_REG_OPERATION_STTL_DATE = "I_STTL_DATE";
	private static final String SQL_REG_OPERATION_WITHOUT_CHECKS = "I_WITHOUT_CHECKS";
	private static final String SQL_REG_OPERATION_INST_ID = "I_INST_ID";

    private static final String SQL_REGISTER_OPERATION = "{call itf_prc_import_pkg.register_operation_batch(" +
                                                         "    i_oper_tab          => ? " +
														 "  , i_auth_data_tab     => ? " +
														 "  , i_auth_tag_tab      => ? " +
                                                         "  , i_import_clear_pan  => ? " +
                                                         "  , i_oper_status       => ? " +
                                                         "  , i_sttl_date         => ? " +
                                                         "  , i_without_checks    => ? " +
		                                                 "  , i_inst_id           => ?)}";

    private static final String SQL_SET_SESSION_FILE_ID = "{call prc_api_file_pkg.set_session_file_id(" +
                                                          "    i_sess_file_id => ? )}";

    protected Connection con = null;
    private CommonDao commonDao;
    private Map<String, Object> params;
    private List<OperClearingRec> rawsAsArray = new ArrayList<OperClearingRec>();
	private List<AuthDataRec> authDataArray = new ArrayList<>();
 	private List<AuthTagRec> authTagArray = new ArrayList<>();
    private static final int NUM_IN_BATCH = 1000;
    private Map<Integer, java.sql.Date> sttlDateMap = new HashMap<Integer, java.sql.Date>();

    public RegisterOperationJdbc(Map<String, Object> params, Connection con) throws SystemException, SQLException {
        this.params = params;
        this.con = con;
        init();
    }

    public void insert(List<ClearingOperation> rows) throws Exception {
        for(ClearingOperation row : rows) {
            rawsAsArray.add(new OperClearingRec(row, con));
			if (row.getAuthDataObject() != null) {
				authDataArray.add(new AuthDataRec(row.getAuthDataObject(), con));
				if (row.getAuthDataObject().getAuthTags() != null) {
					for (AuthTag tag : row.getAuthDataObject().getAuthTags()) {
						authTagArray.add(new AuthTagRec(tag, con));
					}
				}
			}
        }
        if (rawsAsArray.size() >= NUM_IN_BATCH) {
            execute();
        }
    }

    public void flush() throws Exception {
        execute();
    }

    public void setSessionFileId(ProcessFileAttribute file) throws Exception {
        if (file != null) {
            CallableStatement cstmt = null;
            try {
                cstmt = con.prepareCall(SQL_SET_SESSION_FILE_ID);
                cstmt.setLong(1, file.getSessionId());
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
        CallableStatement cstmt = null;
        try {
            cstmt = con.prepareCall(SQL_REGISTER_OPERATION);

	        BigDecimal instId = (BigDecimal) params.get(SQL_REG_OPERATION_INST_ID);
            BigDecimal importClearPan = (BigDecimal) params.get(SQL_REG_OPERATION_IMPORT_CLEAR_PAN);
            String operStatus = (String) params.get(SQL_REG_OPERATION_OPER_STATUS);
            java.sql.Date sttlDate = getSttlDate(instId == null ? SystemConstants.DEFAULT_INSTITUTION : instId.intValue());
            BigDecimal withoutChecks = (BigDecimal) params.get(SQL_REG_OPERATION_WITHOUT_CHECKS);

			cstmt.setArray(1, DBUtils.createArray(AuthOracleTypeNames.T_OPER_CLEARING_TAB, con, rawsAsArray.toArray(new OperClearingRec[rawsAsArray.size()])));
			cstmt.setArray(2, DBUtils.createArray(AuthOracleTypeNames.AUTH_DATA_TAB, con, authDataArray.toArray(new AuthDataRec[authDataArray.size()])));
			cstmt.setArray(3, DBUtils.createArray(AuthOracleTypeNames.AUTH_TAG_TAB, con, authTagArray.toArray(new AuthTagRec[authTagArray.size()])));

            if(importClearPan != null) {
                cstmt.setInt(4, importClearPan.intValue());
            } else {
                cstmt.setObject(4, null, OracleTypes.INTEGER);
            }
            if(operStatus != null) {
                cstmt.setString(5, operStatus);
            } else {
                cstmt.setObject(5, null, OracleTypes.VARCHAR);
            }

            cstmt.setDate(6, sttlDate);

	        if(withoutChecks != null) {
		        cstmt.setInt(7, withoutChecks.intValue());
	        } else {
		        cstmt.setObject(7, null, OracleTypes.INTEGER);
	        }

	        if(instId != null) {
		        cstmt.setInt(8, instId.intValue());
	        } else {
		        cstmt.setObject(8, null, OracleTypes.INTEGER);
	        }

            cstmt.execute();
            rawsAsArray.clear();
			authDataArray.clear();
   			authTagArray.clear();
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

    public void init() {
        commonDao = new CommonDao();
    }

    private java.sql.Date getSttlDate(Integer instId){
        if(sttlDateMap.containsKey(instId)){
            return sttlDateMap.get(instId);
        }

	    Date date = (Date) params.get(SQL_REG_OPERATION_STTL_DATE);
	    if (date == null) {
		    SettingsCache settingParamsCache = SettingsCache.getInstance();

		    if (SystemConstants.DEFAULT_INSTITUTION.equals(instId)) {
			    int multi = settingParamsCache.getParameterNumberValue(SettingsConstants.MULTI_INSTITUTION).intValue();
			    int commonSttlDay = settingParamsCache.getParameterNumberValue(SettingsConstants.COMMON_SETTLEMENT_DAY).intValue();
			    if (multi == 0 && commonSttlDay == 1) {
				    date = commonDao.getOpenSttlDate(instId);
			    }
		    } else {
			    date = commonDao.getOpenSttlDate(instId);
		    }
	    }

	    java.sql.Date resultDate = null;

	    if (date != null) {
		    Calendar gc = new GregorianCalendar();
		    gc.setTime(date);
		    resultDate = new java.sql.Date(gc.getTimeInMillis());
	    }

	    sttlDateMap.put(instId, resultDate);

        return resultDate;
    }
}
