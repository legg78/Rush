/*
 * BaseMBean.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.mbean;

import java.util.MissingResourceException;
import java.util.ResourceBundle;

import javax.management.MBeanAttributeInfo;
import javax.management.MBeanInfo;
import javax.management.StandardMBean;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * <p>
 * Abstract BaseMBean class.
 * </p>
 *
 * @author Ilya Yushin
 * @version $Id: 80b19709c074ddb2ada285a6b3e170d28ed04c16 $
 */
public abstract class BaseMBean extends StandardMBean {
    private static final Logger log = LoggerFactory.getLogger("MONITORING");

    private final ResourceBundle bundle;
    private final String beanKey;

    /**
     * <p>
     * Constructor for BaseMBean.
     * </p>
     *
     * @param mbeanInterface a {@link java.lang.Class} object.
     * @param beanKey a {@link java.lang.String} object.
     * @param bundle a {@link java.util.ResourceBundle} object.
     */
    protected BaseMBean(ResourceBundle bundle, Class<?> mbeanInterface, String beanKey) {
        super(mbeanInterface, true);
        this.bundle = bundle;
        this.beanKey = beanKey;
    }

    /** {@inheritDoc} */
    @Override
    protected String getDescription(MBeanInfo info) {
        final String infoKey = String.format("%s.%s", beanKey, "description");

        try {
            return bundle.getString(infoKey);
        } catch (final MissingResourceException e) {
            log.debug(e.toString());
        } catch (final Exception e) {
            log.warn("Couldn't get bundle value for \"" + infoKey + "\".", e);
        }

        return super.getDescription(info);
    }

    /** {@inheritDoc} */
    @Override
    protected String getDescription(MBeanAttributeInfo info) {
        final String infoKey = String.format("%s.%s.%s", beanKey, //
            StringUtils.uncapitalize(info.getName()), "description");

        try {
            return bundle.getString(infoKey);
        } catch (final MissingResourceException e) {
            log.debug(e.toString());
        } catch (final Exception e) {
            log.warn("Couldn't get bundle value for \"" + infoKey + "\".", e);
        }

        return super.getDescription(info);
    }
}
