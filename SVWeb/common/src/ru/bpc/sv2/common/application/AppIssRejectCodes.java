package ru.bpc.sv2.common.application;

public interface AppIssRejectCodes {
    public final static String INVALID              = "APRJ0003";
    public final static String CREDIT_TO_CARDHOLDER = "APRJ0004";
    public final static String CARDHOLDER_TO_BEAR   = "APRJ0005";
    public final static String WRITE_OFF            = "APRJ0006";
    public final static String ACCEPTED             = "APRJ0007";
    public final static String REPRESENTED          = "ACCR0008";
    public final static String UNFULFILLED          = "APRJ0009";
    public final static String FULFILLED            = "APRJ0010";
    public final static String UNRESOLVED           = "APRJ0011";
}
