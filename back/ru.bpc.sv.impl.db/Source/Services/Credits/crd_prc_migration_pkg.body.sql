create or replace package body crd_prc_migration_pkg as

    BULK_LIMIT      constant integer := 1000;

    cursor cur_invoices is
       select x.account_number
            , crd_api_const_pkg.INVOICE_TYPE_REGULAR as invoice_type
            , x.exceed_limit
            , x.total_amount_due
            , x.mandatory_amount_due mandatory_amount_due
            , x.own_funds
            , to_date(x.start_date, com_api_const_pkg.XML_DATETIME_FORMAT) start_date
            , to_date(x.invoice_date, com_api_const_pkg.XML_DATETIME_FORMAT) invoice_date
            , to_date(x.due_date, com_api_const_pkg.XML_DATETIME_FORMAT) due_date
            , to_date(x.grace_date, com_api_const_pkg.XML_DATETIME_FORMAT) grace_date
            , to_date(x.penalty_date, com_api_const_pkg.XML_DATETIME_FORMAT) penalty_date
            , to_date(x.overdue_date, com_api_const_pkg.XML_DATETIME_FORMAT) overdue_date
            , x.aging_period
            , x.is_tad_paid
            , x.is_mad_paid
         from prc_session_file s
            , prc_file_attribute a
            , prc_file f
            , xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/credit/invoice')
                   , '/invoices/invoice' passing s.file_xml_contents
                   columns
                      account_number                    varchar2(32)  path 'account_number'
                    , exceed_limit                      number        path 'exceed_limit'
                    , total_amount_due                  number        path 'total_amount_due'
                    , mandatory_amount_due              number        path 'mandatory_amount_due'
                    , own_funds                         number        path 'own_funds'
                    , start_date                        varchar2(20)  path 'start_date'
                    , invoice_date                      varchar2(20)  path 'invoice_date'
                    , due_date                          varchar2(20)  path 'due_date'
                    , grace_date                        varchar2(20)  path 'grace_date'
                    , penalty_date                      varchar2(20)  path 'penalty_date'
                    , overdue_date                      varchar2(20)  path 'overdue_date'
                    , aging_period                      number        path 'aging_period'
                    , is_tad_paid                       number        path 'is_tad_paid'
                    , is_mad_paid                       number        path 'is_mad_paid'
              ) x
         where s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = crd_api_const_pkg.FILE_TYPE_MIGRATION;

    cursor cur_invoice_count is
        select nvl(sum(invoice_count), 0) invoice_count
         from prc_session_file s
            , prc_file_attribute a
            , prc_file f
            , xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/credit/invoice')
                   , '/invoices' passing s.file_xml_contents
                columns
                      invoice_count                        number        path 'fn:count(invoice)'
              ) x
         where s.session_id = get_session_id
         and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = crd_api_const_pkg.FILE_TYPE_MIGRATION;

    type t_invoice_tab     is varray(1000) of t_invoice_rec;
    l_invoice_tab          t_invoice_tab;

    cursor cur_debts is
       select null id
            , null account_id
            , null card_id
            , null product_id
            , null service_id
            , null oper_id
            , null oper_type
            , null sttl_type
            , x.fee_type
            , null terminal_type
            , null oper_date
            , null posting_date
            , null sttl_day
            , null currency
            , x.amount
            , x.debt_amount
            , null mcc
            , x.aging_period
            , 0 is_new
            , x.status
            , null inst_id
            , null agent_id
            , null split_hash
            , x.macros_type_id
            , x.is_grace_enabled
            , x.originator_refnum
            , x.account_number
            , x.card_number
            , to_date(x.invoice_date, com_api_const_pkg.XML_DATETIME_FORMAT) invoice_date
            , x.debt_balance
            , null invoice_id
         from prc_session_file s
            , prc_file_attribute a
            , prc_file f
            , xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/credit/debt')
                   , '/debts/debt' passing s.file_xml_contents
                   columns
                      originator_refnum                 varchar2(36)  path 'originator_refnum'
                    , account_number                    varchar2(32)  path 'account_number'
                    , card_number                       varchar2(30)  path 'card_number'
                    , amount                            number        path 'amount'
                    , debt_amount                       number        path 'debt_amount'
                    , aging_period                      number        path 'aging_period'
                    , fee_type                          varchar(8)    path 'fee_type'
                    , status                            varchar2(8)   path 'status'
                    , macros_type_id                    number        path 'macros_type_id'
                    , invoice_date                      varchar2(20)  path 'invoice_date'
                    , is_grace_enabled                  number        path 'is_grace_enabled'
                    , debt_balance                      xmltype       path 'debt_balance'
              ) x
         where s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = crd_api_const_pkg.FILE_TYPE_MIGRATION;

    cursor cur_debt_count is
        select nvl(sum(debt_count), 0) debt_count
         from prc_session_file s
            , prc_file_attribute a
            , prc_file f
            , xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/credit/debt')
                   , '/debts' passing s.file_xml_contents
                columns
                      debt_count                        number        path 'fn:count(debt)'
              ) x
         where s.session_id = get_session_id
         and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = crd_api_const_pkg.FILE_TYPE_MIGRATION;

    type t_debt_tab     is varray(1000) of t_debt_rec;
    l_debt_tab          t_debt_tab;

    cursor cur_payments is
       select null id
            , null oper_id
            , null is_reversal
            , null original_oper_id
            , null account_id
            , null card_id
            , null product_id
            , null posting_date
            , null sttl_day
            , null currency
            , x.amount
            , x.pay_amount
            , 0 is_new
            , x.status
            , null inst_id
            , null agent_id
            , null split_hash
            , x.originator_refnum
            , x.account_number
            , x.card_number
            , to_date(x.invoice_date, com_api_const_pkg.XML_DATETIME_FORMAT) invoice_date
            , x.debt_payment
            , null invoice_id
         from prc_session_file s
            , prc_file_attribute a
            , prc_file f
            , xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/credit/payment')
                   , '/payments/payment' passing s.file_xml_contents
                   columns
                      originator_refnum                 varchar2(36)  path 'originator_refnum'
                    , account_number                    varchar2(32)  path 'account_number'
                    , card_number                       varchar2(30)  path 'card_number'
                    , amount                            number        path 'amount'
                    , pay_amount                        number        path 'pay_amount'
                    , status                            varchar2(8)   path 'status'
                    , invoice_date                      varchar2(20)  path 'invoice_date'
                    , debt_payment                      xmltype       path 'debt_payment'
              ) x
         where s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = crd_api_const_pkg.FILE_TYPE_MIGRATION;

    cursor cur_payment_count is
        select nvl(sum(payment_count), 0) payment_count
         from prc_session_file s
            , prc_file_attribute a
            , prc_file f
            , xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/credit/payment')
                   , '/payments' passing s.file_xml_contents
                columns
                      payment_count                        number        path 'fn:count(payment)'
              ) x
         where s.session_id = get_session_id
         and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = crd_api_const_pkg.FILE_TYPE_MIGRATION;

    type t_payment_tab     is varray(1000) of t_payment_rec;
    l_payment_tab          t_payment_tab;

procedure register_invoice (
    i_invoice_rec   in      t_invoice_rec
    , i_inst_id     in      com_api_type_pkg.t_inst_id
) is
    l_account_id      com_api_type_pkg.t_medium_id;
    l_agent_id        com_api_type_pkg.t_medium_id;
    l_inst_id         com_api_type_pkg.t_inst_id;
    l_split_hash      com_api_type_pkg.t_tiny_id;
    l_invoice_id      com_api_type_pkg.t_medium_id;
    l_serial_number   com_api_type_pkg.t_tiny_id;
    l_invoice_date    date;
    l_sttl_date       date;
    l_grace_date      date;
    l_penalty_date    date;

begin
    l_sttl_date := com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id);

    begin
        select a.id
             , a.agent_id
             , a.inst_id
             , a.split_hash
          into l_account_id
             , l_agent_id
             , l_inst_id
             , l_split_hash
          from acc_account a
         where a.account_number = i_invoice_rec.account_number
           and a.inst_id = i_inst_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ACCOUNT_NOT_FOUND'
              , i_env_param1    => i_invoice_rec.account_number
              , i_env_param2    => i_inst_id
            );
    end;

    select max(serial_number)
         , max(invoice_date)
      into l_serial_number
         , l_invoice_date
      from crd_invoice
     where account_id = l_account_id
       and split_hash = l_split_hash;

    if l_invoice_date is not null then
        if l_invoice_date >= i_invoice_rec.invoice_date then
            com_api_error_pkg.raise_error (
                i_error         => 'INCORRECT_INVOICE_DATE'
                , i_env_param1  => com_api_type_pkg.convert_to_char(i_invoice_rec.invoice_date)
                , i_env_param2  => com_api_type_pkg.convert_to_char(l_invoice_date)
                , i_env_param3  => i_invoice_rec.account_number
            );
        else
            l_serial_number := l_serial_number + 1;
        end if;
    else
        l_serial_number := 1;
    end if;

    select crd_invoice_seq.nextval
      into l_invoice_id
      from dual;

    -- add invoice record
    insert into crd_invoice(
        id
        , account_id
        , invoice_type
        , serial_number
        , exceed_limit
        , total_amount_due
        , min_amount_due
        , own_funds
        , start_date
        , invoice_date
        , grace_date
        , due_date
        , penalty_date
        , overdue_date
        , aging_period
        , is_tad_paid
        , is_mad_paid
        , inst_id
        , agent_id
        , split_hash
    ) values (
        l_invoice_id
        , l_account_id
        , i_invoice_rec.invoice_type
        , l_serial_number
        , i_invoice_rec.exceed_limit
        , i_invoice_rec.total_amount_due
        , i_invoice_rec.mandatory_amount_due
        , i_invoice_rec.own_funds
        , i_invoice_rec.start_date
        , i_invoice_rec.invoice_date
        , i_invoice_rec.grace_date
        , i_invoice_rec.due_date
        , i_invoice_rec.penalty_date
        , i_invoice_rec.overdue_date
        , i_invoice_rec.aging_period
        , i_invoice_rec.is_tad_paid
        , i_invoice_rec.is_mad_paid
        , l_inst_id
        , l_agent_id
        , l_split_hash
    );

    -- create cycle counter
    if l_sttl_date < i_invoice_rec.grace_date then
        l_grace_date := i_invoice_rec.grace_date;
    else
        l_grace_date := null;
    end if;

    if l_sttl_date < i_invoice_rec.penalty_date then
        l_penalty_date := i_invoice_rec.penalty_date;
    else
        l_penalty_date := null;
    end if;
    trc_log_pkg.debug(
        i_text          => 'l_grace_date =' || l_grace_date || ', l_penalty_date='||l_penalty_date
    );

    fcl_api_cycle_pkg.add_cycle_counter(
        i_cycle_type        => crd_api_const_pkg.GRACE_PERIOD_CYCLE_TYPE
      , i_entity_type       => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id         => l_invoice_id
      , i_split_hash        => l_split_hash
      , i_next_date         => l_grace_date
      , i_inst_id           => l_inst_id
    );

    fcl_api_cycle_pkg.add_cycle_counter(
        i_cycle_type        => crd_api_const_pkg.PENALTY_PERIOD_CYCLE_TYPE
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => l_account_id
      , i_split_hash        => l_split_hash
      , i_next_date         => l_penalty_date
      , i_inst_id           => l_inst_id
    );

end;

procedure load_invoice(
    i_inst_id       com_api_type_pkg.t_inst_id
) is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
begin
    savepoint read_invoices_start;

    trc_log_pkg.debug(
        i_text          => 'Read invoices'
    );

    prc_api_stat_pkg.log_start;

    open cur_invoice_count;
    fetch cur_invoice_count into l_estimated_count;
    close cur_invoice_count;
    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    open    cur_invoices;

    trc_log_pkg.debug(
        i_text          => 'cursor opened'
    );

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching '||BULK_LIMIT||' invoices'
        );

        fetch cur_invoices bulk collect into l_invoice_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 invoices fetched'
          , i_env_param1    => l_invoice_tab.count
        );

        for i in 1 .. l_invoice_tab.count loop
            savepoint register_invoices_start;

            begin
                register_invoice(
                    i_invoice_rec         => l_invoice_tab(i)
                    , i_inst_id           => i_inst_id
                );
            exception
                when others then
                    rollback to savepoint register_invoices_start;
                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        l_excepted_count := l_excepted_count + 1;

                    else
                        close   cur_invoices;
                        raise;

                    end if;
            end;
            
            l_processed_count := l_processed_count + 1;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;

        end loop;

        exit when cur_invoices%notfound;
    end loop;

    close cur_invoices;

    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text  => 'Read invoices finished'
    );

exception
    when others then
        rollback to savepoint read_invoices_start;
        if cur_invoices%isopen then
            close   cur_invoices;

        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

        raise;
end;

procedure register_debt_interest(
    i_debt_rec          in  out nocopy t_debt_rec
    , i_debt_interest   in  xmltype
    , i_balance_type    in  com_api_type_pkg.t_dict_value
    , i_min_amount_due  in  com_api_type_pkg.t_money
    , o_debt_intr_id    out com_api_type_pkg.t_long_id
) is
    l_from_id           com_api_type_pkg.t_long_id;
    l_fee_id            com_api_type_pkg.t_long_id;
    l_debt_intr_id      com_api_type_pkg.t_long_id;
    l_add_fee_id        com_api_type_pkg.t_long_id;
    l_last_invoice_id   com_api_type_pkg.t_medium_id;
begin

    l_from_id      := com_api_id_pkg.get_from_id_num(i_debt_rec.id);
    trc_log_pkg.debug(
        i_text          => 'Start register debt interest'
    );

    for b in (
        select to_date(x.balance_date, com_api_const_pkg.XML_DATETIME_FORMAT) balance_date
            , x.amount
            , to_number(x.interest_rate, 'FM999999999999999990.00000', 'nls_numeric_characters=,.') interest_rate              
            , to_number(x.additional_interest_rate, 'FM999999999999999990.00000', 'nls_numeric_characters=,.') additional_interest_rate                          
            , x.interest_amount
            , x.is_charged
         from xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/credit/debt'),
              '/debt_interest'
              passing i_debt_interest
              columns
              balance_date                      varchar2(20) path 'balance_date'
            , amount                            number       path 'amount'
            , interest_rate                     varchar2(20) path 'interest_rate'            
            , additional_interest_rate          varchar2(20) path 'additional_interest_rate'            
            , interest_amount                   number       path 'interest_amount'
            , is_charged                        number       path 'is_charged'
        )x
     )loop
         -- if interest_amount is null then search fee_id
         if nvl(b.interest_amount, 0) = 0 and b.is_charged = 0 then
             -- search main fee_id
             select max(to_number(f.fee_id, 'FM999999999999999990.0000')) fee_id
                 into l_fee_id
                 from (
                     select fee_id
                         from (select v.attr_value fee_id
                                  , v.start_date
                               from prd_attribute_value v
                                  , prd_attribute a
                              where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                and v.object_id    = i_debt_rec.account_id
                                and v.service_id   = i_debt_rec.service_id
                                and v.split_hash   = i_debt_rec.split_hash
                                and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_FEE
                                and a.object_type  = crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
                                and a.id           = v.attr_id
                              union all
                             select v.attr_value fee_id
                                  , v.start_date
                               from (
                                    select connect_by_root id product_id
                                         , level level_priority
                                         , id parent_id
                                         , product_type
                                         , case when parent_id is null then 1 else 0 end top_flag
                                      from prd_product
                                     connect by prior parent_id = id
                                       start with id = i_debt_rec.product_id
                                    ) p
                                  , prd_attribute_value v
                                  , prd_attribute a
                                  , prd_service s
                                  , rul_mod m
                                  , prd_product_service ps
                              where ps.product_id     = p.product_id
                                and ps.service_id     = s.id
                                and v.service_id      = s.id
                                and a.service_type_id = s.service_type_id
                                and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id) 
                                and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                and v.attr_id         = a.id
                                and v.mod_id          = m.id(+)    
                                and s.id              = i_debt_rec.service_id
                                and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_FEE
                                and a.object_type     = crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
                             )
                 ) f
                 , fcl_fee_tier t
             where to_number(f.fee_id, 'FM999999999999999990.0000') = t.fee_id
               and t.percent_rate = b.interest_rate; 

             if l_fee_id is null then
                 trc_log_pkg.debug(
                     i_text          => 'FEE_NOT_FOUND: i_debt_rec.product_id=' || i_debt_rec.product_id ||
                                        ' i_debt_rec.service_id= ' || i_debt_rec.service_id              ||
                                        ' i_debt_rec.account_number= ' || i_debt_rec.account_number      ||
                                        ' interest_rate = ' || b.interest_rate                           ||
                                        ' i_debt_rec.account_id= ' || i_debt_rec.account_id              ||
                                        ' i_debt_rec.split_hash= ' || i_debt_rec.split_hash
                 );

                 com_api_error_pkg.raise_error(
                     i_error         => 'FEE_NOT_FOUND'
                   , i_env_param1    => i_debt_rec.originator_refnum
                   , i_env_param2    => crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
                   , i_env_param3    => i_debt_rec.service_id
                   , i_env_param4    => b.interest_rate
                 );
             end if;

             trc_log_pkg.debug(
                 i_text          => 'l_fee_id=' || l_fee_id
             );

             -- search additional fee_id only for overdue
             select max(to_number(f.fee_id, 'FM999999999999999990.0000')) fee_id
                 into l_add_fee_id
                 from (
                     select fee_id
                         from (select v.attr_value fee_id
                                  , v.start_date
                               from prd_attribute_value v
                                  , prd_attribute a
                              where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                and v.object_id    = i_debt_rec.account_id
                                and v.service_id   = i_debt_rec.service_id
                                and v.split_hash   = i_debt_rec.split_hash
                                and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_FEE
                                and a.object_type  = crd_api_const_pkg.ADDIT_INTEREST_RATE_FEE_TYPE
                                and a.id           = v.attr_id
                              union all
                             select v.attr_value fee_id
                                  , v.start_date
                               from (
                                    select connect_by_root id product_id
                                         , level level_priority
                                         , id parent_id
                                         , product_type
                                         , case when parent_id is null then 1 else 0 end top_flag
                                      from prd_product
                                     connect by prior parent_id = id
                                       start with id = i_debt_rec.product_id
                                    ) p
                                  , prd_attribute_value v
                                  , prd_attribute a
                                  , prd_service s
                                  , rul_mod m
                                  , prd_product_service ps
                              where ps.product_id     = p.product_id
                                and ps.service_id     = s.id
                                and v.service_id      = s.id
                                and a.service_type_id = s.service_type_id
                                and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id) 
                                and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                and v.attr_id         = a.id
                                and v.mod_id          = m.id(+)    
                                and s.id              = i_debt_rec.service_id
                                and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_FEE
                                and a.object_type     = crd_api_const_pkg.ADDIT_INTEREST_RATE_FEE_TYPE                                
                            )
                 ) f
                 , fcl_fee_tier t
             where to_number(f.fee_id, 'FM999999999999999990.0000') = t.fee_id
               and t.percent_rate = nvl(b.additional_interest_rate, 0);

             if l_add_fee_id is null then
                 trc_log_pkg.debug(
                     i_text          => 'ADD_FEE_NOT_FOUND: i_debt_rec.product_id=' || i_debt_rec.product_id ||
                                        ' i_debt_rec.service_id= ' || i_debt_rec.service_id              ||
                                        ' i_debt_rec.account_number= ' || i_debt_rec.account_number      ||
                                        ' additional_interest_rate = ' || b.additional_interest_rate     ||
                                        ' i_debt_rec.account_id= ' || i_debt_rec.account_id              ||
                                        ' i_debt_rec.split_hash= ' || i_debt_rec.split_hash
                 );
                
                 com_api_error_pkg.raise_error(
                     i_error         => 'FEE_NOT_FOUND'
                   , i_env_param1    => i_debt_rec.originator_refnum
                   , i_env_param2    => crd_api_const_pkg.ADDIT_INTEREST_RATE_FEE_TYPE
                   , i_env_param3    => i_debt_rec.service_id
                   , i_env_param4    => b.additional_interest_rate
                 );  
             end if;

             trc_log_pkg.debug(
                 i_text          => 'l_add_fee_id=' || l_add_fee_id
             );

         end if;

        l_last_invoice_id := 
            crd_invoice_pkg.get_last_invoice_id(
                i_account_id        => i_debt_rec.account_id
              , i_split_hash        => i_debt_rec.split_hash
              , i_mask_error        => com_api_const_pkg.TRUE
            );
         
         insert into crd_debt_interest(
               id
               , debt_id
               , balance_type
               , balance_date
               , amount
               , min_amount_due
               , interest_amount
               , fee_id
               , is_charged
               , is_grace_enable
               , invoice_id
               , split_hash
               , add_fee_id
               , posting_order
           ) values (
               (l_from_id + crd_debt_interest_seq.nextval)
               , i_debt_rec.id
               , i_balance_type
               , b.balance_date
               , b.amount
               , i_min_amount_due
               , b.interest_amount
               , l_fee_id
               , b.is_charged
               , null
               , decode(b.is_charged, com_api_const_pkg.TRUE, l_last_invoice_id, null)
               , i_debt_rec.split_hash
               , l_add_fee_id
               , 0
           ) returning id into l_debt_intr_id;
           
         
         -- add link invoce with debt
         if i_debt_rec.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE and
            i_debt_rec.is_new = com_api_const_pkg.FALSE then
             insert into crd_invoice_debt(
                 id
                 , invoice_id
                 , debt_id
                 , debt_intr_id
                 , is_new
                 , split_hash
               ) values (
                 (l_from_id + crd_invoice_debt_seq.nextval)
                 , l_last_invoice_id
                 , i_debt_rec.id
                 , l_debt_intr_id
                 , case when i_debt_rec.invoice_id = l_last_invoice_id then com_api_const_pkg.TRUE else com_api_const_pkg.FALSE end
                 , i_debt_rec.split_hash
              );
         end if;

         trc_log_pkg.debug(
             i_text          => 'Insert debt interest'
         );

     end loop;

    --set last interest
    o_debt_intr_id := l_debt_intr_id;

    trc_log_pkg.debug(
        i_text          => 'End register debt interest'
    );

end;

procedure register_debt_balance(
    i_debt_rec          in out nocopy t_debt_rec
) is
    l_from_id           com_api_type_pkg.t_long_id;
    l_balance_id        com_api_type_pkg.t_long_id;
    l_debt_intr_id      com_api_type_pkg.t_long_id;
    l_bunch_id          com_api_type_pkg.t_long_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
begin
    l_from_id      := com_api_id_pkg.get_from_id_num(i_debt_rec.id);

    trc_log_pkg.debug(
        i_text          => 'Start register balance'
    );
    /*trc_log_pkg.debug(
        i_text          => i_debt_rec.debt_balance.getclobval()
    );*/

    for b in (
        select x.balance_type
             , x.amount
             , x.repay_priority
             , x.min_amount_due
             , x.debt_interest
             , e.bunch_type_id
          from xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/credit/debt'),
                 '/debt_balance' passing i_debt_rec.debt_balance
                  columns
                  balance_type                      varchar2(8)  path 'balance_type'
                , amount                            number       path 'amount'
                , repay_priority                    number       path 'repay_priority'
                , min_amount_due                    number       path 'min_amount_due'
                , debt_interest                     xmltype      path 'debt_interest'
               ) x
             , crd_event_bunch_type e
         where e.balance_type = x.balance_type
           and e.event_type   = crd_api_const_pkg.DEBT_MIGRATION_EVENT
           and e.inst_id      = i_debt_rec.inst_id
    ) loop
        select (l_from_id + crd_debt_balance_seq.nextval) into l_balance_id from dual;

        insert into crd_debt_balance(
            id
          , debt_id
          , balance_type
          , amount
          , repay_priority
          , min_amount_due
          , split_hash
          , posting_order
        ) values (
            l_balance_id
          , i_debt_rec.id
          , b.balance_type
          , b.amount
          , b.repay_priority
          , b.min_amount_due
          , i_debt_rec.split_hash
          , 0
        );
         
        acc_api_entry_pkg.put_bunch (
            o_bunch_id          => l_bunch_id
          , i_bunch_type_id     => b.bunch_type_id
          , i_macros_id         => i_debt_rec.id
          , i_amount            => b.amount
          , i_currency          => i_debt_rec.currency
          , i_account_type      => null
          , i_account_id        => i_debt_rec.account_id
          , i_posting_date      => i_debt_rec.posting_date
          , i_macros_type_id    => i_debt_rec.macros_type_id
          , i_param_tab         => l_param_tab
        );
         
        trc_log_pkg.debug(
            i_text          => 'Insert balance = ' || l_balance_id
        );

         -- register debt_interest
        if b.debt_interest is not null then
            register_debt_interest(
                 i_debt_rec          => i_debt_rec
                 , i_debt_interest   => b.debt_interest
                 , i_balance_type    => b.balance_type
                 , i_min_amount_due  => b.min_amount_due
                 , o_debt_intr_id    => l_debt_intr_id
            );

            update crd_debt_balance
               set debt_intr_id = l_debt_intr_id
             where id = l_balance_id;

            trc_log_pkg.debug(
                i_text          => 'l_debt_intr_id=' || l_debt_intr_id
            );
            
        elsif i_debt_rec.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE then
            trc_log_pkg.error(
                i_text          => 'CRD_NO_INTEREST_DATA_FOR_ACTIVE_DEBT'
              , i_env_param1    => i_debt_rec.originator_refnum
              , i_env_param2    => i_debt_rec.id
            );

        end if;

     end loop;

    trc_log_pkg.debug(
        i_text          => 'End register balance'
    );

end;

procedure register_debt (
    i_debt_rec      in out nocopy t_debt_rec
    , i_inst_id     in     com_api_type_pkg.t_inst_id
) is
    l_count       com_api_type_pkg.t_inst_id;  
begin
    -- get account_id, agent_id, split_hash and product_id    
    begin
        select a.id
            , a.agent_id
            , a.inst_id
            , a.split_hash
            , c.product_id
            , a.currency
         into i_debt_rec.account_id
            , i_debt_rec.agent_id
            , i_debt_rec.inst_id
            , i_debt_rec.split_hash
            , i_debt_rec.product_id
            , i_debt_rec.currency
         from acc_account a
            , prd_contract c
        where a.account_number = i_debt_rec.account_number
          and a.inst_id = i_inst_id
          and c.id = a.contract_id;
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text          => 'ACCOUNT_NOT_FOUND: i_debt_rec.account_number=' || i_debt_rec.account_number
            );

            com_api_error_pkg.raise_error(
                i_error         => 'ACCOUNT_NOT_FOUND'
              , i_env_param1    => i_debt_rec.account_number
              , i_env_param2    => i_inst_id
            );
    end;

    --get card_id
    if i_debt_rec.card_number is not null then    
        i_debt_rec.card_id := iss_api_card_pkg.get_card_id(i_card_number => i_debt_rec.card_number); -- exception isn't raised
    
        if i_debt_rec.card_id is not null then
            trc_log_pkg.debug(
                i_text  => 'card_id=' || i_debt_rec.card_id  
            );
        else
            com_api_error_pkg.raise_error(
                i_error         => 'CARD_NOT_FOUND'
              , i_env_param1    => iss_api_card_pkg.get_card_mask(i_debt_rec.card_number)
              , i_env_param2    => i_debt_rec.originator_refnum
            );  
        end if; 
    end if;
    
    --get operation of debt
    select max(id)
        , max(oper_type)
        , max(sttl_type)
        , max(terminal_type)
        , max(oper_date)
        , max(host_date)
        , max(mcc)
        , count(1)    
     into i_debt_rec.oper_id
        , i_debt_rec.oper_type
        , i_debt_rec.sttl_type
        , i_debt_rec.terminal_type
        , i_debt_rec.oper_date
        , i_debt_rec.posting_date
        , i_debt_rec.mcc
        , l_count
     from opr_operation o
        , opr_participant iss
    where o.originator_refnum = i_debt_rec.originator_refnum
      and o.id = iss.oper_id
      and o.is_reversal = 0
      --and nvl(o.oper_amount, 0) = nvl(i_debt_rec.amount, 0)
      and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
      and (iss.account_id = i_debt_rec.account_id or iss.account_number = i_debt_rec.account_number);
        
    -- serch of card_id and originator_refnum  
    if l_count = 0 then
        begin
            select id
                 , oper_type
                 , sttl_type
                 , terminal_type
                 , oper_date
                 , host_date
                 , mcc                
              into i_debt_rec.oper_id
                 , i_debt_rec.oper_type
                 , i_debt_rec.sttl_type
                 , i_debt_rec.terminal_type
                 , i_debt_rec.oper_date
                 , i_debt_rec.posting_date
                 , i_debt_rec.mcc
              from opr_operation o
                 , opr_participant iss
                 , opr_card c
             where o.originator_refnum = i_debt_rec.originator_refnum
               and o.id = iss.oper_id
               and o.is_reversal = 0
               --and nvl(o.oper_amount, 0) = nvl(i_debt_rec.amount, 0)
               and o.id = c.oper_id(+) 
               and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and c.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and (iss.card_id = i_debt_rec.card_id 
                    or
                    reverse(c.card_number) = reverse(iss_api_token_pkg.encode_card_number(i_card_number => i_debt_rec.card_number))
               );
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'OPERATION_NOT_FOUND: i_debt_rec.originator_refnum [#1], i_debt_rec.card_id [#2], i_debt_rec.account_id [#3], i_debt_rec.account_number [#4]'
                  , i_env_param1    => i_debt_rec.originator_refnum
                  , i_env_param2    => i_debt_rec.card_id
                  , i_env_param3    => i_debt_rec.account_id
                  , i_env_param4    => i_debt_rec.account_number
                );

                com_api_error_pkg.raise_error(
                    i_error         => 'OPERATION_NOT_FOUND'
                  , i_env_param1    => i_debt_rec.originator_refnum
                  , i_env_param2    => i_inst_id
                );
                
            when too_many_rows then
                trc_log_pkg.debug(
                    i_text          => 'TOO_MANY_OPERATIONS: i_debt_rec.originator_refnum [#1], i_debt_rec.card_number [#2], i_debt_rec.card_id [#3]'
                  , i_env_param1    => i_debt_rec.originator_refnum
                  , i_env_param2    => iss_api_card_pkg.get_card_mask(i_debt_rec.card_number)
                  , i_env_param3    => i_debt_rec.card_id
                );
                
                com_api_error_pkg.raise_error(
                    i_error         => 'TOO_MANY_RECORDS_FOUND'
                  , i_env_param1    => i_debt_rec.originator_refnum
                  , i_env_param2    => i_inst_id
                );     
        end;
    
    elsif l_count > 1 then
        trc_log_pkg.debug(
            i_text          => 'TOO_MANY_OPERATIONS: i_debt_rec.originator_refnum [#1], i_debt_rec.account_number [#2], i_debt_rec.account_id [#3]'
          , i_env_param1    => i_debt_rec.originator_refnum
          , i_env_param2    => i_debt_rec.account_number
          , i_env_param3    => i_debt_rec.account_id
        );
                
        com_api_error_pkg.raise_error(
            i_error         => 'TOO_MANY_RECORDS_FOUND'
          , i_env_param1    => i_debt_rec.originator_refnum
          , i_env_param2    => i_inst_id
        );     
    end if;     

    --get service_id
    i_debt_rec.service_id :=
        crd_api_service_pkg.get_active_service(
            i_account_id        => i_debt_rec.account_id
          , i_eff_date          => com_api_sttl_day_pkg.get_sysdate --i_debt_rec.posting_date
          , i_split_hash        => i_debt_rec.split_hash
        );
        
    --SERVICE_NOT_FOUND
    if i_debt_rec.service_id is null then
        trc_log_pkg.debug(
            i_text          => 'SERVICE_NOT_FOUND: i_debt_rec.account_id [#1], i_debt_rec.posting_date [#2], i_debt_rec.split_hash [#3]'
          , i_env_param1    => i_debt_rec.account_id
          , i_env_param2    => i_debt_rec.posting_date
          , i_env_param3    => i_debt_rec.split_hash
        );

        com_api_error_pkg.raise_error(
            i_error         => 'SERVICE_NOT_FOUND'
          , i_env_param1    => i_debt_rec.originator_refnum
        );     
    end if;
    
    -- get settl_day
    i_debt_rec.sttl_day := com_api_sttl_day_pkg.get_open_sttl_day(i_inst_id);

    --get id
    select com_api_id_pkg.get_id(i_seq => acc_macros_seq.nextval) into i_debt_rec.id from dual;
    trc_log_pkg.debug(
        i_text          => 'debt_id=' || i_debt_rec.id
    );

    --search invoice of invoice_date
    trc_log_pkg.debug(
        i_text          => 'account_id=' || i_debt_rec.account_id || ', i_debt_rec.invoice_date=' || i_debt_rec.invoice_date || ', i_debt_rec.split_hash=' || i_debt_rec.split_hash
    );

    begin
        if i_debt_rec.invoice_date is null then
            i_debt_rec.invoice_id := null;
            i_debt_rec.is_new := 1;
        else
            select i.id
              into i_debt_rec.invoice_id
              from crd_invoice_vw i
             where i.account_id = i_debt_rec.account_id
               and i.invoice_date = i_debt_rec.invoice_date
               and i.split_hash = i_debt_rec.split_hash;

            i_debt_rec.is_new := 0;
        end if;

        trc_log_pkg.debug(
            i_text          => 'i_debt_rec.invoice_id=' || i_debt_rec.invoice_id
        );

    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text          => 'INVOICE_NOT_FOUND: account_id=' || i_debt_rec.account_id || ', invoice_date=' || com_api_type_pkg.convert_to_char(i_debt_rec.invoice_date)
            );

            com_api_error_pkg.raise_error(
                i_error         => 'INVOICE_NOT_FOUND'
              , i_env_param1    => i_debt_rec.originator_refnum
              , i_env_param2    => com_api_type_pkg.convert_to_char(i_debt_rec.invoice_date)
            );
    end;

    --create row
    insert into crd_debt(
        id
        , account_id
        , card_id
        , product_id
        , service_id
        , oper_id
        , oper_type
        , sttl_type
        , fee_type
        , terminal_type
        , oper_date
        , posting_date
        , sttl_day
        , currency
        , amount
        , debt_amount
        , mcc
        , aging_period
        , status
        , is_new
        , inst_id
        , agent_id
        , split_hash
        , macros_type_id
        , is_grace_enable
    ) values (
        i_debt_rec.id
        , i_debt_rec.account_id
        , i_debt_rec.card_id
        , i_debt_rec.product_id
        , i_debt_rec.service_id
        , i_debt_rec.oper_id
        , i_debt_rec.oper_type
        , i_debt_rec.sttl_type
        , i_debt_rec.fee_type
        , i_debt_rec.terminal_type
        , i_debt_rec.oper_date
        , i_debt_rec.posting_date
        , i_debt_rec.sttl_day
        , i_debt_rec.currency
        , i_debt_rec.amount
        , i_debt_rec.debt_amount
        , i_debt_rec.mcc
        , i_debt_rec.aging_period
        , i_debt_rec.status
        , i_debt_rec.is_new
        , i_debt_rec.inst_id
        , i_debt_rec.agent_id
        , i_debt_rec.split_hash
        , i_debt_rec.macros_type_id
        , i_debt_rec.is_grace_enabled
    );

    --debt_balance
    if i_debt_rec.debt_balance is not null then
        register_debt_balance(
            i_debt_rec          => i_debt_rec
        );
    end if;

    -- create macros
    trc_log_pkg.debug(
        i_text          => 'crate macros for debt ' || i_debt_rec.id
    );

    insert into acc_macros (
        id
        , entity_type
        , object_id
        , macros_type_id
        , posting_date
        , account_id
        , amount
        , currency
        , amount_purpose
        , fee_id
        , fee_tier_id
        , fee_mod_id
        , details_data
        , status
        , cancel_indicator
    ) values (
        i_debt_rec.id
        , opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_debt_rec.oper_id
        , i_debt_rec.macros_type_id
        , i_debt_rec.posting_date
        , i_debt_rec.account_id
        , i_debt_rec.amount
        , i_debt_rec.currency
        , null
        , null
        , null
        , null
        , null
        , acc_api_const_pkg.MACROS_STATUS_POSTED
        , com_api_const_pkg.INDICATOR_NOT_CANCELED
    );

    trc_log_pkg.debug(
        i_text          => 'macros created'
    );

end;

procedure load_debt(
    i_inst_id       com_api_type_pkg.t_inst_id
) is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;

begin
    savepoint read_debts_start;

    trc_log_pkg.debug(
        i_text          => 'Read debts'
    );

    prc_api_stat_pkg.log_start;

    open cur_debt_count;
    fetch cur_debt_count into l_estimated_count;
    close cur_debt_count;
    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    open    cur_debts;

    trc_log_pkg.debug(
        i_text          => 'cursor opened'
    );

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching '||BULK_LIMIT||' debts'
        );

        fetch cur_debts bulk collect into l_debt_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 debts fetched'
          , i_env_param1    => l_debt_tab.count
        );

        for i in 1 .. l_debt_tab.count loop
            savepoint register_debts_start;

            begin
                register_debt (
                    i_debt_rec      => l_debt_tab(i)
                  , i_inst_id       => i_inst_id
                );
            exception
                when others then
                    rollback to savepoint register_debts_start;
                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        l_excepted_count := l_excepted_count + 1;

                    else
                        raise;

                    end if;
            end;
            
            l_processed_count := l_processed_count + 1;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;
        end loop;

        exit when cur_debts%notfound;
    end loop;

    close cur_debts;

    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text  => 'Read debts finished'
    );
    
exception
    when others then
        rollback to savepoint read_debts_start;
        if cur_debts%isopen then
            close   cur_debts;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

        raise;
end;

procedure register_debt_payment(
    i_payment_rec          in out nocopy t_payment_rec
) is
    l_debt_id       com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text  => 'Start register debt payment'
    );

    for p in (
        select x.debt_refnum
            , x.balance_type
            , x.fee_type
            , x.pay_amount
            , to_date(x.eff_date, com_api_const_pkg.XML_DATETIME_FORMAT) eff_date
         from xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/credit/payment'),
              '/debt_payment' passing i_payment_rec.debt_payment
              columns
              debt_refnum                       varchar2(36)  path 'debt_refnum'
            , balance_type                      varchar2(8)   path 'balance_type'
            , fee_type                          varchar2(8)   path 'fee_type'
            , pay_amount                        number        path 'pay_amount'
            , eff_date                          varchar2(20)  path 'eff_date'
         )x
     )loop
         --get debt
         begin
             select d.id
               into l_debt_id
               from opr_operation o
                  , crd_debt d
              where o.originator_refnum = p.debt_refnum
                and d.oper_id = o.id
                and (
                     (p.fee_type is null and d.fee_type is null)
                     or 
                     d.fee_type = p.fee_type
                    );
         exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'DEBT_NOT_FOUND'
                  , i_env_param1    => p.debt_refnum
                  , i_env_param2    => p.fee_type
                );
                raise;
         end;
         trc_log_pkg.debug (
             i_text  => 'l_debt_id= ' || l_debt_id
         );

         insert into crd_debt_payment(
             id
             , debt_id
             , balance_type
             , pay_id
             , pay_amount
             , eff_date
             , split_hash
         ) values (
              com_api_id_pkg.get_id(crd_debt_payment_seq.nextval, l_debt_id)
             , l_debt_id
             , p.balance_type
             , i_payment_rec.id
             , p.pay_amount
             , p.eff_date
             , i_payment_rec.split_hash
         );
         trc_log_pkg.debug (
             i_text  => 'Insert debt payment for debt = ' || l_debt_id
         );

     end loop;
     trc_log_pkg.debug (
         i_text  => 'End register debt payment'
     );
end;

procedure register_payment (
    i_payment_rec      in out nocopy t_payment_rec
    , i_inst_id        in     com_api_type_pkg.t_inst_id
)is
    l_count             com_api_type_pkg.t_count := 0;
    l_last_invoice_id   com_api_type_pkg.t_medium_id;
begin
    -- get account_id, agent_id, split_hash and product_id
    begin
        select a.id
            , a.agent_id
            , a.inst_id
            , a.split_hash
            , c.product_id
         into i_payment_rec.account_id
            , i_payment_rec.agent_id
            , i_payment_rec.inst_id
            , i_payment_rec.split_hash
            , i_payment_rec.product_id
         from acc_account a
            , prd_contract c
        where a.account_number = i_payment_rec.account_number
          and a.inst_id = i_inst_id
          and c.id = a.contract_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ACCOUNT_NOT_FOUND'
              , i_env_param1    => i_payment_rec.account_number
              , i_env_param2    => i_inst_id
            );
    end;

    --get card_id
    if i_payment_rec.card_number is not null then
        i_payment_rec.card_id := iss_api_card_pkg.get_card_id(i_card_number => i_payment_rec.card_number); -- exception isn't raised
        
        if i_payment_rec.card_id is not null then
            trc_log_pkg.debug(
                i_text  => 'card_id='|| i_payment_rec.card_id
            );
        else
            com_api_error_pkg.raise_error(
                i_error         => 'CARD_NOT_FOUND'
              , i_env_param1    => iss_api_card_pkg.get_card_mask(i_payment_rec.card_number)
              , i_env_param2    => i_payment_rec.originator_refnum
            );
        end if;
    end if;

    --get operation of payment
    select max(o.id)
        , max(o.original_id)
        , max(o.is_reversal)
        , max(o.host_date)
        , max(o.oper_currency)
        , count(1)
     into i_payment_rec.oper_id
        , i_payment_rec.original_oper_id
        , i_payment_rec.is_reversal
        , i_payment_rec.posting_date
        , i_payment_rec.currency
        , l_count
     from opr_operation o
        , opr_participant iss            
    where o.id = iss.oper_id 
      and o.is_reversal = 0
      --and nvl(o.oper_amount, 0) = nvl(i_payment_rec.amount, 0)
      and originator_refnum = i_payment_rec.originator_refnum
      and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
      and (iss.account_id = i_payment_rec.account_id or iss.account_number = i_payment_rec.account_number);
    
    if l_count = 0 then
        begin
            select o.id
                 , o.original_id
                 , o.is_reversal
                 , o.host_date
                 , o.oper_currency
              into i_payment_rec.oper_id
                 , i_payment_rec.original_oper_id
                 , i_payment_rec.is_reversal
                 , i_payment_rec.posting_date
                 , i_payment_rec.currency
              from opr_operation o
                 , opr_participant iss
                 , opr_card c
             where o.id = iss.oper_id 
               and o.is_reversal = 0
               --and nvl(o.oper_amount, 0) = nvl(i_payment_rec.amount, 0)
               and originator_refnum = i_payment_rec.originator_refnum
               and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and c.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and o.id = c.oper_id(+) 
               and (iss.card_id = i_payment_rec.card_id 
                    or
                    reverse(c.card_number) = reverse(iss_api_token_pkg.encode_card_number(i_card_number => i_payment_rec.card_number))
               );
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'OPERATION_NOT_FOUND: i_payment_rec.originator_refnum [#1], i_payment_rec.card_id [#2], i_payment_rec.account_id [#3], i_payment_rec.account_number [#4]'
                  , i_env_param1    => i_payment_rec.originator_refnum
                  , i_env_param2    => i_payment_rec.card_id
                  , i_env_param3    => i_payment_rec.account_id
                  , i_env_param4    => i_payment_rec.account_number
                );
            
                com_api_error_pkg.raise_error(
                    i_error         => 'OPERATION_NOT_FOUND'
                  , i_env_param1    => i_payment_rec.originator_refnum
                  , i_env_param2    => i_inst_id
                );
           when too_many_rows then          
                trc_log_pkg.debug(
                    i_text          => 'TOO_MANY_OPERATIONS: i_payment_rec.originator_refnum [#1], i_payment_rec.card_number [#2], i_payment_rec.card_id [#3]'
                  , i_env_param1    => i_payment_rec.originator_refnum
                  , i_env_param2    => iss_api_card_pkg.get_card_mask(i_payment_rec.card_number)
                  , i_env_param3    => i_payment_rec.card_id
                );
                    
                com_api_error_pkg.raise_error(
                    i_error         => 'TOO_MANY_RECORDS_FOUND'
                );                 
        end;
        
    elsif l_count > 1 then
   
        trc_log_pkg.debug(
            i_text          => 'TOO_MANY_OPERATIONS: i_payment_rec.originator_refnum [#1], account_number [#2], account_id [#3]'
          , i_env_param1    => i_payment_rec.originator_refnum
          , i_env_param2    => i_payment_rec.account_number
          , i_env_param3    => i_payment_rec.account_id
        );
                    
        com_api_error_pkg.raise_error(
            i_error         => 'TOO_MANY_RECORDS_FOUND'
        );                             
    end if;
    
    trc_log_pkg.debug (
        i_text  => 'Operation_id='|| i_payment_rec.oper_id
    );

    -- get settl_day
    i_payment_rec.sttl_day := com_api_sttl_day_pkg.get_open_sttl_day(i_inst_id);

    --get id
    i_payment_rec.id := com_api_id_pkg.get_id(i_seq => acc_macros_seq.nextval);
    trc_log_pkg.debug(
        i_text          => 'Id=' || i_payment_rec.id
    );

    --search invoice of invoice_date
    begin
        if i_payment_rec.invoice_date is null then
            i_payment_rec.invoice_id := null;
            i_payment_rec.is_new := 1;
        else
            select i.id
              into i_payment_rec.invoice_id
              from crd_invoice_vw i
             where i.account_id = i_payment_rec.account_id
               and i.invoice_date = i_payment_rec.invoice_date
               and i.split_hash = i_payment_rec.split_hash;

            i_payment_rec.is_new := 0;
        end if;
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text          => 'INVOICE_NOT_FOUND: account_id=' || i_payment_rec.account_id || ', invoice_date=' || com_api_type_pkg.convert_to_char(i_payment_rec.invoice_date)
            );
            com_api_error_pkg.raise_error(
                i_error         => 'INVOICE_NOT_FOUND'
              , i_env_param1    => com_api_type_pkg.convert_to_char(i_payment_rec.invoice_date)
            );
    end;
    trc_log_pkg.debug (
        i_text  => 'invoice_id='|| i_payment_rec.invoice_id
    );

    --create row
    insert into crd_payment(
        id
        , oper_id
        , is_reversal
        , original_oper_id
        , account_id
        , card_id
        , product_id
        , posting_date
        , sttl_day
        , currency
        , amount
        , pay_amount
        , is_new
        , status
        , inst_id
        , agent_id
        , split_hash
    ) values (
        i_payment_rec.id
        , i_payment_rec.oper_id
        , i_payment_rec.is_reversal
        , i_payment_rec.original_oper_id
        , i_payment_rec.account_id
        , i_payment_rec.card_id
        , i_payment_rec.product_id
        , i_payment_rec.posting_date
        , i_payment_rec.sttl_day
        , i_payment_rec.currency
        , i_payment_rec.amount
        , case when i_payment_rec.status = crd_api_const_pkg.PAYMENT_STATUS_SPENT then 0 
               else i_payment_rec.pay_amount
          end        
        , i_payment_rec.is_new
        , i_payment_rec.status
        , i_payment_rec.inst_id
        , i_payment_rec.agent_id
        , i_payment_rec.split_hash
    );
    trc_log_pkg.debug (
        i_text  => 'Insert payment ' || i_payment_rec.id
    );

    if i_payment_rec.debt_payment is not null then
        register_debt_payment(
            i_payment_rec      => i_payment_rec
        );
    end if;

    --save crd_invoice_payment if invoice exists
    if i_payment_rec.invoice_id is not null and i_payment_rec.status = crd_api_const_pkg.PAYMENT_STATUS_ACTIVE then
    
        l_last_invoice_id := 
            crd_invoice_pkg.get_last_invoice_id(
                i_account_id        => i_payment_rec.account_id
              , i_split_hash        => i_payment_rec.split_hash
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            
        insert into crd_invoice_payment(
            id
            , invoice_id
            , pay_id
            , pay_amount
            , is_new
            , split_hash
          ) values (
            com_api_id_pkg.get_id(crd_invoice_payment_seq.nextval, i_payment_rec.id)
            , l_last_invoice_id
            , i_payment_rec.id
            , i_payment_rec.pay_amount
            , case when l_last_invoice_id = i_payment_rec.invoice_id then com_api_const_pkg.TRUE else com_api_const_pkg.FALSE end
            , i_payment_rec.split_hash
        );
    end if;

    -- create macros
    trc_log_pkg.debug(
        i_text          => 'crate macros for payment ' || i_payment_rec.id
    );

    insert into acc_macros (
        id
        , entity_type
        , object_id
        , macros_type_id
        , posting_date
        , account_id
        , amount
        , currency
        , amount_purpose
        , fee_id
        , fee_tier_id
        , fee_mod_id
        , details_data
        , status
        , cancel_indicator
    ) values (
        i_payment_rec.id
        , opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_payment_rec.oper_id
        , 1003
        , i_payment_rec.posting_date
        , i_payment_rec.account_id
        , i_payment_rec.amount
        , i_payment_rec.currency
        , null
        , null
        , null
        , null
        , null
        , acc_api_const_pkg.MACROS_STATUS_POSTED
        , com_api_const_pkg.INDICATOR_NOT_CANCELED
    );

    trc_log_pkg.debug(
        i_text          => 'macros created'
    );

end;

procedure apply_payment(
    i_inst_id     in  com_api_type_pkg.t_inst_id
) is
    l_eff_date                  date;

    l_param_tab             com_api_type_pkg.t_param_tab;
    l_payment_condition     com_api_type_pkg.t_dict_value;
    l_service_id            com_api_type_pkg.t_short_id;
    l_repay_mad_first       com_api_type_pkg.t_boolean;
    l_bunch_id              com_api_type_pkg.t_long_id;
    l_debt_added            com_api_type_pkg.t_boolean;
    l_debt_id_tab           com_api_type_pkg.t_number_tab;
    l_original_oper_id      com_api_type_pkg.t_long_id;
    l_payment_id            com_api_type_pkg.t_long_id;
    l_payment_amount        com_api_type_pkg.t_money;
    l_from_id               com_api_type_pkg.t_long_id;
    l_till_id               com_api_type_pkg.t_long_id;
    l_unpaid_debt           com_api_type_pkg.t_money;
    l_uncharged_intrst      com_api_type_pkg.t_money;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_charge_interest       com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE;
    
begin
    trc_log_pkg.debug (
        i_text  => 'apply_payment started'
    );
   
    -- get effective date
    l_eff_date := com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => i_inst_id);

    for rec in (
          select a.id account_id
               , a.account_number
               , b.balance
               , a.split_hash
               , c.product_id
               , a.currency
               , a.account_type               
            from acc_account a
               , acc_balance b
               , prd_contract c
               , prd_service_object o
               , prd_service s
           where a.id = b.account_id
             and a.contract_id      = c.id
             and b.balance_type     = acc_api_const_pkg.BALANCE_TYPE_LEDGER
             and a.account_type     = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
             and b.balance > 0
             and o.entity_type      = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
             and o.object_id        = a.id
             and o.split_hash       = a.split_hash
             and o.service_id       = s.id
             and s.service_type_id  = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
             and l_eff_date between nvl(trunc(o.start_date), l_eff_date) and nvl(o.end_date, trunc(l_eff_date)+1)
    )loop       
        begin   
            -- get payment
            select max(id)
                 , max(original_oper_id)
              into l_payment_id
                 , l_original_oper_id
              from crd_payment
             where account_id = rec.account_id;
  
            trc_log_pkg.debug('apply_payment: l_payment_id=['||l_payment_id||'], l_original_oper_id=[' || l_original_oper_id || ']');

            if l_payment_id is not null then
                
                --ledger
                l_payment_amount := rec.balance;
                
                -- get service_id    
                l_service_id :=
                    prd_api_service_pkg.get_active_service_id(
                        i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id         => rec.account_id
                      , i_attr_name         => null
                      , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                      , i_split_hash        => rec.split_hash
                      , i_eff_date          => l_eff_date
                      , i_inst_id           => i_inst_id
                    );

                begin
                    l_charge_interest :=
                        nvl(prd_api_product_pkg.get_attr_value_number(
                            i_product_id    => rec.product_id
                          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => rec.account_id
                          , i_attr_name     => crd_api_const_pkg.CHARGE_INTR_BEFORE_PAYMENT
                          , i_split_hash    => rec.split_hash
                          , i_service_id    => l_service_id
                          , i_params        => l_param_tab
                          , i_eff_date      => l_eff_date
                          , i_inst_id       => i_inst_id
                        ), com_api_const_pkg.TRUE);

                exception
                    when com_api_error_pkg.e_application_error then
                        if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then

                            trc_log_pkg.debug('Attribute value [CRD_CHARGE_INTR_BEFORE_PAYMENT] not defined. Set attribute = 1');
                            l_charge_interest := com_api_const_pkg.TRUE;
                        else
                            raise;

                        end if;
                    when others then
                        trc_log_pkg.debug('Get attribute value error. '||sqlerrm);
                        raise;
                end;
                trc_log_pkg.debug('l_charge_interest=' || l_charge_interest);

                if l_charge_interest = com_api_const_pkg.TRUE then
    
                    -- calc interest
                    crd_interest_pkg.charge_interest(
                           i_account_id        => rec.account_id
                         , i_eff_date          => l_eff_date
                         , i_split_hash        => rec.split_hash
                    );
                end if;

                l_payment_condition :=
                    prd_api_product_pkg.get_attr_value_char(
                        i_product_id    => rec.product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => rec.account_id
                      , i_attr_name     => crd_api_const_pkg.PAYMENT_CONDITION
                      , i_params        => l_param_tab
                      , i_eff_date      => l_eff_date
                      , i_service_id    => l_service_id
                      , i_split_hash    => rec.split_hash
                      , i_inst_id       => i_inst_id
                    );
                trc_log_pkg.debug('apply_payment: l_payment_condition=['||l_payment_condition||']');

                l_repay_mad_first :=
                    prd_api_product_pkg.get_attr_value_number(
                        i_product_id    => rec.product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => rec.account_id
                      , i_attr_name     => crd_api_const_pkg.REPAY_MAD_FIRST
                      , i_params        => l_param_tab
                      , i_eff_date      => l_eff_date
                      , i_service_id    => l_service_id
                      , i_split_hash    => rec.split_hash
                      , i_inst_id       => i_inst_id
                    );
                trc_log_pkg.debug('apply_payment: l_repay_mad_first=['||l_repay_mad_first||']');

                for r in (
                    select d.id debt_id
                         , e.bunch_type_id
                         , case when d.is_new = com_api_const_pkg.TRUE or l_repay_mad_first = com_api_const_pkg.FALSE then b.amount
                                when iteration = 1 then b.min_amount_due
                                else b.amount - b.min_amount_due
                           end amount
                         , b.balance_type
                         , d.macros_type_id
                         , d.card_id
                      from crd_debt d
                         , crd_debt_balance b
                         , crd_event_bunch_type e
                         , (select rownum iteration from dual connect by rownum <=2)
                     where decode(d.status, 'DBTSACTV', d.account_id, null) = rec.account_id
                       and d.id           = b.debt_id
                       and b.amount       > 0
                       and e.balance_type = b.balance_type
                       and e.inst_id      = d.inst_id
                       and e.event_type   = crd_api_const_pkg.APPLY_PAYMENT_EVENT
                       and e.bunch_type_id is not null
                       and d.split_hash   = rec.split_hash
                       and b.split_hash   = rec.split_hash
                       and b.id >= trunc(d.id, com_api_id_pkg.DAY_ROUNDING)
                       and not (iteration = 2 and b.amount = b.min_amount_due and d.is_new = com_api_const_pkg.FALSE)
                       and not (iteration = 1 and (d.is_new = com_api_const_pkg.TRUE or l_repay_mad_first = com_api_const_pkg.FALSE))
                       and (
                            (l_original_oper_id = d.oper_id)
                            or
                            (l_payment_condition = crd_api_const_pkg.REPAY_COND_NO_CONDITION)
                            or
                            (
                             l_payment_condition = crd_api_const_pkg.REPAY_COND_INVOICED_DEBT
                             and
                             d.is_new = com_api_const_pkg.FALSE
                            )
                            or
                            (
                             l_payment_condition = crd_api_const_pkg.REPAY_COND_BETW_INVOICE_DUE
                             and
                             d.is_new = com_api_const_pkg.FALSE
                             and
                             exists (
                                     select null
                                       from crd_invoice a
                                          , crd_invoice_debt c
                                      where c.debt_id    = d.id
                                        and c.invoice_id = a.id
                                        and l_eff_date between a.invoice_date and a.penalty_date
                                    )
                            )
                           )
                       and b.id >= trunc(d.id, com_api_id_pkg.DAY_ROUNDING)
                       and d.is_grace_enable = com_api_const_pkg.FALSE
                     order by decode(l_original_oper_id, d.oper_id, 0, 1, 1), iteration, b.repay_priority, d.posting_date
                ) loop

                    trc_log_pkg.debug('apply_payment: pay debt=['||r.debt_id||'] balance type=['||r.balance_type||'] amount=['||r.amount||']');

                    rul_api_param_pkg.set_param (
                        i_name       => 'CARD_TYPE_ID'
                        , io_params  => l_param_tab
                        , i_value    => iss_api_card_pkg.get_card(i_card_id => r.card_id).card_type_id
                    );

                    acc_api_entry_pkg.put_bunch (
                        o_bunch_id          => l_bunch_id
                      , i_bunch_type_id     => r.bunch_type_id
                      , i_macros_id         => r.debt_id
                      , i_amount            => least(l_payment_amount, r.amount)
                      , i_currency          => rec.currency
                      , i_account_type      => rec.account_type
                      , i_account_id        => rec.account_id
                      , i_posting_date      => l_eff_date
                      , i_macros_type_id    => r.macros_type_id
                      , i_param_tab         => l_param_tab
                    );

                    l_debt_added := com_api_const_pkg.FALSE;
                    for i in 1..l_debt_id_tab.count loop
                        if l_debt_id_tab(i) = r.debt_id then
                            l_debt_added := com_api_const_pkg.TRUE;
                            exit;
                        end if;
                    end loop;

                    if l_debt_added = com_api_const_pkg.FALSE then
                        l_debt_id_tab(l_debt_id_tab.count + 1) := r.debt_id;
                    end if;

                    insert into crd_debt_payment(
                        id
                      , debt_id
                      , balance_type
                      , pay_id
                      , pay_amount
                      , eff_date
                      , split_hash
                    ) values (
                        com_api_id_pkg.get_id(crd_debt_payment_seq.nextval, r.debt_id)
                      , r.debt_id
                      , r.balance_type
                      , l_payment_id
                      , least(l_payment_amount, r.amount)
                      , l_eff_date
                      , rec.split_hash
                    );

                    l_payment_amount := l_payment_amount - r.amount;

                    trc_log_pkg.debug('apply_payment: payment amount=['||l_payment_amount||']');

                    exit when l_payment_amount <= 0;

                end loop;

                acc_api_entry_pkg.flush_job;

                for i in 1..l_debt_id_tab.count loop
                    crd_debt_pkg.set_balance(
                        i_debt_id           => l_debt_id_tab(i)
                      , i_eff_date          => l_eff_date
                      , i_account_id        => rec.account_id
                      , i_service_id        => l_service_id
                      , i_inst_id           => i_inst_id
                      , i_split_hash        => rec.split_hash
                    );

                    crd_interest_pkg.set_interest(
                        i_debt_id           => l_debt_id_tab(i)
                      , i_eff_date          => l_eff_date
                      , i_account_id        => rec.account_id
                      , i_service_id        => l_service_id
                      , i_split_hash        => rec.split_hash
                    );

                    l_from_id      := com_api_id_pkg.get_from_id_num(l_debt_id_tab(i));
                    l_till_id      := com_api_id_pkg.get_till_id_num(l_debt_id_tab(i));

                    select nvl(sum(amount), 0)
                      into l_unpaid_debt
                      from crd_debt_balance
                     where debt_id    = l_debt_id_tab(i)
                       and balance_type != acc_api_const_pkg.BALANCE_TYPE_LEDGER
                       and split_hash = rec.split_hash
                       and id between l_from_id and l_till_id;

                    if l_unpaid_debt = 0 then
                        select count(1)
                          into l_uncharged_intrst
                          from crd_debt_interest
                         where debt_id    = l_debt_id_tab(i)
                           and is_charged = com_api_const_pkg.FALSE
                           and amount > 0
                           and split_hash = rec.split_hash
                           and id between l_from_id and l_till_id;
                    end if;

                    if l_unpaid_debt = 0 and l_uncharged_intrst = 0 then
                        update crd_debt
                           set status     = crd_api_const_pkg.DEBT_STATUS_PAID
                         where id         = l_debt_id_tab(i);
                    end if;
                end loop;

                
                update crd_payment
                   set pay_amount = case when status = crd_api_const_pkg.PAYMENT_STATUS_SPENT then 0 
                                         else greatest(0, l_payment_amount)
                                    end     
                     , status     = case when (greatest(0, l_payment_amount) = 0 or status = crd_api_const_pkg.PAYMENT_STATUS_SPENT) then crd_api_const_pkg.PAYMENT_STATUS_SPENT
                                         else status
                                    end
                 where id         = l_payment_id;

            else
                trc_log_pkg.debug(
                    i_text          => 'PAYMENT_NOT_FOUND: account_id=' || rec.account_id || ', account_number=' || rec.account_number || ', split_hash=' || rec.split_hash
                );
            end if;
                    
        exception
            when others then
                trc_log_pkg.debug(
                    i_text          => 'UNHANDLED_EXCEPTION: account_id=' || rec.account_id || ', account_number=' || rec.account_number || ', split_hash=' || rec.split_hash || ', sqlerrm=' ||sqlerrm
                );   
        end;
    end loop;

    trc_log_pkg.debug(
        i_text          => 'l_processed_count=' || l_processed_count || ', l_excepted_count=' || l_excepted_count
    );
    trc_log_pkg.debug (
        i_text  => 'apply_payment finished'
    );
    
end;

procedure load_payment(
    i_inst_id       com_api_type_pkg.t_inst_id
)is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;

begin
    savepoint read_payments_start;

    trc_log_pkg.debug(
        i_text          => 'Read payments'
    );

    prc_api_stat_pkg.log_start;

    open cur_payment_count;
    fetch cur_payment_count into l_estimated_count;
    close cur_payment_count;
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    open    cur_payments;

    trc_log_pkg.debug(
        i_text          => 'cursor opened'
    );

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching '||BULK_LIMIT||' payments'
        );

        fetch cur_payments bulk collect into l_payment_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 payments fetched'
          , i_env_param1    => l_payment_tab.count
        );

        for i in 1 .. l_payment_tab.count loop
            savepoint register_payments_start;

            begin
                register_payment (
                    i_payment_rec     => l_payment_tab(i)
                    , i_inst_id       => i_inst_id
                );
            exception
                when others then
                    rollback to savepoint register_payments_start;
                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        l_excepted_count := l_excepted_count + 1;
                    else
                        raise;

                    end if;
            end;
            
            l_processed_count := l_processed_count + 1;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;
        end loop;

        exit when cur_payments%notfound;
    end loop;
    close cur_payments;

    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text  => 'Read payments finished'
    );

    apply_payment(
        i_inst_id     => i_inst_id
    );
    
exception
    when others then
        rollback to savepoint read_payments_start;
        if cur_payments%isopen then
            close   cur_payments;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

        raise;
end;

end;
/
