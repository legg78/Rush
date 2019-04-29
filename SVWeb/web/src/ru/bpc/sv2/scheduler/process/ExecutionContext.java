/*
 * ExecutionContext.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.scheduler.process;

import java.net.URI;
import java.nio.charset.Charset;
import java.nio.file.Path;
import java.util.Map;

/**
 * Defines a contract for passing process parameters to {@link AsyncProcessHandler}.
 *
 * @author Ilya Yushin
 * @version $Id$
 */
public interface ExecutionContext {
    /**
     * @return : The ID of the process container
     */
    long getContainerId();

    /**
     * @return : The ID of the 'logical' container, which describes in PRC_CONTAINER as ID column
     */
    long getContainerBindId();

    /**
     * @return : The process session.
     */
    long getSessionId();

    /**
     * @return : Identifier of user who starts the process.
     */
    int getUserId();

    /**
     * @return : Identifier of running process.
     */
    Integer getProcessId();

    /**
     * @return : Session identifier of parent process or container.
     */
    long getParentSessionId();

    /**
     * Keeps a detail information about process files. <br/>
     * (Hint: can be moved to a separate Java source file).
     *
     * @author Ilya Yushin
     * @version $Id$
     */
    interface FileInfo {
        /**
         * Returns resolved absolute {@link Path} to the source file in case target
         * {@link AsyncProcessHandler} implementation requires file as input.
         */
        URI getPath();

        /**
         * Should return either <tt>Charset.forName("IBM037")</tt> or
         * <tt>java.nio.charset.StandardCharsets.US_ASCII</tt> according to file settings.
         */
        Charset getCharset();

        /**
         * As alternative to {@link #getCharset()} if mapping cannot be done.
         */
        String getCharsetName();
    }

    /**
     * Returns incoming file or <tt>null</tt> if the handler does not expect any file input.
     */
    FileInfo getSourceFile();

    /**
     * Returns process parameters dictionary.
     */
    Map<String, Object> getParameters();

    /**
     * Returns outgoing file information or <tt>null</tt> if the handler does not produce any file
     * output.
     */
    FileInfo getDestinationFile();
}
