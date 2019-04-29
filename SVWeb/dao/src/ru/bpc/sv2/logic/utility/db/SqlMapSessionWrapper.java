package ru.bpc.sv2.logic.utility.db;

import com.ibatis.common.util.PaginatedList;
import com.ibatis.sqlmap.client.SqlMapSession;
import com.ibatis.sqlmap.client.event.RowHandler;
import com.ibatis.sqlmap.engine.execution.BatchException;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class SqlMapSessionWrapper implements SqlMapSession {
	private SqlMapSession target;
	private boolean closeConnectionWithSession;

	public SqlMapSessionWrapper(SqlMapSession target) {
		this(target, true);
	}

	public SqlMapSessionWrapper(SqlMapSession target, boolean closeConnectionWithSession) {
		this.target = target;
		this.closeConnectionWithSession = closeConnectionWithSession;
	}

	@Override
	public void close() {
		try {
			if (closeConnectionWithSession && getCurrentConnection() != null)
				getCurrentConnection().close();
		} catch (SQLException ignored) {
		}
		target.close();
	}

	@Override
	public Object insert(String id, Object parameterObject) throws SQLException {
		return target.insert(id, parameterObject);
	}

	@Override
	public Object insert(String id) throws SQLException {
		return target.insert(id);
	}

	@Override
	public int update(String id, Object parameterObject) throws SQLException {
		return target.update(id, parameterObject);
	}

	@Override
	public int update(String id) throws SQLException {
		return target.update(id);
	}

	@Override
	public int delete(String id, Object parameterObject) throws SQLException {
		return target.delete(id, parameterObject);
	}

	@Override
	public int delete(String id) throws SQLException {
		return target.delete(id);
	}

	@Override
	public Object queryForObject(String id, Object parameterObject) throws SQLException {
		return target.queryForObject(id, parameterObject);
	}

	@Override
	public Object queryForObject(String id) throws SQLException {
		return target.queryForObject(id);
	}

	@Override
	public Object queryForObject(String id, Object parameterObject, Object resultObject) throws SQLException {
		return target.queryForObject(id, parameterObject, resultObject);
	}

	@Override
	public List queryForList(String id, Object parameterObject) throws SQLException {
		return target.queryForList(id, parameterObject);
	}

	@Override
	public List queryForList(String id) throws SQLException {
		return target.queryForList(id);
	}

	@Override
	public List queryForList(String id, Object parameterObject, int skip, int max) throws SQLException {
		return target.queryForList(id, parameterObject, skip, max);
	}

	@Override
	public List queryForList(String id, int skip, int max) throws SQLException {
		return target.queryForList(id, skip, max);
	}

	@Override
	public void queryWithRowHandler(String id, Object parameterObject, RowHandler rowHandler) throws SQLException {
		target.queryWithRowHandler(id, parameterObject, rowHandler);
	}

	@Override
	public void queryWithRowHandler(String id, RowHandler rowHandler) throws SQLException {
		target.queryWithRowHandler(id, rowHandler);
	}

	@Override
	public PaginatedList queryForPaginatedList(String id, Object parameterObject, int pageSize) throws SQLException {
		return target.queryForPaginatedList(id, parameterObject, pageSize);
	}

	@Override
	public PaginatedList queryForPaginatedList(String id, int pageSize) throws SQLException {
		return target.queryForPaginatedList(id, pageSize);
	}

	@Override
	public Map queryForMap(String id, Object parameterObject, String keyProp) throws SQLException {
		return target.queryForMap(id, parameterObject, keyProp);
	}

	@Override
	public Map queryForMap(String id, Object parameterObject, String keyProp, String valueProp) throws SQLException {
		return target.queryForMap(id, parameterObject, keyProp, valueProp);
	}

	@Override
	public void startBatch() throws SQLException {
		target.startBatch();
	}

	@Override
	public int executeBatch() throws SQLException {
		return target.executeBatch();
	}

	@Override
	public List executeBatchDetailed() throws SQLException, BatchException {
		return target.executeBatchDetailed();
	}

	@Override
	public void startTransaction() throws SQLException {
		target.startTransaction();
	}

	@Override
	public void startTransaction(int transactionIsolation) throws SQLException {
		target.startTransaction(transactionIsolation);
	}

	@Override
	public void commitTransaction() throws SQLException {
		target.commitTransaction();
	}

	@Override
	public void endTransaction() throws SQLException {
		target.endTransaction();
	}

	@Override
	public void setUserConnection(Connection connnection) throws SQLException {
		target.setUserConnection(connnection);
	}

	@Override
	public Connection getUserConnection() throws SQLException {
		return target.getUserConnection();
	}

	@Override
	public Connection getCurrentConnection() throws SQLException {
		return target.getCurrentConnection();
	}

	@Override
	public DataSource getDataSource() {
		return target.getDataSource();
	}
}
