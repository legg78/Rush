create or replace package crd_prc_reserve_pkg as

procedure process(
    i_inst_id        in      com_api_type_pkg.t_inst_id
);

end;
/
