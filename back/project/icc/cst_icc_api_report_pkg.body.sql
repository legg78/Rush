create or replace package body cst_icc_api_report_pkg as

procedure cup_audit_trailer_unmatched(
    o_xml                     out  clob
  , i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_lang                     in  com_api_type_pkg.t_dict_value   default null
  , i_audit_trailer_file_id    in  com_api_type_pkg.t_long_id      default null
  , i_start_date               in  date                            default null
  , i_end_date                 in  date                            default null
) is
    LOG_PREFIX  constant    com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.cup_audit_trailer_unmatched: ';
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Run with params inst_id [#1] lang [#2] audit_trailer_file_id [#3] start_date [#4] end_date [#5]'
      , i_env_param1  => i_inst_id
      , i_env_param2  => i_lang
      , i_env_param3  => i_audit_trailer_file_id
      , i_env_param4  => i_start_date
      , i_env_param5  => i_end_date
    );
    
    cup_api_report_pkg.audit_trailer_data_matching(
        o_xml                     => o_xml
      , i_inst_id                 => i_inst_id
      , i_lang                    => i_lang
      , i_audit_trailer_file_id   => i_audit_trailer_file_id
      , i_start_date              => i_start_date
      , i_end_date                => i_end_date
      , i_match_status            => opr_api_const_pkg.OPERATION_MATCH_NOT_MATCHED
    );
    
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Finish success'
    );
    
end cup_audit_trailer_unmatched;

end cst_icc_api_report_pkg;
/
