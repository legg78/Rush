/*
 * AsyncProcessHandler.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.scheduler.process;

/**
 * @author Ilya Yushin
 * @version $Id$
 */
public interface AsyncProcessHandler {
    /**
     * Invoked right after a new handler implementation is created to configure and prepare for
     * execution.
     *
     * @param provider a source where handler implementation can find required configuration
     *                 attributes
     */
    void configure(ConfigurationProvider provider);

    /**
     * This functions initiates asynchronous process and returns upon successful start.
     *
     * @param context represent entire input for the process including process parameters, file etc.
     * @throws ExecutionFailedException in case when execution fails due to configuration or other
     *                                  error
     */
    void execute(ExecutionContext context) throws ExecutionFailedException;

    /**
     * This function resets handler to state identical to that before
     * {@link #execute(ExecutionContext)}. Implementation type should resets self state
     */
    void reset();

    enum HandlerState {
        /**
         * STANDBY - Just initialized, ready to execute (have no previously running processes).
         */
        StandBy,

        /**
         * PRSR0000 - Locked by another process/already executing another process.
         */
        AlreadyRunning,

        /**
         * PRSR0001 - In progress/process working.
         */
        InProgress,

        /**
         * PRSR0002 - In progress/process working.
         */
        Completed,

        /**
         * PRSR0004 - Finished with errors/has non-critical errors.
         */
        CompletedWithErrors,

        /**
         * PRSR0005 - Interrupted/cancelled by a user.
         */
        Cancelled,

        /**
         * PRSR0003 - Successfully finished / normally done.
         */
        Failed
    }

    /**
     * Returns effective state of process handler.
     * <p/>
     * Note: The value of this property is set to {@link HandlerState#StandBy} by {@link #reset()}.
     */
    HandlerState getState();

    /**
     * @return : required file for this handler or not.
     */
    boolean isFileRequired();

    /**
     * {@link AsyncProcessExecutor} invokes this method to collect progress information.
     *
     * @param consumer object that handler populates with status data
     */
    void fillStatus(StatusConsumer consumer);

    /**
     * {@link AsyncProcessExecutor} invokes this method to
     * properly close resources, taken by configure method call.
     */
    void destroy();
}
