/*
 * JSON.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.utils;

import java.text.SimpleDateFormat;

import com.fasterxml.jackson.annotation.JsonInclude.Include;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

/**
 * <p>
 * JSON class.
 * </p>
 *
 * @author Ilya Yushin
 * @version $Id: eab3e35874651bd3fc65b91c76e07fbff1250e1f $
 */
public class JSON {
    private static final ObjectMapper defaultMapper = createDefaultMapper();
    private static final ObjectMapper prettyMapper = createPrettyMapper();

    private JSON() {
    }

    /**
     * Creates a new {@link ObjectMapper} that can be used to serializing objects.
     *
     * @return resulting default mapper instance
     */
    private static final ObjectMapper createDefaultMapper() {
        return new ObjectMapper() //
            .setSerializationInclusion(Include.NON_NULL) //
            .enable(SerializationFeature.WRITE_NULL_MAP_VALUES) //
            .disable(SerializationFeature.FAIL_ON_EMPTY_BEANS) //
            .setDateFormat(new SimpleDateFormat("dd.MM.yyyy HH:mm:ss"));
    }

    /**
     * Creates a new {@link ObjectMapper} that can be used to pretty printing objects.
     *
     * @return resulting pretty mapper instance
     */
    private static final ObjectMapper createPrettyMapper() {
        return createDefaultMapper().enable(SerializationFeature.INDENT_OUTPUT);
    }

    /**
     * Encodes a given <tt>source</tt> object into a JSON string.
     *
     * @param source the source object
     * @return resulting JSON string or <tt>null</tt> if the <tt>source</tt> was <tt>null</tt>
     */
    public static final String toJsonString(Object source) {
        if (source == null) {
            return null;
        }
        try {
            return defaultMapper.writer().writeValueAsString(source);
        } catch (final JsonProcessingException e) {
            return e.toString();
        }
    }

    /**
     * Encodes a given <tt>source</tt> object into a indented JSON string.
     *
     * @param source the source object
     * @return resulting JSON string or <tt>null</tt> if the <tt>source</tt> was <tt>null</tt>
     */
    public static final String toPrettyJsonString(Object source) {
        if (source == null) {
            return null;
        }
        try {
            return prettyMapper.writer().writeValueAsString(source);
        } catch (final JsonProcessingException e) {
            return e.toString();
        }
    }
}
