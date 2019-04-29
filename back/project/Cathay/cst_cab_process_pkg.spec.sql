create or replace package cst_cab_process_pkg as

function get_customer_name(
    i_customer_id           in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name;

function get_pay_status(
    i_account_id            in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_dict_value;

procedure generate_cbc_report(
    i_inst_id               in      com_api_type_pkg.t_inst_id
);

end cst_cab_process_pkg;
/
