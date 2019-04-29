package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.ps.nbc.NbcFile;
import ru.bpc.sv2.ps.nbc.NbcFinMessage;
import ru.bpc.sv2.ps.nbc.NbcPrivConstants;
import ru.bpc.sv2.utils.AuditParamUtil;


import java.sql.SQLException;
import java.util.List;

@SuppressWarnings("unchecked")
public class NbcDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("PROCESSES");


	public List<NbcFinMessage> getFinancialMessages(final Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, NbcPrivConstants.VIEW_NBC_FIN_MESSAGES, AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
				new IbatisSessionCallback<List<NbcFinMessage>>() {
					@Override
					public List<NbcFinMessage> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, NbcPrivConstants.VIEW_NBC_FIN_MESSAGES);
						return ssn.queryForList("nbc.get-nbc-fin-messages", convertQueryParams(params, limitation));
					}
				});
	}


	public int getFinancialMessagesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, NbcPrivConstants.VIEW_NBC_FIN_MESSAGES, AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, NbcPrivConstants.VIEW_NBC_FIN_MESSAGES);
						return (Integer) ssn.queryForObject("nbc.get-nbc-fin-messages-count", convertQueryParams(params, limitation));
					}
				});
	}


	public NbcFinMessage modifyFinMessage(Long userSessionId, NbcFinMessage message) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(message.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NbcPrivConstants.VIEW_NBC_FIN_MESSAGES, paramArr);

			ssn.update("nbc.modify-fin-message", message);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter("id", message.getId());
			filters[1] = new Filter("lang", message.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NbcFinMessage) ssn.queryForObject("nbc.get-nbc-fin-messages", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public List<NbcFile> getFiles(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, NbcPrivConstants.VIEW_NBC_FILES, AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
				new IbatisSessionCallback<List<NbcFile>>() {
					@Override
					public List<NbcFile> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, NbcPrivConstants.VIEW_NBC_FILES);
						return ssn.queryForList("nbc.get-nbc-files", convertQueryParams(params, limitation));
					}
				});
	}


	public int getFilesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, NbcPrivConstants.VIEW_NBC_FILES, AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, NbcPrivConstants.VIEW_NBC_FILES);
						return (Integer) ssn.queryForObject("nbc.get-nbc-files-count", convertQueryParams(params, limitation));
					}
				});
	}
}
