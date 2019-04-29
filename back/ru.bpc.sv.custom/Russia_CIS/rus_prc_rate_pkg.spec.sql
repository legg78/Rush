create or replace package rus_prc_rate_pkg is

procedure load_rates(
    i_inst_id           in    com_api_type_pkg.t_inst_id
    , i_eff_date        in    date
);

end;
/
