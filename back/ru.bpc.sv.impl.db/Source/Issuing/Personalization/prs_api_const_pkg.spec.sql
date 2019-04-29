create or replace package prs_api_const_pkg is
/************************************************************
 * API for personalization constants <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 20.05.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_const_pkg <br />
 * @headcom
 ************************************************************/

    PIN_VERIFIC_METHOD_PVV          constant com_api_type_pkg.t_dict_value := 'PNVM0010';
    PIN_VERIFIC_METHOD_IBM_3624     constant com_api_type_pkg.t_dict_value := 'PNVM0020';
    PIN_VERIFIC_METHOD_UNREQUIRED   constant com_api_type_pkg.t_dict_value := 'PNVM0030';
    PIN_VERIFIC_METHOD_COMBINED     constant com_api_type_pkg.t_dict_value := 'PNVM0040';
    
    PVV_STORING_METHOD_DB           constant com_api_type_pkg.t_dict_value := 'PVSM0010';
    PVV_STORING_METHOD_TRACK        constant com_api_type_pkg.t_dict_value := 'PVSM0020';
    PVV_STORING_METHOD_COMBINED     constant com_api_type_pkg.t_dict_value := 'PVSM0030';

    PIN_STORING_METHOD_YES          constant com_api_type_pkg.t_dict_value := 'PNSM0010';
    PIN_STORING_METHOD_NO           constant com_api_type_pkg.t_dict_value := 'PNSM0020';

    ENTITY_TYPE_TRACK1              constant com_api_type_pkg.t_dict_value := 'ENTTTRK1';
    ENTITY_TYPE_TRACK2              constant com_api_type_pkg.t_dict_value := 'ENTTTRK2';
    ENTITY_TYPE_TRACK3              constant com_api_type_pkg.t_dict_value := 'ENTTTRK3';
    ENTITY_TYPE_EMBOSSING           constant com_api_type_pkg.t_dict_value := 'ENTTEMBS';
    ENTITY_TYPE_CHIP                constant com_api_type_pkg.t_dict_value := 'ENTTCHIP';
    ENTITY_TYPE_PINMAILER           constant com_api_type_pkg.t_dict_value := 'ENTTPNML';
    ENTITY_TYPE_CLESS_TRACK1        constant com_api_type_pkg.t_dict_value := 'ENTTCTR1';
    ENTITY_TYPE_CLESS_TRACK2        constant com_api_type_pkg.t_dict_value := 'ENTTCTR2';
    ENTITY_TYPE_PERS_METHOD         constant com_api_type_pkg.t_dict_value := 'ENTTPMTD';
    ENTITY_TYPE_P3CHIP              constant com_api_type_pkg.t_dict_value := 'ENTTP3CP';

    BATCH_STATUS_INITIAL            constant com_api_type_pkg.t_dict_value := 'BTST0001';
    BATCH_STATUS_PROCESSED          constant com_api_type_pkg.t_dict_value := 'BTST0002';
    BATCH_STATUS_IN_PROGRESS        constant com_api_type_pkg.t_dict_value := 'BTST0003';

    -- pin
    PIN_BLOCK_FORMAT_ANSI           constant com_api_type_pkg.t_dict_value := 'PNBFANSI';
    PIN_BLOCK_FORMAT_DOCUTEL        constant com_api_type_pkg.t_dict_value := 'PNBFDOCL';
    PIN_BLOCK_FORMAT_ISO_1          constant com_api_type_pkg.t_dict_value := 'PNBFISO1';

    PIN_LENGTH                      constant com_api_type_pkg.t_tiny_id := 4;

    -- data format
    EXP_DATE_CERT_FORMAT            constant com_api_type_pkg.t_name := 'MMYY';
    EXP_DATE_FORMAT                 constant com_api_type_pkg.t_name := 'MM/YY';
    ISSUE_DATE_FORMAT               constant com_api_type_pkg.t_name := 'DDMMYYYY';
    MEMBER_DATE_FORMAT              constant com_api_type_pkg.t_name := 'YYYYMMDD';
    
    -- service code
    DEFAULT_SERVICE_CODE            constant com_api_type_pkg.t_module_code := '101';

    -- track length
    NAME_TRACK1_MAX_LEN             constant com_api_type_pkg.t_tiny_id := 26;
    
    -- delimers
    DELIMITER                       constant com_api_type_pkg.t_name := ';';
    
    -- template parameters
    PARAM_CARD_ID                   constant com_api_type_pkg.t_name := 'CARD_ID';
    PARAM_CARD_NUMBER               constant com_api_type_pkg.t_name := 'CARD_NUMBER';
    PARAM_ROWS_NUMBER               constant com_api_type_pkg.t_name := 'ROWS_NUMBER';
    PARAM_RECORD_NUMBER             constant com_api_type_pkg.t_name := 'RECORD_NUMBER';
    PARAM_SEQ_NUMBER                constant com_api_type_pkg.t_name := 'SEQ_NUMBER';
    PARAM_CVV                       constant com_api_type_pkg.t_name := 'CVV';
    PARAM_CVV2                      constant com_api_type_pkg.t_name := 'CVV2';
    PARAM_ICVV                      constant com_api_type_pkg.t_name := 'ICVV';
    PARAM_PVV                       constant com_api_type_pkg.t_name := 'PVV';
    PARAM_PVK_INDEX                 constant com_api_type_pkg.t_name := 'PVK_INDEX';
    PARAM_PIN_OFFSET                constant com_api_type_pkg.t_name := 'PIN_OFFSET';
    PARAM_PIN_BLOCK                 constant com_api_type_pkg.t_name := 'PIN_BLOCK';
    PARAM_SERVICE_CODE              constant com_api_type_pkg.t_name := 'SERVICE_CODE';
    PARAM_TRACK1                    constant com_api_type_pkg.t_name := 'TRACK1';
    PARAM_TRACK2                    constant com_api_type_pkg.t_name := 'TRACK2';
    PARAM_TRACK3                    constant com_api_type_pkg.t_name := 'TRACK3';
    PARAM_ISS_DATE                  constant com_api_type_pkg.t_name := 'ISS_DATE';
    PARAM_EXPIR_DATE                constant com_api_type_pkg.t_name := 'EXPIR_DATE';
    PARAM_CARDHOLDER_NAME           constant com_api_type_pkg.t_name := 'CARDHOLDER_NAME';
    PARAM_COMPANY_NAME              constant com_api_type_pkg.t_name := 'COMPANY_NAME';
    PARAM_PERSON_ID                 constant com_api_type_pkg.t_name := 'PERSON_ID';
    PARAM_FIRST_NAME                constant com_api_type_pkg.t_name := 'FIRST_NAME';
    PARAM_SECOND_NAME               constant com_api_type_pkg.t_name := 'SECOND_NAME';
    PARAM_SURNAME                   constant com_api_type_pkg.t_name := 'SURNAME';
    PARAM_SUFFIX                    constant com_api_type_pkg.t_name := 'SUFFIX';
    PARAM_GENDER                    constant com_api_type_pkg.t_name := 'GENDER';
    PARAM_BIRTHDAY                  constant com_api_type_pkg.t_name := 'BIRTHDAY';
    PARAM_SYS_DATE                  constant com_api_type_pkg.t_name := 'SYS_DATE';
    PARAM_STREET                    constant com_api_type_pkg.t_name := 'STREET';
    PARAM_HOUSE                     constant com_api_type_pkg.t_name := 'HOUSE';
    PARAM_APARTMENT                 constant com_api_type_pkg.t_name := 'APARTMENT';
    PARAM_POSTAL_CODE               constant com_api_type_pkg.t_name := 'POSTAL_CODE';
    PARAM_CITY                      constant com_api_type_pkg.t_name := 'CITY';
    PARAM_COUNTRY                   constant com_api_type_pkg.t_name := 'COUNTRY';
    PARAM_COUNTRY_NAME              constant com_api_type_pkg.t_name := 'COUNTRY_NAME';
    PARAM_REGION_CODE               constant com_api_type_pkg.t_name := 'REGION_CODE';
    PARAM_DISCRETIONARY_DATA        constant com_api_type_pkg.t_name := 'DISCRETIONARY_DATA';
    PARAM_CONVERT_NUMBER            constant com_api_type_pkg.t_name := 'CONVERT_NUMBER';
    PARAM_TRACK1_BEGIN              constant com_api_type_pkg.t_name := 'TRACK1_BEGIN';
    PARAM_TRACK1_END                constant com_api_type_pkg.t_name := 'TRACK1_END';
    PARAM_TRACK1_SEPARATOR          constant com_api_type_pkg.t_name := 'TRACK1_SEPARATOR';
    PARAM_TRACK2_BEGIN              constant com_api_type_pkg.t_name := 'TRACK2_BEGIN';
    PARAM_TRACK2_END                constant com_api_type_pkg.t_name := 'TRACK2_END';
    PARAM_TRACK2_SEPARATOR          constant com_api_type_pkg.t_name := 'TRACK2_SEPARATOR';
    PARAM_TRACK3_BEGIN              constant com_api_type_pkg.t_name := 'TRACK3_BEGIN';
    PARAM_TRACK3_END                constant com_api_type_pkg.t_name := 'TRACK3_END';
    PARAM_TRACK3_SEPARATOR          constant com_api_type_pkg.t_name := 'TRACK3_SEPARATOR';
    PARAM_ATC_PLACEHOLDER           constant com_api_type_pkg.t_name := 'ATC_PLACEHOLDER';
    PARAM_CVC3_PLACEHOLDER          constant com_api_type_pkg.t_name := 'CVC3_PLACEHOLDER';
    PARAM_UN_PLACEHOLDER            constant com_api_type_pkg.t_name := 'UN_PLACEHOLDER';
    PARAM_CARD_LABEL                constant com_api_type_pkg.t_name := 'CARD_LABEL';
    PARAM_CARD_ACCOUNT              constant com_api_type_pkg.t_name := 'CARD_ACCOUNT';
    PARAM_CUSTOMER_ID               constant com_api_type_pkg.t_name := 'CUSTOMER_ID';
    PARAM_CARDHOLDER_ID             constant com_api_type_pkg.t_name := 'CARDHOLDER_ID';
    PARAM_INST_ID                   constant com_api_type_pkg.t_name := 'INST_ID';
    PARAM_INST_NAME                 constant com_api_type_pkg.t_name := 'INST_NAME';
    PARAM_AGENT_ID                  constant com_api_type_pkg.t_name := 'AGENT_ID';
    PARAM_AGENT_NAME                constant com_api_type_pkg.t_name := 'AGENT_NAME';
    PARAM_ID_TYPE                   constant com_api_type_pkg.t_name := 'ID_TYPE';
    PARAM_ID_NUMBER                 constant com_api_type_pkg.t_name := 'ID_NUMBER';
    PARAM_CARD_TYPE_NAME            constant com_api_type_pkg.t_name := 'CARD_TYPE_NAME';
    PARAM_END_OF_RECORD             constant com_api_type_pkg.t_name := 'END_OF_RECORD';
    PARAM_PERSO_PRIORITY            constant com_api_type_pkg.t_name := 'PERSO_PRIORITY';

    PARAM_EMBOSSING_DATA            constant com_api_type_pkg.t_name := 'EMBOSSING_DATA';
    PARAM_TRACK1_DATA               constant com_api_type_pkg.t_name := 'TRACK1_DATA';
    PARAM_TRACK2_DATA               constant com_api_type_pkg.t_name := 'TRACK2_DATA';
    PARAM_CHIP_DATA                 constant com_api_type_pkg.t_name := 'CHIP_DATA';
    PARAM_P3CHIP_DATA               constant com_api_type_pkg.t_name := 'P3CHIP_DATA';
    
    -- others
    RSA_FORMAT_CHINESE              constant com_api_type_pkg.t_dict_value := 'PKOFCRT';
    RSA_FORMAT_EXPT_AND_MODULUS     constant com_api_type_pkg.t_dict_value := 'PKOFMOEX';

    -- Clear component formats
    CLEAR_COMP_FMT_ASIS             constant com_api_type_pkg.t_dict_value := 'PKCF0010';
    CLEAR_COMP_FMT_LENGTH_IN_1BYTE  constant com_api_type_pkg.t_dict_value := 'PKCF0020';

    -- Clear component padding
    CLEAR_COMP_PAD_TO_8B_00         constant com_api_type_pkg.t_dict_value := '0000';
    CLEAR_COMP_PAD_TO_8B_80         constant com_api_type_pkg.t_dict_value := '0080';
    CLEAR_COMP_PAD_80_PAD_TO_8B_00  constant com_api_type_pkg.t_dict_value := '0180';

    THALES_GENERATE_OTS_DK_IDN      constant com_api_type_pkg.t_tiny_id := 3;
    THALES_HOST_STORED_KEY          constant com_api_type_pkg.t_tiny_id := 99;
    THALES_EUROPAY_P_EATS_Q         constant com_api_type_pkg.t_tiny_id := 3;
    
    FILE_TYPE_CHIP_EMB              constant com_api_type_pkg.t_dict_value := 'FLTPCHIP';
    FILE_TYPE_CHIP_MAGSTRIPE        constant com_api_type_pkg.t_dict_value := 'FLTPMGST';
    FILE_TYPE_EMBOSSING             constant com_api_type_pkg.t_dict_value := 'FLTPEMBS';

    g_printer_encoding              com_api_type_pkg.t_name;
    procedure init_printer_encoding;
    g_default_charset               com_api_type_pkg.t_name;
    function init_default_charset return com_api_type_pkg.t_oracle_name;

    DEFAULT_SORTING        constant com_api_type_pkg.t_tiny_id := 1001;
    PERSO_TEMPLATE_ENTITY_ARRAY     constant com_api_type_pkg.t_short_id := 10000009;

end;
/
