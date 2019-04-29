/*
 * DatabaseMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.services;

import ru.bpc.sv2.jmx.oracle.mbean.SessionsMBean;
import ru.bpc.sv2.jmx.oracle.model.SessionsModel;
import org.springframework.stereotype.Service;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * <p>SessionMonitor class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: ecdd7103e4b9a9640ce7660c9b344c07dd0fa64b $
 */
@Service
public class SessionMonitor extends OracleBaseMBeanMonitor<SessionsModel> implements SessionsMBean {
    private final String queryLimit, queryStats;

    /**
     * <p>Constructor for SessionMonitor.</p>
     */
    public SessionMonitor() {
        super(SessionsMBean.class, "sessions");
        queryStats = "select * from jmx_ui_oracle_sessions_vw";
        queryLimit = "select * from jmx_ui_oracle_session_limit_vw";
    }


    /** {@inheritDoc} */
    @Override
    protected SessionsModel queryValue(Connection conn, Statement stmt) throws SQLException {
        final int max;
        try (ResultSet rs = stmt.executeQuery(queryLimit)) {
            if (!rs.next()) {
                return null;
            }

            max = rs.getInt("session_max");
        }

        final int total, active, inactive, system, userConnected;
        try (ResultSet rs = stmt.executeQuery(queryStats)) {
            if (!rs.next()) {
                return null;
            }
            total = rs.getInt("session_count");
            active = rs.getInt("session_active");
            inactive = rs.getInt("session_inactive");
            system = rs.getInt("session_system");
            userConnected = rs.getInt("session_user_connected");
        }

        return new SessionsModel(total, max, active, inactive, system, userConnected);
    }

    /** {@inheritDoc} */
    @Override
    protected SessionsModel getNull() {
        return SessionsModel.NULL;
    }

    /** {@inheritDoc} */
    @Override
    protected String getMBeanName() {
        return "Sessions";
    }

    /** {@inheritDoc} */
    @Override
    public int getTotal() {
        return getModel().getTotal();
    }

    /** {@inheritDoc} */
    @Override
    public int getMax() {
        return getModel().getMax();
    }

    /** {@inheritDoc} */
    @Override
    public int getActive() {
        return getModel().getActive();
    }

    /** {@inheritDoc} */
    @Override
    public int getInactive() {
        return getModel().getInactive();
    }

    /** {@inheritDoc} */
    @Override
    public int getSystem() {
        return getModel().getSystem();
    }

    /** {@inheritDoc} */
    @Override
    public int getConnectedUsers() {
        return getModel().getConnectedUsers();
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        return getModel().toString();
    }
}
