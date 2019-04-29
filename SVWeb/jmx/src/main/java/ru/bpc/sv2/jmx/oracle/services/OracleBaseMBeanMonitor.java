/*
 * BaseMBeanMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.services;

import ru.bpc.sv2.jmx.MonitoringException;
import ru.bpc.sv2.jmx.mbean.BaseMBean;
import ru.bpc.sv2.jmx.oracle.utils.Bundles;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.support.JdbcUtils;
import org.springframework.jmx.export.MBeanExporter;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.management.ObjectName;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.concurrent.atomic.AtomicReference;

/**
 * <p>
 * Abstract BaseMBeanMonitor class.
 * </p>
 *
 * @author Ilya Yushin
 * @version $Id: 3e3f1574d12a2efc89ff18c70cce5b542851f3b8 $
 */
@Service
public abstract class OracleBaseMBeanMonitor<BeanModel> extends BaseMBean implements OracleMonitor {
    private static final Logger log = LoggerFactory.getLogger("MONITORING");

    @Autowired
    private MBeanExporter exporter;
    @Autowired
    private DataSource dataSource;
    @Autowired
    private OracleBeanNamingService namingService;

    private final AtomicReference<BeanModel> model;
    private int errors = 0;

    /**
     * <p>
     * Constructor for BaseMBeanMonitor.
     * </p>
     *
     * @param mbeanInterface a {@link Class} object.
     * @param beanKey a {@link String} object.
     */
    protected OracleBaseMBeanMonitor(Class<?> mbeanInterface, String beanKey) {
        super(Bundles.getDescriptionBundle(), mbeanInterface, beanKey);
        model = new AtomicReference<>(getNull());
    }

    /**
     * <p>
     * Getter for the field <code>model</code>.
     * </p>
     *
     * @return a BeanModel object.
     */
    protected final BeanModel getModel() {
        return model.get();
    }

    /**
     * <p>
     * postConstruct.
     * </p>
     */
    @PostConstruct
    public void postConstruct() {
        try {
            final ObjectName name = namingService.getName(getMBeanName());
            exporter.registerManagedResource(this, name);

            log.info("Added bean '{}'.", name.toString());

        } catch (final MonitoringException e) {
            log.warn(String.format("Couldn't register MBean '%s'.", getMBeanName()), e);
        }
    }

    /**
     * <p>
     * preDestroy.
     * </p>
     */
    @PreDestroy
    public void preDestroy() {
        try {
            final ObjectName name = namingService.getName(getMBeanName());
            exporter.unregisterManagedResource(name);

            log.info("Removed bean '{}'.", name.toString());

        } catch (final MonitoringException e) {
            log.warn(String.format("Couldn't unregister MBean '%s'.", getMBeanName()), e);
        }
    }

    @Override
    public void run() {
        requestInformation();
    }

    /**
     * <p>
     * requestInformation.
     * </p>
     */
    protected void requestInformation() {
        log.trace("{}, updating...", getMBeanName());

        Connection conn = null;
        Statement stmt = null;
        try {
            conn = dataSource.getConnection();
            stmt = conn.createStatement();

            final BeanModel model = queryValue(conn, stmt);
            if (model != null) {
                log.trace("MBean '{}' successfully updated: {}.", getMBeanName(), model);
                this.model.set(model);
            } else {
                log.warn("Query for MBean '{}' returned empty result.", getMBeanName());
                this.model.set(getNull());
            }

            if (errors > 0) {
                errors = 0;
                log.info("Database connection restored.");
            }

        } catch (final SQLException e) {
            if (errors++ == 0) {
                log.warn("Database connection lost.", e);
            }

        } finally {
            JdbcUtils.closeStatement(stmt);
            JdbcUtils.closeConnection(conn);
        }
    }

    /**
     * <p>
     * queryValue.
     * </p>
     *
     * @param conn a {@link Connection} object.
     * @param stmt a {@link Statement} object.
     * @return a BeanModel object.
     * @throws SQLException if any.
     */
    protected abstract BeanModel queryValue(Connection conn, Statement stmt) throws SQLException;

    /**
     * <p>
     * getMBeanName.
     * </p>
     *
     * @return a {@link String} object.
     */
    protected abstract String getMBeanName();

    /**
     * <p>
     * getNull.
     * </p>
     *
     * @return a BeanModel object.
     */
    protected abstract BeanModel getNull();
}
