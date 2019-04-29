/*
 * TablespaceMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.mbean;

import javax.management.MXBean;

/**
 * Discovery bean, provides list of found tablespaces.
 *
 * @author Ilya Yushin
 * @version $Id: e89f33cdd90bbb8a4462f77937b3f416c65ad31e $
 */
@MXBean
public interface TablespacesMBean {
    /**
     * Discovery JSON value.
     *
     * @return a {@link String} object.
     */
    String getDiscoveryValue();
}
