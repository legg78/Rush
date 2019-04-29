create or replace package rul_api_mod_pkg is

function check_condition (
    i_mod_id                in com_api_type_pkg.t_tiny_id
    , i_params              in com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_boolean;

function select_condition (
    i_mods                  in com_api_type_pkg.t_number_tab
    , i_params              in com_api_type_pkg.t_param_tab
    , i_mask_error          in com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
    , i_error_value         in binary_integer                   default null
) return binary_integer;

function select_value (
    i_mods                  in com_api_type_pkg.t_number_tab
    , i_values              in com_api_type_pkg.t_varchar2_tab
    , i_params              in com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_param_value;

function get_mod_id (
    i_scale_type            in com_api_type_pkg.t_dict_value
    , i_params              in com_api_type_pkg.t_param_tab
    , i_inst_id             in com_api_type_pkg.t_inst_id := ost_api_const_pkg.DEFAULT_INST
) return com_api_type_pkg.t_tiny_id;
    
procedure select_mods(
    i_scale_type        in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_params            in      com_api_type_pkg.t_param_tab
  , o_mods                 out  num_tab_tpt
);

procedure add_mod (
    o_id                        out com_api_type_pkg.t_tiny_id
  , o_seqnum                    out com_api_type_pkg.t_seqnum
  , i_scale_id               in     com_api_type_pkg.t_tiny_id
  , i_condition              in     com_api_type_pkg.t_text
  , i_priority               in     com_api_type_pkg.t_tiny_id
  , i_lang                   in     com_api_type_pkg.t_dict_value
  , i_name                   in     com_api_type_pkg.t_name
  , i_description            in     com_api_type_pkg.t_full_desc
);

procedure check_mod (
    i_mod_id       in     com_api_type_pkg.t_tiny_id
  , i_scale_id     in     com_api_type_pkg.t_tiny_id
  , i_priority     in     com_api_type_pkg.t_tiny_id
  , i_name         in     com_api_type_pkg.t_name
  , i_description  in     com_api_type_pkg.t_full_desc
);

procedure check_process_uses_modifier;

end;
/
