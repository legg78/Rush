/*
 * DatabaseModel.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.model;

import ru.bpc.sv2.jmx.utils.JSON;

import java.io.Serializable;

/**
 * <p>DatabaseModel class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 79278dbc7f562ab6954085c3eef1fb7dfae1ba08 $
 */
public final class DatabaseModel implements Serializable {
    private static final long serialVersionUID = 8068300039256182939L;

    /** Constant <code>NULL</code> */
    public static final DatabaseModel NULL = createNullModel();

    private final String version;
    private final long uptime, databaseSize, fileSize, archiveLog, latchMisses;

    /**
     * <p>Constructor for DatabaseModel.</p>
     *
     * @param version a {@link String} object.
     * @param uptime a long.
     * @param databaseSize a long.
     * @param fileSize a long.
     * @param archiveLog a long.
     * @param latchMisses a long.
     */
    public DatabaseModel(String version, long uptime, long databaseSize, long fileSize,
        long archiveLog, long latchMisses) {
        this.version = version;
        this.uptime = uptime;
        this.databaseSize = databaseSize;
        this.fileSize = fileSize;
        this.archiveLog = archiveLog;
        this.latchMisses = latchMisses;
    }

    private static DatabaseModel createNullModel() {
        return new DatabaseModel("N/A", -1L, -1L, -1L, -1L, -1L);
    }

    /**
     * <p>Getter for the field <code>version</code>.</p>
     *
     * @return a {@link String} object.
     */
    public String getVersion() {
        return version;
    }

    /**
     * <p>Getter for the field <code>uptime</code>.</p>
     *
     * @return a long.
     */
    public long getUptime() {
        return uptime;
    }

    /**
     * <p>Getter for the field <code>databaseSize</code>.</p>
     *
     * @return a long.
     */
    public long getDatabaseSize() {
        return databaseSize;
    }

    /**
     * <p>Getter for the field <code>fileSize</code>.</p>
     *
     * @return a long.
     */
    public long getFileSize() {
        return fileSize;
    }

    /**
     * <p>Getter for the field <code>archiveLog</code>.</p>
     *
     * @return a long.
     */
    public long getArchiveLog() {
        return archiveLog;
    }

    /**
     * <p>Getter for the field <code>latchMisses</code>.</p>
     *
     * @return a long.
     */
    public long getLatchMisses() {
        return latchMisses;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (int) (archiveLog ^ archiveLog >>> 32);
        result = prime * result + (int) (databaseSize ^ databaseSize >>> 32);
        result = prime * result + (int) (fileSize ^ fileSize >>> 32);
        result = prime * result + (int) (latchMisses ^ latchMisses >>> 32);
        result = prime * result + (int) (uptime ^ uptime >>> 32);
        result = prime * result + (version == null ? 0 : version.hashCode());
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
        final DatabaseModel other = (DatabaseModel) obj;
        if (archiveLog != other.archiveLog) {
            return false;
        }
        if (databaseSize != other.databaseSize) {
            return false;
        }
        if (fileSize != other.fileSize) {
            return false;
        }
        if (latchMisses != other.latchMisses) {
            return false;
        }
        if (uptime != other.uptime) {
            return false;
        }
        if (version == null) {
            if (other.version != null) {
                return false;
            }
        } else if (!version.equals(other.version)) {
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
