create or replace package fcl_prc_fee_cycle_pkg as

procedure process(
    i_inst_id       in      com_api_type_pkg.t_inst_id
);

end;
/