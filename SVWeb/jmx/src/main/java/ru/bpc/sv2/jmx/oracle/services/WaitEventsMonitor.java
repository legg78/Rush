/*
 * WaitEventsMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.services;

import org.springframework.stereotype.Service;
import ru.bpc.sv2.jmx.oracle.mbean.WaitEventsMBean;
import ru.bpc.sv2.jmx.oracle.model.WaitEventsModel;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * <p>WaitEventsMonitor class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: bb58ed75e5ffb2a72655f1a46010137f1e216faf $
 */
@Service
public class WaitEventsMonitor extends OracleBaseMBeanMonitor<WaitEventsModel> implements
    WaitEventsMBean {

    private final String query;

    /**
     * <p>Constructor for WaitEventsMonitor.</p>
     */
    public WaitEventsMonitor() {
        super(WaitEventsMBean.class, "waitEvents");
        query = "select * from jmx_ui_oracle_wait_events_vw";
    }


    /** {@inheritDoc} */
    @Override
    protected WaitEventsModel queryValue(Connection conn, Statement stmt) throws SQLException {
        try (ResultSet rs = stmt.executeQuery(query)) {
            if (!rs.next()) {
                return null;
            }

            return new WaitEventsModel( //
                rs.getLong("waits_file_io"), //
                rs.getLong("waits_controfileio"), //
                rs.getLong("waits_directpath_read"), //
                rs.getLong("waits_singleblock_read"), //
                rs.getLong("waits_multiblock_read"), //
                rs.getLong("waits_sqlnet"), //
                rs.getLong("waits_logwrite"), //
                rs.getLong("waits_other"));
        }
    }

    /** {@inheritDoc} */
    @Override
    protected String getMBeanName() {
        return "WaitEvents";
    }

    /** {@inheritDoc} */
    @Override
    protected WaitEventsModel getNull() {
        return WaitEventsModel.NULL;
    }

    /** {@inheritDoc} */
    @Override
    public long getFileIO() {
        return getModel().getFileIO();
    }

    /** {@inheritDoc} */
    @Override
    public long getControlFileIO() {
        return getModel().getControlFileIO();
    }

    /** {@inheritDoc} */
    @Override
    public long getDirectPathReads() {
        return getModel().getDirectPathReads();
    }

    /** {@inheritDoc} */
    @Override
    public long getSingleBlockReads() {
        return getModel().getSingleBlockReads();
    }

    /** {@inheritDoc} */
    @Override
    public long getMultiBlockReads() {
        return getModel().getMultiBlockReads();
    }

    /** {@inheritDoc} */
    @Override
    public long getSqlNet() {
        return getModel().getSqlNet();
    }

    /** {@inheritDoc} */
    @Override
    public long getLogWrites() {
        return getModel().getLogWrites();
    }

    /** {@inheritDoc} */
    @Override
    public long getOther() {
        return getModel().getOther();
    }
}
