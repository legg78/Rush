create or replace package cst_mpu_api_const_pkg as

    MODULE_CODE_MPU                constant com_api_type_pkg.t_module_code := 'MPU';
    MPU_BUSINESS_ID                constant com_api_type_pkg.t_name        := 'MPU_BUSINESS_ID';
    
    FILE_TYPE_DMS                  constant com_api_type_pkg.t_module_code := 'C';
    FILE_TYPE_SMS                  constant com_api_type_pkg.t_module_code := 'D';

    TC_PRESENTMENT                 constant com_api_type_pkg.t_mcc         := '100';  -- Settlement

    RECORD_TYPE_HEADER             constant com_api_type_pkg.t_module_code := '000';
    RECORD_TYPE_TRAILER            constant com_api_type_pkg.t_module_code := '001';
    RECORD_TYPE_AUDIT_TRAILER      constant com_api_type_pkg.t_module_code := '500';
    RECORD_TYPE_DISPUTE_TRAILER    constant com_api_type_pkg.t_module_code := '501';
    RECORD_TYPE_SETTLEMENT         constant com_api_type_pkg.t_module_code := '100';
    RECORD_TYPE_SETTL_REFUND       constant com_api_type_pkg.t_module_code := '200';
    RECORD_TYPE_IN_DISPUTE         constant com_api_type_pkg.t_module_code := '199';
    RECORD_TYPE_FUND_STAT          constant com_api_type_pkg.t_module_code := '900';
    RECORD_TYPE_VOL_STAT_IN        constant com_api_type_pkg.t_module_code := '901';
    RECORD_TYPE_VOL_STAT_OUT       constant com_api_type_pkg.t_module_code := '902';
    RECORD_TYPE_MRCH_STTL          constant com_api_type_pkg.t_module_code := '903';

    FILE_TYPE_CLEARING_MPU         constant com_api_type_pkg.t_dict_value   := 'FLTPCMPU';
    FILE_TYPE_STATISTICS_MPU       constant com_api_type_pkg.t_dict_value   := 'FLTPSMPU';

    MSG_TYPE_FIN_REQUEST           constant com_api_type_pkg.t_dict_value   := '0200';
    MSG_TYPE_FIN_REQUEST_RESPONCE  constant com_api_type_pkg.t_dict_value   := '0210';
    MSG_TYPE_FIN_ADVICE            constant com_api_type_pkg.t_dict_value   := '0220';
    MSG_TYPE_FIN_ADVICE_RESP       constant com_api_type_pkg.t_dict_value   := '0230';

    MPU_MSG_STATUS_UPLOADED        constant com_api_type_pkg.t_dict_value   := 'MFMS0010';
    
end cst_mpu_api_const_pkg;
/
