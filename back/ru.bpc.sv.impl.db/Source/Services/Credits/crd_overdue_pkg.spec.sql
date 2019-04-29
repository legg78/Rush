create or replace package crd_overdue_pkg as

procedure check_overdue(
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
);

procedure collect_penalty(
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
);

procedure block_card(
    i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
);

procedure zero_limit(
    i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
);

procedure debt_in_collection(
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
);

procedure check_mad_aging_indebtedness(
    i_account_id        in      com_api_type_pkg.t_account_id
);

procedure reduce_credit_limit(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date                           default null
  , i_shift_fee_date    in      com_api_type_pkg.t_tiny_id     default 0
);

procedure update_debt_aging(
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_aging_period      in      com_api_type_pkg.t_tiny_id
);

end crd_overdue_pkg;
/
