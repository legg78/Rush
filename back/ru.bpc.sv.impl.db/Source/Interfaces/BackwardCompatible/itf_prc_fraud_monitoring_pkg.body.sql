create or replace package body itf_prc_fraud_monitoring_pkg is
/**********************************************************
 * Interface between SVBO and Fraud Monitoring
 *
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 17.11.2016
 *
 * Module: ITF_PRC_FRAUD_MONITORING_PKG
 **********************************************************/
 
CRLF                             constant com_api_type_pkg.t_name := chr(13) || chr(10);
VERSION_1_1                      constant com_api_type_pkg.t_attr_name := '1.1';


procedure unloading_cards_data(
    i_version             in     com_api_type_pkg.t_attr_name     default DEFAULT_VERSION
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
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
  
) is
    DEFAULT_PROCEDURE_NAME     constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.UNLOADING_CARDS_DATA';
    PRC_PROCEDURE_PREFIX       constant com_api_type_pkg.t_name := itf_api_fraud_mon_version_pkg.PREFIX_EXPORT_CARDS;
    
    l_subscriber_name          com_api_type_pkg.t_name       := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    
    l_version                  com_api_type_pkg.t_attr_name  := regexp_replace(i_version,'[^[[:digit:]]]*');

begin
    
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is started'
      , i_env_param1  => DEFAULT_PROCEDURE_NAME
    );
    
    execute immediate 'begin' || CRLF
                   || '    ' || PRC_PROCEDURE_PREFIX || l_version || '(' || CRLF
                   || '        i_full_export         => :p1'      || CRLF
                   || '      , i_event_type          => :p2'      || CRLF
                   || '      , i_include_address     => :p3'      || CRLF
                   || '      , i_include_limits      => :p4'      || CRLF
                   || '      , i_export_clear_pan    => :p5'      || CRLF
                   || '      , i_inst_id             => :p6'      || CRLF
                   || '      , i_count               => :p7'      || CRLF
                   || '      , i_include_notif       => :p8'      || CRLF
                   || '      , i_subscriber_name     => :p9'      || CRLF
                   || '      , i_include_contact     => :p10'     || CRLF
                   || '      , i_lang                => :p11'     || CRLF
                   || '      , i_ids_type            => :p12'     || CRLF
                   || '      , i_exclude_npz_cards   => :p13'     || CRLF
                   || '      , i_include_service     => :p14'     || CRLF
                   || case 
                          when i_version = VERSION_1_1
                              then 
                      '      , i_include_note        => ' || nvl(i_include_note, com_api_type_pkg.FALSE) || CRLF
                          else null
                      end
                   || '    );' || CRLF
                   || 'end;'
                using in i_full_export
                    , in i_event_type
                    , in i_include_address
                    , in i_include_limits
                    , in i_export_clear_pan
                    , in i_inst_id
                    , in i_count
                    , in i_include_notif
                    , in l_subscriber_name
                    , in i_include_contact
                    , in i_lang
                    , in i_ids_type
                    , in i_exclude_npz_cards
                    , in i_include_service;
    
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is finished success'
      , i_env_param1  => DEFAULT_PROCEDURE_NAME
    );
    
exception
    when others then
        trc_log_pkg.debug(
            i_text        => 'Process [#1] is finished with errors: [#2]'
          , i_env_param1  => DEFAULT_PROCEDURE_NAME
          , i_env_param2  => sqlcode
        );
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
         
        raise;
        
end unloading_cards_data;

procedure unloading_merchant_data(
    i_version             in     com_api_type_pkg.t_attr_name    default DEFAULT_VERSION
  , i_inst_id             in     com_api_type_pkg.t_inst_id      
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is
    DEFAULT_PROCEDURE_NAME     constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.UNLOADING_MERCHANT_DATA';
    PRC_PROCEDURE_PREFIX       constant com_api_type_pkg.t_name := itf_api_fraud_mon_version_pkg.PREFIX_EXPORT_MERCHANT;
    
    l_subscriber_name          com_api_type_pkg.t_name       := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    
    l_version                  com_api_type_pkg.t_attr_name  := regexp_replace(i_version,'[^[[:digit:]]]*');

begin
    
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is started'
      , i_env_param1  => DEFAULT_PROCEDURE_NAME
    );
   
    execute immediate 'begin' || CRLF
                   || '    ' || PRC_PROCEDURE_PREFIX || l_version || '(' || CRLF
                   || '        i_inst_id             => :p1'      || CRLF
                   || '      , i_agent_id            => :p2'      || CRLF
                   || '      , i_full_export         => :p3'      || CRLF
                   || '      , i_unload_limits       => :p4'      || CRLF
                   || '      , i_unload_accounts     => :p5'      || CRLF
                   || '      , i_include_service     => :p6'      || CRLF
                   || '      , i_count               => :p7'      || CRLF
                   || '      , i_subscriber_name     => :p8'      || CRLF
                   || '      , i_lang                => :p9'      || CRLF
                   || '    );' || CRLF
                   || 'end;'
                using in i_inst_id
                    , in i_agent_id
                    , in i_full_export
                    , in i_unload_limits
                    , in i_unload_accounts
                    , in i_include_service
                    , in i_count
                    , in l_subscriber_name
                    , in i_lang;
    
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is finished success'
      , i_env_param1  => DEFAULT_PROCEDURE_NAME
    );
    
exception
    when others then
        trc_log_pkg.debug(
            i_text        => 'Process [#1] is finished with errors: [#2]'
          , i_env_param1  => DEFAULT_PROCEDURE_NAME
          , i_env_param2  => sqlcode
        );
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
         
        raise;
        
end unloading_merchant_data;

procedure unloading_terminal_data(
    i_version             in     com_api_type_pkg.t_attr_name    default DEFAULT_VERSION
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is
    DEFAULT_PROCEDURE_NAME     constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.UNLOADING_TERMINAL_DATA';
    PRC_PROCEDURE_PREFIX       constant com_api_type_pkg.t_name := itf_api_fraud_mon_version_pkg.PREFIX_EXPORT_TERMINAL;
    
    l_subscriber_name          com_api_type_pkg.t_name       := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    
    l_version                  com_api_type_pkg.t_attr_name  := regexp_replace(i_version,'[^[[:digit:]]]*');

begin
    
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is started'
      , i_env_param1  => DEFAULT_PROCEDURE_NAME
    );

    execute immediate 'begin'  || CRLF
                   || '    '   || PRC_PROCEDURE_PREFIX || l_version || '(' || CRLF
                   || '        i_inst_id             => :p1'      || CRLF
                   || '      , i_agent_id            => :p2'      || CRLF
                   || '      , i_full_export         => :p3'      || CRLF
                   || '      , i_unload_limits       => :p4'      || CRLF
                   || '      , i_include_service     => :p5'      || CRLF
                   || '      , i_count               => :p6'      || CRLF
                   || '      , i_subscriber_name     => :p7'      || CRLF
                   || '      , i_lang                => :p8'      || CRLF
                   || '    );' || CRLF
                   || 'end;'
                using in i_inst_id
                    , in i_agent_id
                    , in i_full_export
                    , in i_unload_limits
                    , in i_include_service
                    , in i_count
                    , in l_subscriber_name
                    , in i_lang;
    
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is finished success'
      , i_env_param1  => DEFAULT_PROCEDURE_NAME
    );
    
exception
    when others then
        trc_log_pkg.debug(
            i_text        => 'Process [#1] is finished with errors: [#2]'
          , i_env_param1  => DEFAULT_PROCEDURE_NAME
          , i_env_param2  => sqlcode
        );
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
         
        raise;
        
end unloading_terminal_data;

procedure unloading_clearing_data(
    i_version                  in     com_api_type_pkg.t_attr_name  default DEFAULT_VERSION
  , i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
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
) is
    DEFAULT_PROCEDURE_NAME     constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.UNLOADING_CLEARING_DATA';
    PRC_PROCEDURE_PREFIX       constant com_api_type_pkg.t_name := itf_api_fraud_mon_version_pkg.PREFIX_EXPORT_CLEARING;
    
    l_subscriber_name          com_api_type_pkg.t_name       := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    
    l_version                  com_api_type_pkg.t_attr_name  := regexp_replace(i_version,'[^[[:digit:]]]*');

begin
    
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is started'
      , i_env_param1  => DEFAULT_PROCEDURE_NAME
    );
    
    execute immediate 'begin' || CRLF
                   || '    '  || PRC_PROCEDURE_PREFIX || l_version || '(' || CRLF
                   || '        i_inst_id                => :p1'      || CRLF
                   || '      , i_start_date             => :p2'      || CRLF
                   || '      , i_end_date               => :p3'      || CRLF
                   || '      , i_upl_oper_event_type    => :p4'      || CRLF
                   || '      , i_terminal_type          => :p5'      || CRLF
                   || '      , i_load_state             => :p6'      || CRLF
                   || '      , i_load_successfull       => :p7'      || CRLF
                   || '      , i_include_auth           => :p8'      || CRLF
                   || '      , i_include_clearing       => :p9'      || CRLF
                   || '      , i_masking_card           => :p10'     || CRLF
                   || '      , i_process_container      => :p11'     || CRLF
                   || '      , i_session_id             => :p12'     || CRLF
                   || '      , i_split_files            => :p13'     || CRLF
                   || '      , i_reversal_upload_type   => :p14'     || CRLF
                   || '      , i_subscriber_name        => :p15'     || CRLF
                   || '    );' || CRLF
                   || 'end;'
                using in i_inst_id
                    , in i_start_date
                    , in i_end_date
                    , in i_upl_oper_event_type
                    , in i_terminal_type
                    , in i_load_state
                    , in i_load_successfull
                    , in i_include_auth
                    , in i_include_clearing
                    , in i_masking_card
                    , in i_process_container
                    , in i_session_id
                    , in i_split_files
                    , in i_reversal_upload_type
                    , in l_subscriber_name;
    
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is finished success'
      , i_env_param1  => DEFAULT_PROCEDURE_NAME
    );
    
exception
    when others then
        trc_log_pkg.debug(
            i_text        => 'Process [#1] is finished with errors: [#2]'
          , i_env_param1  => DEFAULT_PROCEDURE_NAME
          , i_env_param2  => sqlcode
        );
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
         
        raise;
        
end unloading_clearing_data;

procedure unloading_currency_rate_data(
    i_version             in    com_api_type_pkg.t_attr_name     default DEFAULT_VERSION
  , i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
) is
    DEFAULT_PROCEDURE_NAME     constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.UNLOADING_CURRENCY_RATE_DATA';
    PRC_PROCEDURE_PREFIX       constant com_api_type_pkg.t_name := itf_api_fraud_mon_version_pkg.PREFIX_EXPORT_RATES;
    
    l_subscriber_name          com_api_type_pkg.t_name       := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    
    l_version                  com_api_type_pkg.t_attr_name  := regexp_replace(i_version,'[^[[:digit:]]]*');

begin
    
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is started'
      , i_env_param1  => DEFAULT_PROCEDURE_NAME
    );
    
    execute immediate 'begin'  || CRLF
                   || '    '   || PRC_PROCEDURE_PREFIX || l_version || '(' || CRLF
                   || '        i_inst_id             => :p1'      || CRLF
                   || '      , i_eff_date            => :p2'      || CRLF
                   || '      , i_full_export         => :p3'      || CRLF
                   || '      , i_base_rate_export    => :p4'      || CRLF
                   || '      , i_rate_type           => :p5'      || CRLF
                   || '      , i_subscriber_name     => :p6'      || CRLF
                   || '    );' || CRLF
                   || 'end;'
                using in i_inst_id
                    , in i_eff_date
                    , in i_full_export
                    , in i_base_rate_export
                    , in i_rate_type
                    , in l_subscriber_name;
    
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is finished success'
      , i_env_param1  => DEFAULT_PROCEDURE_NAME
    );
    
exception
    when others then
        trc_log_pkg.debug(
            i_text        => 'Process [#1] is finished with errors: [#2]'
          , i_env_param1  => DEFAULT_PROCEDURE_NAME
          , i_env_param2  => sqlcode
        );
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
         
        raise;
        
end unloading_currency_rate_data;

end itf_prc_fraud_monitoring_pkg;
/
