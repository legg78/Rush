/*
 * Database.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.mbean;

import ru.bpc.sv2.jmx.mbean.DataItem;

import javax.management.MXBean;

/**
 * Library cache metrics for from V$LIBRARYCACHE.
 *
 * @author Ilya Yushin
 * @version $Id: 521e7068811a591634514d57f03b02c0b38a074e $
 */
@MXBean
public interface LibraryCacheMBean {
    /**
     * Percent of GETHITS to GETS for BODY namespace.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getHitratioBody();

    /**
     * Percent of GETHITS to GETS for TABLE and PROCEDURE namespace.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getHitratioTableProcedures();

    /**
     * Percent of GETHITS to GETS for TRIGGER namespace.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getPinHitratioTrigger();

    /**
     * Percent of GETHITS to GETS for SQL AREA namespace.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getHitratioSqlArea();

    /**
     * Number of times a PIN was requested for objects of BODY namespace.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getPinHitratioBody();

    /**
     * Number of times a PIN was requested for objects of TABLE and PROCEDURE namespace.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getPinHitratioTableProcedures();

    /**
     * Number of times a PIN was requested for objects of TRIGGER namespace.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getHitratioTrigger();

    /**
     * Number of times a PIN was requested for objects of SQL AREA namespace.
     *
     * @return a float.
     */
    @DataItem(units = "%")
    float getPinHitratioSqlArea();
}
