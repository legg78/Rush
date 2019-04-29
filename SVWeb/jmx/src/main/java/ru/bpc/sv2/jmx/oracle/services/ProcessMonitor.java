/*
 * DatabaseMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.services;

import ru.bpc.sv2.jmx.oracle.mbean.ProcessesMBean;
import ru.bpc.sv2.jmx.oracle.model.ProcessesModel;
import org.springframework.stereotype.Service;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * <p>ProcessMonitor class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 726eb1558b8c6f4c00d95722948ab9c90423a17a $
 */
@Service
public class ProcessMonitor extends OracleBaseMBeanMonitor<ProcessesModel> implements ProcessesMBean {
    private final String query;

    /**
     * <p>Constructor for ProcessMonitor.</p>
     */
    public ProcessMonitor() {
        super(ProcessesMBean.class, "processes");
        query = "select * from jmx_ui_oracle_processes_vw";
    }


    /** {@inheritDoc} */
    @Override
    protected ProcessesModel queryValue(Connection conn, Statement stmt) throws SQLException {
        try (ResultSet rs = stmt.executeQuery(query)) {
            if (!rs.next()) {
                return null;
            }

            return new ProcessesModel(rs.getInt("process_count"), rs.getInt("process_limit"));
        }
    }

    /** {@inheritDoc} */
    @Override
    protected ProcessesModel getNull() {
        return ProcessesModel.NULL;
    }

    /** {@inheritDoc} */
    @Override
    protected String getMBeanName() {
        return "Processes";
    }

    /** {@inheritDoc} */
    @Override
    public int getCount() {
        return getModel().getCount();
    }

    /** {@inheritDoc} */
    @Override
    public int getMax() {
        return getModel().getMax();
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        return getModel().toString();
    }
}
