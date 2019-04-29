/*
 * TablespaceMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.mbean;

import ru.bpc.sv2.jmx.mbean.DataItem;

import javax.management.MXBean;

/**
 * Keeps information and statistics data about a particular tablespace.
 *
 * @author Ilya Yushin
 * @version $Id: e4b1e9d92039475d7d699a270bcb65b2c8ebf703 $
 */
@MXBean
public interface TablespaceMBean {
    public enum Contents {
        Permanent, Temporary, Undo, Undefined
    }

    public enum Status {
        Online, Offline, ReadOnly, Undefined
    }

    //
    // Configuration data:
    //

    /**
     * Tablespace name.
     *
     * @return a {@link String} object.
     */
    String getName();

    /**
     * Tablespace status.
     *
     * @return a {@link ru.bpc.sv2.jmx.oracle.mbean.TablespaceMBean.Status} object.
     */
    Status getStatus();

    /**
     * Tablespace block size.
     *
     * @return a {@link ru.bpc.sv2.jmx.oracle.mbean.TablespaceMBean.Contents} object.
     */
    Contents getContents();

    /**
     * Number of data files allocated for tablespace.
     *
     * @return a int.
     */
    int getFilesCount();

    /**
     * Tablespace block size.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getBlockSize();

    /**
     * Default initial extent size.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getInitialExtent();

    /**
     * Default incremental extent size.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getNextExtent();

    /**
     * Default minimum number of extents.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getMaxExtents();

    /**
     * Default minimum number of extents.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getMinExtents();

    /**
     * Default percent increase for extent size.
     *
     * @return a int.
     */
    @DataItem(units = "%")
    int getPercentInscrease();

    /**
     * Maximum auto-extensible size of all data files in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getMaxBytes();

    /**
     * Size of all data files in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getActualBytes();

    /**
     * Size of tablespace data in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getUsedBytes();

    /**
     * Size of all free extents in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getFreeBytes();

    /**
     * Total remaining space in bytes.
     *
     * @return a long.
     */
    @DataItem(units = "bytes")
    long getSpaceBytes();

    /**
     * Tablespace utilization percent.
     *
     * @return a int.
     */
    @DataItem(units = "%")
    int getUsage();
}
