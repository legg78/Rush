create or replace package body lty_prc_bonus_pkg as
/*********************************************************
 *  Constants for loyalty bonus <br />
 *  Created by Kopachev D.(kopachev@bpc.ru)  at 18.11.2009 <br />
 *  Last changed by $Author: kopachev $ <br />
 *  $LastChangedDate:: 2010-06-30 15:04:48 +0400#$ <br />
 *  Revision: $LastChangedRevision:  $ <br />
 *  Module: lty_prc_bonus_pkg <br />
 *  @headcom
 **********************************************************/ 

g_session_file_id   com_api_type_pkg.t_long_id := null;
g_raw_data_tab      com_api_type_pkg.t_raw_tab;
g_rec_num_tab       com_api_type_pkg.t_integer_tab;
g_rec_num           com_api_type_pkg.t_long_id := 0;
BULK_LIMIT constant integer := 400;

procedure flush_file is
begin
    trc_log_pkg.debug('lty_prc_bonus_pkg.flush_file, raw_tab.count='||g_raw_data_tab.count);
    prc_api_file_pkg.put_bulk(
        i_sess_file_id  => g_session_file_id
      , i_raw_tab       => g_raw_data_tab
      , i_num_tab       => g_rec_num_tab
    );
    g_raw_data_tab.delete;
    g_rec_num_tab.delete;
end;

procedure put_line (
    i_line                  in com_api_type_pkg.t_raw_data
) is
begin
    g_rec_num := g_rec_num + 1;
    g_raw_data_tab(g_rec_num)  := i_line;
    g_rec_num_tab(g_rec_num)   := g_rec_num;
    trc_log_pkg.info('lty_prc_bonus_pkg.export_bonus_file: line '||g_rec_num||'='||i_line);

    if mod(g_rec_num, BULK_LIMIT) = 0 then
        flush_file;
    end if;
end;

procedure export_bonus_file (
    i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_service_id  in     com_api_type_pkg.t_short_id
  , i_full_export in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_start_date  in     date                           default null
  , i_end_date    in     date                           default null
) is
    l_excepted_count     com_api_type_pkg.t_long_id := 0;
    l_processed_count    com_api_type_pkg.t_long_id := 0;

    l_line               com_api_type_pkg.t_raw_data;

    l_oper_id            com_api_type_pkg.t_long_id;
    l_sysdate            date;

    l_full_export        com_api_type_pkg.t_boolean;
    l_start_date         date;
    l_end_date           date;
    l_event_tab          com_api_type_pkg.t_number_tab;
    l_bonus_id_tab       num_tab_tpt;

    l_external_number    com_api_type_pkg.t_name;
    l_params             com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug ('start unloading bonuses: inst_id='||i_inst_id||', service_id='||i_service_id||', thread_number='||get_thread_number || 
                       ', i_full_export=' || i_full_export || ', i_start_date='||i_start_date || ', i_end_date='|| i_end_date);

    prc_api_stat_pkg.log_start;
    
    l_full_export := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_start_date  := trunc(coalesce(i_start_date, com_api_sttl_day_pkg.get_sysdate), 'DD');
    l_end_date    := nvl(trunc(i_end_date,'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_sysdate     := com_api_sttl_day_pkg.get_sysdate;  
    
    trc_log_pkg.debug ('l_full_export=' || l_full_export || ', l_start_date='||l_start_date || ', l_end_date='|| l_end_date);

    if l_full_export = com_api_const_pkg.FALSE then

         select o.id
              , b.id  
           bulk collect into 
                l_event_tab
              , l_bonus_id_tab  
           from evt_event_object o
              , evt_event e
              , lty_bonus b
          where decode(o.status, 'EVST0001', o.procedure_name, null) = 'LTY_PRC_BONUS_PKG.EXPORT_BONUS_FILE'
            and o.eff_date      <= l_sysdate
            and o.inst_id        = i_inst_id 
            and o.entity_type    = lty_api_const_pkg.ENTITY_TYPE_BONUS
            and o.object_id      = b.id 
            and e.id             = o.event_id            
            and b.status         = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE
            and b.inst_id        = o.inst_id
            and b.service_id     = i_service_id
            and o.split_hash     = b.split_hash            
            ;    
    else
         select b.id
           bulk collect into 
                l_bonus_id_tab  
           from lty_bonus b
          where b.inst_id        = i_inst_id
            and b.service_id     = i_service_id
            and b.oper_date between l_start_date and l_end_date
            --and b.status         = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE
            ;                                        
    end if;        
    
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
             , trunc(b.oper_date) oper_date
             , sum(b.amount) amount
             , sum(nvl(b.spent_amount,0)) spent_amount
             , a.split_hash
             , b.inst_id             
             , count(*) over() cnt
          from lty_bonus b
             , acc_account a
         where a.id         = b.account_id
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
             , trunc(b.oper_date)
             , a.split_hash
             , b.inst_id
    ) loop

        if g_session_file_id is null then
            
            prc_api_stat_pkg.log_estimation ( i_estimated_count => rec.cnt );
            
            prc_api_file_pkg.open_file( 
                o_sess_file_id => g_session_file_id 
              , i_file_type    => lty_api_const_pkg.LOYALTY_EXPORT_FILE_TYPE                
            );
            trc_log_pkg.debug('g_session_file_id=' || g_session_file_id);
            
            -- put header
            put_line (lpad(nvl(i_inst_id, 0), 4, '0')||' '
                    ||rpad(nvl(to_char(l_sysdate, 'YYYYMMDDHH24MISS'), ' '), 14 ) );
        end if;
        
        begin
            savepoint process_upload_bonus;
            
            l_oper_id := null;
            
            opr_api_create_pkg.create_operation (
                io_oper_id          => l_oper_id             
              , i_session_id        => get_session_id
              , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
              , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL
              , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
              , i_oper_type         => lty_api_const_pkg.LOYALTY_MANUAL_REDEMPTION
              , i_oper_reason       => null
              , i_oper_amount       => rec.amount - nvl(rec.spent_amount, 0)
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
            
            l_external_number := 
                prd_api_product_pkg.get_attr_value_char(
                    i_product_id   => rec.product_id
                  , i_entity_type  => rec.entity_type
                  , i_object_id    => rec.object_id
                  , i_attr_name    => lty_api_bonus_pkg.decode_attr_name(
                                          i_attr_name    => lty_api_const_pkg.LOYALTY_EXTERNAL_NUMBER
                                        , i_entity_type  => rec.entity_type
                                      )   
                  , i_params       => l_params
                  , i_service_id   => rec.service_id
                  , i_eff_date     => rec.oper_date
                  , i_inst_id      => rec.inst_id
                ); 

            -- formating line
            l_line := lpad(nvl(i_inst_id, 0), 4, '0')
                    ||' '|| lpad(nvl(rec.agent_id, 0), 8, '0')
                    ||' '|| rpad(nvl(rec.account_number, ' '), 20)
                    ||' '|| rpad(nvl(rec.currency, ' '), 3)
                    ||' '|| lpad(nvl(rec.service_id, 0), 8, '0')
                    ||' '|| lpad(nvl(rec.amount - rec.spent_amount, 0), 22, '0')
                    ||' '|| rpad(nvl(to_char(rec.oper_date, 'YYYYMMDDHH24MISS'), ' '), 14)
                    ||' '|| rpad(nvl(l_external_number, ' '), 200);
            put_line (l_line );
            
            l_processed_count := l_processed_count + 1;
            
        exception
            when com_api_error_pkg.e_application_error then
                l_excepted_count := l_excepted_count + 1;
                trc_log_pkg.debug(sqlerrm);

            when com_api_error_pkg.e_fatal_error then
                raise;
            when others then
                rollback to savepoint process_upload_bonus;
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
        end;
    
        prc_api_stat_pkg.log_current (
            i_current_count  => l_processed_count
          , i_excepted_count => l_excepted_count
        );
        
    end loop;

    if g_session_file_id is not null then
        -- put trailer
        put_line ( lpad(nvl(l_processed_count + 1, 0), 8, '0')  );
        flush_file;

        prc_api_file_pkg.close_file (
            i_sess_file_id  => g_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
        g_session_file_id  := null;
    end if;
    
    -- set bonus status spend
    forall i in 1 .. l_bonus_id_tab.count
        update lty_bonus
           set spent_amount = amount
             , status       = lty_api_const_pkg.BONUS_TRANSACTION_SPENT
         where id   = l_bonus_id_tab(i);
    
    if l_full_export = com_api_const_pkg.FALSE then
    
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab    => l_event_tab
        );
    end if;
       
    trc_log_pkg.debug ('Process unloading finished ...' );

    prc_api_stat_pkg.log_end (
        i_excepted_total  => l_excepted_count
      , i_processed_total => l_processed_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
exception
    when others then

        g_raw_data_tab.delete;
        g_rec_num_tab.delete;

        prc_api_stat_pkg.log_end (
            i_excepted_total  => l_excepted_count
          , i_processed_total => l_processed_count
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED 
        );        

        if g_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => g_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
            g_session_file_id  := null;
        end if;
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;

end;

procedure outdated_bonus (
    i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_service_id  in     com_api_type_pkg.t_tiny_id
  , i_eff_date    in     date
) is
    l_bunch_type_id      com_api_type_pkg.t_tiny_id;
    l_bunch_id           com_api_type_pkg.t_long_id;
    l_params             com_api_type_pkg.t_param_tab;

    l_excepted_count     com_api_type_pkg.t_long_id := 0;
    l_processed_count    com_api_type_pkg.t_long_id := 0;

    l_param_tab          com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug ('Process outdated bonuses. inst_id='||i_inst_id||', service_id='|| i_service_id 
                    || ', eff_date=' || to_char(i_eff_date, 'YYYYMMDDHH24MISS') );
    prc_api_stat_pkg.log_start;

    for rec in (
        select b.id
             , b.account_id
             , b.product_id
             , b.service_id
             , b.amount - nvl(b.spent_amount,0) amount
             , a.currency
             , row_number() over(order by b.id) rn
             , count(*) over() cnt
             , a.account_type
             , c.card_type_id
             , nvl(b.entity_type, iss_api_const_pkg.ENTITY_TYPE_CARD) as entity_type
             , nvl(b.object_id, b.card_id) as object_id
          from lty_bonus b
             , acc_account a
             , iss_card c
         where b.service_id  = i_service_id
           and b.inst_id     = i_inst_id
           and a.id          = b.account_id
           and b.card_id     = c.id(+)
           and b.expire_date < i_eff_date
           and decode(b.status, 'BNST0100', b.status, null) = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE
           for update of b.status
    ) loop
        if rec.rn = 1 then
            prc_api_stat_pkg.log_estimation (i_estimated_count => rec.cnt);
            
            l_bunch_type_id := prd_api_product_pkg.get_attr_value_number(
                i_product_id   => rec.product_id
              , i_entity_type  => rec.entity_type
              , i_object_id    => rec.object_id
              , i_attr_name    => lty_api_bonus_pkg.decode_attr_name(
                                      i_attr_name   => lty_api_const_pkg.LOYALTY_OUTDATE_BUNCH_TYPE
                                    , i_entity_type => rec.entity_type
                                  )
              , i_params       => l_params
              , i_service_id   => rec.service_id
              , i_eff_date     => i_eff_date
              , i_inst_id      => i_inst_id 
            ); 
        end if;      
        begin
            savepoint process_outdated_bonuses;

            rul_api_param_pkg.set_param (
                i_name       => 'CARD_TYPE_ID'
                , io_params  => l_param_tab
                , i_value    => rec.card_type_id
            );

            acc_api_entry_pkg.put_bunch (
                o_bunch_id       => l_bunch_id
              , i_bunch_type_id  => l_bunch_type_id
              , i_macros_id      => rec.id
              , i_amount         => rec.amount
              , i_currency       => rec.currency
              , i_account_type   => rec.account_type
              , i_account_id     => rec.account_id
              , i_posting_date   => i_eff_date
              , i_param_tab      => l_param_tab
            );

            -- set bonus status outdated
            update lty_bonus
               set status = lty_api_const_pkg.BONUS_TRANSACTION_OUTDATED
             where id     = rec.id;

            l_processed_count := l_processed_count + 1;

        exception
            when com_api_error_pkg.e_application_error then
                l_excepted_count := l_excepted_count + 1;
                trc_log_pkg.debug('outdated_bonus: error, id= '||rec.id||' '||sqlerrm);
            when com_api_error_pkg.e_fatal_error then
                raise;
            when others then
                rollback to savepoint process_outdated_bonuses;

                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
            end;

            prc_api_stat_pkg.log_current (
                i_current_count   => l_processed_count
              , i_excepted_count  => l_excepted_count
            );
    end loop;

    trc_log_pkg.debug ('Process outdated bonuses finished, '||l_processed_count||' processed, '
                     ||l_excepted_count||' excepted.' );

    prc_api_stat_pkg.log_end (
        i_excepted_total  => l_excepted_count
      , i_processed_total => l_processed_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end;

end;
/
