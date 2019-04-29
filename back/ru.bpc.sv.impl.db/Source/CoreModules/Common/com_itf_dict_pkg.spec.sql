create or replace package com_itf_dict_pkg is

function execute_dict_query(
    i_dict_version         in            com_api_type_pkg.t_name
  , i_array_dictionary_id  in            com_api_type_pkg.t_medium_id     default null
  , i_inst_id              in            com_api_type_pkg.t_inst_id       default null
  , i_entry_point          in            com_api_type_pkg.t_attr_name     default com_api_const_pkg.ENTRYPOINT_EXPORT
  , i_lang                 in            com_api_type_pkg.t_dict_value    default null
  , io_xml                 in out nocopy clob
) return com_api_type_pkg.t_short_id;

function execute_rate_query(
    i_count_query_only          in            com_api_type_pkg.t_boolean
  , i_get_rate_id_tab           in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_dict_version              in            com_api_type_pkg.t_name           default com_api_const_pkg.VERSION_DEFAULT
  , i_inst_id                   in            com_api_type_pkg.t_inst_id        default null
  , i_eff_date                  in            date                              default null
  , i_full_export               in            com_api_type_pkg.t_boolean        default null
  , i_base_rate_export          in            com_api_type_pkg.t_boolean        default null
  , i_rate_type                 in            com_api_type_pkg.t_dict_value     default null
  , i_replace_inst_id_by_number in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_entry_point               in            com_api_type_pkg.t_attr_name      default com_api_const_pkg.ENTRYPOINT_EXPORT
  , io_xml                      in out nocopy clob
  , io_rate_id_tab              in out nocopy num_tab_tpt
  , io_event_tab                in out        com_api_type_pkg.t_number_tab
) return com_api_type_pkg.t_short_id;

function execute_mcc_query(
    i_dict_version         in     com_api_type_pkg.t_name
  , i_lang                 in     com_api_type_pkg.t_dict_value default null
  , i_entry_point          in     com_api_type_pkg.t_attr_name  default com_api_const_pkg.ENTRYPOINT_EXPORT
  , o_xml                     out clob
) return com_api_type_pkg.t_short_id;

end com_itf_dict_pkg;
/
