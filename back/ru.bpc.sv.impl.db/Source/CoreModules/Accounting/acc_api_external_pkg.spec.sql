create or replace package acc_api_external_pkg as
/**********************************************************
 * API for external ACC <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 31.08.2017 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: ACC_API_EXTERNAL_PKG
 * @headcom
 **********************************************************/

type t_entries_rec is record(
    transaction_id           com_api_type_pkg.t_long_id
  , transaction_type         com_api_type_pkg.t_dict_value
  , posting_date             date
  , deb_entry_id             com_api_type_pkg.t_long_id
  , deb_account_number       com_api_type_pkg.t_account_number
  , deb_account_currency     com_api_type_pkg.t_curr_code
  , deb_agent_number         com_api_type_pkg.t_name
  , deb_amount_value         com_api_type_pkg.t_money
  , deb_amount_currency      com_api_type_pkg.t_curr_code
  , cred_entry_id            com_api_type_pkg.t_long_id
  , cred_account_number      com_api_type_pkg.t_account_number
  , cred_account_currency    com_api_type_pkg.t_curr_code
  , cred_agent_number        com_api_type_pkg.t_name
  , cred_amount_value        com_api_type_pkg.t_money
  , cred_amount_currency     com_api_type_pkg.t_curr_code
  , conversion_rate          com_api_type_pkg.t_rate
  , rate_type                com_api_type_pkg.t_dict_value
  , amount_purpose           com_api_type_pkg.t_dict_value
);

type t_entries_tab is table of t_entries_rec index by binary_integer;

procedure get_transactions_data(
    i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_date_type                in  com_api_type_pkg.t_dict_value
  , i_start_date               in  date                                default null
  , i_end_date                 in  date                                default null
  , i_balance_type             in  com_api_type_pkg.t_dict_value       default null
  , i_account_number           in  com_api_type_pkg.t_account_number   default null
  , i_fees                     in  com_api_type_pkg.t_boolean          default null
  , i_gl_accounts              in  com_api_type_pkg.t_boolean          default null
  , i_load_reversals           in  com_api_type_pkg.t_boolean          default null
  , i_object_tab               in  com_api_type_pkg.t_object_tab
  , i_array_balance_type_id    in  com_api_type_pkg.t_medium_id        default null
  , i_array_trans_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_array_settl_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_array_operations_type_id in  com_api_type_pkg.t_medium_id        default null
  , i_mask_error               in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_row_count               out  com_api_type_pkg.t_long_id
  , o_ref_cursor              out  com_api_type_pkg.t_ref_cur
);

procedure get_active_accounts_for_period(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_date_type             in     com_api_type_pkg.t_dict_value
  , i_start_date            in     date
  , i_end_date              in     date
  , i_account_id            in     com_api_type_pkg.t_account_id       default null
  , io_account_id_tab       in out num_tab_tpt
  , i_mask_error            in     com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_ref_cursor               out com_api_type_pkg.t_ref_cur
);

procedure get_link_account_balances(
    i_date_type                    in  com_api_type_pkg.t_dict_value
  , i_start_date                   in  date
  , i_end_date                     in  date
  , i_account_id                   in  com_api_type_pkg.t_account_id
  , i_gl_accounts                  in  com_api_type_pkg.t_boolean          default null
  , i_array_link_account_numbers   in  com_api_type_pkg.t_medium_id        default null
  , i_mask_error                   in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_ref_cursor                  out  com_api_type_pkg.t_ref_cur
);

procedure close_ref_cursor(
    i_ref_cursor         in    com_api_type_pkg.t_ref_cur
);

procedure get_gl_account_numbers_data(
    i_inst_id    in     com_api_type_pkg.t_inst_id
  , i_start_date in     date                        default null
  , i_end_date   in     date default null
  , o_row_count     out com_api_type_pkg.t_long_id
  , o_gl_acc_tab    out acc_api_type_pkg.t_gl_account_numbers_ext_tab
);

procedure create_account(
    o_id                     out com_api_type_pkg.t_account_id
  , io_split_hash         in out com_api_type_pkg.t_tiny_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , io_account_number     in out com_api_type_pkg.t_account_number
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id
  , i_status              in     com_api_type_pkg.t_dict_value
  , i_contract_id         in     com_api_type_pkg.t_medium_id
  , i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_customer_number     in     com_api_type_pkg.t_name
);

procedure add_account_object(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_usage_order         in     com_api_type_pkg.t_tiny_id             default null
  , i_is_pos_default      in     com_api_type_pkg.t_boolean             default null
  , i_is_atm_default      in     com_api_type_pkg.t_boolean             default null
  , i_is_atm_currency     in     com_api_type_pkg.t_boolean             default null
  , i_is_pos_currency     in     com_api_type_pkg.t_boolean             default null
  , i_account_seq_number  in     acc_api_type_pkg.t_account_seq_number  default null
  , o_account_object_id      out com_api_type_pkg.t_long_id
);

procedure set_is_settled(
    i_entry_id             in    com_api_type_pkg.t_long_id
  , i_is_settled           in    com_api_type_pkg.t_boolean     := com_api_const_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id
  , i_sttl_flag_date       in    date                           := null
  , i_split_hash           in    com_api_type_pkg.t_tiny_id
);

procedure set_is_settled(
    i_entry_id_tab         in    com_api_type_pkg.t_long_tab
  , i_is_settled           in    com_api_type_pkg.t_boolean     := com_api_const_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id_tab
  , i_sttl_flag_date       in    date                           := null
  , i_split_hash           in    com_api_type_pkg.t_tiny_tab
);

procedure set_is_settled(
    i_operation_id_tab     in    num_tab_tpt
  , i_is_settled           in    com_api_type_pkg.t_boolean     := com_api_const_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id_tab
  , i_sttl_flag_date       in    date                           := null
  , i_split_hash           in    com_api_type_pkg.t_tiny_tab
);

procedure get_opr_entries(
    i_oper_id                  in    com_api_type_pkg.t_long_id
  , i_array_balance_type_id    in    com_api_type_pkg.t_medium_id        default null
  , i_array_trans_type_id      in    com_api_type_pkg.t_medium_id        default null
  , i_array_settl_type_id      in    com_api_type_pkg.t_medium_id        default null
  , i_array_operations_type_id in    com_api_type_pkg.t_medium_id        default null
  , o_ref_cursor               out   com_api_type_pkg.t_ref_cur
);

end acc_api_external_pkg;
/
