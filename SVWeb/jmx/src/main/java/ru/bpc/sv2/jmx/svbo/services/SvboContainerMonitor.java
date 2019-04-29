/*
 * SvboContainerMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.services;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

import org.springframework.stereotype.Service;

import ru.bpc.sv2.jmx.svbo.mbean.SvboContainer;
import ru.bpc.sv2.jmx.svbo.model.State;
import ru.bpc.sv2.jmx.svbo.model.SvboContainerModel;

/**
 * Container monitor service.
 *
 * @author Ilya Yushin
 * @version $Id: 3f000e99c7fe57191c9881ef65c903a9b9f7639e $
 */
@Service
public class SvboContainerMonitor extends SvboMonitor<SvboContainerModel, SvboContainer> {
    private final String query;

    /**
     * <p>
     * Constructor for SvboContainerMonitor.
     * </p>
     */
    public SvboContainerMonitor() {
        super("containers");
        query = "select * from jmx_ui_svbo_container_vw";
    }

    /** {@inheritDoc} */
    @Override
    protected String entityType() {
        return "Containers";
    }

    /** {@inheritDoc} */
    @Override
    protected PreparedStatement prepareStatement(Connection conn) throws SQLException {
        return conn.prepareStatement(query);
    }

    /** {@inheritDoc} */
    @Override
    protected void discoveryAttributes(SvboContainer bean, Map<String, Object> destination) {
        destination.put(macroName("instance.id"), bean.getId());
        destination.put(macroName("name"), bean.getName());
        destination.put(macroName("state"), bean.getState());
        destination.put(macroName("finished"), bean.getFinishTime());
    }

    /** {@inheritDoc} */
    @Override
    protected SvboContainer newBean(SvboContainerModel model) {
        return new SvboContainer(model);
    }

    /** {@inheritDoc} */
    @Override
    protected SvboContainerModel mapBeanModel(ResultSet rs) throws SQLException {
        return new SvboContainerModel( //
            rs.getLong("id"), //
            rs.getString("name"), //
            State.fromSymbol(rs.getString("state")), //
            rs.getTimestamp("finish_time"));
    }

    /** {@inheritDoc} */
    @Override
    protected String macroName(String attribute) {
        return String.format("{#JMX.CONTAINER.%S}", attribute);
    }

    /** {@inheritDoc} */
    @Override
    protected String beanName(SvboContainer bean) {
        return String.format("(%s) %s", bean.getId(), bean.getName());
    }
}
