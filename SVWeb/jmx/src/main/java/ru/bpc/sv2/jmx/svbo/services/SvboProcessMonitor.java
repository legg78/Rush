/*
 * SvboProcessMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.services;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import ru.bpc.sv2.jmx.utils.MonitoringSettings;
import ru.bpc.sv2.jmx.svbo.mbean.SvboProcess;
import ru.bpc.sv2.jmx.svbo.model.State;
import ru.bpc.sv2.jmx.svbo.model.SvboProcessModel;

/**
 * Container monitor service.
 *
 * @author Ilya Yushin
 * @version $Id: 3cf3b28070fa714078938f525a18a39d165496c8 $
 */
@Service
public class SvboProcessMonitor extends SvboMonitor<SvboProcessModel, SvboProcess> {
    private final String query;

    @Autowired
    private MonitoringSettings settings;

    /**
     * <p>
     * Constructor for SvboProcessMonitor.
     * </p>
     */
    public SvboProcessMonitor() {
        super("processes");
        query = "select * from jmx_ui_svbo_process_vw";
    }

    /** {@inheritDoc} */
    @Override
    protected String entityType() {
        return "Processes";
    }

    /** {@inheritDoc} */
    @Override
    protected PreparedStatement prepareStatement(Connection conn) throws SQLException {
        final PreparedStatement stmt = conn.prepareStatement(query);
        return stmt;
    }

    /** {@inheritDoc} */
    @Override
    protected void discoveryAttributes(SvboProcess bean, Map<String, Object> destination) {
        destination.put(macroName("relation.id"), bean.getId());
        destination.put(macroName("instance.id"), bean.getProcessId());
        destination.put(macroName("parent.id"), bean.getContainerId());
        destination.put(macroName("name"), bean.getName());
        destination.put(macroName("state"), bean.getState());
        destination.put(macroName("started"), bean.getStartTime());
        destination.put(macroName("finished"), bean.getFinishTime());
    }

    /** {@inheritDoc} */
    @Override
    protected SvboProcess newBean(SvboProcessModel model) {
        return new SvboProcess(model);
    }

    /** {@inheritDoc} */
    @Override
    protected SvboProcessModel mapBeanModel(ResultSet rs) throws SQLException {
        return new SvboProcessModel( //
            rs.getLong("id"), //
            rs.getString("name"), //
            rs.getLong("process_id"), //
            rs.getLong("container_id"), //
            State.fromSymbol(rs.getString("state")), //
            rs.getFloat("progress"), //
            rs.getLong("processed"), //
            rs.getLong("rejected"), //
            rs.getLong("excepted"), //
            rs.getFloat("remaining"), //
            rs.getTimestamp("start_time"), //
            rs.getTimestamp("end_time"));
    }

    /** {@inheritDoc} */
    @Override
    protected String macroName(String attribute) {
        return String.format("{#JMX.PROCESS.%S}", attribute);
    }

    /** {@inheritDoc} */
    @Override
    protected String beanName(SvboProcess bean) {
        return String.format("(%d/%d) %s", bean.getProcessId(), bean.getId(), bean.getName());
    }
}
