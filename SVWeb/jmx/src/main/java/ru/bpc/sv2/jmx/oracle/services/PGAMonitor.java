/*
 * DatabaseMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.services;

import ru.bpc.sv2.jmx.oracle.mbean.PGAMBean;
import ru.bpc.sv2.jmx.oracle.model.PGAModel;
import org.springframework.stereotype.Service;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * <p>PGAMonitor class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 8708d272b1e9dde801005df24bc5f0152df2c597 $
 */
@Service
public class PGAMonitor extends OracleBaseMBeanMonitor<PGAModel> implements PGAMBean {
    private final String query;

    /**
     * <p>Constructor for PGAMonitor.</p>
     */
    public PGAMonitor() {
        super(PGAMBean.class, "pga");
        query = "select * from jmx_ui_oracle_pga_vw";
    }


    /** {@inheritDoc} */
    @Override
    protected PGAModel queryValue(Connection conn, Statement stmt) throws SQLException {
        try (ResultSet rs = stmt.executeQuery(query)) {
            if (!rs.next()) {
                return null;
            }
            return new PGAModel(rs.getLong("aggregate_target"), rs.getLong("used_bytes"));
        }
    }

    /** {@inheritDoc} */
    @Override
    protected PGAModel getNull() {
        return PGAModel.NULL;
    }

    /** {@inheritDoc} */
    @Override
    protected String getMBeanName() {
        return "PGA";
    }

    /** {@inheritDoc} */
    @Override
    public long getAggregateTarget() {
        return getModel().getAggregateTarget();
    }

    /** {@inheritDoc} */
    @Override
    public long getConsumedBytes() {
        return getModel().getConsumedBytes();
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        return getModel().toString();
    }
}
