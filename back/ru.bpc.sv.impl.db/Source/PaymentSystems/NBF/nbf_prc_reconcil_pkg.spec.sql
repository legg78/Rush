create or replace package nbf_prc_reconcil_pkg as

-- Processing of NBC Fast Incoming Clearing Files
procedure process(
    i_network_id            in com_api_type_pkg.t_network_id
);

end;
/
