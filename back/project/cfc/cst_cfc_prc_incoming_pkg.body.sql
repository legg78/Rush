create or replace package body cst_cfc_prc_incoming_pkg is
/*********************************************************
 *  Processes for data import <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 27.11.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate:                      $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: CST_CFC_PRC_INCOMING_PKG  <br />
 *  @headcom
 **********************************************************/
BULK_LIMIT                  constant integer                     := 1000;
DATE_FORMAT                 constant  com_api_type_pkg.t_name    := cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT;

procedure process_unsuccessfull_trans(
    i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_ntf_scheme_id in     com_api_type_pkg.t_tiny_id
  , i_lang          in     com_api_type_pkg.t_dict_value
) is
    l_processed_count      com_api_type_pkg.t_count := 0;
    l_excepted_count       com_api_type_pkg.t_count := 0;
    l_id                   com_api_type_pkg.t_long_id;
    l_text                 clob;
    l_report_id            com_api_type_pkg.t_short_id;
    l_notif_id             com_api_type_pkg.t_tiny_id;
    l_template_id          com_api_type_pkg.t_short_id;
    l_channel_id           com_api_type_pkg.t_tiny_id;
    l_result               com_api_type_pkg.t_count := 0;
    l_contact_type         com_api_type_pkg.t_dict_value;
    l_card_number          com_api_type_pkg.t_card_number;
    l_account_number       com_api_type_pkg.t_account_number;
    l_customer_number      com_api_type_pkg.t_name;
    l_customer_id          com_api_type_pkg.t_medium_id;
    l_address              com_api_type_pkg.t_full_desc;
    l_event_type           com_api_type_pkg.t_dict_value;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_sysdate              date;
begin
    prc_api_stat_pkg.log_start;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate();
    l_processed_count := 0;
    l_excepted_count := 0;

    begin
        select a.id as notif_id
             , a.report_id
             , e.contact_type
             , e.channel_id
             , e.event_type
          into l_notif_id
             , l_report_id
             , l_contact_type
             , l_channel_id
             , l_event_type
          from ntf_notification_vw a
             , ntf_scheme_event_vw e
         where a. event_type = e.event_type
           and e.scheme_id   = i_ntf_scheme_id
           and a.inst_id     = i_inst_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'NOTIFICATION_NOT_FOUND'
              , i_env_param1 => i_ntf_scheme_id
              , i_env_param2 => i_inst_id
            );
    end;

    select min(b.report_template_id)
         , count(b.id)
      into l_template_id
         , l_result
      from ntf_template b
     where b.notif_id   = l_notif_id
       and b.channel_id = l_channel_id
       and b.lang       = i_lang;

    if l_result = 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'NOTIFICATION_TEMPLATE_NOT_FOUND'
          , i_env_param1 => l_notif_id
          , i_env_param2 => l_channel_id
          , i_env_param3 => i_lang
        );
    end if;

    for rec in (
        select f.id session_file_id
             , f.record_count
             , f.file_xml_contents.getClobVal() clob_data
             , count(1) over() cnt
             , row_number() over(order by f.id)  rn
          from prc_session_file f
         where f.session_id = prc_api_session_pkg.get_session_id
         order by f.id
    ) loop
        if rec.rn = 1 then
            prc_api_stat_pkg.log_estimation(i_estimated_count => rec.cnt);

            trc_log_pkg.debug (i_text => 'estimation record = ' || rec.cnt);
        end if;

        l_excepted_count := 0;
        begin
            savepoint sp_incoming_file;
            trc_log_pkg.debug(
                i_text => 'cst_cfc_prc_incoming_pkg.process_unsuccessfull_trans start, session_file_id=' || rec.session_file_id
            );

            select extractvalue(x.column_value, 'operation/card_number')              card_number
                 , extractvalue(x.column_value, 'operation/account_number')           account_number
                 , extractvalue(x.column_value, 'operation/customer_number')          customer_number
              into l_card_number
                 , l_account_number
                 , l_customer_number
              from table(xmlsequence(xmltype(rec.clob_data))) x;

            if l_card_number is not null then
                l_customer_id := iss_api_card_pkg.get_card(
                                     i_card_number => l_card_number
                                   , i_mask_error  => com_api_const_pkg.FALSE
                                 ).customer_id;
            elsif l_account_number is not null then
                l_customer_id := acc_api_account_pkg.get_account(
                                     i_account_id     => null
                                   , i_account_number => l_account_number
                                   , i_mask_error     => com_api_const_pkg.FALSE
                                 ).customer_id;
            elsif l_customer_number is not null then
                l_customer_id := prd_api_customer_pkg.get_customer_id(
                                     i_customer_number => l_customer_number
                                   , i_mask_error      => com_api_const_pkg.FALSE
                                 );
            else
                com_api_error_pkg.raise_error(
                    i_error      => 'OPR_CUSTOMER_NOT_FOUND'
                );
            end if;

            ntf_api_notification_pkg.get_mobile_number(
                i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_object_id    => l_customer_id
              , i_contact_type => l_contact_type
              , o_address      => l_address
              , o_lang         => l_lang
            );

            l_text := rec.clob_data;
--            dbms_output.put_line(l_text);

            rpt_api_template_pkg.apply_xslt(
                i_report_id   => l_report_id
              , io_xml_source => l_text
            );

            ntf_api_message_pkg.create_message(
                o_id               => l_id
              , i_channel_id       => l_channel_id
              , i_text             => l_text
              , i_lang             => nvl(l_lang, i_lang)
              , i_delivery_address => l_address
              , i_delivery_date    => l_sysdate
              , i_inst_id          => i_inst_id
              , i_event_type       => l_event_type
              , i_eff_date         => l_sysdate
              , i_entity_type      => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_object_id        => l_customer_id
              , i_delivery_time    => l_sysdate
            );

            trc_log_pkg.debug('saved ntf message with id '|| l_id);

            l_processed_count := l_processed_count + 1;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current(
                    i_current_count  => l_processed_count
                  , i_excepted_count => l_excepted_count
                );
            end if;

            prc_api_file_pkg.close_file(
                i_sess_file_id          => rec.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_incoming_file;

                l_excepted_count  := l_excepted_count + 1;
                l_processed_count := l_processed_count + 1;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_processed_count
                  , i_excepted_count => l_excepted_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id => rec.session_file_id
                  , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
        end;
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_processed_count
      , i_excepted_total   => l_excepted_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

end;

procedure process_bucket_raw_data(
    i_raw_data_tab          in com_api_type_pkg.t_raw_tab
  , i_file_name             in com_api_type_pkg.t_name
) is
    l_id_tab                com_api_type_pkg.t_medium_tab; 
    l_num_tab               com_api_type_pkg.t_name_tab;
    l_type_id               com_api_type_pkg.t_boolean_tab;
    l_account_id_tab        com_api_type_pkg.t_medium_tab;
    l_customer_id_tab       com_api_type_pkg.t_medium_tab;
    l_revised_bucket_tab    com_api_type_pkg.t_byte_char_tab;
    l_eff_date_tab          com_api_type_pkg.t_date_tab;
    l_expir_date_tab        com_api_type_pkg.t_date_tab;
    l_valid_period_tab      com_api_type_pkg.t_number_tab;
    l_reason_tab            com_api_type_pkg.t_name_tab;
    l_user_id_tab           com_api_type_pkg.t_name_tab;
begin
    for i in 1..i_raw_data_tab.count loop
        begin
            l_num_tab(i)            := cst_cfc_com_pkg.get_substr(i_raw_data_tab(i), 1);
            l_type_id(i)            := to_number(cst_cfc_com_pkg.get_substr(i_raw_data_tab(i), 2));
            if l_type_id(i) = com_api_const_pkg.TRUE then
                l_account_id_tab(i) := acc_api_account_pkg.get_account_id(i_account_number => l_num_tab(i));
                l_customer_id_tab(i):= null;
            else
                l_customer_id_tab(i):= prd_api_customer_pkg.get_customer_id(i_customer_number => l_num_tab(i));
                l_account_id_tab(i) := null;
            end if;
            l_revised_bucket_tab(i) := cst_cfc_com_pkg.get_substr(i_raw_data_tab(i), 3);
            l_eff_date_tab(i)       := to_date(cst_cfc_com_pkg.get_substr(i_raw_data_tab(i), 4), DATE_FORMAT);
            l_expir_date_tab(i)     := to_date(cst_cfc_com_pkg.get_substr(i_raw_data_tab(i), 5), DATE_FORMAT);
            l_valid_period_tab(i)   := to_number(cst_cfc_com_pkg.get_substr(i_raw_data_tab(i), 6));
            l_reason_tab(i)         := cst_cfc_com_pkg.get_substr(i_raw_data_tab(i), 7);
            l_user_id_tab(i)        := cst_cfc_com_pkg.get_substr(i_raw_data_tab(i), 8);
            
            if l_customer_id_tab(i) is null and (l_account_id_tab(i) is null or l_account_id_tab(i)= 0) then
                trc_log_pkg.error(i_text => 'Record ' || i+1 || ' has incorrect data');
            end if;
        exception
            when others then
                com_api_error_pkg.raise_error(
                    i_error       => 'ERROR_ON_READING_FILE'
                  , i_env_param1  => i
                  , i_env_param2  => i_file_name
                );
        end;
    end loop;

    scr_api_external_pkg.add_buckets(
        io_id_tab               => l_id_tab
      , i_account_id_tab        => l_account_id_tab
      , i_customer_id_tab       => l_customer_id_tab
      , i_revised_bucket_tab    => l_revised_bucket_tab
      , i_eff_date_tab          => l_eff_date_tab
      , i_expir_date_tab        => l_expir_date_tab
      , i_valid_period_tab      => l_valid_period_tab
      , i_reason_tab            => l_reason_tab
      , i_user_id_tab           => l_user_id_tab
    );
end process_bucket_raw_data;

procedure process_incoming_bucket is
    proc_name               constant com_api_type_pkg.t_name := $$plsql_unit || '.PROCESS_INCOMING_BUCKET';
    log_prefix              constant com_api_type_pkg.t_name := lower(proc_name) || ': ';

    l_raw_data_tab          com_api_type_pkg.t_raw_tab;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;
    l_file_name             com_api_type_pkg.t_name     := null;

    cursor cur_bucket(i_session_id  com_api_type_pkg.t_long_id) is
    select raw_data
      from prc_file_raw_data
     where session_file_id = i_session_id
       and record_number > 1
     order by record_number;

begin
    trc_log_pkg.debug(
        i_text => log_prefix || 'Start'
    );

    prc_api_stat_pkg.log_start;

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.session_id = prc_api_session_pkg.get_session_id
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
        l_errors_count := 0;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_process_incoming_bucket;
            trc_log_pkg.debug(
                i_text      => 'Session file_id = ' || p.session_file_id
                            || ', file name = ' || l_file_name
            );
            open cur_bucket(p.session_file_id);
            loop
                fetch cur_bucket bulk collect into l_raw_data_tab
                limit BULK_LIMIT;
                    -- get data and process data
                    process_bucket_raw_data(
                        i_raw_data_tab     => l_raw_data_tab
                      , i_file_name        => l_file_name
                    );

                    l_record_count := l_record_count + l_raw_data_tab.count;

                exit when cur_bucket%notfound;
            end loop;
            close cur_bucket;

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_process_incoming_bucket;
                close cur_bucket;
                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error         => 'SEC_FILE_NOT_FOUND'
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.process_result_success
    );

    trc_log_pkg.debug(
        i_text => log_prefix || 'End'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.process_result_failed
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.true then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.true then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.false then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_incoming_bucket;

end cst_cfc_prc_incoming_pkg;
/
