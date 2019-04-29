create or replace package trc_text_pkg as
/*************************************************************
 * API for text of logging messages <br />
 * Created by Truschelev O.(truschelev@bpcbt.com)  at 03.03.2016
 * Module: TRC_TEXT_PKG
 * @headcom
**************************************************************/

function get_desc(
    i_env_param         in     com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_full_desc;

procedure get_text(
    i_level             in     com_api_type_pkg.t_tiny_id
  , io_text             in out com_api_type_pkg.t_text
  , i_env_param1        in     com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in     com_api_type_pkg.t_name             default null
  , i_env_param3        in     com_api_type_pkg.t_name             default null
  , i_env_param4        in     com_api_type_pkg.t_name             default null
  , i_env_param5        in     com_api_type_pkg.t_name             default null
  , i_env_param6        in     com_api_type_pkg.t_name             default null
  , i_get_text          in     com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , o_label_id             out com_api_type_pkg.t_short_id
  , o_param_text           out com_api_type_pkg.t_text
);

end;
/
