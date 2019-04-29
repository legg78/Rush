create or replace package h2h_api_const_pkg is

MODULE_CODE_H2H             constant com_api_type_pkg.t_module_code := 'H2H';
MODULE_CODE_MASTERCARD      constant com_api_type_pkg.t_module_code := 'MCW';
MODULE_CODE_VISA            constant com_api_type_pkg.t_module_code := 'VIS';
MODULE_CODE_DINERS          constant com_api_type_pkg.t_module_code := 'DIN';
MODULE_CODE_JCB             constant com_api_type_pkg.t_module_code := 'JCB';
MODULE_CODE_AMEX            constant com_api_type_pkg.t_module_code := 'AMX';
MODULE_CODE_MUP             constant com_api_type_pkg.t_module_code := 'MUP';

H2H_STANDARD_ID             constant com_api_type_pkg.t_tiny_id     := 1052;
FILE_TYPE_H2H               constant com_api_type_pkg.t_dict_value  := 'FLTPH2H';
ENTITY_TYPE_H2H             constant com_api_type_pkg.t_dict_value  := 'ENTTH2H';
H2H_INST_CODE               constant com_api_type_pkg.t_name        := 'H2H_INST_CODE';

USE_INSTITUTION_FORWARDING  constant com_api_type_pkg.t_dict_value  := 'USIC6810'; -- forwarding/originator
USE_INSTITUTION_RECEIVING   constant com_api_type_pkg.t_dict_value  := 'USIC6820';

H2H_STANDARD_VERSION_18Q4   constant com_api_type_pkg.t_tiny_id     := 1089;

EMV_TAGS_LIST_FOR_H2H       constant emv_api_type_pkg.t_emv_tag_type_tab :=
    emv_api_type_pkg.t_emv_tag_type_tab(
        com_name_pair_tpr('5F2A', 'DTTPNMBR4')
      , com_name_pair_tpr('5F34', 'DTTPNMBR4')
      , com_name_pair_tpr('71',   'DTTPCHAR16')
      , com_name_pair_tpr('72',   'DTTPCHAR16')
      , com_name_pair_tpr('82',   'DTTPCHAR8')
      , com_name_pair_tpr('84',   'DTTPCHAR32')
      , com_name_pair_tpr('8A',   'DTTPCHAR2')
      , com_name_pair_tpr('91',   'DTTPCHAR32')
      , com_name_pair_tpr('95',   'DTTPCHAR10')
      , com_name_pair_tpr('9A',   'DTTPNMBR6')
      , com_name_pair_tpr('9C',   'DTTPNMBR2')
      , com_name_pair_tpr('9F02', 'DTTPNMBR12')
      , com_name_pair_tpr('9F03', 'DTTPNMBR12')
      , com_name_pair_tpr('9F06', 'DTTPCHAR64')
      , com_name_pair_tpr('9F09', 'DTTPCHAR4')
      , com_name_pair_tpr('9F10', 'DTTPCHAR64')
      , com_name_pair_tpr('9F18', 'DTTPCHAR8')
      , com_name_pair_tpr('9F1A', 'DTTPNMBR4')
      , com_name_pair_tpr('9F1E', 'DTTPCHAR16')
      , com_name_pair_tpr('9F26', 'DTTPCHAR16')
      , com_name_pair_tpr('9F27', 'DTTPCHAR2')
      , com_name_pair_tpr('9F28', 'DTTPCHAR16')
      , com_name_pair_tpr('9F29', 'DTTPCHAR16')
      , com_name_pair_tpr('9F33', 'DTTPCHAR6')
      , com_name_pair_tpr('9F34', 'DTTPCHAR6')
      , com_name_pair_tpr('9F35', 'DTTPNMBR2')
      , com_name_pair_tpr('9F36', 'DTTPCHAR4')
      , com_name_pair_tpr('9F37', 'DTTPCHAR8')
      , com_name_pair_tpr('9F41', 'DTTPNMBR8')
      , com_name_pair_tpr('9F53', 'DTTPCHAR2')
    );

TAG_DATE_FORMAT                 constant com_api_type_pkg.t_oracle_name := 'DD.MM.YYYY';

TAG_SENDER_NAME                 constant com_api_type_pkg.t_short_id    := 10000001;
TAG_SENDER_ADDRESS              constant com_api_type_pkg.t_short_id    := 10000002;
TAG_SENDER_CITY                 constant com_api_type_pkg.t_short_id    := 10000003;
TAG_SENDER_COUNTRY              constant com_api_type_pkg.t_short_id    := 10000004;
TAG_SENDER_POSTCODE             constant com_api_type_pkg.t_short_id    := 10000005;
TAG_PAYEE_FIRST_NAME            constant com_api_type_pkg.t_short_id    := 10000006;
TAG_PAYEE_LAST_NAME             constant com_api_type_pkg.t_short_id    := 10000066;
TAG_PAYEE_ADDRESS               constant com_api_type_pkg.t_short_id    := 10000007;
TAG_PAYEE_CITY                  constant com_api_type_pkg.t_short_id    := 10000008;
TAG_PAYEE_STATE                 constant com_api_type_pkg.t_short_id    := 10000067;
TAG_PAYEE_COUNTRY               constant com_api_type_pkg.t_short_id    := 10000009;
TAG_PAYEE_POSTCODE              constant com_api_type_pkg.t_short_id    := 10000010;
TAG_PAYEE_BIRTH                 constant com_api_type_pkg.t_short_id    := 10000011;
TAG_PAYEE_PHONE                 constant com_api_type_pkg.t_short_id    := 10000012;
TAG_INSTALL_TYPE                constant com_api_type_pkg.t_short_id    := 10000013;
TAG_INSTALL_COUNT               constant com_api_type_pkg.t_short_id    := 10000014;
TAG_SENDER_ACCOUNT              constant com_api_type_pkg.t_short_id    := 10000015;
TAG_FACILITATOR                 constant com_api_type_pkg.t_short_id    := 10000016;
TAG_SUB_MERCHANT                constant com_api_type_pkg.t_short_id    := 10000017;
TAG_IND_ORG_ID                  constant com_api_type_pkg.t_short_id    := 10000018;
TAG_WALLET_ID                   constant com_api_type_pkg.t_short_id    := 10000019;
TAG_ATM_FEE                     constant com_api_type_pkg.t_short_id    := 10000020;
TAG_PROGRAM_ID                  constant com_api_type_pkg.t_short_id    := 10000021;
TAG_ASSIGNED_ID                 constant com_api_type_pkg.t_short_id    := 10000022;
TAG_FUNDING_SOURCE              constant com_api_type_pkg.t_short_id    := 10000023;
TAG_BAI                         constant com_api_type_pkg.t_short_id    := 10000024;
TAG_FORMAT_CODE                 constant com_api_type_pkg.t_short_id    := 10000025;
TAG_PASSENGER_NAME              constant com_api_type_pkg.t_short_id    := 10000026;
TAG_DEPART_DATE                 constant com_api_type_pkg.t_short_id    := 10000027;
TAG_AIRPORT_CODE                constant com_api_type_pkg.t_short_id    := 10000028;
TAG_CARRIER_CODE_1              constant com_api_type_pkg.t_short_id    := 10000029;
TAG_SERVICE_CLASS_1             constant com_api_type_pkg.t_short_id    := 10000030;
TAG_STOP_CODE_1                 constant com_api_type_pkg.t_short_id    := 10000031;
TAG_AIRPORT_CODE_1              constant com_api_type_pkg.t_short_id    := 10000032;
TAG_CARRIER_CODE_2              constant com_api_type_pkg.t_short_id    := 10000033;
TAG_SERVICE_CLASS_2             constant com_api_type_pkg.t_short_id    := 10000034;
TAG_STOP_CODE_2                 constant com_api_type_pkg.t_short_id    := 10000035;
TAG_AIRPORT_CODE_2              constant com_api_type_pkg.t_short_id    := 10000036;
TAG_CARRIER_CODE_3              constant com_api_type_pkg.t_short_id    := 10000037;
TAG_SERVICE_CLASS_3             constant com_api_type_pkg.t_short_id    := 10000038;
TAG_STOP_CODE_3                 constant com_api_type_pkg.t_short_id    := 10000039;
TAG_AIRPORT_CODE_3              constant com_api_type_pkg.t_short_id    := 10000040;
TAG_CARRIER_CODE_4              constant com_api_type_pkg.t_short_id    := 10000041;
TAG_SERVICE_CLASS_4             constant com_api_type_pkg.t_short_id    := 10000042;
TAG_STOP_CODE_4                 constant com_api_type_pkg.t_short_id    := 10000043;
TAG_AIRPORT_CODE_4              constant com_api_type_pkg.t_short_id    := 10000044;
TAG_AGENCY_CODE                 constant com_api_type_pkg.t_short_id    := 10000045;
TAG_AGENCY_NAME                 constant com_api_type_pkg.t_short_id    := 10000046;
TAG_TICKET_ID                   constant com_api_type_pkg.t_short_id    := 10000047;
TAG_FARE_CODE_1                 constant com_api_type_pkg.t_short_id    := 10000048;
TAG_FARE_CODE_2                 constant com_api_type_pkg.t_short_id    := 10000049;
TAG_FARE_CODE_3                 constant com_api_type_pkg.t_short_id    := 10000050;
TAG_FARE_CODE_4                 constant com_api_type_pkg.t_short_id    := 10000051;
TAG_RESERV_SYSTEM               constant com_api_type_pkg.t_short_id    := 10000052;
TAG_FLIGHT_NUM_1                constant com_api_type_pkg.t_short_id    := 10000053;
TAG_FLIGHT_NUM_2                constant com_api_type_pkg.t_short_id    := 10000054;
TAG_FLIGHT_NUM_3                constant com_api_type_pkg.t_short_id    := 10000055;
TAG_FLIGHT_NUM_4                constant com_api_type_pkg.t_short_id    := 10000056;
TAG_CREDIT_ID                   constant com_api_type_pkg.t_short_id    := 10000057;
TAG_TICKET_CHANGE_ID            constant com_api_type_pkg.t_short_id    := 10000058;
TAG_VALID_CODE                  constant com_api_type_pkg.t_short_id    := 10000059;
TAG_MVV                         constant com_api_type_pkg.t_short_id    := 10000060;
TAG_DCC_INDICATOR               constant com_api_type_pkg.t_short_id    := 10000061;
TAG_AVS_CODE                    constant com_api_type_pkg.t_short_id    := 10000062;
TAG_AUTH_SOURCE_CODE            constant com_api_type_pkg.t_short_id    := 10000063;
TAG_ECI                         constant com_api_type_pkg.t_short_id    := 10000069;
TAG_FPI                         constant com_api_type_pkg.t_short_id    := 10000070;
TAG_REIMB_ATTR                  constant com_api_type_pkg.t_short_id    := 10000071;
TAG_DST_ACC_NUMBER              constant com_api_type_pkg.t_short_id    := 10000065;
TAG_PMT_ACC_REF                 constant com_api_type_pkg.t_short_id    := 10000064;
TAG_MEDIA_CODE                  constant com_api_type_pkg.t_short_id    := 10000073;
TAG_ICC_CHIP_PIN_IND            constant com_api_type_pkg.t_short_id    := 10000074;
TAG_ACQ_SWITCH_DATE             constant com_api_type_pkg.t_short_id    := 10000068;
TAG_NET_RESP_CODE               constant com_api_type_pkg.t_short_id    := 10000075;

IPS_FIELD_DELIMITER             constant com_api_type_pkg.t_oracle_name := '|';
IPS_FIELD_DATE_DELIMITER        constant com_api_type_pkg.t_oracle_name := 'date';

end h2h_api_const_pkg;
/
