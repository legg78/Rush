create or replace package aup_api_const_pkg is

    RESP_CODE_KEY                   constant com_api_type_pkg.t_dict_value := 'RESP';
    RESP_CODE_OK                    constant com_api_type_pkg.t_dict_value := 'RESP0001';
    RESP_CODE_ERROR                 constant com_api_type_pkg.t_dict_value := 'RESP0002';
    RESP_CODE_CANT_GET_ACQ_BIN      constant com_api_type_pkg.t_dict_value := 'RESP0005';
    RESP_CODE_CANT_GET_ISSUER       constant com_api_type_pkg.t_dict_value := 'RESP0006';
    RESP_CODE_CANT_GET_SCENARIO     constant com_api_type_pkg.t_dict_value := 'RESP0007';
    RESP_CODE_NO_ORIGINAL_OPER      constant com_api_type_pkg.t_dict_value := 'RESP0008';
    RESP_CODE_REVERSAL_DUBLICATED   constant com_api_type_pkg.t_dict_value := 'RESP0009';
    RESP_CODE_CANT_GET_STTL_TYPE    constant com_api_type_pkg.t_dict_value := 'RESP0014';
    RESP_CODE_NO_RULES              constant com_api_type_pkg.t_dict_value := 'RESP0015';
    RESP_CODE_CARD_NOT_FOUND        constant com_api_type_pkg.t_dict_value := 'RESP0016';
    RESP_CODE_UNKNOWN_CARD_STATUS   constant com_api_type_pkg.t_dict_value := 'RESP0017';
    RESP_CODE_WRONG_CARD_STATE      constant com_api_type_pkg.t_dict_value := 'RESP0018';
    RESP_CODE_WRONG_SERVICE_CODE    constant com_api_type_pkg.t_dict_value := 'RESP0019';
    RESP_CODE_PIN_ATTEMPTS_EXCEED   constant com_api_type_pkg.t_dict_value := 'RESP0020';
    RESP_CODE_UNSUFFICIENT_FUNDS    constant com_api_type_pkg.t_dict_value := 'RESP0021';
    RESP_CODE_LIMIT_EXCEEDED        constant com_api_type_pkg.t_dict_value := 'RESP0022';
    RESP_CODE_CANT_GET_ACCOUNT      constant com_api_type_pkg.t_dict_value := 'RESP0023';
    RESP_CODE_CANT_GET_AMOUNT       constant com_api_type_pkg.t_dict_value := 'RESP0024';
    RESP_CODE_INVALID_PIN           constant com_api_type_pkg.t_dict_value := 'RESP0025';
    RESP_CODE_SERVICE_NOT_ALLOWED   constant com_api_type_pkg.t_dict_value := 'RESP0032';
    RESP_CODE_ACCT_NOT_FOUND        constant com_api_type_pkg.t_dict_value := 'RESP0034';
    RESP_CODE_CANT_GET_CUSTOMER     constant com_api_type_pkg.t_dict_value := 'RESP0035';
    RESP_CODE_STOLEN_CARD           constant com_api_type_pkg.t_dict_value := 'RESP0036';
    RESP_CODE_EXPIRED_CARD          constant com_api_type_pkg.t_dict_value := 'RESP0037';
    RESP_CODE_ACCOUNT_RESTRICTED    constant com_api_type_pkg.t_dict_value := 'RESP0038';
    RESP_CODE_CANCEL_NOT_ALLOWED    constant com_api_type_pkg.t_dict_value := 'RESP0041';
    RESP_CODE_DO_NOT_HONOR          constant com_api_type_pkg.t_dict_value := 'RESP0044';
    RESP_CODE_CANT_FIND_DEST        constant com_api_type_pkg.t_dict_value := 'RESP0047';
    RESP_CODE_PREAUTH_NOT_FOUND     constant com_api_type_pkg.t_dict_value := 'RESP0051';
    RESP_CODE_COMPL_TIMEOUT         constant com_api_type_pkg.t_dict_value := 'RESP0052';
    RESP_CODE_PREAUTH_FAILED        constant com_api_type_pkg.t_dict_value := 'RESP0053';
    RESP_CODE_PREAUTH_CANCELED      constant com_api_type_pkg.t_dict_value := 'RESP0054';
    RESP_CODE_ILLEG_SUM_COMPL       constant com_api_type_pkg.t_dict_value := 'RESP0055';
    RESP_CODE_COMPL_DUBLICATE       constant com_api_type_pkg.t_dict_value := 'RESP0056';
    RESP_CODE_INVALID_TRACK         constant com_api_type_pkg.t_dict_value := 'RESP0057';
    
    RESP_CODE_ADDR_ZIP_MATCH        constant com_api_type_pkg.t_dict_value := 'RESP0072';
    RESP_CODE_ADDR_MATCH_ZIP_NOT    constant com_api_type_pkg.t_dict_value := 'RESP0073';
    RESP_CODE_ZIP_MATCH_ADDR_NOT    constant com_api_type_pkg.t_dict_value := 'RESP0074';
    RESP_CODE_ADDR_ZIP_NOT_MATCH    constant com_api_type_pkg.t_dict_value := 'RESP0075';
    RESP_CODE_ADDR_CHECK_PASSED     constant com_api_type_pkg.t_dict_value := 'RESP0076';
    RESP_CODE_ADDR_CHECK_NOT_PASS   constant com_api_type_pkg.t_dict_value := 'RESP0077';

    RESP_CODE_OPERATION_DUPLICATED  constant com_api_type_pkg.t_dict_value := 'RESP0079';

    AUTH_SCHEME_TYPE_POSITIVE       constant com_api_type_pkg.t_dict_value := 'AUSC0001';
    AUTH_SCHEME_TYPE_NEGATIVE       constant com_api_type_pkg.t_dict_value := 'AUSC0002';
    AUTH_SCHEME_TYPE_POS_NEG        constant com_api_type_pkg.t_dict_value := 'AUSC0003';
    AUTH_SCHEME_TYPE_NEG_POS        constant com_api_type_pkg.t_dict_value := 'AUSC0004';
    
    AUTH_TEMPLATE_TYPE_POSITIVE     constant com_api_type_pkg.t_dict_value := 'AUTM0001';
    AUTH_TEMPLATE_TYPE_NEGATIVE     constant com_api_type_pkg.t_dict_value := 'AUTM0002';
    
    AUTH_ADDR_CHECK_ADDR_ZIP        constant com_api_type_pkg.t_dict_value := 'AVLGSAPA';
    AUTH_ADDR_CHECK_TO_5D_ADDR_ZIP  constant com_api_type_pkg.t_dict_value := 'AVLGSFPA';    
    AUTH_ADDR_CHECK_5D_ADDR_ZIP     constant com_api_type_pkg.t_dict_value := 'AVLGS5PA';
    AUTH_ADDR_CHECK_5D_ADDR_DG_ZIP  constant com_api_type_pkg.t_dict_value := 'AVLGS5PN';

    AVS_RES_INITIAL                constant com_api_type_pkg.t_dict_value  := 'AVRS0000';
    AVS_RES_ADDR_MATCH_ZIP_NOT     constant com_api_type_pkg.t_dict_value  := 'AVRS000A';
    AVS_RES_ADDR_MATCH_ZIP_INCOMP  constant com_api_type_pkg.t_dict_value  := 'AVRS000B';
    AVS_RES_ADDR_INCOMP_ZIP_INCOMP constant com_api_type_pkg.t_dict_value  := 'AVRS000C';
    AVS_RES_NOT_VERIFIED_INTERNAL  constant com_api_type_pkg.t_dict_value  := 'AVRS000G';
    AVS_RES_NO_MATCH               constant com_api_type_pkg.t_dict_value  := 'AVRS000N';
    AVS_RES_ADDR_INCOMP            constant com_api_type_pkg.t_dict_value  := 'AVRS000P';
    AVS_RES_NOR_SUPPORTED          constant com_api_type_pkg.t_dict_value  := 'AVRS000S';
    AVS_RES_NOT_VERFIED_DOMESTIC   constant com_api_type_pkg.t_dict_value  := 'AVRS000U';
    AVS_RES_ADDR_MATCH_ZIP_MATCH   constant com_api_type_pkg.t_dict_value  := 'AVRS000Y';
    AVS_RES_ZIP_MATCH_ADDR_NOT     constant com_api_type_pkg.t_dict_value  := 'AVRS000Z';   
    
    CLIENT_ID_TYPE_UNKNOWN          constant com_api_type_pkg.t_dict_value := opr_api_const_pkg.CLIENT_ID_TYPE_UNKNOWN;
    CLIENT_ID_TYPE_NONE             constant com_api_type_pkg.t_dict_value := opr_api_const_pkg.CLIENT_ID_TYPE_NONE;
    CLIENT_ID_TYPE_CARD             constant com_api_type_pkg.t_dict_value := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    CLIENT_ID_TYPE_ACCOUNT          constant com_api_type_pkg.t_dict_value := opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT;
    CLIENT_ID_TYPE_EMAIL            constant com_api_type_pkg.t_dict_value := opr_api_const_pkg.CLIENT_ID_TYPE_EMAIL;
    CLIENT_ID_TYPE_MOBILE           constant com_api_type_pkg.t_dict_value := opr_api_const_pkg.CLIENT_ID_TYPE_MOBILE;
    CLIENT_ID_TYPE_CUSTOMER         constant com_api_type_pkg.t_dict_value := opr_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER;
    CLIENT_ID_TYPE_CONTRACT         constant com_api_type_pkg.t_dict_value := opr_api_const_pkg.CLIENT_ID_TYPE_CONTRACT;

    DCC_RATE_TYPE                   constant com_api_type_pkg.t_dict_value := 'RTTPDCCR';

    TAG_SOURCE_ACC                  constant com_api_type_pkg.t_short_id   := 8708;
    TAG_DESTINATION_ACC             constant com_api_type_pkg.t_short_id   := 8709;
    TAG_DESTINATION_BANK_CODE       constant com_api_type_pkg.t_short_id   := 452;
    TAG_ISSUER_BANK_CODE            constant com_api_type_pkg.t_short_id   := 453;
    TAG_ACQ_SWITCH_DATW             constant com_api_type_pkg.t_short_id   := 8716;
    TAG_TRACE_NUMBER                constant com_api_type_pkg.t_short_id   := 35878;
    TAG_SECOND_CARD_NUMBER          constant com_api_type_pkg.t_short_id   := 10;

    TAG_PARTIAL_AUTH_AMOUNT         constant com_api_type_pkg.t_short_id   := 8723;

    TAG_INSTALLMENT_PAYMENT_DATA_1  constant com_api_type_pkg.t_short_id   := 8744;
    TAG_INSTALLMENT_PAYMENT_DATA_2  constant com_api_type_pkg.t_short_id   := 8729;
    TAG_INSTALLMENT_PAYMENT_DATA_3  constant com_api_type_pkg.t_short_id   := 8743;

    TAG_PAYMENT_FACILITATOR_ID      constant com_api_type_pkg.t_short_id   := 8775;
    TAG_SUB_MERCHANT_ID             constant com_api_type_pkg.t_short_id   := 8776;
    TAG_INDEP_SALES_ORGANIZATION    constant com_api_type_pkg.t_short_id   := 8777;
    TAG_ATM_SERVICE_FEE             constant com_api_type_pkg.t_short_id   := 34683; -- 0x877B (DF877B)
    TAG_BUSINESS_FORMAT_CODE        constant com_api_type_pkg.t_short_id   := 35400;

    TAG_PRODUCT_NUMBER              constant com_api_type_pkg.t_short_id   := 36363;
    TAG_PRODUCT_NAME                constant com_api_type_pkg.t_short_id   := 36364;
    TAG_DELIVERY_BRANCH_NAME        constant com_api_type_pkg.t_short_id   := 36365;
    TAG_BRANCH_NAME                 constant com_api_type_pkg.t_short_id   := 36366;
    TAG_COUNTRY_NAME                constant com_api_type_pkg.t_short_id   := 36367;

    TAG_BANK_NAME                   constant com_api_type_pkg.t_short_id   := 33576;
    TAG_CARDHOLDER_NAME_EXTENDED    constant com_api_type_pkg.t_short_id   := 33537;
    TAG_MISC_ACCOUNT_NUMBER         constant com_api_type_pkg.t_short_id   := 32879;
    TAG_TRANSACTION_COMMENT         constant com_api_type_pkg.t_short_id   := 34682;
    
    TAG_MOBILE_NUMBER               constant com_api_type_pkg.t_short_id   := 8705;
    
    TAG_CUSTOMER_NUMBER             constant com_api_type_pkg.t_short_id   := 32771;
    TAG_CARDHOLDER_ID               constant com_api_type_pkg.t_short_id   := 32775;
    TAG_DIGITAL_ACCT_REFERENCE      constant com_api_type_pkg.t_short_id   := 33925;
    TAG_IS_INCREMENTAL              constant com_api_type_pkg.t_short_id   := 8754;

    TAG_DCC_ATM_AMOUNT              constant com_api_type_pkg.t_short_id   := 36374;
    TAG_DCC_ATM_CURRENCY            constant com_api_type_pkg.t_short_id   := 36375;
    TAG_STATE_PROVINCE_CODE         constant com_api_type_pkg.t_short_id   := 35446;
    TAG_ELECTR_COMMERCE_INDICATOR   constant com_api_type_pkg.t_short_id   := 34405;

    TAG_AMX_MERCH_ID                constant com_api_type_pkg.t_short_id   := 34648;

    TAG_WALLET_PROVIDER             constant com_api_type_pkg.t_short_id   := 35437;

    TAG_CUSTOMER_NAME               constant com_api_type_pkg.t_short_id   := 13;
    TAG_PERSON_NAME                 constant com_api_type_pkg.t_short_id   := 15;

    TAG_SENDER_STREET               constant com_api_type_pkg.t_short_id   := 30;
    TAG_SENDER_CITY                 constant com_api_type_pkg.t_short_id   := 31;
    TAG_SENDER_STATE                constant com_api_type_pkg.t_short_id   := 32;
    TAG_SENDER_COUNTRY              constant com_api_type_pkg.t_short_id   := 33;
    TAG_SENDER_POSTCODE             constant com_api_type_pkg.t_short_id   := 34;

end aup_api_const_pkg;
/
