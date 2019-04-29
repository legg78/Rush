create or replace package trc_log_pkg is
/*************************************************************
 * API for logging <br />
 * Created by Filimonov E.(filimonov@bpc.ru)  at 08.07.2009
 * Module: TRC_LOG_PKG
 * @headcom
**************************************************************/

function get_desc(
    i_env_param         in      com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_full_desc;

procedure set_object(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
);

procedure clear_object;

function who_called_me(
    i_level in com_api_type_pkg.t_tiny_id default trc_config_pkg.DEFAULT_LEVEL
) return           com_api_type_pkg.t_name;

function get_error_stack return com_api_type_pkg.t_text;

function get_text(
    i_label_id          in      com_api_type_pkg.t_short_id
  , i_trace_text        in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text;

function get_details return com_api_type_pkg.t_text;

function get_details(
    i_label_id          in      com_api_type_pkg.t_short_id
  , i_trace_text        in      com_api_type_pkg.t_text
) return com_api_type_pkg.t_text;

/*************************************************************
*  Trace log on level debug
*  @param i_text
*  @param i_env_param1
*  @param i_env_param2
*  @param i_env_param3
*  @param i_env_param4
*  @param i_env_param5
*  @param i_env_param6
*  @param i_entity_type
*  @param i_object_id
*  @param i_event_id
*  @param i_inst_id
***************************************************************/
procedure debug(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
);

procedure info(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
);

procedure warn(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , o_id                   out  com_api_type_pkg.t_long_id
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
  , o_param_text           out  com_api_type_pkg.t_text
);

procedure warn(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , o_id                   out  com_api_type_pkg.t_long_id
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
);

procedure warn(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
);

procedure warn(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
);

procedure error(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , o_id                   out  com_api_type_pkg.t_long_id
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
  , o_param_text           out  com_api_type_pkg.t_text
);

procedure error(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , o_id                   out  com_api_type_pkg.t_long_id
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
);

procedure error(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
);

procedure error(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
);

procedure fatal(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
  , o_param_text           out  com_api_type_pkg.t_text
);

procedure fatal(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
);

procedure fatal(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
);

procedure wipe_by_level(
    i_level             in      com_api_type_pkg.t_tiny_id          default trc_config_pkg.DEBUG
);

procedure reset_trace_count;

end trc_log_pkg;
/
