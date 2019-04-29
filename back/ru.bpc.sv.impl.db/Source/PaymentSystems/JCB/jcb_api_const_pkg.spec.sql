create or replace package jcb_api_const_pkg is

    MODULE_CODE_JCB                     constant com_api_type_pkg.t_module_code := 'JCB';

    JCB_NETWORK_ID                      constant com_api_type_pkg.t_tiny_id := 1011;
    NATIONAL_PROC_CENTER_INST           constant com_api_type_pkg.t_inst_id := 9012;
    STANDARD_ID                         constant com_api_type_pkg.t_tiny_id := 1032;
    STANDARD_ID_VERISON_18Q2            constant com_api_type_pkg.t_tiny_id := 1071;

    PDS_TAG_LEN                         constant number := 4;
    PDS_LENGTH_LEN                      constant number := 3;

    MAX_PDS_LEN                         constant number := 992;
    MAX_PDS_DE_LEN                      constant number := 999;
    MAX_PDS_DE_COUNT                    constant number := 6; -- (DE048, DE062, DE123, DE124, DE125, DE126)

    CLEARING_MODE_TEST                  constant jcb_api_type_pkg.t_pds_body := 'T';
    CLEARING_MODE_PRODUCTION            constant jcb_api_type_pkg.t_pds_body := 'P';
    CLEARING_MODE_DEFAULT               constant jcb_api_type_pkg.t_pds_body := CLEARING_MODE_TEST;

    MSG_TYPE_PRESENTMENT                constant jcb_api_type_pkg.t_mti   := '1240';
    FUNC_CODE_FIRST_PRES                constant jcb_api_type_pkg.t_de024 := '200';
    FUNC_CODE_SECOND_PRES_FULL          constant jcb_api_type_pkg.t_de024 := '205';
    FUNC_CODE_SECOND_PRES_PART          constant jcb_api_type_pkg.t_de024 := '280';

    MSG_TYPE_ADMINISTRATIVE             constant jcb_api_type_pkg.t_mti   := '1644';
    FUNC_CODE_HEADER                    constant jcb_api_type_pkg.t_de024 := '689';
    FUNC_CODE_TRAILER                   constant jcb_api_type_pkg.t_de024 := '690';
    FUNC_CODE_ADDENDUM                  constant jcb_api_type_pkg.t_de024 := '695';
    FUNC_CODE_RETRIEVAL_REQUEST         constant jcb_api_type_pkg.t_de024 := '603';
    FUNC_CODE_ERROR_INFORMATION         constant jcb_api_type_pkg.t_de024 := '691';
    FUNC_CODE_FILE_REJECTION            constant jcb_api_type_pkg.t_de024 := '692';

    MSG_TYPE_CHARGEBACK                 constant jcb_api_type_pkg.t_mti   := '1442';
    FUNC_CODE_CHARGEBACK1_FULL          constant jcb_api_type_pkg.t_de024 := '450';
    FUNC_CODE_CHARGEBACK1_PART          constant jcb_api_type_pkg.t_de024 := '453';
    FUNC_CODE_CHARGEBACK2_FULL          constant jcb_api_type_pkg.t_de024 := '451';
    FUNC_CODE_CHARGEBACK2_PART          constant jcb_api_type_pkg.t_de024 := '454';

    MSG_TYPE_FEE                        constant jcb_api_type_pkg.t_mti   := '1740';
    FUNC_CODE_FEE_COLLECTION            constant jcb_api_type_pkg.t_de024 := '781';

    MSG_TYPE_ACKNOWLEDGMENT             constant jcb_api_type_pkg.t_mti   := '1540';
    FUNC_CODE_ACKNOWLEDGMENT            constant jcb_api_type_pkg.t_de024 := '570';

    DEFAULT_DE003_2                     constant jcb_api_type_pkg.t_de003 := '00';
    DEFAULT_DE003_3                     constant jcb_api_type_pkg.t_de003 := '00';

    P3901_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YYMMDD';
    DE012_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YYMMDDhh24miss';
    DE014_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YYMM';
    DE016_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'MMDD';
    DE031_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'MMDD';
    DE031_SEQ_FORMAT                    constant com_api_type_pkg.t_oracle_name := 'FM099999999999';
    P3007_DATE_FORMAT                   constant com_api_type_pkg.t_oracle_name := 'YYMMDD';
    TAG_9A_DATE_FORMAT                  constant com_api_type_pkg.t_oracle_name := 'YYMMDD';

    FILE_TYPE_CLEARING_JCB              constant com_api_type_pkg.t_dict_value := 'FLTPCLJB';

    FILE_TYPE_INC_CLEARING              constant jcb_api_type_pkg.t_pds_body := '001';
    FILE_TYPE_OUT_CLEARING              constant jcb_api_type_pkg.t_pds_body := '002';
    FILE_TYPE_VERIFICATION_RESULT       constant jcb_api_type_pkg.t_pds_body := '003';
    FILE_TYPE_SETTLEMENT_RESULT         constant jcb_api_type_pkg.t_pds_body := '004';

    PDS_TAG_3901                        constant jcb_api_type_pkg.t_pds_tag  := 3901;
    PDS_TAG_3902                        constant jcb_api_type_pkg.t_pds_tag  := 3902;
    PDS_TAG_3903                        constant jcb_api_type_pkg.t_pds_tag  := 3903;

    PDS_TAG_3001                        constant jcb_api_type_pkg.t_pds_tag  := 3001;
    PDS_TAG_3002                        constant jcb_api_type_pkg.t_pds_tag  := 3002;
    PDS_TAG_3003                        constant jcb_api_type_pkg.t_pds_tag  := 3003;
    PDS_TAG_3005                        constant jcb_api_type_pkg.t_pds_tag  := 3005;
    PDS_TAG_3006                        constant jcb_api_type_pkg.t_pds_tag  := 3006;
    PDS_TAG_3007                        constant jcb_api_type_pkg.t_pds_tag  := 3007;
    PDS_TAG_3008                        constant jcb_api_type_pkg.t_pds_tag  := 3008;
    PDS_TAG_3009                        constant jcb_api_type_pkg.t_pds_tag  := 3009;
    PDS_TAG_3011                        constant jcb_api_type_pkg.t_pds_tag  := 3011;
    PDS_TAG_3012                        constant jcb_api_type_pkg.t_pds_tag  := 3012;
    PDS_TAG_3013                        constant jcb_api_type_pkg.t_pds_tag  := 3013;
    PDS_TAG_3014                        constant jcb_api_type_pkg.t_pds_tag  := 3014;
    PDS_TAG_3021                        constant jcb_api_type_pkg.t_pds_tag  := 3021;

    PDS_TAG_3201                        constant jcb_api_type_pkg.t_pds_tag  := 3201;
    PDS_TAG_3202                        constant jcb_api_type_pkg.t_pds_tag  := 3202;
    PDS_TAG_3203                        constant jcb_api_type_pkg.t_pds_tag  := 3203;
    PDS_TAG_3205                        constant jcb_api_type_pkg.t_pds_tag  := 3205;
    PDS_TAG_3206                        constant jcb_api_type_pkg.t_pds_tag  := 3206;
    PDS_TAG_3207                        constant jcb_api_type_pkg.t_pds_tag  := 3207;
    PDS_TAG_3208                        constant jcb_api_type_pkg.t_pds_tag  := 3208;
    PDS_TAG_3209                        constant jcb_api_type_pkg.t_pds_tag  := 3209;
    PDS_TAG_3210                        constant jcb_api_type_pkg.t_pds_tag  := 3210;
    PDS_TAG_3211                        constant jcb_api_type_pkg.t_pds_tag  := 3211;

    PDS_TAG_3250                        constant jcb_api_type_pkg.t_pds_tag  := 3250;
    PDS_TAG_3251                        constant jcb_api_type_pkg.t_pds_tag  := 3251;
    PDS_TAG_3302                        constant jcb_api_type_pkg.t_pds_tag  := 3302;

    PDS_TAG_3600                        constant jcb_api_type_pkg.t_pds_tag  := 3600;
    PDS_TAG_3601                        constant jcb_api_type_pkg.t_pds_tag  := 3601;
    PDS_TAG_3602                        constant jcb_api_type_pkg.t_pds_tag  := 3602;
    PDS_TAG_3604                        constant jcb_api_type_pkg.t_pds_tag  := 3604;

    REVERSAL_PDS_CANCEL                 constant jcb_api_type_pkg.t_pds_body := ' ';
    REVERSAL_PDS_REVERSAL               constant jcb_api_type_pkg.t_pds_body := 'R';
    REVERSAL_PDS_ORIGINAL               constant jcb_api_type_pkg.t_pds_body := 'O';

    CREDIT                              constant jcb_api_type_pkg.t_pds_body := 'C';
    DEBIT                               constant jcb_api_type_pkg.t_pds_body := 'D';

    CMID                                constant com_api_type_pkg.t_name     := 'BUSINESS_ICA';
    ATM_FEE_CHARGE                      constant com_api_type_pkg.t_name     := 'ATM_FEE_CHARGE';
    --ACQUIRER_BIN                        constant com_api_type_pkg.t_name     := 'ACQUIRER_BIN';
    --FORW_INST_ID                        constant com_api_type_pkg.t_name     := 'FORW_INST_ID';
    RECV_INST_ID                        constant com_api_type_pkg.t_name     := 'RECV_INST_ID';

    g_default_charset       com_api_type_pkg.t_oracle_name;
    function init_default_charset return com_api_type_pkg.t_oracle_name;

    -- card_type
    PAY_LATER                           constant com_api_type_pkg.t_tiny_id    := 1006;
    PAY_NOW                             constant com_api_type_pkg.t_tiny_id    := 1005;

    CURRENCY_CODE_US_DOLLAR             constant com_api_type_pkg.t_curr_code  := '840';

    RATE_TYPE_BUY                       constant com_api_type_pkg.t_dict_value := 'B';
    RATE_TYPE_SELL                      constant com_api_type_pkg.t_dict_value := 'S';
    RATE_TYPE_MID                       constant com_api_type_pkg.t_dict_value := 'M';

    RATE_VALIDITY_PERIOD                constant com_api_type_pkg.t_name       := 'RATE_VALIDITY_PERIOD';
    DEFAULT_RATE_VALIDITY_PERIOD        constant com_api_type_pkg.t_tiny_id    := 1;

    MSG_STATUS_INVALID                  constant com_api_type_pkg.t_dict_value := 'CLMS0080';

    MCC_CASH                            constant com_api_type_pkg.t_mcc        := '6010';
    MCC_ATM                             constant com_api_type_pkg.t_mcc        := '6011';

    PROC_CODE_PURCHASE                  constant jcb_api_type_pkg.t_de003s     := '00';
    PROC_CODE_ATM                       constant jcb_api_type_pkg.t_de003s     := '01';
    PROC_CODE_CASH                      constant jcb_api_type_pkg.t_de003s     := '12';
    PROC_CODE_SENDER_DEBIT              constant jcb_api_type_pkg.t_de003s     := '19';
    PROC_CODE_REFUND                    constant jcb_api_type_pkg.t_de003s     := '20';
    PROC_CODE_SENDER_CREDIT             constant jcb_api_type_pkg.t_de003s     := '29';

    PROC_CODE_UNIQUE                    constant jcb_api_type_pkg.t_de003s     := '18';

    UPLOAD_FORWARDING                   constant com_api_type_pkg.t_dict_value := 'UPIN0010';
    UPLOAD_ORIGINATOR                   constant com_api_type_pkg.t_dict_value := 'UPIN0020';

    JCB_RATE_TYPE                       constant com_api_type_pkg.t_dict_value := 'RTTPJCBR';

    MERCHANT_COMMISS_RATE               constant com_api_type_pkg.t_name       := 'MERCHANT_COMMISS_RATE';
    MERCHANT_DEFAULT_FEE_TYPE           constant com_api_type_pkg.t_name       := 'FETP0200';

    -- List of EMV tags that should be retrieved from auth EMV data and save to field DE55,
    -- every tag is associated with data type (empty data type is treated as HEX),
    -- for numeric tags is also defined lenghts of their hexadecimal representation
    EMV_TAGS_LIST_FOR_DE055             constant emv_api_type_pkg.t_emv_tag_type_tab :=
        emv_api_type_pkg.t_emv_tag_type_tab(
            com_name_pair_tpr('9F26', '')
          , com_name_pair_tpr('9F27', '')
          , com_name_pair_tpr('9F10', '')
          , com_name_pair_tpr('9F37', '')
          , com_name_pair_tpr('9F36', '')
          , com_name_pair_tpr('95',   '')
          , com_name_pair_tpr('9A',   'DTTPNMBR6')
          , com_name_pair_tpr('9C',   'DTTPNMBR2')
          , com_name_pair_tpr('9F02', 'DTTPNMBR12')
          , com_name_pair_tpr('5F2A', 'DTTPNMBR4')
          , com_name_pair_tpr('82',   '')
          , com_name_pair_tpr('9F1A', 'DTTPNMBR4')
          , com_name_pair_tpr('9F03', 'DTTPNMBR12')
          , com_name_pair_tpr('9F34', '')
          , com_name_pair_tpr('9F35', 'DTTPNMBR2')
          , com_name_pair_tpr('9F09', '')
          , com_name_pair_tpr('9F33', '')
          , com_name_pair_tpr('9F1E', 'DTTPCHAR')
          , com_name_pair_tpr('4F',   '') --new tag
          , com_name_pair_tpr('9F41', 'DTTPNMBR8')
          --, com_name_pair_tpr('9F53', 'DTTPCHAR') in JCB not exists
          , com_name_pair_tpr('84',   '')
        );

end;
/
