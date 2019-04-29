create or replace package cst_woo_rcn_processing_pkg is

procedure aggregate_gl_balance(
    i_inst_id       in com_api_type_pkg.t_inst_id
  , i_eff_date      in date
);

procedure reconcile_gl_balance(
    i_start_date    in date
  , i_end_date      in date
);

end cst_woo_rcn_processing_pkg;
/
