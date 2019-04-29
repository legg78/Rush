/*
 * SGAModel.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.model;

import ru.bpc.sv2.jmx.utils.JSON;

import java.io.Serializable;

/**
 * <p>PGAModel class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 2b284dc53f707a56329b27715d6015bb1276dddb $
 */
public final class PGAModel implements Serializable {
    private static final long serialVersionUID = 84573345781153913L;

    /** Constant <code>NULL</code> */
    public static final PGAModel NULL = createNullModel();

    private final long aggregateTarget, consumedBytes;

    /**
     * <p>Constructor for PGAModel.</p>
     *
     * @param aggregateTarget a long.
     * @param consumedBytes a long.
     */
    public PGAModel(long aggregateTarget, long consumedBytes) {
        this.aggregateTarget = aggregateTarget;
        this.consumedBytes = consumedBytes;
    }

    private static PGAModel createNullModel() {
        return new PGAModel(-1L, -1L);
    }

    /**
     * <p>Getter for the field <code>aggregateTarget</code>.</p>
     *
     * @return a long.
     */
    public long getAggregateTarget() {
        return aggregateTarget;
    }

    /**
     * <p>Getter for the field <code>consumedBytes</code>.</p>
     *
     * @return a long.
     */
    public long getConsumedBytes() {
        return consumedBytes;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (int) (aggregateTarget ^ aggregateTarget >>> 32);
        result = prime * result + (int) (consumedBytes ^ consumedBytes >>> 32);
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
        final PGAModel other = (PGAModel) obj;
        if (aggregateTarget != other.aggregateTarget) {
            return false;
        }
        if (consumedBytes != other.consumedBytes) {
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
