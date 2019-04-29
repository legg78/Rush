/*
 * LibraryCacheMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.services;

import ru.bpc.sv2.jmx.oracle.mbean.LibraryCacheMBean;
import ru.bpc.sv2.jmx.oracle.model.LibraryCacheModel;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * <p>LibraryCacheMonitor class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 86b505120d045757e6e8567cb6033f7cfa8abede $
 */
public class LibraryCacheMonitor extends OracleBaseMBeanMonitor<LibraryCacheModel> implements
    LibraryCacheMBean {

    private final String query;

    /**
     * <p>Constructor for LibraryCacheMonitor.</p>
     */
    public LibraryCacheMonitor() {
        super(LibraryCacheMBean.class, "libraryCache");
        query = "select * from jmx_ui_oracle_library_cache_vw";
    }


    /** {@inheritDoc} */
    @Override
    protected final String getMBeanName() {
        return "LibraryCache";
    }

    /** {@inheritDoc} */
    @Override
    protected final LibraryCacheModel getNull() {
        return LibraryCacheModel.NULL;
    }

    /** {@inheritDoc} */
    @Override
    protected LibraryCacheModel queryValue(Connection conn, Statement stmt) throws SQLException {
        try (ResultSet rs = stmt.executeQuery(query)) {
            if (!rs.next()) {
                return null;
            }

            return new LibraryCacheModel( //
                rs.getFloat("hitratio_body"), //
                rs.getFloat("hitratio_table_proc"), //
                rs.getFloat("hitratio_trigger"), //
                rs.getFloat("hitratio_sqlarea"), //
                rs.getFloat("pinhitratio_body"), //
                rs.getFloat("pinhitratio_table_proc"), //
                rs.getFloat("pinhitratio_trigger"), //
                rs.getFloat("pinhitratio_sqlarea"));
        }
    }

    /** {@inheritDoc} */
    @Override
    public float getHitratioBody() {
        return getModel().getHitratioBody();
    }

    /** {@inheritDoc} */
    @Override
    public float getHitratioTableProcedures() {
        return getModel().getHitratioTableProcedures();
    }

    /** {@inheritDoc} */
    @Override
    public float getHitratioTrigger() {
        return getModel().getHitratioTrigger();
    }

    /** {@inheritDoc} */
    @Override
    public float getHitratioSqlArea() {
        return getModel().getHitratioSqlArea();
    }

    /** {@inheritDoc} */
    @Override
    public float getPinHitratioBody() {
        return getModel().getPinHitratioBody();
    }

    /** {@inheritDoc} */
    @Override
    public float getPinHitratioTableProcedures() {
        return getModel().getPinHitratioTableProcedures();
    }

    /** {@inheritDoc} */
    @Override
    public float getPinHitratioTrigger() {
        return getModel().getPinHitratioTrigger();
    }

    /** {@inheritDoc} */
    @Override
    public float getPinHitratioSqlArea() {
        return getModel().getPinHitratioSqlArea();
    }
}
