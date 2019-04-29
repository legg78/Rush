/*
 * SvboDiscoveryMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.mbean;

import javax.management.MXBean;

/**
 * Discovery MBean specification.
 *
 * @author Ilya Yushin
 * @version $Id: c63bccac5ae215ec69fcf542dba2a886bc0327c7 $
 */
@MXBean
public interface SvboDiscoveryMBean {
    /**
     * Returns LLD discovery text.
     *
     * @return discovery JSON value
     */
    String getDiscoveryValue();
}
