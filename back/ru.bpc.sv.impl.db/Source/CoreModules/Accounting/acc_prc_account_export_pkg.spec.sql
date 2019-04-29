create or replace package acc_prc_account_export_pkg is
/*********************************************************
 *  process for accounts export to XML file <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 25.05.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: acc_prc_account_export_pkg  <br />
 *  @headcom
 **********************************************************/

procedure process(
    i_inst_id   in    com_api_type_pkg.t_inst_id
);

procedure process_unload_turnover(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_mode                  in     com_api_type_pkg.t_dict_value
  , i_date_type             in     com_api_type_pkg.t_dict_value
  , i_start_date            in     date                              default null
  , i_end_date              in     date                              default null
  , i_shift_from            in     com_api_type_pkg.t_tiny_id        default 0
  , i_shift_to              in     com_api_type_pkg.t_tiny_id        default 0
  , i_balance_type          in     com_api_type_pkg.t_dict_value     default null
  , i_unload_limits         in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
  , i_array_account_type_id in     com_api_type_pkg.t_medium_id      default null
);

/*
 * This process obsolete. 
 * It is recommended to use the process process_turnover_info.
 */
procedure process_unload_turnover_info(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_mode                  in     com_api_type_pkg.t_dict_value
  , i_date_type             in     com_api_type_pkg.t_dict_value
  , i_start_date            in     date                              default null
  , i_end_date              in     date                              default null
  , i_shift_from            in     com_api_type_pkg.t_tiny_id        default 0
  , i_shift_to              in     com_api_type_pkg.t_tiny_id        default 0
  , i_balance_type          in     com_api_type_pkg.t_dict_value     default null
  , i_account_number        in     com_api_type_pkg.t_account_number default null
  , i_masking_card          in     com_api_type_pkg.t_boolean        default com_api_type_pkg.TRUE
  , i_load_reversals        in     com_api_type_pkg.t_boolean        default com_api_type_pkg.TRUE 
);

function check_inst_id(i_inst_id  in com_api_type_pkg.t_inst_id)
return com_api_type_pkg.t_boolean;

-- WARNING! This process is obsolete and is no longer supported.
-- Instead, you should use acc_prc_account_export_pkg.process_turnover_info,
-- which has more parameters and is updated to unload the full format of clearing.
procedure process_unload_transactions(
    i_inst_id   in  com_api_type_pkg.t_inst_id
);

procedure process_turnover_info(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_full_export                  in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_date_type                    in     com_api_type_pkg.t_dict_value
  , i_start_date                   in     date                              default null
  , i_end_date                     in     date                              default null
  , i_shift_from                   in     com_api_type_pkg.t_tiny_id        default 0
  , i_shift_to                     in     com_api_type_pkg.t_tiny_id        default 0
  , i_balance_type                 in     com_api_type_pkg.t_dict_value     default null
  , i_account_number               in     com_api_type_pkg.t_account_number default null
  , i_masking_card                 in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_load_reversals               in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_array_balance_type_id        in     com_api_type_pkg.t_medium_id      default null
  , i_array_trans_type_id          in     com_api_type_pkg.t_medium_id      default null
  , i_array_settl_type_id          in     com_api_type_pkg.t_medium_id      default null
  , i_use_matched_data             in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_use_custom_method            in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_auth                 in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_Visa_clearing        in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_MasterCard_clearing  in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_document             in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_lang                         in     com_api_type_pkg.t_dict_value     default null 
  , i_count                        in     com_api_type_pkg.t_medium_id      default null
  , i_include_payment_order        in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_note                 in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_additional_amount    in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_canceled_entries     in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
);

function get_limit_id (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id;

function generate_limit_xml(
    i_account_id         in      com_api_type_pkg.t_account_id
)return xmltype;

end acc_prc_account_export_pkg;
/
