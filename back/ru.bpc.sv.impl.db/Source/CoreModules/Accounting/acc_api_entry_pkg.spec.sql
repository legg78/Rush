create or replace package acc_api_entry_pkg is
/*********************************************************
 *  API for entries <br /> 
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 19.03.2010 <br />
 *  Module: acc_api_entry_pkg <br /> 
 *  @headcom 
 **********************************************************/
procedure flush_job;

procedure cancel_job;

procedure post_entries (
    i_entry_id                      in com_api_type_pkg.t_number_tab
    , i_macros_id                   in com_api_type_pkg.t_number_tab
    , i_bunch_id                    in com_api_type_pkg.t_number_tab
    , i_transaction_id              in com_api_type_pkg.t_number_tab
    , i_transaction_type            in com_api_type_pkg.t_name_tab
    , i_account_id                  in com_api_type_pkg.t_number_tab
    , i_amount                      in com_api_type_pkg.t_number_tab
    , i_currency                    in com_api_type_pkg.t_name_tab
    , i_account_type                in com_api_type_pkg.t_name_tab
    , i_balance_type                in com_api_type_pkg.t_name_tab
    , i_balance_impact              in com_api_type_pkg.t_number_tab
    , i_original_account_id         in com_api_type_pkg.t_number_tab
    , i_transf_entity               in com_api_type_pkg.t_name_tab
    , i_transf_type                 in com_api_type_pkg.t_name_tab
    , i_macros_type                 in com_api_type_pkg.t_number_tab
    , i_status                      in com_api_type_pkg.t_name_tab
    , i_ref_entry_id                in com_api_type_pkg.t_number_tab
    , o_processed_entries           out com_api_type_pkg.t_integer_tab
    , o_excepted_entries            out com_api_type_pkg.t_integer_tab
    , i_save_exceptions             in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    , i_rounding_method             in com_api_type_pkg.t_dict_tab
);

procedure put_bunch (
    o_bunch_id                  out com_api_type_pkg.t_long_id
    , i_bunch_type_id           in com_api_type_pkg.t_tiny_id
    , i_macros_id               in com_api_type_pkg.t_long_id
    , i_amount_tab              in com_api_type_pkg.t_amount_by_name_tab
    , i_account_tab             in acc_api_type_pkg.t_account_by_name_tab
    , i_date_tab                in com_api_type_pkg.t_date_by_name_tab
    , i_details_data            in com_api_type_pkg.t_full_desc := null
    , i_macros_type_id          in com_api_type_pkg.t_tiny_id := null
    , i_param_tab               in com_api_type_pkg.t_param_tab
);

procedure put_bunch(
    o_bunch_id                    out com_api_type_pkg.t_long_id
  , i_bunch_type_id            in     com_api_type_pkg.t_tiny_id
  , i_macros_id                in     com_api_type_pkg.t_long_id
  , i_amount                   in     com_api_type_pkg.t_money
  , i_currency                 in     com_api_type_pkg.t_curr_code
  , i_account_type             in     com_api_type_pkg.t_dict_value    default null
  , i_account_id               in     com_api_type_pkg.t_account_id
  , i_posting_date             in     date                             default null
  , i_amount_name              in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_AMOUNT_NAME
  , i_account_name             in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_ACCOUNT_NAME
  , i_date_name                in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_DATE_NAME
  , i_details_data             in     com_api_type_pkg.t_full_desc     default null
  , i_macros_type_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_param_tab                in     com_api_type_pkg.t_param_tab
);

procedure put_macros (
    o_macros_id                 out com_api_type_pkg.t_long_id
    , o_bunch_id                out com_api_type_pkg.t_long_id
    , i_entity_type             in com_api_type_pkg.t_dict_value
    , i_object_id               in com_api_type_pkg.t_long_id
    , i_macros_type_id          in com_api_type_pkg.t_tiny_id
    , i_amount_tab              in com_api_type_pkg.t_amount_by_name_tab
    , i_account_tab             in acc_api_type_pkg.t_account_by_name_tab
    , i_date_tab                in com_api_type_pkg.t_date_by_name_tab
    , i_amount_name             in com_api_type_pkg.t_oracle_name := acc_api_const_pkg.DEFAULT_AMOUNT_NAME
    , i_account_name            in com_api_type_pkg.t_oracle_name := acc_api_const_pkg.DEFAULT_ACCOUNT_NAME
    , i_amount_purpose          in com_api_type_pkg.t_dict_value := null
    , i_fee_id                  in com_api_type_pkg.t_short_id := null
    , i_fee_tier_id             in com_api_type_pkg.t_short_id := null
    , i_fee_mod_id              in com_api_type_pkg.t_tiny_id := null
    , i_details_data            in com_api_type_pkg.t_full_desc := null
    , i_param_tab               in com_api_type_pkg.t_param_tab
);

procedure put_macros(
    o_macros_id                   out com_api_type_pkg.t_long_id
  , o_bunch_id                    out com_api_type_pkg.t_long_id
  , i_entity_type              in     com_api_type_pkg.t_dict_value
  , i_object_id                in     com_api_type_pkg.t_long_id
  , i_macros_type_id           in     com_api_type_pkg.t_tiny_id
  , i_amount                   in     com_api_type_pkg.t_money
  , i_currency                 in     com_api_type_pkg.t_curr_code
  , i_account_type             in     com_api_type_pkg.t_dict_value    default null
  , i_account_id               in     com_api_type_pkg.t_account_id
  , i_posting_date             in     date                             default null
  , i_amount_name              in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_AMOUNT_NAME
  , i_account_name             in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_ACCOUNT_NAME
  , i_date_name                in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_DATE_NAME
  , i_amount_purpose           in     com_api_type_pkg.t_dict_value    default null
  , i_fee_id                   in     com_api_type_pkg.t_short_id      default null
  , i_fee_tier_id              in     com_api_type_pkg.t_short_id      default null
  , i_fee_mod_id               in     com_api_type_pkg.t_tiny_id       default null
  , i_details_data             in     com_api_type_pkg.t_full_desc     default null
  , i_conversion_rate          in     com_api_type_pkg.t_rate          default null
  , i_param_tab                in     com_api_type_pkg.t_param_tab
);

procedure process_buffered_entries;

procedure process_pending_entries;
    
procedure process_exception_entries;

procedure cancel_processing (
    i_entity_type               in com_api_type_pkg.t_dict_value
    , i_object_id               in com_api_type_pkg.t_long_id
    , i_macros_status           in com_api_type_pkg.t_dict_value
    , i_macros_type             in com_api_type_pkg.t_tiny_id := null
    , i_entry_status            in com_api_type_pkg.t_dict_value := acc_api_const_pkg.ENTRY_STATUS_CANCELED
);

procedure revert_entries (
    i_transaction_id            in com_api_type_pkg.t_long_id
    , i_bunch_id                in com_api_type_pkg.t_long_id := null
    , i_entry_status            in com_api_type_pkg.t_dict_value := acc_api_const_pkg.ENTRY_STATUS_CANCELED
);

procedure partial_revert_entries (
    i_entity_type               in com_api_type_pkg.t_dict_value
    , i_object_id               in com_api_type_pkg.t_long_id
    , i_macros_status           in com_api_type_pkg.t_dict_value
    , i_macros_type             in com_api_type_pkg.t_tiny_id := null
    , i_entry_status            in com_api_type_pkg.t_dict_value := acc_api_const_pkg.ENTRY_STATUS_CANCELED
    , i_amount                  in com_api_type_pkg.t_amount_rec := null
    , i_final_unhold            in com_api_type_pkg.t_boolean := null
);

function get_hold_amount(
    i_object_id                 in com_api_type_pkg.t_long_id
  , i_entity_type               in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_amount_rec;

function get_unhold_amount(
    i_object_id                 in com_api_type_pkg.t_long_id
  , i_entity_type               in com_api_type_pkg.t_dict_value
) return  com_api_type_pkg.t_amount_rec;

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

end;
/
