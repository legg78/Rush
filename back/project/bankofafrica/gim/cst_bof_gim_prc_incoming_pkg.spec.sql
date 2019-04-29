create or replace package cst_bof_gim_prc_incoming_pkg as

-- Processing of Incoming clearing files
procedure process(
    i_network_id           in     com_api_type_pkg.t_tiny_id
  , i_create_operation     in     com_api_type_pkg.t_boolean
);

end;
/
