create or replace package body cst_cfc_scoring_pkg as

procedure generate_scoring_data(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_customer_number              in     com_api_type_pkg.t_name
  , i_account_number               in     com_api_type_pkg.t_account_number
  , i_start_date                   in     date                                default null
  , i_end_date                     in     date                                default null
) is
    cursor cur_scoring_data(
        i_inst_id           com_api_type_pkg.t_inst_id
      , i_customer_number   com_api_type_pkg.t_name
      , i_account_number    com_api_type_pkg.t_account_number
      , i_from_date         date
      , i_to_date           date
    ) is
        select pc.customer_number
             , aa.account_number
             , coalesce(
                   ic.card_mask
                 , iss_api_card_pkg.get_card_mask(i_card_number => ic.card_number)
               ) card_mask
             , decode(ic.category
                    , iss_api_const_pkg.CARD_CATEGORY_PRIMARY -- 'CRCG0800'
                    , 1, 0) as category
             , ii.status
             , cst_cfc_com_pkg.get_balance_amount(
                   i_account_id         => aa.id
                 , i_balance_type       => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED --'BLTP1001'
                ) as card_limit
             , iv.invoice_date
             , iv.due_date
             , iv.min_amount_due
             , acc_api_balance_pkg.get_aval_balance_amount_only(
                   i_account_id         => aa.id
               ) exceed_limit
             , null  sub_acct
             , cst_cfc_com_pkg.get_principal_amount(
                    i_account_id         => aa.id
               ) as sub_acct_bal
             , op.count_oper atm_wdr_cnt             
             , 0 pos_cnt             
             , op.count_oper all_trx_cnt 
             , op.sum_amt atm_wdr_amt                         
             , 0 pos_amt
             , op.sum_amt total_trx_amt
             , cst_cfc_com_pkg.get_total_payment(
                   i_account_id     => aa.id
                 , i_start_date     => i_from_date
                 , i_end_date       => i_to_date
               ) daily_repayment 
             , 0 cycle_repayment 
             , greatest(0, trunc(sysdate - cst_cfc_com_pkg.get_first_overdue_date(
                                                   i_account_id  => aa.id
                                                 , i_split_hash  => aa.split_hash
                                               ))) current_dpd
             , coalesce(substr(crd_invoice_pkg.get_converted_aging_period(i_aging_period => iv.aging_period), -2)
                             , to_char(iv.aging_period), '1a') bucket 
             , bk.revised_bucket
             , bk.eff_date 
             , bk.expir_date
             , bk.valid_period
             , bk.reason 
             , '' highest_bucket_01
             , '' highest_bucket_03
             , '' highest_bucket_06
             , 0 highest_dpd
             , 0 cycle_wdr_amt
             , cst_cfc_com_pkg.get_debit_amount(
                   i_account_id         => aa.id
                 , i_split_hash         => aa.split_hash
                 , i_start_date         => iv.invoice_date
                 , i_end_date           => add_months(iv.invoice_date, 1)
               ) total_debit_amt
             , 0 cycle_avg_wdr_amt
             , 0 cycle_daily_avg_usage
             , 0 life_wdr_amt
             , 0 life_wdr_cnt
             , 0 avg_wdr
             , 0 daily_usage
             , 0 monthly_usage
             , prd_api_product_pkg.get_attr_value_number(
                   i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                 , i_object_id          => ic.id
                 , i_attr_name          => iss_api_const_pkg.ATTR_CARD_TEMP_CREDIT_LIMIT --'ISS_CARD_TEMPORARY_CREDIT_LIMIT_VALUE'
                 , i_mask_error         => com_api_const_pkg.TRUE
               ) tmp_crd_limit
             , cst_cfc_com_pkg.get_card_limit_valid_date(
                   i_card_id            => ic.id
                 , i_split_hash         => ic.split_hash
                 , i_is_start           => com_api_const_pkg.TRUE
                 , i_limit_type         => cst_cfc_api_const_pkg.CARD_TEMPORARY_CREDIT_LIMIT --'LMTP0141'
               ) limit_start_date
             , cst_cfc_com_pkg.get_card_limit_valid_date(
                   i_card_id            => ic.id
                 , i_split_hash         => ic.split_hash
                 , i_is_start           => com_api_const_pkg.FALSE
                 , i_limit_type         => cst_cfc_api_const_pkg.CARD_TEMPORARY_CREDIT_LIMIT --'LMTP0141'
               ) limit_end_date
             , 0 card_usage_limit
             , cst_cfc_com_pkg.get_balance_amount(
                   i_account_id         => aa.id
                 , i_balance_type       => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST --'BLTP1005'
               ) overdue_interest
             , cst_cfc_com_pkg.get_balance_amount(
                   i_account_id         => aa.id
                 , i_balance_type       => crd_api_const_pkg.BALANCE_TYPE_INTEREST --'BLTP1003'
               ) indue_interest  
             , aa.split_hash        
          from acc_account          aa
             , acc_account_object   ao
             , prd_customer         pc
             , iss_card_instance    ii
             , iss_card_vw          ic
             , (select invoice_id
                     , account_id  
                     , invoice_date
                     , due_date
                     , min_amount_due
                     , aging_period
                  from (select row_number() over(partition by i.account_id order by i.id desc) rn
                             , i.id as invoice_id
                             , i.account_id
                             , i.invoice_date
                             , i.due_date
                             , i.min_amount_due
                             , i.aging_period
                          from crd_invoice i 
                       )
                  where rn = 1
               ) iv
             , (select account_id
                     , customer_id
                     , revised_bucket
                     , eff_date
                     , expir_date
                     , valid_period
                     , reason
                  from (select row_number() over(order by b.eff_date desc, b.log_date desc) rn
                             , b.id
                             , b.account_id
                             , b.customer_id
                             , b.revised_bucket
                             , b.eff_date
                             , b.expir_date
                             , b.valid_period
                             , b.reason
                          from scr_bucket_vw b
                         where get_sysdate between b.eff_date and b.expir_date
                        )
                  where rn = 1
                 ) bk
             , (select sum(opr.oper_amount) as sum_amt
                     , count(1) as count_oper
                     , opc.card_number
                     , opc.split_hash
                  from opr_operation opr
                     , opr_participant ptp
                     , opr_card opc
                 where ptp.oper_id              = opr.id  
                   and ptp.participant_type     = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                   and opc.oper_id              = ptp.oper_id 
                   and opc.participant_type     = ptp.participant_type
                   and opc.split_hash           = ptp.split_hash   
                   and ptp.split_hash in (select split_hash from com_api_split_map_vw) 
                   and opr.oper_type            = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH --'OPTP0001' 
                   and opr.status               = opr_api_const_pkg.OPERATION_STATUS_PROCESSED --'OPST0400'
                   and opr.is_reversal          = com_api_const_pkg.FALSE
                   and not exists (select /*+ index(orig opr_oper_original_id_ndx) */
                                          1
                                     from opr_operation
                                    where original_id = opr.id
                                      and is_reversal = com_api_const_pkg.TRUE)
                   and opr.id between com_api_id_pkg.get_from_id(i_from_date)
                                  and com_api_id_pkg.get_till_id(i_to_date)  
                 group by
                       opc.card_number
                     , opc.split_hash
               ) op
         where aa.customer_id       = pc.id
           and aa.id                = ao.account_id
           and ao.entity_type       = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
           and ao.object_id         = ic.id
           and ii.card_id           = ic.id
           and bk.account_id (+)    = aa.id
           and bk.customer_id(+)    = aa.customer_id
           and aa.split_hash        = pc.split_hash
           and aa.split_hash        = ao.split_hash
           and ao.split_hash        = ic.split_hash
           and op.card_number(+)    = ic.card_number
           and op.split_hash(+)     = ic.split_hash
           and reverse(op.card_number(+)) = reverse(ic.card_number)  -- support indexes
           and reverse(aa.account_number) = nvl(reverse(i_account_number), reverse(aa.account_number))      -- support indexes 
           and reverse(pc.customer_number) = nvl(reverse(i_customer_number), reverse(pc.customer_number))   -- support indexes 
           and aa.inst_id           = nvl(i_inst_id, aa.inst_id)
           and aa.account_type      = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT             --'ACTP0130'
           and ii.status            != cst_cfc_api_const_pkg.CARD_STATUS_INSTANT_CARD   --'CSTS0026'
           and ii.state             != iss_api_const_pkg.CARD_STATE_CLOSED              --'CSTE0300'
           and ii.expir_date        >= get_sysdate
           and iv.account_id(+)     = aa.id
           and aa.split_hash in (select split_hash from com_api_split_map_vw)
        ;
        
    LOG_PREFIX                      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.generate_scoring_data: ';
    BULK_LIMIT                      constant pls_integer := 1000;
    l_scoring_tab                   cst_cfc_api_type_pkg.t_scoring_tab;
    l_estimated_count               com_api_type_pkg.t_count := 0;
    l_record_count                  com_api_type_pkg.t_count := 0;
    l_from_date                     date;
    l_to_date                       date;

begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_inst_id [#1] i_customer_number [#2]
                    i_account_number [#3] i_start_date [#4] i_end_date [#5]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_customer_number
      , i_env_param3 => i_account_number
      , i_env_param4 => i_start_date
      , i_env_param5 => i_end_date
    );
    
    l_from_date := nvl(i_start_date, trunc(get_sysdate) - 1);
    l_to_date   := nvl(i_end_date, l_from_date + 1 - com_api_const_pkg.ONE_SECOND);
    
    prc_api_stat_pkg.log_start;
    
    select count(1)
      into l_estimated_count
      from acc_account          aa
         , acc_account_object   ao
         , prd_customer         pc
         , iss_card_instance    ii
     where aa.customer_id       = pc.id
       and aa.id                = ao.account_id
       and ao.object_id         = ii.card_id
       and ao.entity_type       = iss_api_const_pkg.ENTITY_TYPE_CARD  --'ENTTCARD'
       and aa.split_hash        = pc.split_hash
       and aa.split_hash        = ao.split_hash 
       and aa.split_hash        = ii.split_hash
       and aa.account_type      = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT             --'ACTP0130' 
       and ii.status            != cst_cfc_api_const_pkg.CARD_STATUS_INSTANT_CARD   --'CSTS0026'
       and ii.state             != iss_api_const_pkg.CARD_STATE_CLOSED              --'CSTE0300'
       and ii.expir_date        >= get_sysdate
       and aa.inst_id           = nvl(i_inst_id, aa.inst_id)
       and reverse(aa.account_number) = nvl(reverse(i_account_number), reverse(aa.account_number))      -- support indexes
       and reverse(pc.customer_number) = nvl(reverse(i_customer_number), reverse(pc.customer_number))   -- support indexes
       and aa.split_hash in (select split_hash from com_api_split_map_vw)
       ;
                  
    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_estimated_count
    );
    
    --Delete data in current date in case the process will be run again
    delete 
      from cst_cfc_scoring 
     where split_hash in (select split_hash from com_api_split_map_vw)
       and trunc(run_date) = trunc(get_sysdate)
    ;
    
    --Prepare data details to export
    open cur_scoring_data(
        i_inst_id           => i_inst_id
      , i_customer_number   => i_customer_number
      , i_account_number    => i_account_number
      , i_from_date         => l_from_date
      , i_to_date           => l_to_date
    );

    loop
        fetch cur_scoring_data bulk collect into l_scoring_tab limit BULK_LIMIT;

        for i in 1..l_scoring_tab.count loop
            l_record_count := l_record_count + 1;
            
            insert into cst_cfc_scoring (
                  customer_number      
                , account_number       
                , card_mask            
                , category             
                , status               
                , card_limit           
                , invoice_date         
                , due_date             
                , min_amount_due       
                , exceed_limit         
                , sub_acct             
                , sub_acct_bal         
                , atm_wdr_cnt          
                , pos_cnt              
                , all_trx_cnt          
                , atm_wdr_amt          
                , pos_amt              
                , total_trx_amt        
                , daily_repayment      
                , cycle_repayment      
                , current_dpd          
                , bucket               
                , revised_bucket       
                , eff_date             
                , expir_date           
                , valid_period         
                , reason               
                , highest_bucket_01    
                , highest_bucket_03    
                , highest_bucket_06    
                , highest_dpd          
                , cycle_wdr_amt        
                , total_debit_amt      
                , cycle_avg_wdr_amt    
                , cycle_daily_avg_usage
                , life_wdr_amt         
                , life_wdr_cnt         
                , avg_wdr              
                , daily_usage          
                , monthly_usage        
                , tmp_crd_limit        
                , limit_start_date     
                , limit_end_date       
                , card_usage_limit     
                , overdue_interest     
                , indue_interest       
                , split_hash           
                , run_date             
            ) values (
                  l_scoring_tab(i).customer_number      
                , l_scoring_tab(i).account_number       
                , l_scoring_tab(i).card_mask            
                , l_scoring_tab(i).category             
                , l_scoring_tab(i).status               
                , l_scoring_tab(i).card_limit           
                , l_scoring_tab(i).invoice_date         
                , l_scoring_tab(i).due_date             
                , l_scoring_tab(i).min_amount_due       
                , l_scoring_tab(i).exceed_limit         
                , l_scoring_tab(i).sub_acct             
                , l_scoring_tab(i).sub_acct_bal         
                , l_scoring_tab(i).atm_wdr_cnt          
                , l_scoring_tab(i).pos_cnt              
                , l_scoring_tab(i).all_trx_cnt          
                , l_scoring_tab(i).atm_wdr_amt          
                , l_scoring_tab(i).pos_amt              
                , l_scoring_tab(i).total_trx_amt        
                , l_scoring_tab(i).daily_repayment      
                , l_scoring_tab(i).cycle_repayment      
                , l_scoring_tab(i).current_dpd          
                , l_scoring_tab(i).bucket               
                , l_scoring_tab(i).revised_bucket       
                , l_scoring_tab(i).eff_date             
                , l_scoring_tab(i).expir_date           
                , l_scoring_tab(i).valid_period         
                , l_scoring_tab(i).reason               
                , l_scoring_tab(i).highest_bucket_01    
                , l_scoring_tab(i).highest_bucket_03    
                , l_scoring_tab(i).highest_bucket_06    
                , l_scoring_tab(i).highest_dpd          
                , l_scoring_tab(i).cycle_wdr_amt        
                , l_scoring_tab(i).total_debit_amt      
                , l_scoring_tab(i).cycle_avg_wdr_amt    
                , l_scoring_tab(i).cycle_daily_avg_usage
                , l_scoring_tab(i).life_wdr_amt         
                , l_scoring_tab(i).life_wdr_cnt         
                , l_scoring_tab(i).avg_wdr              
                , l_scoring_tab(i).daily_usage          
                , l_scoring_tab(i).monthly_usage        
                , l_scoring_tab(i).tmp_crd_limit        
                , l_scoring_tab(i).limit_start_date     
                , l_scoring_tab(i).limit_end_date       
                , l_scoring_tab(i).card_usage_limit     
                , l_scoring_tab(i).overdue_interest     
                , l_scoring_tab(i).indue_interest       
                , l_scoring_tab(i).split_hash           
                , get_sysdate
            );
                    
            if mod(l_record_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_record_count
                  , i_excepted_count    => 0
                );
            end if;
        
        end loop;
        
        exit when cur_scoring_data%notfound;

    end loop;

    close cur_scoring_data;     

    prc_api_stat_pkg.log_current(
        i_current_count     => l_record_count
      , i_excepted_count    => 0
    );   
        
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Process Finished.'
    );  
exception    
    when others then

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => 1
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;
end generate_scoring_data;

procedure export_scoring_data
is
    LOG_PREFIX                  constant  com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.export_scoring_data:';
    DELIMETER                   constant  com_api_type_pkg.t_name := '|';

    l_session_file_id                     com_api_type_pkg.t_long_id;
    l_record                              com_api_type_pkg.t_raw_tab;
    l_record_count                        pls_integer := 0;

    l_estimated_count                     com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started process'
    );
    
    prc_api_stat_pkg.log_start;
    
    select count(1)
      into l_estimated_count
      from cst_cfc_scoring
     where split_hash in (select split_hash from com_api_split_map_vw)
       and trunc(run_date) = trunc(get_sysdate);
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_estimated_count
    );
    
    if l_estimated_count > 0 then

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
        );

        prc_api_file_pkg.put_line(
            i_sess_file_id => l_session_file_id
          , i_raw_data     => cst_cfc_api_const_pkg.SCORING_DATA_FILE_HEADER
        );
        
        for i in (
            select customer_number      
                 , account_number       
                 , card_mask            
                 , category             
                 , status               
                 , card_limit           
                 , invoice_date         
                 , due_date             
                 , min_amount_due       
                 , exceed_limit         
                 , sub_acct             
                 , sub_acct_bal         
                 , atm_wdr_cnt          
                 , pos_cnt              
                 , all_trx_cnt          
                 , atm_wdr_amt          
                 , pos_amt              
                 , total_trx_amt        
                 , daily_repayment      
                 , cycle_repayment      
                 , current_dpd          
                 , bucket               
                 , revised_bucket       
                 , eff_date             
                 , expir_date           
                 , valid_period         
                 , reason               
                 , highest_bucket_01    
                 , highest_bucket_03    
                 , highest_bucket_06    
                 , highest_dpd          
                 , cycle_wdr_amt        
                 , total_debit_amt      
                 , cycle_avg_wdr_amt    
                 , cycle_daily_avg_usage
                 , life_wdr_amt         
                 , life_wdr_cnt         
                 , avg_wdr              
                 , daily_usage          
                 , monthly_usage        
                 , tmp_crd_limit        
                 , limit_start_date     
                 , limit_end_date       
                 , card_usage_limit     
                 , overdue_interest     
                 , indue_interest       
                 , split_hash           
                 , run_date 
             from cst_cfc_scoring
            where split_hash in (select split_hash from com_api_split_map_vw)
              and trunc(run_date) = trunc(get_sysdate)
            )
        loop
            l_record_count := l_record_count + 1;
            
            l_record(1) := 
                to_char(i.run_date, cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT) || DELIMETER
                || rpad(i.customer_number, 32)              || DELIMETER
                || rpad(i.account_number, 32)               || DELIMETER
                || rpad(i.card_mask, 24)                    || DELIMETER
                || rpad(i.category, 1)                      || DELIMETER
                || rpad(i.status, 8)                        || DELIMETER
                || rpad(to_char(i.card_limit, com_api_const_pkg.XML_NUMBER_FORMAT), 16)|| DELIMETER
                || to_char(i.invoice_date, cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT)  || DELIMETER
                || to_char(i.due_date, cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT)  || DELIMETER
                || rpad(i.min_amount_due, 16)                      || DELIMETER
                || rpad(i.exceed_limit, 16)                        || DELIMETER
                || rpad(i.sub_acct, 32)                            || DELIMETER
                || rpad(i.sub_acct_bal, 16)                        || DELIMETER
                || rpad(i.atm_wdr_cnt, 12)                         || DELIMETER
                || rpad(i.pos_cnt, 12)                             || DELIMETER
                || rpad(i.all_trx_cnt, 12)                         || DELIMETER
                || rpad(i.atm_wdr_amt, 16)                         || DELIMETER
                || rpad(i.pos_amt, 16)                             || DELIMETER
                || rpad(i.total_trx_amt, 16)                       || DELIMETER
                || rpad(i.daily_repayment, 16)                     || DELIMETER
                || rpad(i.cycle_repayment, 16)                     || DELIMETER
                || rpad(i.current_dpd, 4)                          || DELIMETER
                || rpad(i.bucket, 2)                               || DELIMETER
                || rpad(i.revised_bucket, 2)                       || DELIMETER
                || rpad(i.eff_date, 8)                             || DELIMETER
                || rpad(i.expir_date, 8)                           || DELIMETER
                || rpad(i.valid_period, 3)                         || DELIMETER
                || rpad(i.reason, 128)                             || DELIMETER
                || rpad(i.highest_bucket_01, 2)                    || DELIMETER
                || rpad(i.highest_bucket_03, 2)                    || DELIMETER
                || rpad(i.highest_bucket_06, 2)                    || DELIMETER
                || rpad(i.highest_dpd, 4)                          || DELIMETER
                || rpad(i.cycle_wdr_amt, 16)                       || DELIMETER
                || rpad(i.total_debit_amt, 16)                     || DELIMETER
                || rpad(i.cycle_avg_wdr_amt, 16)                   || DELIMETER
                || rpad(i.cycle_daily_avg_usage, 16)               || DELIMETER
                || rpad(i.life_wdr_amt, 16)                        || DELIMETER
                || rpad(i.life_wdr_cnt, 12)                        || DELIMETER
                || rpad(i.avg_wdr, 16)                             || DELIMETER
                || rpad(i.daily_usage, 16)                         || DELIMETER
                || rpad(i.monthly_usage, 16)                       || DELIMETER
                || rpad(i.tmp_crd_limit, 16)                       || DELIMETER
                || to_char(i.limit_start_date, cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT) || DELIMETER
                || to_char(i.limit_end_date,   cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT) || DELIMETER
                || rpad(i.card_usage_limit, 16)                    || DELIMETER
                || rpad(i.overdue_interest, 16)                    || DELIMETER
                || rpad(i.indue_interest, 16)
                ; 
            
            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(1)
              , i_sess_file_id  => l_session_file_id
            );  
            
            l_record.delete;
            
            if mod(l_record_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_record_count
                  , i_excepted_count    => 0
                );
            end if;
        
        end loop;
        
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    
    end if;
    
    prc_api_stat_pkg.log_current(
        i_current_count     => l_record_count
      , i_excepted_count    => 0
    );   
        
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finished process'
    );    
        
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end export_scoring_data;

end cst_cfc_scoring_pkg;
/
