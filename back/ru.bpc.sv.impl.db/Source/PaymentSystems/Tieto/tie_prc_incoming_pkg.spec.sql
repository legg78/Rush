create or replace package tie_prc_incoming_pkg is

-- Purpose : KONTS Incoming clearing file processing
  
procedure process(
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_host_inst_id          in com_api_type_pkg.t_inst_id
  , i_dst_inst_id           in com_api_type_pkg.t_inst_id
);

end tie_prc_incoming_pkg;
/
