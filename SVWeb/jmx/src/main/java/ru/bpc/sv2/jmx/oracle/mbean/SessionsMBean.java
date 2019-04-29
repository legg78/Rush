/*
 * SessionsMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.mbean;

import javax.management.MXBean;

/**
 * Session metrics from V$SESSION.
 *
 * @author Ilya Yushin
 * @version $Id: b27836b1b327cfba21912d22ed85d8ce5fc055ba $
 */
@MXBean
public interface SessionsMBean {
    /**
     * Number of the all sessions.
     *
     * @return a int.
     */
    int getTotal();

    /**
     * The maximum number of sessions that can be created in the system.
     *
     * @return a int.
     */
    int getMax();

    /**
     * Number of the currently active user sessions.
     *
     * @return a int.
     */
    int getActive();

    /**
     * Number of the currently inactive user sessions.
     *
     * @return a int.
     */
    int getInactive();

    /**
     * Number of the currently active system sessions.
     *
     * @return a int.
     */
    int getSystem();

    /**
     * Number of active user connections.
     *
     * @return a int.
     */
    int getConnectedUsers();
}
