package ru.bpc.sv2.datasource;

import org.springframework.util.Assert;

import javax.sql.DataSource;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Logger;

public abstract class LazyDataSource implements DataSource {
	private DataSource targetDataSource;

	/**
	 * Set the target DataSource that this DataSource should delegate to.
	 */
	public void setTargetDataSource(DataSource targetDataSource) {
		Assert.notNull(targetDataSource, "'targetDataSource' must not be null");
		this.targetDataSource = targetDataSource;
	}

	/**
	 * Return the target DataSource that this DataSource should delegate to.
	 */
	public DataSource getTargetDataSource() {
		if (targetDataSource == null) {
			targetDataSource = initDataSource();
		}
		return targetDataSource;
	}

	protected abstract DataSource initDataSource();

	@Override
	public Connection getConnection() throws SQLException {
		return getTargetDataSource().getConnection();
	}

	@Override
	public Connection getConnection(String username, String password) throws SQLException {
		return getTargetDataSource().getConnection(username, password);
	}

	@Override
	public PrintWriter getLogWriter() throws SQLException {
		return getTargetDataSource().getLogWriter();
	}

	@Override
	public void setLogWriter(PrintWriter out) throws SQLException {
		getTargetDataSource().setLogWriter(out);
	}

	@Override
	public int getLoginTimeout() throws SQLException {
		return getTargetDataSource().getLoginTimeout();
	}

	@Override
	public void setLoginTimeout(int seconds) throws SQLException {
		getTargetDataSource().setLoginTimeout(seconds);
	}


	//---------------------------------------------------------------------
	// Implementation of JDBC 4.0's Wrapper interface
	//---------------------------------------------------------------------

	@Override
	@SuppressWarnings("unchecked")
	public <T> T unwrap(Class<T> iface) throws SQLException {
		if (iface.isInstance(this)) {
			return (T) this;
		}
		return getTargetDataSource().unwrap(iface);
	}

	@Override
	public boolean isWrapperFor(Class<?> iface) throws SQLException {
		return (iface.isInstance(this) || getTargetDataSource().isWrapperFor(iface));
	}


	//---------------------------------------------------------------------
	// Implementation of JDBC 4.1's getParentLogger method
	//---------------------------------------------------------------------

	@Override
	public Logger getParentLogger() {
		return Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
	}

}
