/*
 * DatabaseModel.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.model;

import ru.bpc.sv2.jmx.utils.JSON;

import java.io.Serializable;

/**
 * <p>SessionsModel class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: debb6e9b0cb8b337f792638da3ccfc808d42c731 $
 */
public final class SessionsModel implements Serializable {
    private static final long serialVersionUID = 514597231461953848L;

    /** Constant <code>NULL</code> */
    public static final SessionsModel NULL = createNullModel();

    private final int total, max, active, inactive, system, connectedUsers;

    /**
     * <p>Constructor for SessionsModel.</p>
     *
     * @param total a int.
     * @param max a int.
     * @param active a int.
     * @param inactive a int.
     * @param system a int.
     * @param users a int.
     */
    public SessionsModel(int total, int max, int active, int inactive, int system, int users) {
        this.total = total;
        this.max = max;
        this.active = active;
        this.inactive = inactive;
        this.system = system;
        this.connectedUsers = users;
    }

    private static SessionsModel createNullModel() {
        return new SessionsModel(-1, -1, -1, -1, -1, -1);
    }

    /**
     * <p>Getter for the field <code>total</code>.</p>
     *
     * @return a int.
     */
    public int getTotal() {
        return total;
    }

    /**
     * <p>Getter for the field <code>max</code>.</p>
     *
     * @return a int.
     */
    public int getMax() {
        return max;
    }

    /**
     * <p>Getter for the field <code>active</code>.</p>
     *
     * @return a int.
     */
    public int getActive() {
        return active;
    }

    /**
     * <p>Getter for the field <code>inactive</code>.</p>
     *
     * @return a int.
     */
    public int getInactive() {
        return inactive;
    }

    /**
     * <p>Getter for the field <code>system</code>.</p>
     *
     * @return a int.
     */
    public int getSystem() {
        return system;
    }

    /**
     * <p>Getter for the field <code>connectedUsers</code>.</p>
     *
     * @return a int.
     */
    public int getConnectedUsers() {
        return connectedUsers;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + active;
        result = prime * result + inactive;
        result = prime * result + max;
        result = prime * result + system;
        result = prime * result + total;
        result = prime * result + connectedUsers;
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
        final SessionsModel other = (SessionsModel) obj;
        if (active != other.active) {
            return false;
        }
        if (inactive != other.inactive) {
            return false;
        }
        if (max != other.max) {
            return false;
        }
        if (system != other.system) {
            return false;
        }
        if (total != other.total) {
            return false;
        }
        if (connectedUsers != other.connectedUsers) {
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
