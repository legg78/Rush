/*
 * SvboContainer.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.mbean;

import java.util.Date;
import java.util.concurrent.atomic.AtomicReference;

import org.apache.commons.lang3.ObjectUtils;

import ru.bpc.sv2.jmx.mbean.BaseMBean;
import ru.bpc.sv2.jmx.svbo.model.State;
import ru.bpc.sv2.jmx.svbo.model.SvboContainerModel;
import ru.bpc.sv2.jmx.svbo.utils.Bundles;

/**
 * <p>
 * SvboContainer class.
 * </p>
 *
 * @author Ilya Yushin
 * @version $Id: 2801368d80285d5d13b6a48934816096a5ef13ba $
 */
public class SvboContainer extends BaseMBean implements SvboContainerMBean,
    SvboEntityMBean<SvboContainerModel> {

    private AtomicReference<SvboContainerModel> model;

    /**
     * <p>
     * Constructor for SvboContainer.
     * </p>
     */
    public SvboContainer() {
        this(null);
    }

    /**
     * <p>
     * Constructor for SvboContainer.
     * </p>
     *
     * @param model a {@link SvboContainerModel} object.
     */
    public SvboContainer(SvboContainerModel model) {
        super(Bundles.getDescriptionBundle(), SvboContainerMBean.class, "container");
        this.model = new AtomicReference<>(ObjectUtils.defaultIfNull(model,
            SvboContainerModel.NULL));
    }

    /** {@inheritDoc} */
    @Override
    public void updateModel(SvboContainerModel model) {
        this.model.set(ObjectUtils.defaultIfNull(model, SvboContainerModel.NULL));
    }

    /** {@inheritDoc} */
    @Override
    public long getId() {
        return model.get().getId();
    }

    /** {@inheritDoc} */
    @Override
    public String getName() {
        return model.get().getName();
    }

    /** {@inheritDoc} */
    @Override
    public String getState() {
        final State state = model.get().getState();
        return ObjectUtils.defaultIfNull(state, State.UNDEFINED).toZabbix(getFinishTime());
    }

    /** {@inheritDoc} */
    @Override
    public Date getFinishTime() {
        return model.get().getFinishTime();
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        return model.get().toString();
    }
}
