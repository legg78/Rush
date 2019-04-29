create or replace package opr_prc_export_pkg is
/************************************************************
 * Export operation process <br />
 * Created by Kopachev D.(kopachev@bpc.ru)  at 18.10.2013 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-08-26 12:45:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 27843 $ <br />
 * Module: OPR_PRC_EXPORT_PKG <br />
 * @headcom
 *************************************************************/

function check_inst_id(i_inst_id  in com_api_type_pkg.t_inst_id)
return com_api_type_pkg.t_boolean;

procedure upload_operation(
    i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
  , i_start_date                in     date                             default null
  , i_end_date                  in     date                             default null
  , i_upl_oper_event_type       in     com_api_type_pkg.t_dict_value    default null
  , i_terminal_type             in     com_api_type_pkg.t_dict_value    default null
  , i_full_export               in     com_api_type_pkg.t_boolean       default null
  , i_load_successfull          in     com_api_type_pkg.t_dict_value    default null
  , i_include_auth              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_include_clearing          in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_masking_card              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_process_container         in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_session_id                in     com_api_type_pkg.t_long_id       default null
  , i_split_files               in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_reversal_upload_type      in     com_api_type_pkg.t_dict_value    default null
  , i_array_operations_type_id  in     com_api_type_pkg.t_medium_id     default null
  , i_count                     in     com_api_type_pkg.t_medium_id     default null
  , i_array_account_type_cbs    in     com_api_type_pkg.t_medium_id     default null
  , i_array_trans_type_id       in     com_api_type_pkg.t_medium_id     default null
  , i_array_balance_type_id     in     com_api_type_pkg.t_medium_id     default null
  , i_include_additional_amount in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_include_canceled_entries  in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

end opr_prc_export_pkg;
/
