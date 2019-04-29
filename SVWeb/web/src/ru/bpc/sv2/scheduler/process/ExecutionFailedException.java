/*
 * ExecutionFailedException.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.scheduler.process;

import ru.bpc.sv2.utils.SystemException;

/**
 * @author Ilya Yushin
 * @version $Id$
 */
public class ExecutionFailedException extends SystemException {
    private static final long serialVersionUID = 1L;

    public ExecutionFailedException(String msg) {
        super(msg);
    }
}
