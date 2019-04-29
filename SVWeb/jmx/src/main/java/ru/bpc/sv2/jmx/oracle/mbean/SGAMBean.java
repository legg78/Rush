/*
 * SGAMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.mbean;

import ru.bpc.sv2.jmx.mbean.DataItem;

import javax.management.MXBean;

/**
 * Information about the system global area (SGA) that is a group of shared memory structures
 * containing data and control information for one Oracle database instance.
 *
 * @author Ilya Yushin
 * @version $Id: 4c340905017a9952d30d005728c82cff04479dea $
 */
@MXBean
public interface SGAMBean {
    /**
     * Size of memory allocated for the REDO log buffer.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getLogBufferSize();

    /**
     * Size in bytes of general information about the state of the database and the instance.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getFixedSgaSize();

    /**
     * Size of the buffer cache in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getBufferCacheSize();

    /**
     * Free memory of shared pool in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getSharedPoolFreeSize();

    /**
     * Memory allocated for the rest of shared pool components (excluding library cache, dictionary
     * cache, free memory and SQL area).
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getSharedPoolSize();

    /**
     * Size of memory allocated for SQL areas.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getSqlAreaSize();

    /**
     * Size of memory allocated for library cache in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getLibraryCacheSize();

    /**
     * Size of memory allocated for data dictionary in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getDictionaryCacheSize();

    /**
     * Free memory of large pool in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getLargePoolFreeSize();

    /**
     * Size of Java pool large in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getLargePoolSize();

    /**
     * Free memory of Java pool in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getJavaPoolFreeSize();

    /**
     * Size of Java pool memory in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getJavaPoolSize();
}
