package ru.bpc.sv2.common.application;

public interface ApplicationFlows {
    public static int DSP_INVESTIGATION        = 1501;
    public static int DSP_INTERNAL             = 1502;
    public static int DSP_ISS_DOMESTIC         = 1503;
    public static int DSP_ACQ_DOMESTIC         = 1504;
    public static int DSP_ISS_INTERNATIONAL    = 1505;
    public static int DSP_ACQ_INTERNATIONAL    = 1506;

    public static int FRQ_UNHOLD_AUTHORIZATION = 1601;
    public static int FRQ_BALANCE_CORRECTION   = 1602;
    public static int FRQ_BALANCE_TRANSFER     = 1603;
    public static int FRQ_COMMON_OPERATION     = 1604;
    public static int FRQ_WRITE_OFF            = 1605;

    public static int FRQ_ID_REPROCESS_OPER = 1606;
    public static int FRQ_ID_CHANGE_OPER_STATUS = 1607;
    public static int FRQ_ID_MATCH_OPER_MANUALLY = 1608;
    public static int FRQ_ID_MATCH_REVERSAL_OPER = 1609;
    public static int FRQ_FEE_COLLECTION       = 1610;
    public static int FRQ_ID_SET_OPER_STAGE = 1611;
    public static int FRQ_ID_LTY_SPENT_OPERATION = 1612;

    public static int REISSUE_CARD = 5;
    public static int CHANGE_CONTRACT = 1010;
}
