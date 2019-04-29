create or replace package jcb_prc_outgoing_pkg is

procedure process (
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id     := null
  , i_start_date            in date default null
  , i_end_date              in date default null
  , i_with_rdw              in com_api_type_pkg.t_boolean     := null
  , i_include_affiliate     in com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
);

end;
/
