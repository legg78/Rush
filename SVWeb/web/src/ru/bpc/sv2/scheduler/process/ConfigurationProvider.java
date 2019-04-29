/*
 * ConfigurationProvider.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.scheduler.process;

/**
 * Defines a contract for {@link AsyncProcessHandler} to access its implementation specific set of
 * configuration attributes (system or host parameters etc.)<br/>
 * (Hint: implementation requirements to be defined.)
 *
 * @author Ilya Yushin
 * @version $Id$
 */
public interface ConfigurationProvider {
    String getValue(String name);

    String getValue(String name, String defaultValue);
}
