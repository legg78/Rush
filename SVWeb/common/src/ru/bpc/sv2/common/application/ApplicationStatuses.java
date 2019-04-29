package ru.bpc.sv2.common.application;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public interface ApplicationStatuses {
	public static final int VALUE_LENGTH = 8;
    public static final String DICTIONARY_NAME          = "APST";
    public final static String UNDEFINED                = "APST0000";
    public final static String JUST_CREATED             = "APST0001";
    public final static String AWAITING_CONFIRM         = "APST0002";
    public final static String AWAITING_CORRECTION      = "APST0003";
    public final static String AWAITING_CHECKING        = "APST0004";
    public final static String FURTHER_INFO             = "APST0005";
    public final static String AWAITING_PROCESSING      = "APST0006";
    public final static String PROCESSES_SUCCESSFULLY   = "APST0007";
    public final static String PROCESSING_FAILED        = "APST0008";
    public final static String SYNCHRONIZE_OBJECTS      = "APST0009";
    public final static String DUPLICATED               = "APST0010";
    public final static String READY_FOR_REVIEW         = "APST0011";
    public final static String ACCEPTED                 = "APST0012";
    public final static String REJECTED                 = "APST0013";
    public final static String PENDING                  = "APST0014";
    public final static String IN_PROGRESS              = "APST0015";
    public final static String RESOLVED                 = "APST0016";
    public final static String CLOSED                   = "APST0017";
    public final static String APPROVING_WRITE_OFF      = "APST0018";
    public final static String SUCCESS_EVALUATION       = "APST0019";
    public final static String FAILED_EVALUATION        = "APST0020";
    public final static String CLOSED_WO_INVESTIGATION  = "APST0021";


    public final static Set<String> CLOSED_STATUSES = new HashSet<String>(Arrays.asList(
		    ApplicationStatuses.CLOSED,
		    ApplicationStatuses.CLOSED_WO_INVESTIGATION
    ));
}
