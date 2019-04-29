/*
 * ProcessesMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.mbean;

import javax.management.MXBean;

/**
 * Process statistics from V$PROCESS.
 *
 * @author Ilya Yushin
 * @version $Id: 6c05624920791c81a213a2daab56d7a9bdce137a $
 */
@MXBean
public interface ProcessesMBean {
    /**
     * Number of the currently active processes.
     *
     * @return a int.
     */
    int getCount();

    /**
     * Maximum number of operating system processes that can simultaneously connect to Oracle.
     *
     * @return a int.
     */
    int getMax();
}
