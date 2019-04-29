/*
 * MonitoringException.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx;

import java.io.Serializable;

/**
 * Exception thrown if some of the monitoring operations fails.
 *
 * @author Ilya Yushin
 * @version $Id: 2a48a89a1089c638358e603d7458b7facf298dd8 $
 */
public class MonitoringException extends Exception implements Serializable {
    private static final long serialVersionUID = -3423562310467100909L;

    /**
     * <p>Constructor for MonitoringException.</p>
     *
     * @param message a {@link java.lang.String} object.
     */
    public MonitoringException(String message) {
        super(message);
    }

    /**
     * <p>Constructor for MonitoringException.</p>
     *
     * @param message a {@link java.lang.String} object.
     * @param cause a {@link java.lang.Throwable} object.
     */
    public MonitoringException(String message, Throwable cause) {
        super(message, cause);
    }
}
