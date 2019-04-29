create or replace package body ntf_api_report_pkg is
/***********************************************************
* API for notification reports. <br>
* Created by Kryukov E. (krukov@bpcbt.com)  at 25.02.2013  <br>
* Last changed by $Author$ <br>
* $LastChangedDate::                           $  <br>
* Revision: $LastChangedRevision$ <br>
* Module: NTF_API_REPORT_PKG <br>
* @headcom
*************************************************************/

    procedure ntf_report (
        o_xml                  out  clob
        , i_event_type         in com_api_type_pkg.t_dict_value
        , i_eff_date           in date
        , i_entity_type        in com_api_type_pkg.t_dict_value
        , i_object_id          in com_api_type_pkg.t_long_id
        , i_inst_id            in com_api_type_pkg.t_inst_id
        , i_notify_party_type  in com_api_type_pkg.t_dict_value
        , i_lang               in com_api_type_pkg.t_dict_value
    ) is
        l_result                xmltype;
        l_lang                  com_api_type_pkg.t_dict_value;
    begin
        trc_log_pkg.debug (
            i_text          => 'Notification report [#1] [#2] [#3] [#4] [#5]'
            , i_env_param1  => i_event_type
            , i_env_param2  => i_lang
            , i_env_param3  => i_inst_id
            , i_env_param4  => i_entity_type
            , i_env_param5  => i_object_id
        );
        
        l_lang := nvl(i_lang, get_user_lang);
        
        if i_event_type in ('EVNT1905', 'EVNT1904', 'EVNT1903', 'EVNT1902', 'EVNT1901', 'EVNT1900') then
            select
                xmlelement("event"
                    , xmlelement("event_type", i_event_type)
                    , xmlelement("eff_date", to_char(i_eff_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                    , xmlelement("host_description", x.description)
                )
            into
                l_result
            from (
                select
                    d.device_id
                    , d.host_member_id
                    , get_text (
                        i_table_name    => 'net_member'
                        , i_column_name => 'description'
                        , i_object_id   => d.host_member_id
                        , i_lang        => l_lang
                    ) description
                from
                    net_device d
                where
                    d.device_id = i_object_id
            ) x;
        
        else
            null;
        end if;
        
        o_xml := l_result.getclobval();
    end;

-- Obsolete. Do not use->
    procedure create_text_message_report(
        o_xml               out     clob
      , i_lang              in      com_api_type_pkg.t_dict_value  default null
    ) is
        l_result            xmltype;
        l_message_text      com_api_type_pkg.t_text;
    begin

        l_message_text := evt_api_shared_data_pkg.get_param_char(i_name => 'I_MESSAGE_TEXT');

        select xmlelement("report", xmlelement("message_text", l_message_text))
          into l_result
          from dual;

        o_xml := l_result.getclobval();

    exception
        when others then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );

    end create_text_message_report;

    procedure create_due_message_report(
        o_xml               out     clob
      , i_lang              in      com_api_type_pkg.t_dict_value  default null
    ) is
        l_result            xmltype;
        l_inst_id           com_api_type_pkg.t_inst_id;
        l_object_id         com_api_type_pkg.t_long_id;
        l_entity_type       com_api_type_pkg.t_name;
        l_account_rec       acc_api_type_pkg.t_account_rec;
        l_due_date          date;
        l_min_amount_due    com_api_type_pkg.t_money;
        l_total_amount_due  com_api_type_pkg.t_money;
        l_last_invoice_id   com_api_type_pkg.t_long_id;

    begin

        l_inst_id                       := evt_api_shared_data_pkg.get_param_num('INST_ID');
        l_entity_type                   := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
        l_object_id                     := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

        if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
        or l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE
        then

            if l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
                l_object_id := crd_invoice_pkg.get_invoice(
                                   i_invoice_id  => l_object_id
                                 , i_mask_error  => com_api_const_pkg.FALSE
                               ).account_id;            
            end if;

            l_account_rec := acc_api_account_pkg.get_account(
                                 i_account_id    => l_object_id
                               , i_inst_id       => l_inst_id
                               , i_mask_error    => com_api_const_pkg.FALSE
                             );

            if l_account_rec.account_type <> acc_api_const_pkg.ACCOUNT_TYPE_CREDIT then

                trc_log_pkg.debug(
                    i_text       => 'Account[#1] is not a [#2] type instance.'
                  , i_env_param1 => l_account_rec.account_id
                  , i_env_param2 => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
                );

                raise com_api_error_pkg.e_stop_execute_rule_set;
            end if;

            l_last_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                                     i_account_id    => l_account_rec.account_id
                                   , i_split_hash    => l_account_rec.split_hash
                                   , i_mask_error    => com_api_const_pkg.FALSE
                                 );

            select due_date
                 , min_amount_due
                 , total_amount_due
              into l_due_date
                 , l_min_amount_due
                 , l_total_amount_due
              from crd_invoice
             where id = l_last_invoice_id;

            select xmlelement(
                       "report"
                     , xmlelement("due_date",         l_due_date)
                     , xmlelement("min_amount_due",   l_min_amount_due)
                     , xmlelement("total_amount_due", l_total_amount_due)
                   )
              into l_result
              from dual;

            o_xml := l_result.getclobval();

        else

            trc_log_pkg.debug(
                i_text       => 'Current entity_type[#1] is not a ACCT instance. Object[#2].'
              , i_env_param1 => l_entity_type
              , i_env_param2 => l_object_id
            );

            raise com_api_error_pkg.e_stop_execute_rule_set;

        end if;

    exception
        when others then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );

    end create_due_message_report;
-- <-Obsolete. Do not use

end;
/
