package ru.bpc.sv2.jmx.utils;

import org.springframework.stereotype.Service;

@Service
public abstract class MonitoringSettings {
    public static final String PORT = "JMX_MONITORING_PORT";
    public static final String DELAY = "JMX_MONITORING_DELAY";
    public static final String POOL_SIZE = "JMX_MONITORING_POOL_SIZE";

    public static final String SVBO_ON = "JMX_MONITORING_SVBO_ON";
    public static final String SVBO_DOMAIN = "JMX_MONITORING_SVBO_DOMAIN";

    public static final String ORACLE_ON = "JMX_MONITORING_ORACLE_ON";
    public static final String ORACLE_DOMAIN = "JMX_MONITORING_ORACLE_DOMAIN";

    protected abstract Object get(String name);

    public int getInteger(String name, int defaultValue) {
        Object value = get(name);
        if (value == null) return defaultValue;
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }

        if (value instanceof String) {
            if ("".equals(value)) return defaultValue;
            return Integer.valueOf((String) value);
        }

        return defaultValue;
    }

    public int getInteger(String name) {
        return getInteger(name, 0);
    }

    public String getString(String name, String defaultValue) {
        Object value = get(name);
        if (value == null) return defaultValue;
        return value.toString();
    }
    public String getString(String name) {
        return getString(name, null);
    }

    public boolean getBoolean(String name) {
        return getInteger(name) == 1;
    }
}
