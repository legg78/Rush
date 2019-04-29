create or replace package jcb_prc_incoming_pkg is

procedure process (
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_create_operation      in com_api_type_pkg.t_boolean     := null
  , i_with_rdw              in com_api_type_pkg.t_boolean     := null
);

end;
/
