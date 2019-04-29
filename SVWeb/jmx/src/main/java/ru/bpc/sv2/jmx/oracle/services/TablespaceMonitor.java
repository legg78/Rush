/*
 * TablespaceMonitor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.services;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.support.JdbcUtils;
import org.springframework.jmx.export.MBeanExporter;
import org.springframework.stereotype.Service;
import ru.bpc.sv2.jmx.MonitoringException;
import ru.bpc.sv2.jmx.mbean.BaseMBean;
import ru.bpc.sv2.jmx.oracle.mbean.Tablespace;
import ru.bpc.sv2.jmx.oracle.mbean.TablespaceMBean.Contents;
import ru.bpc.sv2.jmx.oracle.mbean.TablespaceMBean.Status;
import ru.bpc.sv2.jmx.oracle.mbean.TablespacesMBean;
import ru.bpc.sv2.jmx.oracle.model.TablespaceModel;
import ru.bpc.sv2.jmx.oracle.utils.Bundles;
import ru.bpc.sv2.jmx.utils.JSON;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.management.ObjectName;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

/**
 * <p>
 * TablespaceMonitor class.
 * </p>
 *
 * @author Ilya Yushin
 * @version $Id: 0f91ada5c0848a0c6e2515632e51a6b06d0aba5c $
 */
@Service
public class TablespaceMonitor extends BaseMBean implements TablespacesMBean, OracleMonitor {
    private static final Logger log = LoggerFactory.getLogger("MONITORING");

    /** Constant <code>MBEAN_SECTION="Tablespaces"</code> */
    public static final String MBEAN_SECTION = "Tablespaces";

    @Autowired
    private MBeanExporter exporter;
    @Autowired
    private DataSource dataSource;
    @Autowired
    private OracleBeanNamingService namingService;

    private final Map<String, Tablespace> tablespaces = new LinkedHashMap<>();
    private final String query;

    private int errors = 0;
    private String discoveryValue;

    /**
     * <p>
     * Constructor for TablespaceMonitor.
     * </p>
     */
    public TablespaceMonitor() {
        super(Bundles.getDescriptionBundle(), TablespacesMBean.class, "tablespaces");
        query = "select * from jmx_ui_oracle_tablespaces_vw";
    }

    /**
     * <p>
     * postConstruct.
     * </p>
     */
    @PostConstruct
    public void postConstruct() {
        try {
            final ObjectName name = namingService.getName(MBEAN_SECTION);
            exporter.registerManagedResource(this, name);

        } catch (final MonitoringException e) {
            log.warn("Couldn't register discovery MBean.", e);
        }
    }

    /**
     * <p>
     * preDestroy.
     * </p>
     */
    @PreDestroy
    public void preDestroy() {
        final Map<String, Tablespace> tmp = new HashMap<>(tablespaces);
        tablespaces.clear();
        unregisterMBeans(tmp);
    }

    /** {@inheritDoc} */
    @Override
    public String getDiscoveryValue() {
        return discoveryValue;
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
    public void requestInformation() {
        log.trace("Tablespaces, updating...");

        Connection conn = null;
        PreparedStatement stmt = null;
        try {
            conn = dataSource.getConnection();
            stmt = conn.prepareStatement(query);

            final Map<String, Tablespace> beans = new HashMap<>(tablespaces);
            boolean updateDiscovery = false;
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    final TablespaceModel model = mapBean(rs);
                    final String modelName = model.getTablespaceName();

                    Tablespace bean = beans.remove(modelName);
                    if (bean != null) {
                        bean.updateModel(model);
                    } else {
                        bean = new Tablespace(model);
                        tablespaces.put(modelName, bean);

                        try {
                            final ObjectName name = namingService.getName(MBEAN_SECTION, modelName);
                            exporter.registerManagedResource(bean, name);
                            updateDiscovery = true;

                            log.info("Added bean '{}'.", name.toString());

                        } catch (final MonitoringException e) {
                            log.error("Couldn't register MBean for tablespace.", e);
                        }
                    }
                }
            }

            if (!beans.isEmpty()) {
                updateDiscovery = true;
                unregisterMBeans(beans);
            }

            if (updateDiscovery || StringUtils.isEmpty(discoveryValue)) {
                discoveryValue = prepareDiscoveryValue();
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

    private String prepareDiscoveryValue() {
        log.trace("Tablespaces discovery, updating...");

        final List<Object> entries = new ArrayList<>(tablespaces.size());
        for (final String name : tablespaces.keySet()) {
            try {
                final Map<String, String> entry = new LinkedHashMap<>();
                entry.put("{#JMX.NAME}", name);
                entry.put("{#JMX.PATH}", namingService.getName(MBEAN_SECTION, name).toString());
                entries.add(entry);

            } catch (final Exception e) {
                log.warn("Couldn't prepare discovery data for " + name + ".", e);
            }
        }

        final String value = JSON.toJsonString(Collections.singletonMap("data", entries));
        log.info("Tablespaces discovery: {}.", value);
        return value;
    }

    private TablespaceModel mapBean(ResultSet rs) throws SQLException {
        final String tablespaceName;
        try {
            tablespaceName = rs.getString("tablespace_name");
        } catch (final SQLException e) {
            log.error("Couldn't extract tablespace name from ResultSet.", e);
            throw e;
        }

        try {
            Contents contents = Contents.Undefined;
            final String contentsText = rs.getString("contents");
            if (!StringUtils.isEmpty(contentsText)) {
                for (final Contents tag : Contents.values()) {
                    if (StringUtils.equalsIgnoreCase(tag.name(), contentsText)) {
                        contents = tag;
                        break;
                    }
                }
            }

            Status status = Status.Undefined;
            final String statusText = rs.getString("status");
            if (!StringUtils.isEmpty(statusText)) {
                for (final Status tag : Status.values()) {
                    if (StringUtils.equalsIgnoreCase(tag.name(), statusText)) {
                        status = tag;
                        break;
                    }
                }
            }

            return new TablespaceModel( //
                tablespaceName, //
                contents, //
                status, //
                rs.getInt("files_count"), //
                rs.getLong("block_size"), //
                rs.getLong("initial_extent"), //
                rs.getLong("next_extent"), //
                rs.getLong("min_extents"), //
                rs.getLong("max_extents"), //
                rs.getInt("pct_increase"), //
                rs.getLong("used_bytes"), //
                rs.getLong("actual_bytes"), //
                rs.getLong("max_bytes"), //
                rs.getLong("free_bytes"));
        } catch (final SQLException e) {
            log.error(String.format("Couldn't extract data from ResultSet for '%s'.",
                tablespaceName), e);
            throw e;
        }
    }

    private void unregisterMBeans(final Map<String, Tablespace> beans) {
        for (final Tablespace bean : beans.values()) {
            try {
                final ObjectName name = namingService.getName(MBEAN_SECTION, bean.getName());
                exporter.unregisterManagedResource(name);

                log.info("Removed bean '{}'.", name.toString());

            } catch (final MonitoringException e) {
                log.warn(String.format("Couldn't unregister MBean '%s'.", bean), e);
            }
        }
    }
}
