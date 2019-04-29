create or replace package bgn_api_const_pkg as

    MODULE_CODE_BORICA                      constant    com_api_type_pkg.t_module_code  := 'BGN';

    BORICA_INST_ID                          constant    com_api_type_pkg.t_inst_id      := 9005;
    BORICA_NETWORK_ID                       constant    com_api_type_pkg.t_network_id   := 1006;
    BORICA_OWN_CODE                         constant    com_api_type_pkg.t_name         := '999';
    
    FILE_TYPE_BORICA_QO                     constant    com_api_type_pkg.t_dict_value   := 'FLTPCLBQ';
    FILE_TYPE_BORICA_FO                     constant    com_api_type_pkg.t_dict_value   := 'FLTPCLBF';
    FILE_TYPE_BORICA_EO                     constant    com_api_type_pkg.t_dict_value   := 'FLTPCLBE';
    FILE_TYPE_BORICA_SO                     constant    com_api_type_pkg.t_dict_value   := 'FLTPCLBS';
    FILE_TYPE_BORICA_NO                     constant    com_api_type_pkg.t_dict_value   := 'FLTPCLBN';
    FILE_TYPE_BORICA_NI                     constant    com_api_type_pkg.t_dict_value   := 'FLTPCLBI';
    FILE_TYPE_BORICA_BIN_TABLE              constant    com_api_type_pkg.t_dict_value   := 'FLTPBGBN';
    
    BGN_CLEARING_STANDARD                   constant    com_api_type_pkg.t_tiny_id      := 1025;
    
    BGN_DEFAULT_CURRENCY                    constant    com_api_type_pkg.t_curr_code    := '975';
    BGN_DEFAULT_COUNTRY                     constant    com_api_type_pkg.t_curr_code    := '100';
    
    CMN_PARAMETER_BANK_CODE                 constant    com_api_type_pkg.t_name         := 'BGN_BANK_CODE';
    CMN_PARAMETER_ACQ_BIN                   constant    com_api_type_pkg.t_name         := 'ACQ_BIN';
    
    BGN_LOCAL_BIN                           constant    com_api_type_pkg.t_bin          := '6760';

end bgn_api_const_pkg;
/
