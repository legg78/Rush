create or replace package body cst_cab_process_pkg as

function get_customer_name(
    i_customer_id           in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name
is
    l_customer_name     com_api_type_pkg.t_name;
    l_lang              com_api_type_pkg.t_dict_value := get_user_lang;
begin
    select case c.entity_type
           when com_api_const_pkg.ENTITY_TYPE_PERSON -- 'ENTTPERS'
           then com_ui_person_pkg.get_person_name(c.object_id, l_lang)
           when com_api_const_pkg.ENTITY_TYPE_COMPANY -- 'ENTTCOMP'
           then nvl(
                    get_text('COM_COMPANY', 'DESCRIPTION', c.object_id, l_lang)
                  , get_text('COM_COMPANY', 'LABEL', c.object_id, l_lang)
                )
           end as customer_name
      into l_customer_name
      from prd_customer c
     where c.id = i_customer_id;
    return l_customer_name;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text          => lower($$PLSQL_UNIT) || '.get_customer_name(i_customer_id => [#1]) No data found.'
          , i_env_param1    => i_customer_id
        );
        return null;
end get_customer_name;

function get_pay_status(
    i_account_id            in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_dict_value
is
    l_status                com_api_type_pkg.t_dict_value;
    l_acc_status            com_api_type_pkg.t_dict_value;
    l_overdue_days          com_api_type_pkg.t_short_id;
    l_count_trans           com_api_type_pkg.t_short_id;
begin
    select status
      into l_acc_status
      from acc_account
     where id = i_account_id;
     
    case l_acc_status
        when 'ACSTACRQ' then l_status := 'N';    -- New – Not yet activated
        when 'ACSTCLSD' then l_status := 'C';    -- Closed
        when 'ACSTWOFF' then l_status := 'W';    -- Write off
        when 'ACSTACTV' then l_status := '0';    -- Current
        when 'ACSTCOLL' then l_status := '0';
        when 'ACSTCRED' then l_status := '0';
        else l_status := null;
    end case;
    
    if l_status = '0' then
        l_overdue_days := cst_cab_com_pkg.get_overdue_days(i_account_id => i_account_id);
        case 
            when l_overdue_days between 1   and 29  then l_status := '1';
            when l_overdue_days between 30  and 59  then l_status := '2';
            when l_overdue_days between 60  and 89  then l_status := '3';
            when l_overdue_days between 90  and 119 then l_status := '4';
            when l_overdue_days between 120 and 149 then l_status := '5';
            when l_overdue_days between 150 and 179 then l_status := '6';
            when l_overdue_days between 180 and 209 then l_status := '7';
            when l_overdue_days between 210 and 239 then l_status := '8';
            when l_overdue_days between 240 and 269 then l_status := '9';
            when l_overdue_days between 270 and 299 then l_status := 'T';
            when l_overdue_days between 300 and 329 then l_status := 'E';
            when l_overdue_days between 330 and 359 then l_status := 'Y';
            when l_overdue_days >= 360 then l_status := 'L';
            else l_status := '0';
        end case;  
        
        select count(1)
          into l_count_trans
          from crd_debt d
         where decode(d.status, 'DBTSACTV', d.account_id , null) = i_account_id;  
        
        if l_count_trans = 0 then 
            l_status := 'Q';
        end if;
             
    end if;        
    return l_status;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text          => lower($$PLSQL_UNIT) || '.get_pay_status(i_account_id => [#1]) No data found.'
          , i_env_param1    => i_account_id
        );
        return null;
end get_pay_status;

procedure generate_cbc_report(
    i_inst_id               in      com_api_type_pkg.t_inst_id
) is
    LOG_PREFIX                      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.generate_cbc_report: ';
    l_estimated_count               com_api_type_pkg.t_count := 0;
    l_record_count                  com_api_type_pkg.t_count := 0;
    l_session_file_id               com_api_type_pkg.t_long_id;
    l_line                          com_api_type_pkg.t_text;                      
begin
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Process Begin'
    ); 
    prc_api_stat_pkg.log_start;
    
    select count(1)
      into l_estimated_count
      from acc_account aac
         , prd_customer cus
         , (select n.card_number
                 , i.seq_number             
                 , i.cardholder_name
                 , i.expir_date             
                 , c.card_type_id
                 , c.category
                 , c.cardholder_id                          
                 , o.account_id
              from iss_card c
                 , iss_card_instance i
                 , iss_card_number n
                 , acc_account_object o
             where i.card_id        = c.id
               and n.card_id        = c.id
               and i.state         != iss_api_const_pkg.CARD_STATE_CLOSED --'CSTE0300'
               and o.object_id      = i.card_id
               and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
           ) cad
     where aac.customer_id  = cus.id
       and cad.account_id   = aac.id
       and aac.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
       and cus.entity_type  in (com_api_const_pkg.ENTITY_TYPE_PERSON  -- 'ENTTPERS'
                              , com_api_const_pkg.ENTITY_TYPE_COMPANY -- 'ENTTCOMP'
                              )
       and aac.inst_id      = nvl(i_inst_id, aac.inst_id);
                  
    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_estimated_count
    );
    
    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );
    
    for m in (
        select cus.customer_number
             , cst_cab_process_pkg.get_customer_name(cus.id) as customer_name
             , (select h.cardholder_number
                  from iss_cardholder h
                 where h.id = cad.cardholder_id            
                ) as cardholder_id
             , cad.cardholder_name     
             , iss_api_token_pkg.decode_card_number(
                   i_card_number => cad.card_number
                 , i_mask_error  => com_api_type_pkg.TRUE
               ) as card_number
             , cad.seq_number as card_seq_number
             , get_text('NET_CARD_TYPE'
                        , 'NAME'
                        , cad.card_type_id
                        , get_user_lang
               ) as prod_type_sv
             , case cad.category
                    when 'CRCG0800' then 'P'
                    when 'CRCG0410' then 'S'
                    when 'CRCG0400' then 'S'
               end as applicant_type               
             , 'S' as account_type          
             , aac.account_number          
             , (select to_char(open_date, 'ddmmyyyy') 
                  from acc_balance 
                 where balance_type = 'BLTP1001' 
                  and account_id = aac.id
                ) as issued_date
             , com_api_currency_pkg.get_currency_name(aac.currency) as currency
             , com_api_currency_pkg.get_amount_str(
                    i_amount            => (select balance 
                                              from acc_balance 
                                             where balance_type = 'BLTP1001' 
                                               and account_id = aac.id
                                            )
                  , i_curr_code         => aac.currency
                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                  , i_mask_error        => com_api_type_pkg.TRUE
               ) as acc_credit_limit  
             , cad.expir_date
             , case aac.status   
                    when 'ACSTACTV' then 'N'    --Normal
                    when 'ACSTCLSD' then 'C'    --Closed
                    when 'ACSTWOFF' then 'W'    --Write Off
                    when 'ACSTFRAU' then 'D'    --Doubtful
                    else ''                     --Unknown
               end as prod_status
             , 0 as min_payment_amt
             , 'M' as payment_frequency     
             , (select to_char(max(posting_date), 'ddmmyyyy') 
                  from crd_payment 
                 where account_id = aac.id
               ) as last_payment_date
             , com_api_currency_pkg.get_amount_str(
                    i_amount            => (select max(amount) keep (dense_rank last order by posting_date)
                                              from crd_payment 
                                             where account_id = aac.id
                                            )
                  , i_curr_code         => aac.currency
                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                  , i_mask_error        => com_api_type_pkg.TRUE
               )  as last_amount_paid
             , 'FD' as security_type
             , com_api_currency_pkg.get_amount_str(
                    i_amount            => (select nvl(sum(cdb.amount), 0)
                                              from crd_debt cd
                                                 , crd_debt_balance cdb
                                              where cd.id = cdb.debt_id
                                                and decode(cd.status, 'DBTSACTV', cd.account_id, null) = aac.id
                                            )
                  , i_curr_code         => aac.currency
                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                  , i_mask_error        => com_api_type_pkg.TRUE
               ) as outstanding_balance
             , com_api_currency_pkg.get_amount_str(
                    i_amount            => (select nvl(sum(cdb.min_amount_due), 0)
                                              from crd_debt cd
                                                 , crd_debt_balance cdb
                                              where cd.id = cdb.debt_id
                                                and decode(cd.status, 'DBTSACTV', cd.account_id, null) = aac.id
                                            )
                  , i_curr_code         => aac.currency
                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                  , i_mask_error        => com_api_type_pkg.TRUE
               ) as past_due_amount
             , (select to_char(next_date, 'ddmmyyyy')
                  from fcl_cycle_counter
                 where entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   and cycle_type = crd_api_const_pkg.DUE_DATE_CYCLE_TYPE  --'CYTP1003'
                   and object_id = aac.id
                ) as next_due_date
             , cst_cab_process_pkg.get_pay_status(i_account_id => aac.id) as pay_status_code
             , null as wof_status
             , null as wof_status_date
             , null as wof_original_amt
          from acc_account aac
             , prd_customer cus
             , (select n.card_number
                     , i.seq_number             
                     , i.cardholder_name
                     , i.expir_date             
                     , c.card_type_id
                     , c.category
                     , c.cardholder_id                          
                     , o.account_id
                  from iss_card c
                     , iss_card_instance i
                     , iss_card_number n
                     , acc_account_object o
                 where i.card_id        = c.id
                   and n.card_id        = c.id
                   and i.state         != iss_api_const_pkg.CARD_STATE_CLOSED --'CSTE0300'
                   and o.object_id      = i.card_id
                   and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
               ) cad
         where aac.customer_id  = cus.id
           and cad.account_id   = aac.id
           and aac.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
           and cus.entity_type  in (com_api_const_pkg.ENTITY_TYPE_PERSON  -- 'ENTTPERS'
                                  , com_api_const_pkg.ENTITY_TYPE_COMPANY -- 'ENTTCOMP'
                                  )
           and aac.inst_id      = nvl(i_inst_id, aac.inst_id)
         order by aac.id
    ) loop    
        l_record_count := l_record_count + 1; 
        l_line :=  m.customer_number        -- Customer ID (number)
            || ',' || m.customer_name       -- Customer name
            || ',' || m.cardholder_id       -- Cardholder ID (number)
            || ',' || m.cardholder_name     -- Cardholder name
            || ',' || m.card_number         -- Card number
            || ',' || m.card_seq_number     -- Card sequence number
            || ',' || m.prod_type_sv        -- Product Type SV (card type in SV)
            || ',' || m.applicant_type      -- Applicant Type (P: Primary, S: Supplementary)
            || ',' || m.account_type        -- Account type (S for Single credit account)                   
            || ',' || m.account_number      -- Account Number
            || ',' || m.issued_date         -- Date Issued (Credit account open date)
            || ',' || m.currency            -- Currency (Credit account currency)
            || ',' || m.acc_credit_limit    -- Product Limit (Customer Credit Account limit)
            || ',' || m.expir_date          -- Product Expiry Date (Customer Credit card expiry date)
            || ',' || m.prod_status         -- Product status                   
            || ',' || m.min_payment_amt     -- Instalment Amount (Minimum Payment Amount)                   
            || ',' || m.payment_frequency   -- Payment Frequency
            || ',' || m.last_payment_date   -- Last Payment Date
            || ',' || m.last_amount_paid    -- Last Amount Paid
            || ',' || m.security_type       -- Security Type - Primary
            || ',' || m.outstanding_balance -- Outstanding Balance
            || ',' || m.past_due_amount     -- Past Due Amount
            || ',' || m.next_due_date       -- Next Payment Date
            || ',' || m.pay_status_code     -- Payment status code
            || ',' || m.wof_status          -- Write Off Status
            || ',' || m.wof_status_date     -- Write Off Status Date
            || ',' || m.wof_original_amt    -- Write Off Original Amount as at Load Date            
            ;
                            
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => l_session_file_id
        );
        
        if mod(l_record_count, 100) = 0 then                
            prc_api_stat_pkg.log_current (
                i_current_count     => l_record_count
              , i_excepted_count    => 0
            );
        end if;
        
    end loop;       

    prc_api_stat_pkg.log_current(
        i_current_count     => l_record_count
      , i_excepted_count    => 0
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
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
end generate_cbc_report;

end cst_cab_process_pkg;
/
