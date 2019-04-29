/*
 * SvboMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.services;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.management.ObjectName;
import javax.sql.DataSource;

import org.apache.commons.collections4.map.HashedMap;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.support.JdbcUtils;
import org.springframework.jmx.export.MBeanExporter;
import org.springframework.stereotype.Service;

import ru.bpc.sv2.jmx.MonitoringException;
import ru.bpc.sv2.jmx.mbean.BaseMBean;
import ru.bpc.sv2.jmx.svbo.mbean.SvboDiscoveryMBean;
import ru.bpc.sv2.jmx.svbo.mbean.SvboEntityMBean;
import ru.bpc.sv2.jmx.svbo.model.SvboEntityModel;
import ru.bpc.sv2.jmx.svbo.utils.Bundles;
import ru.bpc.sv2.jmx.utils.JSON;

/**
 * <p>
 * Abstract SvboMonitor class.
 * </p>
 *
 * @author Ilya Yushin
 * @version $Id: 52528086ccf0a260a1e1a01e4e9207aca7e8783c $
 */
@Service
public abstract class SvboMonitor<BeanModel extends SvboEntityModel, Bean extends SvboEntityMBean<BeanModel>>
    extends BaseMBean implements SvboDiscoveryMBean, Runnable {

    private static final Logger log = LoggerFactory.getLogger("MONITORING");

    private final AtomicReference<String> discoveryValue = new AtomicReference<>();
    private final Map<Object, Bean> beans = new HashedMap<>();

    @Autowired
    private DataSource dataSource;
    @Autowired
    private MBeanExporter exporter;
    @Autowired
    private SvboBeanNamingService naming;

    private int errors = 0;

    /**
     * <p>
     * Constructor for SvboMonitor.
     * </p>
     *
     * @param beanKey a {@link java.lang.String} object.
     */
    protected SvboMonitor(String beanKey) {
        super(Bundles.getDescriptionBundle(), SvboDiscoveryMBean.class, beanKey);
    }

    /**
     * <p>
     * postConstruct.
     * </p>
     */
    @PostConstruct
    public void postConstruct() {
        try {
            final ObjectName name = naming.getName(entityType());
            exporter.registerManagedResource(this, name);

            log.info("Added bean '{}'.", name.toString());

        } catch (final MonitoringException e) {
            log.warn(String.format("Couldn't register MBean '%s'.", entityType()), e);
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
            final ObjectName name = naming.getName(entityType());
            exporter.unregisterManagedResource(name);

            log.info("Removed bean '{}'.", name.toString());

        } catch (final MonitoringException e) {
            log.warn(String.format("Couldn't unregister MBean '%s'.", entityType()), e);
        }
    }

    @Override
    public void run() {
        requestInformation();
    }

    /**
     * {@inheritDoc}}
     */
    @Override
    public String getDiscoveryValue() {
        return StringUtils.defaultString(discoveryValue.get(), "");
    }

    /**
     * Retrieves status information for a target entity from the database.
     */
    protected void requestInformation() {
        log.trace("{}, updating...", entityType());

        Connection conn = null;
        PreparedStatement stmt = null;
        try {
            conn = dataSource.getConnection();
            stmt = prepareStatement(conn);

            final Map<Object, Bean> beans = new HashMap<>(this.beans);
            boolean updateDiscovery = false;
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    log.warn("Query for {} states returned empty result.", entityType());
                    return;
                }

                do {
                    final BeanModel model = mapBeanModel(rs);
                    if (model == null) {
                        continue;
                    }

                    Bean bean = beans.remove(model.getId());
                    if (bean != null) {
                        bean.updateModel(model);
                    } else {
                        bean = newBean(model);
                        this.beans.put(model.getId(), bean);

                        try {
                            final ObjectName name = naming.getName(entityType(), beanName(bean));
                            exporter.registerManagedResource(bean, name);
                            updateDiscovery = true;

                            log.info("Added bean '{}'.", name.toString());

                        } catch (final MonitoringException e) {
                            log.error("Couldn't register MBean.", e);
                        }
                    }

                } while (rs.next());
            }

            if (!beans.isEmpty()) {
                updateDiscovery = true;
                unregisterMBeans(beans);
            }

            if (updateDiscovery || StringUtils.isEmpty(discoveryValue.get())) {
                discoveryValue.set(prepareDiscoveryValue());
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

    private void unregisterMBeans(final Map<Object, Bean> beans) {
        for (final Bean bean : beans.values()) {
            try {
                final ObjectName name = naming.getName(entityType(), beanName(bean));
                exporter.unregisterManagedResource(name);

                log.info("Removed bean '{}'.", name.toString());

            } catch (final MonitoringException e) {
                log.warn(String.format("Couldn't unregister MBean '%s'.", bean), e);
            }
        }
    }

    private String prepareDiscoveryValue() {
        log.trace("{} discovery, updating...", entityType());

        final List<Object> entries = new ArrayList<>(beans.size());
        for (final Bean bean : beans.values()) {
            try {
                final Map<String, Object> entry = new LinkedHashMap<>();
                discoveryAttributes(bean, entry);
                entry.put(macroName("path"), naming.getName(entityType(), //
                    beanName(bean)).toString());
                entries.add(entry);
            } catch (final Exception e) {
                log.warn("Couldn't prepare discovery data for " + beanName(bean) + ".", e);
            }
        }

        final String value = JSON.toJsonString(Collections.singletonMap("data", entries));
        log.info("{} discovery: {}.", entityType(), value);
        return value;
    }

    /**
     * <p>
     * prepareStatement.
     * </p>
     *
     * @param conn a {@link java.sql.Connection} object.
     * @return a {@link java.sql.PreparedStatement} object.
     * @throws java.sql.SQLException if any.
     */
    protected abstract PreparedStatement prepareStatement(Connection conn) throws SQLException;

    /**
     * <p>
     * mapBeanModel.
     * </p>
     *
     * @param rs a {@link java.sql.ResultSet} object.
     * @return a BeanModel object.
     * @throws java.sql.SQLException if any.
     */
    protected abstract BeanModel mapBeanModel(ResultSet rs) throws SQLException;

    /**
     * <p>
     * discoveryAttributes.
     * </p>
     *
     * @param bean a Bean object.
     * @param destination a {@link java.util.Map} object.
     */
    protected abstract void discoveryAttributes(Bean bean, Map<String, Object> destination);

    /**
     * <p>
     * entityType.
     * </p>
     *
     * @return a {@link java.lang.String} object.
     */
    protected abstract String entityType();

    /**
     * <p>
     * newBean.
     * </p>
     *
     * @param model a BeanModel object.
     * @return a Bean object.
     */
    protected abstract Bean newBean(BeanModel model);

    /**
     * <p>
     * beanName.
     * </p>
     *
     * @param bean a Bean object.
     * @return a {@link java.lang.String} object.
     */
    protected abstract String beanName(Bean bean);

    /**
     * <p>
     * macroName.
     * </p>
     *
     * @param attribute a {@link java.lang.String} object.
     * @return a {@link java.lang.String} object.
     */
    protected abstract String macroName(String attribute);
}
