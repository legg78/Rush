create or replace package nps_prc_incoming_pkg as

-- Processing of Incoming files
procedure process(
    i_network_id           in     com_api_type_pkg.t_tiny_id
);

end nps_prc_incoming_pkg;
/
