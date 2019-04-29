/*
 * DataItem.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.mbean;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import javax.management.DescriptorKey;

/**
 * <p>DataItem class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 934566c81f0afdc08e30c3066c9c9b252cf376b5 $
 */
@Documented
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface DataItem {
    @DescriptorKey("units")
    String units() default "";

    @DescriptorKey("currencyTimeLimit")
    long timeout() default -1;
}
