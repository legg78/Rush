/*
 * ProcessesModel.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.model;

import ru.bpc.sv2.jmx.utils.JSON;

import java.io.Serializable;

/**
 * <p>ProcessesModel class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 90f0fb7f5ba67424bd98917dca56a33ea4f50a65 $
 */
public final class ProcessesModel implements Serializable {
    private static final long serialVersionUID = 2262904309741856530L;

    /** Constant <code>NULL</code> */
    public static final ProcessesModel NULL = createNullModel();

    private final int count, limit;

    /**
     * <p>Constructor for ProcessesModel.</p>
     *
     * @param count a int.
     * @param limit a int.
     */
    public ProcessesModel(int count, int limit) {
        this.count = count;
        this.limit = limit;
    }

    private static ProcessesModel createNullModel() {
        return new ProcessesModel(-1, -1);
    }

    /**
     * <p>Getter for the field <code>count</code>.</p>
     *
     * @return a int.
     */
    public int getCount() {
        return count;
    }

    /**
     * <p>getMax.</p>
     *
     * @return a int.
     */
    public int getMax() {
        return limit;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + count;
        result = prime * result + limit;
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
        final ProcessesModel other = (ProcessesModel) obj;
        if (count != other.count) {
            return false;
        }
        if (limit != other.limit) {
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
