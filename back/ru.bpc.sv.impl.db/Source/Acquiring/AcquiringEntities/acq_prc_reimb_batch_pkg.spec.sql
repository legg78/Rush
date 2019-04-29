create or replace package acq_prc_reimb_batch_pkg as

procedure process(
    i_inst_id       in      com_api_type_pkg.t_inst_id
);

end;
/
