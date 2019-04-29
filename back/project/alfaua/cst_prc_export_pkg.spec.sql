create or replace package cst_prc_export_pkg is
/************************************************************
 * Export operation process (L/W/B file) <br />
 * Created by Sidorik R.(sidorik@bpc.ru)  at 10.11.2017 <br />
 * Last changed by $Author: sidorik $ <br />
 * $LastChangedDate:: 2018-04-06 09:06:14 +0300#$ <br />
 * Revision: $LastChangedRevision: 63505 $ <br />
 * Module: CST_PRC_EXPORT_PKG <br />
 * @headcom
 *************************************************************/

function get_pos_data_code(
    i_card_data_input_cap    in com_api_type_pkg.t_dict_value,
    i_crdh_auth_cap          in com_api_type_pkg.t_dict_value,
    i_card_capture_cap       in com_api_type_pkg.t_dict_value,
    i_terminal_operating_env in com_api_type_pkg.t_dict_value,
    i_crdh_presence          in com_api_type_pkg.t_dict_value,
    i_card_presence          in com_api_type_pkg.t_dict_value,
    i_card_data_input_mode   in com_api_type_pkg.t_dict_value,
    i_crdh_auth_method       in com_api_type_pkg.t_dict_value,
    i_crdh_auth_entity       in com_api_type_pkg.t_dict_value,
    i_card_data_output_cap   in com_api_type_pkg.t_dict_value,
    i_terminal_output_cap    in com_api_type_pkg.t_dict_value,
    i_pin_capture_cap        in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name;

function get_tran_info(
    i_card_presence          in com_api_type_pkg.t_dict_value,
    i_card_data_input_mode   in com_api_type_pkg.t_dict_value,
    i_crdh_auth_method       in com_api_type_pkg.t_dict_value,
    i_card_seq_number        in opr_participant.card_seq_number%type
) return com_api_type_pkg.t_name;

function get_amount(
    i_amount_type            in com_api_type_pkg.t_dict_value,
    i_inst_id                in com_api_type_pkg.t_inst_id,
    i_file_type              in com_api_type_pkg.t_dict_value,
    i_sttl_type              in com_api_type_pkg.t_dict_value,
    i_card_network_id        in com_api_type_pkg.t_network_id,
    i_card_country           in com_api_type_pkg.t_country_code,
    i_oper_currency          in com_api_type_pkg.t_curr_code,
    i_oper_amount            in com_api_type_pkg.t_money,
    i_sttl_currency          in com_api_type_pkg.t_curr_code,
    i_sttl_amount            in com_api_type_pkg.t_money,
    i_bill_currency          in com_api_type_pkg.t_curr_code,
    i_bill_amount            in com_api_type_pkg.t_money,
    i_acct_currency          in com_api_type_pkg.t_curr_code,
    i_acct_amount            in com_api_type_pkg.t_money
) return com_api_type_pkg.t_money;

function get_currency(
    i_amount_type            in com_api_type_pkg.t_dict_value,
    i_inst_id                in com_api_type_pkg.t_inst_id,
    i_file_type              in com_api_type_pkg.t_dict_value,
    i_sttl_type              in com_api_type_pkg.t_dict_value,
    i_card_network_id        in com_api_type_pkg.t_network_id,
    i_card_country           in com_api_type_pkg.t_country_code,
    i_oper_currency          in com_api_type_pkg.t_curr_code,
    i_oper_amount            in com_api_type_pkg.t_money,
    i_sttl_currency          in com_api_type_pkg.t_curr_code,
    i_sttl_amount            in com_api_type_pkg.t_money,
    i_bill_currency          in com_api_type_pkg.t_curr_code,
    i_bill_amount            in com_api_type_pkg.t_money,
    i_acct_currency          in com_api_type_pkg.t_curr_code,
    i_acct_amount            in com_api_type_pkg.t_money
) return com_api_type_pkg.t_curr_code;

procedure upload_operation_l (
    i_inst_id               in     com_api_type_pkg.t_inst_id        default null
  , i_full_export           in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
  , i_start_date            in     date                              default null
  , i_end_date              in     date                              default null
  , i_card_network_id       in     com_api_type_pkg.t_network_id     default null
);

procedure upload_operation_w (
    i_inst_id               in     com_api_type_pkg.t_inst_id        default null
  , i_full_export           in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
  , i_start_date            in     date                              default null
  , i_end_date              in     date                              default null
  , i_card_network_id       in     com_api_type_pkg.t_network_id     default null
);

procedure upload_operation_b (
    i_inst_id               in     com_api_type_pkg.t_inst_id        default null
  , i_full_export           in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
  , i_start_date            in     date                              default null
  , i_end_date              in     date                              default null
  , i_card_network_id       in     com_api_type_pkg.t_network_id     default null
);

end;
/
