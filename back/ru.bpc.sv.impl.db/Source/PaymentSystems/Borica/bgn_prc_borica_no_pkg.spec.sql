create or replace package bgn_prc_borica_no_pkg as

procedure process;

procedure process_export(
    i_inst_id       com_api_type_pkg.t_inst_id
);

procedure process_answer;

end bgn_prc_borica_no_pkg;
/
 