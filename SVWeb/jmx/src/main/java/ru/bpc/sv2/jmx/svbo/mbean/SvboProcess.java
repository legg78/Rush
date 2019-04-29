/*
 * SvboProcess.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.mbean;

import java.util.Date;
import java.util.concurrent.atomic.AtomicReference;

import org.apache.commons.lang3.ObjectUtils;

import ru.bpc.sv2.jmx.mbean.BaseMBean;
import ru.bpc.sv2.jmx.svbo.model.State;
import ru.bpc.sv2.jmx.svbo.model.SvboProcessModel;
import ru.bpc.sv2.jmx.svbo.utils.Bundles;

/**
 * <p>
 * SvboProcess class.
 * </p>
 *
 * @author Ilya Yushin
 * @version $Id: b5dd4d1d04df9152770dd978fb5f83c4e3619ad6 $
 */
public class SvboProcess extends BaseMBean implements SvboProcessMBean,
    SvboEntityMBean<SvboProcessModel> {

    private AtomicReference<SvboProcessModel> model;

    /**
     * <p>
     * Constructor for SvboProcess.
     * </p>
     */
    public SvboProcess() {
        this(null);
    }

    /**
     * <p>
     * Constructor for SvboProcess.
     * </p>
     *
     * @param model a {@link SvboProcessModel} object.
     */
    public SvboProcess(SvboProcessModel model) {
        super(Bundles.getDescriptionBundle(), SvboProcessMBean.class, "process");
        this.model = new AtomicReference<>(ObjectUtils.defaultIfNull(model, SvboProcessModel.NULL));
    }

    /** {@inheritDoc} */
    @Override
    public void updateModel(SvboProcessModel model) {
        this.model.set(ObjectUtils.defaultIfNull(model, SvboProcessModel.NULL));
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
    public long getProcessId() {
        return model.get().getProcessId();
    }

    /** {@inheritDoc} */
    @Override
    public long getContainerId() {
        return model.get().getContainerId();
    }

    /** {@inheritDoc} */
    @Override
    public String getState() {
        final State state = model.get().getState();
        return ObjectUtils.defaultIfNull(state, State.UNDEFINED).toZabbix(getFinishTime());
    }

    /** {@inheritDoc} */
    @Override
    public float getProgress() {
        return model.get().getProgress();
    }

    /** {@inheritDoc} */
    @Override
    public long getProcessed() {
        return model.get().getProcessed();
    }

    /** {@inheritDoc} */
    @Override
    public long getRejected() {
        return model.get().getRejected();
    }

    /** {@inheritDoc} */
    @Override
    public long getExcepted() {
        return model.get().getExcepted();
    }

    /** {@inheritDoc} */
    @Override
    public float getRemaining() {
        return model.get().getRemaining();
    }

    /** {@inheritDoc} */
    @Override
    public Date getStartTime() {
        return model.get().getStartTime();
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
