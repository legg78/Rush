create or replace package cst_pfp_process_pkg as

function format_amount (
    i_amount                in     com_api_type_pkg.t_money
  , i_curr_code             in     com_api_type_pkg.t_curr_code
  , i_mask_error            in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name;

function get_tran_code_gl(
    i_card_id               in     com_api_type_pkg.t_long_id
  , i_account_id            in     com_api_type_pkg.t_long_id
  , i_oper_reason           in     com_api_type_pkg.t_dict_value
  , i_mask_error            in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name;

procedure export_gl_data(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_start_date            in     date
  , i_end_date              in     date
  , i_full_export           in     com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
);

end cst_pfp_process_pkg;
/
