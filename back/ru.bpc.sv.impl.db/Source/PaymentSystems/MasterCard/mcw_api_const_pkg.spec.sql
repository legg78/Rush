create or replace package mcw_api_const_pkg is

MODULE_CODE_MASTERCARD              constant com_api_type_pkg.t_module_code := 'MCW';

PDS_TAG_LEN                         constant number := 4;
PDS_LENGTH_LEN                      constant number := 3;

MAX_PDS_LEN                         constant number := 992;
MAX_PDS_DE_LEN                      constant number := 999;
MAX_PDS_DE_COUNT                    constant number := 5; -- (DE048, DE062, DE123, DE124, DE125)
-- Maximum PDS number (index) that is unloaded to an outgoing clearing file by procedure pack_message()
MAX_PDS_NUMBER                      constant number := 1001;

TABLE_KEY                           constant com_api_type_pkg.t_dict_value := 'IP00';
TABLE_FULL                          constant com_api_type_pkg.t_dict_value := 'FULL';
TABLE_KEYS                          constant com_api_type_pkg.t_dict_value := 'IP0000T1';
TABLE_DE                            constant com_api_type_pkg.t_dict_value := 'IP0006T1';
TABLE_PDS                           constant com_api_type_pkg.t_dict_value := 'IP0008T1';
TABLE_ERROR_CODE                    constant com_api_type_pkg.t_dict_value := 'IP0015T1';
TABLE_BRAND_PRODUCT                 constant com_api_type_pkg.t_dict_value := 'IP0016T1';
TABLE_CURRENCY                      constant com_api_type_pkg.t_dict_value := 'IP0017T1';
TABLE_COUNTRY                       constant com_api_type_pkg.t_dict_value := 'IP0028T1';
TABLE_DEF_ARRANGEMENT               constant com_api_type_pkg.t_dict_value := 'IP0036T1';
TABLE_ACCOUNT                       constant com_api_type_pkg.t_dict_value := 'IP0040T1';
TABLE_BIN                           constant com_api_type_pkg.t_dict_value := 'IP0041T1';
TABLE_PROC_CODE_IRD                 constant com_api_type_pkg.t_dict_value := 'IP0052T1';
TABLE_MEMBER_INFO                   constant com_api_type_pkg.t_dict_value := 'IP0072T1';
TABLE_MCC                           constant com_api_type_pkg.t_dict_value := 'IP0075T1';
TABLE_ISS_ARRANGEMENT               constant com_api_type_pkg.t_dict_value := 'IP0090T1';
TABLE_ACQ_ARRANGEMENT               constant com_api_type_pkg.t_dict_value := 'IP0091T1';
TABLE_CAB_PROGRAM_IRD               constant com_api_type_pkg.t_dict_value := 'IP0095T1';
TABLE_PRODUCT_IRD                   constant com_api_type_pkg.t_dict_value := 'IP0096T1';

RECONCILIATION_MODE_FULL            constant mcw_api_type_pkg.t_pds_body := 'RCLMFULL';
RECONCILIATION_MODE_NONE            constant mcw_api_type_pkg.t_pds_body := 'RCLMNONE';

CLEARING_MODE_TEST                  constant mcw_api_type_pkg.t_pds_body := 'T';
CLEARING_MODE_PRODUCTION            constant mcw_api_type_pkg.t_pds_body := 'P';
CLEARING_MODE_DEFAULT               constant mcw_api_type_pkg.t_pds_body := CLEARING_MODE_TEST;

ARRANGEMENT_TYPE_INTERREGIONAL      constant com_api_type_pkg.t_oracle_name := '1';
ARRANGEMENT_TYPE_REGIONAL           constant com_api_type_pkg.t_oracle_name := '2';

MSG_TYPE_PRESENTMENT                constant mcw_api_type_pkg.t_mti := '1240';
FUNC_CODE_FIRST_PRES                constant mcw_api_type_pkg.t_de024 := '200';
FUNC_CODE_SECOND_PRES_FULL          constant mcw_api_type_pkg.t_de024 := '205';
FUNC_CODE_SECOND_PRES_PART          constant mcw_api_type_pkg.t_de024 := '282';

MSG_TYPE_ADMINISTRATIVE             constant mcw_api_type_pkg.t_mti := '1644';
FUNC_CODE_HEADER                    constant mcw_api_type_pkg.t_de024 := '697';
FUNC_CODE_TRAILER                   constant mcw_api_type_pkg.t_de024 := '695';
FUNC_CODE_TEXT                      constant mcw_api_type_pkg.t_de024 := '693';
FUNC_CODE_CURR_UPDATE               constant mcw_api_type_pkg.t_de024 := '640';
FUNC_CODE_ADDENDUM                  constant mcw_api_type_pkg.t_de024 := '696';
FUNC_CODE_FPD                       constant mcw_api_type_pkg.t_de024 := '685';
FUNC_CODE_SPD                       constant mcw_api_type_pkg.t_de024 := '688';
FUNC_CODE_FILE_SUMMARY              constant mcw_api_type_pkg.t_de024 := '680';
FUNC_CODE_MSG_REJECT                constant mcw_api_type_pkg.t_de024 := '691';
FUNC_CODE_FILE_REJECT               constant mcw_api_type_pkg.t_de024 := '699';
FUNC_CODE_RETRIEVAL_REQUEST         constant mcw_api_type_pkg.t_de024 := '603';
FUNC_CODE_RETRIEVAL_RQ_ACKNOWL      constant mcw_api_type_pkg.t_de024 := '605';

MSG_TYPE_FEE                        constant mcw_api_type_pkg.t_mti := '1740';
FUNC_CODE_MEMBER_FEE                constant mcw_api_type_pkg.t_de024 := '700';
FUNC_CODE_FEE_RETURN                constant mcw_api_type_pkg.t_de024 := '780';
FUNC_CODE_FEE_RESUBMITION           constant mcw_api_type_pkg.t_de024 := '781';
FUNC_CODE_FEE_SECOND_RETURN         constant mcw_api_type_pkg.t_de024 := '782';
FUNC_CODE_SYSTEM_FEE                constant mcw_api_type_pkg.t_de024 := '783';
FUNC_CODE_FUNDS_TRANSFER            constant mcw_api_type_pkg.t_de024 := '790';
FUNC_CODE_FUNDS_TRANS_BACK          constant mcw_api_type_pkg.t_de024 := '791';

FEE_REASON_RETRIEVAL_RESP           constant mcw_api_type_pkg.t_de025 := '7614';
FEE_REASON_HANDL_ISS_CHBK           constant mcw_api_type_pkg.t_de025 := '7622';
FEE_REASON_HANDL_ACQ_PRES2          constant mcw_api_type_pkg.t_de025 := '7623';
FEE_REASON_HANDL_ISS_CHBK2          constant mcw_api_type_pkg.t_de025 := '7624';
FEE_REASON_HANDL_ISS_ADVICE         constant mcw_api_type_pkg.t_de025 := '7627';
FEE_REASON_HANDL_MEMBER_SETTL       constant mcw_api_type_pkg.t_de025 := '7800';

MAX_AMOUNT_HANDLING_FEE1            constant mcw_api_type_pkg.t_de004 := 50;
MAX_AMOUNT_HANDLING_FEE2            constant mcw_api_type_pkg.t_de004 := 100;
MAX_AMOUNT_HANDLING_FEE3            constant mcw_api_type_pkg.t_de004 := 150;

MSG_TYPE_CHARGEBACK                 constant mcw_api_type_pkg.t_mti := '1442';
FUNC_CODE_CHARGEBACK1_FULL          constant mcw_api_type_pkg.t_de024 := '450';
FUNC_CODE_CHARGEBACK1_PART          constant mcw_api_type_pkg.t_de024 := '453';
FUNC_CODE_CHARGEBACK2_FULL          constant mcw_api_type_pkg.t_de024 := '451';
FUNC_CODE_CHARGEBACK2_PART          constant mcw_api_type_pkg.t_de024 := '454';

CHBK_REASON_WARN_BULLETIN           constant mcw_api_type_pkg.t_de025 := '4807';
CHBK_REASON_NO_AUTH                 constant mcw_api_type_pkg.t_de025 := '4808';
CHBK_REASON_NO_AUTH_FLOOR           constant mcw_api_type_pkg.t_de025 := '4847';

PROC_CODE_PURCHASE                  constant mcw_api_type_pkg.t_de003 := '00';
PROC_CODE_ATM                       constant mcw_api_type_pkg.t_de003 := '01';
PROC_CODE_CASHBACK                  constant mcw_api_type_pkg.t_de003 := '09';
PROC_CODE_CASH                      constant mcw_api_type_pkg.t_de003 := '12';
PROC_CODE_UNIQUE                    constant mcw_api_type_pkg.t_de003 := '18';
PROC_CODE_CREDIT_FEE                constant mcw_api_type_pkg.t_de003 := '19';
PROC_CODE_REFUND                    constant mcw_api_type_pkg.t_de003 := '20';
PROC_CODE_PAYMENT                   constant mcw_api_type_pkg.t_de003 := '28';
PROC_CODE_DEBIT_FEE                 constant mcw_api_type_pkg.t_de003 := '29';
PROC_CODE_BALANCE_INQUIRY           constant mcw_api_type_pkg.t_de003 := '30';
PROC_CODE_PIN_UNBLOCK               constant mcw_api_type_pkg.t_de003 := '91';
PROC_CODE_PIN_CHANGE                constant mcw_api_type_pkg.t_de003 := '92';

DEFAULT_DE003_2                     constant mcw_api_type_pkg.t_de003 := '00';
DEFAULT_DE003_3                     constant mcw_api_type_pkg.t_de003 := '00';

DE012_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YYMMDDhh24miss';
DE014_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YYMM';
DE031_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YDDD';
DE031_SEQ_FORMAT                    constant com_api_type_pkg.t_oracle_name := 'FM09999999999';
DE073_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YYMMDD';

DE043_FIELD_DELIMITER               constant char(1) := '\';

P0025_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YYMMDD';
P0105_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YYMMDD';
P0158_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YYMMDD';
P0159_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YYMMDD';

P0005_PART_LENGTH                   constant integer := 14;
P0146_PART_LENGTH                   constant integer := 36;
P0147_PART_LENGTH                   constant integer := 48;

P0164_PART_LENGTH                   constant integer := 23;
P0164_4_DATE_FORMAT                 constant com_api_type_pkg.t_oracle_name := 'YYMMDD';

FPD_REASON_ACKNOWLEDGEMENT          constant mcw_api_type_pkg.t_de025 := '6861';
FPD_REASON_NOTIFICATION             constant mcw_api_type_pkg.t_de025 := '6862';

SETTLEMENT_TYPE_MASTERCARD          constant char(1) := 'M';
SETTLEMENT_TYPE_COLLECTION          constant char(1) := 'C';

FILE_TYPE_CLEARING_MASTERCARD       constant com_api_type_pkg.t_dict_value := 'FLTPCLMC';
FILE_TYPE_MDES_BULK_R311            constant com_api_type_pkg.t_dict_value := 'FLTPR311';
FILE_TYPE_ABU_R274                  constant com_api_type_pkg.t_dict_value  := 'FLTPR274';
FILE_TYPE_ABU_T275                  constant com_api_type_pkg.t_dict_value  := 'FLTPT275';

FILE_TYPE_ABU_R625                  constant com_api_type_pkg.t_dict_value  := 'FLTPR625';
FILE_TYPE_ABU_T626                  constant com_api_type_pkg.t_dict_value  := 'FLTPT626';

FILE_TYPE_INC_CLEARING              constant mcw_api_type_pkg.t_pds_body := '001';
FILE_TYPE_OUT_CLEARING              constant mcw_api_type_pkg.t_pds_body := '002';
FILE_TYPE_INC_EARLY_RECONCIL        constant mcw_api_type_pkg.t_pds_body := '003';
FILE_TYPE_INC_AUTO_RECONCIL         constant mcw_api_type_pkg.t_pds_body := '004';
FILE_TYPE_MASTERCOM                 constant mcw_api_type_pkg.t_pds_body := '901';
FILE_TYPE_REWARDS_SYSTEM            constant mcw_api_type_pkg.t_pds_body := '902';
FILE_TYPE_EPSNET_SYSTEM             constant mcw_api_type_pkg.t_pds_body := '903';
FILE_TYPE_BANKNET_SYSTEM            constant mcw_api_type_pkg.t_pds_body := '904';

CAB_TYPE_ATM                        constant com_api_type_pkg.t_mcc := 'Z';
CAB_TYPE_CASH                       constant com_api_type_pkg.t_mcc := 'C';
CAB_TYPE_UNIQUE                     constant com_api_type_pkg.t_mcc := 'U';
CAB_TYPE_PAYMENT                    constant com_api_type_pkg.t_mcc := 'D';
CAB_TYPE_MONEYSEND                  constant com_api_type_pkg.t_mcc := '9';

PDS_TAG_0001                        constant mcw_api_type_pkg.t_pds_tag := 0001;
PDS_TAG_0002                        constant mcw_api_type_pkg.t_pds_tag := 0002;
PDS_TAG_0004                        constant mcw_api_type_pkg.t_pds_tag := 0004;
PDS_TAG_0005                        constant mcw_api_type_pkg.t_pds_tag := 0005;
PDS_TAG_0014                        constant mcw_api_type_pkg.t_pds_tag := 0014;
PDS_TAG_0018                        constant mcw_api_type_pkg.t_pds_tag := 0018;
PDS_TAG_0021                        constant mcw_api_type_pkg.t_pds_tag := 0021;
PDS_TAG_0022                        constant mcw_api_type_pkg.t_pds_tag := 0022;
PDS_TAG_0023                        constant mcw_api_type_pkg.t_pds_tag := 0023;
PDS_TAG_0025                        constant mcw_api_type_pkg.t_pds_tag := 0025;
PDS_TAG_0026                        constant mcw_api_type_pkg.t_pds_tag := 0026;
PDS_TAG_0028                        constant mcw_api_type_pkg.t_pds_tag := 0028;
PDS_TAG_0029                        constant mcw_api_type_pkg.t_pds_tag := 0029;
PDS_TAG_0042                        constant mcw_api_type_pkg.t_pds_tag := 0042;
PDS_TAG_0043                        constant mcw_api_type_pkg.t_pds_tag := 0043;
PDS_TAG_0045                        constant mcw_api_type_pkg.t_pds_tag := 0045;
PDS_TAG_0047                        constant mcw_api_type_pkg.t_pds_tag := 0047;
PDS_TAG_0052                        constant mcw_api_type_pkg.t_pds_tag := 0052;
PDS_TAG_0058                        constant mcw_api_type_pkg.t_pds_tag := 0058;
PDS_TAG_0059                        constant mcw_api_type_pkg.t_pds_tag := 0059;
PDS_TAG_0072                        constant mcw_api_type_pkg.t_pds_tag := 0072;
PDS_TAG_0105                        constant mcw_api_type_pkg.t_pds_tag := 0105;
PDS_TAG_0122                        constant mcw_api_type_pkg.t_pds_tag := 0122;
PDS_TAG_0137                        constant mcw_api_type_pkg.t_pds_tag := 0137;
PDS_TAG_0138                        constant mcw_api_type_pkg.t_pds_tag := 0138;
PDS_TAG_0146                        constant mcw_api_type_pkg.t_pds_tag := 0146;
PDS_TAG_0147                        constant mcw_api_type_pkg.t_pds_tag := 0147;
PDS_TAG_0148                        constant mcw_api_type_pkg.t_pds_tag := 0148;
PDS_TAG_0149                        constant mcw_api_type_pkg.t_pds_tag := 0149;
PDS_TAG_0158                        constant mcw_api_type_pkg.t_pds_tag := 0158;
PDS_TAG_0159                        constant mcw_api_type_pkg.t_pds_tag := 0159;
PDS_TAG_0164                        constant mcw_api_type_pkg.t_pds_tag := 0164;
PDS_TAG_0165                        constant mcw_api_type_pkg.t_pds_tag := 0165;
PDS_TAG_0176                        constant mcw_api_type_pkg.t_pds_tag := 0176;
PDS_TAG_0181                        constant mcw_api_type_pkg.t_pds_tag := 0181;
PDS_TAG_0184                        constant mcw_api_type_pkg.t_pds_tag := 0184;
PDS_TAG_0185                        constant mcw_api_type_pkg.t_pds_tag := 0185;
PDS_TAG_0186                        constant mcw_api_type_pkg.t_pds_tag := 0186;
PDS_TAG_0198                        constant mcw_api_type_pkg.t_pds_tag := 0198;
PDS_TAG_0200                        constant mcw_api_type_pkg.t_pds_tag := 0200;
PDS_TAG_0207                        constant mcw_api_type_pkg.t_pds_tag := 0207;
PDS_TAG_0208                        constant mcw_api_type_pkg.t_pds_tag := 0208;
PDS_TAG_0209                        constant mcw_api_type_pkg.t_pds_tag := 0209;
PDS_TAG_0210                        constant mcw_api_type_pkg.t_pds_tag := 0210;
PDS_TAG_0228                        constant mcw_api_type_pkg.t_pds_tag := 0228;
PDS_TAG_0230                        constant mcw_api_type_pkg.t_pds_tag := 0230;
PDS_TAG_0241                        constant mcw_api_type_pkg.t_pds_tag := 0241;
PDS_TAG_0243                        constant mcw_api_type_pkg.t_pds_tag := 0243;
PDS_TAG_0244                        constant mcw_api_type_pkg.t_pds_tag := 0244;
PDS_TAG_0260                        constant mcw_api_type_pkg.t_pds_tag := 0260;
PDS_TAG_0262                        constant mcw_api_type_pkg.t_pds_tag := 0262;
PDS_TAG_0263                        constant mcw_api_type_pkg.t_pds_tag := 0263;
PDS_TAG_0264                        constant mcw_api_type_pkg.t_pds_tag := 0264;
PDS_TAG_0265                        constant mcw_api_type_pkg.t_pds_tag := 0265;
PDS_TAG_0266                        constant mcw_api_type_pkg.t_pds_tag := 0266;
PDS_TAG_0267                        constant mcw_api_type_pkg.t_pds_tag := 0267;
PDS_TAG_0268                        constant mcw_api_type_pkg.t_pds_tag := 0268;
PDS_TAG_0280                        constant mcw_api_type_pkg.t_pds_tag := 0280;
PDS_TAG_0300                        constant mcw_api_type_pkg.t_pds_tag := 0300;
PDS_TAG_0301                        constant mcw_api_type_pkg.t_pds_tag := 0301;
PDS_TAG_0302                        constant mcw_api_type_pkg.t_pds_tag := 0302;
PDS_TAG_0306                        constant mcw_api_type_pkg.t_pds_tag := 0306;
PDS_TAG_0358                        constant mcw_api_type_pkg.t_pds_tag := 0358;
PDS_TAG_0359                        constant mcw_api_type_pkg.t_pds_tag := 0359;
PDS_TAG_0367                        constant mcw_api_type_pkg.t_pds_tag := 0367;
PDS_TAG_0368                        constant mcw_api_type_pkg.t_pds_tag := 0368;
PDS_TAG_0369                        constant mcw_api_type_pkg.t_pds_tag := 0369;
PDS_TAG_0370                        constant mcw_api_type_pkg.t_pds_tag := 0370;
PDS_TAG_0372                        constant mcw_api_type_pkg.t_pds_tag := 0372;
PDS_TAG_0374                        constant mcw_api_type_pkg.t_pds_tag := 0374;
PDS_TAG_0375                        constant mcw_api_type_pkg.t_pds_tag := 0375;
PDS_TAG_0378                        constant mcw_api_type_pkg.t_pds_tag := 0378;
PDS_TAG_0380                        constant mcw_api_type_pkg.t_pds_tag := 0380;
PDS_TAG_0381                        constant mcw_api_type_pkg.t_pds_tag := 0381;
PDS_TAG_0384                        constant mcw_api_type_pkg.t_pds_tag := 0384;
PDS_TAG_0390                        constant mcw_api_type_pkg.t_pds_tag := 0390;
PDS_TAG_0391                        constant mcw_api_type_pkg.t_pds_tag := 0391;
PDS_TAG_0392                        constant mcw_api_type_pkg.t_pds_tag := 0392;
PDS_TAG_0393                        constant mcw_api_type_pkg.t_pds_tag := 0393;
PDS_TAG_0394                        constant mcw_api_type_pkg.t_pds_tag := 0394;
PDS_TAG_0395                        constant mcw_api_type_pkg.t_pds_tag := 0395;
PDS_TAG_0396                        constant mcw_api_type_pkg.t_pds_tag := 0396;
PDS_TAG_0397                        constant mcw_api_type_pkg.t_pds_tag := 0397;
PDS_TAG_0398                        constant mcw_api_type_pkg.t_pds_tag := 0398;
PDS_TAG_0399                        constant mcw_api_type_pkg.t_pds_tag := 0399;
PDS_TAG_0400                        constant mcw_api_type_pkg.t_pds_tag := 0400;
PDS_TAG_0401                        constant mcw_api_type_pkg.t_pds_tag := 0401;
PDS_TAG_0402                        constant mcw_api_type_pkg.t_pds_tag := 0402;
PDS_TAG_0501                        constant mcw_api_type_pkg.t_pds_tag := 0501;
PDS_TAG_0670                        constant mcw_api_type_pkg.t_pds_tag := 0670;
PDS_TAG_0674                        constant mcw_api_type_pkg.t_pds_tag := 0674;
PDS_TAG_0715                        constant mcw_api_type_pkg.t_pds_tag := 0715;
PDS_TAG_0765                        constant mcw_api_type_pkg.t_pds_tag := 0765;
PDS_TAG_1001                        constant mcw_api_type_pkg.t_pds_tag := 1001;

REVERSAL_PDS_CANCEL                 constant mcw_api_type_pkg.t_pds_body := ' ';
REVERSAL_PDS_REVERSAL               constant mcw_api_type_pkg.t_pds_body := 'R';
REVERSAL_PDS_ORIGINAL               constant mcw_api_type_pkg.t_pds_body := 'O';

CREDIT                              constant mcw_api_type_pkg.t_pds_body := 'C';
DEBIT                               constant mcw_api_type_pkg.t_pds_body := 'D';

MASTERCARD_FTCH                     constant com_api_type_pkg.t_dict_value  := 'CFCHSTDR';
CIRRUS_FTCH                         constant com_api_type_pkg.t_dict_value  := 'CFCHELEC';
MC_RATE_TYPE                        constant com_api_type_pkg.t_dict_value  := 'RTTPMCRP';
DEBIT_CARD                          constant com_api_type_pkg.t_dict_value  := 'CFCHDEBT';
CONTACTLESS_FTCH                    constant com_api_type_pkg.t_dict_value  := 'CFCHCNTL';
ANNUAL_CARD_FEE                     constant com_api_type_pkg.t_dict_value  := 'FETP0102';
VALID_ACCT_STATUS                   constant com_api_type_pkg.t_short_id    := 18;

RETRIEVAL_DOCUMENT_HARDCOPY         constant com_api_type_pkg.t_tiny_id := 1;

LOCAL_CLEARING_CENTRE               constant com_api_type_pkg.t_name := 'LOCAL_CLEARING_CENTRE';
LOCAL_CLEARING_CENTRE_NO            constant com_api_type_pkg.t_name := 'NO';
LOCAL_CLEARING_CENTRE_RUSSIA        constant com_api_type_pkg.t_name := 'LCC for Russia';

-- standard parameters
RECONCILIATION_MODE                 constant com_api_type_pkg.t_name := 'RECONCILIATION_MODE';
CLEARING_MODE                       constant com_api_type_pkg.t_name := 'CLEARING_MODE';
CMID                                constant com_api_type_pkg.t_name := 'BUSINESS_ICA';
CMID_MAESTRO                        constant com_api_type_pkg.t_name := 'BUSINESS_ICA_MAESTRO';
ACQUIRER_BIN                        constant com_api_type_pkg.t_name := 'ACQUIRER_BIN';
FORW_INST_ID                        constant com_api_type_pkg.t_name := 'FORW_INST_ID';
COLLECTION_ONLY                     constant com_api_type_pkg.t_name := 'COLLECTION_ONLY';
CERTIFIED_EMV_COMPLIANT             constant com_api_type_pkg.t_name := 'CERTIFIED_EMV_COMPLIANT';

g_default_charset                            com_api_type_pkg.t_oracle_name;

function init_default_charset return com_api_type_pkg.t_oracle_name;

SCALE_IRD                           constant com_api_type_pkg.t_tiny_id := 1007;

UPLOAD_FORWARDING                   constant com_api_type_pkg.t_dict_value := 'UPIN0010';
UPLOAD_ORIGINATOR                   constant com_api_type_pkg.t_dict_value := 'UPIN0020';

-- card_type
PAY_LATER                           constant com_api_type_pkg.t_tiny_id    := 1006;
PAY_NOW                             constant com_api_type_pkg.t_tiny_id    := 1005;

-- network card type
BRAND_DEBIT                         constant com_api_type_pkg.t_dict_value := 'DMC___';
BRAND_CREDIT                        constant com_api_type_pkg.t_dict_value := 'MCC___';
BRAND_PRIVATE                       constant com_api_type_pkg.t_dict_value := 'PVL___';
BRAND_MAESTRO                       constant com_api_type_pkg.t_dict_value := 'MSI___';

CURRENCY_CODE_US_DOLLAR             constant com_api_type_pkg.t_curr_code := '840';

RATE_TYPE_BUY                       constant com_api_type_pkg.t_dict_value := 'B';
RATE_TYPE_SELL                      constant com_api_type_pkg.t_dict_value := 'S';
RATE_TYPE_MID                       constant com_api_type_pkg.t_dict_value := 'M';

RATE_VALIDITY_PERIOD                constant com_api_type_pkg.t_name := 'RATE_VALIDITY_PERIOD';
DEFAULT_RATE_VALIDITY_PERIOD        constant com_api_type_pkg.t_tiny_id := 1;

TAG_WALLET_ID                       constant com_api_type_pkg.t_short_id := 8752;
TAG_MASTERCARD_ASSIGNED_ID          constant com_api_type_pkg.t_short_id := 35362; -- 0x8A22 (DF8A22)
TAG_BUSINESS_APPLICATION_ID         constant com_api_type_pkg.t_short_id := 35364; -- 0x8a24 (DF8A24)
TAG_DST_ACC_NUMBER_ID               constant com_api_type_pkg.t_short_id := 10;    -- 0x8A1B (DF8A1B)
TAG_FUND_PAYMENT_TRNS_TYPE_ID       constant com_api_type_pkg.t_short_id := 35435; -- 0x8A6B (DF8A6B)
TAG_DS_TRANSACTION_ID               constant com_api_type_pkg.t_short_id := 34818; -- 0x8802 (DF8802) PDS 184
TAG_ACCOUNTHOLDER_AUTH_VALUE        constant com_api_type_pkg.t_short_id := 34368; -- 0x8640 (DF8640) PDS 185
TAG_PROGRAM_PROTOCOL_A              constant com_api_type_pkg.t_short_id := 36416; -- 0x8E40 (DF8E40) PDS 186 A FE
TAG_PROGRAM_PROTOCOL_RND            constant com_api_type_pkg.t_short_id := 34819; -- 0x8803 (DF8803) PDS 186 RND FE
MCW_NETWORK_ID                      constant com_api_type_pkg.t_tiny_id := 1002;

MCW_STANDARD_ID                     constant com_api_type_pkg.t_tiny_id := 1016;
STANDARD_VERSION_19Q2_ID            constant com_api_type_pkg.t_tiny_id := 1103;
STANDARD_VERSION_19Q2_DATE          constant date                       := date '2019-06-11';

LOV_ID_MCW_STOP_LIST_TYPES          constant com_api_type_pkg.t_tiny_id := 544;
LOV_ID_MC_FIRST_CHARGEBACK          constant com_api_type_pkg.t_tiny_id := 560;
LOV_ID_MAE_FIRST_CHARGEBACK         constant com_api_type_pkg.t_tiny_id := 558;
LOV_ID_MAE_SECOND_PRESENT           constant com_api_type_pkg.t_tiny_id := 364;

NATIONAL_PROC_CENTER_INST           constant com_api_type_pkg.t_inst_id := 9009;

MSG_STATUS_INVALID                  constant com_api_type_pkg.t_dict_value := 'CLMS0080';
QR_ARRAY_TYPE                       constant com_api_type_pkg.t_tiny_id  := 1022;
QR_ACQ_OPER_TYPE_ARRAY              constant com_api_type_pkg.t_short_id := 10000029;
QR_ISS_OPER_TYPE_ARRAY              constant com_api_type_pkg.t_short_id := 10000030;
QR_CARD_TYPE_ARRAY                  constant com_api_type_pkg.t_short_id := 10000033;
ABU_BLOCKED_STATUS_ARRAY            constant com_api_type_pkg.t_short_id := 10000054;

MCC_CASH                            constant com_api_type_pkg.t_mcc := '6010';
MCC_ATM                             constant com_api_type_pkg.t_mcc := '6011';

QR_MASTER_CARD_TYPE                 constant com_api_type_pkg.t_tiny_id := 1002;
QR_MAESTRO_CARD_TYPE                constant com_api_type_pkg.t_tiny_id := 1005;
QR_CIRRUS_CARD_TYPE                 constant com_api_type_pkg.t_tiny_id := 0;

MSG_TYPE_250B_HEADER                constant com_api_type_pkg.t_dict_value := 'FHDR';
MSG_TYPE_250B_FREC                  constant com_api_type_pkg.t_dict_value := 'FREC';
MSG_TYPE_250B_NREC                  constant com_api_type_pkg.t_dict_value := 'NREC';
MSG_TYPE_250B_SHDR                  constant com_api_type_pkg.t_dict_value := 'SHDR';
MSG_TYPE_250B_STRL                  constant com_api_type_pkg.t_dict_value := 'STRL';
MSG_TYPE_250B_TRAILER               constant com_api_type_pkg.t_dict_value := 'FTRL';

TRIM_LEAD_ZEROS                     constant com_api_type_pkg.t_oracle_name := 'TRIM_LEAD_ZEROS';

ATTR_BANK_PRODUCT_CODE              constant com_api_type_pkg.t_name        := 'MCW_BANK_PRODUCT_CODE';
ATTR_PROGRAM_IDENTIFIER             constant com_api_type_pkg.t_name        := 'MCW_PROGRAM_IDENTIFIER';

REWARD_SERVICE_TYPE_ID              constant com_api_type_pkg.t_short_id    := 10004386;

REWARD_SERVICE_OUT_DATE_FORMAT      constant com_api_type_pkg.t_date_short  := 'yyyymmdd';
REWARD_SERVICE_OUT_TIME_FORMAT      constant com_api_type_pkg.t_date_short  := 'hh24miss';

REWARD_CARD_STATUS_LOV_ID           constant com_api_type_pkg.t_tiny_id     := 1003;
REWARD_CARD_STATUS_ARRAY_TYPE       constant com_api_type_pkg.t_tiny_id     := 1079;
REWARD_CARD_STATUS_ARRAY_ID         constant com_api_type_pkg.t_short_id    := 10000110;

EVENT_TYPE_WORLD_REWARD_ACTIV       constant com_api_type_pkg.t_dict_value  := 'EVNT4601';

ABU_MSG_STATUS_UPLOADED             constant com_api_type_pkg.t_dict_value  := 'ABUS0010';
ABU_MSG_STATUS_REJECTED             constant com_api_type_pkg.t_dict_value  := 'ABUS0020';

ABU_FILE_FORMAT_CHANGE              constant com_api_type_pkg.t_dict_value  := 'ABUFR274';
ABU_FILE_FORMAT_COMFIRM             constant com_api_type_pkg.t_dict_value  := 'ABUFT275';
PARAM_NAME_MASTERCOM_ENABLED        constant com_api_type_pkg.t_name        := 'MASTERCOM_ENABLED';

-- List of EMV tags that should be retrieved from auth EMV data and save to field DE55,
-- every tag is associated with data type (empty data type is treated as HEX),
-- for numeric tags is also defined lenghts of their hexadecimal representation
EMV_TAGS_LIST_FOR_DE055             constant emv_api_type_pkg.t_emv_tag_type_tab :=
    emv_api_type_pkg.t_emv_tag_type_tab(
        com_name_pair_tpr('5F2A', 'DTTPNMBR4')
      , com_name_pair_tpr('9A',   'DTTPNMBR6')
      , com_name_pair_tpr('9C',   'DTTPNMBR2')
      , com_name_pair_tpr('9F02', 'DTTPNMBR12')
      , com_name_pair_tpr('9F03', 'DTTPNMBR12')
      , com_name_pair_tpr('9F1A', 'DTTPNMBR4')
      , com_name_pair_tpr('9F35', 'DTTPNMBR2')
      , com_name_pair_tpr('9F41', 'DTTPNMBR4')
      , com_name_pair_tpr('9F1E', 'DTTPCHAR')
      , com_name_pair_tpr('9F53', 'DTTPCHAR')
      , com_name_pair_tpr('9F26', '')
      , com_name_pair_tpr('9F27', '')
      , com_name_pair_tpr('9F10', '')
      , com_name_pair_tpr('9F37', '')
      , com_name_pair_tpr('9F36', '')
      , com_name_pair_tpr('95',   '')
      , com_name_pair_tpr('82',   '')
      , com_name_pair_tpr('9F34', '')
      , com_name_pair_tpr('9F33', '')
      , com_name_pair_tpr('84',   '')
      , com_name_pair_tpr('9F09', '')
    );

end;
/
