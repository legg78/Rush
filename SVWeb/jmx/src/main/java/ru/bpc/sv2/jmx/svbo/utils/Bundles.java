/*
 * Bundles.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.svbo.utils;

import java.util.ResourceBundle;

/**
 * Loads a module MBeans description bundle.
 *
 * @author Ilya Yushin
 * @version $Id: 62196df163a3da630c90502be96a0f96e8ec5e10 $
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
        return ResourceBundle.getBundle("mbeans/svbo/description");
    }
}
