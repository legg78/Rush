/*
 * SvboContainerMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.mbean;

import java.util.Date;

import javax.management.MXBean;

import ru.bpc.sv2.jmx.mbean.DataItem;

/**
 * MBean specification for process status.
 *
 * @author Ilya Yushin
 * @version $Id: ff19a4c0162f099f8aabca9c3e797eee9595c948 $
 */
@MXBean
public interface SvboProcessMBean {
    /**
     * Identifiers of relation to parent container.
     *
     * @return a long.
     */
    long getId();

    /**
     * Process identifier.
     *
     * @return a long.
     */
    long getProcessId();

    /**
     * Root container identifier.
     *
     * @return a long.
     */
    long getContainerId();

    /**
     * Symbolic name of the process.
     *
     * @return a {@link java.lang.String} object.
     */
    String getName();

    /**
     * Returns state of the last process launch.
     *
     * @return process launch state
     */
    String getState();

    /**
     * Returns date and time of the last process session finish.
     *
     * @return process finish date
     */
    Date getFinishTime();

    /**
     * Returns date and time of the last process session start.
     *
     * @return process execution date
     */
    Date getStartTime();

    /**
     * Percent of remaining task.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getRemaining();

    /**
     * Percent of complete task.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getProgress();

    /**
     * Number of excepted records.
     *
     * @return a long.
     */
    @DataItem(units = "rows")
    long getExcepted();

    /**
     * Number of rejected (ignored) records.
     *
     * @return a long.
     */
    @DataItem(units = "rows")
    long getRejected();

    /**
     * Total number of processed records.
     *
     * @return a long.
     */
    @DataItem(units = "rows")
    long getProcessed();
}
