create or replace package cst_smt_api_const_pkg is
/*********************************************************
 *  CST constatnt for smt procject
 **********************************************************/
    APP_FLOW_ID_1001                constant com_api_type_pkg.t_tiny_id         := 1001;
    APP_FLOW_ID_5                   constant com_api_type_pkg.t_tiny_id         := 5;
    APP_FLOW_ID_1012                constant com_api_type_pkg.t_tiny_id         := 1012;
    APP_FLOW_ID_1013                constant com_api_type_pkg.t_tiny_id         := 1013;
    ID_IDENTITY_CARD_TYPE           constant com_api_type_pkg.t_dict_value      := 'IDTP0001';
    ADDRESS_TYPE_HOME               constant com_api_type_pkg.t_dict_value      := 'ADTPHOME';

    INTERNATIONAL_ISS_EVENT         constant com_api_type_pkg.t_dict_value      := 'EVNT5201';
    INTERNATIONAL_ACQ_EVENT         constant com_api_type_pkg.t_dict_value      := 'EVNT5202';

    DOMESTIC_ISS_EVENT              constant com_api_type_pkg.t_dict_value      := 'EVNT5203';
    DOMESTIC_ACQ_EVENT              constant com_api_type_pkg.t_dict_value      := 'EVNT5204';
    MNO_OPERATION_EVENT             constant com_api_type_pkg.t_dict_value      := 'EVNT5205';
    MNO_OPER_UPLOADED_EVENT         constant com_api_type_pkg.t_dict_value      := 'EVNT5206';
    MNO_OPER_AGREED_EVENT           constant com_api_type_pkg.t_dict_value      := 'EVNT5207';

    INTERCHBAGE_FEE_AMOUNT          constant com_api_type_pkg.t_dict_value      := 'AMPR5001';
    TAX_AMOUNT                      constant com_api_type_pkg.t_dict_value      := 'AMPR5002';
    COMMISSION_WITHOUT_TAX_AMOUNT   constant com_api_type_pkg.t_dict_value      := 'AMPR5003';
    TAX_ON_INTERCHBAGE_FEE_AMOUNT   constant com_api_type_pkg.t_dict_value      := 'AMPR5004';
    MERCHANT_FEE_AMOUNT             constant com_api_type_pkg.t_dict_value      := 'AMPR5005';
    TAX_ON_MERCHANT_FEE_AMOUNT      constant com_api_type_pkg.t_dict_value      := 'AMPR5006';

    MERCHANT_ACTICITY_SECTOR        constant com_api_type_pkg.t_name            := 'CST_MERCHANT_ACTIVITY_SECTOR';
    BANK_CTB                        constant com_api_type_pkg.t_name            := 'CST_CTB';
    MERCHANT_RIB                    constant com_api_type_pkg.t_name            := 'CST_MERCHANT_RIB';
    CARD_RIB                        constant com_api_type_pkg.t_name            := 'CST_CARD_RIB';
    FLX_ADDIT_INST_NAME_PTDF        constant com_api_type_pkg.t_name            := 'CST_ADDITIONAL_NAME_PTDF';

    TAG_BATCH_NUMBER                constant com_api_type_pkg.t_name            := 'DF8E09';
    TAG_ARN                         constant com_api_type_pkg.t_name            := 'CST_ARN';
    TAG_INVOCE                      constant com_api_type_pkg.t_name            := 'DF8E0A';
    TAG_BATCH_ID                    constant com_api_type_pkg.t_name            := 'CST_BATCH_ID';
    TAG_DEVICE_SEQ_NUMBER           constant com_api_type_pkg.t_name            := 'CST_DEVICE_SEQ_NUMBER';

    FILE_TYPE_CB_DOMESTIC_CLEARING  constant com_api_type_pkg.t_dict_value      := 'FLTPDCCB';
    FILE_TYPE_CB_SETTLEMENT         constant com_api_type_pkg.t_dict_value      := 'FLTPSTCB';
    FILE_TYPE_CB_INTERNATIONAL_CL   constant com_api_type_pkg.t_dict_value      := 'FLTPICCB';

    INSTITUTE_GL_ACCOUNT            constant com_api_type_pkg.t_dict_value      := 'ACTPGLIN';
    INSTITUTE_PROCESSING_TYPE       constant com_api_type_pkg.t_dict_value      := 'INTPPRCN';

    COUNTRY_CODE_TUNISIA            constant com_api_type_pkg.t_country_code    := '778';

    CARD_TYPE_ARRAY_TYPE            constant com_api_type_pkg.t_tiny_id         := -5027;
    CARD_TYPE_CONVERTER             constant com_api_type_pkg.t_short_id        := -5012;
    DEFAULT_CARD_TYPE               constant com_api_type_pkg.t_one_char        := '1';

    NETWORK_ARRAY_TYPE              constant com_api_type_pkg.t_tiny_id         := -5014;
    NETWORK_CONVERTER               constant com_api_type_pkg.t_short_id        := -5013;
    DEFAULT_NETWORK                 constant com_api_type_pkg.t_one_char        := 'L';

    LOCAL_INSTITUTION               constant com_api_type_pkg.t_inst_id         := 1001;

    BQNTRNX_RECORD_LOADED_STATUS    constant com_api_type_pkg.t_dict_value      := 'BQST0000';
    BQNTRNX_RECORD_READY_STATUS     constant com_api_type_pkg.t_dict_value      := 'BQST0001';
    BQNTRNX_RECORD_PROCESSED_ST     constant com_api_type_pkg.t_dict_value      := 'BQST0002';
    BQNTRNX_RECORD_ERROR_STATUS     constant com_api_type_pkg.t_dict_value      := 'BQST0003';

    BQNTRNX_RECORD_DEBIT_CODE       constant com_api_type_pkg.t_one_char        := 'D';
    BQNTRNX_RECORD_CREDIT_CODE      constant com_api_type_pkg.t_one_char        := 'C';

    BQNTRNX_RECORD_POS_SOURCE       constant com_api_type_pkg.t_one_char        := 'T';
    BQNTRNX_RECORD_ATM1_SOURCE      constant com_api_type_pkg.t_one_char        := 'G';
    BQNTRNX_RECORD_ATM2_SOURCE      constant com_api_type_pkg.t_one_char        := 'D';
    BQNTRNX_RECORD_MANUAL1_SOURCE   constant com_api_type_pkg.t_one_char        := '0';
    BQNTRNX_RECORD_MANUAL2_SOURCE   constant com_api_type_pkg.t_one_char        := 'M';
    BQNTRNX_RECORD_INTERNET_SOURCE  constant com_api_type_pkg.t_one_char        := 'I';
    BQNTRNX_RECORD_RECHARGE_SOURCE  constant com_api_type_pkg.t_one_char        := 'R';

    BQNTRNX_RECORD_DNRS_INST        constant cst_smt_api_type_pkg.t_inst_name   := 'DNRS';
    BQNTRNX_RECORD_AMEX_INST        constant cst_smt_api_type_pkg.t_inst_name   := 'AEGN';
    BQNTRNX_RECORD_MAESTRO_INST     constant cst_smt_api_type_pkg.t_inst_name   := 'MDS';
    BQNTRNX_RECORD_VISA_INST        constant cst_smt_api_type_pkg.t_inst_name   := 'VISA';
    BQNTRNX_RECORD_VISASMS_INST     constant cst_smt_api_type_pkg.t_inst_name   := 'SMS';
    BQNTRNX_RECORD_MC_INST          constant cst_smt_api_type_pkg.t_inst_name   := 'BNET';

    AMEX_NETWORK                    constant com_api_type_pkg.t_network_id      := 1004;
    VISA_NETWORK                    constant com_api_type_pkg.t_network_id      := 1003;
    MC_NETWORK                      constant com_api_type_pkg.t_network_id      := 1002;
    AMEX_NETWORK_INST               constant com_api_type_pkg.t_network_id      := 9003;
    VISA_NETWORK_INST               constant com_api_type_pkg.t_network_id      := 9002;
    MC_NETWORK_INST                 constant com_api_type_pkg.t_network_id      := 9001;

    MSSTRXN_DATE                    constant com_api_type_pkg.t_date_short      := 'yymmdd';
    MSSTRXN_TIME_TRANSFORM          constant com_api_type_pkg.t_date_short      := 'hh24miss';

    OPER_TYPE_ARRAY_TYPE            constant com_api_type_pkg.t_tiny_id         := -5029;
    TLF_OPER_TYPE_ARRAY             constant com_api_type_pkg.t_medium_id       := -50000068;
    PTLF_OPER_TYPE_ARRAY            constant com_api_type_pkg.t_medium_id       := -50000067;

    IS_HOSTED                       constant com_api_type_pkg.t_name            := 'CST_IS_HOSTED';
    IS_SWITCHED                     constant com_api_type_pkg.t_name            := 'CST_IS_SWITCHED';

    INVALID_CARD_STATUS_ARRAY       constant com_api_type_pkg.t_short_id        := -50000069;
    INST_ABBREVIATION               constant com_api_type_pkg.t_name            := 'CST_INST_ABBREVIATION';
    LOCAL_NETWORK                   constant com_api_type_pkg.t_network_id      := 1001;
    MASTERCARD_NETWORK_NAME         constant com_api_type_pkg.t_name            := 'MASTERCARD PRODUCT';
    VISA_NETWORK_NAME               constant com_api_type_pkg.t_name            := 'VISA PRODUCT';

end;
/
