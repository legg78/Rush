package ru.bpc.sv2.constants;

public interface DictNames {
	public static final int ARTICLE_CODE_LENGTH				= 4;

	public static final String MAIN_DICTIONARY 				= "DICT";

	public static final String LIMIT_TYPES 					= "LMTP";
	public static final String LIMITS 						= "LIMT";
	public static final String SHIFT_TYPES 					= "CSHT";
	public static final String TRUNC_TYPES 					= "LNGT";
	public static final String LENGTH_TYPES 				= "LNGT";
	public static final String CYCLE_TYPES 					= "CYTP";
	public static final String CYCLES 						= "CYCL";
	public static final String ENTITY_TYPES					= "ENTT";
	public static final String FEE_BASES_CALC 				= "FEEB";
	public static final String FEE_LIMITS_CALC 				= "FEEL";
	public static final String FEE_RATES_CALC 				= "FEEM";
	public static final String FEES 						= "FEES";
	public static final String LANGUAGES 					= "LANG";

	public static final String TERMINAL_TYPE 				= "TRMT";
	public static final String CARD_DATA_INPUT_CAP 			= "F221";
	public static final String CRDH_AUTH_CAP 				= "F222";
	public static final String CARD_CAPTURE_CAP 			= "F223";
	public static final String TERM_OPERATING_ENV 			= "F224";
	public static final String CRDH_DATA_PRESENT 			= "F225";
	public static final String CARD_DATA_PRESENT 			= "F226";
	public static final String CARD_DATA_INPUT_MODE 		= "F227";
	public static final String CRDH_AUTH_METHOD 			= "F228";
	public static final String CRDH_AUTH_ENTITY 			= "F229";
	public static final String CARD_DATA_OUTPUT_CAP			= "F22A";
	public static final String TERM_DATA_OUTPUT_CAP 		= "F22B";
	public static final String PIN_CAPTURE_CAP 				= "F22C";
	public static final String CRDHDR_ACTIVATED_TERM_LVL 	= "F22D";
	public static final String TERMINAL_STATUS 				= "TRMS";

	public static final String MERCHANT_TYPE 				= "MRCT";
	public static final String MERCHANT_LICENSE_TYPE 		= "MRCL";
	public static final String MERCHANT_REPORT_TYPE 		= "MRCR";
	public static final String MERCHANT_STATUS 				= "MRCS";

	public static final String OPER_TYPE 					= "OPTP";
	public static final String FEE_TYPE 					= "FETP";
	public static final String ACCOUNT_TYPE 				= "ACTP";
	public static final String BALANCE_TYPE 				= "BLTP";
	public static final String BALANCE_STATUS 				= "BLST";
	public static final String ISO_TYPE			 			= "ACCT";

	public static final String AGENT_TYPE 					= "AGTP";
	public static final String ADDRESS_TYPE 				= "ADTP";

	public static final String DATA_TYPE 					= "DTTP";

	public static final String CONTACT_TYPE 				= "CNTT";
	public static final String JOB_TITLE 					= "JTTL";
	public static final String PERSON_TITLE 				= "PTTL";
	public static final String PERSON_SUFFIX 				= "PSFX";
	public static final String PERSON_GENDER 				= "GNDR";
	public static final String IDENTITY_CARD_TYPE			= "IDTP";
	public static final String IM_TYPE						= "IMTP";

	public static final String TRANSACTION_TYPE 			= "TRNT";
	public static final String POSTING_METHOD 				= "POST";

	public static final String AP_REJECT_CODES 				= "APRJ";
	public static final String AP_STATUSES 					= "APST";
	public static final String AP_TYPES 					= "APTP";

	public static final String STTL_TYPE 					= "STTT";
	public static final String MSG_TYPE 					= "MSGT";
	public static final String USER_STATUSES 				= "USST";

	public static final String ACCOUNT_STATUS 				= "ACST";

	public static final String PROCESS_FILE_TYPE 			= "FLTP";
	public static final String PROCESS_FILE_PURPOSE 		= "FLPS";

	public static final String AUTH_SCN_STATE_TYPE 			= "ASTP";

	public static final String HSM_STATUS 					= "HSMS";
	public static final String HSM_PLUGINS 					= "HSMP";
	public static final String HSM_MANUFACTURERS 			= "HSMM";
	public static final String HSM_COMMUNICATION_TYPE 		= "HSMC";

	public static final String BUSINESS_ENTITIES 			= "ENTT";

	public static final String ISSUING_PRODUCT 				= "IPRD";
	public static final String ACQUIRING_PRODUCT 			= "APRD";
	public static final String ACCOUNT 						= "ACCT";
	public static final String CARD 						= "CARD";
	public static final String SCALE_TYPE 					= "SCTP";

	public static final String RESPONSE_CODE 				= "RESP";
	public static final String RESPONSE_CODE_IP 			= "RCIP";
	public static final String RESPONSE_CODE_MASTER_CARD 	= "RCMC";
	public static final String APPLICATION_PLUGIN 			= "APPL";

	public static final String REIMBURSEMENT_STATUS 		= "REBS";

	public static final String DES_KEY_TYPE 				= "ENKT";
	public static final String DES_KEY_LENGTH 				= "SDKL";

	public static final String CMN_STANDARD_TYPE 			= "STDT";

	public static final String RATE_TYPE 					= "RTTP";
	public static final String RATE_STATUS 					= "RTST";

	public static final String PROC_STAGE 					= "PSTG";
	public static final String RULE_CATEGORIES 				= "RLCG";
	public static final String PRODUCT_STATUSES 			= "PRDS";

	public static final String TCP_INITIATOR 				= "TCPI";
	public static final String TCP_FORMAT 					= "TCPF";

	public static final String INSTITUTION_TYPES 			= "INTP";
	public static final String COMMUNICATION_PLUGIN 		= "CMPL";

	public static final String CHECK_ALGORITHMS 			= "CHCK";
	public static final String PAD_TYPES					= "PADT";
	public static final String TRANSFORMATION_TYPES			= "TSFT";
	public static final String BASE_VALUE_TYPES				= "BVTP";
	public static final String INDEX_RANGE_ALGORITHMS		= "IRAG";

	public static final String NOTE_TYPES					= "NTTP";
	public static final String EVENT_TYPES					= "EVNT";

	public static final String ACQUIRING_APPLICATION		= "ACQA";
	public static final String ISSUING_APPLICATION			= "ISSA";
	public static final String PAYMENT_ORDERS_APPLICATION	= "PMNO";

	public static final String PVV_STORE_METHODS			= "PVSM";
	public static final String PIN_STORE_METHODS			= "PNSM";
	public static final String PIN_VERIFY_METHODS			= "PNVM";

	public static final String PIN_REQUEST					= "PNRQ";
	public static final String PIN_MAILER_REQUEST			= "PMRQ";
	public static final String EMBOSSING_REQUEST			= "EMRQ";
	public static final String ONLINE_STATUS				= "OLST";
	public static final String PERSO_PRIORITY				= "PRSP";
	public static final String BATCH_STATUSES				= "BTST";

	public static final String HSM_SELECTION_ACTIONS		= "HSAC";
	public static final String REPORT_SOURCE_TYPES			= "RPTS";
	public static final String REPORT_STATUSES				= "RPST";
	public static final String REPORT_BANNER_STATUSES		= "BNST";

	public static final String REISSUE_COMMAND				= "RCMD";
	public static final String REISSUE_EXPIRY_DATE_RULE		= "EDRL";
	public static final String REISSUE_START_DATE_RULE		= "SDRL";

	public static final String ALGORITHM_STEP				= "ALGS";
	public static final String MATCH_STATUS					= "MTST";
	public static final String DEFINITION_LEVEL				= "SADL";
	public static final String SERVICE_STATUS				= "SRVS";

	public static final String SECURITY_QUESTION			= "SEQU";

	public static final String SCHEME_TYPE					= "NTFS";
	public static final String TEMPLATE_TYPE 				= "AUTM";
	public static final String AUTH_SCHEME_TYPE				= "AUSC";

	public static final String LOV_SORT_MODE				= "LVSM";
	public static final String LOV_APPEARANCE				= "LVAP";

	public static final String TAG_TYPE						= "ATTP";
	public static final String OPERATION_CHECK_TYPES		= "OPCK";
	public static final String PARTY_TYPE					= "PRTY";
	public static final String ID_TYPES						= "IDTP";

	public static final String MATRIX_TYPE					= "MTTP";
	public static final String CHECK_TYPE					= "CHTP";
	public static final String ALERT_TYPE					= "ALTP";

	public static final String CONTRACT_TYPE				= "CNTP";

	public static final String EMV_PERSO_FILE_FORMAT		= "EPFF";
	public static final String CARD_CONFIG					= "CCFG";

	public static final String CALL_MODES					= "CACM";

	public static final String CONV_TYPE 					= "CNVT";

	public static final String DEBT_STATUS					= "DBTS";
	public static final String PAYMENT_STATUS				= "PMTS";
	
	public static final String CARD_STATE 					= "CSTE";
	public static final String CARD_STATUS					= "CSTS";
	public static final String TOKEN_STATUS					= "TSTS";
	public static final String PIN_PRESENCE					= "PINP";
	
	public static final String PAYMENT_TEMPLATE_STATUS 		= "POTS";
	public static final String PMO_EXECUTION_TYPE 			= "POET";
	
	public static final String OPERATION_STATUS 			= "OPST";
	public static final String PRODUCT_TYPE 				= "PRDT";
	
	public static final String AUTH_PROCESSING_TYPE			= "AUPT";
	public static final String AUTH_PROCESSING_MODE			= "AUPM";
	public static final String AUTH_STATUS_REASON			= "AUSR";
	public static final String AUTH_STATUS					= "AUST";
	public static final String ENCRYPTION_KEY_LENGTH		= "ENKL";
	public static final String ENCRYPTION_KEY_PREFIX		= "ENKP";
	
	public static final String PAYMENT_AMOUNT_ALGORITHMS	= "POAA";
	public static final String VOUCHERS_BATCH_STATUS		= "VCBS";
	public static final String STATUS_REASON				= "VCSR";
	public static final String ATM_INSTALLATION_PLACE 		= "ATMP";
	public static final String ATM_SERVICE_STATUS	 		= "ASST";
	public static final String HARDWARE_CONF_DATA			= "HCDT";
	
	public static final String CARD_READER_STATUS_ATM		= "CARS";
	public static final String DISPENSER_STATUS_ATM			= "DIST";
	public static final String CASSETTE_STATUS_ATM			= "CSST";
	public static final String PRINTER_STATUS_ATM			= "CSST";
	public static final String PRINTER_PAPER_STATUS_ATM		= "PPST";
	public static final String PRINTER_RIBBON_STATUS_ATM	= "RBST";
	public static final String PRINTER_PRT_HEAD_STATUS_ATM	= "HDST";
	public static final String PRINTER_KNIFE_STATUS_ATM		= "KNST";
	public static final String TIME_OF_D_CLOCK_STATUS_ATM	= "TDST";
	public static final String DEPOSITORY_STATUS_ATM		= "DSST";
	public static final String NIGHT_SAFE_DEPS_STATUS_ATM	= "NDST";
	public static final String ENCRYPTOR_STATUS_ATM			= "ENST";
	public static final String TOUCH_SCREEN_KEY_STATUS_ATM	= "TKST";
	public static final String CAMERA_STATUS_ATM			= "CAMS";
	public static final String VOICE_GUIDANCE_STATUS_ATM	= "VGST";
	public static final String BUNCH_NOTE_ACC_STATUS_ATM	= "BAST";
	public static final String ENVELOPE_DISP_STATUS_ATM		= "EDST";
	public static final String CHEQUE_PROC_STATUS_ATM		= "CPST";
	public static final String COIN_DISPENSER_STATUS_ATM	= "CDST";
	public static final String WORKFLOW_STATUS_ATM			= "AWST";
	public static final String STMNT_PRN_CAP_STATUS_ATM		= "SCBS";
	public static final String JOURNAL_STATUS_ATM			= "JRNL";
	public static final String BARCODE_READER_STATUS_ATM	= "BRST";
	
	public static final String HOST_STATUS					= "HSST";
	
	public static final String DOCUMENT_CONTENT_TYPES		= "DCCT";
	public static final String DOCUMENT_TYPE 				= "DCMT";
	public static final String FILE_SIGNATURE_TYPE			= "FSIT";
	public static final String AUDIT_STATUS					= "UAST";
	public static final String CLIENT_IDENTIFICATION_TYPE	= "CITP";
	public static final String ENTITY_STATUS_CHANGE_INIT	= "ENSI";

	public static final String JCB_LOAD_TYPE				= "JCBV";
	public static final String DIN_LOAD_TYPE				= "DINV";

	public static final String VISA_SMS_REPORT_STATUSES		= "CLMS";

	public static final String MIR_TRANSACTION_REPORT_TYPES	= "MTRT";

	public static final String INSTITUTE_STATUSES			= "INSS";
	public static final String DATA_ACTIONS					= "DACT";

	public static final String MC_ABU_MESSAGE_STATUSES		= "ABUS";
	public static final String MC_ABU_FILE_FORMATS			= "ABUF";

	public static final String ALGORITHM_ENTRY_POINT		= "ALGE";
}
