create or replace package trc_table_pkg as
/*********************************************************
 *  API for trc_log table <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 02.07.2009 <br />
 *  Module: TRC_TABLE_PKG <br />
 *  @headcom
 **********************************************************/

procedure log(
    i_trace_conf        in      trc_config_pkg.trace_conf
  , i_timestamp         in      timestamp
  , i_level             in      com_api_type_pkg.t_dict_value
  , i_section           in      com_api_type_pkg.t_full_desc
  , i_user              in      com_api_type_pkg.t_oracle_name
  , i_text              in      com_api_type_pkg.t_text
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_label_id          in      com_api_type_pkg.t_short_id         default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_session_id        in      com_api_type_pkg.t_long_id          default null
  , i_thread_number     in      com_api_type_pkg.t_tiny_id          default null
  , i_who_called        in      com_api_type_pkg.t_name
  , i_trace_count       in      com_api_type_pkg.t_long_id          default null
  , i_level_code        in      com_api_type_pkg.t_tiny_id          default null
  , i_text_mode         in      com_api_type_pkg.t_boolean          default null
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
);

end;
/
