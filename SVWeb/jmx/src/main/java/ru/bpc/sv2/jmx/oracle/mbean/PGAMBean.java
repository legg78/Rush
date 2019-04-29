/*
 * SGAMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.mbean;

import ru.bpc.sv2.jmx.mbean.DataItem;

import javax.management.MXBean;

/**
 * PGA memory usage statistics from V$PGASTAT.
 *
 * @author Ilya Yushin
 * @version $Id: 68656bab29409c8a07a6761da4d8cc3517f02c1a $
 */
@MXBean
public interface PGAMBean {
    /**
     * Current value of the PGA_AGGREGATE_TARGET initialization parameter.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getAggregateTarget();

    /**
     * Indicates how much PGA memory is currently consumed by work areas.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getConsumedBytes();
}
