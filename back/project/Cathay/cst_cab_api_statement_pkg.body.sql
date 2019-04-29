create or replace package body cst_cab_api_statement_pkg as
/************************************************************
* Credit Statement report for Cathay bank <br />
* $LastChangedDate::  01.08.2018#$ <br />
* Module: cst_cab_api_statement_pkg <br />
* @headcom
************************************************************/
    CRLF                constant  com_api_type_pkg.t_name := chr(13) || chr(10);
    
procedure create_statement(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date
  , i_account_number        in      com_api_type_pkg.t_account_number
  , i_card_number           in      com_api_type_pkg.t_card_number      default null
)
is
    LOG_PREFIX                      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_statement: ';
    l_session_file_id               com_api_type_pkg.t_long_id;
    l_line                          com_api_type_pkg.t_text;     
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_account_id                    com_api_type_pkg.t_medium_id;
    l_dpp_account_id                com_api_type_pkg.t_medium_id;
    l_product_id                    com_api_type_pkg.t_medium_id;
    l_tad_amount                    com_api_type_pkg.t_money;
    l_mad_amount                    com_api_type_pkg.t_money;
    l_ownfund_amt                   com_api_type_pkg.t_money;
    l_ownfund_amt_str               com_api_type_pkg.t_name;
    l_tad_amount_str                com_api_type_pkg.t_name;
    l_mad_amount_str                com_api_type_pkg.t_name;    
    l_crd_limit_str                 com_api_type_pkg.t_name;
    l_stm_delivery_method           com_api_type_pkg.t_name;
    l_dpp_interest_rate             com_api_type_pkg.t_name;
    l_acct_currency                 com_api_type_pkg.t_curr_code;
    l_crd_limit_balance             com_api_type_pkg.t_amount_rec;
    l_total_dest_amount             com_api_type_pkg.t_money := 0;
    l_invoice_paid_amount           com_api_type_pkg.t_money := 0;
    l_sum_new_debts                 com_api_type_pkg.t_money := 0;
    l_due_date                      date;
    l_customer_id                   com_api_type_pkg.t_medium_id;
    l_customer_name                 com_api_type_pkg.t_name;
    l_customer_number               com_api_type_pkg.t_name;
    l_cust_address                  com_api_type_pkg.t_text;
    l_stmt_address                  com_api_type_pkg.t_address_rec;
    l_cust_phone                    com_api_type_pkg.t_name;
    l_cust_email                    com_api_type_pkg.t_name;
    l_acct_product                  com_api_type_pkg.t_name;
    l_debit_acct_num                com_api_type_pkg.t_account_number;
    l_file_name                     com_api_type_pkg.t_name;
    l_prev_invoice                  crd_api_type_pkg.t_invoice_rec;
    l_invoice_id                    com_api_type_pkg.t_medium_id;
    l_current_points                com_api_type_pkg.t_medium_id := 0;
    l_earned_points                 com_api_type_pkg.t_medium_id := 0;
    l_expire_points                 com_api_type_pkg.t_medium_id := 0;
    l_open_points                   com_api_type_pkg.t_medium_id := 0;
    l_redeem_points                 com_api_type_pkg.t_medium_id := 0;
    l_sum_open_points               com_api_type_pkg.t_medium_id := 0;
    l_sum_earned_points             com_api_type_pkg.t_medium_id := 0;
    l_sum_current_points            com_api_type_pkg.t_medium_id := 0;
    l_sum_expire_points             com_api_type_pkg.t_medium_id := 0;
    l_final_expire_date             date := trunc(get_sysdate) + 365;
    l_last_payment_date             date;
    l_expire_date                   date;
    l_start_date                    date;
    l_invoice_date                  date;
    l_prev_inv_date                 date;
    l_next_inv_date                 date;
    
begin
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Process Begin'
    ); 
    
    l_account_id := acc_api_account_pkg.get_account_id(i_account_number => i_account_number);
    
    l_product_id := prd_api_product_pkg.get_product_id(
                        i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                      , i_object_id     => l_account_id
                      , i_inst_id       => i_inst_id
                    ); 
                    
    l_invoice_date := trunc(i_end_date);    
    
    if l_account_id is null then
        trc_log_pkg.error(
            i_text        => LOG_PREFIX || 'l_account_id is null, i_account_number=' || i_account_number
        );
    else    
        -- Get current invoice and account information
        begin
            select i.total_amount_due
                 , i.min_amount_due
                 , i.due_date     
                 , case c.entity_type
                    when com_api_const_pkg.ENTITY_TYPE_PERSON -- 'ENTTPERS'
                    then com_ui_person_pkg.get_surname(c.object_id, null) || ' ' ||com_ui_person_pkg.get_first_name(c.object_id, null)
                    when com_api_const_pkg.ENTITY_TYPE_COMPANY -- 'ENTTCOMP'
                    then get_text ('COM_COMPANY', 'DESCRIPTION', c.object_id, null)
                   end as customer_name
                 , c.customer_number
                 , (select com_api_address_pkg.get_address_string(i_address_id => a.id) 
                      from com_address a
                         , com_address_object o
                     where a.id = o.address_id
                       and o.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
                       and o.address_type(+) = com_api_const_pkg.ADDRESS_TYPE_HOME   --'ADTPHOME'
                       and o.object_id(+) = c.id
                       and rownum = 1
                   ) as cust_address
                 , (select cd.commun_address
                      from com_contact_data cd
                         , com_contact_object co
                     where cd.contact_id = co.contact_id
                       and cd.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE --'CMNM0001'
                       and co.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY         --'CNTTPRMC'
                       and co.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER                        
                       and co.object_id = c.id
                       and rownum = 1
                   ) as cust_phone
                 , (select cd.commun_address
                      from com_contact_data cd
                         , com_contact_object co
                     where cd.contact_id = co.contact_id
                       and cd.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_EMAIL --'CMNM0002'
                       and co.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY        --'CNTTPRMC'
                       and co.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                       and co.object_id = c.id
                       and rownum = 1
                   ) as cust_email
                 , i.id as invoice_id
                 , a.split_hash
                 , a.currency
                 , a.customer_id
                 , i.own_funds
              into l_tad_amount
                 , l_mad_amount
                 , l_due_date
                 , l_customer_name
                 , l_customer_number
                 , l_cust_address
                 , l_cust_phone
                 , l_cust_email
                 , l_invoice_id
                 , l_split_hash
                 , l_acct_currency
                 , l_customer_id
                 , l_ownfund_amt
              from crd_invoice i
                 , acc_account a
                 , prd_customer c
             where a.id = i.account_id
               and c.id = a.customer_id
               and a.split_hash = i.split_hash
               and a.split_hash = c.split_hash
               and a.split_hash in (select split_hash from com_api_split_map_vw)
               and i.account_id = l_account_id
               and a.inst_id = i_inst_id
               and trunc(i.invoice_date) = l_invoice_date           
               ;
        exception
            when no_data_found then
                trc_log_pkg.debug (
                    i_text  => LOG_PREFIX || 'Invoice not found'
                );
        end;                        
        
        if l_invoice_id is not null then
        
            --Get statement delivery method
            select nvl((select distinct com_api_dictionary_pkg.get_article_text(first_value(attr_value) over (order by start_date desc))
                          from prd_attribute_value
                         where attr_id = (select id
                                            from prd_attribute
                                           where attr_name = 'CRD_INVOICING_DELIVERY_STATEMENT_METHOD')
                           and entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT -- 'ENTTACCT'
                           and object_id = l_account_id
                           and split_hash = l_split_hash
                           and start_date < get_sysdate
                           and (end_date > get_sysdate or end_date is null)
                        )                          
                     , (select distinct com_api_dictionary_pkg.get_article_text(first_value(attr_value) over (order by start_date desc))
                          from prd_attribute_value
                         where attr_id = (select id
                                            from prd_attribute
                                           where attr_name = 'CRD_INVOICING_DELIVERY_STATEMENT_METHOD')
                           and entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT -- 'ENTTPROD'
                           and object_id in (select id
                                               from prd_product
                                              start with id = l_product_id
                                              connect by id = prior parent_id
                                            )
                           and start_date < get_sysdate
                           and (end_date > get_sysdate or end_date is null)
                        )
                     ) 
              into l_stm_delivery_method
              from dual;
            
            --Get statement delivery address
            l_stmt_address := 
                com_api_address_pkg.get_address(
                    i_object_id     => l_customer_id
                  , i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER       --'ENTTCUST'
                  , i_address_type  => com_api_const_pkg.ADDRESS_TYPE_STMT_DELIVERY --'ADTPSTDL'
                  , i_mask_error    => com_api_const_pkg.TRUE
                );            
            
            l_acct_product := get_text('PRD_PRODUCT'
                                     , 'LABEL'
                                     , l_product_id 
                                     , null
                                    );
                              
            l_crd_limit_balance := acc_api_balance_pkg.get_balance_amount (
                                       i_account_id     => l_account_id
                                     , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED --'BLTP1001'
                                     , i_mask_error     => com_api_type_pkg.TRUE
                                     , i_lock_balance   => com_api_type_pkg.FALSE
                                   );    
                      
            l_crd_limit_str :=  com_api_currency_pkg.get_amount_str(
                                    i_amount            => l_crd_limit_balance.amount
                                  , i_curr_code         => l_crd_limit_balance.currency
                                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                                  , i_mask_error        => com_api_type_pkg.TRUE
                                );
                                
            l_tad_amount_str := com_api_currency_pkg.get_amount_str(
                                    i_amount            => l_tad_amount
                                  , i_curr_code         => l_acct_currency
                                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                                  , i_mask_error        => com_api_type_pkg.TRUE
                                );
                                
            l_mad_amount_str := com_api_currency_pkg.get_amount_str(
                                    i_amount            => l_mad_amount
                                  , i_curr_code         => l_acct_currency
                                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                                  , i_mask_error        => com_api_type_pkg.TRUE
                                );            
            if l_tad_amount = 0 and l_ownfund_amt > 0 then
                l_ownfund_amt_str := com_api_currency_pkg.get_amount_str(
                                        i_amount            => l_ownfund_amt
                                      , i_curr_code         => l_acct_currency
                                      , i_mask_curr_code    => com_api_type_pkg.TRUE
                                      , i_mask_error        => com_api_type_pkg.TRUE
                                    );
            end if;
                            
            -- Get previous invoice information
            begin
                select i1.id
                     , i1.account_id
                     , i1.serial_number
                     , i1.invoice_type
                     , i1.exceed_limit
                     , i1.total_amount_due
                     , i1.own_funds
                     , i1.min_amount_due
                     , i1.invoice_date
                     , i1.grace_date
                     , i1.due_date
                     , i1.penalty_date
                     , i1.aging_period
                     , i1.is_tad_paid
                     , i1.is_mad_paid
                     , i1.inst_id
                     , i1.agent_id
                     , i1.split_hash
                     , i1.overdue_date
                     , i1.start_date
                  into l_prev_invoice
                  from crd_invoice_vw i1
                     , (select a.id
                             , lag(a.id) over (order by a.invoice_date, a.id) lag_id
                          from crd_invoice_vw a
                         where a.account_id = l_account_id
                       ) i2
                 where i1.id = i2.lag_id
                   and i2.id = l_invoice_id;

            exception
                when no_data_found then
                    trc_log_pkg.debug (
                        i_text  => LOG_PREFIX || 'Previous invoice not found'
                      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
                      , i_object_id   => l_invoice_id
                    );
            end;
                                
            -- Calculate start date
            if l_prev_invoice.id is null then
                begin
                    select o.start_date
                      into l_start_date
                      from prd_service_object o
                         , prd_service s
                     where o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       and o.object_id = l_account_id
                       and o.split_hash = l_split_hash
                       and s.id = o.service_id
                       and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error (
                            i_error       => 'ACCOUNT_SERVICE_NOT_FOUND'
                          , i_env_param1  => l_account_id
                          , i_env_param2  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                        );
                end;
                if l_start_date < add_months(l_invoice_date, -1) then
                    l_start_date := add_months(l_invoice_date, -1);
                end if;
            else
                l_start_date := l_prev_invoice.invoice_date;
            end if;

            trc_log_pkg.debug (
                i_text        => LOG_PREFIX || 'Calculated start date: [#1]'
              , i_env_param1  => to_char(l_start_date, 'dd/mm/yyyy')
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
              , i_object_id   => l_invoice_id
            );
        
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE --'CYTP1001'
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => l_account_id
              , i_split_hash        => l_split_hash
              , i_add_counter       => com_api_type_pkg.FALSE
              , o_prev_date         => l_prev_inv_date
              , o_next_date         => l_next_inv_date
            );
                        
            -- Get loyalty points
            begin
                for i in (
                    select a2.id as loyalty_account_id
                      from acc_account a1
                         , acc_account a2
                     where a1.contract_id = a2.contract_id
                       and a1.split_hash = a2.split_hash
                       and a1.split_hash = l_split_hash
                       and a1.id = l_account_id
                       and a2.account_type = cst_cab_api_const_pkg.ACCT_TYPE_LOYALTY --'ACTPLOYT'
                       and a2.status = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE --'ACSTACTV'
                ) loop
                    
                    select nvl(sum(balance_impact * amount), 0)
                      into l_earned_points
                      from acc_entry
                     where account_id = i.loyalty_account_id
                       and split_hash = l_split_hash
                       and id >= com_api_id_pkg.get_from_id(l_start_date)
                       and id >= com_api_id_pkg.get_from_id(to_date('01.04.2019', 'dd.mm.yyyy')) ----to exclude the migration points
                       and posting_date >= l_start_date
                       and posting_date < l_invoice_date
                       and balance_type = cst_cab_api_const_pkg.BALANCE_TYPE_LOYALTY --'BLTP5001'
                       ;
                    
                    select nvl(sum(balance_impact * amount), 0)
                      into l_current_points
                      from acc_entry
                     where account_id = i.loyalty_account_id
                       and split_hash = l_split_hash
                       and id >= com_api_id_pkg.get_from_id(l_invoice_date)
                       and posting_date >= l_invoice_date
                       and balance_type = cst_cab_api_const_pkg.BALANCE_TYPE_LOYALTY --'BLTP5001'
                       ;

                    select l.balance - l_current_points
                      into l_current_points
                      from acc_balance l
                     where l.balance_type = cst_cab_api_const_pkg.BALANCE_TYPE_LOYALTY --'BLTP5001'
                       and l.account_id = i.loyalty_account_id
                       and split_hash = l_split_hash
                       ;

                    --Get total points will be expired in next invoice date
                    select nvl(sum(b.amount - b.spent_amount), 0)
                      into l_expire_points
                      from lty_bonus b
                     where b.expire_date >= get_sysdate
                       and b.expire_date <= l_next_inv_date
                       and b.status = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE
                       and b.account_id = i.loyalty_account_id
                       and split_hash = l_split_hash
                       ;
                       
                    --select min(b.expire_date)
                    --  into l_expire_date
                    --  from lty_bonus b
                    -- where b.status = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE
                    --   and b.account_id = i.loyalty_account_id;
                    
                    l_expire_date := 
                        fcl_api_cycle_pkg.calc_next_date(
                            i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE --'CYTP1001'
                          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                          , i_object_id         => l_account_id
                          , i_split_hash        => l_split_hash
                          , i_start_date        => l_invoice_date
                          , i_inst_id           => i_inst_id
                          , i_product_id        => l_product_id
                        );
                       
                    l_open_points := l_current_points - l_earned_points;
                    
                    l_sum_open_points       := l_sum_open_points + l_open_points;
                    l_sum_earned_points     := l_sum_earned_points + l_earned_points;
                    l_sum_current_points    := l_sum_current_points + l_current_points;
                    l_sum_expire_points     := l_sum_expire_points + l_expire_points;
                    l_final_expire_date     := case when l_expire_date < l_final_expire_date
                                                    then l_expire_date
                                                    else l_final_expire_date
                                               end;                
                end loop;
            exception
                when no_data_found then
                    trc_log_pkg.debug(
                        i_text          => LOG_PREFIX || 'Unable to find loyalty account'
                      , i_entity_type   => crd_api_const_pkg.ENTITY_TYPE_INVOICE
                      , i_object_id     => l_invoice_id
                    );
            end;
            
            --Get debit account:
            begin                
                select get_char_value (b.data_type, nvl (a.param_value, c.default_value))   
                  into l_debit_acct_num           
                  from pmo_order_data         a
                     , pmo_parameter          b
                     , pmo_purpose_parameter  c
                     , pmo_order              d
                     , pmo_schedule           s
                 where a.param_id = b.id
                   and c.param_id = b.id
                   and a.order_id = d.id
                   and s.order_id = d.id
                   and d.purpose_id = c.purpose_id
                   and b.param_name = 'PMT_ACCOUNT'
                   and b.data_type = 'DTTPCHAR'
                   and d.is_template = com_api_const_pkg.TRUE
                   and d.templ_status = pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD  -- 'POTSVALD'
                   and s.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   and s.object_id = l_account_id
                   and d.customer_id = l_customer_id
                   and d.split_hash = l_split_hash
                   ;
            exception
                when no_data_found then
                    trc_log_pkg.debug(
                        i_text          => LOG_PREFIX || 'Unable to find Debit account number'
                      , i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
                      , i_object_id     => l_customer_id
                    );    
                when too_many_rows then
                    trc_log_pkg.error(
                        i_text          => LOG_PREFIX || 'Too many Debit account number!'
                      , i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
                      , i_object_id     => l_customer_id
                    );                              
            end;                               
            
            --Get sum of actual payment amount for current invoice
            select nvl(sum(dp.pay_amount), 0)
                 , nvl(max(cp.posting_date), l_invoice_date)
              into l_invoice_paid_amount
                 , l_last_payment_date
              from crd_debt_payment dp
                 , crd_payment cp
             where cp.id = dp.pay_id
               and cp.split_hash = dp.split_hash
               and cp.split_hash = l_split_hash
               and exists (select 1
                             from crd_invoice_payment ip                    
                            where cp.id = ip.pay_id                  
                              and ip.invoice_id = l_invoice_id
                              and ip.split_hash = l_split_hash
                           );                            
                            
            --Get sum amount of new debts (without interest) in current invoice
            select nvl(sum(cd.amount), 0)
              into l_sum_new_debts                                       
              from crd_debt cd
             where exists (select 1
                             from crd_invoice_debt cid
                            where cid.debt_id = cd.id
                              and cid.split_hash = cd.split_hash
                              and cid.is_new = com_api_type_pkg.TRUE
                              and cid.invoice_id = l_invoice_id
                              and cid.split_hash = l_split_hash
                           );
                       
            l_file_name := 'Credit_statement_' || i_account_number || '_' || to_char(sysdate, 'ddmmyyyyhh24miss') || '.txt';
            
            prc_api_file_pkg.open_file(
                o_sess_file_id  => l_session_file_id
              , i_file_name     => l_file_name
              , i_file_type     => 'FLTP1001'
              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT --FLPSOUTG
              , i_object_id     => l_invoice_id
              , i_entity_type   => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
            );
            
            l_line :=  'Statement Delivery Method:' || l_stm_delivery_method
            || CRLF || 'Payment Slip:'              || l_acct_product
            || CRLF || 'Statement Date:'            || to_char(l_invoice_date, 'dd Mon yyyy')
            || CRLF || 'Credit Limit:USD '          || l_crd_limit_str
            || CRLF || 'Customer Name:'             || l_customer_name
            || CRLF || 'Customer Id:'               || l_customer_number
            || CRLF || 'Statement Delivery Address:'|| replace(replace(l_stmt_address.street, CHR(13)), CHR(10))
            || CRLF || 'Customer Billing Address:#' || replace(replace(l_cust_address, CHR(13)), CHR(10))
            || CRLF || 'Customer Phone:'            || l_cust_phone
            || CRLF || 'Customer E-mail:'           || l_cust_email
            || CRLF || 'Account Number:'            || i_account_number
            || CRLF || 'TAD:USD '                   || case when l_tad_amount = 0 and l_ownfund_amt > 0
                                                            then '-' || l_ownfund_amt_str
                                                            else l_tad_amount_str
                                                       end
            || CRLF || 'MAD:USD '                   || l_mad_amount_str
            || CRLF || 'Payment Due Date:'          || to_char(l_due_date, 'dd Mon yyyy')
            || CRLF || 'Debit Account Number:'      || l_debit_acct_num
            || CRLF || 'Previous Account Balance:USD '  || nvl( com_api_currency_pkg.get_amount_str(
                                                                    i_amount            => l_prev_invoice.total_amount_due - l_prev_invoice.own_funds
                                                                  , i_curr_code         => l_acct_currency
                                                                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                                                                  , i_mask_error        => com_api_type_pkg.TRUE
                                                                )
                                                                , 0
                                                               )
            ;
                                
            prc_api_file_pkg.put_line(
                i_raw_data      => l_line
              , i_sess_file_id  => l_session_file_id
            );
            
            l_line := null;
            
            for m in (
                select n.card_number
                     , h.cardholder_name
                     , row_number() over(order by category desc, reg_date asc) as rn
                  from acc_account a
                     , acc_account_object o
                     , iss_card i
                     , iss_card_number n
                     , iss_cardholder h
                 where i.id = n.card_id
                   and a.id = o.account_id
                   and h.id = i.cardholder_id
                   and o.object_id = i.id
                   and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                   and o.account_id = l_account_id
                   and a.split_hash = o.split_hash
                   and a.split_hash = i.split_hash
                   and a.split_hash = l_split_hash                   
                   and reverse(n.card_number) = reverse(nvl(i_card_number, n.card_number)) 
                   and (exists(--check if card exists in debts
                                select 1
                                  from crd_debt cd
                                     , opr_operation op
                                     , opr_participant pa
                                     , opr_card oc
                                     , crd_invoice_debt cid
                                where cd.oper_id = op.id
                                  and pa.oper_id = op.id
                                  and cid.debt_id = cd.id
                                  and pa.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                                  and oc.oper_id = pa.oper_id
                                  and oc.participant_type = pa.participant_type
                                  and oc.split_hash = pa.split_hash
                                  and cid.split_hash = pa.split_hash
                                  and cd.split_hash = pa.split_hash
                                  and pa.split_hash = l_split_hash
                                  and cid.invoice_id = l_invoice_id
                                  and reverse(oc.card_number) = reverse(n.card_number)
                               )
                        or
                        exists(--check if card exists in payments
                                select 1
                                  from crd_payment cp
                                     , opr_operation op
                                     , opr_participant pa
                                     , opr_card oc
                                     , crd_invoice_payment cip
                                where cp.oper_id = op.id
                                  and pa.oper_id = op.id
                                  and cip.pay_id = cp.id
                                  and pa.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                                  and oc.oper_id = pa.oper_id
                                  and oc.participant_type = pa.participant_type
                                  and oc.split_hash = pa.split_hash
                                  and cip.split_hash = pa.split_hash
                                  and cp.split_hash = pa.split_hash
                                  and pa.split_hash = l_split_hash
                                  and cip.invoice_id = l_invoice_id
                                  and reverse(oc.card_number) = reverse(n.card_number)
                               )
                        )
            ) loop 
            
                --Get DPP account linked to card
                begin           
                    select ao.account_id
                      into l_dpp_account_id
                      from acc_account_object ao
                         , iss_card_number cn
                         , acc_account aa
                     where ao.object_id = cn.card_id
                       and ao.account_id = aa.id
                       and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'     
                       and aa.account_type = cst_cab_api_const_pkg.ACCT_TYPE_DPP_INSTALMENT  --'ACTP1500'
                       and aa.split_hash = ao.split_hash
                       and aa.split_hash = l_split_hash
                       and reverse(cn.card_number) = reverse(m.card_number);           
                exception
                    when no_data_found then
                        trc_log_pkg.debug (
                            i_text  => LOG_PREFIX || 'DPP account not found'
                        );
                    when too_many_rows then
                        trc_log_pkg.debug (
                            i_text  => LOG_PREFIX || 'Many DPP accounts are linked to one card number = ' || m.card_number
                        );
                        com_api_error_pkg.raise_error(
                            i_error         => 'TOO_MANY_RECORDS_FOUND'
                        );
                end;
            
                l_line :=  'Card Holder Name:'      || m.cardholder_name
                || CRLF || 'Card Holder Number:'    ||  substr(m.card_number, 1, 4) || ' ' ||    
                                                        substr(m.card_number, 5, 4) || ' ' ||
                                                        substr(m.card_number, 9, 4) || ' ' ||
                                                        substr(m.card_number, 13)
                ;                                
                prc_api_file_pkg.put_line(
                    i_raw_data      => l_line
                  , i_sess_file_id  => l_session_file_id
                );
                l_line := null;
                
                for n in (
                    --New debts in current invoice (belong to card)
                    select op.oper_date
                         , cd.posting_date
                         , case when cd.fee_type is not null then 'Fee Charge'
                                else op.merchant_name
                           end as merchant_name
                         , com_api_country_pkg.get_country_full_name(
                               i_code => op.merchant_country
                           ) as country_name
                         , com_api_country_pkg.get_country_name(
                               i_code        => op.merchant_country
                             , i_raise_error => com_api_type_pkg.FALSE
                           ) as country_code
                         , com_api_currency_pkg.get_currency_name(op.oper_currency) as currency_code
                         , com_api_currency_pkg.get_amount_str(
                                    i_amount            => op.oper_amount
                                  , i_curr_code         => op.oper_currency
                                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                                  , i_mask_error        => com_api_type_pkg.TRUE
                            ) as source_amount
                         , com_api_currency_pkg.get_amount_str(
                                    i_amount            => cd.amount
                                  , i_curr_code         => cd.currency
                                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                                  , i_mask_error        => com_api_type_pkg.TRUE
                            ) as destination_amount
                         , cd.amount as t_amount
                         , op.id as oper_id
                      from opr_operation op
                         , opr_participant pa
                         , opr_card oc
                         , crd_debt cd     
                         , crd_invoice_debt cid
                     where op.id = pa.oper_id
                       and pa.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                       and pa.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD --'CITPCARD'
                       and oc.oper_id = pa.oper_id
                       and oc.participant_type = pa.participant_type
                       and oc.split_hash = pa.split_hash
                       and cd.split_hash = pa.split_hash
                       and cd.split_hash = cid.split_hash
                       and cd.split_hash = l_split_hash
                       and reverse(oc.card_number) = reverse(m.card_number) -- support indexes
                       and op.oper_type not in (dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE   -- 'OPTP1500'
                                              , dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER   -- 'OPTP1501'
                                              )
                       and op.id = cd.oper_id
                       and cid.debt_id = cd.id          
                       and cid.is_new = com_api_type_pkg.TRUE           
                       and cid.invoice_id = l_invoice_id
                  group by op.oper_date
                         , cd.posting_date
                         , op.merchant_name
                         , op.merchant_country
                         , op.oper_currency
                         , op.oper_amount
                         , cd.amount
                         , cd.currency
                         , cd.fee_type
                         , op.id
                    
                union all

                    --New debts in current invoice (belong to account)
                    select op.oper_date
                         , cd.posting_date
                         , case when cd.fee_type is not null then 'Fee Charge'
                                else op.merchant_name
                           end as merchant_name
                         , com_api_country_pkg.get_country_full_name(
                               i_code => op.merchant_country
                           ) as country_name
                         , com_api_country_pkg.get_country_name(
                               i_code        => op.merchant_country
                             , i_raise_error => com_api_type_pkg.FALSE
                           ) as country_code
                         , com_api_currency_pkg.get_currency_name(op.oper_currency) as currency_code
                         , com_api_currency_pkg.get_amount_str(
                                    i_amount            => op.oper_amount
                                  , i_curr_code         => op.oper_currency
                                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                                  , i_mask_error        => com_api_type_pkg.TRUE
                            ) as source_amount
                         , com_api_currency_pkg.get_amount_str(
                                i_amount            => cd.amount
                                  , i_curr_code         => cd.currency
                                  , i_mask_curr_code    => com_api_type_pkg.TRUE
                                  , i_mask_error        => com_api_type_pkg.TRUE
                            ) as destination_amount
                         , cd.amount as t_amount
                         , op.id as oper_id
                      from opr_operation op
                         , opr_participant pa
                         , crd_debt cd     
                         , crd_invoice_debt cid
                     where op.id = pa.oper_id
                       and pa.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                       and pa.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT --'CITPACCT'
                       and op.oper_type not in (dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE   -- 'OPTP1500'
                                              , dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER   -- 'OPTP1501'
                                              )
                       and op.id = cd.oper_id
                       and cid.debt_id = cd.id          
                       and cid.is_new = com_api_type_pkg.TRUE           
                       and cd.split_hash = pa.split_hash
                       and cd.split_hash = cid.split_hash
                       and cd.split_hash = l_split_hash         
                       and cid.invoice_id = l_invoice_id
                       and pa.account_id = l_account_id
                       and m.rn = 1
                  group by op.oper_date
                         , cd.posting_date
                         , op.merchant_name
                         , op.merchant_country
                         , op.oper_currency
                         , op.oper_amount
                         , cd.amount
                         , cd.currency
                         , cd.fee_type                         
                         , op.id
                         
                union all

                    --Sum interest amount of all debts
                    select l_invoice_date as oper_date
                         , l_invoice_date as posting_date
                         , 'Interest Charge' as merchant_name
                         , null as country_name
                         , null as country_code
                         , com_api_currency_pkg.get_currency_name(l_acct_currency) as currency_code
                         , com_api_currency_pkg.get_amount_str(
                                i_amount            => (l_tad_amount - l_prev_invoice.total_amount_due - l_sum_new_debts + l_invoice_paid_amount)
                              , i_curr_code         => l_acct_currency
                              , i_mask_curr_code    => com_api_type_pkg.TRUE
                              , i_mask_error        => com_api_type_pkg.TRUE
                           ) as source_amount
                         , com_api_currency_pkg.get_amount_str(
                                i_amount            => (l_tad_amount - l_prev_invoice.total_amount_due - l_sum_new_debts + l_invoice_paid_amount)
                              , i_curr_code         => l_acct_currency
                              , i_mask_curr_code    => com_api_type_pkg.TRUE
                              , i_mask_error        => com_api_type_pkg.TRUE
                           ) as destination_amount
                         , (l_tad_amount - l_prev_invoice.total_amount_due - l_sum_new_debts + l_invoice_paid_amount) as t_amount
                         , null as oper_id
                      from dual
                     where (l_tad_amount - l_prev_invoice.total_amount_due - l_sum_new_debts + l_invoice_paid_amount) > 0   
                       and m.rn = 1     
                 
                union all

                    --New payment operations in current invoice
                    select op.oper_date as oper_date
                         , cp.posting_date as posting_date
                         , op.merchant_name as merchant_name
                         , com_api_country_pkg.get_country_full_name(
                               i_code => op.merchant_country
                           ) as country_name
                         , com_api_country_pkg.get_country_name(
                               i_code        => op.merchant_country
                             , i_raise_error => com_api_type_pkg.FALSE
                           ) as country_code
                         , com_api_currency_pkg.get_currency_name(op.oper_currency) as currency_code
                         , '-' ||
                            com_api_currency_pkg.get_amount_str(
                                i_amount            => op.oper_amount
                              , i_curr_code         => op.oper_currency
                              , i_mask_curr_code    => com_api_type_pkg.TRUE
                              , i_mask_error        => com_api_type_pkg.TRUE
                            ) as source_amount
                         , '-' ||
                            com_api_currency_pkg.get_amount_str(
                                i_amount            => cp.amount
                              , i_curr_code         => cp.currency
                              , i_mask_curr_code    => com_api_type_pkg.TRUE
                              , i_mask_error        => com_api_type_pkg.TRUE
                            ) as destination_amount
                         , - cp.amount as t_amount
                         , op.id as oper_id
                      from crd_payment cp
                         , crd_invoice_payment cip
                         , opr_operation op
                     where cp.id = cip.pay_id
                       and op.id = cp.oper_id
                       and cip.split_hash = cp.split_hash
                       and cip.split_hash = l_split_hash
                       and cip.invoice_id = l_invoice_id
                       and cip.is_new = com_api_type_pkg.TRUE
                       and exists (select 1
                                     from opr_card oc
                                    where oc.oper_id = cp.oper_id
                                      and oc.split_hash = l_split_hash
                                      and reverse(oc.card_number) = reverse(m.card_number) -- support indexes
                                   )
                      
                  order by oper_date
                         , posting_date

                ) loop
                    l_line :=  'NTD:Trxn_Date='         || to_char(n.oper_date, 'dd Mon')
                            || ';Posting_Date='         || to_char(n.posting_date, 'dd Mon')
                            || ';Merchant_Name='        || trim(n.merchant_name)
                            || ';Country_Name='         || n.country_name
                            || ';Country_Code='         || n.country_code
                            || ';Currency_Code='        || n.currency_code
                            || ';Source_Amount='        || n.source_amount
                            || ';Destination_Amount='   || n.destination_amount
                            ;
                    prc_api_file_pkg.put_line(
                        i_raw_data      => l_line
                      , i_sess_file_id  => l_session_file_id
                    );
                    l_line := null;   
                    l_total_dest_amount := l_total_dest_amount + n.t_amount;                                    
                end loop; 
                
                for d1 in(
                    select dp.oper_date
                         , dp.posting_date
                         , (select merchant_name
                              from opr_operation
                             where id = dp.oper_id
                           ) as merchant_name
                         , dp.instalment_total as tenor
                         , com_api_currency_pkg.get_amount_str(
                               i_amount            => dp.oper_amount
                             , i_curr_code         => dp.oper_currency
                             , i_mask_curr_code    => com_api_type_pkg.TRUE
                             , i_mask_error        => com_api_type_pkg.TRUE
                           ) as oper_amount
                      from dpp_payment_plan dp
                         , dpp_instalment di
                         , opr_operation op
                         , opr_participant pa
                         , opr_card oc
                         , crd_debt cd
                     where di.dpp_id = dp.id
                       and dp.account_id = l_dpp_account_id
                       and op.id = dp.oper_id
                       and op.id = pa.oper_id
                       and op.id = cd.oper_id
                       and pa.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                       and oc.oper_id = pa.oper_id
                       and oc.participant_type = pa.participant_type
                       and oc.split_hash = pa.split_hash
                       and cd.split_hash = pa.split_hash
                       and cd.split_hash = dp.split_hash
                       and cd.split_hash = di.split_hash
                       and cd.split_hash = l_split_hash
                       and reverse(oc.card_number) = reverse(m.card_number) -- support indexes                       
                       and op.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE --'OPTP1500'
                       and di.instalment_number = 1
                       and di.instalment_date <= l_invoice_date
                       and di.instalment_date > nvl(l_prev_invoice.invoice_date, di.instalment_date - 1)             
                ) loop
                    l_line :=  'DPP:Trxn_Date='     || to_char(d1.oper_date, 'dd Mon')
                            || ';Posting_Date='     || to_char(d1.posting_date, 'dd Mon')
                            || ';FLAG=APR'          -- DPP was approved
                            || ';Merchant_Name='    || d1.merchant_name
                            || ';Installment_No='     
                            || ';Tenor='            || d1.tenor
                            || ';Amount='           || d1.oper_amount
                            ;                            
                    prc_api_file_pkg.put_line(
                        i_raw_data      => l_line
                      , i_sess_file_id  => l_session_file_id
                    );
                    l_line := null; 
                    
                end loop;
                
                for d2 in(
                    select dp.oper_date
                         , di.instalment_date
                         , (select merchant_name
                              from opr_operation
                             where id = dp.oper_id
                           ) as merchant_name
                         , dp.instalment_total as tenor
                         , di.instalment_number
                         , com_api_currency_pkg.get_amount_str(
                               i_amount            => di.interest_amount
                             , i_curr_code         => dp.oper_currency
                             , i_mask_curr_code    => com_api_type_pkg.TRUE
                             , i_mask_error        => com_api_type_pkg.TRUE
                           ) as dpp_interest_amount
                         , com_api_currency_pkg.get_amount_str(
                               i_amount            => di.instalment_amount - di.interest_amount
                             , i_curr_code         => dp.oper_currency
                             , i_mask_curr_code    => com_api_type_pkg.TRUE
                             , i_mask_error        => com_api_type_pkg.TRUE
                           ) as dpp_amount  
                         , di.interest_amount as o_dpp_interest_amount
                         , (di.instalment_amount - di.interest_amount) as o_dpp_amount
                      from dpp_payment_plan dp
                         , dpp_instalment di
                         , opr_operation op
                         , opr_participant pa
                         , opr_card oc
                         , crd_debt cd
                     where di.dpp_id = dp.id
                       and dp.account_id = l_dpp_account_id
                       and op.id = dp.oper_id
                       and op.id = pa.oper_id
                       and op.id = cd.oper_id
                       and pa.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                       and oc.oper_id = pa.oper_id
                       and oc.participant_type = pa.participant_type
                       and oc.split_hash = pa.split_hash
                       and cd.split_hash = pa.split_hash
                       and cd.split_hash = dp.split_hash
                       and cd.split_hash = di.split_hash
                       and cd.split_hash = l_split_hash
                       and reverse(oc.card_number) = reverse(m.card_number) -- support indexes                       
                       and op.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE --'OPTP1500'
                       and di.instalment_date <= l_invoice_date
                       and di.instalment_date > nvl(l_prev_invoice.invoice_date, di.instalment_date - 1) 
                       and exists (select 1
                                     from crd_invoice_debt ci
                                    where ci.debt_id in (di.macros_id, di.macros_intr_id)
                                      and ci.invoice_id = l_invoice_id
                                      and ci.split_hash = l_split_hash
                                  )  
                ) loop
                    l_line :=  'DPP:Trxn_Date='     || to_char(d2.oper_date, 'dd Mon')
                            || ';Posting_Date='     || to_char(d2.instalment_date, 'dd Mon')
                            || ';FLAG=INS'          -- DPP Installment
                            || ';Merchant_Name='    || d2.merchant_name
                            || ';Installment_No='   || d2.instalment_number
                            || ';Tenor='            || d2.tenor
                            || ';Amount='           || d2.dpp_amount
                            ;                            
                    prc_api_file_pkg.put_line(
                        i_raw_data      => l_line
                      , i_sess_file_id  => l_session_file_id
                    );
                    l_line := null;
                    
                    l_line :=  'DPP:Trxn_Date='     || to_char(d2.oper_date, 'dd Mon')
                            || ';Posting_Date='     || to_char(d2.instalment_date, 'dd Mon')
                            || ';FLAG=INT'          -- DPP Interest Fee
                            || ';Merchant_Name='    || d2.merchant_name
                            || ';Installment_No='   || d2.instalment_number
                            || ';Tenor='            || d2.tenor
                            || ';Amount='           || d2.dpp_interest_amount
                            ;                            
                    prc_api_file_pkg.put_line(
                        i_raw_data      => l_line
                      , i_sess_file_id  => l_session_file_id
                    );
                    l_line := null;
                    
                    l_total_dest_amount := l_total_dest_amount + d2.o_dpp_amount + d2.o_dpp_interest_amount;

                end loop;                                                
                
                for f in (
                    select op.oper_date
                         , cd.posting_date
                         , op.merchant_name
                         , com_api_currency_pkg.get_amount_str(
                                i_amount            => cd.amount
                              , i_curr_code         => cd.currency
                              , i_mask_curr_code    => com_api_type_pkg.TRUE
                              , i_mask_error        => com_api_type_pkg.TRUE
                           ) as fee_amount
                         , cd.amount as t_amount
                      from opr_operation op
                         , opr_participant pa
                         , opr_card oc
                         , crd_debt cd
                     where op.id = pa.oper_id
                       and op.id = cd.oper_id
                       and pa.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                       and oc.oper_id = pa.oper_id
                       and oc.participant_type = pa.participant_type
                       and oc.split_hash = pa.split_hash
                       and cd.split_hash = pa.split_hash
                       and cd.split_hash = l_split_hash
                       and reverse(oc.card_number) = reverse(m.card_number) -- support indexes                       
                       and op.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE --'OPTP1500'
                       and cd.fee_type = cst_cab_api_const_pkg.FEE_TYPE_DPP_REGISTER --'FETP0425'
                       and cd.posting_date <= l_invoice_date
                       and cd.posting_date > nvl(l_prev_invoice.invoice_date, cd.posting_date - 1)
                       and exists (select 1
                                     from crd_invoice_debt ci
                                    where ci.debt_id = cd.id
                                      and ci.invoice_id = l_invoice_id
                                      and ci.split_hash = l_split_hash
                                  )                       
                ) loop
                    l_line :=  'DPP:Trxn_Date='     || to_char(f.oper_date, 'dd Mon')
                            || ';Posting_Date='     || to_char(f.posting_date, 'dd Mon')
                            || ';FLAG=REG'          -- DPP Registration Fee
                            || ';Merchant_Name='    || f.merchant_name
                            || ';Installment_No='      
                            || ';Tenor='               
                            || ';Amount='           || f.fee_amount
                            ;                            
                    prc_api_file_pkg.put_line(
                        i_raw_data      => l_line
                      , i_sess_file_id  => l_session_file_id
                    );
                    l_line := null;  
                    l_total_dest_amount := l_total_dest_amount + f.t_amount;
                end loop;               
                                
                prc_api_file_pkg.put_line(
                    i_raw_data      => 'Total destination amount:' || 
                                        com_api_currency_pkg.get_amount_str(
                                            i_amount            => l_total_dest_amount
                                          , i_curr_code         => l_acct_currency
                                          , i_mask_curr_code    => com_api_type_pkg.TRUE
                                          , i_mask_error        => com_api_type_pkg.TRUE
                                        )
                  , i_sess_file_id  => l_session_file_id
                );
                l_total_dest_amount := 0;
            end loop;

            l_line :=  'Opening Point:'             || l_sum_open_points
            || CRLF || 'Point Earned:'              || l_sum_earned_points
            || CRLF || 'Point Redeemed:'            || l_redeem_points
            || CRLF || 'Point Total Outstanding:'   || l_sum_current_points
            || CRLF || 'Point Expire:'              || l_sum_expire_points  
            || CRLF || 'Point Expire Date:'         || to_char(l_final_expire_date, 'ddmmyyyy')  
            ;
            prc_api_file_pkg.put_line(
                i_raw_data      => l_line
              , i_sess_file_id  => l_session_file_id
            );
            l_line := null;
                        
            --Unpaid DPP data
            for n in (
                select rownum as rn
                     , n.card_number
                  from acc_account a
                     , acc_account_object o
                     , iss_card i
                     , iss_card_number n
                 where i.id = n.card_id
                   and a.id = o.account_id
                   and o.object_id = i.id
                   and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                   and o.account_id = l_account_id
                   and a.split_hash = o.split_hash
                   and a.split_hash = i.split_hash
                   and a.split_hash = l_split_hash
                   and reverse(n.card_number) = reverse(nvl(i_card_number, n.card_number)) 
            ) loop                 
                
                begin
                    select ao.account_id 
                      into l_dpp_account_id
                      from acc_account_object ao
                         , iss_card_number cn
                         , acc_account aa
                     where ao.object_id = cn.card_id
                       and ao.account_id = aa.id
                       and ao.split_hash = aa.split_hash
                       and ao.split_hash = l_split_hash
                       and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD -- 'ENTTCARD' 
                       and aa.account_type = cst_cab_api_const_pkg.ACCT_TYPE_DPP_INSTALMENT --'ACTP1500'
                       and reverse(cn.card_number) = reverse(n.card_number);
                exception
                    when no_data_found then
                        trc_log_pkg.debug (
                            i_text  => LOG_PREFIX || 'DPP account not found'
                        );
                    when too_many_rows then
                        trc_log_pkg.debug (
                            i_text  => LOG_PREFIX || 'Many DPP accounts are linked to one card number = ' || n.card_number
                        );
                        com_api_error_pkg.raise_error(
                            i_error         => 'TOO_MANY_RECORDS_FOUND'
                        );                        
                end;
                
                begin           
                    select percent_rate
                      into l_dpp_interest_rate
                      from fcl_fee_tier t
                         , (select prd_api_product_pkg.get_attr_value_number(
                                i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                              , i_object_id         => l_dpp_account_id
                              , i_attr_name         => 'DPP_INTEREST_RATE'
                              , i_mask_error        => com_api_type_pkg.TRUE
                            ) as fee_id from dual
                           ) f
                     where t.fee_id = f.fee_id;
                exception
                    when no_data_found then
                        trc_log_pkg.debug (
                            i_text  => LOG_PREFIX || 'DPP interest rate not found'
                        );  
                end;                 
                
                for b in (
                    select dp.oper_date
                         , (select merchant_name
                              from opr_operation
                             where id = dp.oper_id
                           ) as merchant_name
                         , dp.instalment_total as tenor
                         , com_api_currency_pkg.get_amount_str(
                                i_amount            => dp.dpp_amount
                              , i_curr_code         => dp.oper_currency
                              , i_mask_curr_code    => com_api_type_pkg.TRUE
                              , i_mask_error        => com_api_type_pkg.TRUE
                           ) as total_princ_amount                         
                         , com_api_currency_pkg.get_amount_str(
                                i_amount            => sum(di.instalment_amount) - sum(di.interest_amount)
                              , i_curr_code         => dp.oper_currency
                              , i_mask_curr_code    => com_api_type_pkg.TRUE
                              , i_mask_error        => com_api_type_pkg.TRUE
                           ) as unpaid_princ_amount  
                         , min(di.instalment_number) as instalment_no   
                      from dpp_payment_plan dp
                         , dpp_instalment di
                         , opr_operation op
                         , opr_participant pa
                         , opr_card oc
                         , crd_debt cd
                     where di.dpp_id = dp.id
                       and dp.account_id = l_dpp_account_id
                       and op.id = dp.oper_id
                       and op.id = pa.oper_id
                       and op.id = cd.oper_id
                       and pa.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                       and oc.oper_id = pa.oper_id
                       and oc.participant_type = pa.participant_type
                       and oc.split_hash = pa.split_hash
                       and cd.split_hash = pa.split_hash
                       and cd.split_hash = dp.split_hash
                       and cd.split_hash = di.split_hash
                       and cd.split_hash = l_split_hash
                       and reverse(oc.card_number) = reverse(n.card_number) -- support indexes                       
                       and op.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE --'OPTP1500'
                       and (di.instalment_date > l_invoice_date or di.macros_id is null)
                  group by dp.oper_date
                         , dp.oper_id
                         , dp.instalment_total
                         , dp.dpp_amount
                         , dp.interest_amount
                         , dp.oper_currency       
                ) loop                    
                    l_line :=  'UDPP:Seq_No='       || n.rn
                            || ';Trxn_Date='        || to_char(b.oper_date, 'dd-Mon-yyyy')
                            || ';Merchant_Name='    || b.merchant_name
                            || ';Installment_No='   || b.instalment_no 
                            || ';Tenor='            || b.tenor          
                            || ';TTL_Princ_Amt='    || b.total_princ_amount
                            || ';Unpaid_Princ_Amt=' || b.unpaid_princ_amount
                            || ';Annual_Int='       || l_dpp_interest_rate
                            || '%;Card_Number='     || substr(n.card_number, length(n.card_number) - 3, length(n.card_number))
                            ;                            
                    prc_api_file_pkg.put_line(
                        i_raw_data      => l_line
                      , i_sess_file_id  => l_session_file_id
                    );
                    l_line := null; 
                end loop;
                
            end loop;
                    
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );            
                           
        end if;        
                   
    end if;
    
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Process Finished.'
    );  
exception
    when others then
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
end create_statement;    
   
procedure export_credit_statements(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date
  , i_card_number           in      com_api_type_pkg.t_card_number      default null
  , i_account_number        in      com_api_type_pkg.t_account_number   default null
)
is
    LOG_PREFIX             constant com_api_type_pkg.t_name  := lower($$PLSQL_UNIT) || '.export_credit_statements: ';
    l_account_count                 com_api_type_pkg.t_count := 0;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_end_date                      date;
begin
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Process begin'
    ); 
    
    l_inst_id   := nvl(i_inst_id, cst_cab_api_const_pkg.DEFAULT_INST);
    l_end_date  := nvl(i_end_date, get_sysdate);
    
    prc_api_stat_pkg.log_start;        

    select count(distinct a.account_number)
      into l_account_count
      from acc_account a
         , acc_account_object o
         , iss_card_number n
     where a.id = o.account_id
       and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT   --'ACTP0130'
       and a.status <> acc_api_const_pkg.ACCOUNT_STATUS_CLOSED      --'ACSTCLSD'
       and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD       --'ENTTCARD'
       and o.object_id = n.card_id
       and o.split_hash = a.split_hash
       and a.split_hash in (select split_hash from com_api_split_map_vw)             
       and a.inst_id = l_inst_id
       and a.account_number = nvl(i_account_number, a.account_number)
       and reverse(n.card_number) = reverse(nvl(i_card_number, n.card_number))
       and exists (select 1 
                     from crd_invoice 
                    where account_id = a.id
                      and trunc(invoice_date) = trunc(l_end_date)
                   )
       ;                  
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_account_count
    );

    l_account_count := 0;
    
    for i in (
        select distinct a.account_number
          from acc_account a
             , acc_account_object o
             , iss_card_number n
         where a.id = o.account_id
           and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT   --'ACTP0130'
           and a.status <> acc_api_const_pkg.ACCOUNT_STATUS_CLOSED      --'ACSTCLSD'
           and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD       --'ENTTCARD'
           and o.object_id = n.card_id
           and o.split_hash = a.split_hash
           and a.split_hash in (select split_hash from com_api_split_map_vw)             
           and a.inst_id = l_inst_id
           and a.account_number = nvl(i_account_number, a.account_number)
           and reverse(n.card_number) = reverse(nvl(i_card_number, n.card_number))
           and exists (select 1 
                         from crd_invoice 
                        where account_id = a.id
                          and trunc(invoice_date) = trunc(l_end_date)
                      )
    ) loop
        create_statement(
            i_inst_id           => l_inst_id
          , i_end_date          => l_end_date
          , i_account_number    => i.account_number
          , i_card_number       => i_card_number
        );    
        l_account_count := l_account_count + 1;
        
        if mod(l_account_count, 100) = 0 then                
            prc_api_stat_pkg.log_current (
                i_current_count     => l_account_count
              , i_excepted_count    => 0
            );
        end if;         
    end loop;

    prc_api_stat_pkg.log_current (
        i_current_count     => l_account_count
      , i_excepted_count    => 0
    );
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_account_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception    
    when others then

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_account_count
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
end export_credit_statements;

end;
/
