package ru.bpc.sv2.process.btrt;

import java.util.HashMap;
import java.util.Map;

public enum BTRTMapping {
	CARD_STATUS_CHANGE_BLOCK("FF8020"),
	ACCOUNT_STATUS_CHANGE_BLOCK("FF8021"),
	
	// self-defined codes
	// TODO: it's better to get rid of them to not to get confused
	PERSO_PRIORITY("PERSO_PRIORITY"),
	CONTACT_TYPE("CONTACT_TYPE"),
	PREFERRED_LANG("PREFERRED_LANG"),
	CATEGORY("CATEGORY"),
	CARDHOLDER_NUMBER("CARDHOLDER_NUMBER"),
	// -------------------
	
	//PRODUCT_ID("DF9000"),
	APPLICATION_FLOW_ID("DF9001"),
	CONTRACT_TYPE("DF9002"),
	CUSTOMER_TYPE("DF9003"),
	CARD_BRANCH("DF9004"),
	ACCOUNT_BRANCH("DF9005"),
	PERSON_NAME("DF9006"),
	ADDRESS_NAME("DF9007"),
	MERCHANT_BRANCH("DF9008"),
	SEC_WORD("DF900A"),
	SECRET_QUESTION("DF900B"),
	SECRET_ANSWER("DF900C"),
	CONTRACT("DF900D"),
	CONTACT_DATA("DF900E"),
	COMMUN_METHOD("DF900F"),
	COMMUN_ADDRESS("DF9010"),
	BTRT55("DF9011"),
	TERMINAL("DF9012"),
	APPLICATION_NUMBER("DF9013"),
	COMPANY("DF9014"),
	CARDHOLDER_NAME("DF9015"),
	SERVICE("DF9016"),
	SERVICE_OBJECT("DF9017"),
	ATTRIBUTE_LIMIT("DF9018"),
	LIMIT_SUM_VALUE("DF9019"),
	ATTRIBUTE_CHAR("DF901A"),
	ATTRIBUTE_VALUE_CHAR("DF901B"),
	ACCOUNT_OBJECT("DF901F"),
	//Flexible fields
	OWNERSHIP_TYPE("DF901C"),
	PARENT_CUSTOMER("DF901D"),
	ORIGIN_APPL_NUMBER("DF901E"),
	//Application with card account
	BTRT01("FFFF01"),
	BTRT02("FFFF02"),
	BTRT03("FFFF03"),
	BTRT04("FFFF04"),
	//BTRT05("FFFF05"),
	BTRT06("FFFF06"),
	BTRT07("FFFF07"),
	BTRT08("FFFF08"),
	BTRT10("FFFF09"),	
	BTRT15("FFFF17"),
	BTRT18("FFFF49"),
	BTRT19("FFFF34"),
	BTRT20("FFFF0A"),	
	BTRT25("FFFF0C"),
	//Application customer with contact info 
	BTRT05("FFFF05"),
	BTRT21("FFFF0B"),
	BTRT30("FFFF0D"),
	BTRT35("FFFF0E"),
	BTRT40("FFFF16"),
//	BTRT52("FFFF10"),
//	BTRT53("FFFF11"),
//	BTRT54("FFFF12"),
	// Merchant application
	BTRT51("FFFF0F"),//has contact info
	BTRT53("FFFF11"),//has contact info
	BTRT54("FFFF12"),
//	BTRT55("FFFF0F"),
	BTRT56("FFFF35"),//has contact info
	BTRT59("FFFF41"),
	BTRT60("FFFF13"),
	// Terminal application
	BTRT52("FFFF10"),
	
	SEQUENCE("DF805D"),
	VERSION("DF805E"),
//	CARDHOLDER_APPLICATION_BTRT01("FFFF01"),
	
	//FFFF33 APP FILE PROCESSING RESPONSE
	APP_FILE_PROCESSING_RESPONSE("FFFF33"),
	FILE_PROCESSING_RESULT("FF8050"),
	FILE_PROCESSING_RESULT_MSG("DF8439"),
	ORIGINAL_FILE_NAME("DF8436"),
	FILE_PROCESSING_DATE("DF8437"),
	FILE_PROCESSING_RESULT_CODE("DF8438"),
	FILE_REFERENCE_NUMBER("DF8267"),
	// FF45 File Header Block
	APP_FILE_HEADER("FF45"),
	FILE_HEADER("FF49"),
	FILE_TYPE("DF807D"),
	APPLICATION_DATE("DF807C", "dd.MM.yyyy_hh:mm:ss"),
	INSTITUTION_ID("DF8079"),
	AGENT_ID("DF807A"),
	// FF46 File Trailer Block
	APP_FILE_TRAILER("FF46"),
	FILE_TRAILER("FF4A"),
	NUMBER_OF_RECORDS("DF807E"),
	CRC("DF8060"),
	// FF8034 APPLICATION_ERROR_BLOCK
	ERROR("FF8034"),
	ERROR_CODE("DF8307"),
	ERROR_TYPE("DF8308"),
	ERROR_DESC("DF8309"),
	ERROR_BLOCK_UNIQUE_SEQ("DF830A"),
	ERROR_ELEMENT("DF830B"),
	// FF2E MAIN_BLOCK
	MAIN_BLOCK("FF2E"),
	APPLICATION_ID("DF8041"),
	APPLICATION_TYPE("DF8000"),
	FILE_REC_NUM("DF8001"),
	PRODUCT_ID("DF8002"),
	PRIMARY_FLAG("DF803A"),
	APPLICATION_STATUS("DF834B"),
	APPLICATION_REJECT_CODE("DF803D"),
	APPLICATION_SOURCE("DF803E"),
	OPERATOR_ID("DF803F"),
	APPLICATION_LETTER_SCHEME("DF8040"),
	DELIVERY_INFORMATION("DF8046"),
	REJECT_REASON("DF8456"),
	BATCH_ID("DF8474"),
	//PARAMETER BLOCK
	ADDITIONAL_PARAMETERS_BLOCK("FF8054"),
	PARAMETER("FF804B"),
	PARAMETER_NAME("DF842B"),
	PARAMETER_VALUE("DF842C"),
	
	// FF20 CUSTOMER_BLOCK
	CUSTOMER("FF20"),
	CUSTOMER_NUMBER("DF8003"),
	CUSTOMER_CATEGORY("DF8006"),
	STATEMENT_SCHEME("DF8521"),
	CUSTOMER_DESCRIPTION("DF8004"),
	CUSTOMER_RELATION("DF8005"),
	DELIVERY_AGENT_CODE_CUSTOMER("DF8047"),
	INSIDER_FLAG("DF827D"),
	INN("DF8418"),
	KPP("DF8419"),
	OKPO("DF8330"),
	
	CONTACT("FF8002"),
	// FF806C DOCUMENT_BLOCK
	IDENTITY_CARD("FF806C"),	
	DOCUMENT_ID("DF8523"),
//	DOCUMENT_TYPE("DF803B"),
//	NUMBER("DF803C"),
//	SERIES("DF8261"),
//	AUTHORITY("DF8344"),
//	ISSUE_DATE("DF8345", "dd.MM.yyyy"),
//	EXPIRE_DATE("DF8346", "dd.MM.yyyy"),
	
	// FF2C - CARD_HOLDER
	CARDHOLDER("FF2C"),
	// FF22 PERSON_BLOCK
	PERSON("FF22"),
	FIRST_NAME("DF8019"),
	SECOND_NAME("DF801A"),
	SURNAME("DF801B"),
	BIRTHDAY("DF801C", "MMddyyyy"),
	COMMAND("DF8108"),//PERSON_PROCESSING_MODE
	COMPANY_NAME("DF800F"),
	SECURITY_ID_1("DF8013"),
	SECURITY_ID_2("DF8014"),
	SECURITY_ID_3("DF8015"),
	SECURITY_ID_4("DF8016"),
	SECURITY_ID_5("DF8017"),
	GENDER("DF8008"),
	MARITAL_STATUS("DF8009"),
	RESIDENCE("DF800A"),
	NUMBER_OF_DEPENDENTS("DF800B"),
	DOMAIN("DF800C"),
	POSITION("DF800D"),
	EMPLOYED_FLAG("DF800E"),
	ANNUAL_INCOME_RANGE("DF8010"),
	MONTHLY_DEDUCTIONS("DF8011"),
	PERSON_TITLE("DF8018"),
	LANGUAGE_CODE("DF8012"),
	ACCOUNT_SCHEME("DF8379"),
	ENTRIES_SCHEME("DF837A"),
	//INN_PERSON("DF8418"),
	//INSIDER_FLAG("DF827D"),
	SIGN_TO_USE_BUREAU_CREDIT_STORIES("DF8452"),
	GMT_OFFSET("DF815B"),
	SECURITY_QUESTION_1("DF8431"),
	SECURITY_QUESTION_2("DF8432"),
	SECURITY_QUESTION_3("DF8433"),
	SECURITY_QUESTION_4("DF8434"),
	SECURITY_QUESTION_5("DF8435"),
	PLACE_OF_BIRTH("DF847C"),
	// Person ID block
	PERSON_ID("DF8007"),
	ID_TYPE("DF803B"),//TYPE_OF_THE_PERSON_ID
	ID_NUMBER("DF803C"),//NUMBER_OF_THE_PERSON_ID
	ID_SERIES("DF8261"),//SERIES_OF_THE_PERSON_ID
	ID_ISSUER("DF8344"),//PERSON_ID_AUTHORITY
	ID_ISSUE_DATE("DF8345", "dd.MM.yyyy"),//PERSON_ID_ISSUE_DATE
	ID_EXPIRE_DATE("DF8346", "dd.MM.yyyy"),//PERSON_ID_EXPIRE_DATE
	NEW_ID_TYPE("DF8262"),//NEW_TYPE_OF_THE_PERSON_ID
	NEW_ID_NUMBER("DF8263"),//NEW_NUMBER_OF_THE_PERSON_ID
	NEW_ID_SERIES("DF8264"),//NEW_SERIES_OF_THE_PERSON_ID
	
	// FF2A ADDRESS_BLOCK
	ADDRESS("FF2A"),
	ADDRESS_ID("DF801D"),
	ADDRESS_TYPE("DF801E"),
//	COMMAND("DF8108"),//ADDRESS_PROCESSING_MODE
	HOUSE("DF8020"),
	ADDRESS_LINE_2("DF8021"),
	ADDRESS_LINE_3("DF8022"),
	ADDRESS_LINE_4("DF8023"),
//	HOUSE("DF801F"),
	ROUTE("DF8478"),
//	REGION("DF8024"),
	COUNTRY("DF8025"),
	POSTAL_CODE("DF8026"),
	GPS_CORDS("DF8515"),
	PRIMARY_PHONE("DF8027"),
	SECONDARY_PHONE("DF8028"),
	MOBILE_PHONE("DF8029"),
	FAX("DF802A"),
	EMAIL("DF802B"),
	APARTMENT("DF8530"),
	BUILDING_NUMBER("DF8532"),
	BUILDING_NAME("DF8533"),
	REGION_TYPE("DF855E"),
	REGION("DF855F"),
	DISTRICT_NAME("DF8560"),
	POPULATED_AREA_TYPE("DF8561"),
	POPULATED_AREA_NAME("DF8562"),
	STREET_TYPE("DF8563"),
	CITY("DF8564"),
	STREET("DF8565"),
	// FF24 - CARD_BLOCK
	CARD("FF24"),
	CARD_INIT("FF33"),
	CARD_NUMBER("DF802C"),	
	CARD_TYPE("DF802F"),
	CARD_COUNT("DF8043"),
	// FF34 CARD_DATA_BLOCK
	CARD_DATA("FF34"),
	CARD_REISSUE_DATA("FF4B"),
	EMBOSSED_NAME("DF8042"),
	EXPRESS_FLAG("DF8048"),
	DEFAULT_ATM_ACCOUNT("DF8030"),
	DEFAULT_POS_ACCOUNT("DF8031"),
	CARD_STATUS("DF802E"),
	HOT_CARD_STATUS("DF8175"),
	CARD_PRIMARY("DF802D"),
	BANK_CARD_FLAG("DF804F"),
	CARD_RELINK_FLAG("DF8050"),
	MEMBERSHIP_DATE("DF8219"),
	PROGRAM_CLASS("DF8222"),
	EXPIRATION_DATE("DF8078", "MMyy"),
	CYCLE_SCHEME("DF820F"),
	LIMITS_SCHEME("DF8210"),
	FEE_SCHEME("DF8213"),
	CURRENCY_RATE_MODIFIER_SCHEME("DF862D"),
	LETTER_SCHEME("DF8040"),
	HOT_CARD_STATUS_REASON("DF8454"),
	OBJECT_SERVICE_SCHEME("DF8410"),
	CARDHOLDER_PHOTO_FILENAME("DF840D"),
	CARDHOLDER_SIGN_FILENAME("DF840E"),
	TROUBLE_PIN("DF8520"),
	CARD_PLAST_TYPE("DF8354"),
	DATE_OF_CARD_PRODUCTION("DF860B"),
	// FF32 - CARD_LIMIT
	CARD_LIMIT("FF32"),
	CARD_ATM_LIMIT("DF8056"),
	CARD_POS_LIMIT("DF8057"),
	CARD_USAGE_LIMIT("DF8058"),
	CARD_AGGREGATE_LIMIT("DF805A"),
	CARD_CREDIT_LIMIT("DF8059"),
	
	// FF30 REG_RECORD_BLOCK
	REG_RECORD("FF30"),
	REG_RECORD_STATUS("DF8049"),
	//REG_RECORD_START_DATE("DF804A", "MMddyyyy"),
	
	//FF8026 - FLEXIBLE LIMIT BLOCK
	FLEXIBLE_LIMIT_BLOCK("FF8026"),
	FLEXIBLE_LIMIT_TYPE("DF8236"),
	FLEXIBLE_LIMIT_VALUE("DF8237"),
	LIMIT_START_DATE("DF8240", "yyyyMMdd"),
	LIMIT_END_DATE("DF8475", "yyyyMMdd"),
	LIMIT_PRIORITY("DF8476"),
	LIMIT_CURRENCY("DF808E"),
	
	// FF805E DELIVERY_BLOCK
	DELIVERY_BLOCK("FF805E"),
	DELIVERY_INSTRUCTIONS("DF846E"),
	DELIVERY_AGENT_CODE("DF820D"),
	
	//FF26 - ACCOUNT_BLOCK
	ACCOUNT("FF26"),
	// FF36 ACCOUNT_INIT_BLOCK
	ACCOUNT_INIT("FF36"),
	ACCOUNT_NUMBER("DF8033"),
	ACCOUNT_TYPE("DF8035"),
	CURRENCY("DF8034"),
	NEW_ACCOUNT_NUMBER_TO_OPEN("DF810E"),
	ABS_ACCOUNT_NUMBER("DF8350"),
	// FF37 - ACCOUNT_DATA
	ACCOUNT_DATA("FF37"),
	START_DATE("DF804A", "ddMMyyyy"),
	ACCOUNT_STATUS("DF8036"),
	ACCOUNT_LINK_FLAG("DF8051"),
	ACCOUNT_DONOR_FLAG("DF804C"),
	ACCOUNT_RECIPIENT_FLAG("DF804D"),
	DESTINATION_CLOSING_ACCOUNT("DF8038"),
	SOURCE_OPENING_ACCOUNT("DF8037"),
	RATES_SCHEME("DF8214"),
	PROJECT_CODE("DF834F"),
	PROJECT_DESCRIPTION("DF8358"),
	STATUS_REASON("DF820E"),
	PRIORITY("DF8400"),
	CARD_ACCOUNT_REFERENCE_TYPE("DF856A"),
	ACCOUNT_MAXIMUM_AVAILABLE_BALANCE("DF845E"),
	// FF35 - ACCOUNT_LIMIT
	ACCOUNT_LIMIT("FF35"),
	ACCOUNT_ATM_LIMIT("DF8052"),
	ACCOUNT_POS_LIMIT("DF8053"),
	ACCOUNT_USAGE_LIMIT("DF8054"),
	ACCOUNT_EXCEED_LIMIT("DF8055"),
	IRREDUCIBLE_BALANCE("DF834E"),
	
	ADDITIONAL_SERVICE_BLOCK("FF2F"),
	SERVICE_DATA_BLOCK("FF4C"),
	SERVICE_ID("DF805B"),
	SERVICE_LINK_LEVEL("DF805C"),
	SERVICE_END_DATE("DF8250", "yyyyMMdd"),
	SERVICE_ACTION_FLAG("DF812D"),
	SERVICE_INSTANCE_NUMBER("DF8347"),

	INTERNET_BANK_BLOCK("FF4D"),
	ACCESS_CODE_DESC("DF810C"),
	CALL_CENTER_BLOCK("FF4E"),
	ACCESS_PASSWORD("DF810B"),
	LOYALTY_CARD_SERVICE_BLOCK("FF8025"),
	PROGRAM_MEMBER_CODE("DF8220"),
	// SMS SEVICE BLOCK
	SMS_SERVICE_BLOCK("FF8018"),
	// CREDIT_SERVICE_BLOCK
	CREDIT_SERVICE_BLOCK("FF802E"),
	CREDIT_LIMIT("DF8055"),
	CREDIT_CONTRACT_NUMBER("DF8251"),
	DATE_OF_SIGNATURE("DF8252"),
	CONTRACT_OF_DEPOSIT_1("DF8253"),
	CONTRACT_OF_DEPOSIT_2("DF8254"),
	PAYING_OFF_DATE("DF8255", "yyyyMMdd"),
	ENSURING_AMOUNT_1("DF8256"),
	ENSURING_AMOUNT_2("DF8257"),
	CATEGORY_CREDIT_OPERATION("DF8258"),
	FINANCIAL_CONDITION_DEBTOR("DF8259"),
	DEBT_SERVICE("DF825A"),
	CURRENCY_OF_DEPOSITE_1("DF825B"),
	CURRENCY_OF_DEPOSITE_2("DF825C"),
	PURPOSE_OF_CREDIT("DF825D"),
	PERIOD_OF_CREDIT("DF825E"),
	CREDIT_SERVICE_FORCED_CLOSE("DF825F"),

	PURE_LOYALTY_SERVICE_BLOCK("FF805D"),
//	LOYALTY_ACCOUNT_NUMBER("DF8033"),

	PAYMENT_SERVICE_BLOCK("FF804E"),
	DESTINATION_ACCOUNT_DESC("DF840A"),
	PAYMENT_PURPOSE("DF8332"),

	ADA_SERVICE_BLOCK("FF801D"),
	EXTERNAL_ACCOUNT_NUMBER("DF8221"),
	DELAY("DF821F"),

	EMAIL_NOTIFICATION_SERVICE_BLOCK("FF803A"),
	EMAIL_ADDRESS("DF802B"),

	DEPOSIT_BLOCK("FF8077"),
	Deposit_bonus_pr("DF8621"),
	Deposit_bonus_pr_len("DF8622"),
	Deposit_bonus_pr_basis("DF8623"),
	
	// FF8003 - MERCHANT_BLOCK
	MERCHANT("FF8003"),
	
	MERCHANT_SUB_LEVEL_1("FF802B"),
	MERCHANT_SUB_LEVEL_2("FF802C"),
	MERCHANT_SUB_LEVEL_3("FF802D"),
	
	MERCHANT_LEVEL("FF8005"),
	MERCHANT_ENTRY_ID("DF8116"),
	MERCHANT_ENTITY_ID("DF8117"),
	MERCHANT_NAME("DF8118"),
	MERCHANT_LABEL("DF8119"),
	MCC("DF811A"),
	MERCHANT_STATUS("DF811C"),
	MERCHANT_PRIVATE_1("DF811D"),
	MERCHANT_PRIVATE_2("DF811E"),
	MERCHANT_PRIVATE_3("DF811F"),
	MERCHANT_PRIVATE_4("DF8120"),
	MERCHANT_PRIVATE_5("DF8121"),
	MERCHANT_LIMITS_SCHEME("DF8177"),
	MERCHANT_CYCLE_SCHEME("DF817D"),
	MERCHANT_FEE_SCHEME("DF8202"),
	MERCHANT_STATEMENT_SCHEME("DF8521"),
	AGREEMENT_END_DATE("DF8211", "ddMMyyyy"),
	SSIC_CODE("DF8440"),
	VENDOR("DF8519"),
	
	// FF8004 - CONTRACT_DETAILS_BLOCK
	CONTRACT_DETAILS("FF8004"),
	DEFAULT_ACCOUNT_NUMBER("DF810F"),

	//FF8045 - MERCHANT_MSC_BLOCK
	MERCHANT_MSC("FF8045"),
	FEE_ID("DF835D"),
	MERCHANT_DOMAIN("DF8401"),
	ACQUIRER_INSTITUTION("DF836A"),
	ISSUER_INSTITUTION("DF8369"),
	OPERATION_TYPE("DF8342"),
	MSC_DESCRIPTION("DF8353"),
	ISSUER_BIN("DF847E"),
	PARAMETERS_GROUP_ID("DF8557"),

	//FF801B - MERCHANT_PAYMENT_BLOCK
	MERCHANT_PAYMENT_BLOCK("FF801B"),
	PAYMENT_AMOUNT_TYPE("DF8479"),
	FINDING_ACCOUNT("DF821B"),
	PAYMENT_MODE("DF821C"),
	SR_CODE("DF821D"),
	PAYMENT_DELIVERY("DF821E"),
	
	// FF8003 - TERMINAL_BLOCK
//	TERMINAL("FF8003"),
	GROUP_TERMINAL("FF802A"),
	
	PARENT_LEVEL("FF8006"),
	PARENT_ENTRY_ID("DF8123"),
	PARENT_ENTITY_ID("DF8122"),
	PARENT_LEVEL_TYPE("DF8124"),
	
	TERMINAL_LEVEL("FF8007"),
	TERMINAL_ID_ISO("DF8125"),
	TERMINAL_ID_INTERNAL("DF8126"),
	TERMINAL_TYPE("DF8127"),
	CAT_LEVEL("DF8128"),
	CARD_DATA_INPUT_CAP("DF8129"),
	CRDH_AUTH_CAP("DF812A"),
	CARD_CAPTURE_CAP("DF812B"),
	TERM_OPERATING_ENV("DF812C"),
	CARD_DATA_OUTPUT_CAP("DF8132"),
	TERM_DATA_OUTPUT_CAP("DF8133"),
	PIN_CAPTURE_CAP("DF8134"),
	PLASTIC_NUMBER("DF8135"),
	TERMINAL_STATUS("DF811C"),
	TERMINAL_QUANTITY("DF824A"),
	TERMINAL_LIMITS_SCHEME("DF8177"),
	TERMINAL_CYCLE_SCHEME("DF817D"),
	TERMINAL_FEE_SCHEME("DF8202"),
	TERMINAL_FUNCTION_TYPES("DF837C"),
	TERMINAL_ACCEPTED_NETWORKS("DF8425"),
	CIPS_SERTIFICATION_FLAG("DF8441"),
	POSTING_FLAG("DF8176"),

	INSTALMENT_ALGORITHM("DF8C25"),
	NUMBER_OF_INSTALMENTS("DF8C23"),
	USING_CUSTOM_EVENTS("DF8913"),
	SERVICE_TYPE("DF8139"),

	// FF8019 - ENCRYPTION_BLOCK
	ENCRYPTION("FF8019"),
	ENCRYPTION_KEY_TYPE("DF8164"),
	ENCRYPTION_KEY("DF8165"),
	ENCRYPTION_KEY_CHECK_VALUE("DF8169"),

	
	// FF3C - Reference
	REFERENCE("FF3C"),
	LINK_ACCOUNT_WITH_CARD("DF8061"),
	LINK_CARD_WITH_ADDITIONAL_SERVICE("DF8063"),
	LINK_CARD_WITH_ACCOUNT("DF8138"),
	LINK_ACCOUNT_WITH_ADDITIONAL_SERVICE("DF8162"),
	LINK_UNIPAGO_RETAILER_WITH_DISTRIBUTOR("DF8461"),
	LINK_CARD_WITH_CARD("DF8605"),
	MOVE_SERVICE_FROM_ACC_TO_ACC("DF8624"),
	
	// SRLL - service link levels
	CUSTOMER_SERVICE_LINK_LEVEL("SRLL1"),
	CARDHOLDER_SERVICE_LINK_LEVEL("SRLL2"),
	CARD_SERVICE_LINK_LEVEL("SRLL3"),
	ACCOUNT_SERVICE_LINK_LEVEL("SRLL4"),
	
	// Service action flags
	SERVICE_ACTION_FLAG_ADD("SRAF1"),
	SERVICE_ACTION_FLAG_REMOVE("SRAF2"),
	SERVICE_ACTION_FLAG_UPDATE("SRAF3"),
	
	// VIP codes (CUSTOMER_CATEGORY in SV2)
	VIP_CODE_ORDINARY("CVIP0"),
	VIP_CODE_IMPORTANT("CVIP1"),
	VIP_CODE_VIP("CVIP2"),
	VIP_CODE_TEMPORARY("CVIP3"),
	
	// account statuses
	ACCOUNT_STATUS_ACTIVE("ACST1"),
	ACCOUNT_STATUS_FROZEN("ACST2"),
	ACCOUNT_STATUS_CLOSED("ACST3"),
	ACCOUNT_STATUS_SUSPEND("ACST4"),
	ACCOUNT_STATUS_ATM_ONLY("ACST5"),
	ACCOUNT_STATUS_POS_ONLY("ACST6"),
	ACCOUNT_STATUS_DEPOSITS_ONLY("ACST7"),
	ACCOUNT_STATUS_IN_COLLECTIONS("ACST8"),
	ACCOUNT_STATUS_DELETED("ACST9");
	
//	private static final Map<String, BTRTMapping> EXCEPTION_CASES = new HashMap<String, BTRTMapping>() {{
//		put("DF8013", BTRTMapping.SECRET_ANSWER);
//		put("DF8014", BTRTMapping.SECRET_ANSWER);
//		put("DF8015", BTRTMapping.SECRET_ANSWER);
//		put("DF8016", BTRTMapping.SECRET_ANSWER);
//		put("DF8017", BTRTMapping.SECRET_ANSWER);
//		put("DF8431", BTRTMapping.SECRET_QUESTION);
//		put("DF8432", BTRTMapping.SECRET_QUESTION);
//		put("DF8433", BTRTMapping.SECRET_QUESTION);
//		put("DF8434", BTRTMapping.SECRET_QUESTION);
//		put("DF8435", BTRTMapping.SECRET_QUESTION);
//	}};
	
	// Reverse-lookup map for getting a day from an abbreviation
    private static final Map<String, BTRTMapping> lookup = new HashMap<String, BTRTMapping>();
    static {
        for (BTRTMapping d : BTRTMapping.values())
            lookup.put(d.getCode(), d);
    }
    
	private String code;
    private String value;

	private BTRTMapping(String code) {
		this.code = code;
	}
	
	private BTRTMapping(String code, String value) {
		this.code = code;
		this.value = value;
	}

	public String getCode() {
		return code;
	}
	
    public String getValue() {
		return value;
	}

	public static BTRTMapping get(String code) {
//		if (EXCEPTION_CASES.get(code) != null) {
//			return EXCEPTION_CASES.get(code);
//		}
        return lookup.get(code);
    }

}
