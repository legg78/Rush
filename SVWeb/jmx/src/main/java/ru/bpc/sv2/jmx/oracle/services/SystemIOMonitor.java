/*
 * DatabaseMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.services;

import ru.bpc.sv2.jmx.oracle.mbean.SystemIOMBean;
import ru.bpc.sv2.jmx.oracle.model.SystemIOModel;
import org.springframework.stereotype.Service;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * <p>SystemIOMonitor class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 782c679333de4415770aea753d7cd3a79aaedff0 $
 */
@Service
public class SystemIOMonitor extends OracleBaseMBeanMonitor<SystemIOModel> implements SystemIOMBean {
    private final String query;

    /**
     * <p>Constructor for SystemIOMonitor.</p>
     */
    public SystemIOMonitor() {
        super(SystemIOMBean.class, "systemio");
        query = "select * from jmx_ui_oracle_systemio_vw";
    }


    /** {@inheritDoc} */
    @Override
    protected SystemIOModel queryValue(Connection conn, Statement stmt) throws SQLException {
        try (ResultSet rs = stmt.executeQuery(query)) {
            if (!rs.next()) {
                return null;
            }

            return new SystemIOModel( //
                rs.getLong("physical_reads"), //
                rs.getLong("datafile_reads"), //
                rs.getLong("datafile_writes"), //
                rs.getLong("redo_writes"), //
                rs.getLong("block_gets"), //
                rs.getLong("consistent_gets"), //
                rs.getFloat("hit_ratio"), //
                rs.getLong("block_changes"), //
                rs.getFloat("sql_not_indexed"));
        }
    }

    /** {@inheritDoc} */
    @Override
    protected SystemIOModel getNull() {
        return SystemIOModel.NULL;
    }

    /** {@inheritDoc} */
    @Override
    protected String getMBeanName() {
        return "SystemIO";
    }

    /** {@inheritDoc} */
    @Override
    public long getPhysicalReads() {
        return getModel().getPhysicalReads();
    }

    /** {@inheritDoc} */
    @Override
    public long getDatafileReads() {
        return getModel().getDatafileReads();
    }

    /** {@inheritDoc} */
    @Override
    public long getDatafileWrites() {
        return getModel().getDatafileWrites();
    }

    /** {@inheritDoc} */
    @Override
    public long getRedoWrites() {
        return getModel().getRedoWrites();
    }

    /** {@inheritDoc} */
    @Override
    public long getBlockGets() {
        return getModel().getBlockGets();
    }

    /** {@inheritDoc} */
    @Override
    public long getConsistentGets() {
        return getModel().getConsistentGets();
    }

    /** {@inheritDoc} */
    @Override
    public float getHitRatio() {
        return getModel().getHitRatio();
    }

    /** {@inheritDoc} */
    @Override
    public long getBlockChanges() {
        return getModel().getBlockChanges();
    }

    /** {@inheritDoc} */
    @Override
    public float getNotIndexedSqlRatio() {
        return getModel().getNotIndexedSqlRatio();
    }
}
