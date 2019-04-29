create or replace package cst_amk_epw_prc_reconcil_pkg is

-- Processing of Incoming reconciliation files
procedure process(
    i_network_id           in     com_api_type_pkg.t_tiny_id
);

end ;
/
