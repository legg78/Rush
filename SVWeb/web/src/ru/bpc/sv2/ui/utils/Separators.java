package ru.bpc.sv2.ui.utils;

import java.util.HashMap;
import java.util.Map;

public enum Separators {
    DOT_NO_SEPARATOR("SPRT0000", ""),
    DOT_COMMA("SPRT0001", ","),
    DOT_SPACE("SPRT0002", " "),
	COMMA_NO_SEPARATOR("SPRT0003", ""),
	COMMA_DOT("SPRT0004", "."),
	COMMA_SPACE("SPRT0005", " ");

    private final String code;
    private final String separator;
    private static final Map<String, Separators> enums = new HashMap<String, Separators>();

    static {
        for (Separators ls : Separators.values())
            enums.put(ls.code, ls);
    }

    private Separators(String code, String separator) {
        this.code = code;
        this.separator = separator;
    }

    public String getSeparator() {
        return separator;
    }

    public static Map<String, Separators> getSeparators() {
        return enums;
    }
}
