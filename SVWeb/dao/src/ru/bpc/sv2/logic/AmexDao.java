package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.commons.codec.binary.Hex;
import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.ps.amex.*;
import ru.bpc.sv2.utils.AuditParamUtil;


import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;

@SuppressWarnings("unchecked")
public class AmexDao extends IbatisAware {
    private static final Logger logger = Logger.getLogger("AMEX");
    private static final String MAJOR_KEY = "MTID";
    private static final String MINOR_KEY = "LANG";


    public List<LinkedHashMap> getLinkedFinMessages(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<LinkedHashMap>>() {
	        @Override
            public List<LinkedHashMap> doInSession(SqlMapSession ssn) throws Exception {
                List<LinkedHashMap> list = ssn.queryForList("amex.get-linked-fin-messages", convertQueryParams(params));
                for (LinkedHashMap map : list) {
                    boolean keep = false;
                    for (Iterator i = map.keySet().iterator(); i.hasNext();) {
                        Object key = i.next();
                        if (MAJOR_KEY.equalsIgnoreCase(key.toString())) {
                            keep = true;
                        } else if (MINOR_KEY.equalsIgnoreCase(key.toString())) {
                            keep = false;
                        }
                        if (!keep) {
                            i.remove();
                        } else {
                            Object val = map.get(key);
                            if (val instanceof byte[]) {
                                map.put(key, new String(Hex.encodeHex((byte[]) val)));
                            }
                        }
                    }
                }
                return list;
            }
        });
    }


    public List<AmexFinMessage> getFinancialMessages(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  AmexPrivConstants.VIEW_AMX_FIN_MESSAGES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<List<AmexFinMessage>>() {
        	@Override
            public List<AmexFinMessage> doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, AmexPrivConstants.VIEW_AMX_FIN_MESSAGES);
                return ssn.queryForList("amex.get-fin-messages", convertQueryParams(params, limitation));
            }
        });
    }


    public int getFinancialMessagesCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  AmexPrivConstants.VIEW_AMX_FIN_MESSAGES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, AmexPrivConstants.VIEW_AMX_FIN_MESSAGES);
                Object result = ssn.queryForObject("amex.get-fin-messages-count", convertQueryParams(params, limitation));
                return (result != null) ? (Integer)result : 0;
            }
        });
    }


    public List<AmexFinMessageAddendum> getFinMessageAddendum(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  AmexPrivConstants.VIEW_AMX_FIN_MESSAGES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<List<AmexFinMessageAddendum>>() {
	        @Override
            public List<AmexFinMessageAddendum> doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, AmexPrivConstants.VIEW_AMX_FIN_MESSAGES);
                return ssn.queryForList("amex.get-fin-messages-addendum", convertQueryParams(params, limitation));
            }
        });
    }


    public int getFinMessageAddendumCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  AmexPrivConstants.VIEW_AMX_FIN_MESSAGES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, AmexPrivConstants.VIEW_AMX_FIN_MESSAGES);
                Object result = ssn.queryForObject("amex.get-fin-messages-addendum-count", convertQueryParams(params, limitation));
                return (result != null) ? (Integer)result : 0;
            }
        });
    }


    public List<AmexReject> getRejects(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  AmexPrivConstants.VIEW_AMX_FIN_MESSAGES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<List<AmexReject>>() {
	        @Override
            public List<AmexReject> doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, AmexPrivConstants.VIEW_AMX_FIN_MESSAGES);
                return ssn.queryForList("amex.get-rejects", convertQueryParams(params, limitation));
            }
        });
    }


    public int getRejectsCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  AmexPrivConstants.VIEW_AMX_FIN_MESSAGES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, AmexPrivConstants.VIEW_AMX_FIN_MESSAGES);
                Object result = ssn.queryForObject("amex.get-rejects-count", convertQueryParams(params, limitation));
                return (result != null) ? (Integer)result : 0;
            }
        });
    }


    public List<AmexFile> getFiles(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  AmexPrivConstants.VIEW_AMX_FILES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<List<AmexFile>>() {
	        @Override
            public List<AmexFile> doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, AmexPrivConstants.VIEW_AMX_FILES);
                return ssn.queryForList("amex.get-files", convertQueryParams(params, limitation));
            }
        });
    }


    public int getFilesCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  AmexPrivConstants.VIEW_AMX_FILES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	         @Override
             public Integer doInSession(SqlMapSession ssn) throws Exception {
                 String limitation = CommonController.getLimitationByPriv(ssn, AmexPrivConstants.VIEW_AMX_FILES);
                 Object result = ssn.queryForObject("amex.get-files-count", convertQueryParams(params, limitation));
                 return (result != null) ? (Integer)result : 0;
             }
        });
    }


    public List<AmexAtmReconciliation> getAtmReconciliations(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  AmexPrivConstants.VIEW_AMX_ATM_RECONCILIATIONS,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<List<AmexAtmReconciliation>>() {
	         @Override
             public List<AmexAtmReconciliation> doInSession(SqlMapSession ssn) throws Exception {
                 String limitation = CommonController.getLimitationByPriv(ssn, AmexPrivConstants.VIEW_AMX_ATM_RECONCILIATIONS);
                 return ssn.queryForList("amex.get-atm-reconciliations", convertQueryParams(params, limitation));
            }
        });
    }


    public int getAtmReconciliationsCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  AmexPrivConstants.VIEW_AMX_ATM_RECONCILIATIONS,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	         @Override
             public Integer doInSession(SqlMapSession ssn) throws Exception {
                 String limitation = CommonController.getLimitationByPriv(ssn, AmexPrivConstants.VIEW_AMX_ATM_RECONCILIATIONS);
                 Object result = ssn.queryForObject("amex.get-atm-reconciliations-count", convertQueryParams(params, limitation));
                 return (result != null) ? (Integer)result : 0;
             }
        });
    }
}
