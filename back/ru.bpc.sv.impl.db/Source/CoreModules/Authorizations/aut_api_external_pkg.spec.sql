create or replace package aut_api_external_pkg is

procedure get_auth_tag_values(
    i_oper_id           in     com_api_type_pkg.t_long_id
  , i_tag_reference     in     com_api_type_pkg.t_name       default null
  , i_seq_number        in     com_api_type_pkg.t_tiny_id    default null
  , o_ref_cursor           out com_api_type_pkg.t_ref_cur
);

end;
/
