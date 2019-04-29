create or replace package body evt_api_notif_report_pkg is
/**********************************************************
 * Create reports for send event notification
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 05.10.2016
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 * Module: EVT_API_NOTIFICATION_PKG
 * @headcom
 **********************************************************/

/* Obsolete. Do not use */
procedure create_report(
    o_xml               out     clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value  default null
) is
    l_result            xmltype;
    l_xml_entity_data   xmltype;
begin
    trc_log_pkg.debug (
        i_text       => 'Event notification [#1] [#2] [#3] [#4] [#5]: Data generation is started'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

    if i_entity_type = app_api_const_pkg.ENTITY_TYPE_APPLICATION
    then

        evt_api_notif_report_data_pkg.generate_application_data(
            i_appl_id              => i_object_id
          , i_lang                 => i_lang
          , o_appl_report_data     => l_xml_entity_data
        );
        
    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_STTL_DATE
    then
        
        evt_api_notif_report_data_pkg.generate_settlement_data(
            i_sttl_day_id          => i_object_id
          , i_lang                 => i_lang
          , o_sttl_day_report_data => l_xml_entity_data
        );
        
    elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
    then
        
        evt_api_notif_report_data_pkg.generate_card_instance_data(
            i_card_instance_id       => i_object_id
          , i_lang                   => i_lang
          , o_card_inst_report_data  => l_xml_entity_data
        );
        
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
    then
        
        if i_event_type = acc_api_const_pkg.EVENT_MIN_THRESHOLD_OVERCOMING then
            
            evt_api_notif_report_data_pkg.generate_account_complex_data(
                i_account_id          => i_object_id
              , i_lang                => i_lang
              , o_account_complex_xml => l_xml_entity_data
            );
            
        else

            evt_api_notif_report_data_pkg.generate_account_data(
                i_account_id             => i_object_id
              , i_lang                   => i_lang
              ,o_account_report_data     => l_xml_entity_data
            );

        end if;
        
    elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
    then
        
        evt_api_notif_report_data_pkg.generate_card_data(
            i_card_id                => i_object_id
          , i_lang                   => i_lang
          , o_card_report_data       => l_xml_entity_data
        );
        
    elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
    then
        
        evt_api_notif_report_data_pkg.generate_merchant_data(
            i_merchant_id            => i_object_id
          , i_lang                   => i_lang
          , o_merchant_report_data   => l_xml_entity_data
        );
        
    elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
    then
        
        evt_api_notif_report_data_pkg.generate_terminal_data(
            i_terminal_id            => i_object_id
          , i_lang                   => i_lang
          , o_terminal_report_data   => l_xml_entity_data
        );
    
    elsif i_entity_type = prc_api_const_pkg.ENTITY_TYPE_SESSION
    then
        
        evt_api_notif_report_data_pkg.generate_session_data(
            i_session_id             => i_object_id
          , i_lang                   => i_lang
          , o_session_report_data    => l_xml_entity_data
        );
        
    elsif i_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE
    then
        
        evt_api_notif_report_data_pkg.generate_credit_invoice_data(
            i_credit_invoice_id             => i_object_id
          , i_lang                          => i_lang
          , o_credit_invoice_report_data    => l_xml_entity_data
        );
    elsif i_entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
    then
        
        evt_api_notif_report_data_pkg.generate_oper_acc_iss_data(
            i_operation_id                  => i_object_id
          , i_lang                          => i_lang
          , o_operation_acc_iss_data        => l_xml_entity_data
        );        
    elsif i_entity_type = lty_api_const_pkg.ENTITY_TYPE_BONUS
    then

        evt_api_notif_report_data_pkg.generate_bonus_data(
            i_macros_id    => i_object_id
          , i_lang         => i_lang
          , o_report_xml   => l_xml_entity_data
        );
    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_CONTACT_DATA
    then

        evt_api_notif_report_data_pkg.generate_contact_data(
            i_contact_data_id  => i_object_id
          , i_lang             => i_lang
          , o_contact_data_xml => l_xml_entity_data
        );
    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_IDENTIFY_OBJECT
    then

        evt_api_notif_report_data_pkg.generate_identifier_data(
            i_identifier_object_id  => i_object_id
          , i_lang                  => i_lang
          , o_identifier_data_xml   => l_xml_entity_data
        );
    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_ADDRESS
    then

        evt_api_notif_report_data_pkg.generate_address_data(
            i_address_id            => i_object_id
          , i_lang                  => i_lang
          , o_address_data_xml      => l_xml_entity_data
        );
    end if;
    
    if l_xml_entity_data is not null
    then
    
        select xmlelement("report"
                 , xmlelement("event"
                     , xmlelement("event_type_code", i_event_type)
                     , xmlelement("event_type_name", com_api_dictionary_pkg.get_article_text(
                                                         i_article => i_event_type
                                                       , i_lang    => i_lang
                                                     )
                       )
                     , xmlelement("event_date", to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss'))
                     , xmlelement("entity_type_code", i_entity_type)
                     , xmlelement("entity_type_name", com_api_dictionary_pkg.get_article_text(
                                                          i_article => i_entity_type
                                                        , i_lang    => i_lang
                                                      )
                       )
                     , xmlelement("object_id", i_object_id)
                   )
                 , l_xml_entity_data
               )
          into l_result
          from dual;
          
        o_xml := l_result.getclobval();
    
    else
        
        com_api_error_pkg.raise_error(
            i_error         => 'REPORT_DATA_NOT_FOUND'
        );
        
    end if;
    
    trc_log_pkg.debug (
        i_text       => 'Event notification [#1] [#2] [#3] [#4] [#5]: Data generation is finished success'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text       => 'Event notification [#1] [#2] [#3] [#4] [#5]: Data generation is finished failed, error: [#6]'
          , i_env_param1 => i_event_type
          , i_env_param2 => i_lang
          , i_env_param3 => i_inst_id
          , i_env_param4 => i_entity_type
          , i_env_param5 => i_object_id
          , i_env_param6 => SQLERRM
        );
        
        raise;
        
end create_report;

end;
/
