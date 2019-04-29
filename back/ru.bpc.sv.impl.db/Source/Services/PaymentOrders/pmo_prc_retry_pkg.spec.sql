create or replace package pmo_prc_retry_pkg is

procedure process(
    i_inst_id                     in      com_api_type_pkg.t_inst_id
);

end;
/
