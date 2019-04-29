create or replace package trc_api_const_pkg as

TRACE_LEVEL_FATAL           constant        com_api_type_pkg.t_dict_value := 'FATAL';
TRACE_LEVEL_ERROR           constant        com_api_type_pkg.t_dict_value := 'ERROR';
TRACE_LEVEL_WARNING         constant        com_api_type_pkg.t_dict_value := 'WARNING';
TRACE_LEVEL_INFO            constant        com_api_type_pkg.t_dict_value := 'INFO';
TRACE_LEVEL_DEBUG           constant        com_api_type_pkg.t_dict_value := 'DEBUG';

DEFAULT_ORACLE_TRACE_LABEL  constant        com_api_type_pkg.t_tiny_id    := 0;

end;
/
