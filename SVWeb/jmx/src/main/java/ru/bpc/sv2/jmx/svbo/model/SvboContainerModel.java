/*
 * SvboContainerModel.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.model;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.jmx.utils.JSON;

/**
 * <p>SvboContainerModel class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 5659df8eab34eb3baf79ad9393ec6ec92a361cf2 $
 */
public final class SvboContainerModel implements SvboEntityModel, Serializable {
    private static final long serialVersionUID = 828443952745794275L;

    /** Constant <code>NULL</code> */
    public static final SvboContainerModel NULL = createNullModel();

    private final long id;
    private final String name;
    private final State state;
    private final Date finishTime;

    /**
     * <p>Constructor for SvboContainerModel.</p>
     *
     * @param id a long.
     * @param name a {@link java.lang.String} object.
     * @param state a {@link State} object.
     * @param finishTime a {@link java.util.Date} object.
     */
    public SvboContainerModel(long id, String name, State state, Date finishTime) {
        this.id = id;
        this.name = name;
        this.state = state;
        this.finishTime = finishTime;

    }

    private static SvboContainerModel createNullModel() {
        return new SvboContainerModel(-1L, "<undefined>", State.UNDEFINED, new Date());
    }

    /** {@inheritDoc} */
    @Override
    public long getId() {
        return id;
    }

    /**
     * <p>Getter for the field <code>name</code>.</p>
     *
     * @return a {@link java.lang.String} object.
     */
    public String getName() {
        return name;
    }

    /**
     * <p>Getter for the field <code>state</code>.</p>
     *
     * @return a {@link State} object.
     */
    public State getState() {
        return state;
    }

    /**
     * <p>Getter for the field <code>finishTime</code>.</p>
     *
     * @return a {@link java.util.Date} object.
     */
    public Date getFinishTime() {
        return finishTime;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (int) (id ^ id >>> 32);
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
        final SvboContainerModel other = (SvboContainerModel) obj;
        if (id != other.id) {
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
