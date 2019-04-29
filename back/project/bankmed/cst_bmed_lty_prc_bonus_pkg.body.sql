create or replace package body cst_bmed_lty_prc_bonus_pkg as

BULK_LIMIT              constant integer := 400;

procedure export_new_members(
    i_inst_id            in        com_api_type_pkg.t_inst_id
  , i_service_id         in        com_api_type_pkg.t_short_id
) is
    l_card_id               com_api_type_pkg.t_medium_id;
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_customer_number       com_api_type_pkg.t_name;
    l_commun_address        com_api_type_pkg.t_full_desc;
    l_sysdate               date;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_object_id_tab         com_api_type_pkg.t_number_tab;
    l_eff_date_tab          com_api_type_pkg.t_date_tab;
    l_container_id          com_api_type_pkg.t_long_id;

    l_events_processed_tab  com_api_type_pkg.t_number_tab;
    l_events_ignored_tab    com_api_type_pkg.t_number_tab;
    l_events_skipped_tab    com_api_type_pkg.t_number_tab;
    l_excepted_count        com_api_type_pkg.t_count := 0;

    l_line                  com_api_type_pkg.t_raw_data;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_raw_data_tab          com_api_type_pkg.t_raw_tab;
    l_rec_num_tab           com_api_type_pkg.t_integer_tab;
    l_rec_num               com_api_type_pkg.t_long_id := 0;

    l_product_id            com_api_type_pkg.t_short_id;
    l_service_id            com_api_type_pkg.t_short_id;
    l_account               acc_api_type_pkg.t_account_rec;

    l_welcome_gift          com_api_type_pkg.t_dict_value;

    procedure flush_file is
    begin
        trc_log_pkg.debug('cst_bmed_lty_prc_bonus_pkg.flush_file, raw_tab.count='||l_raw_data_tab.count);
        prc_api_file_pkg.put_bulk(
            i_sess_file_id  => l_session_file_id
          , i_raw_tab       => l_raw_data_tab
          , i_num_tab       => l_rec_num_tab
        );
        l_raw_data_tab.delete;
        l_rec_num_tab.delete;
    end;

    procedure put_line(
        i_line                  in com_api_type_pkg.t_raw_data
    ) is
    begin
        l_rec_num := l_rec_num + 1;
        l_raw_data_tab(l_rec_num)  := i_line;
        l_rec_num_tab(l_rec_num)   := l_rec_num;
        trc_log_pkg.info('cst_bmed_lty_prc_bonus_pkg.export_bonus_file: line ' || l_rec_num || '=' || i_line);

        if mod(l_rec_num, BULK_LIMIT) = 0 then
            flush_file;
        end if;
    end;

    function check_card_has_event(
        i_event_object_id    in     com_api_type_pkg.t_long_id
      , i_card_id            in     com_api_type_pkg.t_long_id
      , i_eff_date           in     date
    ) return com_api_type_pkg.t_boolean as
        l_count                     com_api_type_pkg.t_short_id;
    begin
        select count(*)
          into l_count
          from evt_event_object o
             , iss_card_instance ci
         where o.status in (evt_api_const_pkg.EVENT_STATUS_READY, evt_api_const_pkg.EVENT_STATUS_PROCESSED) 
           and o.procedure_name = 'CST_BMED_LTY_PRC_BONUS_PKG.EXPORT_NEW_MEMBERS'
           and o.eff_date      <= i_eff_date
           and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
           and ci.card_id       = i_card_id
           and o.object_id      = ci.id
           and o.id            != i_event_object_id
           and rownum           < 3;
        if l_count > 0 then
            return com_api_const_pkg.TRUE;
        end if;
        
        return com_api_const_pkg.FALSE;
    end;
begin
    trc_log_pkg.debug('start export_new_members: inst_id=' || i_inst_id || ', service_id=' || i_service_id || ', thread_number=' || get_thread_number );

    prc_api_stat_pkg.log_start;
    
    l_sysdate     := com_api_sttl_day_pkg.get_sysdate;
    savepoint sp_bmed_lty_new_member_export;
    
    select o.id
         , ci.card_id
         , o.eff_date
      bulk collect into 
           l_event_tab
         , l_object_id_tab
         , l_eff_date_tab
      from evt_event_object o
         , evt_event e
         , iss_card_instance ci
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_BMED_LTY_PRC_BONUS_PKG.EXPORT_NEW_MEMBERS'
       and o.eff_date      <= l_sysdate
       and o.inst_id        = i_inst_id
       and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
       and o.object_id      = ci.id
       and ci.inst_id       = o.inst_id
       and ci.split_hash    = o.split_hash
       and e.id             = o.event_id
       and (o.container_id is null or o.container_id = l_container_id);
    
    if l_event_tab.count <> 0 then
        for i in l_event_tab.first .. l_event_tab.last loop
            begin
                select c.id as card_id
                     , cs.id
                     , cs.customer_number
                     , com_api_contact_pkg.get_contact_string(
                           i_contact_id      => o.contact_id
                         , i_commun_method   => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                         , i_start_date      => l_sysdate
                       )
                  into l_card_id
                     , l_customer_id
                     , l_customer_number
                     , l_commun_address
                  from iss_card c
                     , prd_customer cs
                     , com_contact_object o
                 where c.id               = l_object_id_tab(i)
                   and c.cardholder_id    = o.object_id(+)
                   and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                   and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                   and c.customer_id      = cs.id;
            exception when no_data_found then
                trc_log_pkg.debug('customer not found ...' );
                l_excepted_count := l_excepted_count + 1;
                l_customer_id := null;
            end;
            
            l_welcome_gift := com_api_flexible_data_pkg.get_flexible_value (
                                  i_field_name      => 'WELCOME_GIFT'
                                , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                                , i_object_id       => l_card_id
                              );
            if l_welcome_gift is not null then
                if check_card_has_event(
                       i_event_object_id    => l_event_tab(i)
                     , i_card_id            => l_object_id_tab(i)
                     , i_eff_date           => l_eff_date_tab(i)
                   ) = com_api_const_pkg.FALSE then
                    if l_customer_id is not null then
                        lty_api_bonus_pkg.get_lty_account_info(
                            i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
                          , i_object_id    => l_card_id
                          , i_inst_id      => i_inst_id
                          , i_eff_date     => null
                          , i_mask_error   => com_api_const_pkg.TRUE
                          , o_account      => l_account
                          , o_service_id   => l_service_id
                          , o_product_id   => l_product_id
                        );
                        
                        if cst_bmed_lty_api_bonus_pkg.check_customer_has_lty_card(
                               i_customer_id   => l_customer_id
                             , i_service_id    => i_service_id
                             , i_card_id       => l_card_id
                             , i_eff_date      => l_eff_date_tab(i)
                           ) = com_api_const_pkg.FALSE
                           and l_service_id = i_service_id then
                            if l_session_file_id is null then
                                prc_api_stat_pkg.log_estimation(i_estimated_count => l_event_tab.count);
                                         
                                prc_api_file_pkg.open_file(
                                    o_sess_file_id => l_session_file_id
                                );
                                trc_log_pkg.debug('l_session_file_id=' || l_session_file_id);
                            end if;
                                    
                            l_events_processed_tab(l_events_processed_tab.count + 1) := l_event_tab(i);
                                    
                            -- formating line
                            l_line := 
                                substr(regexp_replace(l_commun_address, '[^0-9]'), -8) || ',' ||  -- digits only
                                l_customer_number;
                                    
                            put_line(l_line);
                        elsif l_service_id = i_service_id then
                            l_events_ignored_tab(l_events_ignored_tab.count + 1) := l_event_tab(i);
                        else
                            l_events_skipped_tab(l_events_skipped_tab.count + 1) := l_event_tab(i);
                        end if;
                    end if;
                else
                    l_events_ignored_tab(l_events_ignored_tab.count + 1) := l_event_tab(i);
                end if;
            else
                l_events_skipped_tab(l_events_skipped_tab.count + 1) := l_event_tab(i);
            end if;
            prc_api_stat_pkg.log_current(
                i_current_count  => l_events_processed_tab.count + l_events_ignored_tab.count
              , i_excepted_count => l_excepted_count
            );
        end loop;

        prc_api_stat_pkg.log_estimation(i_estimated_count => l_events_processed_tab.count);
        
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab    => l_events_processed_tab
        );

        evt_api_event_pkg.change_event_object_status(
            i_event_object_id_tab    => l_events_ignored_tab
          , i_event_object_status    => evt_api_const_pkg.EVENT_STATUS_DO_NOT_PROCES
        );
    end if;

    if l_session_file_id is not null then
        flush_file;

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
        l_session_file_id  := null;
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => l_excepted_count
      , i_processed_total => l_events_processed_tab.count + l_events_ignored_tab.count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );

    trc_log_pkg.debug('Process unloading finished ...' );
exception
    when others then
        rollback to sp_bmed_lty_new_member_export;

        prc_api_stat_pkg.log_end(
            i_excepted_total  => l_excepted_count
          , i_processed_total => l_events_processed_tab.count + l_events_ignored_tab.count
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED 
        );        

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
             or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end export_new_members;

procedure export_bonus_spending_file(
    i_inst_id            in        com_api_type_pkg.t_inst_id
  , i_service_id         in        com_api_type_pkg.t_short_id
  , i_dest_curr          in        com_api_type_pkg.t_curr_code
  , i_rate_type          in        com_api_type_pkg.t_dict_value
  , i_transaction_type   in        com_api_type_pkg.t_dict_value
) as
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;

    l_line                  com_api_type_pkg.t_raw_data;

    l_oper_id               com_api_type_pkg.t_long_id;
    l_sysdate               date;
    l_dest_curr             com_api_type_pkg.t_dict_value;
    l_amount                com_api_type_pkg.t_money;
    l_amount_str            com_api_type_pkg.t_name;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_bonus_id_tab          num_tab_tpt;
    
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_raw_data_tab          com_api_type_pkg.t_raw_tab;
    l_rec_num_tab           com_api_type_pkg.t_integer_tab;
    l_rec_num               com_api_type_pkg.t_long_id := 0;
    l_container_id          com_api_type_pkg.t_long_id;

    procedure flush_file is
    begin
        trc_log_pkg.debug('cst_bmed_lty_prc_bonus_pkg.flush_file, raw_tab.count='||l_raw_data_tab.count);
        prc_api_file_pkg.put_bulk(
            i_sess_file_id  => l_session_file_id
          , i_raw_tab       => l_raw_data_tab
          , i_num_tab       => l_rec_num_tab
        );
        l_raw_data_tab.delete;
        l_rec_num_tab.delete;
    end;

    procedure put_line(
        i_line                  in com_api_type_pkg.t_raw_data
    ) is
    begin
        l_rec_num := l_rec_num + 1;
        l_raw_data_tab(l_rec_num)  := i_line;
        l_rec_num_tab(l_rec_num)   := l_rec_num;
        trc_log_pkg.info('cst_bmed_lty_prc_bonus_pkg.export_bonus_file: line ' || l_rec_num || '=' || i_line);

        if mod(l_rec_num, BULK_LIMIT) = 0 then
            flush_file;
        end if;
    end;
begin
    trc_log_pkg.debug('start unloading bonuses: inst_id='||i_inst_id||', service_id='||i_service_id||', thread_number='||get_thread_number );

    prc_api_stat_pkg.log_start;

    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;  
    l_dest_curr     := nvl(i_dest_curr, cst_bmed_csc_const_pkg.CURRENCY_CODE_US_DOLLAR);
    l_container_id  :=  prc_api_session_pkg.get_container_id;
    
    select o.id
         , b.id  
      bulk collect into 
           l_event_tab
         , l_bonus_id_tab  
      from evt_event_object o
         , evt_event e
         , lty_bonus b
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_BMED_LTY_PRC_BONUS_PKG.EXPORT_BONUS_SPENDING_FILE'
       and o.eff_date      <= l_sysdate
       and o.inst_id        = i_inst_id
       and o.entity_type    = lty_api_const_pkg.ENTITY_TYPE_BONUS
       and o.object_id      = b.id
       and e.id             = o.event_id
       and b.status         = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE
       and b.inst_id        = o.inst_id
       and b.service_id     = i_service_id
       and o.split_hash     = b.split_hash
       and (o.container_id is null or o.container_id = l_container_id)
       and ( i_transaction_type is null
          or exists (
                 select 1
                   from acc_entry e 
                  where e.transaction_type = i_transaction_type
                    and e.macros_id = b.id
             )
       );
    
    for rec in (
        select b.product_id
             , b.card_id
             , b.object_id
             , b.entity_type
             , a.agent_id
             , a.customer_id
             , a.account_number
             , a.currency
             , b.service_id
             , b.account_id
             , trunc(l_sysdate)                           as oper_date
             , sum(b.amount)                              as amount
             , sum(nvl(b.spent_amount,0))                 as spent_amount
             , sum(b.amount) - sum(nvl(b.spent_amount,0)) as bonus_amount
             , a.split_hash
             , b.inst_id
             , c.customer_number
             , (
                   select d.commun_address
                     from com_contact_object o
                        , com_contact_data d
                    where o.object_id        = a.customer_id
                      and o.entity_type      = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      and o.contact_type     = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                      and o.contact_id       = d.contact_id(+)
                      and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                      and rownum = 1
               ) as commun_address
             , count(*) over() cnt
          from lty_bonus b
             , acc_account a
             , prd_customer c
         where a.id          = b.account_id
           and a.customer_id = c.id
           and b.id in (select column_value from table(cast(l_bonus_id_tab as num_tab_tpt)))
      group by b.product_id
             , b.card_id
             , b.object_id
             , b.entity_type
             , a.id
             , a.agent_id
             , a.customer_id
             , a.account_number
             , a.currency
             , b.service_id
             , b.account_id
             , trunc(l_sysdate)
             , a.split_hash
             , b.inst_id
             , c.customer_number
    )
    loop
        if l_session_file_id is null then
            prc_api_stat_pkg.log_estimation( i_estimated_count => rec.cnt );
            
            prc_api_file_pkg.open_file( 
                o_sess_file_id => l_session_file_id
              , i_file_type    => cst_bmed_lty_api_const_pkg.LTY_SPENDING_BONUS_FILE_TYPE
            );
            trc_log_pkg.debug('l_session_file_id=' || l_session_file_id);
        end if;
        
        begin
            savepoint process_upload_bonus;
            
            l_oper_id := null;
            
            opr_api_create_pkg.create_operation(
                io_oper_id          => l_oper_id
              , i_session_id        => get_session_id
              , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
              , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL
              , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
              , i_oper_type         => lty_api_const_pkg.LOYALTY_MANUAL_REDEMPTION
              , i_oper_reason       => null
              , i_oper_amount       => rec.bonus_amount
              , i_oper_currency     => rec.currency
              , i_is_reversal       => com_api_const_pkg.FALSE
              , i_oper_date         => get_sysdate
              , i_host_date         => get_sysdate
            );
            
            opr_api_create_pkg.add_participant(
                i_oper_id               => l_oper_id
              , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
              , i_oper_type             => lty_api_const_pkg.LOYALTY_MANUAL_REDEMPTION
              , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
              , i_host_date             => get_sysdate
              , i_inst_id               => rec.inst_id
              , i_customer_id           => rec.customer_id
              , i_card_id               => rec.card_id
              , i_account_number        => rec.account_number
              , i_split_hash            => rec.split_hash
              , i_without_checks        => com_api_const_pkg.TRUE
            );

            if l_dest_curr = rec.currency then
                l_amount := rec.bonus_amount;
            else
                l_amount := com_api_rate_pkg.convert_amount(
                                i_src_amount      => rec.bonus_amount
                              , i_src_currency    => rec.currency
                              , i_dst_currency    => l_dest_curr
                              , i_rate_type       => i_rate_type
                              , i_inst_id         => i_inst_id
                              , i_eff_date        => get_sysdate
                              , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                            );
            end if;

            l_amount_str := com_api_currency_pkg.get_amount_str(
                                i_amount          => l_amount
                              , i_curr_code       => l_dest_curr
                              , i_mask_curr_code  => com_api_const_pkg.TRUE
                              , i_format_mask     => com_api_const_pkg.XML_FLOAT_FORMAT
                            );

            l_line := substr(regexp_replace(rec.commun_address, '[^0-9]'), -8)  -- digits only
                      || ',' || l_amount_str
                      || ',' || rec.customer_number;

            put_line(l_line);
            
            l_processed_count := l_processed_count + 1;
        exception
            when com_api_error_pkg.e_application_error then
                l_excepted_count := l_excepted_count + 1;
            when com_api_error_pkg.e_fatal_error then
                raise;
            when others then
                rollback to savepoint process_upload_bonus;
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
        end;
        
        prc_api_stat_pkg.log_current(
            i_current_count  => l_processed_count
          , i_excepted_count => l_excepted_count
        );
    end loop;

    if l_session_file_id is not null then
        flush_file;
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
        l_session_file_id  := null;
    end if;
    
    -- set bonus status spend
    if l_bonus_id_tab.count > 0 then
        forall i in 1 .. l_bonus_id_tab.count
            update lty_bonus
               set spent_amount = amount
                 , status       = lty_api_const_pkg.BONUS_TRANSACTION_SPENT
             where id  = l_bonus_id_tab(i);
    end if;
    
    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab    => l_event_tab
    );
       
    trc_log_pkg.debug('Process unloading finished ...' );

    prc_api_stat_pkg.log_end(
        i_excepted_total  => l_excepted_count
      , i_processed_total => l_processed_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_excepted_total  => l_excepted_count
          , i_processed_total => l_processed_count
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED 
        );
        
        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
             or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end export_bonus_spending_file;

end cst_bmed_lty_prc_bonus_pkg;
/
