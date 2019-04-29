/*
 * SvboEntityMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.mbean;

import ru.bpc.sv2.jmx.svbo.model.SvboEntityModel;

/**
 * Interface for an updatable entity MBean.
 *
 * @author Ilya Yushin
 * @version $Id: 22499eba52df43155fe2021575678ae2b0a1489a $
 */
public interface SvboEntityMBean<BeanModel extends SvboEntityModel> {
    /**
     * Updates self attributes by copying values from the given <tt>model</tt>.
     *
     * @param model source model to copy values from
     */
    void updateModel(BeanModel model);
}
