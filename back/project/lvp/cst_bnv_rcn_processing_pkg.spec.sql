create or replace package cst_bnv_rcn_processing_pkg is

procedure process_disputes(
    i_start_date    in date
  , i_end_date      in date
);

procedure process_transactions(
    i_start_date    in date
  , i_end_date      in date
  , i_network_id    in com_api_type_pkg.t_network_id
);

end cst_bnv_rcn_processing_pkg;
/

