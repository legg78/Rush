/*
 * SvboContainerMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.mbean;

import java.util.Date;

import javax.management.MXBean;

/**
 * MBean specification for container status.
 *
 * @author Ilya Yushin
 * @version $Id: 0451c91a065f90c7e6d46b6d161a7671a0c5e10b $
 */
@MXBean
public interface SvboContainerMBean {
    /**
     * Returns the unique identifier of this container.
     *
     * @return container id
     */
    long getId();

    /**
     * Returns the name of this container.
     *
     * @return container name
     */
    String getName();

    /**
     * Returns state of the last container launch.
     *
     * @return container launch state
     */
    String getState();

    /**
     * Returns date and time of the last container launch.
     *
     * @return container launch date
     */
    Date getFinishTime();
}
