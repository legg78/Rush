package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.commons.codec.binary.Hex;
import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.ps.mir.*;
import ru.bpc.sv2.utils.AuditParamUtil;


import java.util.*;

@SuppressWarnings("unchecked")

public class MirDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("PROCESSES");


	public List<LinkedHashMap> getFinMessagesAsMap(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<LinkedHashMap>>() {
			@Override
			public List<LinkedHashMap> doInSession(SqlMapSession ssn) throws Exception {
				List<LinkedHashMap> list = ssn.queryForList("mir.get-fin-messages-map", convertQueryParams(params));
				for (LinkedHashMap map : list) {
					boolean keep = false;
					for (Iterator i = map.keySet().iterator(); i.hasNext(); ) {
						Object key = i.next();
						if (key.toString().equalsIgnoreCase("MTI")) {
							keep = true;
						} else if (key.toString().equalsIgnoreCase("LANG")) {
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


	public List<MirFinMessage> getFinancialMessages(final Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, MirPrivConstants.VIEW_MIR_FIN_MESSAGES, AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
				new IbatisSessionCallback<List<MirFinMessage>>() {
					@Override
					public List<MirFinMessage> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, MirPrivConstants.VIEW_MIR_FIN_MESSAGES);
						return ssn.queryForList("mir.get-mir-fin-messages", convertQueryParams(params, limitation));
					}
				});
	}


	public int getFinancialMessagesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, MirPrivConstants.VIEW_MIR_FIN_MESSAGES, AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, MirPrivConstants.VIEW_MIR_FIN_MESSAGES);
						return (Integer) ssn.queryForObject("mir.get-mir-fin-messages-count", convertQueryParams(params, limitation));
					}
				});
	}


	public List<MirFinMessageAddendum> getMirFinMessageAddendum(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, MirPrivConstants.VIEW_MIR_FIN_MESSAGES, AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
				new IbatisSessionCallback<List<MirFinMessageAddendum>>() {
					@Override
					public List<MirFinMessageAddendum> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, MirPrivConstants.VIEW_MIR_FIN_MESSAGES);
						return ssn.queryForList("mir.get-mir-fin-messages-addendum", convertQueryParams(params, limitation));
					}
				});
	}


	public int getMirFinMessageAddendumCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, MirPrivConstants.VIEW_MIR_FIN_MESSAGES, AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, MirPrivConstants.VIEW_MIR_FIN_MESSAGES);
						return (Integer) ssn.queryForObject("mir.get-mir-fin-messages-addendum-count", convertQueryParams(params, limitation));
					}
				});
	}


	public List<MirReject> getMirRejects(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<MirReject>>() {
			@Override
			public List<MirReject> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("mir.get-mir-rejects", convertQueryParams(params));
			}
		});
	}


	public int getMirRejectsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer) ssn.queryForObject("mir.get-mir-rejects-count", convertQueryParams(params));
			}
		});
	}


	public List<MirRejectCode> getMirRejectCodes(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<MirRejectCode>>() {
			@Override
			public List<MirRejectCode> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("mir.get-mir-reject-codes", convertQueryParams(params));
			}
		});
	}


	public int getMirRejectCodesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer) ssn.queryForObject("mir.get-mir-reject-codes-count", convertQueryParams(params));
			}
		});
	}


	public List<MirFile> getFiles(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, MirPrivConstants.VIEW_MIR_FILES, AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
				new IbatisSessionCallback<List<MirFile>>() {
					@Override
					public List<MirFile> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, MirPrivConstants.VIEW_MIR_FILES);
						return ssn.queryForList("mir.get-mir-files", convertQueryParams(params, limitation));
					}
				});
	}


	public int getFilesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, MirPrivConstants.VIEW_MIR_FILES, AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, MirPrivConstants.VIEW_MIR_FILES);
						return (Integer) ssn.queryForObject("mir.get-mir-files-count", convertQueryParams(params, limitation));
					}
				});
	}


	public List<MirReport> getMirReports(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  MirPrivConstants.VIEW_MIR_REPORTS,
								  params,
								  logger,
								  new IbatisSessionCallback<List<MirReport>>() {
			@Override
			public List<MirReport> doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, MirPrivConstants.VIEW_MIR_REPORTS);
				return ssn.queryForList("mir.get-mir-reports", convertQueryParams(params, limitation));
			}
		});
	}


	public int getMirReportsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  MirPrivConstants.VIEW_MIR_REPORTS,
								  params,
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, MirPrivConstants.VIEW_MIR_REPORTS);
				Object count = ssn.queryForObject("mir.get-mir-reports-count", convertQueryParams(params, limitation));
				return (count != null) ? (Integer)count : 0;
			}
		});
	}
}
