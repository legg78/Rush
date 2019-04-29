/*
 * WaitEventsModel.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.model;

import ru.bpc.sv2.jmx.utils.JSON;

import java.io.Serializable;

/**
 * <p>WaitEventsModel class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 9e2e7dc524add63a53e668add5aea511742383b5 $
 */
public final class WaitEventsModel implements Serializable {
    private static final long serialVersionUID = -6628173473870319454L;

    /** Constant <code>NULL</code> */
    public static final WaitEventsModel NULL = createNullModel();

    private final long fileIO, controlFileIO, directPathReads, singleBlockReads, multiBlockReads,
        sqlNet, logWrites, other;

    /**
     * <p>Constructor for WaitEventsModel.</p>
     *
     * @param fileIO a long.
     * @param controlFileIO a long.
     * @param directPathReads a long.
     * @param singleBlockReads a long.
     * @param multiBlockReads a long.
     * @param sqlNet a long.
     * @param logWrites a long.
     * @param other a long.
     */
    public WaitEventsModel(long fileIO, long controlFileIO, long directPathReads, long singleBlockReads,
        long multiBlockReads, long sqlNet, long logWrites, long other) {
        this.fileIO = fileIO;
        this.controlFileIO = controlFileIO;
        this.directPathReads = directPathReads;
        this.singleBlockReads = singleBlockReads;
        this.multiBlockReads = multiBlockReads;
        this.sqlNet = sqlNet;
        this.logWrites = logWrites;
        this.other = other;
    }

    private static WaitEventsModel createNullModel() {
        return new WaitEventsModel(-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L);
    }

    /**
     * <p>Getter for the field <code>fileIO</code>.</p>
     *
     * @return a long.
     */
    public long getFileIO() {
        return fileIO;
    }

    /**
     * <p>Getter for the field <code>controlFileIO</code>.</p>
     *
     * @return a long.
     */
    public long getControlFileIO() {
        return controlFileIO;
    }

    /**
     * <p>Getter for the field <code>directPathReads</code>.</p>
     *
     * @return a long.
     */
    public long getDirectPathReads() {
        return directPathReads;
    }

    /**
     * <p>Getter for the field <code>singleBlockReads</code>.</p>
     *
     * @return a long.
     */
    public long getSingleBlockReads() {
        return singleBlockReads;
    }

    /**
     * <p>Getter for the field <code>multiBlockReads</code>.</p>
     *
     * @return a long.
     */
    public long getMultiBlockReads() {
        return multiBlockReads;
    }

    /**
     * <p>Getter for the field <code>sqlNet</code>.</p>
     *
     * @return a long.
     */
    public long getSqlNet() {
        return sqlNet;
    }

    /**
     * <p>Getter for the field <code>logWrites</code>.</p>
     *
     * @return a long.
     */
    public long getLogWrites() {
        return logWrites;
    }

    /**
     * <p>Getter for the field <code>other</code>.</p>
     *
     * @return a long.
     */
    public long getOther() {
        return other;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (int) (controlFileIO ^ controlFileIO >>> 32);
        result = prime * result + (int) (directPathReads ^ directPathReads >>> 32);
        result = prime * result + (int) (fileIO ^ fileIO >>> 32);
        result = prime * result + (int) (logWrites ^ logWrites >>> 32);
        result = prime * result + (int) (multiBlockReads ^ multiBlockReads >>> 32);
        result = prime * result + (int) (other ^ other >>> 32);
        result = prime * result + (int) (singleBlockReads ^ singleBlockReads >>> 32);
        result = prime * result + (int) (sqlNet ^ sqlNet >>> 32);
        return result;
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final WaitEventsModel other = (WaitEventsModel) obj;
        if (controlFileIO != other.controlFileIO) {
            return false;
        }
        if (directPathReads != other.directPathReads) {
            return false;
        }
        if (fileIO != other.fileIO) {
            return false;
        }
        if (logWrites != other.logWrites) {
            return false;
        }
        if (multiBlockReads != other.multiBlockReads) {
            return false;
        }
        if (this.other != other.other) {
            return false;
        }
        if (singleBlockReads != other.singleBlockReads) {
            return false;
        }
        if (sqlNet != other.sqlNet) {
            return false;
        }
        return true;
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        return JSON.toJsonString(this);
    }
}
