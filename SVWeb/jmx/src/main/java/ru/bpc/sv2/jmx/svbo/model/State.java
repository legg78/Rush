package ru.bpc.sv2.jmx.svbo.model;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;

import ru.bpc.sv2.jmx.utils.DateUtils;

/**
 * <p>
 * State class.
 * </p>
 *
 * @author Malyanov Dmitry
 * @version $Id: 4920c7116d43bfb9f970e95d390a3d03871d48e7 $
 */
public enum State {
    LOCKED("Locked", false), //
    IN_PROGRESS("In progress", false), //
    SUCCESSFULLY_FINISHED("Success", true), //
    FAILED("Failure", true), //
    FINISHED_WITH_ERRORS("Finished with errors", true), //
    INTERRUPT("Interrupted", true), //
    UNDEFINED("Undefined", false);

    /** Constant <code>statesMap</code> */
    private static final Map<String, State> statesMap;
    static {
        statesMap = new HashMap<>();
        statesMap.put("PRSR0000", State.LOCKED);
        statesMap.put("PRSR0001", State.IN_PROGRESS);
        statesMap.put("PRSR0002", State.SUCCESSFULLY_FINISHED);
        statesMap.put("PRSR0003", State.FAILED);
        statesMap.put("PRSR0004", State.FINISHED_WITH_ERRORS);
        statesMap.put("PRSR0005", State.INTERRUPT);
    }

    private final String label;
    private final boolean timed;

    private State(String label, boolean timed) {
        this.label = label;
        this.timed = timed;
    }

    /**
     * <p>toZabbix.</p>
     *
     * @param toAppend a {@link java.util.Date} object.
     * @return a {@link java.lang.String} object.
     */
    public final String toZabbix(Date toAppend) {
        final StringBuilder buffer = new StringBuilder();
        buffer.append(label);
        if (timed && toAppend != null) {
            buffer.append(' ').append(DateUtils.format(toAppend));
        }
        return buffer.toString();
    }

    /**
     * <p>
     * fromSymbol.
     * </p>
     *
     * @param symbol a {@link java.lang.String} object.
     * @return a {@link State} object.
     */
    public static final State fromSymbol(String symbol) {
        if (StringUtils.isEmpty(symbol)) {
            return State.UNDEFINED;
        }

        return ObjectUtils.defaultIfNull(statesMap.get(symbol), UNDEFINED);
    }

}
