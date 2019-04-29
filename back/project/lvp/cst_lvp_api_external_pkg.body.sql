create or replace package body cst_lvp_api_external_pkg as

function find_invoice_id (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_account_id          in     com_api_type_pkg.t_account_id
  , i_eff_date            in     date
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_medium_id
is
    LOG_PREFIX   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.find_invoice_id: ';
    l_invoice_id          com_api_type_pkg.t_medium_id;
    l_split_hash          com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'account [#1], date [#2]'
      , i_env_param1  => i_account_id
      , i_env_param2  => to_char(i_eff_date, 'yyyy-mm-dd hh24:mi:ss')
      , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => i_account_id
    );

    l_split_hash :=
        com_api_hash_pkg.get_split_hash (
            i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id       => i_account_id
        );

    for rec in (
        select t.id
          from (
                select i.id
                     , i.invoice_date
                  from crd_invoice i
                 where i.inst_id = i_inst_id
                   and i.account_id = i_account_id
                   and i.split_hash = l_split_hash
               ) t
         where i_eff_date >= t.invoice_date
         order by t.id desc
    ) loop
        return rec.id;
    end loop;

    if i_mask_error = com_api_type_pkg.TRUE then
        trc_log_pkg.debug (
            i_text        => LOG_PREFIX || 'No invoice found'
          , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => i_account_id
        );
        return com_api_type_pkg.FALSE;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'INVOICE_NOT_FOUND'
        );
    end if;
end find_invoice_id;


procedure invoice_info (
    i_invoice_id          in     com_api_type_pkg.t_medium_id
  , o_ref_cursor             out sys_refcursor
)
is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.invoice_info: ';
    l_exceed_limit            com_api_type_pkg.t_amount_rec;
    l_credit_limit            com_api_type_pkg.t_money;
    l_cash_limit              com_api_type_pkg.t_money;
    l_avail_cash_amount       com_api_type_pkg.t_money;
    l_account_number          com_api_type_pkg.t_account_number;
    l_previous_tad            com_api_type_pkg.t_money;
    l_previous_own_funds      com_api_type_pkg.t_money;
    l_debits_amount           com_api_type_pkg.t_money;
    l_credits_amount          com_api_type_pkg.t_money;
    l_account_id              com_api_type_pkg.t_account_id;
    l_own_funds               com_api_type_pkg.t_money;
    l_total_amount_due        com_api_type_pkg.t_money;
    l_min_amount_due          com_api_type_pkg.t_money;
    l_interest_amount         com_api_type_pkg.t_money;
    l_expense_amount          com_api_type_pkg.t_money;
    l_dpp_interest_amount     com_api_type_pkg.t_money;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_invoice_date            date;
    l_due_date                date;
begin

    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'invoice [#1]'
      , i_env_param1  => i_invoice_id
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id   => i_invoice_id
    );

    -- Get invoice information
    begin
        select i.account_id
             , nvl(i.total_amount_due, 0)
             , nvl(i.own_funds, 0)
             , nvl(i.min_amount_due, 0)
             , nvl(i.interest_amount, 0)
             , nvl(i.expense_amount, 0)
             , i.invoice_date
             , i.due_date
             , i.inst_id
             , i.split_hash
             , a.account_number
          into l_account_id
             , l_total_amount_due
             , l_own_funds
             , l_min_amount_due
             , l_interest_amount
             , l_expense_amount
             , l_invoice_date
             , l_due_date
             , l_inst_id
             , l_split_hash
             , l_account_number
          from crd_invoice i
             , acc_account a
         where i.account_id = a.id
           and i.id = i_invoice_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error       => 'INVOICE_NOT_FOUND'
              , i_env_param1  => i_invoice_id
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
              , i_object_id   => i_invoice_id
            );
    end;

    -- Get previous invoice information
    begin
        select i.total_amount_due
             , i.own_funds
          into l_previous_tad
             , l_previous_own_funds
          from crd_invoice_vw i
             , (
                select a.id
                     , lag(a.id) over (order by a.invoice_date, a.id) lag_id
                  from crd_invoice_vw a
                 where a.account_id = l_account_id
               ) i2
         where i.id = i2.lag_id
           and i2.id = i_invoice_id;
    exception
        when no_data_found then
            l_previous_tad := 0;
            l_previous_own_funds := 0;
    end;

    -- Get credit limit and cash limit:
    l_exceed_limit :=
        acc_api_balance_pkg.get_balance_amount (
            i_account_id     => l_account_id
          , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
          , i_date           => l_invoice_date
          , i_date_type      => com_api_const_pkg.DATE_PURPOSE_PROCESSING
          , i_mask_error     => com_api_const_pkg.TRUE
        );
    l_credit_limit := nvl(l_exceed_limit.amount, 0);

    cst_lvp_com_pkg.get_cash_limit_value(
        i_account_id     => l_account_id
      , i_split_hash     => l_split_hash
      , i_inst_id        => l_inst_id
      , i_date           => l_invoice_date
      , o_value          => l_cash_limit
      , o_current_sum    => l_avail_cash_amount
    );

    if l_cash_limit = -1 then
        l_cash_limit := l_credit_limit;
    end if;
    l_cash_limit := nvl(l_cash_limit, 0);

    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Credit limit [#1], cash limit [#2]'
      , i_env_param1  => l_credit_limit
      , i_env_param2  => l_cash_limit
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id   => i_invoice_id
    );

    -- Get DPP interest total (currently it's being counted twice in invoice: in expense_amount and interest_amount)
    l_dpp_interest_amount := 0;
--    -- >> Phase 2
--    
--    select nvl(sum(amount), 0)
--      into l_dpp_interest_amount
--      from crd_debt
--     where macros_type_id = 7182 -- DPP interest
--       and split_hash = l_split_hash
--       and oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
--       and status in (
--                       crd_api_const_pkg.DEBT_STATUS_PAID
--                     , crd_api_const_pkg.DEBT_STATUS_ACTIVE
--                     )
--       and id in (select debt_id
--                    from crd_invoice_debt_vw
--                   where invoice_id = l_invoice_id
--                     and is_new = com_api_type_pkg.TRUE);

    -- Get debits:
    l_debits_amount := nvl(l_expense_amount, 0) + nvl(l_interest_amount, 0) - nvl(l_dpp_interest_amount, 0);

    -- Get credits:
    -- Get total payments amount
    select nvl(sum(p.amount), 0)
      into l_credits_amount
      from crd_invoice_payment i
         , crd_payment p
     where i.invoice_id = i_invoice_id
       and p.id = i.pay_id
       and i.split_hash = l_split_hash
       and p.split_hash = l_split_hash
       and i.is_new = com_api_type_pkg.TRUE
       and not exists
           (select 1
              from opr_operation po
             where po.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER
               and po.id = p.oper_id);

    open o_ref_cursor for
    select l_account_number as account_number
         , l_credit_limit as credit_limit
         , l_cash_limit as cash_limit
         , l_invoice_date - com_api_const_pkg.ONE_SECOND as invoice_date
         , l_due_date as due_date
         , l_previous_tad as previous_tad
         , l_previous_own_funds as previous_own_funds
         , l_debits_amount as debits_amount
         , l_credits_amount as credits_amount
         , l_total_amount_due as total_amount_due
         , l_min_amount_due as min_amount_due
      from dual;

end invoice_info;

procedure invoice_transactions (
    i_invoice_id          in     com_api_type_pkg.t_medium_id
  , i_account_id          in     com_api_type_pkg.t_account_id  default null
  , i_lang                in     com_api_type_pkg.t_dict_value  default null
  , o_ref_cursor             out sys_refcursor
)
is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.invoice_transactions: ';
    l_account_id              com_api_type_pkg.t_account_id;
    l_main_card_id            com_api_type_pkg.t_medium_id;
    l_main_card_number        com_api_type_pkg.t_card_number;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_invoice                 crd_api_type_pkg.t_invoice_rec;
    l_account                 acc_api_type_pkg.t_account_rec;
    l_lang                    com_api_type_pkg.t_dict_value;
    l_interest_amount         com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'invoice [#1], account [#2], language [#3]'
      , i_env_param1  => i_invoice_id
      , i_env_param2  => i_account_id
      , i_env_param3  => i_lang
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id   => i_invoice_id
    );

    l_account_id := i_account_id;
    l_invoice :=
        crd_invoice_pkg.get_invoice (
            i_invoice_id  => i_invoice_id
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    if l_account_id is null then
        l_account_id := l_invoice.account_id;
    end if;

    l_account :=
        acc_api_account_pkg.get_account (
            i_account_id  => l_account_id
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    l_split_hash := l_account.split_hash;

    -- Get main card (Primary or other existing)
    l_main_card_id := 
        cst_lvp_com_pkg.get_main_card_id (
            i_account_id => l_account_id
          , i_split_hash => l_split_hash
        );

    select iss_api_token_pkg.decode_card_number(
               i_card_number => icn.card_number
             , i_mask_error  => com_api_type_pkg.TRUE
           ) as card_number
      into l_main_card_number
      from iss_card_number icn
     where icn.card_id = l_main_card_id;

    l_lang := nvl(i_lang, get_user_lang);

    select nvl(i.interest_amount, 0)
      into l_interest_amount
      from crd_invoice i
     where i.id = i_invoice_id;

    open o_ref_cursor for
    select t.oper_id as oper_id
         , t.oper_part_num as oper_part_num
         , t.oper_date as oper_date
         , nvl(t.card_id, l_main_card_id) as card_id
         , t.oper_type_name as oper_type_name
         , t.posting_date as posting_date
         , trim(t.merchant_name) as merchant_name
         , trim(t.merchant_country) as merchant_country
         , t.oper_currency as oper_currency
         , cc2.name as oper_currency_name
         , cc2.exponent as oper_currency_expo
         , t.oper_amount as oper_amount
         , t.transaction_amount as transaction_amount
         , cc1.name as currency_name
         , cc1.exponent as currency_expo
         , case when icn.card_number is null
                then iss_api_card_pkg.get_card_mask(l_main_card_number)
                else iss_api_card_pkg.get_card_mask(
                         iss_api_token_pkg.decode_card_number(
                             i_card_number => icn.card_number
                           , i_mask_error  => com_api_type_pkg.TRUE
                         )
                     )
           end as card_number_masked
         , case when t.card_id = l_main_card_id 
                then com_api_type_pkg.TRUE 
                else com_api_type_pkg.FALSE
           end as card_is_main
         , t.terminal_type
         , t.originator_refnum
         , iss_api_card_pkg.get_card_mask(l_main_card_number) as main_card_number
         , t.auth_code
      from (
            select oo.id as oper_id
                 , oo.oper_date
                 , case when d.fee_amount > 0
                        then 2
                        else 1
                   end as oper_part_num
                 , d.card_id
                 , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                        then com_api_dictionary_pkg.get_article_text(oo.oper_reason, l_lang)
                        when oo.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
                        then 'DPP'
                        else case when d.fee_amount > 0
                                  then 'Fee for ' || replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '')
                                  else replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '')
                             end
                   end as oper_type_name
                 , d.posting_date
                 , oo.merchant_name
                 , oo.merchant_country
                 , oo.terminal_type
                 , oo.originator_refnum
                 , case when d.fee_amount > 0
                        then d.currency
                        else oo.oper_currency
                   end as oper_currency
                 , case when d.fee_amount > 0
                        then d.fee_amount
                        else oo.oper_amount
                   end as oper_amount
                 , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                        then d.fee_amount
                        else case when d.fee_amount > 0
                                  then d.fee_amount
                                  else d.transaction_amount
                        end
                   end as transaction_amount
                 , d.currency
                 , iss.auth_code
              from (
                    select cd.account_id
                         , cd.card_id
                         , cd.oper_id
                         , cd.oper_type
                         , cd.id as debt_id
                         , cd.currency
                         , sum(cd.transaction_amount) as transaction_amount
                         , sum(cd.fee_amount) as fee_amount
                         , min(cd.posting_date) as posting_date
                      from (
                            select distinct debt_id
                              from crd_invoice_debt_vw
                             where invoice_id = i_invoice_id
                               and split_hash = l_split_hash
                               and is_new = com_api_type_pkg.TRUE
                           ) cid -- debts included into invoice
                         , (
                            select d.id
                                 , d.account_id
                                 , d.card_id
                                 , d.service_id
                                 , d.oper_id
                                 , d.oper_type
                                 , d.currency
                                 , d.posting_date
                                 , case when d.macros_type_id in (
                                                                  select numeric_value
                                                                    from com_ui_array_element_vw
                                                                   where array_id = cst_lvp_const_pkg.ARRAY_FEE_MACROS_TYPE -- -50000025
                                                                     and lang = com_api_const_pkg.LANGUAGE_ENGLISH
                                                                 ) 
                                        then 0
                                        when d.macros_type_id in (
                                                                  select numeric_value
                                                                    from com_ui_array_element_vw
                                                                   where array_id = cst_lvp_const_pkg.ARRAY_CARDHLDR_CR_MACROS_TYPE -- -50000028
                                                                     and lang = com_api_const_pkg.LANGUAGE_ENGLISH
                                                                 )
                                        then -d.amount
                                        else d.amount
                                   end as transaction_amount 
                                 , case when d.macros_type_id in (
                                                                  select numeric_value
                                                                    from com_ui_array_element_vw
                                                                   where array_id = cst_lvp_const_pkg.ARRAY_DEBIT_FEE_MACROS_TYPE -- -50000026
                                                                     and lang = com_api_const_pkg.LANGUAGE_ENGLISH
                                                                 )
                                        then d.amount
                                        when d.macros_type_id in (
                                                                  select numeric_value
                                                                    from com_ui_array_element_vw
                                                                   where array_id = cst_lvp_const_pkg.ARRAY_CREDIT_FEE_MACROS_TYPE -- -50000027
                                                                     and lang = com_api_const_pkg.LANGUAGE_ENGLISH
                                                                 )
                                        then -d.amount
                                        else 0
                                   end as fee_amount
                              from crd_debt d
                             where d.status in (
                                                 crd_api_const_pkg.DEBT_STATUS_PAID
                                               , crd_api_const_pkg.DEBT_STATUS_ACTIVE
                                               )
                           ) cd -- amounts from debts
                     where cd.id = cid.debt_id
                     group by
                           cd.account_id
                         , cd.card_id
                         , cd.oper_id
                         , cd.id
                         , cd.oper_type
                         , cd.currency
                   ) d
                 , opr_operation oo
                 , opr_participant iss
             where d.oper_id = oo.id(+)
               and iss.oper_id(+) = oo.id
               and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
            union all
            select oo.id as oper_id
                 , oo.oper_date
                 , null as oper_part_num
                 , l_main_card_id as card_id
                 , replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '') as oper_type_name
                 , cp.posting_date
                 , oo.merchant_name
                 , oo.merchant_country
                 , oo.terminal_type
                 , oo.originator_refnum
                 , oo.oper_currency
                 , -oo.oper_amount as oper_amount
                 , -nvl(cp.amount, 0) as account_amount
                 , cp.currency as account_currency
                 , iss.auth_code
              from crd_invoice_payment cip
                 , crd_payment cp
                 , opr_operation oo
                 , opr_participant iss
             where cip.invoice_id = i_invoice_id
               and cp.id = cip.pay_id
               and cip.split_hash = l_split_hash
               and cp.split_hash = l_split_hash
               and cip.is_new = com_api_type_pkg.TRUE
               and oo.oper_type not in (dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER)
               and cp.oper_id = oo.id
               and iss.oper_id(+) = oo.id
               and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
           ) t
         , iss_card_number icn
         , com_currency cc1
         , com_currency cc2
     where t.card_id = icn.card_id(+)
       and t.currency = cc1.code(+)
       and t.oper_currency = cc2.code(+)
    union all
    select com_api_id_pkg.get_till_id(l_invoice.invoice_date - com_api_const_pkg.ONE_SECOND) as oper_id
         , 0 as oper_part_num
         , l_invoice.invoice_date - com_api_const_pkg.ONE_SECOND as oper_date
         , l_main_card_id as card_id
         , 'Interest amount' as oper_type_name
         , l_invoice.invoice_date - com_api_const_pkg.ONE_SECOND as posting_date
         , to_char(null) as merchant_name
         , to_char(null) as merchant_country
         , l_account.currency as oper_currency
         , cc.name as oper_currency_name
         , cc.exponent as oper_currency_expo
         , nvl(l_interest_amount, 0) as oper_amount
         , nvl(l_interest_amount, 0) as transaction_amount
         , cc.name as currency_name
         , cc.exponent as currency_expo
         , iss_api_card_pkg.get_card_mask(l_main_card_number) as card_number
         , com_api_type_pkg.TRUE as card_is_main
         , null as terminal_type
         , null as originator_refnum
         , iss_api_card_pkg.get_card_mask(l_main_card_number) as main_card_number
         , null as auth_code
      from com_currency cc
     where nvl(l_interest_amount, 0) > 0
       and cc.code = l_account.currency;

end invoice_transactions;

procedure transactions_by_date_range (
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_begin_date          in     date                           default null
  , i_end_date            in     date                           default null
  , i_lang                in     com_api_type_pkg.t_dict_value  default null
  , o_ref_cursor             out sys_refcursor
)
is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.transactions_by_date_range: ';
    l_account_id              com_api_type_pkg.t_account_id;
    l_main_card_id            com_api_type_pkg.t_medium_id;
    l_main_card_number        com_api_type_pkg.t_card_number;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_invoice                 crd_api_type_pkg.t_invoice_rec;
    l_account                 acc_api_type_pkg.t_account_rec;
    l_lang                    com_api_type_pkg.t_dict_value;
    l_from_id                 com_api_type_pkg.t_long_id;
    l_till_id                 com_api_type_pkg.t_long_id;
    l_begin_date              date;
    l_end_date                date;
begin
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'account [#1], begin date [#2], end date [#3], language [#4]'
      , i_env_param1  => i_account_id
      , i_env_param2  => to_char(i_begin_date, 'yyyy-mm-dd hh24:mi:ss')
      , i_env_param3  => to_char(i_end_date, 'yyyy-mm-dd hh24:mi:ss')
      , i_env_param4  => i_lang
      , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => i_account_id
    );

    l_account_id := i_account_id;

    l_account :=
        acc_api_account_pkg.get_account (
            i_account_id  => l_account_id
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    l_split_hash := l_account.split_hash;

    -- Get main card (Primary or other existing)
    l_main_card_id := 
        cst_lvp_com_pkg.get_main_card_id (
            i_account_id => l_account_id
          , i_split_hash => l_split_hash
        );

    select iss_api_token_pkg.decode_card_number(
               i_card_number => icn.card_number
             , i_mask_error  => com_api_type_pkg.TRUE
           ) as card_number
      into l_main_card_number
      from iss_card_number icn
     where icn.card_id = l_main_card_id;

    l_lang := nvl(i_lang, get_user_lang);
    
    l_begin_date := i_begin_date;
    if l_begin_date is null then
        select max(i.invoice_date)
          into l_begin_date
          from crd_invoice_vw i
         where i.account_id = l_account_id;
    end if;

    l_end_date := nvl(trunc(i_end_date), get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND;

    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Calculated begin date [#1], end date [#2]'
      , i_env_param1  => to_char(l_begin_date, 'yyyy-mm-dd hh24:mi:ss')
      , i_env_param2  => to_char(l_end_date, 'yyyy-mm-dd hh24:mi:ss')
      , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => i_account_id
    );

    l_from_id := com_api_id_pkg.get_from_id(l_begin_date);
    l_till_id := com_api_id_pkg.get_till_id(l_end_date);

    open o_ref_cursor for
    select t.oper_id as oper_id
         , t.oper_part_num as oper_part_num
         , t.oper_date as oper_date
         , nvl(t.card_id, l_main_card_id) as card_id
         , t.oper_type_name as oper_type_name
         , t.posting_date as posting_date
         , trim(t.merchant_name) as merchant_name
         , trim(t.merchant_country) as merchant_country
         , t.oper_currency as oper_currency
         , cc2.name as oper_currency_name
         , cc2.exponent as oper_currency_expo
         , t.oper_amount as oper_amount
         , t.transaction_amount as transaction_amount
         , cc1.name as currency_name
         , cc1.exponent as currency_expo
         , case when icn.card_number is null
                then iss_api_card_pkg.get_card_mask(l_main_card_number)
                else iss_api_card_pkg.get_card_mask(
                         iss_api_token_pkg.decode_card_number(
                             i_card_number => icn.card_number
                           , i_mask_error  => com_api_type_pkg.TRUE
                         )
                     )
           end as card_number_masked
         , case when t.card_id = l_main_card_id 
                then com_api_type_pkg.TRUE 
                else com_api_type_pkg.FALSE
           end as card_is_main
         , t.terminal_type
         , t.originator_refnum
         , iss_api_card_pkg.get_card_mask(l_main_card_number) as main_card_number
         , t.auth_code
      from (
            select oo.id as oper_id
                 , oo.oper_date
                 , case when d.fee_amount > 0
                        then 2
                        else 1
                   end as oper_part_num
                 , d.card_id
                 , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                        then com_api_dictionary_pkg.get_article_text(oo.oper_reason, l_lang)
                        when oo.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
                        then 'DPP'
                        else case when d.fee_amount > 0
                                  then 'Fee for ' || replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '')
                                  else replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '')
                             end
                   end as oper_type_name
                 , d.posting_date
                 , oo.merchant_name
                 , oo.merchant_country
                 , oo.terminal_type
                 , oo.originator_refnum
                 , case when d.fee_amount > 0
                        then d.currency
                        else oo.oper_currency
                   end as oper_currency
                 , case when d.fee_amount > 0
                        then d.fee_amount
                        else oo.oper_amount
                   end as oper_amount
                 , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                        then d.fee_amount
                        else case when d.fee_amount > 0
                                  then d.fee_amount
                                  else d.transaction_amount
                        end
                   end as transaction_amount
                 , d.currency
                 , iss.auth_code
              from (
                    select cd.account_id
                         , cd.card_id
                         , cd.oper_id
                         , cd.oper_type
                         , cd.id as debt_id
                         , cd.currency
                         , sum(cd.transaction_amount) as transaction_amount
                         , sum(cd.fee_amount) as fee_amount
                         , min(cd.posting_date) as posting_date
                      from (
                            select d.id as debt_id
                                 , d.amount
                              from crd_debt d
                             where d.split_hash = l_split_hash
                               and d.account_id = l_account_id
                               and d.is_new = com_api_type_pkg.TRUE
                               and d.id between l_from_id and l_till_id
                           ) cid -- only required debts
                         , (
                            select d.id
                                 , d.account_id
                                 , d.card_id
                                 , d.service_id
                                 , d.oper_id
                                 , d.oper_type
                                 , d.currency
                                 , d.posting_date
                                 , case when d.macros_type_id in (
                                                                  select numeric_value
                                                                    from com_ui_array_element_vw
                                                                   where array_id = cst_lvp_const_pkg.ARRAY_FEE_MACROS_TYPE -- -50000025
                                                                     and lang = com_api_const_pkg.LANGUAGE_ENGLISH
                                                                 ) 
                                        then 0
                                        when d.macros_type_id in (
                                                                  select numeric_value
                                                                    from com_ui_array_element_vw
                                                                   where array_id = cst_lvp_const_pkg.ARRAY_CARDHLDR_CR_MACROS_TYPE -- -50000028
                                                                     and lang = com_api_const_pkg.LANGUAGE_ENGLISH
                                                                 )
                                        then -d.amount
                                        else d.amount
                                   end as transaction_amount 
                                 , case when d.macros_type_id in (
                                                                  select numeric_value
                                                                    from com_ui_array_element_vw
                                                                   where array_id = cst_lvp_const_pkg.ARRAY_DEBIT_FEE_MACROS_TYPE -- -50000026
                                                                     and lang = com_api_const_pkg.LANGUAGE_ENGLISH
                                                                 )
                                        then d.amount
                                        when d.macros_type_id in (
                                                                  select numeric_value
                                                                    from com_ui_array_element_vw
                                                                   where array_id = cst_lvp_const_pkg.ARRAY_CREDIT_FEE_MACROS_TYPE -- -50000027
                                                                     and lang = com_api_const_pkg.LANGUAGE_ENGLISH
                                                                 )
                                        then -d.amount
                                        else 0
                                   end as fee_amount
                              from crd_debt d
                             where d.status in (
                                                 crd_api_const_pkg.DEBT_STATUS_PAID
                                               , crd_api_const_pkg.DEBT_STATUS_ACTIVE
                                               )
                           ) cd -- amounts from debts
                     where cd.id = cid.debt_id
                     group by
                           cd.account_id
                         , cd.card_id
                         , cd.oper_id
                         , cd.id
                         , cd.oper_type
                         , cd.currency
                   ) d
                 , opr_operation oo
                 , opr_participant iss
             where d.oper_id = oo.id(+)
               and iss.oper_id(+) = oo.id
               and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
            union all
            select oo.id as oper_id
                 , oo.oper_date
                 , null as oper_part_num
                 , l_main_card_id as card_id
                 , replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '') as oper_type_name
                 , cp.posting_date
                 , oo.merchant_name
                 , oo.merchant_country
                 , oo.terminal_type
                 , oo.originator_refnum
                 , oo.oper_currency
                 , -oo.oper_amount as oper_amount
                 , -nvl(cp.amount, 0) as account_amount
                 , cp.currency as account_currency
                 , iss.auth_code
              from (
                    select id as pay_id
                      from crd_payment
                     where account_id = l_account_id
                       and split_hash = l_split_hash
                       and is_new = com_api_type_pkg.TRUE
                       and id between l_from_id and l_till_id
                   ) cip
                 , crd_payment cp
                 , opr_operation oo
                 , opr_participant iss
             where cp.id = cip.pay_id
               and cp.split_hash = l_split_hash
               and oo.oper_type not in (dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER)
               and cp.oper_id = oo.id
               and iss.oper_id(+) = oo.id
               and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
           ) t
         , iss_card_number icn
         , com_currency cc1
         , com_currency cc2
     where t.card_id = icn.card_id(+)
       and t.currency = cc1.code(+)
       and t.oper_currency = cc2.code(+);

end transactions_by_date_range;


procedure credit_client_info (
    i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_mask_error          in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , o_result                 out cst_lvp_type_pkg.t_credit_card_info_tab
)
is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.credit_client_info: ';
    l_client_info_rec         cst_lvp_type_pkg.t_credit_card_info_rec;
    l_client_info_tab         cst_lvp_type_pkg.t_credit_card_info_tab;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_invoice_id              com_api_type_pkg.t_medium_id;
    l_current_date            date := get_sysdate;
    l_invoice                 crd_api_type_pkg.t_invoice_rec;
    l_exceed_limit            com_api_type_pkg.t_amount_rec;
    l_current_value           com_api_type_pkg.t_money;
    l_current_value_cash      com_api_type_pkg.t_money;
    l_index                   com_api_type_pkg.t_tiny_id;
begin

    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'customer [#1], mask error [#2]'
      , i_env_param1  => i_customer_id
      , i_env_param2  => i_mask_error
      , i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id   => i_customer_id
    );

    l_split_hash :=
        com_api_hash_pkg.get_split_hash(
            i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id     => i_customer_id
        );

    l_index := 1;

    for rec in (
        select aa.id as account_id
             , aa.account_number
             , aa.currency
             , aa.agent_id
             , aa.inst_id
             , aa.status as account_status
             , aao.object_id as card_id
             , iss_api_card_pkg.get_card_mask(
                   iss_api_token_pkg.decode_card_number(
                       i_card_number => icn.card_number
                     , i_mask_error  => i_mask_error
                   )
               ) as card_number
             , ici.seq_number as card_seq_number
             , ici.state as card_state
             , oa.agent_number as agent_number
             , case when cst_lvp_com_pkg.get_main_card_id (
                             i_account_id => aa.id
                           , i_split_hash => l_split_hash
                         ) = ic.id
                    then com_api_type_pkg.TRUE
                    else com_api_type_pkg.FALSE
               end as main_card_flag
             , ici.cardholder_name as embossed_name
             , ici.state as card_instance_state
             , rownum as row_number
             , cc.name as currency_name
          from acc_account aa
             , acc_account_object aao
             , iss_card ic
             , iss_card_number icn
             , iss_card_instance ici
             , ost_agent oa
             , com_currency cc
         where aa.id = aao.account_id
           and aao.object_id = ic.id
           and ic.id = ici.card_id
           and ic.id = icn.card_id
           and aa.agent_id = oa.id(+)
           and aa.currency = cc.code(+)
           and aa.customer_id = i_customer_id
           and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
           and aa.split_hash = l_split_hash
           and aao.split_hash = l_split_hash
           and ici.split_hash = l_split_hash
           and aao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD -- 'ENTTCARD'
    ) loop
        l_client_info_rec.id                        := rec.row_number;
        l_client_info_rec.account_id                := rec.account_id;
        l_client_info_rec.account_number            := rec.account_number;
        l_client_info_rec.account_currency          := rec.currency;
        l_client_info_rec.account_currency_name     := rec.currency_name;
        l_client_info_rec.agent_id                  := rec.agent_id;
        l_client_info_rec.agent_number              := rec.agent_number;
        l_client_info_rec.card_id                   := rec.card_id;
        l_client_info_rec.card_number               := rec.card_number;
        l_client_info_rec.card_is_main              := rec.main_card_flag;
        l_client_info_rec.card_embossed_name        := rec.embossed_name;
        l_client_info_rec.account_status            := rec.account_status;
        l_client_info_rec.card_instance_state       := rec.card_instance_state;

        l_invoice_id :=
            crd_invoice_pkg.get_last_invoice_id(
                i_account_id  => rec.account_id
              , i_split_hash  => l_split_hash
              , i_mask_error  => i_mask_error
            );
        if l_invoice_id is null then
            l_client_info_rec.last_invoice_date     := null;
            l_client_info_rec.last_due_date         := null;
            l_client_info_rec.last_total_amount_due := 0;
            l_client_info_rec.last_min_amount_due   := 0;
        else
            l_invoice :=
                crd_invoice_pkg.get_invoice(
                    i_invoice_id  => l_invoice_id
                  , i_mask_error  => i_mask_error
                );
            l_client_info_rec.last_invoice_date     := l_invoice.invoice_date;
            l_client_info_rec.last_due_date         := l_invoice.due_date;
            l_client_info_rec.last_total_amount_due := l_invoice.total_amount_due;
            l_client_info_rec.last_min_amount_due   := l_invoice.min_amount_due;
        end if;

        -- Get available balance
        l_client_info_rec.available_balance := 
            acc_api_balance_pkg.get_aval_balance_amount_only (
                i_account_id    => rec.account_id
            );

        -- Get credit limit and cash limit:
        l_exceed_limit :=
            acc_api_balance_pkg.get_balance_amount (
                i_account_id     => rec.account_id
              , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
              , i_date           => l_current_date
              , i_date_type      => com_api_const_pkg.DATE_PURPOSE_PROCESSING
              , i_mask_error     => i_mask_error
            );
        l_client_info_rec.account_credit_limit := nvl(l_exceed_limit.amount, 0);
        l_client_info_rec.account_credit_available := least(l_client_info_rec.available_balance, l_client_info_rec.account_credit_limit);

        cst_lvp_com_pkg.get_cash_limit_value(
            i_account_id     => rec.account_id
          , i_split_hash     => l_split_hash
          , i_inst_id        => rec.inst_id
          , i_date           => l_current_date
          , o_value          => l_client_info_rec.account_cash_limit
          , o_current_sum    => l_current_value_cash
        );

        if l_client_info_rec.account_cash_limit = -1 then
            l_client_info_rec.account_cash_limit := l_client_info_rec.account_credit_limit;
        end if;
        l_client_info_rec.account_cash_limit := nvl(l_client_info_rec.account_cash_limit, 0);
        l_client_info_rec.account_cash_available := 
            greatest(l_client_info_rec.account_cash_limit - nvl(l_current_value_cash, 0), 0);

        cst_lvp_com_pkg.get_card_credit_limits_current(
            i_card_id          => rec.card_id
          , i_split_hash       => l_split_hash
          , i_mask_error       => i_mask_error
          , o_value            => l_client_info_rec.card_credit_limit
          , o_current_sum      => l_current_value
          , o_value_cash       => l_client_info_rec.card_cash_limit
          , o_current_sum_cash => l_current_value_cash
        );

        l_client_info_rec.card_credit_limit     := nvl(l_client_info_rec.card_credit_limit, l_client_info_rec.account_credit_limit);
        l_client_info_rec.card_cash_limit       := nvl(l_client_info_rec.card_cash_limit, l_client_info_rec.account_cash_limit);

        if l_current_value is null then
            l_client_info_rec.card_credit_available := l_client_info_rec.account_credit_available;
        else
            l_client_info_rec.card_credit_available := greatest(l_client_info_rec.card_credit_limit - l_current_value, 0);
        end if;
        if l_current_value_cash is null then
            l_client_info_rec.card_cash_available := l_client_info_rec.account_cash_available;
        else
            l_client_info_rec.card_cash_available := greatest(l_client_info_rec.card_cash_limit - l_current_value_cash, 0);
        end if;

        l_client_info_tab(l_index) := l_client_info_rec;
        l_index := l_index + 1;

        trc_log_pkg.debug (
            i_text        => LOG_PREFIX || 'Added info account [#1], card [#2]'
          , i_env_param1  => rec.account_id
          , i_env_param2  => rec.card_id
          , i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id   => i_customer_id
        );

    end loop;
    
    o_result := l_client_info_tab;

end credit_client_info;


procedure invoice_info_and_transactions (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_account_number      in     com_api_type_pkg.t_account_number
  , i_eff_date            in     date
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , o_result_xml             out clob
)
is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.invoice_info_and_transactions: ';
    l_response_code           xmltype;
    l_response_data           xmltype;
    l_response_data_part      xmltype;
    l_stat_info               xmltype;
    l_result                  xmltype;
    l_invoice_id              com_api_type_pkg.t_medium_id;
    l_ref_cursor              sys_refcursor;
    l_info_is_present         com_api_type_pkg.t_boolean;
    l_account_id              com_api_type_pkg.t_account_id;
    l_resp_code               com_api_type_pkg.t_dict_value;
    l_error_message           com_api_type_pkg.t_text;

    l_account_number          com_api_type_pkg.t_account_number;
    l_credit_limit            com_api_type_pkg.t_money;
    l_cash_limit              com_api_type_pkg.t_money;
    l_invoice_date            date;
    l_due_date                date; 
    l_previous_tad            com_api_type_pkg.t_money;
    l_previous_own_funds      com_api_type_pkg.t_money;
    l_debits_amount           com_api_type_pkg.t_money;
    l_credits_amount          com_api_type_pkg.t_money;
    l_total_amount_due        com_api_type_pkg.t_money;
    l_min_amount_due          com_api_type_pkg.t_money;

    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_part_num           com_api_type_pkg.t_tiny_id;
    l_oper_date               date;
    l_card_id                 com_api_type_pkg.t_medium_id;
    l_oper_type_name          com_api_type_pkg.t_name;
    l_posting_date            date;
    l_merchant_name           com_api_type_pkg.t_name;
    l_merchant_country        com_api_type_pkg.t_country_code;
    l_oper_currency           com_api_type_pkg.t_curr_code;
    l_oper_currency_name      com_api_type_pkg.t_curr_name;
    l_oper_currency_expo      com_api_type_pkg.t_tiny_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_transaction_amount      com_api_type_pkg.t_money;
    l_currency_name           com_api_type_pkg.t_curr_name;
    l_currency_expo           com_api_type_pkg.t_tiny_id;
    l_card_number             com_api_type_pkg.t_card_number;
    l_card_is_main            com_api_type_pkg.t_boolean;
    l_terminal_type           com_api_type_pkg.t_dict_value;
    l_originator_refnum       com_api_type_pkg.t_rrn;
    l_auth_code               com_api_type_pkg.t_auth_code;
    l_main_card_number        com_api_type_pkg.t_card_number;

begin

    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'institution [#1], account number [#2], date [#3], mask error [#4]'
      , i_env_param1  => i_inst_id
      , i_env_param2  => i_account_number
      , i_env_param3  => to_char(i_eff_date, 'yyyy-mm-dd hh24:mi:ss')
      , i_env_param4  => i_mask_error
    );

    acc_api_account_pkg.find_account (
        i_account_number  => i_account_number
      , i_oper_type       => null
      , i_inst_id         => i_inst_id
      , i_party_type      => 'PRTYISS'
      , o_account_id      => l_account_id
      , o_resp_code       => l_resp_code
    );

    l_invoice_id :=
        find_invoice_id (
            i_inst_id     => i_inst_id
          , i_account_id  => l_account_id
          , i_eff_date    => i_eff_date
          , i_mask_error  => i_mask_error
        );

    l_info_is_present := com_api_type_pkg.FALSE;

    invoice_info (
        i_invoice_id  => l_invoice_id
      , o_ref_cursor  => l_ref_cursor
    );

    if l_ref_cursor%isopen then
        loop
            fetch l_ref_cursor
             into l_account_number
                , l_credit_limit
                , l_cash_limit
                , l_invoice_date
                , l_due_date
                , l_previous_tad
                , l_previous_own_funds
                , l_debits_amount
                , l_credits_amount
                , l_total_amount_due
                , l_min_amount_due;

            exit when l_ref_cursor%notfound;

            select xmlelement("stat_info"
                     , xmlelement("stat_id"
                         , xmlattributes(l_invoice_id as "id")
                         , xmlconcat(
                               xmlelement("account_nbr", l_account_number)
                             , xmlelement("credit_limit", l_credit_limit)
                             , xmlelement("cash_limit", l_cash_limit)
                             , xmlelement("stat_date", to_char(l_invoice_date, 'yyyy-mm-dd'))
                             , xmlelement("payment_date", to_char(l_due_date, 'yyyy-mm-dd'))
                             , xmlelement("date_format", 'yyyy-mm-dd')
                             , xmlelement("opening_bal", l_previous_tad - l_previous_own_funds)
                             , xmlelement("usein_stat", l_debits_amount)
                             , xmlelement("paymentin_stat", l_credits_amount)
                             , xmlelement("closing_bal", l_total_amount_due)
                             , xmlelement("min_due", l_min_amount_due)
                           )
                       )
                   )
              into l_stat_info
              from dual;

            l_info_is_present := com_api_type_pkg.TRUE;

        end loop;

        close l_ref_cursor;
    end if;

    invoice_transactions (
        i_invoice_id  => l_invoice_id
      , i_account_id  => l_account_id
      , i_lang        => null
      , o_ref_cursor  => l_ref_cursor
    );

    if l_ref_cursor%isopen then
        loop
            fetch l_ref_cursor
             into l_oper_id
                , l_oper_part_num
                , l_oper_date
                , l_card_id
                , l_oper_type_name
                , l_posting_date
                , l_merchant_name
                , l_merchant_country
                , l_oper_currency
                , l_oper_currency_name
                , l_oper_currency_expo
                , l_oper_amount
                , l_transaction_amount
                , l_currency_name
                , l_currency_expo
                , l_card_number
                , l_card_is_main
                , l_terminal_type
                , l_originator_refnum
                , l_main_card_number
                , l_auth_code;

            exit when l_ref_cursor%notfound;

            select xmlelement("trn_id"
                     , xmlattributes(l_oper_id as "oper_id")
                     , xmlconcat(
                           xmlelement("card_nbr", l_card_number)
                         , xmlelement("primary_card", l_main_card_number)
                         , xmlelement("txn_dt", to_char(l_oper_date, 'yyyy-mm-dd'))
                         , xmlelement("proc_dt", to_char(l_posting_date, 'yyyy-mm-dd'))
                         , xmlelement("txn_type", l_oper_type_name)
                         , xmlelement("txn_chanel", case when l_terminal_type = 'TRMT0002' then 'ATM' else 'POS' end)
                         , xmlelement("arn", l_originator_refnum)
                         , xmlelement("auth_code", l_auth_code)
                         , xmlelement("acronym", l_merchant_name)
                         , xmlelement("d_c", case when l_transaction_amount >= 0 then 'd' else 'c' end)
                         , xmlelement("txn_amt", abs(l_oper_amount))
                         , xmlelement("txn_ccy", l_oper_currency_name)
                         , xmlelement("bill_amt", abs(l_transaction_amount))
                         , xmlelement("bill_ccy", l_currency_name)
                         , xmlelement("date_format", 'yyyy-mm-dd')
                         , xmlelement("card_is_primary", l_card_is_main)
                       )
                   )
              into l_response_data_part
              from dual;

            select xmlconcat(
                       l_response_data
                     , l_response_data_part
                   )
              into l_response_data
              from dual;

        end loop;

        close l_ref_cursor;
    end if;

    select xmlconcat(
               xmlelement("response_code", case when l_info_is_present = com_api_type_pkg.TRUE then '00' else '05' end)
             , l_response_data
             , l_stat_info
           )
      into l_result
      from dual;

    o_result_xml := l_result.getclobval();

    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Info present [#1]'
      , i_env_param1  => l_info_is_present
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id   => l_invoice_id
    );

exception
    when others then
        l_error_message := substr(sqlerrm, 1, 2000);
        select xmlconcat(
                   xmlelement("response_code", '99')
                 , xmlelement("error_message", l_error_message)
                 , l_response_data
                 , l_stat_info
               )
          into l_result
          from dual;
        o_result_xml := l_result.getclobval();

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
            and
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE
        then
            trc_log_pkg.error(
                i_text        => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
              , i_entity_type => case when l_invoice_id is not null
                                      then crd_api_const_pkg.ENTITY_TYPE_INVOICE
                                      when l_account_id is not null
                                      then acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                      else null
                                 end
              , i_object_id   => nvl(l_invoice_id, l_account_id)
            );
        end if;
        
end invoice_info_and_transactions;


procedure transactions_by_date_range (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_account_number      in     com_api_type_pkg.t_account_number
  , i_begin_date          in     date
  , i_end_date            in     date
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , o_result_xml             out clob
)
is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.transactions_by_date_range: ';
    l_response_code           xmltype;
    l_response_data           xmltype;
    l_response_data_part      xmltype;
    l_result                  xmltype;
    l_ref_cursor              sys_refcursor;
    l_info_is_present         com_api_type_pkg.t_boolean;
    l_account_id              com_api_type_pkg.t_account_id;
    l_resp_code               com_api_type_pkg.t_dict_value;
    l_error_message           com_api_type_pkg.t_text;

    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_part_num           com_api_type_pkg.t_tiny_id;
    l_oper_date               date;
    l_card_id                 com_api_type_pkg.t_medium_id;
    l_oper_type_name          com_api_type_pkg.t_name;
    l_posting_date            date;
    l_merchant_name           com_api_type_pkg.t_name;
    l_merchant_country        com_api_type_pkg.t_country_code;
    l_oper_currency           com_api_type_pkg.t_curr_code;
    l_oper_currency_name      com_api_type_pkg.t_curr_name;
    l_oper_currency_expo      com_api_type_pkg.t_tiny_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_transaction_amount      com_api_type_pkg.t_money;
    l_currency_name           com_api_type_pkg.t_curr_name;
    l_currency_expo           com_api_type_pkg.t_tiny_id;
    l_card_number             com_api_type_pkg.t_card_number;
    l_card_is_main            com_api_type_pkg.t_boolean;
    l_terminal_type           com_api_type_pkg.t_dict_value;
    l_originator_refnum       com_api_type_pkg.t_rrn;
    l_auth_code               com_api_type_pkg.t_auth_code;
    l_main_card_number        com_api_type_pkg.t_card_number;

begin

    acc_api_account_pkg.find_account (
        i_account_number  => i_account_number
      , i_oper_type       => null
      , i_inst_id         => i_inst_id
      , i_party_type      => 'PRTYISS'
      , o_account_id      => l_account_id
      , o_resp_code       => l_resp_code
    );

    l_info_is_present := com_api_type_pkg.FALSE;

    transactions_by_date_range (
        i_account_id  => l_account_id
      , i_begin_date  => i_begin_date
      , i_end_date    => i_end_date
      , i_lang        => null
      , o_ref_cursor  => l_ref_cursor
    );

    if l_ref_cursor%isopen then
        loop
            fetch l_ref_cursor
             into l_oper_id
                , l_oper_part_num
                , l_oper_date
                , l_card_id
                , l_oper_type_name
                , l_posting_date
                , l_merchant_name
                , l_merchant_country
                , l_oper_currency
                , l_oper_currency_name
                , l_oper_currency_expo
                , l_oper_amount
                , l_transaction_amount
                , l_currency_name
                , l_currency_expo
                , l_card_number
                , l_card_is_main
                , l_terminal_type
                , l_originator_refnum
                , l_main_card_number
                , l_auth_code;

            exit when l_ref_cursor%notfound;

            select xmlelement("trn_id"
                     , xmlattributes(l_oper_id as "oper_id")
                     , xmlconcat(
                           xmlelement("card_nbr", l_card_number)
                         , xmlelement("primary_card", l_main_card_number)
                         , xmlelement("txn_dt", to_char(l_oper_date, 'yyyy-mm-dd'))
                         , xmlelement("proc_dt", to_char(l_posting_date, 'yyyy-mm-dd'))
                         , xmlelement("txn_type", l_oper_type_name)
                         , xmlelement("txn_chanel", case when l_terminal_type = 'TRMT0002' then 'ATM' else 'POS' end)
                         , xmlelement("arn", l_originator_refnum)
                         , xmlelement("auth_code", l_auth_code)
                         , xmlelement("acronym", l_merchant_name)
                         , xmlelement("d_c", case when l_transaction_amount >= 0 then 'd' else 'c' end)
                         , xmlelement("txn_amt", abs(l_oper_amount))
                         , xmlelement("txn_ccy", l_oper_currency_name)
                         , xmlelement("bill_amt", abs(l_transaction_amount))
                         , xmlelement("bill_ccy", l_currency_name)
                         , xmlelement("date_format", 'yyyy-mm-dd')
                         , xmlelement("card_is_primary", l_card_is_main)
                       )
                   )
              into l_response_data_part
              from dual;

            l_info_is_present := com_api_type_pkg.TRUE;

            select xmlconcat(
                       l_response_data
                     , l_response_data_part
                   )
              into l_response_data
              from dual;

        end loop;

        close l_ref_cursor;
    end if;

    select xmlconcat(
               xmlelement("response_code", case when l_info_is_present = com_api_type_pkg.TRUE then '00' else '05' end)
             , l_response_data
           )
      into l_result
      from dual;

    o_result_xml := l_result.getclobval();

exception
    when others then
        l_error_message := substr(sqlerrm, 1, 2000);
        select xmlconcat(
                   xmlelement("response_code", '99')
                 , xmlelement("error_message", l_error_message)
                 , l_response_data
               )
          into l_result
          from dual;
        o_result_xml := l_result.getclobval();

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
            and
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE
        then
            trc_log_pkg.error(
                i_text        => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
              , i_entity_type => case when l_account_id is not null
                                      then acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                      else null
                                 end
              , i_object_id   => l_account_id
            );
        end if;

end transactions_by_date_range;


procedure credit_client_info (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_customer_number     in     com_api_type_pkg.t_name
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , o_result_xml             out clob
)
is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.credit_client_info: ';
    l_response_code           xmltype;
    l_response_data           xmltype;
    l_response_data_part      xmltype;
    l_result                  xmltype;
    l_ref_cursor              sys_refcursor;
    l_info_is_present         com_api_type_pkg.t_boolean;
    l_customer_id             com_api_type_pkg.t_medium_id;
    l_resp_code               com_api_type_pkg.t_dict_value;
    l_error_message           com_api_type_pkg.t_text;
    l_client_info_rec         cst_lvp_type_pkg.t_credit_card_info_rec;
    l_client_info_tab         cst_lvp_type_pkg.t_credit_card_info_tab;

begin

    l_customer_id :=
        prd_api_customer_pkg.get_customer_id(
            i_customer_number => i_customer_number
          , i_inst_id         => i_inst_id
          , i_mask_error      => i_mask_error
        );

    l_info_is_present := com_api_type_pkg.FALSE;

    credit_client_info(
        i_customer_id => l_customer_id
      , i_mask_error  => i_mask_error
      , o_result      => l_client_info_tab
    );

    if l_client_info_tab.count > 0 then
        for i in l_client_info_tab.first..l_client_info_tab.last loop
            l_client_info_rec := l_client_info_tab(i);

            select xmlconcat(
                       l_response_data
                     , xmlelement(
                           "record"
                         , xmlattributes(l_client_info_rec.id as "id")
                         , xmlconcat(
                               xmlelement("card_id", l_client_info_rec.card_id)
                             , xmlelement("cr_account_nbr", l_client_info_rec.account_number) 
                             , xmlelement("account_credit_limit", l_client_info_rec.account_credit_limit)
                             , xmlelement("account_cash_limit", l_client_info_rec.account_cash_limit)
                             , xmlelement("account_avail_credit", l_client_info_rec.account_credit_available)
                             , xmlelement("account_avail_cash", l_client_info_rec.account_cash_available)
                             , xmlelement("card_number", l_client_info_rec.card_number)
                             , xmlelement("basic_card_flag", l_client_info_rec.card_is_main)
                             , xmlelement("embossed_name", l_client_info_rec.card_embossed_name)
                             , xmlelement("credit_limit", l_client_info_rec.card_credit_limit)
                             , xmlelement("cash_limit", l_client_info_rec.card_cash_limit)
                             , xmlelement("card_avail_credit", l_client_info_rec.card_credit_available)
                             , xmlelement("card_avail_cash", l_client_info_rec.card_cash_available)
                             , xmlelement(
                                          "total_outstanding"
                                        , case when l_client_info_rec.available_balance - l_client_info_rec.account_credit_limit < 0
                                               then abs(l_client_info_rec.available_balance - l_client_info_rec.account_credit_limit)
                                               else 0
                                          end
                                         )
                             , xmlelement("last_statement_date", to_char(l_client_info_rec.last_invoice_date - com_api_const_pkg.ONE_SECOND, 'yyyy-mm-dd'))
                             , xmlelement("last_due_date", to_char(l_client_info_rec.last_due_date, 'yyyy-mm-dd'))
                             , xmlelement("last_stat_out_standing", l_client_info_rec.last_total_amount_due)
                             , xmlelement("last_min_due", l_client_info_rec.last_min_amount_due)
                             , xmlelement("branch_code", l_client_info_rec.agent_number)
                             , xmlelement("date_format", 'yyyy-mm-dd')
                             , xmlelement("account_currency", l_client_info_rec.account_currency_name)
                             , xmlelement("account_status", l_client_info_rec.account_status)
                             , xmlelement("card_instance_state", l_client_info_rec.card_instance_state)
                           )
                       )
                   )
              into l_response_data
              from dual;

            l_info_is_present := com_api_type_pkg.TRUE;
            
        end loop;
    end if;

    select xmlconcat(
               xmlelement("response_code", case when l_info_is_present = com_api_type_pkg.TRUE then '00' else '05' end)
             , l_response_data
           )
      into l_result
      from dual;

    o_result_xml := l_result.getclobval();

exception
    when others then
        l_error_message := substr(sqlerrm, 1, 2000);
        select xmlconcat(
                   xmlelement("response_code", '99')
                 , xmlelement("error_message", l_error_message)
                 , l_response_data
               )
          into l_result
          from dual;
        o_result_xml := l_result.getclobval();

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
            and
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE
        then
            trc_log_pkg.error(
                i_text        => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
              , i_entity_type => case when l_customer_id is not null
                                      then com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                      else null
                                 end
              , i_object_id   => l_customer_id
            );
        end if;

end credit_client_info;


procedure credit_card_info (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_card_number         in     com_api_type_pkg.t_card_number
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , o_result_xml             out clob
)
is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.credit_card_info: ';
    l_response_code           xmltype;
    l_response_data           xmltype;
    l_response_data_part      xmltype;
    l_result                  xmltype;
    l_ref_cursor              sys_refcursor;
    l_info_is_present         com_api_type_pkg.t_boolean;
    l_customer_id             com_api_type_pkg.t_medium_id;
    l_resp_code               com_api_type_pkg.t_dict_value;
    l_error_message           com_api_type_pkg.t_text;

    l_card_id                 com_api_type_pkg.t_medium_id;
    l_card_number_masked      com_api_type_pkg.t_card_number;
    l_card_seq_number         com_api_type_pkg.t_tiny_id;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_invoice                 crd_api_type_pkg.t_invoice_rec;
    l_invoice_id              com_api_type_pkg.t_medium_id;

begin

    l_card_id :=
        iss_api_card_pkg.get_card_id(
            i_card_number => i_card_number
        );
        
    l_card_seq_number := 
        iss_api_card_pkg.get_seq_number(
            i_card_number => i_card_number
        );
        
    l_split_hash :=
        com_api_hash_pkg.get_split_hash(
            i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => l_card_id
        );
    
    l_info_is_present := com_api_type_pkg.FALSE;

    for rec in (
        select ici.cardholder_name as embossed_name
             , ici.state as card_state
             , ici.expir_date
             , case when ici.state = 'CSTE0300' then 'CSTE0300 - ' || com_api_dictionary_pkg.get_article_text('CSTE0300') 
               else ici.status || ' - ' || com_api_dictionary_pkg.get_article_text(ici.status) 
                 end as card_status
             , aa.id as account_id
             , oa.agent_number as agent_number
             , case when ici.status = 'CSTS0022' 
                      or ici.expir_date < trunc(get_sysdate)
                      or ici.state = 'CSTE0300'
                    then com_api_type_pkg.FALSE
                    else com_api_type_pkg.TRUE
               end as payment_allowed
          from iss_card_instance ici
             , acc_account_object aao
             , acc_account aa
             , ost_agent oa
         where ici.card_id = l_card_id 
           and ici.seq_number = l_card_seq_number
           and aao.object_id = ici.card_id
           and aa.id = aao.account_id
           and aao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD -- 'ENTTCARD'
           and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
           and aa.status in (
                   acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE -- 'ACSTACTV'
                 , acc_api_const_pkg.ACCOUNT_STATUS_CREDITS -- 'ACSTCRED'
                 , acc_api_const_pkg.ACCOUNT_STATUS_INCOLLECTION -- 'ACSTCOLL'
               )
           and aa.agent_id = oa.id(+)
           and aa.split_hash = l_split_hash
           and aao.split_hash = l_split_hash
    ) loop

        l_info_is_present := com_api_type_pkg.TRUE;
        
        l_invoice :=
            crd_invoice_pkg.get_last_invoice(
                i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT -- 'ENTTACCT'
              , i_object_id  => rec.account_id
              , i_split_hash  => l_split_hash
              , i_mask_error  => i_mask_error
            );
        
        select xmlelement("response_data",
                   xmlconcat(
                       xmlelement("card_id", l_card_id)
                     , xmlelement("card_number", i_card_number) 
                     , xmlelement("embossed_name", rec.embossed_name)
                     , xmlelement("last_statement_date", to_char(l_invoice.invoice_date - com_api_const_pkg.ONE_SECOND, 'yyyy-mm-dd'))
                     , xmlelement("last_due_date", to_char(l_invoice.due_date, 'yyyy-mm-dd'))
                     , xmlelement("last_stat_out_standing", l_invoice.total_amount_due)
                     , xmlelement("last_min_due", l_invoice.min_amount_due)
                     , xmlelement("card_status", rec.card_status)
                     , xmlelement("payment_flag", rec.payment_allowed)
                     , xmlelement("branch_code", rec.agent_number)
                     , xmlelement("date_format", 'yyyy-mm-dd')
                   )
               )
          into l_response_data
          from dual;
          
        exit; -- Currently we need to return only one record

    end loop;

    select xmlconcat(
               xmlelement("response_code", case when l_info_is_present = com_api_type_pkg.TRUE then '00' else '05' end)
             , l_response_data
           )
      into l_result
      from dual;

    o_result_xml := l_result.getclobval();

exception
    when others then
        l_error_message := substr(sqlerrm, 1, 2000);
        select xmlconcat(
                   xmlelement("response_code", '99')
                 , xmlelement("error_message", l_error_message)
                 , l_response_data
               )
          into l_result
          from dual;
        o_result_xml := l_result.getclobval();

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
            and
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE
        then
            trc_log_pkg.error(
                i_text        => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
              , i_entity_type => case when l_customer_id is not null
                                      then com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                      else null
                                 end
              , i_object_id   => l_customer_id
            );
        end if;

end credit_card_info;


procedure prepaid_card_info (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_card_number         in     com_api_type_pkg.t_card_number
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , o_result_xml             out clob
)
is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.prepaid_card_info: ';
    l_response_code           xmltype;
    l_response_data           xmltype;
    l_response_data_part      xmltype;
    l_result                  xmltype;
    l_ref_cursor              sys_refcursor;
    l_info_is_present         com_api_type_pkg.t_boolean;
    l_customer_id             com_api_type_pkg.t_medium_id;
    l_resp_code               com_api_type_pkg.t_dict_value;
    l_error_message           com_api_type_pkg.t_text;

    l_card_id                 com_api_type_pkg.t_medium_id;
    l_card_number_masked      com_api_type_pkg.t_card_number;
    l_card_seq_number         com_api_type_pkg.t_tiny_id;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_product_id              com_api_type_pkg.t_short_id;
    l_identification          com_api_type_pkg.t_boolean;
    l_balance                 com_api_type_pkg.t_amount_rec;

begin

    l_card_id :=
        iss_api_card_pkg.get_card_id(
            i_card_number => i_card_number
        );
        
    l_card_seq_number := 
        iss_api_card_pkg.get_seq_number(
            i_card_number => i_card_number
        );
        
    l_split_hash :=
        com_api_hash_pkg.get_split_hash(
            i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => l_card_id
        );
    
    l_info_is_present := com_api_type_pkg.FALSE;
    
    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id         => l_card_id
          , i_inst_id           => i_inst_id
        );
        
    begin
        select decode(parent_id, 70000240, com_api_type_pkg.TRUE, com_api_type_pkg.FALSE)
          into l_identification
          from (
                select parent_id
                  from prd_product
                 start with id = l_product_id
               connect by id = prior parent_id
               )
         where parent_id in (70000240, 70000241);
    exception 
        when no_data_found then
            l_identification := 0;
    end;

    for rec in (
        select ici.cardholder_name as embossed_name
             , ici.state as card_state
             , ici.expir_date
             , case when ici.state = 'CSTE0300' then 'CSTE0300 - ' || com_api_dictionary_pkg.get_article_text('CSTE0300') 
               else ici.status || ' - ' || com_api_dictionary_pkg.get_article_text(ici.status) 
                 end as card_status
             , aa.id as account_id
             , oa.agent_number as agent_number
             , case when ici.status = 'CSTS0022' 
                      or ici.expir_date < trunc(get_sysdate)
                      or ici.state = 'CSTE0300'
                    then com_api_type_pkg.FALSE
                    else com_api_type_pkg.TRUE
               end as payment_allowed
          from iss_card_instance ici
             , acc_account_object aao
             , acc_account aa
             , ost_agent oa
         where ici.card_id = l_card_id 
           and ici.seq_number = l_card_seq_number
           and aao.object_id = ici.card_id
           and aa.id = aao.account_id
           and aao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD -- 'ENTTCARD'
           --and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
           and aa.status in (
                   acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE -- 'ACSTACTV'
                 , acc_api_const_pkg.ACCOUNT_STATUS_CREDITS -- 'ACSTCRED'
               )
           and aa.agent_id = oa.id(+)
           and aa.split_hash = l_split_hash
           and aao.split_hash = l_split_hash
           --and ici.split_hash = l_split_hash
    ) loop

        l_info_is_present := com_api_type_pkg.TRUE;
        
        l_balance :=
            acc_api_balance_pkg.get_aval_balance_amount(
                i_account_id => rec.account_id
            );
        
        select xmlelement("response_data",
                   xmlconcat(
                       xmlelement("card_id", l_card_id)
                     , xmlelement("card_number", i_card_number) 
                     , xmlelement("embossed_name", rec.embossed_name)
                     , xmlelement("branch_code", rec.agent_number)
                     , xmlelement("card_type", 'PREPAID')
                     , xmlelement("card_status", rec.card_status)
                     , xmlelement("payment_flag", rec.payment_allowed)
                     , xmlelement("identification", l_identification)
                     , xmlelement("balance_unidentification", l_balance.amount)
                     , xmlelement("account_currency", l_balance.currency)
                   )
               )
          into l_response_data
          from dual;
          
        exit; -- Currently we need to return only one record

    end loop;

    select xmlconcat(
               xmlelement("response_code", case when l_info_is_present = com_api_type_pkg.TRUE then '00' else '05' end)
             , l_response_data
           )
      into l_result
      from dual;

    o_result_xml := l_result.getclobval();

exception
    when others then
        l_error_message := substr(sqlerrm, 1, 2000);
        select xmlconcat(
                   xmlelement("response_code", '99')
                 , xmlelement("error_message", l_error_message)
                 , l_response_data
               )
          into l_result
          from dual;
        o_result_xml := l_result.getclobval();

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
            and
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE
        then
            trc_log_pkg.error(
                i_text        => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
              , i_entity_type => case when l_customer_id is not null
                                      then com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                      else null
                                 end
              , i_object_id   => l_customer_id
            );
        end if;

end prepaid_card_info;


end cst_lvp_api_external_pkg;
/
