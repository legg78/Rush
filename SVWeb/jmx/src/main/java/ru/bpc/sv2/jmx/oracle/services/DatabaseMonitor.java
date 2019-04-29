/*
 * DatabaseMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.services;

import ru.bpc.sv2.jmx.oracle.mbean.DatabaseMBean;
import ru.bpc.sv2.jmx.oracle.model.DatabaseModel;
import org.springframework.stereotype.Service;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * <p>DatabaseMonitor class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 8dc5675721caaaa00b1c4c960d173da24ab96c92 $
 */
@Service
public class DatabaseMonitor extends OracleBaseMBeanMonitor<DatabaseModel> implements DatabaseMBean {
    private final String infoQuery;
    private final String sizeQuery;

    /**
     * <p>Constructor for DatabaseMonitor.</p>
     */
    public DatabaseMonitor() {
        super(DatabaseMBean.class, "general");
        infoQuery = "select * from jmx_ui_oracle_general_info_vw";
        sizeQuery = "select * from jmx_ui_oracle_general_size_vw";
    }


    /** {@inheritDoc} */
    @Override
    protected DatabaseModel queryValue(Connection conn, Statement stmt) throws SQLException {
        final String version;
        final long uptime, databaseSize, fileSize, archiveLog, latchMisses;

        try (ResultSet rs = stmt.executeQuery(infoQuery)) {
            if (!rs.next()) {
                return null;
            }

            version = rs.getString("version");
            uptime = rs.getLong("uptime");
            archiveLog = rs.getLong("archive_log");
            latchMisses = rs.getLong("latch_misses");
        }

        try (ResultSet rs = stmt.executeQuery(sizeQuery)) {
            if (!rs.next()) {
                return null;
            }

            databaseSize = rs.getLong("database_size");
            fileSize = rs.getLong("file_size");
        }

        return new DatabaseModel(version, uptime, databaseSize, fileSize, archiveLog, latchMisses);
    }

    /** {@inheritDoc} */
    @Override
    protected DatabaseModel getNull() {
        return DatabaseModel.NULL;
    }

    /** {@inheritDoc} */
    @Override
    protected String getMBeanName() {
        return "General";
    }

    /** {@inheritDoc} */
    @Override
    public String getVersion() {
        return getModel().getVersion();
    }

    /** {@inheritDoc} */
    @Override
    public long getUptime() {
        return getModel().getUptime();
    }

    /** {@inheritDoc} */
    @Override
    public long getDatabaseSize() {
        return getModel().getDatabaseSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getFileSize() {
        return getModel().getFileSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getArchiveLog() {
        return getModel().getArchiveLog();
    }

    /** {@inheritDoc} */
    @Override
    public long getLatchMisses() {
        return getModel().getLatchMisses();
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        return getModel().toString();
    }
}
