create or replace package vis_api_const_pkg as
/*********************************************************
*  Visa API constants <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.10.2009 <br />
*  Module: VIS_API_CONST_PKG <br />
*  @headcom
**********************************************************/

MODULE_CODE_VISA                constant com_api_type_pkg.t_module_code := 'VIS';

TC_RETURNED_CREDIT              constant varchar2(2) := '01';
TC_RETURNED_DEBIT               constant varchar2(2) := '02';
TC_RETURNED_NONFINANCIAL        constant varchar2(2) := '03';
TC_SALES                        constant varchar2(2) := '05';
TC_VOUCHER                      constant varchar2(2) := '06';
TC_CASH                         constant varchar2(2) := '07';
TC_SALES_CHARGEBACK             constant varchar2(2) := '15';
TC_VOUCHER_CHARGEBACK           constant varchar2(2) := '16';
TC_CASH_CHARGEBACK              constant varchar2(2) := '17';
TC_SALES_REVERSAL               constant varchar2(2) := '25';
TC_VOUCHER_REVERSAL             constant varchar2(2) := '26';
TC_CASH_REVERSAL                constant varchar2(2) := '27';
TC_MULTIPURPOSE_MESSAGE         constant varchar2(2) := '33';
TC_SALES_CHARGEBACK_REV         constant varchar2(2) := '35';
TC_VOUCHER_CHARGEBACK_REV       constant varchar2(2) := '36';
TC_CASH_CHARGEBACK_REV          constant varchar2(2) := '37';
TC_MONEY_TRANSFER               constant varchar2(2) := '09';
TC_MONEY_TRANSFER2              constant varchar2(2) := '19';
TC_FEE_COLLECTION               constant varchar2(2) := '10';
TC_FUNDS_DISBURSEMENT           constant varchar2(2) := '20';
TC_GENERAL_DELIVERY_REPORT      constant varchar2(2) := '45';
TC_REJECTED                     constant varchar2(2) := '44';
TC_MEMBER_SETTLEMENT_DATA       constant varchar2(2) := '46';
TC_VISA_AMMF_SERVICE            constant varchar2(2) := '50';
TC_REQUEST_ORIGINAL_PAPER       constant varchar2(2) := '51';
TC_REQUEST_FOR_PHOTOCOPY        constant varchar2(2) := '52';
TC_MAILING_CONFIRMATION         constant varchar2(2) := '53';
TC_CURRENCY_RATE_UPDATE         constant varchar2(2) := '56';
TC_FRAUD_ADVICE                 constant varchar2(2) := '40';
TC_FILE_HEADER                  constant varchar2(2) := '90';
TC_BATCH_TRAILER                constant varchar2(2) := '91';
TC_FILE_TRAILER                 constant varchar2(2) := '92';

TCQ_DEFAULT                     constant varchar2(2) := '0';
TCQ_AFT                         constant varchar2(2) := '1';
TCQ_OCT                         constant varchar2(2) := '2';

VISA_NETWORK_ID                 constant com_api_type_pkg.t_tiny_id    := 1003;
NATIONAL_PROC_CENTER_INST       constant com_api_type_pkg.t_inst_id    := 9008;

VISA_DIALECT_DEFAULT            constant com_api_type_pkg.t_dict_value := 'VIB2VISA';
VISA_DIALECT_OPENWAY            constant com_api_type_pkg.t_dict_value := 'VIB2WAY4';
VISA_DIALECT_BASEII             constant com_api_type_pkg.t_dict_value := 'VIB2BSII';
VISA_DIALECT_TIETO              constant com_api_type_pkg.t_dict_value := 'VIB2TIET';

VISA_BASEII_STANDARD            constant com_api_type_pkg.t_tiny_id    := 1008;
STANDARD_VERSION_ID_17Q4        constant com_api_type_pkg.t_tiny_id    := 1051;
STANDARD_VERSION_ID_19Q2        constant com_api_type_pkg.t_tiny_id    := 1102;

LOV_ID_VIS_STOP_LIST_TYPES      constant com_api_type_pkg.t_tiny_id    := 543;
LOV_ID_VIS_FIRST_CHARGEBACK     constant com_api_type_pkg.t_tiny_id    := 428;
LOV_ID_VIS_RETR_REQ_RSN_CODES   constant com_api_type_pkg.t_tiny_id    := 99;
LOV_ID_VIS_DISPUTE_CONDITIONS   constant com_api_type_pkg.t_tiny_id    := 625;

VISA_VSS_RECORD_TYPE_1          constant com_api_type_pkg.t_auth_code  := 'V22200';
VISA_SMS_RECORD_TYPE_1          constant com_api_type_pkg.t_auth_code  := 'V23200';

SMS_MSG_TYPE_REVERSAL           constant varchar2(4)                   := '0400';
SMS_MSG_TYPE_REVERSAL_ADVICE    constant varchar2(4)                   := '0420';

FILE_TYPE_CLEARING_VISA         constant com_api_type_pkg.t_dict_value := 'FLTPCLVS';
FILE_TYPE_VDEP_BULK_FILE        constant com_api_type_pkg.t_dict_value := 'FLTPVTKN';
FILE_TYPE_VSMS_DISPUTE_TO_FE    constant com_api_type_pkg.t_dict_value := 'FLTPVSFE';
FILE_TYPE_AMMF                  constant com_api_type_pkg.t_dict_value := 'FLTPAMMF';
FILE_TYPE_VCF                   constant com_api_type_pkg.t_dict_value := 'FLTPVCF';

ALG_CALC_BALANCE_MIN            constant com_api_type_pkg.t_dict_value := 'ACAB0001';
ALG_CALC_BALANCE_AVERAGE        constant com_api_type_pkg.t_dict_value := 'ACAB0002';
ALG_CALC_BALANCE_MAX            constant com_api_type_pkg.t_dict_value := 'ACAB0003';

VISA_CARD_PRODUCT_CODE_KEY      constant com_api_type_pkg.t_dict_value := 'VCPC';
VISA_PRODUCT_ELECTRON           constant com_api_type_pkg.t_dict_value := 'VCPCL_';
VISA_PRODUCT_UNDEFINE           constant com_api_type_pkg.t_dict_value := 'VCPC__';
VISA_PRODUCT_CLASSIC            constant com_api_type_pkg.t_dict_value := 'VCPCF_';
VISA_PRODUCT_TRADITIONAL        constant com_api_type_pkg.t_dict_value := 'VCPCA_';
VISA_PRODUCT_INFINITE           constant com_api_type_pkg.t_dict_value := 'VCPCI_';
VISA_PRODUCT_PLATINUM           constant com_api_type_pkg.t_dict_value := 'VCPCN_';
VISA_PRODUCT_GOLD               constant com_api_type_pkg.t_dict_value := 'VCPCP_';
VISA_PRODUCT_PURCHASING         constant com_api_type_pkg.t_dict_value := 'VCPCS_';

CMID                            constant com_api_type_pkg.t_name := 'VISA_ACQ_PROC_BIN';
ACQ_BUSINESS_ID                 constant com_api_type_pkg.t_name := 'VISA_ACQ_BUSINESS_ID';
PRIMARY_CMID                    constant com_api_type_pkg.t_name := 'VISA_ACQ_PRIMARY_BUSINESS_ID';
VISA_BASEII_DIALECT             constant com_api_type_pkg.t_name := 'VISA_BASEII_DIALECT';
VISA_SECURITY_CODE              constant com_api_type_pkg.t_name := 'VISA_SECURITY_CODE';
EURO_SETTLEMENT                 constant com_api_type_pkg.t_name := 'EURO_SETTLEMENT';
RUB_SETTLEMENT                  constant com_api_type_pkg.t_name := 'RUB_SETTLEMENT';
COLLECTION_ONLY                 constant com_api_type_pkg.t_name := 'COLLECTION_ONLY';
VISA_PARENT_NETWORK             constant com_api_type_pkg.t_name := 'VISA_PARENT_NETWORK';
VCR_DISPUTE_ENABLE              constant com_api_type_pkg.t_name := 'VCR_DISPUTE_ENABLE';
VISA_ACQ_PROC_BIN_HEADER        constant com_api_type_pkg.t_name := 'VISA_ACQ_PROC_BIN_HEADER';

VISA_STANDART                   constant com_api_type_pkg.t_dict_value := 'CFCHSTDR';
VISA_ELECTRON                   constant com_api_type_pkg.t_dict_value := 'CFCHELEC';
VISA_CONTACTLESS                constant com_api_type_pkg.t_dict_value := 'CFCHCNTL';
VISA_RATE_TYPE                  constant com_api_type_pkg.t_dict_value := 'RTTPVIRP';
MCC_CASH                        constant com_api_type_pkg.t_mcc        := '6010';
MCC_ATM                         constant com_api_type_pkg.t_mcc        := '6011';
MCC_WIRE_TRANSFER_MONEY         constant com_api_type_pkg.t_mcc        := '4829';
MCC_FIN_INSTITUTIONS            constant com_api_type_pkg.t_mcc        := '6012';
MCC_NON_FIN_INSTITUTIONS        constant com_api_type_pkg.t_mcc        := '6051';
MCC_BETTING_CASINO_GAMBLING     constant com_api_type_pkg.t_mcc        := '7995';

TAG_REF_SENDER_ACCOUNT          constant com_api_type_pkg.t_name := 'DF8608';
TAG_REF_SENDER_STREET           constant com_api_type_pkg.t_name := 'SENDER_STREET';
TAG_REF_SENDER_CITY             constant com_api_type_pkg.t_name := 'SENDER_CITY';
TAG_REF_SENDER_COUNTRY          constant com_api_type_pkg.t_name := 'SENDER_COUNTRY';

FRP_TYPE_ACQ_REP_COUNTERFEIT    constant com_api_type_pkg.t_dict_value := 'VFTP0009';

COLLECTION_ONLY_NO              constant com_api_type_pkg.t_dict_value := 'VCOCNOCO';
COLLECTION_ONLY_NOWD            constant com_api_type_pkg.t_dict_value := 'VCOCNOWD';
COLLECTION_ONLY_ALL             constant com_api_type_pkg.t_dict_value := 'VCOCALLO';

QUARTER_REPORT_TYPE             constant com_api_type_pkg.t_tiny_id := 2;

QUARTER_REPORT_ACQ_VOLUMES      constant com_api_type_pkg.t_name := 'PS_VISA_ACQ_VOLUMES';
QUARTER_REPORT_MRC_CATEGORY     constant com_api_type_pkg.t_name := 'PS_VISA_MRC_CATEGORY';
QUARTER_REPORT_MRC_INFORM       constant com_api_type_pkg.t_name := 'PS_VISA_MRC_INFORM';
QUARTER_REPORT_SCHEDULE_F       constant com_api_type_pkg.t_name := 'PS_VISA_SCHEDULE_F';
QUARTER_REPORT_MONTHLY_ISSUING  constant com_api_type_pkg.t_name := 'PS_VISA_MONTHLY_ISSUING';
QUARTER_REPORT_CARD_ISSUANCE    constant com_api_type_pkg.t_name := 'PS_VISA_CARD_ISSUANCE';
QUARTER_REPORT_SCHEDULE_A_E     constant com_api_type_pkg.t_name := 'PS_VISA_SCHEDULE_A_E';
QUARTER_REPORT_CO_BRAND         constant com_api_type_pkg.t_name := 'PS_VISA_CO_BRAND';
QUARTER_REPORT_CASH_ACQUIRING   constant com_api_type_pkg.t_name := 'PS_VISA_CASH_ACQUIRING';
QUARTER_REPORT_MRC_ACQUIRING    constant com_api_type_pkg.t_name := 'PS_VISA_MRC_ACQUIRING';
QUARTER_REPORT_V_PAY_ACQUIRING  constant com_api_type_pkg.t_name := 'PS_V_PAY_ACQUIRING';
QUARTER_REPORT_CONTACTLESS      constant com_api_type_pkg.t_name := 'PS_VISA_ACQUIRING_CONTACTLESS';
QUARTER_REPORT_ECOMMERCE        constant com_api_type_pkg.t_name := 'PS_VISA_ACQUIRING_ECOMMERCE';
QUARTER_REPORT_ACQUIRING_ATM    constant com_api_type_pkg.t_name := 'PS_VISA_ACQUIRING_ATM';
QUARTER_REPORT_ACQUIRING        constant com_api_type_pkg.t_name := 'PS_VISA_ACQUIRING';
QUARTER_REPORT_MOTO_RECURRING   constant com_api_type_pkg.t_name := 'PS_MOTO_RECURRING';
QUARTER_REPORT_ACQUIRING_VMT    constant com_api_type_pkg.t_name := 'PS_VISA_ACQUIRING_VMT';
QUARTER_REPORT_CEMEA            constant com_api_type_pkg.t_name := 'PS_VISA_CEMEA';
QUARTER_REPORT_CROSS_BORDER     constant com_api_type_pkg.t_name := 'PS_VISA_ACQUIRING_CROSS_BORDER';
QUARTER_REPORT_ACQUIRING_BAI    constant com_api_type_pkg.t_name := 'PS_VISA_ACQUIRING_BAI';

VISA_REGION_USA                 constant com_api_type_pkg.t_name := 'US';
DCC_CURRENCY_TCR_MARKER         constant com_api_type_pkg.t_name := 'BIIDCCURR_';

QR_CODE_ACQ_VOLUMES             constant com_api_type_pkg.t_name := 'VIQR0001';
QR_CODE_MRC_CATEGORY            constant com_api_type_pkg.t_name := 'VIQR0002';
QR_CODE_MRC_INFORM              constant com_api_type_pkg.t_name := 'VIQR0003';
QR_CODE_SCHEDULE_F              constant com_api_type_pkg.t_name := 'VIQR0004';
QR_CODE_MONTHLY_ISSUING         constant com_api_type_pkg.t_name := 'VIQR0005';
QR_CODE_CARD_ISSUANCE           constant com_api_type_pkg.t_name := 'VIQR0006';
QR_CODE_SCHEDULE_A_E            constant com_api_type_pkg.t_name := 'VIQR0007';
QR_CODE_CO_BRAND                constant com_api_type_pkg.t_name := 'VIQR0008';
QR_CODE_V_PAY                   constant com_api_type_pkg.t_name := 'VIQR0009';
QR_CODE_CONTACTLESS             constant com_api_type_pkg.t_name := 'VIQR0010';
QR_CODE_ECOMMERCE               constant com_api_type_pkg.t_name := 'VIQR0011';
QR_CODE_ACQUIRING_ATM           constant com_api_type_pkg.t_name := 'VIQR0012';
QR_CODE_ACQUIRING               constant com_api_type_pkg.t_name := 'VIQR0013';
QR_CODE_MOTO_RECURRING          constant com_api_type_pkg.t_name := 'VIQR0014';
QR_CODE_ACQUIRING_VMT           constant com_api_type_pkg.t_name := 'VIQR0015';
QR_CODE_CEMEA                   constant com_api_type_pkg.t_name := 'VIQR0016';
QR_CODE_CROSS_BORDER            constant com_api_type_pkg.t_name := 'VIQR0017';
QR_CODE_ACQUIRING_BAI           constant com_api_type_pkg.t_name := 'VIQR0019';

QR_ARRAY_TYPE                   constant com_api_type_pkg.t_tiny_id  := 1030;
QR_BAI_ARRAY_TYPE               constant com_api_type_pkg.t_tiny_id  := 1084;
QR_ACQ_OPER_TYPE_ARRAY          constant com_api_type_pkg.t_short_id := 10000031;
QR_ISS_OPER_TYPE_ARRAY          constant com_api_type_pkg.t_short_id := 10000032;
QR_CARD_TYPE_ARRAY              constant com_api_type_pkg.t_short_id := 10000034;
QR_CO_BRAND_ARRAY               constant com_api_type_pkg.t_short_id := 10000035;
QR_CONTACTLESS_ARRAY            constant com_api_type_pkg.t_short_id := 10000053;
QR_CARD_NETWORK_ARRAY           constant com_api_type_pkg.t_short_id := 10000108;
QR_CEMEA_ACQ_OPER_TYPE_ARRAY    constant com_api_type_pkg.t_short_id := 10000115;
QR_CEMEA_ISS_OPER_TYPE_ARRAY    constant com_api_type_pkg.t_short_id := 10000116;
QR_BAI_REPORT_PARAMS_ARRAY      constant com_api_type_pkg.t_short_id := 10000124;

VISA_REGION_EUROPE              constant com_api_type_pkg.t_name := 'EU';
VISA_REGION_ASIA_PACIFIC        constant com_api_type_pkg.t_name := 'AP';

VISA_STTL_SELL_RATE_TYPE        constant com_api_type_pkg.t_dict_value := 'RTTPVISR';
VISA_STTL_BUY_RATE_TYPE         constant com_api_type_pkg.t_dict_value := 'RTTPVIBR';

-- VISA Award reason codes (TC 10 / TC 20)
FEE_RSN_CODE_AWARD              constant com_api_type_pkg.t_mcc := '6040';
FEE_RSN_CODE_AWARD_REVERSAL     constant com_api_type_pkg.t_mcc := '6050';
FEE_RSN_CODE_OFFSET_SUM         constant com_api_type_pkg.t_mcc := '6060';
FEE_RSN_CODE_OFFSET_SUM_RVRSL   constant com_api_type_pkg.t_mcc := '6070';
FEE_RSN_SWEEP_AWARD_RVRSL       constant com_api_type_pkg.t_mcc := '5340';
FEE_RSN_SWEEP_SUMMARY_RVRSL     constant com_api_type_pkg.t_mcc := '5360';
FEE_RSN_POINTS_SETTLE_RVRSL     constant com_api_type_pkg.t_mcc := '6010';
FEE_RSN_POINTS_CREDIT_RVRSL     constant com_api_type_pkg.t_mcc := '6030';
FEE_RSN_VISA_REWARD_RVRSL       constant com_api_type_pkg.t_mcc := '6085';
FEE_RSN_CARDHOLDER_FEE_RVRSL    constant com_api_type_pkg.t_mcc := '6110';
FEE_RSN_CARDHOLDER_CRED_RVRSL   constant com_api_type_pkg.t_mcc := '6130';
FEE_RSN_PURCHASING_VAT_RVRSL    constant com_api_type_pkg.t_mcc := '6210';

QR_ELECTRON_CARD_TYPE           constant com_api_type_pkg.t_tiny_id := 1011;
QR_V_PAY_CARD_TYPE              constant com_api_type_pkg.t_tiny_id := 1053;

EVENT_TYPE_SMS_DISPUTE_CREATED  constant com_api_type_pkg.t_dict_value := 'EVNT2010';
EVENT_TYPE_VSS_MESSAGE          constant com_api_type_pkg.t_dict_value := 'EVNT1912';

EVENT_TYPE_MERCHANT_ACTIVATION  constant com_api_type_pkg.t_dict_value := 'EVNT0280';
EVENT_TYPE_MERCHANT_CHANGE      constant com_api_type_pkg.t_dict_value := 'EVNT0230';

ENTITY_TYPE_VSS_MESSAGE         constant com_api_type_pkg.t_dict_value := 'ENTTVSSM';

INSTITUTION_VISA                constant com_api_type_pkg.t_inst_id := 9002;
INSTITUTION_VISA_SMS            constant com_api_type_pkg.t_inst_id := 9006;

TAG_BUSINESS_APPLICATION_ID     constant com_api_type_pkg.t_short_id := 55; -- DF8A24 Business Application Identifier

BAI_MERCHANT_PAYMENT            constant com_api_type_pkg.t_byte_char :='MP';
BAI_CASH_OUT                    constant com_api_type_pkg.t_byte_char :='CO';

-- TCR3
INDUSTRY_SPEC_DATA_CREDIT_FUND  constant com_api_type_pkg.t_byte_char := 'CR';
INDUSTRY_SPEC_DATA_PASS_ITINER  constant com_api_type_pkg.t_byte_char := 'AI';

TAG_PASS_ITINER_PASSENGER_NAME  constant com_api_type_pkg.t_short_id := 35401; -- DF8A49  Passenger Itinerary. Passenger Name
TAG_PASS_ITINER_DEPARTURE_DATE  constant com_api_type_pkg.t_short_id := 35402; -- DF8A4A  Passenger Itinerary. Departure Date (MMDDYY)
TAG_PASS_ITINER_ORIG_CITY_AIR   constant com_api_type_pkg.t_short_id := 35403; -- DF8A4B  Passenger Itinerary. Origination City/Airport Code
TAG_PASS_ITINER_CARRIER_CODE1   constant com_api_type_pkg.t_short_id := 35404; -- DF8A4C  Passenger Itinerary. Trip Leg 1. Carrier Code
TAG_PASS_ITINER_SERVICE_CLASS1  constant com_api_type_pkg.t_short_id := 35405; -- DF8A4D  Passenger Itinerary. Trip Leg 1. Service Class
TAG_PASS_ITINER_STOP_OVR_CODE1  constant com_api_type_pkg.t_short_id := 35406; -- DF8A4E  Passenger Itinerary. Trip Leg 1. Stop-Over Code
TAG_PASS_ITINER_DEST_CITY_AIR1  constant com_api_type_pkg.t_short_id := 35407; -- DF8A4F  Passenger Itinerary. Trip Leg 1. Destination City/Airport Code
TAG_PASS_ITINER_CARRIER_CODE2   constant com_api_type_pkg.t_short_id := 35408; -- DF8A50  Passenger Itinerary. Trip Leg 2. Carrier Code
TAG_PASS_ITINER_SERVICE_CLASS2  constant com_api_type_pkg.t_short_id := 35409; -- DF8A51  Passenger Itinerary. Trip Leg 2. Service Class
TAG_PASS_ITINER_STOP_OVR_CODE2  constant com_api_type_pkg.t_short_id := 35410; -- DF8A52  Passenger Itinerary. Trip Leg 2. Stop-Over Code
TAG_PASS_ITINER_DEST_CITY_AIR2  constant com_api_type_pkg.t_short_id := 35411; -- DF8A53  Passenger Itinerary. Trip Leg 2. Destination City/Airport Code
TAG_PASS_ITINER_CARRIER_CODE3   constant com_api_type_pkg.t_short_id := 35412; -- DF8A54  Passenger Itinerary. Trip Leg 3. Carrier Code
TAG_PASS_ITINER_SERVICE_CLASS3  constant com_api_type_pkg.t_short_id := 35413; -- DF8A55  Passenger Itinerary. Trip Leg 3. Service Class
TAG_PASS_ITINER_STOP_OVR_CODE3  constant com_api_type_pkg.t_short_id := 35414; -- DF8A56  Passenger Itinerary. Trip Leg 3. Stop-Over Code
TAG_PASS_ITINER_DEST_CITY_AIR3  constant com_api_type_pkg.t_short_id := 35415; -- DF8A57  Passenger Itinerary. Trip Leg 3. Destination City/Airport Code
TAG_PASS_ITINER_CARRIER_CODE4   constant com_api_type_pkg.t_short_id := 35416; -- DF8A58  Passenger Itinerary. Trip Leg 4. Carrier Code
TAG_PASS_ITINER_SERVICE_CLASS4  constant com_api_type_pkg.t_short_id := 35417; -- DF8A59  Passenger Itinerary. Trip Leg 4. Service Class
TAG_PASS_ITINER_STOP_OVR_CODE4  constant com_api_type_pkg.t_short_id := 35418; -- DF8A5A  Passenger Itinerary. Trip Leg 4. Stop-Over Code
TAG_PASS_ITINER_DEST_CITY_AIR4  constant com_api_type_pkg.t_short_id := 35419; -- DF8A5B  Passenger Itinerary. Trip Leg 4. Destination City/Airport Code
TAG_PASS_ITINER_TRAV_AGEN_CODE  constant com_api_type_pkg.t_short_id := 35420; -- DF8A5C  Passenger Itinerary. Travel Agency Code
TAG_PASS_ITINER_TRAV_AGEN_NAME  constant com_api_type_pkg.t_short_id := 35421; -- DF8A5D  Passenger Itinerary. Travel Agency Name
TAG_PASS_ITINER_R_TICKET_INDIC  constant com_api_type_pkg.t_short_id := 35422; -- DF8A5E  Passenger Itinerary. Restricted Ticket Indicator
TAG_PASS_ITINER_FARE_BAS_CODE1  constant com_api_type_pkg.t_short_id := 35389; -- DF8A3D  Passenger Itinerary. Fare Basis Code - Leg 1
TAG_PASS_ITINER_FARE_BAS_CODE2  constant com_api_type_pkg.t_short_id := 35390; -- DF8A3E  Passenger Itinerary. Fare Basis Code - Leg 2
TAG_PASS_ITINER_FARE_BAS_CODE3  constant com_api_type_pkg.t_short_id := 35391; -- DF8A3F  Passenger Itinerary. Fare Basis Code - Leg 3
TAG_PASS_ITINER_FARE_BAS_CODE4  constant com_api_type_pkg.t_short_id := 35392; -- DF8A40  Passenger Itinerary. Fare Basis Code - Leg 4
TAG_PASS_ITINER_COMP_RESRV_SYS  constant com_api_type_pkg.t_short_id := 35393; -- DF8A41  Passenger Itinerary. Computerized Reservation System
TAG_PASS_ITINER_FLIGHT_NUMBER1  constant com_api_type_pkg.t_short_id := 35394; -- DF8A42  Passenger Itinerary. Flight Number - Leg 1
TAG_PASS_ITINER_FLIGHT_NUMBER2  constant com_api_type_pkg.t_short_id := 35395; -- DF8A43  Passenger Itinerary. Flight Number - Leg 2
TAG_PASS_ITINER_FLIGHT_NUMBER3  constant com_api_type_pkg.t_short_id := 35396; -- DF8A44  Passenger Itinerary. Flight Number - Leg 3
TAG_PASS_ITINER_FLIGHT_NUMBER4  constant com_api_type_pkg.t_short_id := 35397; -- DF8A45  Passenger Itinerary. Flight Number - Leg 4
TAG_PASS_ITINER_CRD_RSN_INDIC   constant com_api_type_pkg.t_short_id := 35398; -- DF8A46  Passenger Itinerary. Credit Reason Indicator
TAG_PASS_ITINER_TIC_CHN_INDIC   constant com_api_type_pkg.t_short_id := 35399; -- DF8A47  Passenger Itinerary. Ticket Change Indicator

VIS_AMMF_SERVICE_TYPE_ID        constant com_api_type_pkg.t_short_id := 10004482;

g_default_charset               com_api_type_pkg.t_oracle_name;
function init_default_charset return com_api_type_pkg.t_oracle_name;

end;
/
