/*
 * WaitEventsMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.mbean;

/**
 * Wait events metrics from V$SYSTEM_EVENT.
 *
 * @author Ilya Yushin
 * @version $Id: 303a1d2469549f9c898d4aebb5d017327396bf3d $
 */
public interface WaitEventsMBean {
    /**
     * Number of events of identifying a file so that it can be opened later or opening the file.
     *
     * @return a long.
     */
    long getFileIO();

    /**
     * Number of control file reads and writes.
     *
     * @return a long.
     */
    long getControlFileIO();

    /**
     * Number of outstanding asynchronous I/O awating to be completed to disk.
     *
     * @return a long.
     */
    long getDirectPathReads();

    /**
     * Number of session waits while while a sequential read from the database is performed.
     *
     * @return a long.
     */
    long getSingleBlockReads();

    /**
     * Number of session waits while reading multiple data blocks.
     *
     * @return a long.
     */
    long getMultiBlockReads();

    /**
     * Number of server messages from and to the clients.
     *
     * @return a long.
     */
    long getSqlNet();

    /**
     * Number of log file writes.
     *
     * @return a long.
     */
    long getLogWrites();

    /**
     * Number of miscellaneous server events.
     *
     * @return a long.
     */
    long getOther();
}
