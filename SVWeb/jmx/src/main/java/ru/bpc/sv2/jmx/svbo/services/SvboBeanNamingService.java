/*
 * BeanNamingService.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.services;

import javax.annotation.PostConstruct;
import javax.management.MalformedObjectNameException;
import javax.management.ObjectName;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import ru.bpc.sv2.jmx.MonitoringException;
import ru.bpc.sv2.jmx.utils.MonitoringSettings;

/**
 * <p>
 * BeanNamingService class.
 * </p>
 *
 * @author Ilya Yushin
 * @version $Id: f4f717713e7b2b28dfbc2048ba01be526ab20fe2 $
 */
@Service
public class SvboBeanNamingService {
    private static final Logger log = LoggerFactory.getLogger("MONITORING");

    @Autowired
    private MonitoringSettings settings;

    /**
     * <p>
     * postConstruct.
     * </p>
     */
    @PostConstruct
    public void postConstruct() {
        final StringBuilder prefix = new StringBuilder();
        prefix.append(getDomain()).append(':');
        log.debug("MBean naming prefix: {}.", prefix);
    }

    /**
     * <p>getName.</p>
     *
     * @param type a {@link java.lang.String} object.
     * @return a {@link javax.management.ObjectName} object.
     * @throws ru.bpc.sv2.jmx.MonitoringException if any.
     */
    public ObjectName getName(String type) throws MonitoringException {
        return createName(String.format("%s:type=%s", getDomain(), type));
    }

    /**
     * <p>
     * getName.
     * </p>
     *
     * @param type a {@link java.lang.String} object.
     * @param name a {@link java.lang.String} object.
     * @return a {@link javax.management.ObjectName} object.
     * @throws ru.bpc.sv2.jmx.MonitoringException if any.
     */
    public ObjectName getName(String type, String name) throws MonitoringException {
        return createName(String.format("%s:type=%s,name=%s", getDomain(), type, name == null ? null : name.replaceAll("[[=:\"\n]]", "")));
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
        return settings.getString(MonitoringSettings.SVBO_DOMAIN, "com.bpcbt.svbo");
    }
}
