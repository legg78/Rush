/*
 * SystemIOModel.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.model;

import ru.bpc.sv2.jmx.utils.JSON;

import java.io.Serializable;

/**
 * <p>SystemIOModel class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 13daa46bed71f6f1048823c19c6b03ae4aa7b3b0 $
 */
public final class SystemIOModel implements Serializable {
    private static final long serialVersionUID = -3830654806700758664L;

    /** Constant <code>NULL</code> */
    public static final SystemIOModel NULL = createNullModel();

    private final long physicalReads, datafileReads, datafileWrites, redoWrites, blockGets,
        consistentGets, blockChanges;
    private final float hitRatio, notIndexedSqlRatio;

    /**
     * <p>Constructor for SystemIOModel.</p>
     *
     * @param physicalReads a long.
     * @param datafileReads a long.
     * @param datafileWrites a long.
     * @param redoWrites a long.
     * @param blockGets a long.
     * @param consistentGets a long.
     * @param hitRatio a float.
     * @param blockChanges a long.
     * @param notIndexedSqlRatio a float.
     */
    public SystemIOModel(long physicalReads, long datafileReads, long datafileWrites,
        long redoWrites, long blockGets, long consistentGets, float hitRatio, long blockChanges,
        float notIndexedSqlRatio) {

        this.physicalReads = physicalReads;
        this.datafileReads = datafileReads;
        this.datafileWrites = datafileWrites;
        this.redoWrites = redoWrites;
        this.blockGets = blockGets;
        this.consistentGets = consistentGets;
        this.hitRatio = hitRatio;
        this.blockChanges = blockChanges;
        this.notIndexedSqlRatio = notIndexedSqlRatio;
    }

    private static SystemIOModel createNullModel() {
        return new SystemIOModel(-1L, -1L, -1L, -1L, -1L, -1L, 0f, -1L, 0f);
    }

    /**
     * <p>Getter for the field <code>physicalReads</code>.</p>
     *
     * @return a long.
     */
    public long getPhysicalReads() {
        return physicalReads;
    }

    /**
     * <p>Getter for the field <code>datafileReads</code>.</p>
     *
     * @return a long.
     */
    public long getDatafileReads() {
        return datafileReads;
    }

    /**
     * <p>Getter for the field <code>datafileWrites</code>.</p>
     *
     * @return a long.
     */
    public long getDatafileWrites() {
        return datafileWrites;
    }

    /**
     * <p>Getter for the field <code>redoWrites</code>.</p>
     *
     * @return a long.
     */
    public long getRedoWrites() {
        return redoWrites;
    }

    /**
     * <p>Getter for the field <code>blockGets</code>.</p>
     *
     * @return a long.
     */
    public long getBlockGets() {
        return blockGets;
    }

    /**
     * <p>Getter for the field <code>consistentGets</code>.</p>
     *
     * @return a long.
     */
    public long getConsistentGets() {
        return consistentGets;
    }

    /**
     * <p>Getter for the field <code>hitRatio</code>.</p>
     *
     * @return a float.
     */
    public float getHitRatio() {
        return hitRatio;
    }

    /**
     * <p>Getter for the field <code>blockChanges</code>.</p>
     *
     * @return a long.
     */
    public long getBlockChanges() {
        return blockChanges;
    }

    /**
     * <p>Getter for the field <code>notIndexedSqlRatio</code>.</p>
     *
     * @return a float.
     */
    public float getNotIndexedSqlRatio() {
        return notIndexedSqlRatio;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (int) (blockChanges ^ blockChanges >>> 32);
        result = prime * result + (int) (blockGets ^ blockGets >>> 32);
        result = prime * result + (int) (consistentGets ^ consistentGets >>> 32);
        result = prime * result + (int) (datafileReads ^ datafileReads >>> 32);
        result = prime * result + (int) (datafileWrites ^ datafileWrites >>> 32);
        result = prime * result + Float.floatToIntBits(hitRatio);
        result = prime * result + Float.floatToIntBits(notIndexedSqlRatio);
        result = prime * result + (int) (physicalReads ^ physicalReads >>> 32);
        result = prime * result + (int) (redoWrites ^ redoWrites >>> 32);
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
        final SystemIOModel other = (SystemIOModel) obj;
        if (blockChanges != other.blockChanges) {
            return false;
        }
        if (blockGets != other.blockGets) {
            return false;
        }
        if (consistentGets != other.consistentGets) {
            return false;
        }
        if (datafileReads != other.datafileReads) {
            return false;
        }
        if (datafileWrites != other.datafileWrites) {
            return false;
        }
        if (Float.floatToIntBits(hitRatio) != Float.floatToIntBits(other.hitRatio)) {
            return false;
        }
        if (Float.floatToIntBits(notIndexedSqlRatio) != Float.floatToIntBits(
            other.notIndexedSqlRatio)) {
            return false;
        }
        if (physicalReads != other.physicalReads) {
            return false;
        }
        if (redoWrites != other.redoWrites) {
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
