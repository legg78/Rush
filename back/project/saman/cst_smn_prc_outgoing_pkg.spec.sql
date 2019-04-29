create or replace package cst_smn_prc_outgoing_pkg as

procedure proc_acq_fin_to_shetab_exp(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_file_type                 in  com_api_type_pkg.t_dict_value          default cst_smn_api_const_pkg.FILE_TYPE_ACQ_FIN_SHETAB
  , i_full_export               in  com_api_type_pkg.t_boolean             default com_api_type_pkg.FALSE
  , i_calendar                  in  com_api_type_pkg.t_dict_value          default null
  , i_calendar_date             in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_calendar_date_format      in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_oper_currency             in  com_api_type_pkg.t_curr_code           default null
  , i_array_operations_type_id  in  com_api_type_pkg.t_medium_id           default cst_smn_api_const_pkg.ARRAY_OPER_TYPE_911_SHETAB
  , i_array_oper_statuses_id    in  com_api_type_pkg.t_medium_id           default null
  , i_separate_char             in  com_api_type_pkg.t_byte_char
);

procedure proc_iss_fin_to_shetab_exp(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_file_type                 in  com_api_type_pkg.t_dict_value          default cst_smn_api_const_pkg.FILE_TYPE_ISS_FIN_SHETAB
  , i_full_export               in  com_api_type_pkg.t_boolean             default com_api_type_pkg.FALSE
  , i_calendar                  in  com_api_type_pkg.t_dict_value          default null
  , i_calendar_date             in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_calendar_date_format      in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_oper_currency             in  com_api_type_pkg.t_curr_code           default null
  , i_array_operations_type_id  in  com_api_type_pkg.t_medium_id           default cst_smn_api_const_pkg.ARRAY_OPER_TYPE_912_SHETAB
  , i_array_oper_statuses_id    in  com_api_type_pkg.t_medium_id           default null
  , i_separate_char             in  com_api_type_pkg.t_byte_char
);

procedure proc_iss_scs_fin_to_shetab_exp(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_file_type                 in  com_api_type_pkg.t_dict_value          default cst_smn_api_const_pkg.FILE_TYPE_ISS_SCS_FIN_SHETAB
  , i_full_export               in  com_api_type_pkg.t_boolean             default com_api_type_pkg.FALSE
  , i_calendar                  in  com_api_type_pkg.t_dict_value          default null
  , i_calendar_date             in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_calendar_date_format      in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_oper_currency             in  com_api_type_pkg.t_curr_code           default null
  , i_array_operations_type_id  in  com_api_type_pkg.t_medium_id           default cst_smn_api_const_pkg.ARRAY_OPER_TYPE_913_SHETAB
  , i_array_oper_statuses_id    in  com_api_type_pkg.t_medium_id           default null
  , i_separate_char             in  com_api_type_pkg.t_byte_char
);

procedure proc_daily_fin_to_shetab_exp(
    i_inst_id                       in  com_api_type_pkg.t_inst_id
  , i_file_type                     in  com_api_type_pkg.t_dict_value          default cst_smn_api_const_pkg.FILE_TYPE_DAILY_FIN_SHETAB
  , i_full_export                   in  com_api_type_pkg.t_boolean             default com_api_type_pkg.FALSE
  , i_calendar                      in  com_api_type_pkg.t_dict_value          default null
  , i_calendar_date                 in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_calendar_date_format          in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_oper_currency                 in  com_api_type_pkg.t_curr_code           default null
  , i_array_oper_participant_type   in  com_api_type_pkg.t_medium_id           default cst_smn_api_const_pkg.ARRAY_OPER_PRTY_921_SHETAB
  , i_array_operations_type_id      in  com_api_type_pkg.t_medium_id           default cst_smn_api_const_pkg.ARRAY_OPER_TYPE_921_SHETAB
  , i_array_oper_statuses_id        in  com_api_type_pkg.t_medium_id           default null
  , i_separate_char                 in  com_api_type_pkg.t_byte_char           
);

end cst_smn_prc_outgoing_pkg;
/
