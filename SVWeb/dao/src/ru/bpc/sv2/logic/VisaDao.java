package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.ps.visa.*;


import java.util.List;

/**
 * Session Bean implementation class VisaDao
 */
@SuppressWarnings("unchecked")
public class VisaDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");
	

	public VisaFinMessage[] getVisaFinMessages(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<VisaFinMessage[]>() {
			@Override
			public VisaFinMessage[] doInSession(SqlMapSession ssn) throws Exception {
				List<VisaFinMessage> items = ssn.queryForList("vis.get-visa-fin-messages", convertQueryParams(params));
    		return items.toArray(new VisaFinMessage[items.size()]);
    	}
		});
    }


	public int getVisaFinMessagesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer) ssn.queryForObject("vis.get-visa-fin-messages-count", convertQueryParams(params));
    	}
		});
    }


	public VisaFee[] getVisaFees(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<VisaFee[]>() {
			@Override
			public VisaFee[] doInSession(SqlMapSession ssn) throws Exception {
				List<VisaFee> items = ssn.queryForList("vis.get-visa-fees", convertQueryParams(params));
    		return items.toArray(new VisaFee[items.size()]);
    	}
		});
    }


	public int getVisaFeesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer) ssn.queryForObject("vis.get-visa-fees-count", convertQueryParams(params));
    	}
		});
    }


	public VisaAddendum[] getVisaAddendums(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<VisaAddendum[]>() {
			@Override
			public VisaAddendum[] doInSession(SqlMapSession ssn) throws Exception {
				List<VisaAddendum> items = ssn.queryForList("vis.get-visa-addendums", convertQueryParams(params));
    		return items.toArray(new VisaAddendum[items.size()]);
    	}
		});
    }


	public int getVisaAddendumsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer) ssn.queryForObject("vis.get-visa-addendums-count", convertQueryParams(params));
    	}
		});
    }


	public VisaFile[] getFiles(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, VisaPrivConstants.VIEW_VISA_FILES, params, logger,
				new IbatisSessionCallback<VisaFile[]>() {
					@Override
					public VisaFile[] doInSession(SqlMapSession ssn) throws Exception {
			            String limitation = CommonController.getLimitationByPriv(ssn, VisaPrivConstants.VIEW_VISA_FILES);
			            List<VisaFile> messages = ssn.queryForList("vis.get-visa-files", convertQueryParams(params, limitation));
			            return messages.toArray(new VisaFile[messages.size()]);
			        }
				});
    }


	public int getFilesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, VisaPrivConstants.VIEW_VISA_FILES, params, logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
			            String limitation = CommonController.getLimitationByPriv(ssn, VisaPrivConstants.VIEW_VISA_FILES);
			            return (Integer) ssn.queryForObject("vis.get-visa-files-count", convertQueryParams(params, limitation));
			        }
				});
    }


	public VisaFinMessage[] getVisaFileFinMessages(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, VisaPrivConstants.VIEW_VISA_FIN_MESSAGES, params, logger,
				new IbatisSessionCallback<VisaFinMessage[]>() {
					@Override
					public VisaFinMessage[] doInSession(SqlMapSession ssn) throws Exception {
			            String limitation = CommonController.getLimitationByPriv(ssn, VisaPrivConstants.VIEW_VISA_FIN_MESSAGES);
			            List<VisaFinMessage> fileFinMessages = ssn.queryForList("vis.get-visa-fin-messages", convertQueryParams(params, limitation));
			            return fileFinMessages.toArray(new VisaFinMessage[fileFinMessages.size()]);
			        }
				});
    }


	public int getVisaFileFinMessagesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, VisaPrivConstants.VIEW_VISA_FIN_MESSAGES, params, logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
			            String limitation = CommonController.getLimitationByPriv(ssn, VisaPrivConstants.VIEW_VISA_FIN_MESSAGES);
			            return (Integer) ssn.queryForObject("vis.get-visa-fin-messages-count", convertQueryParams(params, limitation));
			        }
				});
    }


	public VisaReturn[] getVisaReturns(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger,
				new IbatisSessionCallback<VisaReturn[]>() {
					@Override
					public VisaReturn[] doInSession(SqlMapSession ssn) throws Exception {
						List<VisaReturn> items = ssn.queryForList("vis.get-visa-returns", convertQueryParams(params));
			            return items.toArray(new VisaReturn[items.size()]);
			        }
				});
	}


	public int getVisaReturnsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						return (Integer) ssn.queryForObject("vis.get-visa-returns-count", convertQueryParams(params));
					}
				});
	}


	public List<VisaVssReport> getVisaVssReports(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, VisaPrivConstants.VIEW_VISA_VSS_REPORTS, params, logger,
				new IbatisSessionCallback<List<VisaVssReport>>() {
					@Override
					public List<VisaVssReport> doInSession(SqlMapSession ssn) throws Exception {
						return ssn.queryForList("vis.get-visa-vss-reports", convertQueryParams(params));
					}
				});
	}


	public int getVisaVssReportsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, VisaPrivConstants.VIEW_VISA_VSS_REPORTS, params, logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						return (Integer) ssn.queryForObject("vis.get-visa-vss-reports-count", convertQueryParams(params));
					}
				});
    }


	public List<VisaVssReportDetailV2> getVisaVssReportsV2(Long userSessionId, final Long reportId) {
		return executeWithSession(userSessionId, VisaPrivConstants.VIEW_VISA_VSS_REPORTS, new CommonParamRec[0], logger,
				new IbatisSessionCallback<List<VisaVssReportDetailV2>>() {
					@Override
					public List<VisaVssReportDetailV2> doInSession(SqlMapSession ssn) throws Exception {
						return ssn.queryForList("vis.get-visa-vss-reports-v2", reportId);
                    }
				});
    }


	public List<VisaVssReportDetailV4> getVisaVssReportsV4(Long userSessionId, final Long reportId) {
		return executeWithSession(userSessionId, VisaPrivConstants.VIEW_VISA_VSS_REPORTS, new CommonParamRec[0], logger,
				new IbatisSessionCallback<List<VisaVssReportDetailV4>>() {
					@Override
					public List<VisaVssReportDetailV4> doInSession(SqlMapSession ssn) throws Exception {
						return ssn.queryForList("vis.get-visa-vss-reports-v4", reportId);
					}
				});
	}


	public List<VisaVssReportDetailV6> getVisaVssReportsV6(Long userSessionId, final Long reportId) {
		return executeWithSession(userSessionId, VisaPrivConstants.VIEW_VISA_VSS_REPORTS, new CommonParamRec[0], logger,
				new IbatisSessionCallback<List<VisaVssReportDetailV6>>() {
					@Override
					public List<VisaVssReportDetailV6> doInSession(SqlMapSession ssn) throws Exception {
						return ssn.queryForList("vis.get-visa-vss-reports-v6", reportId);
					}
				});
	}


	public Boolean isVisaOperation(Long userSessionId, final Long operationId) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Boolean>() {
			@Override
			public Boolean doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForObject("vis.is-visa-operation", operationId) != null;
			}
		});
	}


	public VisaFinStatusAdvice[] getVisaFinStatusAdvices(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, VisaPrivConstants.VIEW_VISA_FIN_STATUS_ADVICES, params, logger, new IbatisSessionCallback<VisaFinStatusAdvice[]>() {
			@Override
			public VisaFinStatusAdvice[] doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, VisaPrivConstants.VIEW_VISA_FIN_STATUS_ADVICES);
				List<VisaFinStatusAdvice> items = ssn.queryForList("vis.get-fin-status-advices", convertQueryParams(params, limitation));
				return items.toArray(new VisaFinStatusAdvice[items.size()]);
			}
		});
	}


	public int getVisaFinStatusAdvicesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, VisaPrivConstants.VIEW_VISA_FIN_STATUS_ADVICES, params, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, VisaPrivConstants.VIEW_VISA_FIN_STATUS_ADVICES);
				Integer i = (Integer) ssn.queryForObject("vis.get-fin-status-advices-count", convertQueryParams(params, limitation));
				return i;
			}
		});
	}


	public List<VisaSmsReport> getVisaSmsReports(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  VisaPrivConstants.VIEW_VISA_SMS_REPORTS,
								  params,
								  logger,
								  new IbatisSessionCallback<List<VisaSmsReport>>() {
			@Override
			public List<VisaSmsReport> doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, VisaPrivConstants.VIEW_VISA_SMS_REPORTS);
				return ssn.queryForList("vis.get-sms-reports", convertQueryParams(params, limitation));
			}
		});
	}


	public int getVisaSmsReportsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  VisaPrivConstants.VIEW_VISA_SMS_REPORTS,
								  params,
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, VisaPrivConstants.VIEW_VISA_SMS_REPORTS);
				Object out = ssn.queryForObject("vis.get-sms-reports-count", convertQueryParams(params, limitation));
				return (out != null) ? (Integer)out : 0;
			}
		});
	}
}
