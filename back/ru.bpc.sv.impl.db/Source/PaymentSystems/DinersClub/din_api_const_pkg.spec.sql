create or replace package din_api_const_pkg as
/*********************************************************
*  Constants for DCI financial messages <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 30.04.2016 <br />
*  Module: DIN_API_CONST_PKG <br />
*  @headcom
**********************************************************/

MODULE_CODE_DINNERS            constant com_api_type_pkg.t_module_code       := 'DIN';

DIN_NETWORK_ID                 constant com_api_type_pkg.t_tiny_id           := 1012;
DIN_INSTITUTION_ID             constant com_api_type_pkg.t_inst_id           := 9013;
DIN_CLEARING_STANDARD          constant com_api_type_pkg.t_tiny_id           := 1033;
DIN_CLEARING_STANDARD_17_1     constant com_api_type_pkg.t_tiny_id           := 1040;

MAX_MESSAGE_COUNT_WITHIN_BATCH constant com_api_type_pkg.t_tiny_id           := 60;
MAX_BATCH_COUNT_WITHIN_RECAP   constant com_api_type_pkg.t_tiny_id           := 998;
MAX_RECAP_NUMBER               constant din_api_type_pkg.t_recap_number      := 999;

FILE_TYPE_DINERS_CLEARING      constant com_api_type_pkg.t_dict_value        := 'FLTPCLDN';

MSG_CATEGORY_DETAIL_MESSAGE    constant com_api_type_pkg.t_dict_value        := 'DCMCDMSG';
MSG_CATEGORY_ADDENDUM          constant com_api_type_pkg.t_dict_value        := 'DCMCADND';

DELIMITER                      constant com_api_type_pkg.t_byte_char         := '>';

TRANSACTION_CODE_OUTGOING      constant varchar2(4)                          := 'FRRC';
TRANSACTION_CODE_INCOMING      constant varchar2(4)                          := 'RFRC';

FUNCTION_CODE_RECAP_HEADER     constant varchar2(2)                          := 'UX';
FUNCTION_CODE_RECAP_TRAILER    constant varchar2(2)                          := 'UY';
FUNCTION_CODE_BATCH_HEADER     constant varchar2(2)                          := 'UH';
FUNCTION_CODE_BATCH_TRAILER    constant varchar2(2)                          := 'UT';
FUNCTION_CODE_DETAIL_MESSAGE   constant varchar2(2)                          := 'XD';
FUNCTION_CODE_ADD_ATM          constant varchar2(2)                          := 'XC';
FUNCTION_CODE_ADD_CHIP_CARD    constant varchar2(2)                          := 'XM';

PARAM_NAME_ACQ_AGENT_CODE      constant com_api_type_pkg.t_name              := 'DIN_ACQ_AGENT_CODE';
PARAM_NAME_PROGRAM_TRNSC_AMNT  constant com_api_type_pkg.t_name              := 'DIN_PROGRAM_TRANSACTION_AMOUNT';
PARAM_NAME_ALTERNATE_CURRENCY  constant com_api_type_pkg.t_name              := 'DIN_ALTERNATE_CURRENCY';
PARAM_NAME_ALTERNATE_RATE_TYPE constant com_api_type_pkg.t_name              := 'DIN_ALTERNATE_RATE_TYPE';

DATE_TYPE_MERCHANT_PROVIDED    constant com_api_type_pkg.t_date_short        := 'TS';
DEFAULT_PROGRAM_TRNSC_AMOUNT   constant com_api_type_pkg.t_money             := 0;
MIN_PROGRAM_TRNSC_AMOUNT       constant com_api_type_pkg.t_money             :=  0.001;
MAX_PROGRAM_TRNSC_AMOUNT       constant com_api_type_pkg.t_money             := 99.999;
DATE_FORMAT                    constant com_api_type_pkg.t_date_short        := 'YYMMDD';
REVERSE_DATE_FORMAT            constant com_api_type_pkg.t_date_short        := 'DDMMYY';
TIME_FORMAT                    constant com_api_type_pkg.t_date_short        := 'HH24MISS';
AMOUNT_FORMAT                  constant com_api_type_pkg.t_oracle_name       := 'FM9999999999990.00';
PROGRAM_TRNSC_AMOUNT_FORMAT    constant com_api_type_pkg.t_oracle_name       := 'FM90.999';
NUMBER_3DIGITS_FORMAT          constant com_api_type_pkg.t_oracle_name       := 'FM000';

CHTYP_ATM_CASH_ADV_WITHOUT_FEE constant din_api_type_pkg.t_charge_type       := '830';
CHTYP_ATM_CASH_ADV_INCLD_FEE   constant din_api_type_pkg.t_charge_type       := '831';
CHTYP_ATM_SRV_FEE_FOR_CASH_ADV constant din_api_type_pkg.t_charge_type       := '832';
-- The next 2 charge types define the range of cash (or cash equivalent) charge types
CHTYP_CASHES_RANGE_START       constant din_api_type_pkg.t_charge_type       := '800';
CHTYP_CASHES_RANGE_END         constant din_api_type_pkg.t_charge_type       := '842';

TYPCH_ACQUIRED_INTERNET_CREDIT constant din_api_type_pkg.t_type_of_charge    := 'TJ';

FIELD_ACQUIRER_TIME            constant din_api_type_pkg.t_field_name        := 'SCGMT';
FIELD_ACQUIRER_DATE            constant din_api_type_pkg.t_field_name        := 'SCDAT';
FIELD_LOCAL_TERMINAL_TIME      constant din_api_type_pkg.t_field_name        := 'LCTIM';
FIELD_LOCAL_TERMINAL_DATE      constant din_api_type_pkg.t_field_name        := 'LCDAT';
FIELD_ATM_ID_NUMBER            constant din_api_type_pkg.t_field_name        := 'ATMID';

TAG_ADDENDUM_EMV_5F34          constant com_api_type_pkg.t_dict_value := 'CPANSQN';
TAG_ADDENDUM_EMV_9F06          constant com_api_type_pkg.t_dict_value := 'CAIDT';
TAG_ADDENDUM_EMV_82            constant com_api_type_pkg.t_dict_value := 'CAIPFL';
TAG_ADDENDUM_EMV_9F36          constant com_api_type_pkg.t_dict_value := 'CATCTR';
TAG_ADDENDUM_EMV_9F26          constant com_api_type_pkg.t_dict_value := 'CACRG';
TAG_ADDENDUM_EMV_8A            constant com_api_type_pkg.t_dict_value := 'CAUCN';
TAG_ADDENDUM_EMV_9F02          constant com_api_type_pkg.t_dict_value := 'CAMTA';
TAG_ADDENDUM_EMV_9F03          constant com_api_type_pkg.t_dict_value := 'CAMTO';
TAG_ADDENDUM_EMV_9F27          constant com_api_type_pkg.t_dict_value := 'CCRIF';
TAG_ADDENDUM_EMV_9F34          constant com_api_type_pkg.t_dict_value := 'CCVMR';
TAG_ADDENDUM_EMV_84            constant com_api_type_pkg.t_dict_value := 'CDEDF';
TAG_ADDENDUM_EMV_9F1E          constant com_api_type_pkg.t_dict_value := 'CIDSN';
TAG_ADDENDUM_EMV_9F10          constant com_api_type_pkg.t_dict_value := 'CADA1';
TAG_ADDENDUM_EMV_91            constant com_api_type_pkg.t_dict_value := 'CADAT';
TAG_ADDENDUM_EMV_72            constant com_api_type_pkg.t_dict_value := 'CISRT';
TAG_ADDENDUM_EMV_9F1A          constant com_api_type_pkg.t_dict_value := 'CTRMG';
TAG_ADDENDUM_EMV_9F09          constant com_api_type_pkg.t_dict_value := 'CTAVN';
TAG_ADDENDUM_EMV_9F33          constant com_api_type_pkg.t_dict_value := 'CTRMC';
TAG_ADDENDUM_EMV_9F35          constant com_api_type_pkg.t_dict_value := 'CTRMT';
TAG_ADDENDUM_EMV_95            constant com_api_type_pkg.t_dict_value := 'CTRMR';
TAG_ADDENDUM_EMV_9A            constant com_api_type_pkg.t_dict_value := 'CTRND';
TAG_ADDENDUM_EMV_9C            constant com_api_type_pkg.t_dict_value := 'CTRNT';
TAG_ADDENDUM_EMV_5F2A          constant com_api_type_pkg.t_dict_value := 'CTRNC';
TAG_ADDENDUM_EMV_9F37          constant com_api_type_pkg.t_dict_value := 'CUNPN';

end;
/
