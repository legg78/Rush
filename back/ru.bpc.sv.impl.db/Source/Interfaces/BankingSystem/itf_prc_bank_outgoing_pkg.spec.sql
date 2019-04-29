CREATE OR REPLACE package itf_prc_bank_outgoing_pkg as

procedure process(
    i_inst_id           in      com_api_type_pkg.t_inst_id
);

end;
/
