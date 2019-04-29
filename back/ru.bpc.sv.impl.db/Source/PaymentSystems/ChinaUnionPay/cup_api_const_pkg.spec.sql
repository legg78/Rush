create or replace package cup_api_const_pkg as

    MODULE_CODE_CUP                constant com_api_type_pkg.t_module_code := 'CUP';

    CUP_ACQUIRER_NAME              constant com_api_type_pkg.t_name        := 'CUP_ACQUIRER_NAME';
    FILE_TYPE_CLEARING_CUP         constant com_api_type_pkg.t_dict_value  := 'FLTPCLCU';
    UPI_INST_ID                    constant com_api_type_pkg.t_inst_id     := 9011;
    UPI_NETWORK_ID                 constant com_api_type_pkg.t_inst_id     := 1010;

    STANDARD_VERSION_ID_19Q2       constant com_api_type_pkg.t_tiny_id     := 1104;

    TC_PRESENTMENT                 constant com_api_type_pkg.t_mcc         := '100';  -- Settlement
    TC_ONLINE_REFUND               constant com_api_type_pkg.t_mcc         := '101';  -- Refund (Online), MOTO Refund
    TC_CASH_WITHDRAWAL             constant com_api_type_pkg.t_mcc         := '102';  -- Cash withdrawal throught bank counter; Manual cash withdrawal / POS cash withdrawal
    TC_OFFLINE_PURCHASE            constant com_api_type_pkg.t_mcc         := '300';  -- Offline purchase of IC Card E-cash application
    TC_OFFLINE_REFUND              constant com_api_type_pkg.t_mcc         := '300';  -- Offline refund of IC Card E-cash application
    TC_DISPUTE                     constant com_api_type_pkg.t_mcc         := '700';  -- Dispute
    
    FT_INTERCHANGE                 constant com_api_type_pkg.t_mcc         := '10';   -- Interchange Fee
    FT_COLLECTION                  constant com_api_type_pkg.t_mcc         := '20';   -- Fee Collection
    FT_DISBURSEMENT                constant com_api_type_pkg.t_mcc         := '30';   -- Funds Disbursement

    TRANS_TYPE_ONLINE              constant com_api_type_pkg.t_sign        := 0;      -- Online Transaction
    TRANS_TYPE_BATCH_FILE          constant com_api_type_pkg.t_sign        := 1;      -- Batch File Transaction
    TRANS_TYPE_DISPUTE_MANUAL      constant com_api_type_pkg.t_sign        := 2;      -- Dispute and manual Transaction

    CODE_FEE_COLLECTION            constant com_api_type_pkg.t_dict_value  := 'UFCR';
end;
/
