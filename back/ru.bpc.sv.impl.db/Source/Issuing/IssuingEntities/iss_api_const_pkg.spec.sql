create or replace package iss_api_const_pkg is
/*********************************************************
*  Issuer - list of constants <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 15.04.2010 <br />
*  Module: ISS_API_CONST_PKG <br />
*  @headcom
**********************************************************/

    CYCLE_EXPIRATION_DATE               constant com_api_type_pkg.t_dict_value := 'CYTP0100';
    CYCLE_UNHOLD_PERIOD                 constant com_api_type_pkg.t_dict_value := 'CYTP0101';
    CYCLE_AUTO_REISSUE                  constant com_api_type_pkg.t_dict_value := 'CYTP0102';
    CYCLE_THRESHOLD_DATE                constant com_api_type_pkg.t_dict_value := 'CYTP0137';
    CYCLE_DELAY_START_DATE              constant com_api_type_pkg.t_dict_value := 'CYTP0139';
    CYCLE_MERCH_CARD_EXPIR_DATE         constant com_api_type_pkg.t_dict_value := 'CYTP1106';
    CYCLE_AUTHREISS_CHECK_LENGTH        constant com_api_type_pkg.t_dict_value := 'CYTP0141';

    LIMIT_PIN_ENTRY                     constant com_api_type_pkg.t_dict_value := 'LMTP0101';
    LIMIT_CARD_USAGE                    constant com_api_type_pkg.t_dict_value := 'LMTP0102';
    LIMIT_CARD_SPEND_CREDIT             constant com_api_type_pkg.t_dict_value := 'LMTP0131';

    EVENT_TYPE_CARD_CREATION            constant com_api_type_pkg.t_dict_value := 'EVNT0100';
    EVENT_TYPE_CARD_DESTRUCT            constant com_api_type_pkg.t_dict_value := 'EVNT0101'; 
    EVENT_TYPE_CARD_ISSUANCE            constant com_api_type_pkg.t_dict_value := 'EVNT0110';
    EVENT_TYPE_CARD_REISSUANCE          constant com_api_type_pkg.t_dict_value := 'EVNT0111';
    EVENT_TYPE_CARD_ACTIVATION          constant com_api_type_pkg.t_dict_value := 'EVNT0102';
    EVENT_TYPE_CARD_DEACTIVATION        constant com_api_type_pkg.t_dict_value := 'EVNT0162';
    EVENT_TYPE_CARD_STATUS_CHANGE       constant com_api_type_pkg.t_dict_value := 'EVNT0160';
    EVENT_TYPE_INSTANCE_CREATION        constant com_api_type_pkg.t_dict_value := 'EVNT0120';
    EVENT_TYPE_CARD_EXPIR_DEACT         constant com_api_type_pkg.t_dict_value := 'EVNT0103';
    EVENT_TYPE_CUSTOMER_CREATION        constant com_api_type_pkg.t_dict_value := 'EVNT0140';
    EVENT_TYPE_CARD_PERSONALIZATN       constant com_api_type_pkg.t_dict_value := 'EVNT0141';
    EVENT_TYPE_CARDHOLDER_CREATION      constant com_api_type_pkg.t_dict_value := 'EVNT0150';
    EVENT_TYPE_CARDHOLDER_MODIFY        constant com_api_type_pkg.t_dict_value := 'EVNT0151';
    EVENT_TYPE_ZERO_WRONGPIN_LIMIT      constant com_api_type_pkg.t_dict_value := 'EVNT0164';
    EVENT_TYPE_REGISTER_PVV             constant com_api_type_pkg.t_dict_value := 'EVNT0165';
    EVENT_ATTRIBUTE_CHANGE_CARD         constant com_api_type_pkg.t_dict_value := 'EVNT0180';
    EVENT_CARD_ATTR_END_CHANGE          constant com_api_type_pkg.t_dict_value := 'EVNT0181';
    EVENT_PIN_OFFSET_REGISTERED         constant com_api_type_pkg.t_dict_value := 'EVNT0142';
    EVENT_LINK_ACCOUNT_TO_CARD          constant com_api_type_pkg.t_dict_value := 'EVNT0115';
    EVENT_TYPE_UPD_SENSITIVE_DATA       constant com_api_type_pkg.t_dict_value := 'EVNT0143';
    EVENT_3D_SECURE_DEACTIVATION        constant com_api_type_pkg.t_dict_value := 'EVNT0105';
    EVENT_NOTIF_DEACTIVATION            constant com_api_type_pkg.t_dict_value := 'EVNT0113';
    EVENT_3D_SECURE_AUTH_REQUEST        constant com_api_type_pkg.t_dict_value := 'EVNT1800';
    EVENT_TYPE_PIN_REISSUE              constant com_api_type_pkg.t_dict_value := 'EVNT0144';
    EVENT_UNLINK_ACCOUNT_FROM_CARD      constant com_api_type_pkg.t_dict_value := 'EVNT0116';
    EVENT_DELIVERY_STATUS_CHANGE        constant com_api_type_pkg.t_dict_value := 'EVNT0159';
    EVENT_CARD_DAMAGED                  constant com_api_type_pkg.t_dict_value := 'EVNT2006';
    EVENT_TYPE_TOKEN_UPDATE             constant com_api_type_pkg.t_dict_value := 'EVNT0152';
    EVENT_TYPE_TOKEN_RELINK             constant com_api_type_pkg.t_dict_value := 'EVNT0153';
    EVENT_CARD_RECONNECTION             constant com_api_type_pkg.t_dict_value := 'EVNT0145';
    EVENT_TYPE_TOKEN_SUSPEND            constant com_api_type_pkg.t_dict_value := 'EVNT0154';
    EVENT_TYPE_TOKEN_RESUME             constant com_api_type_pkg.t_dict_value := 'EVNT0155';
    EVENT_TYPE_TOKEN_DEACTIVEATE        constant com_api_type_pkg.t_dict_value := 'EVNT0156';
    EVENT_TYPE_TOKEN_PAN_UPDATE         constant com_api_type_pkg.t_dict_value := 'EVNT0157';

    CARD_STATE_PERSONALIZATION          constant com_api_type_pkg.t_dict_value := 'CSTE0100';
    CARD_STATE_ACTIVE                   constant com_api_type_pkg.t_dict_value := 'CSTE0200';
    CARD_STATE_CLOSED                   constant com_api_type_pkg.t_dict_value := 'CSTE0300';
    CARD_STATE_DELIVERED                constant com_api_type_pkg.t_dict_value := 'CSTE0400';

    ENTITY_TYPE_CARD                    constant com_api_type_pkg.t_dict_value := 'ENTTCARD';
    ENTITY_TYPE_CARD_INSTANCE           constant com_api_type_pkg.t_dict_value := 'ENTTCINS';
    ENTITY_TYPE_ISS_BIN                 constant com_api_type_pkg.t_dict_value := 'ENTTIBIN';
    ENTITY_TYPE_CUSTOMER                constant com_api_type_pkg.t_dict_value := prd_api_const_pkg.ENTITY_TYPE_CUSTOMER;
    ENTITY_TYPE_CARDHOLDER              constant com_api_type_pkg.t_dict_value := 'ENTTCRDH';
    ENTITY_TYPE_ISS_PRODUCT             constant com_api_type_pkg.t_dict_value := prd_api_const_pkg.PRODUCT_TYPE_ISS;
    ENTITY_TYPE_CARD_DELIVERY           constant com_api_type_pkg.t_dict_value := 'ENTTCRDL';
    ENTITY_TYPE_CARD_TOKEN              constant com_api_type_pkg.t_dict_value := 'ENTTCTKN';
    ENTITY_TYPE_REFERRER_CODE           constant com_api_type_pkg.t_dict_value := 'ENTTRFRC';

    PIN_REQUEST_DONT_GENERATE           constant com_api_type_pkg.t_dict_value := 'PNRQDONT';
    PIN_REQUEST_GENERATE                constant com_api_type_pkg.t_dict_value := 'PNRQGENR';
    PIN_REQUEST_INHERIT                 constant com_api_type_pkg.t_dict_value := 'PNRQINHR';

    PIN_MAILER_REQUEST_DONT_PRINT       constant com_api_type_pkg.t_dict_value := 'PMRQDONT';
    PIN_MAILER_REQUEST_PRINT            constant com_api_type_pkg.t_dict_value := 'PMRQPRNT';

    EMBOSSING_REQUEST_DONT_EMBOSS       constant com_api_type_pkg.t_dict_value := 'EMRQDONT';
    EMBOSSING_REQUEST_EMBOSS            constant com_api_type_pkg.t_dict_value := 'EMRQEMBS';
    EMBOSSING_REQUEST_CHIP              constant com_api_type_pkg.t_dict_value := 'EMRQCHIP';

    PERSO_PRIORITY_EXPRESS              constant com_api_type_pkg.t_dict_value := 'PRSP0100';
    PERSO_PRIORITY_NORMAL               constant com_api_type_pkg.t_dict_value := 'PRSP0500';

    CARD_CATEGORY_UNDEFINED             constant com_api_type_pkg.t_dict_value := 'CRCG0200';
    CARD_CATEGORY_SUPLEMENTARY          constant com_api_type_pkg.t_dict_value := 'CRCG0400';
    CARD_CATEGORY_DOUBLE                constant com_api_type_pkg.t_dict_value := 'CRCG0600';
    CARD_CATEGORY_PRIMARY               constant com_api_type_pkg.t_dict_value := 'CRCG0800';
    CARD_CATEGORY_VIRTUAL               constant com_api_type_pkg.t_dict_value := 'CRCG0900';

    CARD_STATUS_INITIATOR_OPERATOR      constant com_api_type_pkg.t_dict_value := 'CRSIOPER';
    CARD_STATUS_INITIATOR_CARDHLDR      constant com_api_type_pkg.t_dict_value := 'CRSICRDH';
    CARD_STATUS_INITIATOR_SYSTEM        constant com_api_type_pkg.t_dict_value := 'CRSISSTM';

    CARD_STATUS_VALID_CARD              constant com_api_type_pkg.t_dict_value := 'CSTS0000';
    CARD_STATUS_CALL_ISSUER             constant com_api_type_pkg.t_dict_value := 'CSTS0001';
    CARD_STATUS_WARM_CARD               constant com_api_type_pkg.t_dict_value := 'CSTS0002';
    CARD_STATUS_DO_NOT_HONOR            constant com_api_type_pkg.t_dict_value := 'CSTS0003';
    CARD_STATUS_HONOR_WITH_ID           constant com_api_type_pkg.t_dict_value := 'CSTS0004';
    CARD_STATUS_NOT_PERMITTED           constant com_api_type_pkg.t_dict_value := 'CSTS0005';
    CARD_STATUS_LOST_CARD               constant com_api_type_pkg.t_dict_value := 'CSTS0006';
    CARD_STATUS_STOLEN_CARD             constant com_api_type_pkg.t_dict_value := 'CSTS0007';
    CARD_STATUS_CALL_SECURITY           constant com_api_type_pkg.t_dict_value := 'CSTS0008';
    CARD_STATUS_INVALID_CARD            constant com_api_type_pkg.t_dict_value := 'CSTS0009';
    CARD_STATUS_SPECIAL_CONDITION       constant com_api_type_pkg.t_dict_value := 'CSTS0010';
    CARD_STATUS_CALL_ACQUIRER           constant com_api_type_pkg.t_dict_value := 'CSTS0011';
    CARD_STATUS_NOT_ACTIVATED           constant com_api_type_pkg.t_dict_value := 'CSTS0012';
    CARD_STATUS_PIN_ATTEMPTS_EXCD       constant com_api_type_pkg.t_dict_value := 'CSTS0013';
    CARD_STATUS_FORCED_PIN_CHANGE       constant com_api_type_pkg.t_dict_value := 'CSTS0014';
    CARD_STATUS_CREDIT_DEBTS            constant com_api_type_pkg.t_dict_value := 'CSTS0015';
    CARD_STATUS_VRT_CARD_PERS_WAIT      constant com_api_type_pkg.t_dict_value := 'CSTS0016';
    CARD_STATUS_PIN_ACTIVATION          constant com_api_type_pkg.t_dict_value := 'CSTS0017';
    CARD_STATUS_PERSONIF_WAITING        constant com_api_type_pkg.t_dict_value := 'CSTS0018';
    CARD_STATUS_FRAUD_PREVENTION        constant com_api_type_pkg.t_dict_value := 'CSTS0019';
    CARD_STATUS_TEMP_BLOCK_CLIENT       constant com_api_type_pkg.t_dict_value := 'CSTS0020';
    CARD_STATUS_PERM_BLOCK_CLIENT       constant com_api_type_pkg.t_dict_value := 'CSTS0021';
    CARD_STATUS_EXPIRY_OF_CARD          constant com_api_type_pkg.t_dict_value := 'CSTS0022';
    CARD_STATUS_TEMP_BLOCK_BANK         constant com_api_type_pkg.t_dict_value := 'CSTS0023';
    CARD_STATUS_TEMP_BLOCK_CLREQ        constant com_api_type_pkg.t_dict_value := 'CSTS0024';
    CARD_STATUS_PERM_BLOCK_BANK         constant com_api_type_pkg.t_dict_value := 'CSTS0025';
    CARD_STATUS_DAMAGED                 constant com_api_type_pkg.t_dict_value := 'CSTS0027';
    CARD_STATUS_ACTIVTION_REQIRED       constant com_api_type_pkg.t_dict_value := 'CSTS0030';
    

    CARD_TOKEN_STATUS_ACTIVE            constant com_api_type_pkg.t_dict_value := 'TSTS0001';
    CARD_TOKEN_STATUS_DEACTIVATED       constant com_api_type_pkg.t_dict_value := 'TSTS0002';
    CARD_TOKEN_STATUS_SUSPEND           constant com_api_type_pkg.t_dict_value := 'TSTS0003';

    REISS_COMMAND_RENEWAL               constant com_api_type_pkg.t_dict_value := 'RCMDRENW';
    REISS_COMMAND_OLD_NUMBER            constant com_api_type_pkg.t_dict_value := 'RCMDOLDN';
    REISS_COMMAND_NEW_NUMBER            constant com_api_type_pkg.t_dict_value := 'RCMDNEWN';

    START_DATE_OLD_EXPIRY_MONTH         constant com_api_type_pkg.t_dict_value := 'SDRLOEMN';
    START_DATE_OLD_EXPIRY_DATE          constant com_api_type_pkg.t_dict_value := 'SDRLOEDT';
    START_DATE_OLD_START_DATE           constant com_api_type_pkg.t_dict_value := 'SDRLOSDT';
    START_DATE_SYSDATE                  constant com_api_type_pkg.t_dict_value := 'SDRLSYSD';
    START_DATE_SYSDATE_DELAY            constant com_api_type_pkg.t_dict_value := 'SDRLSDDL';

    EXPIRY_DATE_EQUAL_EXPIRY_DATE       constant com_api_type_pkg.t_dict_value := 'EDRLOEXP';
    EXPIRY_DATE_FROM_EXPIRY_DATE        constant com_api_type_pkg.t_dict_value := 'EDRLOEDT';
    EXPIRY_DATE_FROM_START_DATE         constant com_api_type_pkg.t_dict_value := 'EDRLSTDT';
    EXPIRY_DATE_FROM_THRESHOLD          constant com_api_type_pkg.t_dict_value := 'EDRLOETH'; 

    MAX_CARDHOLDER_NAME_LENGTH          constant com_api_type_pkg.t_tiny_id    := 26;
    MAX_CARD_NUMBER_LENGTH              constant com_api_type_pkg.t_tiny_id    := 24;
    DEFAULT_PIN_KEY_INDEX_VALUE         constant com_api_type_pkg.t_tiny_id    := 1; -- tag <key_index>, field <pvk_index>

    CARD_STATUS_REASON_CARD_ISSUE       constant com_api_type_pkg.t_dict_value := 'CSRS0000';
    CARD_STATUS_REASON_CUST_REQ         constant com_api_type_pkg.t_dict_value := 'CSRS0001';
    CARD_STATUS_REASON_PC_REGUL         constant com_api_type_pkg.t_dict_value := 'CSRS0002';
    CARD_STATUS_REASON_DELIVERED        constant com_api_type_pkg.t_dict_value := 'CSRS0008';
    
    ATTR_CARD_LIFE_CYCLE                constant com_api_type_pkg.t_name       := 'ISS_CARD_LIFE_CYCLE';
    ATTR_CARD_AUTO_REISSUE              constant com_api_type_pkg.t_name       := 'ISS_CARD_AUTO_REISSUE';
    ATTR_CARD_SPEND_CREDIT_LIMIT        constant com_api_type_pkg.t_name       := 'ISS_CARD_SPENDING_CREDIT_LIMIT_VALUE';
    ATTR_CARD_CREDIT_OVERLIMIT          constant com_api_type_pkg.t_name       := 'ISS_CARD_CREDIT_OVERLIMIT_VALUE';
    ATTR_CARD_TEMP_CREDIT_LIMIT         constant com_api_type_pkg.t_name       := 'ISS_CARD_TEMPORARY_CREDIT_LIMIT_VALUE';
    
    FILE_TYPE_CARDS_STATUSES            constant com_api_type_pkg.t_dict_value := 'FLTPCRDS';
    FILE_TYPE_CARD_INFO                 constant com_api_type_pkg.t_dict_value := 'FLTPCINF';
    FILE_TYPE_CARDS_SECURE_FILE         constant com_api_type_pkg.t_dict_value := 'FLTPCSEC';
    FILE_TYPE_CARD_BLACK_LIST           constant com_api_type_pkg.t_dict_value := 'FLTPCBLL';
    FILE_TYPE_PERS_INFO                 constant com_api_type_pkg.t_dict_value := 'FLTPPINF';
    FILE_TYPE_COMP_INFO                 constant com_api_type_pkg.t_dict_value := 'FLTPCPIF';

    DOWNLOADING_TYPE_CLEANING           constant com_api_type_pkg.t_dict_value := 'MDLF0001';
    DOWNLOADING_TYPE_NOT_CLEANING       constant com_api_type_pkg.t_dict_value := 'MDLF0002';

    CARD_DELIVERY_STATUS_PERS           constant com_api_type_pkg.t_dict_value := 'CRDSPERS';

    -- Default settings for card mask: counts of visible digits from beginning and ending of a card number
    DEFAULT_BEGIN_CHAR                  constant com_api_type_pkg.t_tiny_id    := 6;
    DEFAULT_END_CHAR                    constant com_api_type_pkg.t_tiny_id    := 4;

    -- Index of the default coding table that is used for encoding of source PAN and decoding encrypted with a token PAN.
    -- In current realization the only one table is used, although SVTOKEN supports up to 12 tables.
    DEFAULT_TOKEN_TABLE_INDEX           constant com_api_type_pkg.t_tiny_id    := 0;
    -- Maximum length of buffer for storing PAN (source or encoded) value
    TOKEN_BUFFER_SIZE                   constant com_api_type_pkg.t_tiny_id    := 25;
    -- Successful completion of some SVTOKEN function in C 
    TOKEN_ANSWER_OK                     constant com_api_type_pkg.t_tiny_id    := 0;
    -- Lengths of non-encoded beginning and ending of a PAN
    LENGTH_OF_PLAIN_PAN_BEGINNING       constant com_api_type_pkg.t_tiny_id    := 6;
    LENGTH_OF_PLAIN_PAN_ENDING          constant com_api_type_pkg.t_tiny_id    := 4;

    MINIMAL_CARD_NUMBER_LENGTH          constant com_api_type_pkg.t_tiny_id    := 12;

    UID_NAME_FORMAT                     constant com_api_type_pkg.t_name := 'UID_NAME_FORMAT';
    ATTR_UID_PREFIX                     constant com_api_type_pkg.t_name := 'UID_PREFIX';

    FLX_TEMPORARY_LIMIT_MCC_LIST        constant com_api_type_pkg.t_name := 'TEMPORARY_LIMIT_MCC_LIST';
    
    SERVICE_TYPE_MOBILE_PAYMENT         constant com_api_type_pkg.t_short_id := 10004065;
    SERVICE_TYPE_MERCH_CARD_MAINT       constant com_api_type_pkg.t_short_id := 10004110;

    WALLET_PROVIDER_KEY                 constant com_api_type_pkg.t_dict_value := 'WLPR';
    WALLET_PROVIDER_APPLE_PAY           constant com_api_type_pkg.t_dict_value := 'WLPR103';
    WALLET_PROVIDER_ANDROID_PAY         constant com_api_type_pkg.t_dict_value := 'WLPR216';
    WALLET_PROVIDER_SAMSUNG_PAY         constant com_api_type_pkg.t_dict_value := 'WLPR217';

end;
/
