/*
 * DatabaseMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.mbean;

import ru.bpc.sv2.jmx.mbean.DataItem;

import javax.management.MXBean;

/**
 * <p>DatabaseMBean interface.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 3d338e952679c181c3492fd51a44390aa4286cd2 $
 */
@MXBean
public interface DatabaseMBean {
    /**
     * Identifies Oracle database software release.
     *
     * @return a {@link String} object.
     */
    String getVersion();

    /**
     * Database uptime in seconds.
     *
     * @return a long.
     */
    @DataItem(units = "seconds")
    long getUptime();

    /**
     * Database size including data files, REDO log files, control files and temporary files.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getDatabaseSize();

    /**
     * Database files size including data files and temporary files.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getFileSize();

    /**
     * Archive log production for trend analysis.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getArchiveLog();

    /**
     * Number of times the latch was requested in willing-to-wait mode and the requester had to
     * wait.
     *
     * @return a long.
     */
    long getLatchMisses();
}
