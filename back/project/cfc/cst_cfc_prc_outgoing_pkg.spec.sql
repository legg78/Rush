create or replace package cst_cfc_prc_outgoing_pkg is
/*********************************************************
 *  Processes for data export <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 22.11.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate:                      $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: CST_CFC_PRC_OUTGOING_PKG  <br />
 *  @headcom
 **********************************************************/

procedure process_unload_gl_acc_numbers(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure process_unload_acc_gl_data(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_full_export                  in     com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_date_type                    in     com_api_type_pkg.t_dict_value
  , i_start_date                   in     date                                default null
  , i_end_date                     in     date                                default null
  , i_account_number               in     com_api_type_pkg.t_account_number   default null
  , i_array_link_account_numbers   in     com_api_type_pkg.t_medium_id        default null
  , i_separate_char                in     com_api_type_pkg.t_byte_char
);

procedure process_unload_scoring_data(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_agent_id                     in     com_api_type_pkg.t_agent_id
  , i_customer_number              in     com_api_type_pkg.t_name
  , i_account_number               in     com_api_type_pkg.t_account_number
  , i_start_date                   in     date                                default null
  , i_end_date                     in     date                                default null
);

procedure process_unload_coa_data(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
);

procedure process_unload_appl_respond(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_start_date                   in     date                                default null
  , i_end_date                     in     date                                default null
);

procedure process_payment_inquiry_batch(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_array_account_status_id      in     com_api_type_pkg.t_short_id
);

procedure process_direct_debit_data(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_purpose_id                   in     com_api_type_pkg.t_short_id
);

end cst_cfc_prc_outgoing_pkg;
/
