create or replace package agr_prc_calulation_pkg is


procedure process(
    i_inst_id      in com_api_type_pkg.t_inst_id
    , i_aggr_type  in com_api_type_pkg.t_long_id default null
    , i_aggr_value in com_api_type_pkg.t_long_id default null
    , i_network_id in com_api_type_pkg.t_inst_id
);

end;
/
 