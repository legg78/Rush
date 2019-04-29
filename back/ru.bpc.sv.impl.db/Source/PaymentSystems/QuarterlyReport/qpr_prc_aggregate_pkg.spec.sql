create or replace package qpr_prc_aggregate_pkg is

procedure refresh_aggregate_cards(
    i_start_date              in date
  , i_end_date                in date
);

procedure refresh_detail(
    i_start_date              in date
  , i_end_date                in date
  , i_load_reversals          in com_api_type_pkg.t_boolean  :=  com_api_type_pkg.FALSE
);

procedure refresh_aggregate(
    i_start_date              in date
  , i_end_date                in date
  , i_load_reversals          in com_api_type_pkg.t_boolean  :=  com_api_type_pkg.FALSE
);

end qpr_prc_aggregate_pkg;
/
