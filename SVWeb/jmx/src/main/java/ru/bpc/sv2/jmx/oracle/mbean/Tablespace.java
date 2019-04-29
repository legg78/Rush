/*
 * Tablespace.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.mbean;

import ru.bpc.sv2.jmx.mbean.BaseMBean;
import ru.bpc.sv2.jmx.oracle.model.TablespaceModel;
import ru.bpc.sv2.jmx.oracle.utils.Bundles;
import org.apache.commons.lang3.ObjectUtils;

import java.io.Serializable;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicReference;

/**
 * <p>Tablespace class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 5ac29e83f8b78ad7b311d834b782376a07c7427d $
 */
public final class Tablespace extends BaseMBean implements TablespaceMBean, Serializable {
    private static final long serialVersionUID = 3342259959871798207L;

    private final AtomicReference<TablespaceModel> model = new AtomicReference<TablespaceModel>();

    /**
     * <p>Constructor for Tablespace.</p>
     */
    public Tablespace() {
        this(null);
    }

    /**
     * <p>Constructor for Tablespace.</p>
     *
     * @param model a {@link ru.bpc.sv2.jmx.oracle.model.TablespaceModel} object.
     */
    public Tablespace(TablespaceModel model) {
        super(Bundles.getDescriptionBundle(), TablespaceMBean.class, "tablespace");
        updateModel(model);
    }

    /**
     * <p>updateModel.</p>
     *
     * @param model a {@link ru.bpc.sv2.jmx.oracle.model.TablespaceModel} object.
     */
    public void updateModel(TablespaceModel model) {
        this.model.set(ObjectUtils.defaultIfNull(model, TablespaceModel.NULL));
    }

    //
    // TablespaceMBean implementation:
    //

    /** {@inheritDoc} */
    @Override
    public String getName() {
        return model.get().getTablespaceName();
    }

    /** {@inheritDoc} */
    @Override
    public Contents getContents() {
        return model.get().getContents();
    }

    /** {@inheritDoc} */
    @Override
    public Status getStatus() {
        return model.get().getStatus();
    }

    /** {@inheritDoc} */
    @Override
    public int getFilesCount() {
        return model.get().getFilesCount();
    }

    /** {@inheritDoc} */
    @Override
    public long getBlockSize() {
        return model.get().getBlockSize();
    }

    /** {@inheritDoc} */
    @Override
    public long getInitialExtent() {
        return model.get().getInitialExtent();
    }

    /** {@inheritDoc} */
    @Override
    public long getNextExtent() {
        return model.get().getNextExtent();
    }

    /** {@inheritDoc} */
    @Override
    public long getMinExtents() {
        return model.get().getMinExtents();
    }

    /** {@inheritDoc} */
    @Override
    public long getMaxExtents() {
        return model.get().getMaxExtents();
    }

    /** {@inheritDoc} */
    @Override
    public int getPercentInscrease() {
        return model.get().getPercentInscrease();
    }

    /** {@inheritDoc} */
    @Override
    public long getUsedBytes() {
        return model.get().getUsedBytes();
    }

    /** {@inheritDoc} */
    @Override
    public long getActualBytes() {
        return model.get().getActualBytes();
    }

    /** {@inheritDoc} */
    @Override
    public long getMaxBytes() {
        return model.get().getMaxBytes();
    }

    /** {@inheritDoc} */
    @Override
    public long getFreeBytes() {
        return model.get().getFreeBytes();
    }

    /** {@inheritDoc} */
    @Override
    public long getSpaceBytes() {
        return model.get().getSpaceBytes();
    }

    /** {@inheritDoc} */
    @Override
    public int getUsage() {
        return model.get().getUsage();
    }

    //
    // Object overrides:
    //

    /** {@inheritDoc} */
    @Override
    public int hashCode() {
        return model.get().hashCode();
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Tablespace) {
            return Objects.equals(model, ((Tablespace) obj).model);
        }
        return false;
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        return model.get().toString();
    }

}
