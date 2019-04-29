package ru.bpc.sv2.ui.reports.constructor.support;

/**
 * Created by Sonin on 18.05.2016.
 */
public enum LogicalOperator {

        AND("AND"),
        OR("OR"),
        BRACKET("(...)");

        private final String value;

        public String getValue() {
            return value;
        }

        private LogicalOperator(String value) {
            this.value = value;
        }
}