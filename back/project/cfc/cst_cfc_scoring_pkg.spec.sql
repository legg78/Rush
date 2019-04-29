create or replace package cst_cfc_scoring_pkg as

procedure generate_scoring_data(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_customer_number              in     com_api_type_pkg.t_name
  , i_account_number               in     com_api_type_pkg.t_account_number
  , i_start_date                   in     date                                default null
  , i_end_date                     in     date                                default null
);

procedure export_scoring_data;

end cst_cfc_scoring_pkg;
/
