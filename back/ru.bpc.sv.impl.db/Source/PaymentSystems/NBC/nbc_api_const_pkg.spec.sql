create or replace package nbc_api_const_pkg as

    MODULE_CODE_NBC              constant com_api_type_pkg.t_module_code := 'NBC';
    NBC_BANK_CODE                constant com_api_type_pkg.t_name        := 'NBC_BANK_CODE';
    NBC_CLEARING_STANDARD        constant com_api_type_pkg.t_tiny_id     := 1037;    
    NBC_NETWORK                  constant com_api_type_pkg.t_tiny_id     := 1016;
    
    FILE_TYPE_NBC_ISS            constant com_api_type_pkg.t_dict_value  := 'FLTPNISS';
    FILE_TYPE_NBC_ACQ            constant com_api_type_pkg.t_dict_value  := 'FLTPNACQ';
    FILE_TYPE_NBC_BNB            constant com_api_type_pkg.t_dict_value  := 'FLTPNBNB';
    FILE_TYPE_NBC_DSP            constant com_api_type_pkg.t_dict_value  := 'FLTPNDSP';
    FILE_TYPE_NBC_SF             constant com_api_type_pkg.t_dict_value  := 'FLTPNBSF';

    RECORD_TYPE_HEADER           constant com_api_type_pkg.t_mcc         := '0001';
    RECORD_TYPE_TRAILER          constant com_api_type_pkg.t_mcc         := '0003';
    RECORD_TYPE_DETAIL           constant com_api_type_pkg.t_mcc         := '0002';
       
    PARTICIPANT_ISSUER           constant com_api_type_pkg.t_dict_value  := 'ISS';
    PARTICIPANT_ACQUIRER         constant com_api_type_pkg.t_dict_value  := 'ACQ';
    PARTICIPANT_BENEFICIARY      constant com_api_type_pkg.t_dict_value  := 'BNB';

    TAG_ISS_FEE_AMOUNT           constant com_api_type_pkg.t_short_id    := 8756;
    TAG_NBC_FEE_AMOUNT           constant com_api_type_pkg.t_short_id    := 8757;
    TAG_BNB_FEE_AMOUNT           constant com_api_type_pkg.t_short_id    := 8758;
    TAG_TO_ACCOUNT_NUMBER        constant com_api_type_pkg.t_short_id    := 8709;
    TAG_ACCOUNT_1_TYPE           constant com_api_type_pkg.t_short_id    := 35855;
    TAG_ACCOUNT_2_TYPE           constant com_api_type_pkg.t_short_id    := 35856;
    TAG_LOCAL_TRANS_DATE_TIME    constant com_api_type_pkg.t_short_id    := 8716;
    TAG_RECEIVING_INST_CODE      constant com_api_type_pkg.t_short_id    := 35857;
    TAG_PROC_CODE                constant com_api_type_pkg.t_short_id    := 35858;
    
    PARAM_IBFT_TRANSFER_OPTP     constant com_api_type_pkg.t_name        := 'IBFT_TRANSFER_OPTP';
    PARAM_IBFT_ATM_OPTP          constant com_api_type_pkg.t_name        := 'IBFT_ATM_OPTP';
    PARAM_IBFT_ATM_PAYMENT_OPTP  constant com_api_type_pkg.t_name        := 'IBFT_ATM_PAYMENT_OPTP';
    PARAM_IBFT_P2P_OPTP          constant com_api_type_pkg.t_name        := 'IBFT_P2P_OPTP';
    PARAM_IBFT_PARTY_TYPE_ALGO   constant com_api_type_pkg.t_name        := 'IBFT_PARTY_TYPE_ALGO';

end;
/
