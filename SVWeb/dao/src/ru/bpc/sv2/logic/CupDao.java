package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.ps.cup.*;


import java.sql.SQLException;
import java.util.List;

public class CupDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");


	public CupFinMessage[] getFinMessages(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<CupFinMessage> items = ssn.queryForList("cup.get_fin_messages", convertQueryParams(params));
			return items.toArray(new CupFinMessage[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CupDispute[] getDisputes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<CupDispute> items = ssn.queryForList("cup.get_disputes", convertQueryParams(params));
			return items.toArray(new CupDispute[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public long getDisputesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			long count = (Long) ssn.queryForObject("cup.get_disputes_count", convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CupAuth getAuth(Long userSessionId, String rrn) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<CupAuth> items = ssn.queryForList("cup.get_auth", rrn);
			if (items == null || items.isEmpty()) {
				return null;
			}
			return items.get(0);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CupFinMessage getClearingOperation(Long userSessionId, String rrn) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<CupFinMessage> items = ssn.queryForList("cup.get_clearing_operation", rrn);
			if (items == null || items.isEmpty()) {
				return null;
			}
			return items.get(0);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getFinMessagesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			int count = (Integer) ssn.queryForObject("cup.get_fin_messages_count", convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CupFile[] getCupFiles(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<CupFile[]>() {
			@Override
			public CupFile[] doInSession(SqlMapSession ssn) throws Exception {
				List<CupFile> items = ssn.queryForList("cup.get-cup-files", convertQueryParams(params));
				return items.toArray(new CupFile[items.size()]);
			}
		});
	}


	public int getCupFilesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("cup.get-cup-files-count", convertQueryParams(params));
			}
		});
	}


	public CupFinMessage[] getCupFileFinMessages(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<CupFinMessage[]>() {
			@Override
			public CupFinMessage[] doInSession(SqlMapSession ssn) throws Exception {
				List<CupFinMessage> items = ssn.queryForList("cup.get-cup-file-fin-messages", convertQueryParams(params));
				return items.toArray(new CupFinMessage[items.size()] );
			}
		});
	}


	public int getCupFileFinMessagesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("cup.get-cup-file-fin-messages-count", convertQueryParams(params));
			}
		});
	}


	public CupFee[] getCupFileFees(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<CupFee[]>() {
			@Override
			public CupFee[] doInSession(SqlMapSession ssn) throws Exception {
				List<CupFee> items = ssn.queryForList("cup.get-cup-file-fees", convertQueryParams(params));
				return items.toArray(new CupFee[items.size()] );
			}
		});
	}


	public int getCupFileFeesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("cup.get-cup-file-fees-count", convertQueryParams(params));
			}
		});
	}
}
