/*
 * SystemIOMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.mbean;

import ru.bpc.sv2.jmx.mbean.DataItem;

import javax.management.MXBean;

/**
 * Statistic metrics from V$SYSSTAT which is related with input/output operations with the data
 * blocks
 *
 * @author Ilya Yushin
 * @version $Id: 862c56f6338008ac319ee087a5b76624f73c7be3 $
 */
@MXBean
public interface SystemIOMBean {
    /**
     * Total number of data blocks read from disk into buffer cache.
     *
     * @return a long.
     */
    @DataItem(units = "op")
    long getPhysicalReads();

    /**
     * Number of reads directly from disk, bypassing the buffer cache.
     *
     * @return a long.
     */
    @DataItem(units = "op")
    long getDatafileReads();

    /**
     * Number of writes directly to disk, bypassing the buffer cache (as in a direct load
     * operation).
     *
     * @return a long.
     */
    @DataItem(units = "op")
    long getDatafileWrites();

    /**
     * Total number of writes by LGWR to the REDO log files.
     *
     * @return a long.
     */
    @DataItem(units = "op")
    long getRedoWrites();

    /**
     * Number of times a CURRENT block was requested.
     *
     * @return a long.
     */
    @DataItem(units = "op")
    long getBlockGets();

    /**
     * Number of consistent gets that require both block rollbacks and block cleanouts.
     *
     * @return a long.
     */
    @DataItem(units = "op")
    long getConsistentGets();

    /**
     * Get the buffer cache hit ratio that is how often a requested block has been found in the
     * buffer cache without requiring disk access.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getHitRatio();

    /**
     * Get statistic that counts the total number of changes that were part of an update or delete
     * operation that were made to all blocks in the SGA.
     *
     * @return a long.
     */
    @DataItem(units = "op")
    long getBlockChanges();

    /**
     * Percent of tables that do not meet the short table criteria and cannot be defined by
     * optimizer hints.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getNotIndexedSqlRatio();
}
