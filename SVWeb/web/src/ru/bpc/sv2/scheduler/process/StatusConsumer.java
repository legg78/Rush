/*
 * StatusConsumer.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.scheduler.process;

/**
 * Interface for observing progress events produced by {@link AsyncProcessHandler}.
 *
 * @author Ilya Yushin
 * @version $Id$
 */
public interface StatusConsumer {
    /**
     * Sets estimated number of items to process in the current phase.
     */
    void countEstimated(long totalItems);

    /**
     * Sets information about items being processed.
     */
    void countUpdated(long processedItems, long failedItems, long rejectedItems);

    /**
     * Sets information about phases.
     */
    void phaseUpdated(int currentPhase, int phaseCount);
}
