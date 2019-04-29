create or replace package mup_api_const_pkg is

    MODULE_CODE_MUP                       constant com_api_type_pkg.t_module_code := 'MUP';
    MUP_NETWORK_ID                        constant com_api_type_pkg.t_tiny_id := 1013;
    NATIONAL_PROC_CENTER_INST             constant com_api_type_pkg.t_inst_id := 9014;
    CUP_NETWORK_ID                        constant com_api_type_pkg.t_tiny_id := 1010;
    JCB_NETWORK_ID                        constant com_api_type_pkg.t_tiny_id := 1011;
    MUP_STANDARD_ID                       constant com_api_type_pkg.t_tiny_id := 1035;

    MUP_STANDARD_VERSION_ID_18Q4          constant com_api_type_pkg.t_tiny_id := 1091;
    MUP_STANDARD_VERSION_ID_19Q2          constant com_api_type_pkg.t_tiny_id := 1101;

    MUP_TRANS_REPORT_AIR_HEADER           constant com_api_type_pkg.t_dict_value := 'HAIR';

    MSG_STATUS_INVALID                    constant com_api_type_pkg.t_dict_value := 'CLMS0080';
    MSG_STATUS_DO_NOT_UNLOAD              constant com_api_type_pkg.t_dict_value := 'CLMS0100';

    PDS_TAG_LEN                           constant number := 4;
    PDS_LENGTH_LEN                        constant number := 3;

    MAX_PDS_LEN                           constant number := 992;
    MAX_PDS_DE_LEN                        constant number := 999;
    MAX_PDS_DE_COUNT                      constant number := 5; -- (DE048, DE062, DE123, DE124, DE125)

    RECONCILIATION_MODE_FULL              constant mup_api_type_pkg.t_pds_body := 'RCLMFULL';
    RECONCILIATION_MODE_NONE              constant mup_api_type_pkg.t_pds_body := 'RCLMNONE';

    CLEARING_MODE_TEST                    constant mup_api_type_pkg.t_pds_body := 'T';
    CLEARING_MODE_PRODUCTION              constant mup_api_type_pkg.t_pds_body := 'P';
    CLEARING_MODE_DEFAULT                 constant mup_api_type_pkg.t_pds_body := CLEARING_MODE_TEST;

    MSG_TYPE_PRESENTMENT                  constant mup_api_type_pkg.t_mti := '1240';
    FUNC_CODE_FIRST_PRES                  constant mup_api_type_pkg.t_de024 := '200';
    FUNC_CODE_SECOND_PRES_FULL            constant mup_api_type_pkg.t_de024 := '205';
    FUNC_CODE_ADJUSTMENT                  constant mup_api_type_pkg.t_de024 := '220';
    FUNC_CODE_SECOND_PRES_PART            constant mup_api_type_pkg.t_de024 := '282';

    MSG_TYPE_CHARGEBACK                   constant mup_api_type_pkg.t_mti := '1442';
    FUNC_CODE_CHARGEBACK1_FULL            constant mup_api_type_pkg.t_de024 := '450';
    FUNC_CODE_CHARGEBACK1_PART            constant mup_api_type_pkg.t_de024 := '453';
    FUNC_CODE_CHARGEBACK2_FULL            constant mup_api_type_pkg.t_de024 := '451';
    FUNC_CODE_CHARGEBACK2_PART            constant mup_api_type_pkg.t_de024 := '454';

    MSG_TYPE_ADMINISTRATIVE               constant mup_api_type_pkg.t_mti := '1644';
    FUNC_CODE_HEADER                      constant mup_api_type_pkg.t_de024 := '697';
    FUNC_CODE_TRAILER                     constant mup_api_type_pkg.t_de024 := '695';
    FUNC_CODE_ADDENDUM                    constant mup_api_type_pkg.t_de024 := '696';
    FUNC_CODE_RETRIEVAL_REQUEST           constant mup_api_type_pkg.t_de024 := '603';
    FUNC_CODE_FILE_SUMMARY                constant mup_api_type_pkg.t_de024 := '680';
    FUNC_CODE_FPD                         constant mup_api_type_pkg.t_de024 := '685';
    FUNC_CODE_MSG_REJECT                  constant mup_api_type_pkg.t_de024 := '691';
    FUNC_CODE_FILE_REJECT                 constant mup_api_type_pkg.t_de024 := '699';
    FUNC_CODE_TEXT                        constant mup_api_type_pkg.t_de024 := '693';

    MSG_TYPE_FEE                          constant mup_api_type_pkg.t_mti := '1740';
    FUNC_CODE_MEMBER_FEE                  constant mup_api_type_pkg.t_de024 := '700';
    FUNC_CODE_FEE_RETURN                  constant mup_api_type_pkg.t_de024 := '780';
    FUNC_CODE_FEE_RESUBMITION             constant mup_api_type_pkg.t_de024 := '781';
    FUNC_CODE_FEE_SECOND_RETURN           constant mup_api_type_pkg.t_de024 := '782';
    FUNC_CODE_SYSTEM_FEE                  constant mup_api_type_pkg.t_de024 := '783';

    MSG_TYPE_NOTIFICATION                 constant mup_api_type_pkg.t_mti := '1244';
    FUNC_CODE_SYSTEM_NTF                  constant mup_api_type_pkg.t_de024 := '299';

    FEE_REASON_RETRIEVAL_RESP             constant mup_api_type_pkg.t_de025 := '7614';
    FEE_REASON_HANDL_ISS_CHBK             constant mup_api_type_pkg.t_de025 := '7622';
    FEE_REASON_HANDL_ACQ_PRES2            constant mup_api_type_pkg.t_de025 := '7623';
    FEE_REASON_HANDL_ISS_CHBK2            constant mup_api_type_pkg.t_de025 := '7624';
    FEE_REASON_HANDL_ISS_ADVICE           constant mup_api_type_pkg.t_de025 := '7627';

    CHBK_REASON_WARN_BULLETIN             constant mup_api_type_pkg.t_de025 := '4807';
    CHBK_REASON_NO_AUTH                   constant mup_api_type_pkg.t_de025 := '4808';
    CHBK_REASON_NO_AUTH_FLOOR             constant mup_api_type_pkg.t_de025 := '4847';

    PROC_CODE_PURCHASE                    constant mup_api_type_pkg.t_de003 := '00';
    PROC_CODE_ATM                         constant mup_api_type_pkg.t_de003 := '01';
    PROC_CODE_DEBIT                       constant mup_api_type_pkg.t_de003 := '02';
    PROC_CODE_CASH                        constant mup_api_type_pkg.t_de003 := '12';
    PROC_CODE_CREDIT_FEE                  constant mup_api_type_pkg.t_de003 := '19';
    PROC_CODE_REFUND                      constant mup_api_type_pkg.t_de003 := '20';
    PROC_CODE_P2P_CREDIT                  constant mup_api_type_pkg.t_de003 := '26';
    PROC_CODE_CASH_IN                     constant mup_api_type_pkg.t_de003 := '27';
    PROC_CODE_PAYMENT                     constant mup_api_type_pkg.t_de003 := '28';
    PROC_CODE_DEBIT_FEE                   constant mup_api_type_pkg.t_de003 := '29';

    DEFAULT_DE003_2                       constant mup_api_type_pkg.t_de003 := '00';
    DEFAULT_DE003_3                       constant mup_api_type_pkg.t_de003 := '00';

    DE012_DATE_FORMAT                     constant com_api_type_pkg.t_oracle_name := 'YYMMDDhh24miss';
    DE014_DATE_FORMAT                     constant com_api_type_pkg.t_oracle_name := 'YYMM';
    DE031_DATE_FORMAT                     constant com_api_type_pkg.t_oracle_name := 'YDDD';
    DE031_SEQ_FORMAT                      constant com_api_type_pkg.t_oracle_name := 'FM09999999999';
    DE073_DATE_FORMAT                     constant com_api_type_pkg.t_oracle_name := 'YYMMDD';

    DE043_FIELD_DELIMITER                 constant char(1) := '\';

    P0025_DATE_FORMAT                     constant com_api_type_pkg.t_oracle_name := 'YYMMDD';
    P0105_DATE_FORMAT                     constant com_api_type_pkg.t_oracle_name := 'YYMMDD';
    P2158_DATE_FORMAT                     constant com_api_type_pkg.t_oracle_name := 'YYMMDD';
    P2159_DATE_FORMAT                     constant com_api_type_pkg.t_oracle_name := 'YYMMDD';

    P0005_PART_LENGTH                     constant integer := 14;
    P0146_PART_LENGTH                     constant integer := 36;

    SETTLEMENT_TYPE_MUP                   constant char(1) := 'M';
    SETTLEMENT_TYPE_COLLECTION            constant char(1) := 'C';
    SETTLEMENT_TYPE_COLLECT_ON_US         constant char(1) := 'R';

    FILE_TYPE_CLEARING_MUP                constant com_api_type_pkg.t_dict_value := 'FLTPCLMP';
    FILE_TYPE_ISSUER_BIN                  constant com_api_type_pkg.t_dict_value := 'FLTPBIMP';
    FILE_TYPE_ACQUIRER_BIN                constant com_api_type_pkg.t_dict_value := 'FLTPBAMP';

    FILE_TYPE_INC_CLEARING_MUP            constant mup_api_type_pkg.t_pds_body := '101';
    FILE_TYPE_OUT_CLEARING_MUP            constant mup_api_type_pkg.t_pds_body := '102';
    FILE_TYPE_INC_EARLY_REJECT_MUP        constant mup_api_type_pkg.t_pds_body := '103';

    FILE_TYPE_OUT_COLLECTION_ONLY         constant mup_api_type_pkg.t_pds_body := '122'; 

    FILE_TYPE_INC_CLEARING_CUP            constant mup_api_type_pkg.t_pds_body := '201';
    FILE_TYPE_OUT_CLEARING_CUP            constant mup_api_type_pkg.t_pds_body := '202';
    FILE_TYPE_INC_EARLY_REJECT_CUP        constant mup_api_type_pkg.t_pds_body := '203';

    FILE_TYPE_INC_CLEARING_JCB            constant mup_api_type_pkg.t_pds_body := '301';
    FILE_TYPE_OUT_CLEARING_JCB            constant mup_api_type_pkg.t_pds_body := '302';
    FILE_TYPE_INC_EARLY_REJECT_JCB        constant mup_api_type_pkg.t_pds_body := '303';

    FILE_TYPE_INC_CLEARING_AMX            constant mup_api_type_pkg.t_pds_body := '401';
    FILE_TYPE_OUT_CLEARING_AMX            constant mup_api_type_pkg.t_pds_body := '402';
    FILE_TYPE_INC_EARLY_REJECT_AMX        constant mup_api_type_pkg.t_pds_body := '403';

    PDS_TAG_0001                          constant mup_api_type_pkg.t_pds_tag := 0001;
    PDS_TAG_0002                          constant mup_api_type_pkg.t_pds_tag := 0002;
    PDS_TAG_0005                          constant mup_api_type_pkg.t_pds_tag := 0005;
    PDS_TAG_0025                          constant mup_api_type_pkg.t_pds_tag := 0025;
    PDS_TAG_0026                          constant mup_api_type_pkg.t_pds_tag := 0026;
    PDS_TAG_0105                          constant mup_api_type_pkg.t_pds_tag := 0105;
    PDS_TAG_0122                          constant mup_api_type_pkg.t_pds_tag := 0122;
    PDS_TAG_0137                          constant mup_api_type_pkg.t_pds_tag := 0137;
    PDS_TAG_0138                          constant mup_api_type_pkg.t_pds_tag := 0138;
    PDS_TAG_0146                          constant mup_api_type_pkg.t_pds_tag := 0146;
    PDS_TAG_0148                          constant mup_api_type_pkg.t_pds_tag := 0148;
    PDS_TAG_0149                          constant mup_api_type_pkg.t_pds_tag := 0149;
    PDS_TAG_0164                          constant mup_api_type_pkg.t_pds_tag := 0164;
    PDS_TAG_0165                          constant mup_api_type_pkg.t_pds_tag := 0165;
    PDS_TAG_0170                          constant mup_api_type_pkg.t_pds_tag := 0170;
    PDS_TAG_0171                          constant mup_api_type_pkg.t_pds_tag := 0171;
    PDS_TAG_0175                          constant mup_api_type_pkg.t_pds_tag := 0175;
    PDS_TAG_0176                          constant mup_api_type_pkg.t_pds_tag := 0176;
    PDS_TAG_0190                          constant mup_api_type_pkg.t_pds_tag := 0190;
    PDS_TAG_0198                          constant mup_api_type_pkg.t_pds_tag := 0198;
    PDS_TAG_0206                          constant mup_api_type_pkg.t_pds_tag := 0206;
    PDS_TAG_0208                          constant mup_api_type_pkg.t_pds_tag := 0208;
    PDS_TAG_0228                          constant mup_api_type_pkg.t_pds_tag := 0228;
    PDS_TAG_0230                          constant mup_api_type_pkg.t_pds_tag := 0230;
    PDS_TAG_0261                          constant mup_api_type_pkg.t_pds_tag := 0261;
    PDS_TAG_0262                          constant mup_api_type_pkg.t_pds_tag := 0262;
    PDS_TAG_0264                          constant mup_api_type_pkg.t_pds_tag := 0264;
    PDS_TAG_0265                          constant mup_api_type_pkg.t_pds_tag := 0265;
    PDS_TAG_0266                          constant mup_api_type_pkg.t_pds_tag := 0266;
    PDS_TAG_0267                          constant mup_api_type_pkg.t_pds_tag := 0267;
    PDS_TAG_0268                          constant mup_api_type_pkg.t_pds_tag := 0268;
    PDS_TAG_0280                          constant mup_api_type_pkg.t_pds_tag := 0280;
    PDS_TAG_0300                          constant mup_api_type_pkg.t_pds_tag := 0300;
    PDS_TAG_0301                          constant mup_api_type_pkg.t_pds_tag := 0301;
    PDS_TAG_0302                          constant mup_api_type_pkg.t_pds_tag := 0302;
    PDS_TAG_0306                          constant mup_api_type_pkg.t_pds_tag := 0306;
    PDS_TAG_0368                          constant mup_api_type_pkg.t_pds_tag := 0368;
    PDS_TAG_0369                          constant mup_api_type_pkg.t_pds_tag := 0369;
    PDS_TAG_0370                          constant mup_api_type_pkg.t_pds_tag := 0370;
    PDS_TAG_0372                          constant mup_api_type_pkg.t_pds_tag := 0372;
    PDS_TAG_0374                          constant mup_api_type_pkg.t_pds_tag := 0374;
    PDS_TAG_0375                          constant mup_api_type_pkg.t_pds_tag := 0375;
    PDS_TAG_0378                          constant mup_api_type_pkg.t_pds_tag := 0378;
    PDS_TAG_0380                          constant mup_api_type_pkg.t_pds_tag := 0380;
    PDS_TAG_0381                          constant mup_api_type_pkg.t_pds_tag := 0381;
    PDS_TAG_0384                          constant mup_api_type_pkg.t_pds_tag := 0384;
    PDS_TAG_0390                          constant mup_api_type_pkg.t_pds_tag := 0390;
    PDS_TAG_0391                          constant mup_api_type_pkg.t_pds_tag := 0391;
    PDS_TAG_0392                          constant mup_api_type_pkg.t_pds_tag := 0392;
    PDS_TAG_0393                          constant mup_api_type_pkg.t_pds_tag := 0393;
    PDS_TAG_0394                          constant mup_api_type_pkg.t_pds_tag := 0394;
    PDS_TAG_0395                          constant mup_api_type_pkg.t_pds_tag := 0395;
    PDS_TAG_0396                          constant mup_api_type_pkg.t_pds_tag := 0396;
    PDS_TAG_0400                          constant mup_api_type_pkg.t_pds_tag := 0400;
    PDS_TAG_0401                          constant mup_api_type_pkg.t_pds_tag := 0401;
    PDS_TAG_0402                          constant mup_api_type_pkg.t_pds_tag := 0402;
    PDS_TAG_0799                          constant mup_api_type_pkg.t_pds_tag := 0799;
    PDS_TAG_2001                          constant mup_api_type_pkg.t_pds_tag := 2001;
    PDS_TAG_2002                          constant mup_api_type_pkg.t_pds_tag := 2002;
    PDS_TAG_2063                          constant mup_api_type_pkg.t_pds_tag := 2063;
    PDS_TAG_2072                          constant mup_api_type_pkg.t_pds_tag := 2072;
    PDS_TAG_2097                          constant mup_api_type_pkg.t_pds_tag := 2097;
    PDS_TAG_2158                          constant mup_api_type_pkg.t_pds_tag := 2158;
    PDS_TAG_2159                          constant mup_api_type_pkg.t_pds_tag := 2159;
    PDS_TAG_2175                          constant mup_api_type_pkg.t_pds_tag := 2175;
    PDS_TAG_2358                          constant mup_api_type_pkg.t_pds_tag := 2358;
    PDS_TAG_2359                          constant mup_api_type_pkg.t_pds_tag := 2359;

    REVERSAL_PDS_CANCEL                   constant mup_api_type_pkg.t_pds_body := ' ';
    REVERSAL_PDS_REVERSAL                 constant mup_api_type_pkg.t_pds_body := 'R';
    REVERSAL_PDS_ORIGINAL                 constant mup_api_type_pkg.t_pds_body := 'O';

    CREDIT                                constant mup_api_type_pkg.t_pds_body := 'C';
    DEBIT                                 constant mup_api_type_pkg.t_pds_body := 'D';

    MCC_CASH                              constant com_api_type_pkg.t_mcc        := '6010';
    MCC_ATM                               constant com_api_type_pkg.t_mcc        := '6011';

    -- standard parameters
    RECONCILIATION_MODE                   constant com_api_type_pkg.t_name := 'RECONCILIATION_MODE';
    CLEARING_MODE                         constant com_api_type_pkg.t_name := 'CLEARING_MODE';
    CMID                                  constant com_api_type_pkg.t_name := 'BUSINESS_ICA';
    ACQUIRER_BIN                          constant com_api_type_pkg.t_name := 'ACQUIRER_BIN';
    FORW_INST_ID                          constant com_api_type_pkg.t_name := 'FORW_INST_ID';
    COLLECTION_ONLY                       constant com_api_type_pkg.t_name := 'COLLECTION_ONLY';

    g_default_charset                     com_api_type_pkg.t_oracle_name;

    function init_default_charset return  com_api_type_pkg.t_oracle_name;

    FPD_REASON_ACKNOWLEDGEMENT            constant mup_api_type_pkg.t_de025 := '6861';
    FPD_REASON_NOTIFICATION               constant mup_api_type_pkg.t_de025 := '6862';

    UPLOAD_FORWARDING                     constant com_api_type_pkg.t_dict_value := 'UPIN0010';
    UPLOAD_ORIGINATOR                     constant com_api_type_pkg.t_dict_value := 'UPIN0020';

    --rejects
    C_REJECT_CODE_INVALID_FORMAT          constant com_api_type_pkg.t_text := '01';
    C_DEF_SCHEME                          constant com_api_type_pkg.t_text := 'Servired';

    OPER_TYPE_DEBIT_NOTIF                 constant com_api_type_pkg.t_dict_value := 'OPTP0002';

    -- List of EMV tags that should be retrieved from auth EMV data and save to field DE55,
    -- every tag is associated with data type (empty data type is treated as HEX),
    -- for numeric tags is also defined lenghts of their hexadecimal representation
    EMV_TAGS_LIST_FOR_DE055               constant emv_api_type_pkg.t_emv_tag_type_tab :=
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

    CBRF_RATE constant com_api_type_pkg.t_dict_value := 'RTTPCBRF';

    OPER_REASON_DEBIT_ADJUSTMENT          constant com_api_type_pkg.t_dict_value := 'OPRS0003';

end mup_api_const_pkg;
/
