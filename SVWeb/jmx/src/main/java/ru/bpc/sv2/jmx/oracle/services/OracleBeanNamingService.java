/*
 * BeanNamingService.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.services;

import org.springframework.beans.factory.annotation.Autowired;
import ru.bpc.sv2.jmx.MonitoringException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;
import ru.bpc.sv2.jmx.utils.MonitoringSettings;

import javax.annotation.PostConstruct;
import javax.management.MalformedObjectNameException;
import javax.management.ObjectName;

/**
 * <p>BeanNamingService class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 026ecdc2e557827351ad6a80958b95dad0e18dda $
 */
@Service
public class OracleBeanNamingService {
    private static final Logger log = LoggerFactory.getLogger("MONITORING");

    @Autowired
    private MonitoringSettings settings;

    private String datasourceUrl = "OracleDatabase";

    private String prefix;

    /**
     * <p>postConstruct.</p>
     */
    @PostConstruct
    public void postConstruct() {
        Assert.hasText(datasourceUrl, "Datasource URL is null.");

        final StringBuilder prefix = new StringBuilder();
        prefix.append(getDomain()).append(':');
        prefix.append("database=").append(datasourceUrl);
        this.prefix = prefix.toString();

        log.debug("MBean naming prefix: {}.", prefix);
    }

    private static String extractAddress(String url) {
        final int adressPos = url.indexOf('@');
        if (adressPos > 0 && adressPos < url.length() - 1) {
            return url.substring(adressPos + 1);
        }
        return url;
    }

    /**
     * <p>getName.</p>
     *
     * @param resource a {@link String} object.
     * @return a {@link ObjectName} object.
     * @throws ru.bpc.sv2.jmx.MonitoringException if any.
     */
    public ObjectName getName(String resource) throws MonitoringException {
        return createName(String.format("%s,resource=%s", prefix, resource));
    }

    /**
     * <p>getName.</p>
     *
     * @param resource a {@link String} object.
     * @param instance a {@link String} object.
     * @return a {@link ObjectName} object.
     * @throws ru.bpc.sv2.jmx.MonitoringException if any.
     */
    public ObjectName getName(String resource, String instance) throws MonitoringException {
        return createName(String.format("%s,resource=%s,instance=%s", prefix, resource, instance));
    }

    private static ObjectName createName(String nameText) throws MonitoringException {
        try {
            return new ObjectName(nameText);
        } catch (final MalformedObjectNameException e) {
            final String message = String.format("Couldn't create ObjectName for %s.", nameText);
            throw new MonitoringException(message, e);
        }
    }
    public String getDomain() {
        return settings.getString(MonitoringSettings.ORACLE_DOMAIN, "com.bpcbt.monitoring");
    }
}
