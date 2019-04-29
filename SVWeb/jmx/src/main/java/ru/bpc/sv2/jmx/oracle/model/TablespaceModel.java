/*
 * TablespaceModel.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.model;

import ru.bpc.sv2.jmx.oracle.mbean.TablespaceMBean.Contents;
import ru.bpc.sv2.jmx.oracle.mbean.TablespaceMBean.Status;
import ru.bpc.sv2.jmx.utils.JSON;

import java.io.Serializable;

/**
 * Stores jmx data about a particular tablespace.
 *
 * @author Ilya Yushin
 * @version $Id: e02a491c389b00a478bd778a8b534517355dbc3b $
 */
public final class TablespaceModel implements Serializable {
    private static final long serialVersionUID = 2625162497763848611L;

    /** Constant <code>NULL</code> */
    public static final TablespaceModel NULL = createNullModel();

    private final String tablespaceName;
    private final Contents contents;
    private final Status status;
    private final int filesCount;
    private final long blockSize;
    private final long initialExtent;
    private final long nextExtent;
    private final long minExtents;
    private final long maxExtents;
    private final int percentInscrease;
    private final long usedBytes;
    private final long actualBytes;
    private final long maxBytes;
    private final long freeBytes;

    /**
     * <p>Constructor for TablespaceModel.</p>
     *
     * @param tablespaceName a {@link String} object.
     * @param contents a {@link ru.bpc.sv2.jmx.oracle.mbean.TablespaceMBean.Contents} object.
     * @param status a {@link ru.bpc.sv2.jmx.oracle.mbean.TablespaceMBean.Status} object.
     * @param filesCount a int.
     * @param blockSize a long.
     * @param initialExtent a long.
     * @param nextExtent a long.
     * @param minExtents a long.
     * @param maxExtents a long.
     * @param percentInscrease a int.
     * @param usedBytes a long.
     * @param actualBytes a long.
     * @param maxBytes a long.
     * @param freeBytes a long.
     */
    public TablespaceModel(String tablespaceName, Contents contents, Status status, int filesCount,
        long blockSize, long initialExtent, long nextExtent, long minExtents, long maxExtents,
        int percentInscrease, long usedBytes, long actualBytes, long maxBytes, long freeBytes) {

        this.tablespaceName = tablespaceName;
        this.contents = contents;
        this.status = status;
        this.filesCount = filesCount;
        this.blockSize = blockSize;
        this.initialExtent = initialExtent;
        this.nextExtent = nextExtent;
        this.minExtents = minExtents;
        this.maxExtents = maxExtents;
        this.percentInscrease = percentInscrease;
        this.usedBytes = usedBytes;
        this.actualBytes = actualBytes;
        this.maxBytes = maxBytes;
        this.freeBytes = freeBytes;
    }

    private static TablespaceModel createNullModel() {
        return new TablespaceModel("Undefined", Contents.Undefined, Status.Undefined, //
            -1, -1L, -1L, -1L, -1L, -1L, -1, -1L, -1L, -1L, -1L);
    }

    /**
     * <p>Getter for the field <code>tablespaceName</code>.</p>
     *
     * @return a {@link String} object.
     */
    public String getTablespaceName() {
        return tablespaceName;
    }

    /**
     * <p>Getter for the field <code>contents</code>.</p>
     *
     * @return a {@link ru.bpc.sv2.jmx.oracle.mbean.TablespaceMBean.Contents} object.
     */
    public Contents getContents() {
        return contents;
    }

    /**
     * <p>Getter for the field <code>status</code>.</p>
     *
     * @return a {@link ru.bpc.sv2.jmx.oracle.mbean.TablespaceMBean.Status} object.
     */
    public Status getStatus() {
        return status;
    }

    /**
     * <p>Getter for the field <code>filesCount</code>.</p>
     *
     * @return a int.
     */
    public int getFilesCount() {
        return filesCount;
    }

    /**
     * <p>Getter for the field <code>blockSize</code>.</p>
     *
     * @return a long.
     */
    public long getBlockSize() {
        return blockSize;
    }

    /**
     * <p>Getter for the field <code>initialExtent</code>.</p>
     *
     * @return a long.
     */
    public long getInitialExtent() {
        return initialExtent;
    }

    /**
     * <p>Getter for the field <code>nextExtent</code>.</p>
     *
     * @return a long.
     */
    public long getNextExtent() {
        return nextExtent;
    }

    /**
     * <p>Getter for the field <code>minExtents</code>.</p>
     *
     * @return a long.
     */
    public long getMinExtents() {
        return minExtents;
    }

    /**
     * <p>Getter for the field <code>maxExtents</code>.</p>
     *
     * @return a long.
     */
    public long getMaxExtents() {
        return maxExtents;
    }

    /**
     * <p>Getter for the field <code>percentInscrease</code>.</p>
     *
     * @return a int.
     */
    public int getPercentInscrease() {
        return percentInscrease;
    }

    /**
     * <p>Getter for the field <code>usedBytes</code>.</p>
     *
     * @return a long.
     */
    public long getUsedBytes() {
        return usedBytes;
    }

    /**
     * <p>Getter for the field <code>actualBytes</code>.</p>
     *
     * @return a long.
     */
    public long getActualBytes() {
        return actualBytes;
    }

    /**
     * <p>Getter for the field <code>maxBytes</code>.</p>
     *
     * @return a long.
     */
    public long getMaxBytes() {
        return maxBytes;
    }

    /**
     * <p>Getter for the field <code>freeBytes</code>.</p>
     *
     * @return a long.
     */
    public long getFreeBytes() {
        return freeBytes;
    }

    /**
     * <p>getSpaceBytes.</p>
     *
     * @return a long.
     */
    public long getSpaceBytes() {
        return  maxBytes - usedBytes;
    }

    /**
     * <p>getUsage.</p>
     *
     * @return a int.
     */
    public int getUsage() {
        if (maxBytes == 0L) {
            return -1;
        }

        return Math.round(100f * ((float) usedBytes / maxBytes));
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (tablespaceName == null ? 0 : tablespaceName.hashCode());
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
        final TablespaceModel other = (TablespaceModel) obj;
        if (tablespaceName == null) {
            if (other.tablespaceName != null) {
                return false;
            }
        } else if (!tablespaceName.equals(other.tablespaceName)) {
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
