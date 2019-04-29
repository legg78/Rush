create or replace package com_api_label_pkg as
/*
 * API for labels <br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 27.11.2009
 * Module: COM_API_LABEL_PKG
 * @headcom
 */

procedure register_label(
    i_name              in      com_api_type_pkg.t_short_desc
  , i_label_type        in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_module_code       in      com_api_type_pkg.t_module_code
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
  , i_env_var1          in      com_api_type_pkg.t_name             default null
  , i_env_var2          in      com_api_type_pkg.t_name             default null
  , i_env_var3          in      com_api_type_pkg.t_name             default null
  , i_env_var4          in      com_api_type_pkg.t_name             default null
  , i_env_var5          in      com_api_type_pkg.t_name             default null
  , i_env_var6          in      com_api_type_pkg.t_name             default null
);

function get_label_text(
    i_name              in      com_api_type_pkg.t_short_desc
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_text_field_name   in      com_api_type_pkg.t_name             default null
) return com_api_type_pkg.t_short_desc;

end;
/
