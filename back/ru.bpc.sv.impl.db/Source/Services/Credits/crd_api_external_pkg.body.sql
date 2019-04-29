create or replace package body crd_api_external_pkg as
/*********************************************************
 *  Credit statement API  <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 03.04.2017 <br />
 *  Module: crd_api_external_pkg <br />
 *  @headcom
 **********************************************************/

-- Account's statement
procedure account_statement(
    i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_account_number    in     com_api_type_pkg.t_account_number    default null
    , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
    , o_ref_cursor           out sys_refcursor
) is
    l_account_id                 com_api_type_pkg.t_account_id;
    l_invoice_id                 com_api_type_pkg.t_medium_id;
    l_invoice_date               date;
    l_prev_invoice_id            com_api_type_pkg.t_medium_id;
    l_prev_due_date              date;
begin
    trc_log_pkg.debug (
        i_text              => 'Start account_statement. i_inst_id [#1], i_account_number [#2], i_invoice_id [#3]'
        , i_env_param1      => i_inst_id
        , i_env_param2      => i_account_number
        , i_env_param3      => i_invoice_id
    );

    if i_account_number is null and i_invoice_id is null then
        com_api_error_pkg.raise_error (
            i_error         => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
        );
    end if;

    -- get current invoice
    begin
        select i.account_id
             , i.id
             , i.invoice_date
          into l_account_id
             , l_invoice_id
             , l_invoice_date
          from crd_invoice i
             , acc_account a
         where a.inst_id = i_inst_id
           and i.account_id = a.id
           and (a.account_number = i_account_number or i_account_number is null)
           and (i.id = i_invoice_id or i_invoice_id is null)
           and i.id in (select nvl(max(ii.id), i.id)
                          from crd_invoice ii
                         where ii.account_id = a.id
                           and i_invoice_id is null);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'INVOICE_NOT_FOUND'
                , i_env_param1  => i_invoice_id
            );
    end;

    -- get previous invoice
    select max(i.id)
         , max(i.due_date)
      into l_prev_invoice_id
         , l_prev_due_date
      from crd_invoice_vw i
     where i.id != l_invoice_id
       and i.invoice_date < l_invoice_date
       and i.account_id = l_account_id;

    open o_ref_cursor for
        select a.account_number
             , i.invoice_date as billing_date
             , i.start_date as start_period
             , last_day(i.start_date) as end_period
             , to_char(i.due_date, 'DD') as settlement_date
             , i.due_date as withdraw_date
             , i.total_amount_due as payment_amount
             , i.overdue_balance as overdue_principal_amount
             , i.overdue_intr_balance as overdue_interest
             , i.expense_amount + i.interest_amount as carry_over_last_month
             , i.expense_amount as billing_amt
             , i.min_amount_due as min_amount_due
             , (select sum(p.amount)
                  from crd_payment p
                     , crd_invoice_payment ip
                 where ip.invoice_id = l_prev_invoice_id
                   and p.posting_date between l_prev_due_date and l_invoice_date
                   and p.id = ip.pay_id) as advance_payment_amount
          from acc_account a
             , crd_invoice i
         where i.id = l_invoice_id
           and i.account_id = a.id;

end account_statement;

function get_tad(
    i_account_id        in     com_api_type_pkg.t_medium_id
  , i_split_hash        in     com_api_type_pkg.t_tiny_id
  , i_last_invoice_date in     date
  , i_total_amount_due  in     com_api_type_pkg.t_money
) return com_api_type_pkg.t_money is
    l_tad               com_api_type_pkg.t_money;
    l_payments          com_api_type_pkg.t_money;
    l_debt              com_api_type_pkg.t_money;
    l_from_id           com_api_type_pkg.t_long_id;
    l_till_id           com_api_type_pkg.t_long_id;
begin
    l_from_id := com_api_id_pkg.get_from_id(i_last_invoice_date);
    l_till_id := com_api_id_pkg.get_till_id(com_api_sttl_day_pkg.get_sysdate() );

    -- get total_income
    select sum (amount)
      into l_payments
      from crd_payment
     where account_id = i_account_id
       and split_hash = i_split_hash
       and id between l_from_id and l_till_id;
  --then add all debts
    select nvl(i_total_amount_due, 0)  + nvl(sum(nvl(d.amount, 0)),0)
      into l_debt
      from crd_debt d
     where decode(d.is_new, 1, d.account_id, null) = i_account_id
       and d.split_hash = i_split_hash
       and is_new       = com_api_type_pkg.TRUE
       and d.id between l_from_id and l_till_id;

    l_tad := nvl(i_total_amount_due,0)  - nvl(l_payments,0)  + nvl(l_debt, 0);

    trc_log_pkg.debug (
        i_text       => 'get_tad: account_id [#1], total_amount_due [#2], payments [#3], debt [#4], tad [#5]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_total_amount_due
      , i_env_param3 => l_payments
      , i_env_param4 => l_debt
      , i_env_param5 => l_tad
    );

    return l_tad;
end;

procedure account_statement(
    i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_array_account_status_id in     com_api_type_pkg.t_short_id   default null
  , i_id_type                 in     com_api_type_pkg.t_dict_value default null
  , i_invoice_date            in     date                          default null
  , o_ref_cursor                 out sys_refcursor
) is
    l_sysdate                 date := com_api_sttl_day_pkg.get_sysdate();
begin
    open o_ref_cursor for
    select customer_id
         , customer_number
         , account_number
         , account_currency
         , account_status
         , coalesce(card_mask, iss_api_card_pkg.get_card_mask(card_number)) card_mask
         , cardholder_name
         , card_expiration_date
         , id_series
         , id_number
         , invoice_id
         , due_date
         , mad
         , x.total_amount_due as tad
         , count(1) over() estimated_count
      from (
          select row_number() over(partition by i.account_id order by i.invoice_date desc) invoice_rn
               , row_number() over(partition by ci.card_id   order by ci.seq_number desc) card_instance_rn
               , a.id               as account_id
               , a.split_hash       as split_hash
               , i.id               as invoice_id
               , cu.id              as customer_id
               , cu.customer_number as customer_number
               , a.account_number   as account_number
               , a.currency         as account_currency
               , a.status           as account_status
               , c.card_mask        as card_mask
               , cn.card_number
               , ci.cardholder_name
               , ci.expir_date   card_expiration_date
               , case when i_id_type is not null then id.id_series end as id_series
               , case when i_id_type is not null then id.id_number end as id_number
               , i.due_date         as due_date
               , i.invoice_date     as invoice_date
               , i.min_amount_due   as mad
               , i.total_amount_due
            from acc_account a
               , prd_customer cu
               , crd_invoice i
               , acc_account_object o
               , iss_card c
               , iss_card_instance ci
               , iss_card_number cn
               , com_person p
               , com_id_object id
           where a.customer_id = cu.id
             and (a.inst_id     = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST) -- 9999
             and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
             and i.account_id   = a.id
             and c.id           = o.object_id
             and o.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
             and o.account_id   = a.id
             and ci.card_id     = c.id
             and c.customer_id  = cu.id
             and ci.state       = iss_api_const_pkg.CARD_STATE_ACTIVE -- 'CSTE0200'
             and cn.card_id     = c.id
             and p.id           = cu.object_id
             and cu.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON -- 'ENTTPERS'
             and id.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON -- 'ENTTPERS'
             and id.object_id   = p.id
             and (id.id_type    = i_id_type or i_id_type is null)
             and ( i.invoice_date between trunc(i_invoice_date) and trunc(i_invoice_date) + 1 - com_api_const_pkg.ONE_SECOND
                   or i_invoice_date is null
                 )
       -- appropriate conditions to the equality of values split_hash for tables that contain split_hash
             and a.split_hash in (select m.split_hash from com_api_split_map_vw m)
             and cu.split_hash  = a.split_hash
             and i.split_hash   = a.split_hash
             and o.split_hash   = a.split_hash
             and c.split_hash   = a.split_hash
             and ci.split_hash  = a.split_hash
             and ((i_array_account_status_id is null and a.status = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE) -- 'ACSTACTV'
               or a.status in (select e.element_value
                                 from com_array_element e
                                where e.array_id = i_array_account_status_id
                              )
                 )
             and exists(select 1
                          from prd_service_object o
                             , prd_service s
                         where s.id              = o.service_id
                           and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID -- 10000403
                           and o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT -- 'ENTTACCT'
                           and o.object_id       = a.id
                           and o.start_date     <= l_sysdate
                           and (o.end_date is null or o.end_date > l_sysdate)
                       )
      ) x
  where invoice_rn       = 1
    and card_instance_rn = 1;
end;

-- Summary of loyalty points
procedure loyalty_points_sum(
    i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_account_number    in     com_api_type_pkg.t_account_number    default null
    , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
    , o_ref_cursor           out sys_refcursor
) is
    l_account_id                 com_api_type_pkg.t_account_id;
    l_invoice_id                 com_api_type_pkg.t_medium_id;
    l_invoice_date               date;
    l_start_date                 date;
    l_prev_invoice_id            com_api_type_pkg.t_medium_id;
    l_prev_invoice_date          date;
    l_loyalty_account_id         com_api_type_pkg.t_account_id;
begin
    trc_log_pkg.debug (
        i_text              => 'Start loyalty_points_sum. i_inst_id [#1], i_account_number [#2], i_invoice_id [#3]'
        , i_env_param1      => i_inst_id
        , i_env_param2      => i_account_number
        , i_env_param3      => i_invoice_id
    );

    if i_account_number is null and i_invoice_id is null then
        com_api_error_pkg.raise_error (
            i_error         => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
        );
    end if;

    -- get current invoice
    begin
        select i.account_id
             , i.id
             , i.invoice_date
             , i.start_date
          into l_account_id
             , l_invoice_id
             , l_invoice_date
             , l_start_date
          from crd_invoice i
             , acc_account a
         where a.inst_id = i_inst_id
           and i.account_id = a.id
           and (a.account_number = i_account_number or i_account_number is null)
           and (i.id = i_invoice_id or i_invoice_id is null)
           and i.id in (select nvl(max(ii.id), i.id)
                          from crd_invoice ii
                         where ii.account_id = a.id
                           and i_invoice_id is null);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'INVOICE_NOT_FOUND'
                , i_env_param1  => i_invoice_id
            );
    end;

    -- get previous invoice
    select max(i.id)
         , max(i.invoice_date)
      into l_prev_invoice_id
         , l_prev_invoice_date
      from crd_invoice_vw i
     where i.id != l_invoice_id
       and i.invoice_date < l_invoice_date
       and i.account_id = l_account_id;

    -- calc start date
    if l_prev_invoice_id is null then
        begin
            select o.start_date
              into l_start_date
              from prd_service_object o
                 , prd_service s
             where o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and object_id = l_account_id
               and s.id = o.service_id
               and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error         => 'ACCOUNT_SERVICE_NOT_FOUND'
                    , i_env_param1  => l_account_id
                    , i_env_param2  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                );
        end;
    else
        l_start_date := l_prev_invoice_date;
    end if;

    begin
        select a2.id
          into l_loyalty_account_id
          from prd_service s
             , prd_service_object o
             , acc_account a1
             , acc_account a2
        where a1.id             = l_account_id
          and a1.customer_id    = a2.customer_id
          and o.object_id       = a2.id
          and o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          and o.service_id      = s.id
          and o.split_hash      = a1.split_hash
          and s.service_type_id = lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID
          and (l_invoice_date  >= o.start_date or o.start_date is null)
          and (l_start_date    <= o.end_date   or o.end_date   is null)
          and rownum = 1;

    exception
        when no_data_found then
            trc_log_pkg.debug('crd_api_exterenal_pkg.loyalty_points_sum: Unable to find loyalty service for customer');
    end;

    open o_ref_cursor for
        select a.account_number
             , l.loyalty_outgoing as current_points
             , l.loyalty_earned as earned_points
             , (select sum(b.amount - b.spent_amount)
                  from lty_bonus b
                 where to_char(b.expire_date, 'yyyy') > to_char(l_invoice_date, 'yyyy')
                   and b.status = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE
                   and b.account_id = l_loyalty_account_id) as expire_points
          from acc_account a
             , (
                select min(loyalty_earned) as loyalty_earned
                     , min(loyalty_outgoing) as loyalty_outgoing
                  from (
                        select sum(decode(e.balance_impact, 1, e.amount, null)) over () as loyalty_earned
                             , min(balance) keep (dense_rank last order by posting_order) over () as loyalty_outgoing
                          from acc_entry e
                         where e.account_id = l_loyalty_account_id
                           and e.posting_date between nvl(l_start_date, e.posting_date) and l_invoice_date
                       )
               ) l
         where a.id = l_account_id;

end loyalty_points_sum;

-- Summary of limits by credit service
procedure credit_service_limits(
    i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_account_number    in     com_api_type_pkg.t_account_number    default null
    , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
    , o_ref_cursor           out sys_refcursor
) is
    l_account_id                 com_api_type_pkg.t_account_id;
    l_invoice_id                 com_api_type_pkg.t_medium_id;
    l_invoice_date               date;
    l_start_date                 date;
begin
    trc_log_pkg.debug (
        i_text              => 'Start credit_service_limits. i_inst_id [#1], i_account_number [#2], i_invoice_id [#3]'
        , i_env_param1      => i_inst_id
        , i_env_param2      => i_account_number
        , i_env_param3      => i_invoice_id
    );

    if i_account_number is null and i_invoice_id is null then
        com_api_error_pkg.raise_error (
            i_error         => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
        );
    end if;

    -- get current invoice
    begin
        select i.account_id
             , i.id
             , i.invoice_date
             , i.start_date
          into l_account_id
             , l_invoice_id
             , l_invoice_date
             , l_start_date
          from crd_invoice i
             , acc_account a
         where a.inst_id = i_inst_id
           and i.account_id = a.id
           and (a.account_number = i_account_number or i_account_number is null)
           and (i.id = i_invoice_id or i_invoice_id is null)
           and i.id in (select nvl(max(ii.id), i.id)
                          from crd_invoice ii
                         where ii.account_id = a.id
                           and i_invoice_id is null);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'INVOICE_NOT_FOUND'
                , i_env_param1  => i_invoice_id
            );
    end;

    open o_ref_cursor for
        select a.account_number
             , b.balance as total_credit_limit
             , fcl_api_limit_pkg.get_sum_limit(
                   i_limit_type        => crd_api_const_pkg.ACCOUNT_CASH_VALUE_LIMIT_TYPE
                 , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 , i_object_id         => a.id
                 , i_split_hash        => a.split_hash
                 , i_mask_error        => com_api_const_pkg.TRUE
               ) as total_cash_limit
          from acc_account a
             , acc_balance b
         where a.id = l_account_id
           and b.account_id = a.id
           and b.balance_type = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
           and b.status = acc_api_const_pkg.BALANCE_STATUS_ACTIVE;

end credit_service_limits;

-- Account's cards
procedure account_cards(
    i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_account_number    in     com_api_type_pkg.t_account_number    default null
    , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
    , o_ref_cursor           out sys_refcursor
) is
    l_account_id                 com_api_type_pkg.t_account_id;
    l_invoice_id                 com_api_type_pkg.t_medium_id;
    l_invoice_date               date;
    l_start_date                 date;
    l_debit_account_number       com_api_type_pkg.t_account_number;
begin
    trc_log_pkg.debug (
        i_text              => 'Start account_cards. i_inst_id [#1], i_account_number [#2], i_invoice_id [#3]'
        , i_env_param1      => i_inst_id
        , i_env_param2      => i_account_number
        , i_env_param3      => i_invoice_id
    );

    if i_account_number is null and i_invoice_id is null then
        com_api_error_pkg.raise_error (
            i_error         => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
        );
    end if;

    -- get current invoice
    begin
        select i.account_id
             , i.id
             , i.invoice_date
             , i.start_date
          into l_account_id
             , l_invoice_id
             , l_invoice_date
             , l_start_date
          from crd_invoice i
             , acc_account a
         where a.inst_id = i_inst_id
           and i.account_id = a.id
           and (a.account_number = i_account_number or i_account_number is null)
           and (i.id = i_invoice_id or i_invoice_id is null)
           and i.id in (select nvl(max(ii.id), i.id)
                          from crd_invoice ii
                         where ii.account_id = a.id
                           and i_invoice_id is null);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'INVOICE_NOT_FOUND'
                , i_env_param1  => i_invoice_id
            );
    end;

    -- get debit account
    select max(a.account_number)
      into l_debit_account_number
      from acc_account a
         , iss_card_vw c
         , acc_account_object ao
         , acc_account_object aom
     where a.id != l_account_id
       and l_account_id = ao.account_id
       and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
       and ao.object_id = c.id
       and aom.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
       and aom.object_id = c.id
       and aom.account_id = a.id
       and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CARD;

    open o_ref_cursor for
        select a.account_number
             , c.category as card_type
             , lpad(iss_api_card_pkg.get_short_card_mask(i_card_number => c.card_number), 16, '*') as card_number
             , l_debit_account_number as saving_account_number
             , prd_ui_product_pkg.get_product_name(i_product_id => cn.product_id) as product_name
          from acc_account a
             , iss_card_vw c
             , acc_account_object ao
             , prd_contract cn
         where a.id = l_account_id
           and a.id = ao.account_id
           and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and ao.object_id = c.id
           and c.contract_id = cn.id;

end account_cards;

-- Due amounts
procedure due_amounts(
    i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_account_number    in     com_api_type_pkg.t_account_number    default null
    , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
    , o_ref_cursor           out sys_refcursor
) is
    l_account_id                 com_api_type_pkg.t_account_id;
    l_invoice_id                 com_api_type_pkg.t_medium_id;
    l_invoice_date               date;
    l_start_date                 date;
begin
    trc_log_pkg.debug (
        i_text              => 'Start due_amounts. i_inst_id [#1], i_account_number [#2], i_invoice_id [#3]'
        , i_env_param1      => i_inst_id
        , i_env_param2      => i_account_number
        , i_env_param3      => i_invoice_id
    );

    if i_account_number is null and i_invoice_id is null then
        com_api_error_pkg.raise_error (
            i_error         => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
        );
    end if;

    -- get current invoice
    begin
        select i.account_id
             , i.id
             , i.invoice_date
             , i.start_date
          into l_account_id
             , l_invoice_id
             , l_invoice_date
             , l_start_date
          from crd_invoice i
             , acc_account a
         where a.inst_id = i_inst_id
           and i.account_id = a.id
           and (a.account_number = i_account_number or i_account_number is null)
           and (i.id = i_invoice_id or i_invoice_id is null)
           and i.id in (select nvl(max(ii.id), i.id)
                          from crd_invoice ii
                         where ii.account_id = a.id
                           and i_invoice_id is null);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'INVOICE_NOT_FOUND'
                , i_env_param1  => i_invoice_id
            );
    end;

    open o_ref_cursor for
        select a.account_number
             , 'Delinquency amount' as description
             , a.currency as currency
             , i.overdue_balance as transaction_amount
             , i.overdue_balance as billing_principal_amount
             , i.overdue_intr_balance as interest_fee
          from acc_account a
             , crd_invoice i
         where i.id = l_invoice_id
           and i.account_id = a.id
     union all
        select a.account_number
             , 'Non delinquency Overdue Amount' as description
             , a.currency as currency
             , i.overdraft_balance as transaction_amount
             , i.overdraft_balance as billing_principal_amount
             , i.interest_balance as interest_fee
          from acc_account a
             , crd_invoice i
         where i.id = l_invoice_id
           and i.account_id = a.id;

end due_amounts;

-- Transactions
procedure transactions(
    i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_account_number    in     com_api_type_pkg.t_account_number    default null
    , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
    , i_currency          in     com_api_type_pkg.t_curr_code
    , i_rate_type         in     com_api_type_pkg.t_dict_value
    , o_ref_cursor           out sys_refcursor
) is
    l_account_id                 com_api_type_pkg.t_account_id;
    l_invoice_id                 com_api_type_pkg.t_medium_id;
    l_invoice_date               date;
    l_start_date                 date;
    l_loyalty_account_id         com_api_type_pkg.t_account_id;
    l_service_name               com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug (
        i_text              => 'Start due_amounts. i_inst_id [#1], i_account_number [#2], i_invoice_id [#3], i_currency[#4], i_rate_type [#5]'
        , i_env_param1      => i_inst_id
        , i_env_param2      => i_account_number
        , i_env_param3      => i_invoice_id
        , i_env_param4      => i_currency
        , i_env_param5      => i_rate_type
    );

    if i_account_number is null and i_invoice_id is null or i_currency is null or i_rate_type is null then
        com_api_error_pkg.raise_error (
            i_error         => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
        );
    end if;

    -- get current invoice
    begin
        select i.account_id
             , i.id
             , i.invoice_date
             , i.start_date
          into l_account_id
             , l_invoice_id
             , l_invoice_date
             , l_start_date
          from crd_invoice i
             , acc_account a
         where a.inst_id = i_inst_id
           and i.account_id = a.id
           and (a.account_number = i_account_number or i_account_number is null)
           and (i.id = i_invoice_id or i_invoice_id is null)
           and i.id in (select nvl(max(ii.id), i.id)
                          from crd_invoice ii
                         where ii.account_id = a.id
                           and i_invoice_id is null);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'INVOICE_NOT_FOUND'
                , i_env_param1  => i_invoice_id
            );
    end;

    begin
        select a2.id
             , get_text (i_table_name    => 'prd_service',
                         i_column_name   => 'label',
                         i_object_id     => s.id)
          into l_loyalty_account_id
             , l_service_name
          from prd_service s
             , prd_service_object o
             , acc_account a1
             , acc_account a2
        where a1.id             = l_account_id
          and a1.customer_id    = a2.customer_id
          and o.object_id       = a2.id
          and o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          and o.service_id      = s.id
          and o.split_hash      = a1.split_hash
          and s.service_type_id = lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID
          and (l_invoice_date  >= o.start_date or o.start_date is null)
          and (l_start_date    <= o.end_date   or o.end_date   is null)
          and rownum = 1;

    exception
        when no_data_found then
            trc_log_pkg.debug('crd_api_exterenal_pkg.loyalty_points_sum: Unable to find loyalty service for customer');
    end;

    open o_ref_cursor for
        select a.account_number
             , d.oper_date as transaction_date
             , d.posting_date as acquire_date
             , o.merchant_name
             , d.currency
             , d.amount as transaction_amount
             , null as discount
             , case
                   when d.currency != i_currency
                   then decode(
                               o.sttl_currency
                             , mcw_api_const_pkg.CURRENCY_CODE_US_DOLLAR
                             , o.sttl_amount
                             , com_api_rate_pkg.convert_amount(
                                   i_src_amount        => o.sttl_amount
                                 , i_src_currency      => o.sttl_currency
                                 , i_dst_currency      => mcw_api_const_pkg.CURRENCY_CODE_US_DOLLAR
                                 , i_rate_type         => i_rate_type
                                 , i_inst_id           => i_inst_id
                                 , i_eff_date          => d.oper_date
                                 , i_mask_exception    => com_api_const_pkg.TRUE
                                 , i_exception_value   => null
                               )
                        )
                   else null
               end as overseas
             , nvl(dpp.instalment_amount, d.amount) as billing_principal_amount
             , (select nvl(sum(di.interest_amount), 0)
                  from crd_debt_interest di
                 where di.debt_id = d.id
               ) +
               case
                   when nvl(o.fee_currency, i_currency) != i_currency
                   then decode(
                               nvl(o.fee_currency, i_currency)
                             , i_currency
                             , nvl(o.fee_amount, 0)
                             , com_api_rate_pkg.convert_amount(
                                   i_src_amount        => nvl(o.fee_amount, 0)
                                 , i_src_currency      => nvl(o.fee_currency, i_currency)
                                 , i_dst_currency      => i_currency
                                 , i_rate_type         => i_rate_type
                                 , i_inst_id           => i_inst_id
                                 , i_eff_date          => d.oper_date
                                 , i_mask_exception    => com_api_const_pkg.TRUE
                                 , i_exception_value   => null
                               )
                        )
                   else nvl(o.fee_amount, 0)
               end as interest_fee
             , case
                   when d.currency != i_currency
                   then com_api_rate_pkg.get_rate (
                            i_src_currency          => mcw_api_const_pkg.CURRENCY_CODE_US_DOLLAR
                            , i_dst_currency        => i_currency
                            , i_rate_type           => i_rate_type
                            , i_inst_id             => i_inst_id
                            , i_eff_date            => d.oper_date
                            , i_conversion_type     => com_api_const_pkg.CONVERSION_TYPE_SELLING
                            , i_mask_exception      => com_api_type_pkg.TRUE
                            , i_exception_value     => null
                        )
                   else null
               end as exchange_rate
             , case
                   when (select sum(decode(e.balance_impact, 1, e.amount, null)) over () as loyalty_earned
                           from acc_entry e
                          where e.account_id = l_loyalty_account_id
                            and e.macros_id = d.id
                        ) is not null
                   then l_service_name
                   else null
               end as point_name
             , (select sum(decode(e.balance_impact, 1, e.amount, null)) over () as loyalty_earned
                  from acc_entry e
                 where e.account_id = l_loyalty_account_id
                   and e.macros_id = d.id
               ) as earned_point
             , (select max(di.instalment_number)
                  from dpp_instalment di
                 where di.dpp_id = dpp.id
               ) as dpp_period
             , dpp.instalment_billed as dpp_count
             , dpp.debt_balance as remaining_balance
             , lpad(iss_api_card_pkg.get_short_card_mask(i_card_number => c.card_number), 16, '*') as card_number
             , c.id as card_id
          from acc_account a
             , crd_invoice i
             , crd_debt d
             , crd_invoice_debt cid
             , opr_operation o
             , dpp_payment_plan dpp
             , iss_card_vw c
         where i.id = l_invoice_id
           and i.account_id = a.id
           and d.id = cid.debt_id
           and i.id = cid.invoice_id
           and d.oper_id = o.id
           and d.id = dpp.id(+)
           and d.card_id = c.id;
end transactions;

-- Accounts in collection
procedure accounts_in_collection(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_ids_type          in      com_api_type_pkg.t_dict_value
  , i_account_type      in      com_api_type_pkg.t_dict_value   default acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
  , i_account_status    in      com_api_type_pkg.t_dict_value   default null
  , i_min_aging_period  in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , o_ref_cursor           out  sys_refcursor
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.accounts_in_collection: ';
    l_eff_date                  date;
begin
    l_eff_date :=
        coalesce(
            i_eff_date
          , com_api_sttl_day_pkg.get_calc_date(
                i_inst_id => i_inst_id
            )
        );

    trc_log_pkg.debug(
        i_text          => LOG_PREFIX ||'i_inst_id [#1], i_ids_type [#2], i_account_type [#3], i_account_status [#4], i_min_aging_period [#5], l_eff_date [#6]'
      , i_env_param1    => i_inst_id
      , i_env_param2    => i_ids_type
      , i_env_param3    => i_account_type
      , i_env_param4    => i_account_status
      , i_env_param5    => i_min_aging_period
      , i_env_param6    => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
    );

    open o_ref_cursor for
        with ad as(
            select row_number() over(partition by o.object_id order by decode(o.address_type, com_api_const_pkg.ADDRESS_TYPE_HOME, 1, 9)) as rnum
                 , o.address_type   as address_type
                 , a.country        as address_country
                 , a.region         as address_region
                 , a.city           as address_city
                 , a.street         as address_street
                 , a.house          as address_house
                 , a.apartment      as address_apartment
                 , o.object_id      as customer_id
              from com_address_object o
                 , com_address a
             where o.entity_type    = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
               and a.id             = o.address_id
        ), ct as (
            select row_number() over(partition by co.object_id
                                     order by decode(co.contact_type, com_api_const_pkg.CONTACT_TYPE_PRIMARY, 1, 9)) as rnum
                 , co.contact_type
                 , ct.preferred_lang
                 , cd.commun_method
                 , cd.commun_address
                 , co.object_id  as customer_id
              from com_contact ct
                 , com_contact_object co
                 , com_contact_data cd
             where ct.id            = co.contact_id
               and ct.id            = cd.contact_id
               and co.entity_type   = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
               and l_eff_date between nvl(cd.start_date, l_eff_date) and nvl(cd.end_date, l_eff_date)
        )
        select t1.account_id
             , t1.account_number
             , t1.account_type
             , t1.account_currency
             , t1.account_status
             , c.card_mask
             , ci.agent_id         as agent_id
             , get_text(
                   i_table_name    => 'ost_agent'
                 , i_column_name   => 'name'
                 , i_object_id     => ci.agent_id
                 , i_lang          => nvl(get_user_lang(), com_api_const_pkg.DEFAULT_LANGUAGE)
               )                   as agent_name
             , ci.expir_date       as card_expire_date
             , t1.aging_period
             , t1.total_outstanding_value
             , t1.min_amount_due
             , cu.category         as customer_category
             , cu.relation         as customer_relation
             , cn.contract_type
             , cn.contract_number
             , pr.surname
             , pr.first_name
             , pr.second_name
             , io.id_type          as id_type
             , io.id_series        as id_series
             , io.id_number        as id_number
             , ct.contact_type
             , ct.preferred_lang
             , ct.commun_method
             , ct.commun_address
             , ad.address_type
             , ad.address_country
             , ad.address_region
             , ad.address_city
             , ad.address_street
             , ad.address_house
             , ad.address_apartment
          from(
               select a.id                 as account_id
                    , a.split_hash         as split_hash
                    , a.account_number     as account_number
                    , a.account_type       as account_type
                    , a.currency           as account_currency
                    , a.status             as account_status
                    , i.min_amount_due     as min_amount_due
                    , i.total_amount_due   as total_outstanding_value
                    , i.aging_period       as aging_period
                 from acc_account a
                    , crd_invoice i
                where a.account_type   = i_account_type
                  and (   a.inst_id    = i_inst_id
                       or i_inst_id    = ost_api_const_pkg.DEFAULT_INST
                      )
                  and (   a.status     = i_account_status
                       or i_account_status is null
                       )
                  and i.id = (select max(inv.id) keep (dense_rank last order by inv.invoice_date) as id
                                from crd_invoice inv
                               where inv.account_id = a.id
                                 and inv.split_hash = a.split_hash
                                 and inv.aging_period >= nvl(i_min_aging_period, 0)
                                 and inv.aging_period > 0
                             )
                  and a.id         = i.account_id
                  and a.split_hash = i.split_hash
                  and crd_api_service_pkg.get_active_service(
                          i_account_id     => a.id
                        , i_eff_date       => l_eff_date
                        , i_split_hash     => a.split_hash
                        , i_mask_error     => com_api_const_pkg.TRUE
                      ) is not null
               ) t1
             , iss_card c
             , iss_card_instance ci
             , acc_account_object ao
             , prd_customer cu
             , prd_contract cn
             , iss_cardholder ch
             , com_person pr
             , com_id_object io
             , ad
             , ct
         where t1.account_id             = ao.account_id
           and t1.split_hash             = ao.split_hash
           and ao.entity_type            = iss_api_const_pkg.ENTITY_TYPE_CARD
           and ao.object_id              = c.id
           and ao.split_hash             = c.split_hash
           and ci.card_id                = c.id
           and ci.split_hash             = c.split_hash
           and ci.state                 != iss_api_const_pkg.CARD_STATE_CLOSED
           and c.customer_id             = cu.id
           and cu.entity_type            = com_api_const_pkg.ENTITY_TYPE_PERSON
           and c.contract_id             = cn.id
           and c.cardholder_id           = ch.id
           and ch.person_id              = pr.id(+)
           and pr.id                     = io.object_id(+)
           and io.id_type(+)             = i_ids_type
           and io.entity_type(+)         = com_api_const_pkg.ENTITY_TYPE_PERSON
           and cu.id                     = ad.customer_id(+)
           and ad.rnum(+)                = 1
           and cu.id                     = ct.customer_id(+)
           and ct.rnum(+)                = 1;

end accounts_in_collection;

end;
/
