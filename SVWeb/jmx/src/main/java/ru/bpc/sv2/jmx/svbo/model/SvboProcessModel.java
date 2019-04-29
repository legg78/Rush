/*
 * SvboProcessModel.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.model;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.jmx.utils.JSON;

/**
 * DTO that keeps SVBO process status information.
 *
 * @author Ilya Yushin
 * @version $Id: 9dc65c7277d57307f0449e07878f120c12ea9e05 $
 */
public final class SvboProcessModel implements SvboEntityModel, Serializable {
    private static final long serialVersionUID = 4367958786373181278L;

    /** Constant <code>NULL</code> */
    public static final SvboProcessModel NULL = createNullModel();

    private final long id;
    private final String name;
    private final long processId;
    private final long containerId;
    private final State state;
    private final float progress;
    private final float remaining;
    private final long processed;
    private final long rejected;
    private final long excepted;
    private final Date startTime;
    private final Date finishTime;

    /**
     * <p>Constructor for SvboProcessModel.</p>
     *
     * @param id a long.
     * @param name a {@link java.lang.String} object.
     * @param processId a long.
     * @param containerId a long.
     * @param state a {@link State} object.
     * @param progress a float.
     * @param processed a long.
     * @param rejected a long.
     * @param excepted a long.
     * @param remaining a float.
     * @param startTime a {@link java.util.Date} object.
     * @param finishTime a {@link java.util.Date} object.
     */
    public SvboProcessModel(long id, String name, long processId, long containerId, State state,
        float progress, long processed, long rejected, long excepted, float remaining,
        Date startTime, Date finishTime) {
        this.id = id;
        this.name = name;
        this.processId = processId;
        this.containerId = containerId;
        this.state = state;
        this.progress = progress;
        this.processed = processed;
        this.rejected = rejected;
        this.excepted = excepted;
        this.remaining = remaining;
        this.startTime = startTime;
        this.finishTime = finishTime;
    }

    private static SvboProcessModel createNullModel() {
        return new SvboProcessModel(-1L, "<undefined>", -1L, -1L, State.UNDEFINED, 0f, -1L, -1L,
            -1L, 0f, null, null);
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
     * <p>Getter for the field <code>processId</code>.</p>
     *
     * @return a long.
     */
    public long getProcessId() {
        return processId;
    }

    /**
     * <p>Getter for the field <code>containerId</code>.</p>
     *
     * @return a long.
     */
    public long getContainerId() {
        return containerId;
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
     * <p>Getter for the field <code>progress</code>.</p>
     *
     * @return a float.
     */
    public float getProgress() {
        return progress;
    }

    /**
     * <p>Getter for the field <code>processed</code>.</p>
     *
     * @return a long.
     */
    public long getProcessed() {
        return processed;
    }

    /**
     * <p>Getter for the field <code>rejected</code>.</p>
     *
     * @return a long.
     */
    public long getRejected() {
        return rejected;
    }

    /**
     * <p>Getter for the field <code>excepted</code>.</p>
     *
     * @return a long.
     */
    public long getExcepted() {
        return excepted;
    }

    /**
     * <p>Getter for the field <code>remaining</code>.</p>
     *
     * @return a float.
     */
    public float getRemaining() {
        return remaining;
    }

    /**
     * <p>Getter for the field <code>startTime</code>.</p>
     *
     * @return a {@link java.util.Date} object.
     */
    public Date getStartTime() {
        return startTime;
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
        final SvboProcessModel other = (SvboProcessModel) obj;
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
