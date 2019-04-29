create or replace package com_api_const_pkg is
/*********************************************************
 *  list of constants <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 09.10.2009 <br />
 *  Module:  com_api_const_pkg <br />
 *  @headcom
 **********************************************************/

-- Section LANG
LANGUAGE_KEY                       constant    com_api_type_pkg.t_dict_value    := 'LANG';
LANGUAGE_ENGLISH                   constant    com_api_type_pkg.t_dict_value    := 'LANGENG';
LANGUAGE_RUSSIAN                   constant    com_api_type_pkg.t_dict_value    := 'LANGRUS';
LANGUAGE_BULGARIAN                 constant    com_api_type_pkg.t_dict_value    := 'LANGBUL';
DEFAULT_LANGUAGE                   constant    com_api_type_pkg.t_dict_value    := LANGUAGE_ENGLISH;

-- Section Data Types
DATA_TYPE_NUMBER                   constant    com_api_type_pkg.t_dict_value    := 'DTTPNMBR';
DATA_TYPE_CHAR                     constant    com_api_type_pkg.t_dict_value    := 'DTTPCHAR';
DATA_TYPE_DATE                     constant    com_api_type_pkg.t_dict_value    := 'DTTPDATE';
DATA_TYPE_CLOB                     constant    com_api_type_pkg.t_dict_value    := 'DTTPCLOB';
DATA_TYPE_RAW                      constant    com_api_type_pkg.t_dict_value    := 'DTTPRAW';

DATA_VARCHAR2_NULL_INIT            constant    com_api_type_pkg.t_name          := 'cast(null as varchar2(4000))';
DATA_NUMBER_NULL_INIT              constant    com_api_type_pkg.t_name          := 'cast(null as number)';
DATA_DATE_NULL_INIT                constant    com_api_type_pkg.t_name          := 'cast(null as date)';

ANYONE                             constant    com_api_type_pkg.t_boolean       := 2;
TRUE                               constant    com_api_type_pkg.t_boolean       := 1;
FALSE                              constant    com_api_type_pkg.t_boolean       := 0;
ONE_SECOND                         constant    number                           := (1/86400);
DAY_IN_SECONDS                     constant    com_api_type_pkg.t_short_id      := 86400;
YEAR_IN_MONTHS                     constant    number(2)                        := 12;
ONE_PERCENT                        constant    number                           := (1/100);
DATE_FORMAT                        constant    com_api_type_pkg.t_name          := 'yyyymmddhh24miss';
TIMESTAMP_FORMAT                   constant    com_api_type_pkg.t_name          := 'yyyymmddhh24missff6';
NUMBER_FORMAT                      constant    com_api_type_pkg.t_name          := 'FM000000000000000000.0000';
LOG_DATE_FORMAT                    constant    com_api_type_pkg.t_name          := 'yyyy-mm-dd hh24:mi:ss';

XML_DATE_FORMAT                    constant    com_api_type_pkg.t_name          := 'yyyy-mm-dd';
XML_DATETIME_FORMAT                constant    com_api_type_pkg.t_name          := 'yyyy-mm-dd"T"hh24:mi:ss';
XML_NUMBER_FORMAT                  constant    com_api_type_pkg.t_name          := 'FM999999999999999990';
XML_FLOAT_FORMAT                   constant    com_api_type_pkg.t_name          := 'FM999999999999999990.0099';
XML_LOCATION_FORMAT                constant    com_api_type_pkg.t_name          := 'FM990.0000000';
XML_HEADER                         constant    com_api_type_pkg.t_original_data := '<?xml version="1.0" encoding="UTF-8"?>';

CREDIT                             constant    com_api_type_pkg.t_sign          := 1;
DEBIT                              constant    com_api_type_pkg.t_sign          := -1;
NONE                               constant    com_api_type_pkg.t_sign          := 0;

DEFAULT_SPLIT_HASH                 constant    com_api_type_pkg.t_tiny_id       := -1;

LOV_SORT_NAME                      constant    com_api_type_pkg.t_dict_value    := 'LVSMNAME';
LOV_SORT_CODE                      constant    com_api_type_pkg.t_dict_value    := 'LVSMCODE';
LOV_SORT_NAME_DESC                 constant    com_api_type_pkg.t_dict_value    := 'LVSMNAMD';
LOV_SORT_CODE_DESC                 constant    com_api_type_pkg.t_dict_value    := 'LVSMCODD';
LOV_SORT_DEFAULT                   constant    com_api_type_pkg.t_dict_value    := LOV_SORT_CODE;

LOV_APPEARANCE_CODE                constant    com_api_type_pkg.t_dict_value    := 'LVAPCODE';
LOV_APPEARANCE_NAME                constant    com_api_type_pkg.t_dict_value    := 'LVAPNAME';
LOV_APPEARANCE_CODE_NAME           constant    com_api_type_pkg.t_dict_value    := 'LVAPCDNM';
LOV_APPEARANCE_NAME_CODE           constant    com_api_type_pkg.t_dict_value    := 'LVAPNMCD';
LOV_APPEARANCE_DEFAULT             constant    com_api_type_pkg.t_dict_value    := LOV_APPEARANCE_CODE_NAME;


AMOUNT_PURPOSE_DICTIONARY          constant    com_api_type_pkg.t_dict_value    := 'AMPR';
AMOUNT_PURPOSE_OPER_REQUEST        constant    com_api_type_pkg.t_dict_value    := 'AMPR0001';
AMOUNT_PURPOSE_OPER_SURCHARGE      constant    com_api_type_pkg.t_dict_value    := 'AMPR0002';
AMOUNT_PURPOSE_OPER_ACTUAL         constant    com_api_type_pkg.t_dict_value    := 'AMPR0003';
AMOUNT_PURPOSE_OPER_CASHBACK       constant    com_api_type_pkg.t_dict_value    := 'AMPR0004';
AMOUNT_PURPOSE_OPER_REPLACE        constant    com_api_type_pkg.t_dict_value    := 'AMPR0005';
AMOUNT_PURPOSE_NETWORK             constant    com_api_type_pkg.t_dict_value    := 'AMPR0006';
AMOUNT_PURPOSE_BIN                 constant    com_api_type_pkg.t_dict_value    := 'AMPR0007';
AMOUNT_PURPOSE_ACCOUNT             constant    com_api_type_pkg.t_dict_value    := 'AMPR0008';
AMOUNT_PURPOSE_SETTLEMENT          constant    com_api_type_pkg.t_dict_value    := 'AMPR0009';
AMOUNT_PURPOSE_MACROS              constant    com_api_type_pkg.t_dict_value    := 'AMPR0010';
AMOUNT_PURPOSE_ACCOUNT_AVAIL       constant    com_api_type_pkg.t_dict_value    := 'AMPR0011';
AMOUNT_PURPOSE_FEE_AMOUNT          constant    com_api_type_pkg.t_dict_value    := 'AMPR0012';
AMOUNT_PURPOSE_SOURCE              constant    com_api_type_pkg.t_dict_value    := 'AMPR0013';
AMOUNT_PURPOSE_DESTINATION         constant    com_api_type_pkg.t_dict_value    := 'AMPR0014';
AMOUNT_PURPOSE_FEE_EQUIVAL         constant    com_api_type_pkg.t_dict_value    := 'AMPR0015';
AMOUNT_ORIGINAL_FEE                constant    com_api_type_pkg.t_dict_value    := 'AMPR0020';
AMOUNT_PURPOSE_CARDHOLDER          constant    com_api_type_pkg.t_dict_value    := 'AMPR0023';

ACCOUNT_PURPOSE_CARD               constant    com_api_type_pkg.t_dict_value    := 'ACPR0001';
ACCOUNT_PURPOSE_MACROS             constant    com_api_type_pkg.t_dict_value    := 'ACPR0002';
ACCOUNT_PURPOSE_MERCHANT           constant    com_api_type_pkg.t_dict_value    := 'ACPR0003';
ACCOUNT_PURPOSE_SOURCE             constant    com_api_type_pkg.t_dict_value    := 'ACPR0004';
ACCOUNT_PURPOSE_DESTINATION        constant    com_api_type_pkg.t_dict_value    := 'ACPR0005';

DATE_PURPOSE_DICTIONARY_TYPE       constant    com_api_type_pkg.t_dict_value    := 'DICTDTPR';
DATE_PURPOSE_PROCESSING            constant    com_api_type_pkg.t_dict_value    := 'DTPR0001';
DATE_PURPOSE_OPERATION             constant    com_api_type_pkg.t_dict_value    := 'DTPR0002';
DATE_PURPOSE_SETTLEMENT            constant    com_api_type_pkg.t_dict_value    := 'DTPR0003';
DATE_PURPOSE_MACROS                constant    com_api_type_pkg.t_dict_value    := 'DTPR0004';
DATE_PURPOSE_UNHOLD                constant    com_api_type_pkg.t_dict_value    := 'DTPR0005';
DATE_PURPOSE_BANK                  constant    com_api_type_pkg.t_dict_value    := 'DTPR0006';
DATE_PURPOSE_HOST                  constant    com_api_type_pkg.t_dict_value    := 'DTPR0007';

CHECK_ALGORITHM_NO_CHECK           constant    com_api_type_pkg.t_dict_value    := 'CHCKNCHK';
CHECK_ALGORITHM_LUHN               constant    com_api_type_pkg.t_dict_value    := 'CHCKLUHN';
CHECK_ALGORITHM_MOD11              constant    com_api_type_pkg.t_dict_value    := 'CHCKMOD1';
CHECK_ALGORITM_CBRF                constant    com_api_type_pkg.t_dict_value    := 'CHCKCBRF';

PARTICIPANT_ISSUER                 constant    com_api_type_pkg.t_dict_value    := 'PRTYISS';
PARTICIPANT_ACQUIRER               constant    com_api_type_pkg.t_dict_value    := 'PRTYACQ';
PARTICIPANT_DEST                   constant    com_api_type_pkg.t_dict_value    := 'PRTYDST';
PARTICIPANT_AGGREGATOR             constant    com_api_type_pkg.t_dict_value    := 'PRTYPAGR';
PARTICIPANT_SERVICE_PROVIDER       constant    com_api_type_pkg.t_dict_value    := 'PRTYSRVP';
PARTICIPANT_LOYALTY                constant    com_api_type_pkg.t_dict_value    := 'PRTYLTY';
PARTICIPANT_INSTITUTION            constant    com_api_type_pkg.t_dict_value    := 'PRTYINST';

ENTITY_TYPE_DICTIONARY             constant    com_api_type_pkg.t_dict_value    := 'ENTT';
ENTITY_TYPE_PERSON                 constant    com_api_type_pkg.t_dict_value    := 'ENTTPERS';
ENTITY_TYPE_COMPANY                constant    com_api_type_pkg.t_dict_value    := 'ENTTCOMP';
ENTITY_TYPE_REPORT                 constant    com_api_type_pkg.t_dict_value    := 'ENTTREPT';
ENTITY_TYPE_PROCESS                constant    com_api_type_pkg.t_dict_value    := 'ENTTPRCS';
ENTITY_TYPE_ROLE                   constant    com_api_type_pkg.t_dict_value    := 'ENTTROLE';
ENTITY_TYPE_USER                   constant    com_api_type_pkg.t_dict_value    := 'ENTTUSER';
ENTITY_TYPE_CUSTOMER               constant    com_api_type_pkg.t_dict_value    := 'ENTTCUST';
ENTITY_TYPE_STTL_DATE              constant    com_api_type_pkg.t_dict_value    := 'ENTTSTDT';
ENTITY_TYPE_CONTACT                constant    com_api_type_pkg.t_dict_value    := 'ENTTCNTC';
ENTITY_TYPE_CONTRACT               constant    com_api_type_pkg.t_dict_value    := 'ENTTCNTR';
ENTITY_TYPE_UNDEFINED              constant    com_api_type_pkg.t_dict_value    := 'ENTTUNDF';
ENTITY_TYPE_ADDRESS                constant    com_api_type_pkg.t_dict_value    := 'ENTTADDR';
ENTITY_TYPE_ACCOUNT_TYPE           constant    com_api_type_pkg.t_dict_value    := 'ENTTACTP';
ENTITY_TYPE_BALANCE_TYPE           constant    com_api_type_pkg.t_dict_value    := 'ENTTBLTP';
ENTITY_TYPE_CURRENCY_RATE          constant    com_api_type_pkg.t_dict_value    := 'ENTT0055';
ENTITY_TYPE_CONTACT_DATA           constant    com_api_type_pkg.t_dict_value    := 'ENTTCNDT';
ENTITY_TYPE_IDENTIFY_OBJECT        constant    com_api_type_pkg.t_dict_value    := 'ENTTIDOB';
ENTITY_TYPE_CARD_IDENTITY          constant    com_api_type_pkg.t_dict_value    := 'ENTT0050';

ID_TYPE_DICTIONARY                 constant    com_api_type_pkg.t_dict_value    := 'IDTP';
ID_TYPE_NATIONAL_ID                constant    com_api_type_pkg.t_dict_value    := 'IDTP0045';

CONTACT_TYPE_PRIMARY               constant    com_api_type_pkg.t_dict_value    := 'CNTTPRMC';
CONTACT_TYPE_NOTIFICATION          constant    com_api_type_pkg.t_dict_value    := 'CNTTNTFC';

EVENT_TYPE_STTL_DAY_CLOSE          constant    com_api_type_pkg.t_dict_value    := 'EVNT0010';
EVENT_TYPE_STTL_DAY_OPEN           constant    com_api_type_pkg.t_dict_value    := 'EVNT0011';
EVENT_TYPE_CURRENCY_RATE           constant    com_api_type_pkg.t_dict_value    := 'EVNT1910';
EVENT_TYPE_CON_DATA_CHANGED        constant    com_api_type_pkg.t_dict_value    := 'EVNT2110';
EVENT_TYPE_IDENT_DATA_CHANGED      constant    com_api_type_pkg.t_dict_value    := 'EVNT2111';
EVENT_TYPE_ADDRESS_CHANGED         constant    com_api_type_pkg.t_dict_value    := 'EVNT2112';

DATE_CALC_ALG_EQUAL_PASSED         constant    com_api_type_pkg.t_dict_value    := 'ALDT0010';
DATE_CALC_ALG_LESS_PASSED          constant    com_api_type_pkg.t_dict_value    := 'ALDT0020';
DATE_CALC_ALG_GREAT_PASSED         constant    com_api_type_pkg.t_dict_value    := 'ALDT0030';
DATE_CALC_ALG_NEXT_PASSED          constant    com_api_type_pkg.t_dict_value    := 'ALDT0040';

INDICATOR_NOT_CANCELED             constant    com_api_type_pkg.t_dict_value    := 'CNLINTCN';
INDICATOR_CANCELED                 constant    com_api_type_pkg.t_dict_value    := 'CNLICNEL';
INDICATOR_CANCELATION              constant    com_api_type_pkg.t_dict_value    := 'CNLICNON';

COMPANY_INCORP_FORM_91             constant    com_api_type_pkg.t_dict_value    := 'INCF0091';

CONVERSION_TYPE_SELLING            constant    com_api_type_pkg.t_dict_value    := 'CVTPSELL';
CONVERSION_TYPE_BUYING             constant    com_api_type_pkg.t_dict_value    := 'CVTPBUYN';

COMMUNICATION_METHOD_KEY           constant    com_api_type_pkg.t_dict_value    := 'CMNM';
COMMUNICATION_METHOD_MOBILE        constant    com_api_type_pkg.t_dict_value    := 'CMNM0001';
COMMUNICATION_METHOD_EMAIL         constant    com_api_type_pkg.t_dict_value    := 'CMNM0002';
COMMUNICATION_METHOD_POST          constant    com_api_type_pkg.t_dict_value    := 'CMNM0003';
COMMUNICATION_METHOD_FAX           constant    com_api_type_pkg.t_dict_value    := 'CMNM0004';
COMMUNICATION_METHOD_SKYPE         constant    com_api_type_pkg.t_dict_value    := 'CMNM0005';
COMMUNICATION_METHOD_AOL           constant    com_api_type_pkg.t_dict_value    := 'CMNM0006';
COMMUNICATION_METHOD_WLMESS        constant    com_api_type_pkg.t_dict_value    := 'CMNM0007';
COMMUNICATION_METHOD_IC            constant    com_api_type_pkg.t_dict_value    := 'CMNM0008';
COMMUNICATION_METHOD_YAHOO         constant    com_api_type_pkg.t_dict_value    := 'CMNM0009';
COMMUNICATION_METHOD_JABBER        constant    com_api_type_pkg.t_dict_value    := 'CMNM0010';
COMMUNICATION_METHOD_TELEX         constant    com_api_type_pkg.t_dict_value    := 'CMNM0011';
COMMUNICATION_METHOD_PHONE         constant    com_api_type_pkg.t_dict_value    := 'CMNM0012';

ADDRESS_TYPE_HOME                  constant    com_api_type_pkg.t_dict_value    := 'ADTPHOME';
ADDRESS_TYPE_BUSINESS              constant    com_api_type_pkg.t_dict_value    := 'ADTPBSNA';
ADDRESS_TYPE_STMT_DELIVERY         constant    com_api_type_pkg.t_dict_value    := 'ADTPSTDL';
ADDRESS_TYPE_LEGAL                 constant    com_api_type_pkg.t_dict_value    := 'ADTPLGLA';

ADDRESS_NOTE_FLX_FIELD             constant    com_api_type_pkg.t_name          := 'ADDRESS_NOTE';

CALENDAR_GREGORIAN                 constant    com_api_type_pkg.t_dict_value    := 'CLNDGREG';
CALENDAR_JALALI                    constant    com_api_type_pkg.t_dict_value    := 'CLNDJALA';

UNDEFINED_CURRENCY                 constant    com_api_type_pkg.t_curr_code     := '999';
ZERO_CURRENCY                      constant    com_api_type_pkg.t_curr_code     := '000';

ERROR_CONV_ARRAY                   constant    com_api_type_pkg.t_tiny_id       := 15;

DIRECTION_INCOME                   constant    com_api_type_pkg.t_tiny_id       := 1;
DIRECTION_OUTCOME                  constant    com_api_type_pkg.t_tiny_id       := -1;

CUST_RATE_TYPE                     constant    com_api_type_pkg.t_dict_value    := 'RTTPCUST';

ALL_DIGIT                          constant    com_api_type_pkg.t_name          := '0123456789';

COUNTRY_NEW_ZEALAND                constant    com_api_type_pkg.t_country_code  := '554';
COUNTRY_AUSTRALIA                  constant    com_api_type_pkg.t_country_code  := '036';

TEXT_IN_NAME                       constant    com_api_type_pkg.t_name          := 'NAME';
TEXT_IN_DESCRIPTION                constant    com_api_type_pkg.t_name          := 'DESCRIPTION';

VALUE_FORMAT_DICTIONARY            constant    com_api_type_pkg.t_dict_value    := 'FVFT';
FACE_VALUE_FORMAT                  constant    com_api_type_pkg.t_dict_value    := 'FVFT0001';
AMOUNT_VALUE_FORMAT                constant    com_api_type_pkg.t_dict_value    := 'FVFT0002';
VALUE_FORMAT_DEFAULT               constant    com_api_type_pkg.t_dict_value    := AMOUNT_VALUE_FORMAT;

FILE_TYPE                          constant    com_api_type_pkg.t_dict_value    := 'FLTP';
DICTIONARY_DICT                    constant    com_api_type_pkg.t_dict_value    := 'DICT';
FILE_TYPE_MCC                      constant    com_api_type_pkg.t_dict_value    := 'FLTPMCC';

FLEXIBLE_FIELD_DICTIONARY          constant    com_api_type_pkg.t_dict_value    := 'FFUS';
FLEXIBLE_FIELD_PROC_OPER           constant    com_api_type_pkg.t_dict_value    := 'FFUSOPPR';
FLEXIBLE_FIELD_PROC_EVNT           constant    com_api_type_pkg.t_dict_value    := 'FFUSEVPR';
FLEXIBLE_FIELD_PROC_ALL            constant    com_api_type_pkg.t_dict_value    := 'FFUSALWY';

ENTRYPOINT_EXPORT                  constant    com_api_type_pkg.t_attr_name     := 'EXPORT';
ENTRYPOINT_WEBSERVICE              constant    com_api_type_pkg.t_attr_name     := 'WEBSERVICE';

VERSION_DEFAULT                    constant    com_api_type_pkg.t_attr_name     := '1.0';

DATA_ACTION_CREATE                 constant    com_api_type_pkg.t_dict_value    := 'DACTCRTE';
DATA_ACTION_MODIFY                 constant    com_api_type_pkg.t_dict_value    := 'DACTMDFY';
DATA_ACTION_NON_FIN_PROC           constant    com_api_type_pkg.t_dict_value    := 'DACTNFPR';
DATA_ACTION_FIN_PROC               constant    com_api_type_pkg.t_dict_value    := 'DACTFIPR';

PERSON_GENDER_MALE                 constant    com_api_type_pkg.t_dict_value    := 'GNDRMALE';
PERSON_GENDER_FEMALE               constant    com_api_type_pkg.t_dict_value    := 'GNDRFEML';

DIGIT_SEPARATOR_DOTE_EMPTY         constant    com_api_type_pkg.t_dict_value    := 'SPRT0000';
DIGIT_SEPARATOR_DOTE_COMMA         constant    com_api_type_pkg.t_dict_value    := 'SPRT0001';
DIGIT_SEPARATOR_DOTE_SPACE         constant    com_api_type_pkg.t_dict_value    := 'SPRT0002';
DIGIT_SEPARATOR_COMMA_EMPTY        constant    com_api_type_pkg.t_dict_value    := 'SPRT0003';
DIGIT_SEPARATOR_COMMA_DOTE         constant    com_api_type_pkg.t_dict_value    := 'SPRT0004';
DIGIT_SEPARATOR_COMMA_SPACE        constant    com_api_type_pkg.t_dict_value    := 'SPRT0005';

NUMBER_FORMAT_DEFAULT              constant    com_api_type_pkg.t_name          := 'FM999999999999999990D0000';
NUMBER_FORMAT_GR_SEPARATOR         constant    com_api_type_pkg.t_name          := 'FM999G999G999G999G999G990D0000';

NUMBER_FL_FORMAT_DEFAULT           constant    com_api_type_pkg.t_name          := 'FM999999999999999990D0099';
NUMBER_FL_FORMAT_GR_SEPARATOR      constant    com_api_type_pkg.t_name          := 'FM999G999G999G999G999G990D0099';

NUMBER_INT_FORMAT_DEFAULT          constant    com_api_type_pkg.t_name          := 'FM999999999999999990';
NUMBER_INT_FORMAT_GR_SEPARATOR     constant    com_api_type_pkg.t_name          := 'FM999G999G999G999G999G990';

EPOCH_DATE                         constant    date                             := to_date('01.01.1970', 'dd.mm.yyyy');

procedure set_separator(
    i_separator  in     com_api_type_pkg.t_name
);

-- Return const to sql query
function get_separator     return  com_api_type_pkg.t_name;

function get_number_format return  com_api_type_pkg.t_name;

function get_date_format   return  com_api_type_pkg.t_name;

function get_format(
    i_data_type  in     com_api_type_pkg.t_dict_value
) return  com_api_type_pkg.t_name;

function get_number_format_with_sep(
    i_number_type in     com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_name;

function get_number_f_format_with_sep return com_api_type_pkg.t_name;

function get_number_i_format_with_sep return com_api_type_pkg.t_name;

end com_api_const_pkg;
/
