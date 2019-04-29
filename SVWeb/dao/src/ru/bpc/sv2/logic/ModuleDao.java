package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.ModuleItem;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.utility.db.IbatisAware;

import ru.bpc.sv2.logic.utility.db.DataAccessException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ModuleDao extends IbatisAware {
	protected static Logger logger = Logger.getLogger(ModuleDao.class);

	protected long getCount(String module, String queryId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			params.setModule(module);
			Long cnt = (Long) ssn.queryForObject(queryId, convertQueryParams(params));
			return cnt;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected long getCount(String queryId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Long cnt = (Long) ssn.queryForObject(queryId, convertQueryParams(params));
			return cnt;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected long getSeqVal(String queryId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Long cnt = (Long) ssn.queryForObject(queryId);
			return cnt;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected void delete(String module, String queryId, String itemId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, String> map = new HashMap<String, String>();
			map.put("item_id", itemId);
			map.put("module", module);
			ssn.delete(queryId, map);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected void delete(String queryId, String itemId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, String> map = new HashMap<String, String>();
			map.put("item_id", itemId);
			ssn.delete(queryId, map);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected void insert(String module, String insertQueryId, ModuleItem item) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			item.setModule(module);
			ssn.insert(insertQueryId, item);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected void insert(String insertQueryId, ModuleItem item) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			ssn.insert(insertQueryId, item);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected void update(String module, String updateQueryId, ModuleItem item) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			item.setModule(module);
			ssn.update(updateQueryId, item);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected void update(String updateQueryId, ModuleItem item) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			ssn.update(updateQueryId, item);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected List getItems(String module, String queryId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			params.setModule(module);
			return ssn.queryForList(queryId, convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected List getItems(String queryId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			return ssn.queryForList(queryId, convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected List getItems(String module, String queryId, Map<String, Object> map) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			map.put("module", module);
			return ssn.queryForList(queryId, map);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	protected List getItems(String queryId, Map<String, Object> map) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			return ssn.queryForList(queryId, map);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}
}
