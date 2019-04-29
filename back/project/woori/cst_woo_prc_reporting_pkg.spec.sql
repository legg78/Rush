create or replace package cst_woo_prc_reporting_pkg is

function get_account_balance(
    i_account_id        in      com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_money;

function get_account_number(
    i_account_id        in      com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_account_number;

procedure export_file_51(
    i_inst_id           in      com_api_type_pkg.t_inst_id
);

procedure export_file_53(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_end_date          in      date    default null
);

procedure export_file_53_1(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_end_date          in      date    default null
);

end cst_woo_prc_reporting_pkg;
/
