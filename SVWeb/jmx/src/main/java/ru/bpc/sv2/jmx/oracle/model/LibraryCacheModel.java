/*
 * LibraryCacheModel.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.model;

import ru.bpc.sv2.jmx.utils.JSON;

import java.io.Serializable;

/**
 * Hit statistics of the database library cache.
 *
 * @author Ilya Yushin
 * @version $Id: dd68ccef6ee072121c99022cb3282fa646fab43e $
 */
public final class LibraryCacheModel implements Serializable {
    private static final long serialVersionUID = 3278836643275458172L;

    /** Constant <code>NULL</code> */
    public static final LibraryCacheModel NULL = createNullModel();

    private final float hitratioBody;
    private final float hitratioTableProcedures;
    private final float hitratioTrigger;
    private final float hitratioSqlArea;
    private final float pinHitratioBody;
    private final float pinHitratioTableProcedures;
    private final float pinHitratioTrigger;
    private final float pinHitratioSqlArea;

    /**
     * <p>Constructor for LibraryCacheModel.</p>
     *
     * @param hitratioBody a float.
     * @param hitratioTableProcedures a float.
     * @param hitratioTrigger a float.
     * @param hitratioSqlArea a float.
     * @param pinHitratioBody a float.
     * @param pinHitratioTableProcedures a float.
     * @param pinHitratioTrigger a float.
     * @param pinHitratioSqlArea a float.
     */
    public LibraryCacheModel(float hitratioBody, float hitratioTableProcedures,
        float hitratioTrigger, float hitratioSqlArea, float pinHitratioBody,
        float pinHitratioTableProcedures, float pinHitratioTrigger, float pinHitratioSqlArea) {
        this.hitratioBody = hitratioBody;
        this.hitratioTableProcedures = hitratioTableProcedures;
        this.hitratioTrigger = hitratioTrigger;
        this.hitratioSqlArea = hitratioSqlArea;
        this.pinHitratioBody = pinHitratioBody;
        this.pinHitratioTableProcedures = pinHitratioTableProcedures;
        this.pinHitratioTrigger = pinHitratioTrigger;
        this.pinHitratioSqlArea = pinHitratioSqlArea;
    }

    private static LibraryCacheModel createNullModel() {
        return new LibraryCacheModel(0, 0, 0, 0, 0, 0, 0, 0);
    }

    /**
     * <p>Getter for the field <code>hitratioBody</code>.</p>
     *
     * @return a float.
     */
    public float getHitratioBody() {
        return hitratioBody;
    }

    /**
     * <p>Getter for the field <code>hitratioTableProcedures</code>.</p>
     *
     * @return a float.
     */
    public float getHitratioTableProcedures() {
        return hitratioTableProcedures;
    }

    /**
     * <p>Getter for the field <code>hitratioTrigger</code>.</p>
     *
     * @return a float.
     */
    public float getHitratioTrigger() {
        return hitratioTrigger;
    }

    /**
     * <p>Getter for the field <code>hitratioSqlArea</code>.</p>
     *
     * @return a float.
     */
    public float getHitratioSqlArea() {
        return hitratioSqlArea;
    }

    /**
     * <p>Getter for the field <code>pinHitratioBody</code>.</p>
     *
     * @return a float.
     */
    public float getPinHitratioBody() {
        return pinHitratioBody;
    }

    /**
     * <p>Getter for the field <code>pinHitratioTableProcedures</code>.</p>
     *
     * @return a float.
     */
    public float getPinHitratioTableProcedures() {
        return pinHitratioTableProcedures;
    }

    /**
     * <p>Getter for the field <code>pinHitratioTrigger</code>.</p>
     *
     * @return a float.
     */
    public float getPinHitratioTrigger() {
        return pinHitratioTrigger;
    }

    /**
     * <p>Getter for the field <code>pinHitratioSqlArea</code>.</p>
     *
     * @return a float.
     */
    public float getPinHitratioSqlArea() {
        return pinHitratioSqlArea;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Float.floatToIntBits(hitratioBody);
        result = prime * result + Float.floatToIntBits(hitratioSqlArea);
        result = prime * result + Float.floatToIntBits(hitratioTableProcedures);
        result = prime * result + Float.floatToIntBits(hitratioTrigger);
        result = prime * result + Float.floatToIntBits(pinHitratioBody);
        result = prime * result + Float.floatToIntBits(pinHitratioSqlArea);
        result = prime * result + Float.floatToIntBits(pinHitratioTableProcedures);
        result = prime * result + Float.floatToIntBits(pinHitratioTrigger);
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
        final LibraryCacheModel other = (LibraryCacheModel) obj;
        if (Float.floatToIntBits(hitratioBody) != Float.floatToIntBits(other.hitratioBody)) {
            return false;
        }
        if (Float.floatToIntBits(hitratioSqlArea) != Float.floatToIntBits(other.hitratioSqlArea)) {
            return false;
        }
        if (Float.floatToIntBits(hitratioTableProcedures) != Float.floatToIntBits(
            other.hitratioTableProcedures)) {
            return false;
        }
        if (Float.floatToIntBits(hitratioTrigger) != Float.floatToIntBits(other.hitratioTrigger)) {
            return false;
        }
        if (Float.floatToIntBits(pinHitratioBody) != Float.floatToIntBits(other.pinHitratioBody)) {
            return false;
        }
        if (Float.floatToIntBits(pinHitratioSqlArea) != Float.floatToIntBits(
            other.pinHitratioSqlArea)) {
            return false;
        }
        if (Float.floatToIntBits(pinHitratioTableProcedures) != Float.floatToIntBits(
            other.pinHitratioTableProcedures)) {
            return false;
        }
        if (Float.floatToIntBits(pinHitratioTrigger) != Float.floatToIntBits(
            other.pinHitratioTrigger)) {
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
