create or replace package cup_prc_match_pkg as

procedure process_match(
    i_inst_id       in      com_api_type_pkg.t_inst_id
);

end cup_prc_match_pkg;
/
