package ru.bpc.sv2.jmx.utils;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * <p>DateUtils class.</p>
 *
 * @author Malyanov Dmitry
 * @version $Id: 0f97bdc26dfdfb9c1be59414405a90c021a948d9 $
 */
public final class DateUtils {
    private static ThreadLocal<DateFormat> format = new ThreadLocal<DateFormat>() {
        @Override
        protected DateFormat initialValue() {
            return new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
        }
    };

    /**
     * <p>
     * format.
     * </p>
     *
     * @param date a {@link java.util.Date} object.
     * @return a {@link java.lang.String} object.
     */
    public static final String format(Date date) {
        return format.get().format(date);
    }
}
