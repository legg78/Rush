/*
 * Bundles.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.utils;

import java.util.ResourceBundle;

/**
 * Loads a module MBeans description bundle.
 *
 * @author Ilya Yushin
 * @version $Id: 87b0c5c2cd6e46c2b4660c316ca4646231ce3dcd $
 * @since 1.0.3
 */
public final class Bundles {
    private Bundles() {
    }

    /**
     * Returns MBean description text bundle.
     *
     * @return description text bundle
     */
    public static ResourceBundle getDescriptionBundle() {
        return ResourceBundle.getBundle("mbeans/oracle/description");
    }
}
