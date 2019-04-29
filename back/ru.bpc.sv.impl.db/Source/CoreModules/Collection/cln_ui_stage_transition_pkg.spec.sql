create or replace package cln_ui_stage_transition_pkg is

procedure add(
    o_id                     out com_api_type_pkg.t_short_id
  , o_seqnum                 out com_api_type_pkg.t_tiny_id
  , i_stage_id            in     com_api_type_pkg.t_short_id
  , i_transition_stage_id in     com_api_type_pkg.t_short_id
  , i_reason_code         in     com_api_type_pkg.t_dict_value
);

procedure modify(
    i_id                  in     com_api_type_pkg.t_short_id
  , io_seqnum             in out com_api_type_pkg.t_tiny_id
  , i_stage_id            in     com_api_type_pkg.t_short_id
  , i_transition_stage_id in     com_api_type_pkg.t_short_id
  , i_reason_code         in     com_api_type_pkg.t_dict_value
);

procedure remove(
    i_id                  in     com_api_type_pkg.t_short_id
  , i_seqnum              in     com_api_type_pkg.t_tiny_id
);

function get_transition_count(
    i_case_id   in     com_api_type_pkg.t_long_id
  , i_status    in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_count;

end cln_ui_stage_transition_pkg;
/
