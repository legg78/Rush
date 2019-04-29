create or replace package itf_api_fraud_mon_version_pkg is
/**********************************************************
 * Versions of interface between SVBO and Fraud Monitoring
 *
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 17.11.2016
 *
 * Module: ITF_API_FRAUD_MON_VERSION_PKG
 **********************************************************/
PREFIX_EXPORT_CARDS              constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.EXPORT_CARDS_DATA_';
PREFIX_EXPORT_MERCHANT           constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.EXPORT_MERCHANT_DATA_';
PREFIX_EXPORT_TERMINAL           constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.EXPORT_TERMINAL_DATA_';
PREFIX_EXPORT_CLEARING           constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.EXPORT_CLEARING_DATA_';
PREFIX_EXPORT_RATES              constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.EXPORT_RATES_DATA_';

procedure export_cards_data_10(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
);

procedure export_cards_data_11(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_include_note        in     com_api_type_pkg.t_boolean       default null
);

procedure export_cards_data_12(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_include_note        in     com_api_type_pkg.t_boolean       default null
);

procedure export_cards_data_13(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_include_note        in     com_api_type_pkg.t_boolean       default null
);

procedure export_cards_data_14(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_include_note        in     com_api_type_pkg.t_boolean       default null
);

procedure export_cards_data_15(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_include_note        in     com_api_type_pkg.t_boolean       default null
);

procedure export_merchant_data_10(
    i_inst_id             in     com_api_type_pkg.t_inst_id      
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure export_merchant_data_11(
    i_inst_id             in     com_api_type_pkg.t_inst_id      
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure export_merchant_data_12(
    i_inst_id             in     com_api_type_pkg.t_inst_id      
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
  , i_ver                 in     com_api_type_pkg.t_dict_value   default null
);

procedure export_merchant_data_13(
    i_inst_id             in     com_api_type_pkg.t_inst_id      
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure export_merchant_data_14(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure export_merchant_data_15(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure export_terminal_data_10(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure export_terminal_data_11(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure export_terminal_data_12(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure export_terminal_data_13(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure export_terminal_data_14(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure export_terminal_data_15(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure export_clearing_data_10(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
);

procedure export_clearing_data_11(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
);

procedure export_clearing_data_12(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
);

procedure export_clearing_data_13(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
);

procedure export_clearing_data_14(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
);

procedure export_clearing_data_15(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
);

procedure export_rates_data_10(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
);

procedure export_rates_data_11(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
);

procedure export_rates_data_12(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
);

procedure export_rates_data_13(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
);

procedure export_rates_data_14(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
);

procedure export_rates_data_15(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
);

end itf_api_fraud_mon_version_pkg;
/
