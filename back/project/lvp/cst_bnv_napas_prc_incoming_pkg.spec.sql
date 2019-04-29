create or replace package cst_bnv_napas_prc_incoming_pkg as

-- Processing of Incoming files
procedure process(
    i_network_id           in     com_api_type_pkg.t_tiny_id
);

end;
/
