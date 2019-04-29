package ru.bpc.sv2.constants.schedule;

public interface ProcessConstants {
	public static final int COMPLETED_ERROR = 0;
	public static final int COMPLETED_OK = 1;
	public static final int STAT_THRESHOLD = 100;

	public static final String OPERATION_NAME = "OPERATION_NAME";
	public static final String ENDPOINT = "ENDPOINT";
	public static final String NAMESPACE = "NAMESPACE";
	public static final String PORT_NAME = "PORT_NAME";
	public static final String SOAP_ACTION_URI = "SOAP_ACTION_URI";

	public static final String PROCESSED_FOLDER = "processed";
	public static final String IN_PROCESS_FOLDER = "in_process";
	public static final String REJECTED_FOLDER = "rejected";

	public static final String PROCESS_LOCKED = "PRSR0000";
	public static final String PROCESS_IN_PROGRESS = "PRSR0001";
	public static final String PROCESS_FINISHED = "PRSR0002";
	public static final String PROCESS_FAILED = "PRSR0003";
	public static final String PROCESS_FINISHED_WITH_ERRORS = "PRSR0004";
	public static final String PROCESS_THREAD_INTERRUPT = "PRSR0005";

	public static final String FILE_PURPOSE_INCOMING = "FLPSINCM";
	public static final String FILE_PURPOSE_OUTGOING = "FLPSOUTG";

	public static final String FILE_NATURE_XML = "FLNT0010";
	public static final String FILE_NATURE_PLAIN = "FLNT0020";
	public static final String FILE_NATURE_LOB = "FLNT0030";
	public static final String FILE_NATURE_REPORT = "FLNT0040";
	public static final String FILE_NATURE_BLOB = "FLNT0050";

	public static final String FILE_STATUS_ACCEPTED = "FLSTACPT";
	public static final String FILE_STATUS_REJECT = "FLSTRJCT";
	public static final String FILE_STATUS_POSTPROCESSING = "FLSTPOST";
	public static final String FILE_STATUS_MERGED = "FLSTMRGD";

	public static final String FILE_TYPE_NBC_FAST = "FLTPNBFT";
	public static final String FILE_TYPE_CBS_AMK_RECONCILIATION = "FLTP2100";
	public static final String FILE_TYPE_HOST_RECONCILIATION = "FLTP2200";
	public static final String FILE_TYPE_RESPONSE = "FLTPRSPF";
	public static final String FILE_TYPE_REPORT = "FLTPROUT";
	public static final String FILE_TYPE_CREF_UNLOAD = "FLTPCINF";
	public static final String FILE_TYPE_TURNOVER_ACCOUNTS = "FLTPTRAC";
	public static final String FILE_TYPE_PERSONS = "FTYPPINF";
	public static final String FILE_TYPE_COMPANIES = "FLTPCPIF";

	public static final String NO_FILE_SIGNATURE = "FSIT0000";
	public static final String FILE_SIGNATURE_SEPARATELY = "FSIT0001";
	public static final String SIGNATURE_SUFFIX = ".sign";

	public final static String DOCUMENT_TYPE_PARAM = "I_DOCUMENT_TYPE";
	public static final String TIMEOUT_PARAM = "I_TIMEOUT";
	public final static String OLTP_IP_ADDRESS_IN_USER_SESSION = "OLTP";

	@Deprecated
	public static final String FILE_STATUS_LOADED = "PSFS0001";
	@Deprecated
	public static final String FILE_STATUS_PROCESSED = "PSFS0002";
	@Deprecated
	public static final String FILE_STATUS_FAILED = "PSFS0003";
	@Deprecated
	public static final String FILE_STATUS_REJECTED = "PSFS0004";
	@Deprecated
	public static final String FILE_STATUS_AWAITS_POSTPROCESSING = "PSFS0005";
}
