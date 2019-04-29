/*
 * DatabaseMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.services;

import ru.bpc.sv2.jmx.oracle.mbean.SGAMBean;
import ru.bpc.sv2.jmx.oracle.model.SGAModel;
import org.springframework.stereotype.Service;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * <p>SGAMonitor class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: e4209285f1ee3ea68fb33c00b3446b275c4c4172 $
 */
@Service
public class SGAMonitor extends OracleBaseMBeanMonitor<SGAModel> implements SGAMBean {
    private final String query;

    /**
     * <p>Constructor for SGAMonitor.</p>
     */
    public SGAMonitor() {
        super(SGAMBean.class, "sga");
        query = "select * from jmx_ui_oracle_sga_vw";
    }


    /** {@inheritDoc} */
    @Override
    protected SGAModel queryValue(Connection conn, Statement stmt) throws SQLException {
        try (ResultSet rs = stmt.executeQuery(query)) {
            if (!rs.next()) {
                return null;
            }

            return new SGAModel(//
                rs.getLong("java_pool_size"), //
                rs.getLong("java_pool_free_size"), //
                rs.getLong("large_pool_size"), //
                rs.getLong("large_pool_free_size"), //
                rs.getLong("dictionary_cache_size"), //
                rs.getLong("library_cache_size"), //
                rs.getLong("sql_area_size"), //
                rs.getLong("shared_pool_size"), //
                rs.getLong("shared_pool_free_size"), //
                rs.getLong("buffer_cache_size"), //
                rs.getLong("fixed_sga_size"), //
                rs.getLong("log_buffer_size"));
        }
    }

    /** {@inheritDoc} */
    @Override
    protected SGAModel getNull() {
        return SGAModel.NULL;
    }

    /** {@inheritDoc} */
    @Override
    protected String getMBeanName() {
        return "SGA";
    }

    /** {@inheritDoc} */
    @Override
    public long getJavaPoolSize() {
        return getModel().getJavaPoolSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getJavaPoolFreeSize() {
        return getModel().getJavaPoolFreeSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getLargePoolSize() {
        return getModel().getLargePoolSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getLargePoolFreeSize() {
        return getModel().getLargePoolFreeSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getDictionaryCacheSize() {
        return getModel().getDictionaryCacheSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getLibraryCacheSize() {
        return getModel().getLibraryCacheSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getSqlAreaSize() {
        return getModel().getSqlAreaSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getSharedPoolSize() {
        return getModel().getSharedPoolSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getSharedPoolFreeSize() {
        return getModel().getSharedPoolFreeSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getBufferCacheSize() {
        return getModel().getBufferCacheSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getFixedSgaSize() {
        return getModel().getFixedSgaSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getLogBufferSize() {
        return getModel().getLogBufferSize();
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        return getModel().toString();
    }
}
