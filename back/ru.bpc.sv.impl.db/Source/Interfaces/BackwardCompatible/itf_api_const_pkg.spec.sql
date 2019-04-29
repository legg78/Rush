create or replace package itf_api_const_pkg as

    RT_FILE_HEADER                  constant varchar2(6) := 'RCTP01';
    RT_FILE_TRAILER                 constant varchar2(6) := 'RCTP02';
    RT_IBI03_BATCH_TRAILER          constant varchar2(6) := 'RCTP03';
    RT_IBI07_BATCH_TRAILER          constant varchar2(6) := 'RCTP07';
    RT_R_IBI_BATCH_TRAILER          constant varchar2(6) := 'RCTP12';
    RT_OCP_BATCH_TRAILER            constant varchar2(6) := 'RCTP10';
    RT_OSL_DETAIL                   constant varchar2(6) := 'RCTP20';
    RT_CARD_ISSUED                  constant varchar2(6) := 'RCTP31';

    FT_IBI_FILE_TYPE                constant com_api_type_pkg.t_dict_value := 'FTYPIBI';
    FT_R_IBI_FILE_TYPE              constant com_api_type_pkg.t_dict_value := 'FTYPOBI';
    FT_OCP_FILE_TYPE                constant com_api_type_pkg.t_dict_value := 'FTYPOCP';

    LR_FLAG                         constant varchar2(2) := 'LR';

    TT_WITHDRAW                     constant com_api_type_pkg.t_dict_value := 'CMTP702';
    TT_PAYMENT                      constant com_api_type_pkg.t_dict_value := 'CMTP700';
    TT_BO_CUSTOMS_PAY               constant com_api_type_pkg.t_dict_value := 'CMTP510';
    TT_ISSUER_FEE                   constant com_api_type_pkg.t_dict_value := 'CMTP900';
    TT_PAY_SCHEME_FEE               constant com_api_type_pkg.t_dict_value := 'CMTP401';

    TT_FE_TRANSACTION_TYPE          constant com_api_type_pkg.t_dict_value := 'TPTP532';
    TT_FE_CUSTOMS_PAY               constant com_api_type_pkg.t_dict_value := 'TPTP549';

    CARD_ISSUE                      constant com_api_type_pkg.t_dict_value := 'FEEC140';
    CARD_REISSUANCE_LOST            constant com_api_type_pkg.t_dict_value := 'FEEC141';
    EXPRESS_CARD_ISSUE              constant com_api_type_pkg.t_dict_value := 'FEEC143';
    EXPRESS_CARD_REISSUANCE_LOST    constant com_api_type_pkg.t_dict_value := 'FEEC144';
    CARD_REISSUANCE_BEFORE_EXPIRE   constant com_api_type_pkg.t_dict_value := 'FEEC150';
    EXPRESS_CARD_REISS_BF_EXPIRE    constant com_api_type_pkg.t_dict_value := 'FEEC151';
    EXPIRED_CARD_REISSUANCE         constant com_api_type_pkg.t_dict_value := 'FEEC152';
    DAMAGED_CARD_REISSUANCE         constant com_api_type_pkg.t_dict_value := 'FEEC153';
    DAMAGED_EXPRESS_CARD_REISS      constant com_api_type_pkg.t_dict_value := 'FEEC154';
    PIN_REISSUANCE                  constant com_api_type_pkg.t_dict_value := 'FEEC160';
    EXPRESS_PIN_REISSUANCE          constant com_api_type_pkg.t_dict_value := 'FEEC161';
    CARD_BLOCKING                   constant com_api_type_pkg.t_dict_value := 'FEEC181';
    CARD_UNBLOCKING                 constant com_api_type_pkg.t_dict_value := 'FEEC184';
    NOTE_SERVICE_ACTIVATION         constant com_api_type_pkg.t_dict_value := 'FEEC20';
    USAGE_SERVICE_ACTIVATION        constant com_api_type_pkg.t_dict_value := 'FEEC23';
    DISPUTES_RESOLUTION             constant com_api_type_pkg.t_dict_value := 'FEEC25';
    TRANSACTION_PROCESSING          constant com_api_type_pkg.t_dict_value := 'FEED17';
    TRANSACTION_PROCESSING_MONTH    constant com_api_type_pkg.t_dict_value := 'FEED35';
    ACCOUNT_BLOCKING                constant com_api_type_pkg.t_dict_value := 'FEED181';
    ACCOUNT_CLOSURE                 constant com_api_type_pkg.t_dict_value := 'FEED184';
    PRODUCT_CHANGING                constant com_api_type_pkg.t_dict_value := 'FEED195';

    NO_ERROR                        constant com_api_type_pkg.t_dict_value := 'BIRC00';
    PAYMENT_ACCEPTED                constant com_api_type_pkg.t_dict_value := 'BIRC01';
    PAYMENT_PROCESSED               constant com_api_type_pkg.t_dict_value := 'BIRC02';
    CUSTOMER_ACCOUNT_NUMBER         constant com_api_type_pkg.t_dict_value := 'BIRC10';
    MERCHANT_ACCOUNT_NUMBER         constant com_api_type_pkg.t_dict_value := 'BIRC11';
    CORRESPONDING_ACCOUNT_NUMBER    constant com_api_type_pkg.t_dict_value := 'BIRC12';
    CARD_NUMBER                     constant com_api_type_pkg.t_dict_value := 'BIRC13';
    MERCHANT_NUMBER                 constant com_api_type_pkg.t_dict_value := 'BIRC14';
    CUSTOMER_ID                     constant com_api_type_pkg.t_dict_value := 'BIRC15';
    ADDRESS_ERROR                   constant com_api_type_pkg.t_dict_value := 'BIRC16';
    TERMINAL_NUMBER                 constant com_api_type_pkg.t_dict_value := 'BIRC17';
    TRANSACTION_TYPE_ERROR          constant com_api_type_pkg.t_dict_value := 'BIRC18';
    CUSTOMER_NAME                   constant com_api_type_pkg.t_dict_value := 'BIRC19';
    ACCOUNT_ERROR                   constant com_api_type_pkg.t_dict_value := 'BIRC20';
    AMOUNT_ERROR                    constant com_api_type_pkg.t_dict_value := 'BIRC21';
    DC_FLAG_ERROR                   constant com_api_type_pkg.t_dict_value := 'BIRC22';
    CURRENCY_ERROR                  constant com_api_type_pkg.t_dict_value := 'BIRC23';
    TRANSACTION_DATE                constant com_api_type_pkg.t_dict_value := 'BIRC24';
    TRANSACTION_ID                  constant com_api_type_pkg.t_dict_value := 'BIRC25';
    TRANSACTION_TYPE                constant com_api_type_pkg.t_dict_value := 'BIRC26';
    ADDRESS                         constant com_api_type_pkg.t_dict_value := 'BIRC27';
    FORMATING_ERROR                 constant com_api_type_pkg.t_dict_value := 'BIRC50';
    INSUFFICIENT_FUNDS              constant com_api_type_pkg.t_dict_value := 'BIRC51';
    CRC_ERROR                       constant com_api_type_pkg.t_dict_value := 'BIRC60';
    OTHER_ERROR                     constant com_api_type_pkg.t_dict_value := 'BIRC99';

    ACS_ACTIVE                      constant com_api_type_pkg.t_dict_value := 'ACST1';
    ACS_BLOCKED                     constant com_api_type_pkg.t_dict_value := 'ACST2';

    DC_IND_DEBIT                    constant varchar2(2) := 'DR';
    DC_IND_CREDIT                   constant varchar2(2) := 'CR';
    DC_IND_DEBIT_ADJUSTMENT         constant varchar2(2) := 'DA';
    DC_IND_CREDIT_ADJUSTMENT        constant varchar2(2) := 'CA';

    FILE_TYPE_IBI                   constant com_api_type_pkg.t_dict_value := 'FLTPIBI';
    FILE_TYPE_R_IBI                 constant com_api_type_pkg.t_dict_value := 'FLTPOBI';
    FILE_TYPE_OCP                   constant com_api_type_pkg.t_dict_value := 'FLTPOCP';
    FILE_TYPE_CARD_SERVICE          constant com_api_type_pkg.t_dict_value := 'FLTPCSIF';
    FILE_TYPE_PRODUCT               constant com_api_type_pkg.t_dict_value := 'FLTPPROD';

    OPERATION_TYPE_ACCOUNT_PAYMENT  constant com_api_type_pkg.t_dict_value := 'OPTP2001';
    OPERATION_TYPE_ACCOUNT_WITHDR   constant com_api_type_pkg.t_dict_value := 'OPTP2002';
    OPERATION_TYPE_CUSTOMS_PAYMENT  constant com_api_type_pkg.t_dict_value := 'OPTP5001';
    OPERATION_TYPE_FEECUST_PAYMENT  constant com_api_type_pkg.t_dict_value := 'OPTP5002';
    OPERATION_TYPE_ACCOUNT_HOLD     constant com_api_type_pkg.t_dict_value := 'OPTP2003';

    FRONT_DBLINK                    constant com_api_type_pkg.t_name       := '@DB_FRONT';

    CARDHOLDER_MIN_LENGTH           constant com_api_type_pkg.t_count      := 2;
    CARDHOLDER_MAX_LENGTH           constant com_api_type_pkg.t_count      := 26;
    
    SERVICE_ID_ARRAY                constant com_api_type_pkg.t_count      := 10000092;
    CBS_ACCOUNT_TYPES               constant com_api_type_pkg.t_short_id   := 10000096;

end;
/
