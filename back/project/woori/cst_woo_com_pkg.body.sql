create or replace package body cst_woo_com_pkg as
/************************************************************
 * Common functions for batch files of Woori bank  <br />
 * Created by:
    Chau Huynh (huynh@bpcbt.com)
    Man Do     (m.do@bpcbt.com)  at 2017-03-03   $ <br />
 * Last changed by $Author: Man Do               $ <br />
 * $LastChangedDate:        2017-11-01 11:00     $ <br />
 * Revision: $LastChangedRevision:  80b4e97c     $ <br />
 * Module: cst_woo_com_pkg                         <br />
 * @headcom
 *************************************************************/

function get_cur_month(
    i_date                  in      date    default null
) return com_api_type_pkg.t_date_tab        deterministic
is
    l_date_tab        com_api_type_pkg.t_date_tab;
begin
    if i_date is null then
        l_date_tab(1) := trunc(sysdate, 'month');
        l_date_tab(2) := last_day(trunc(sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
    else
        l_date_tab(1) := trunc(i_date, 'month');
        l_date_tab(2) := last_day(trunc(i_date)) + 1 - com_api_const_pkg.ONE_SECOND;
    end if;

    return l_date_tab;
end get_cur_month;

function get_first_overdue_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return date
is
    l_last_invoice_id               com_api_type_pkg.t_medium_id;
    l_aging_period                  com_api_type_pkg.t_tiny_id;
    l_first_overdue_date            date;
begin

    l_last_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                            i_account_id    => i_account_id
                          , i_split_hash    => i_split_hash
                          , i_mask_error    => com_api_const_pkg.TRUE
                        );

    select aging_period
         , due_date
      into l_aging_period
         , l_first_overdue_date
      from crd_invoice
     where id = l_last_invoice_id;

    if l_aging_period = 0 then
        return null;
    elsif l_aging_period = 1 then
        return l_first_overdue_date;
    else
        select max(due_date)
          into l_first_overdue_date
          from crd_invoice
         where account_id   = i_account_id
           and split_hash   = i_split_hash
           and aging_period = 1;
        return l_first_overdue_date;
    end if;
end get_first_overdue_date;

function get_payment_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return date
is
    l_last_invoice_id       com_api_type_pkg.t_medium_id;
    l_aging_period          com_api_type_pkg.t_tiny_id;
    l_payment_date          date default null;
begin
    l_last_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                            i_account_id    => i_account_id
                          , i_split_hash    => i_split_hash
                          , i_mask_error    => com_api_const_pkg.TRUE
                         );

    select due_date
      into l_payment_date
      from crd_invoice
     where id = l_last_invoice_id;

    return l_payment_date;
end get_payment_date;

function get_fist_request_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return date
is
    l_last_invoice_id       com_api_type_pkg.t_medium_id;
    l_aging_period          com_api_type_pkg.t_tiny_id;
    l_first_request_date    date;
begin

    l_last_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                            i_account_id    => i_account_id
                          , i_split_hash    => i_split_hash
                          , i_mask_error    => com_api_const_pkg.TRUE
                        );

    select aging_period
         , invoice_date
      into l_aging_period, l_first_request_date
      from crd_invoice
     where id = l_last_invoice_id;

    if l_aging_period = 0 then
        return null;
    elsif l_aging_period = 1 then
        return l_first_request_date;
    else
        select max(invoice_date)
          into l_first_request_date
          from crd_invoice
         where account_id   = i_account_id
           and split_hash   = i_split_hash
           and aging_period = 1;
    end if;

    return l_first_request_date;
end get_fist_request_date;

function get_annual_fee(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money
is
    l_annual_fee            com_api_type_pkg.t_money := 0;
begin
    select sum(amount)
      into l_annual_fee
      from crd_debt d
     where d.account_id = i_account_id
       and d.split_hash = i_split_hash
       and d.oper_type  = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE -- 'OPTP0119'
       and d.fee_type in (
             cst_woo_const_pkg.ACCT_MAINTENANCE_FEE --'FETP0301'
           , mcw_api_const_pkg.ANNUAL_CARD_FEE      --'FETP0102'
           , cst_woo_const_pkg.MAINTENANCE_FEE      --'FETP0202'
           );

    return l_annual_fee;
end get_annual_fee;

function get_overdue_fee(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_is_dom                in      com_api_type_pkg.t_boolean       default null
  , i_is_dpp                in      com_api_type_pkg.t_boolean       default null
  , i_trx_type              in      com_api_type_pkg.t_dict_value    default null
  , i_bill_date             in      date                             default null
) return com_api_type_pkg.t_money
is
    l_overdue_fee           com_api_type_pkg.t_money := 0;
begin
    select nvl(sum(d.amount), 0)
      into l_overdue_fee
      from crd_debt d
         , opr_participant prt
         , opr_operation opr
     where d.oper_id         = opr.id
       and d.oper_id         = prt.oper_id
       and d.fee_type        = crd_api_const_pkg.PENALTY_RATE_FEE_TYPE --'FETP1003'
       --and v.is_new          = 1
       and (case
                when i_is_dom = com_api_type_pkg.TRUE
                    and (opr.sttl_type in (
                          opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                        , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                        )
                    or (opr.merchant_country = prt.card_country)) then 1
                when i_is_dom = com_api_type_pkg.TRUE
                    and opr.merchant_country != prt.card_country  then 0
                when i_is_dom = com_api_type_pkg.FALSE
                    and  (opr.sttl_type in (
                          opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                        , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                        )
                    or (opr.merchant_country  = prt.card_country)) then 0
                 when i_is_dom = com_api_type_pkg.FALSE
                    and opr.merchant_country != prt.card_country then 1
                else 1
            end)             = 1
       and (case
               when (i_is_dpp is not null and
                     i_is_dpp = com_api_type_pkg.TRUE) then dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE  --'OPTP1500'
               else d.oper_type
               end
           ) = d.oper_type
       and (case
                when (i_bill_date is not null)
                     and d.oper_date between i_bill_date and add_months(i_bill_date, 1)
                     then 1
                else 0
                end
           ) = 1
       and not (i_is_dpp = com_api_type_pkg.FALSE and d.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE) --'OPTP1500'
       and nvl (i_trx_type, opr.oper_type)  = opr.oper_type
       and opr.status                       = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and d.account_id                     = i_account_id
       ;

    return l_overdue_fee;
end get_overdue_fee;

function get_overdue_amt(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_is_dom                in      com_api_type_pkg.t_boolean       default null
  , i_trx_type              in      com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_money
is
    l_last_invoice_id       com_api_type_pkg.t_medium_id;
    l_overdue_amount        com_api_type_pkg.t_money;
    l_penalty_date          date;
begin
    l_last_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                            i_account_id    => i_account_id
                          , i_split_hash    => i_split_hash
                          , i_mask_error    => com_api_const_pkg.TRUE
                        );

    select penalty_date
      into l_penalty_date
      from crd_invoice
     where id = l_last_invoice_id;

    select nvl(sum(i.amount), 0)
      into l_overdue_amount
      from (select max(i.id) max_intr_id
                 , i.balance_type
                 , d.id debt_id
              from crd_debt_interest i
                 , crd_debt d
                 , opr_participant   prt
                 , opr_operation     opr
             where d.id in (select debt_id
                              from crd_invoice_debt
                             where invoice_id = l_last_invoice_id
                               and split_hash = i_split_hash)
               and i.debt_id         = d.id
               and i.split_hash      = i_split_hash
               and i.id between      trunc(d.id, com_api_id_pkg.DAY_ROUNDING) and trunc(d.id, com_api_id_pkg.DAY_ROUNDING) + com_api_id_pkg.DAY_TILL_ID
               and i.balance_type    in (crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST, crd_api_const_pkg.BALANCE_TYPE_OVERDUE)
               and i.balance_date    <= l_penalty_date
               and d.oper_id         = opr.id
               and prt.oper_id       = opr.id
               and (case
                    when i_is_dom = com_api_type_pkg.TRUE
                        and (opr.sttl_type in (
                              opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                            , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                            , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                            , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                            )
                        or (opr.merchant_country = prt.card_country)) then 1
                    when i_is_dom = com_api_type_pkg.TRUE
                        and opr.merchant_country != prt.card_country  then 0
                    when i_is_dom = com_api_type_pkg.FALSE
                        and  (opr.sttl_type in (
                              opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                            , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                            , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                            , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                            )
                        or (opr.merchant_country  = prt.card_country)) then 0
                     when i_is_dom = com_api_type_pkg.FALSE
                        and opr.merchant_country != prt.card_country then 1
                    else 1
                    end)                            = 1
               and nvl(i_trx_type, opr.oper_type)   = opr.oper_type
               and opr.status                       = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
               and opr.oper_reason                 != mcw_api_const_pkg.ANNUAL_CARD_FEE             --'FETP0102'
             group by i.balance_type, d.id
            ) intr
          , crd_debt_interest i
    where intr.max_intr_id = i.id;

    return l_overdue_amount;
end get_overdue_amt;

function get_tran_fee(
    i_account_num           in      com_api_type_pkg.t_account_number
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_oper_typ              in      com_dict_tpt
  , i_fee_typ               in      com_api_type_pkg.t_dict_value
  , i_is_dom                in      com_api_type_pkg.t_boolean
  , i_start_date            in      date                             default null
  , i_end_date              in      date                             default null
) return com_api_type_pkg.t_money
is
    l_total_fee_amt         com_api_type_pkg.t_money;
    l_start_date            date;
    l_end_date              date;
    l_date_tab              com_api_type_pkg.t_date_tab;
begin
    l_date_tab       := get_cur_month;
    if i_start_date is null then
        l_start_date := l_date_tab(1);
    else
        l_start_date := i_start_date;
    end if;

    if i_end_date is null then
        l_end_date   := l_date_tab(2);
    else
        l_end_date   := i_end_date;
    end if;

    select sum(f.amount)
      into l_total_fee_amt
      from opr_additional_amount f
         , opr_participant prt
         , opr_operation opr
     where opr.oper_type in (select column_value from table(cast(i_oper_typ as com_dict_tpt)))--i_oper_id
       and f.oper_id            = prt.oper_id
       and f.amount_type        = i_fee_typ
       and prt.account_number   = i_account_num
       and prt.split_hash       = i_split_hash
       and opr.id               = f.oper_id
       and opr.status           = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and (case
            when i_is_dom = com_api_type_pkg.TRUE
                and (opr.sttl_type in (
                      opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                    , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                    )
                or (opr.merchant_country = prt.card_country)) then 1
            when i_is_dom = com_api_type_pkg.TRUE
                and opr.merchant_country != prt.card_country  then 0
            when i_is_dom = com_api_type_pkg.FALSE
                and  (opr.sttl_type in (
                      opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                    , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                    )
                or (opr.merchant_country  = prt.card_country)) then 0
             when i_is_dom = com_api_type_pkg.FALSE
                and opr.merchant_country != prt.card_country then 1
            else 1
        end)                 = 1
        and opr.oper_date       between l_start_date and l_end_date
    ;

   return l_total_fee_amt;
end get_tran_fee;

function get_total_debt(
    i_account_id            in      com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_money
is
    l_account_id            com_api_type_pkg.t_account_id;
    l_total_account_debt    com_api_type_pkg.t_money := 0;
    l_balances              com_api_type_pkg.t_amount_by_name_tab;
begin
    -- total_account_debt
    acc_api_balance_pkg.get_account_balances (
        i_account_id    => i_account_id
      , o_balances      => l_balances
   );

    l_total_account_debt := l_balances(acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT).amount             --'BLTP1002'
                            + l_balances(acc_api_const_pkg.BALANCE_TYPE_OVERDUE).amount             --'BLTP1004'
                            + l_balances(crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST).amount    --'BLTP1007'
                            + l_balances(acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT).amount
                            + l_balances(crd_api_const_pkg.BALANCE_TYPE_INTR_OVERLIMIT).amount      --Interest on Overlimit 'BLTP1008'
                            + l_balances(crd_api_const_pkg.BALANCE_TYPE_INTEREST).amount            --Interest BLTP1003
                            + l_balances(crd_api_const_pkg.BALANCE_TYPE_PENALTY).amount             --Penalty BLTP1006
                            --+ l_balances(cst_woo_const_pkg.BALANCE_TYPE_VAT).amount                 --'BLTP5002'
                            ;

    return abs(l_total_account_debt);
end get_total_debt;

function get_overdue_interest(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_is_dom                in      com_api_type_pkg.t_boolean       default null
  , i_is_dpp                in      com_api_type_pkg.t_boolean       default null
  , i_trx_type              in      com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_money
is
    l_interest_amount       com_api_type_pkg.t_money := 0;
begin
    select round(sum(n.interest_amount))
      into l_interest_amount
      from (select debt_id
                 , sum(interest_amount) as interest_amount
              from crd_debt_interest
             where 1 = 1--invoice_id = i_invoice_id
             --and balance_type = crd_api_const_pkg.BALANCE_TYPE_INTEREST --'BLTP1003'
             group by debt_id
            ) n
         , crd_debt d
         , opr_operation opr
         , opr_participant prt
      where n.debt_id       = d.id
        and d.oper_id       = opr.id
        and opr.status      = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
        and (case
            when i_is_dom = com_api_type_pkg.TRUE
                and (opr.sttl_type in (
                      opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                    , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                    )
                or (opr.merchant_country = prt.card_country)) then 1
            when i_is_dom = com_api_type_pkg.TRUE
                and opr.merchant_country != prt.card_country  then 0
            when i_is_dom = com_api_type_pkg.FALSE
                and  (opr.sttl_type in (
                      opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                    , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                    )
                or (opr.merchant_country  = prt.card_country)) then 0
             when i_is_dom = com_api_type_pkg.FALSE
                and opr.merchant_country != prt.card_country then 1
                    else 1
            end)                 = 1
        and (case
                when (i_is_dpp    is not null and
                      i_is_dpp    = com_api_type_pkg.TRUE) then dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE --'OPTP1500'
                else d.oper_type
             end
            ) = d.oper_type
        and not(i_is_dpp                 = com_api_type_pkg.FALSE and d.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE)
        and nvl(i_trx_type, d.oper_type) = d.oper_type
        and d.account_id                 = i_account_id
        and d.split_hash                 = i_split_hash
        ;

    return l_interest_amount;
end get_overdue_interest;

function get_bill_amt(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_is_dom                in      com_api_type_pkg.t_boolean       default null
  , i_is_dpp                in      com_api_type_pkg.t_boolean       default null
  , i_start_date            in      date                             default null
  , i_end_date              in      date                             default null
) return com_api_type_pkg.t_money
is
    l_debt_amount           com_api_type_pkg.t_money := 0;
    l_start_date            date;
    l_end_date              date;
    l_date_tab              com_api_type_pkg.t_date_tab;
begin
    l_date_tab := get_cur_month;
    if i_start_date is null then
        --i_start_date := trunc(sysdate, 'month');
        l_start_date := l_date_tab(1);
    else
        l_start_date := i_start_date;
    end if;

    if i_end_date is null then
        --i_end_date := last_day(trunc(sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
        l_end_date := l_date_tab(2);
    else
        l_end_date := i_end_date;
    end if;

    select sum(d.debt_amount)
      into l_debt_amount
      from crd_debt         d
         , opr_participant  prt
         , opr_operation    opr
     where
           (case
                when (i_is_dpp is not null and
                     i_is_dpp    = com_api_type_pkg.TRUE) then dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE --'OPTP1500'
                else d.oper_type
            end
           ) = d.oper_type
       and not (i_is_dpp         = com_api_type_pkg.FALSE and d.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE) ----'OPTP1500'
       and d.oper_id             = opr.id
       and d.oper_id             = prt.oper_id
       and opr.status            = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and (case
                when i_is_dom = com_api_type_pkg.TRUE
                    and (opr.sttl_type in (
                          opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                        , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                        )
                    or (opr.merchant_country = prt.card_country)) then 1
                when i_is_dom = com_api_type_pkg.TRUE
                    and opr.merchant_country != prt.card_country  then 0
                when i_is_dom = com_api_type_pkg.FALSE
                    and  (opr.sttl_type in (
                          opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                        , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                        )
                    or (opr.merchant_country  = prt.card_country)) then 0
                 when i_is_dom = com_api_type_pkg.FALSE
                    and opr.merchant_country != prt.card_country then 1
                else 1
            end)                 = 1
       and prt.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
       and d.account_id          = i_account_id
       and d.split_hash          = i_split_hash
       and d.status              = crd_api_const_pkg.DEBT_STATUS_ACTIVE --DBTSACTV
       and d.id       in (select debt_id
                            from crd_invoice_debt  cid
                               , crd_invoice       ci
                           where cid.invoice_id    = ci.id
                             and cid.split_hash    = i_split_hash
                             and ci.due_date       between l_start_date and l_end_date
                           );
    return l_debt_amount;
end get_bill_amt;

function get_cash_advance(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_is_dom                in      com_api_type_pkg.t_boolean       default null
  , i_start_date            in      date                             default null
  , i_end_date              in      date                             default null
) return com_api_type_pkg.t_money
is
    l_dom_cash_adv_amt      com_api_type_pkg.t_money    := 0;
    l_start_date            date;
    l_end_date              date;
    l_date_tab              com_api_type_pkg.t_date_tab;
begin
    l_date_tab          := get_cur_month;
    if i_start_date is null then
        --i_start_date := trunc(sysdate, 'month');
        l_start_date    := l_date_tab(1);
    else
        l_start_date    := i_start_date;
    end if;

    if i_end_date is null then
        --i_end_date := last_day(trunc(sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
        l_end_date      := l_date_tab(2);
    else
        l_end_date      := i_end_date;
    end if;

    select sum(debt_amount)
      into l_dom_cash_adv_amt
      from crd_debt           d
         , opr_participant    prt
         , opr_operation      opr
     where
           d.oper_id          = opr.id
       and d.oper_id          = prt.oper_id
       and opr.status         = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and d.oper_type        in (
             opr_api_const_pkg.OPERATION_TYPE_ATM_CASH          --'OPTP0001'
           , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT   --'OPTP0412'
           )
       and (case
                when i_is_dom = com_api_type_pkg.TRUE
                     and
                     (opr.sttl_type in (
                          opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                        , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                      )
                      or (opr.merchant_country = prt.card_country)
                     ) then 1
                when i_is_dom = com_api_type_pkg.TRUE
                    and opr.merchant_country != prt.card_country  then 0
                when i_is_dom = com_api_type_pkg.FALSE
                    and  (opr.sttl_type in (
                          opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                        , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                        , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                        )
                    or (opr.merchant_country  = prt.card_country)) then 0
                 when i_is_dom = com_api_type_pkg.FALSE
                    and opr.merchant_country != prt.card_country then 1
                else 1
            end)                 = 1
       and prt.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
       and d.account_id          = i_account_id
       and d.split_hash          = i_split_hash
       and d.status              = crd_api_const_pkg.DEBT_STATUS_ACTIVE --DBTSACTV
       and d.id       in (select debt_id
                            from crd_invoice_debt  cid
                               , crd_invoice       ci
                           where cid.invoice_id    = ci.id
                             and cid.split_hash    = i_split_hash
                             and ci.due_date       between l_start_date and l_end_date
                           )
    ;
    return l_dom_cash_adv_amt;
end get_cash_advance;

function get_loyalty_external_num(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name
is
    l_eff_date              date;
    l_external_number       com_api_type_pkg.t_name;
    l_service_id            com_api_type_pkg.t_short_id;
    l_product_id            com_api_type_pkg.t_short_id;
    l_params                com_api_type_pkg.t_param_tab;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_entity_type           com_api_type_pkg.t_dict_value;
    l_object_id             com_api_type_pkg.t_long_id;
begin
    l_eff_date := com_api_sttl_day_pkg.get_sysdate;
    begin
        select a.object_id
             , a.entity_type
             , s.id
             , c.product_id
             , c.inst_id
          into l_object_id
             , l_entity_type
             , l_service_id
             , l_product_id
             , l_inst_id
          from acc_account_object a
             , prd_contract c
             , prd_service s
             , prd_service_object o
         where a.account_id     = i_account_id
           and o.object_id      = a.object_id
           and o.entity_type    = a.entity_type
           and o.service_id     = s.id
           and o.split_hash     = i_split_hash
           and s.service_type_id in (lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID
                                   , lty_api_const_pkg.LOYALTY_SERVICE_ACC_TYPE_ID
                                   , lty_api_const_pkg.LOYALTY_SERVICE_MRCH_TYPE_ID)
           and o.contract_id    = c.id
           and rownum           = 1
          --and (l_end_date   >= o.start_date or o.start_date is null)
          --and (i_start_date <= o.end_date   or o.end_date   is null)
        ;
    exception
        when no_data_found then
             return null;
    end;

    begin
        l_external_number :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id   => l_product_id
          , i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
          , i_attr_name    => lty_api_bonus_pkg.decode_attr_name(
                                  i_attr_name    => lty_api_const_pkg.LOYALTY_EXTERNAL_NUMBER
                                , i_entity_type  => l_entity_type
                              )
          , i_params       => l_params
          , i_service_id   => l_service_id
          , i_eff_date     => l_eff_date
          , i_inst_id      => l_inst_id
        );
    exception
        when others then
             return null;
    end;

    return l_external_number;
end get_loyalty_external_num;

procedure get_latest_change_status(
    i_event_type_tab        in      com_dict_tpt
  , i_object_id             in      com_api_type_pkg.t_long_id
  , o_status                    out com_api_type_pkg.t_dict_value
  , o_eff_date                  out date
) is
begin
    select status, change_date
      into o_status, o_eff_date
      from (select status, change_date
              from evt_status_log
             where object_id = i_object_id
               and event_type in (select column_value
                                     from table(cast(i_event_type_tab  as com_dict_tpt)))
             order by id desc
            )
     where rownum = 1
     ;
end get_latest_change_status;

function get_latest_change_status_dt (
    i_event_type_tab        in      com_dict_tpt
  , i_object_id             in      com_api_type_pkg.t_long_id
) return date
is
    l_eff_date date;
begin
    select max(change_date)
      into l_eff_date
      from evt_status_log
     where object_id = i_object_id
       and event_type in (select column_value
                            from table(cast(i_event_type_tab  as com_dict_tpt)));

    return l_eff_date;
end get_latest_change_status_dt;

function date_yymm(
    i_date                  in      com_api_type_pkg.t_date_short
) return date
is
begin
    if i_date is null or i_date = '0000' then
        return null;
    end if;

    return to_date(i_date, 'YYMM');
end date_yymm;

function date_yymmdd(
    i_date                  in      com_api_type_pkg.t_date_short
) return date
is
begin
    if i_date is null or i_date = '000000' then
        return null;
    end if;

    return to_date(i_date, 'YYMMDD');
end date_yymmdd;

function date_yymmddhhmmss(
    i_date                  in      com_api_type_pkg.t_date_long
) return date
is
begin
    if i_date is null or i_date = '000000000000' then
        return null;
    end if;

    return to_date(i_date, 'YYMMDDHH24MISS');
end date_yymmddhhmmss;

function get_mapping_code(
    i_code                  in      com_api_type_pkg.t_attr_name
  , i_array_id              in      com_api_type_pkg.t_short_id
  , i_in_out                in      com_api_type_pkg.t_boolean       default 1
  , i_language              in      com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_name
is
    l_cursor                sys_refcursor;
    l_element_value         com_api_type_pkg.t_name;
    l_o_code                com_api_type_pkg.t_name;
begin
    if i_in_out = 1 then
        select label
          into l_o_code
          from com_ui_array_element_vw
         where element_value    = i_code
           and lang             = nvl(i_language, com_ui_user_env_pkg.get_user_lang)
           and array_id         = i_array_id
           and rownum = 1;
    else
        select element_value
          into l_o_code
          from com_ui_array_element_vw
         where label            = i_code
           and lang             = nvl(i_language, com_ui_user_env_pkg.get_user_lang)
           and array_id         = i_array_id
           and rownum = 1;
    end if;

    return l_o_code;
exception
    when others then
        return null;
end get_mapping_code;

function get_customer_type(
    i_customer_num          in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_dict_value
is
    l_customer_type    com_api_type_pkg.t_dict_value;
begin
    select entity_type
      into l_customer_type
      from prd_customer
     where customer_number = i_customer_num;

    return l_customer_type;

exception
    when others then
        return null;
end;

function get_contract_due_date(
    i_product_id            in      com_api_type_pkg.t_short_id
 ) return date
is
    l_contract_due_date     date;
begin
    --initial first date of month
    l_contract_due_date := trunc(sysdate, 'month');
    select (case fcs.shift_type
                when fcl_api_const_pkg.CYCLE_SHIFT_MONTH_DAY then
                     l_contract_due_date + (fcs.shift_sign * fcs.shift_length) - 1
            end
           ) into l_contract_due_date
      from fcl_cycle_shift fcs
         , fcl_cycle fc
     where 1 = 1
       and fcs.cycle_id = fc.id
       and fc.id = (select distinct convert_to_number(first_value(attr_value) over (order by register_timestamp desc)) as attr_value
                      from prd_attribute_value
                     where 1 = 1
                       and attr_id      = (select id from prd_attribute where attr_name = 'CRD_DUE_DATE_PERIOD')
                       and entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT --'ENTTPROD'
                       and object_id    in (select id
                                              from prd_product
                                             start with id = i_product_id
                                           connect by id   = prior parent_id)
                    );

    return l_contract_due_date;
exception
    when others then
        return null;
end get_contract_due_date;

function get_contract_bill_date(
    i_product_id            in      com_api_type_pkg.t_short_id
) return date
is
    l_contract_due_date     date;
begin
    --initial first date of month
    l_contract_due_date := trunc(sysdate, 'month');
    select (case fcs.shift_type
                when fcl_api_const_pkg.CYCLE_SHIFT_MONTH_DAY then
                     l_contract_due_date + (fcs.shift_sign * fcs.shift_length) - 1
            end
           ) into l_contract_due_date
      from fcl_cycle_shift fcs, fcl_cycle fc
     where 1 = 1
       and fcs.cycle_id = fc.id
       and fc.id = (select distinct convert_to_number(first_value(attr_value) over (order by register_timestamp desc)) as attr_value
                      from prd_attribute_value
                     where 1 = 1
                       and attr_id      = (select id
                                             from prd_attribute
                                            where attr_name = 'CRD_INVOICING_PERIOD')
                       and object_id    = i_product_id
                       and entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT --'ENTTPROD'
                    );

    return l_contract_due_date;
exception
    when others then
        return null;
end get_contract_bill_date;

function get_contact_type(
    i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_commun_method         in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value
is
    l_contact_type          com_api_type_pkg.t_dict_value;
begin
    select cco.contact_type
           into l_contact_type
      from com_contact_data    ccd
         , com_contact_object  cco
     where ccd.contact_id      = cco.contact_id
       and cco.entity_type     = com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
       and cco.object_id       = i_customer_id
       and ccd.commun_method   = i_commun_method
       and rownum              = 1;

    return l_contact_type;
exception
    when others then
        return null;
end;

function get_card_uid(
    i_customer_num          in      com_api_type_pkg.t_cmid
) return num_tab_tpt
is
    t_card_uid num_tab_tpt;
begin
    select to_number(ici.card_uid) bulk collect into t_card_uid
      from iss_card ica
         , iss_card_instance ici
         , prd_customer pct
     where 1 = 1
       and ica.id               = ici.card_id
       and ica.customer_id      = pct.id
       and pct.customer_number  = i_customer_num;

    return t_card_uid;
exception
    when others then
        return null;
end get_card_uid;

procedure temp_block_cus_cards(
    i_cus_number            in      com_api_type_pkg.t_cmid
) is
    l_params                com_api_type_pkg.t_param_tab;
begin
    for p in (
        select distinct ici.id as card_instance_id
          from iss_card ica
             , iss_card_instance ici
             , prd_customer pct
         where 1 = 1
           and ica.id               = ici.card_id
           and ica.customer_id      = pct.id
           and ici.state            = iss_api_const_pkg.CARD_STATE_ACTIVE       --'CSTE0200'
           and ici.status           = iss_api_const_pkg.CARD_STATUS_VALID_CARD  --'CSTS0000'
           and pct.customer_number  = i_cus_number
    )
    loop
        evt_api_status_pkg.change_status(
            i_event_type   => cst_woo_const_pkg.EVENT_TYPE_CARD_TEMP_BLOCK      --'EVNT0166'
          , i_initiator    => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id    => p.card_instance_id
          , i_reason       => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
          , i_params       => l_params
        );
    end loop;

exception
    when no_data_found then
        trc_log_pkg.debug (
            i_text         =>  'Not found card_instance_id for i_cus_number = ' ||
                               i_cus_number || ' In procedure temp_block_cus_cards'
        );
end temp_block_cus_cards;

procedure permanent_block_cus_cards(
    i_cus_number            in      com_api_type_pkg.t_cmid
) is
    l_params                com_api_type_pkg.t_param_tab;
begin
    for p in (
        select distinct ici.id as card_instance_id
          from iss_card ica
             , iss_card_instance ici
             , prd_customer pct
         where 1 = 1
           and ica.id               = ici.card_id
           and ica.customer_id      = pct.id
           and ici.state            = iss_api_const_pkg.CARD_STATE_ACTIVE       --'CSTE0200'
           and ici.status           = iss_api_const_pkg.CARD_STATUS_VALID_CARD  --'CSTS0000'
           and pct.customer_number  = i_cus_number
    )
    loop
        evt_api_status_pkg.change_status(
            i_event_type   => cst_woo_const_pkg.EVENT_TYPE_CARD_PERM_BLOCK      --'EVNT0167'
          , i_initiator    => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id    => p.card_instance_id
          , i_reason       => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
          , i_params       => l_params
        );
    end loop;

exception
    when no_data_found then
        trc_log_pkg.debug (
            i_text         =>  'Not found card_instance_id for i_cus_number = ' ||
                               i_cus_number || ' In procedure permanent_block_cus_cards'
        );
end permanent_block_cus_cards;

function get_latest_crd_limit_dt(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_obj_entity            in      com_api_type_pkg.t_name
) return date
is
    l_eff_date              date;
begin
    if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select max(oper_date) into l_eff_date
          from opr_operation         opr
             , opr_participant       opp
         where opr.id                = opp.oper_id
           and opr.oper_type         = cst_woo_const_pkg.OPER_TYPE_CREDIT_LIMIT_CHANGE --'OPTP7031'
           and opr.status            = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
           and opp.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER
         --and opp.client_id_type    = 'CITPACCT'
         --and opp.client_id_value   = i_obj_entity
           and opp.account_id        = i_obj_entity;
    end if;

    return l_eff_date;
end get_latest_crd_limit_dt;

function calculate_interest(
    i_account_id            in      com_api_type_pkg.t_long_id
  , i_debt_id               in      com_api_type_pkg.t_long_id      default null
  , i_eff_date              in      date
  , i_period_date           in      date                            default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id
  , i_product_id            in      com_api_type_pkg.t_short_id
  , i_alg_calc_intr         in      com_api_type_pkg.t_dict_value   default crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
) return com_api_type_pkg.t_money
is
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_interest_amount           com_api_type_pkg.t_money;
    l_eff_date                  date;
    l_interest_sum              com_api_type_pkg.t_money    := 0;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_from_id                   com_api_type_pkg.t_long_id;
    l_till_id                   com_api_type_pkg.t_long_id;
    l_interest_calc_start_date  com_api_type_pkg.t_dict_value;
    l_interest_start_date_trnsf com_api_type_pkg.t_dict_value;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    t_tmp number := 0;
    l_calc_interest_end_attr    com_api_type_pkg.t_dict_value;

    l_calc_interest_date_end    date;
    l_calc_due_date             date;
begin
    trc_log_pkg.debug(
        i_text      => 'charge_interest: i_account_id ['||i_account_id||
                       '] i_eff_date ['||to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss')||
                       '] i_period_date ['||to_char(i_period_date, 'dd.mm.yyyy hh24:mi:ss')||']'
    );

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => i_account_id
                        );
    else
        l_split_hash := i_split_hash;
    end if;

    begin
        select inst_id
          into l_inst_id
          from acc_account
         where id = i_account_id;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ACCOUNT_NOT_FOUND'
              , i_env_param1    => i_account_id
           );
    end;

    if i_eff_date is null then
        l_eff_date := com_api_sttl_day_pkg.get_sysdate;
    else
        l_eff_date := i_eff_date;
    end if;

    -- Get calc interest end date ICED
    begin
        l_calc_interest_end_attr :=
            nvl(
                prd_api_product_pkg.get_attr_value_char(
                    i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => i_account_id
                  , i_attr_name     => crd_api_const_pkg.INTEREST_CALC_END_DATE
                  , i_eff_date      => l_eff_date
                )
              , crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
            );
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then
                trc_log_pkg.debug('Attribute value [CRD_INTEREST_CALC_END_DATE] not defined. Set default algorithm = ICEDBLNC');
                l_calc_interest_end_attr := crd_api_const_pkg.INTER_CALC_END_DATE_BLNC;
            else
                raise;
            end if;
    end;

    -- Get Due Date
    l_calc_due_date :=
        crd_invoice_pkg.calc_next_invoice_due_date(
            i_service_id => i_service_id
          , i_account_id => i_account_id
          , i_split_hash => l_split_hash
          , i_inst_id    => l_inst_id
          , i_eff_date   => l_eff_date
          , i_mask_error => case l_calc_interest_end_attr
                                when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                                    then com_api_const_pkg.FALSE
                                when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                                    then com_api_const_pkg.TRUE
                                else com_api_const_pkg.FALSE
                            end
        );

    for p in (
        select d.id debt_id
             , c.account_type
             , c.currency
             , c.account_number
             , c.inst_id
          from crd_debt d
             , acc_account c
         where decode(d.status
                    , crd_api_const_pkg.DEBT_STATUS_ACTIVE, d.account_id ----'DBTSACTV'
                    , null)     = i_account_id
           and d.id             = coalesce(i_debt_id, d.id)
           and d.account_id     = c.id
           and d.split_hash     = l_split_hash
           and crd_cst_interest_pkg.charge_interest_needed(
                    i_debt_id   => d.id
               ) = com_api_const_pkg.TRUE
    )loop
        --l_currency := p.currency;
        --l_account_number := p.account_number;
        l_from_id := com_api_id_pkg.get_from_id_num(p.debt_id);
        l_till_id := com_api_id_pkg.get_till_id_num(p.debt_id);

        for r in (
            select x.balance_type
                 , x.fee_id
                 , x.add_fee_id
                 , x.amount
                 , x.start_date
                 , x.end_date
                 , b.bunch_type_id
                 , x.id
                 , x.macros_type_id
                 , x.interest_amount
                 , x.debt_intr_id
                 , x.due_date
              from (
                    select a.id debt_intr_id
                         , a.balance_type
                         , a.fee_id
                         , a.add_fee_id
                         , a.amount
                         , a.balance_date start_date
                         , nvl(lead(a.balance_date) over (partition by a.balance_type order by a.id), l_eff_date) end_date
                         , a.debt_id
                         , a.id
                         , d.inst_id
                         , d.macros_type_id
                         , a.interest_amount
                         , a.is_charged
                         , i.due_date
                      from crd_debt_interest a
                         , crd_debt d
                         , crd_invoice i
                     where a.debt_id         = p.debt_id
                       and d.is_grace_enable = com_api_const_pkg.FALSE
                       and d.id              = a.debt_id
                       and a.split_hash      = l_split_hash
                       --and a.is_charged      = com_api_const_pkg.FALSE
                       and a.id between l_from_id and l_till_id
                       and a.invoice_id      = i.id(+)
                  ) x
                 , crd_event_bunch_type b
             where x.end_date        <= l_eff_date
               and b.event_type(+)    = crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
               and x.is_charged       = com_api_const_pkg.FALSE
               and b.balance_type(+)  = x.balance_type
               and b.inst_id(+)       = x.inst_id
             order by bunch_type_id nulls first
        ) loop
            l_calc_interest_date_end :=
                case l_calc_interest_end_attr
                    when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                        then r.end_date
                    when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                        then nvl(r.due_date, l_calc_due_date)
                    else r.end_date
                end;
            -- only for migration purposes - interest amount could be sent in migration data
            -- so we do not need to recalculate it
            if nvl(r.interest_amount, 0) = 0 then
                -- Calculate interest amount. Base algorithm
                if i_alg_calc_intr in (
                       crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD 
                     , crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                   )
                then
                    l_interest_amount := round(
                        fcl_api_fee_pkg.get_fee_amount(
                            i_fee_id            => r.fee_id
                          , i_base_amount       => r.amount
                          , io_base_currency    => p.currency
                          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id         => i_account_id
                          , i_split_hash        => i_split_hash
                          , i_eff_date          => r.start_date
                          , i_start_date        => r.start_date
                          , i_end_date          => l_calc_interest_date_end
                        )
                      , case i_alg_calc_intr
                            when crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
                                then 4
                            when crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                                then 0
                        end
                    );

                    if r.add_fee_id is not null then
                        -- Calculate additional interest amount
                        l_interest_amount := l_interest_amount + round(
                            fcl_api_fee_pkg.get_fee_amount(
                                i_fee_id            => r.add_fee_id
                              , i_base_amount       => r.amount
                              , io_base_currency    => p.currency
                              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id         => i_account_id
                              , i_split_hash        => i_split_hash
                              , i_eff_date          => r.start_date
                              , i_start_date        => r.start_date
                              , i_end_date          => l_calc_interest_date_end
                            )
                          , case i_alg_calc_intr
                                when crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
                                    then 4
                                when crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                                    then 0
                            end
                        );
                    end if;
                -- Custom algorithm
                else
                    l_interest_amount :=  round(
                        crd_cst_interest_pkg.get_fee_amount(
                            i_fee_id            => r.fee_id
                          , i_base_amount       => r.amount
                          , io_base_currency    => p.currency
                          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id         => i_account_id
                          , i_split_hash        => i_split_hash
                          , i_eff_date          => r.start_date
                          , i_start_date        => r.start_date
                          , i_end_date          => l_calc_interest_date_end
                          , i_alg_calc_intr     => i_alg_calc_intr
                          , i_debt_id           => p.debt_id
                          , i_balance_type      => r.balance_type
                          , i_debt_intr_id      => r.debt_intr_id
                          , i_service_id        => i_service_id
                          , i_product_id        => i_product_id
                        )
                        , 4
                    );
                    -- Calculate additional interest amount
                    l_interest_amount := l_interest_amount + round(
                        crd_cst_interest_pkg.get_fee_amount(
                            i_fee_id            => r.add_fee_id
                          , i_base_amount       => r.amount
                          , io_base_currency    => p.currency
                          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id         => i_account_id
                          , i_split_hash        => i_split_hash
                          , i_eff_date          => r.start_date
                          , i_start_date        => r.start_date
                          , i_end_date          => l_calc_interest_date_end
                          , i_alg_calc_intr     => i_alg_calc_intr
                          , i_debt_id           => p.debt_id
                          , i_balance_type      => r.balance_type
                          , i_debt_intr_id      => r.debt_intr_id
                          , i_service_id        => i_service_id
                          , i_product_id        => i_product_id
                        )
                        , 4
                    );

                end if;
            else
                l_interest_amount := r.interest_amount;
            end if;

            l_interest_sum := l_interest_sum + l_interest_amount;

            trc_log_pkg.debug(
                i_text      => 'Calulating interest amount base amount ['||r.amount||
                                '] Fee Id ['||r.fee_id||'] Additional fee Id ['||r.add_fee_id||
                                '] Interest amount ['||l_interest_amount||']'
        );
        end loop;
    end loop;

    return l_interest_sum;
end calculate_interest;

function get_total_interest(
    i_account_id            in      com_api_type_pkg.t_long_id
  , i_debt_id               in      com_api_type_pkg.t_long_id      default null
  , i_eff_date              in      date
) return com_api_type_pkg.t_money
is
    l_service_id            com_api_type_pkg.t_short_id;
    l_product_id            com_api_type_pkg.t_short_id;
    l_total_interest        com_api_type_pkg.t_money := 0;
begin
    select pct.product_id
         , pso.service_id
      into
           l_product_id
         , l_service_id
      from prd_contract        pct
         , prd_service_object  pso
         , prd_service         ps
     where pct.id              = pso.contract_id
       and pso.service_id      = ps.id
       and pso.object_id       = i_account_id
       and ps.service_type_id  = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID --10000403
    ;

    l_total_interest := calculate_interest(
                            i_account_id   => i_account_id
                          , i_debt_id      => i_debt_id
                          , i_eff_date     => i_eff_date
                          , i_service_id   => l_service_id
                          , i_product_id   => l_product_id
                        );

    return l_total_interest;
end get_total_interest;

function get_charged_interest(
    i_account_id            in      com_api_type_pkg.t_long_id      default null
  , i_debt_id               in      com_api_type_pkg.t_long_id      default null
  , i_date                  in      date                            default null
) return com_api_type_pkg.t_money
is
    l_charged_interest      com_api_type_pkg.t_money := 0;
begin
    if i_debt_id is not null then
        select sum(amount)
          into l_charged_interest
          from crd_debt_interest
         where id in ((select max(id)
                       from crd_debt_interest
                      where debt_id      = i_debt_id
                        and balance_type = crd_api_const_pkg.BALANCE_TYPE_INTEREST --'BLTP1003'
                        and trunc(balance_date) = trunc(nvl(i_date, get_sysdate))
                      ),
                      (select max(id)
                       from crd_debt_interest
                      where debt_id      = i_debt_id
                        and balance_type = crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST --'BLTP1005'
                        and trunc(balance_date) = trunc(nvl(i_date, get_sysdate))
                      ));

    elsif i_account_id is not null then
        select sum(ci.amount)
          into l_charged_interest
          from crd_debt_interest    ci
             , crd_debt             cd
         where cd.id                = ci.debt_id
           and cd.account_id        = i_account_id
           and ci.id in (
                            (select max(id)
                               from crd_debt_interest
                              where debt_id      = i_debt_id
                                and balance_type = crd_api_const_pkg.BALANCE_TYPE_INTEREST --'BLTP1003'
                                and trunc(balance_date) = trunc(nvl(i_date, get_sysdate))
                              ),
                            (select max(id)
                               from crd_debt_interest
                              where debt_id      = i_debt_id
                                and balance_type = crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST --'BLTP1005'
                                and trunc(balance_date) = trunc(nvl(i_date, get_sysdate))
                              )
                          );
    end if;
    return l_charged_interest;
exception
    when others then
        null;
end;

function get_total_payment(
    i_account_id            in      com_api_type_pkg.t_long_id
  , i_bill_date             in      date
  , i_spent                 in      com_api_type_pkg.t_boolean default 1
) return com_api_type_pkg.t_money
is
    l_payment_amt           com_api_type_pkg.t_money;
begin
    select nvl(sum(amount), 0)
            into l_payment_amt
      from crd_payment
     where account_id       = i_account_id
       and is_reversal      = com_api_const_pkg.FALSE
       and posting_date between i_bill_date and add_months(i_bill_date, 1)
       and decode(i_spent
                  , 1, crd_api_const_pkg.PAYMENT_STATUS_SPENT --'PMTSSPNT'
                  , crd_api_const_pkg.PAYMENT_STATUS_ACTIVE --'PMTSACTV'
                  ) = status;

    return l_payment_amt;
end get_total_payment;

function get_debt_payment(
    i_debt_id               in com_api_type_pkg.t_long_id
  , i_eff_date              in date                             default null
  , i_balance_type          in com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_money
is
    l_payment_amt           com_api_type_pkg.t_money;
begin
    select sum(pay_amount)
      into l_payment_amt
      from crd_debt_payment
     where debt_id = i_debt_id
       and nvl(i_eff_date, eff_date)        >= eff_date
       and nvl(i_balance_type, balance_type) =  balance_type;

    return l_payment_amt;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text  => 'No_data_found in cst_woo_com_pkg.get_debt_payment, i_debt_id = [#1], i_balance_type = [#2], i_eff_date = [#3]'
          , i_env_param1 => i_debt_id
          , i_env_param2 => i_balance_type
          , i_env_param3 => to_date(i_eff_date, 'dd.mm.yyyy hh24:mi:ss')
        );
        return 0;
end get_debt_payment;

function get_mad_tad_payment(
    i_invoice_id            in  com_api_type_pkg.t_long_id
  , i_is_tad                in  com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_money
is
    l_tad_payment_amt           com_api_type_pkg.t_money;
    l_mad_payment_amt           com_api_type_pkg.t_money;
begin

    select nvl(sum(d.pay_amount), 0)
         , nvl(sum(d.pay_mandatory_amount), 0)
      into l_tad_payment_amt
         , l_mad_payment_amt
      from crd_debt_payment d
         , crd_payment p
         , opr_operation o
     where d.pay_id = p.id
       and p.oper_id = o.id
       and p.is_reversal = com_api_type_pkg.FALSE
       and o.oper_type != dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501' --Exclude DPP register operations
       and not exists (
                        select 1
                          from opr_operation
                         where original_id = o.id
                           and is_reversal = com_api_type_pkg.TRUE
                      )
       and not exists (
                        select 1
                          from dpp_payment_plan
                         where oper_id = o.id
                      )
       and exists (
                    select 1
                      from crd_invoice_debt
                     where debt_id = d.debt_id
                       and invoice_id = i_invoice_id
                  );

    if i_is_tad = com_api_type_pkg.TRUE then
        return l_tad_payment_amt;
    else
        return l_mad_payment_amt;
    end if;

end get_mad_tad_payment;

function get_debt_payment_date(
    i_debt_id               in com_api_type_pkg.t_long_id
  , i_balance_type          in com_api_type_pkg.t_dict_value    default null
) return date
is
    l_eff_date              date;
begin
    select min(eff_date)
      into l_eff_date
      from crd_debt_payment
     where debt_id                          = i_debt_id
       and nvl(i_balance_type, balance_type)=  balance_type;

    return l_eff_date;
end get_debt_payment_date;

procedure get_batch_time(
    i_file_id               in      com_api_type_pkg.t_short_id
  , o_from_date                 out date
  , o_to_date                   out date
) is
begin
    select from_date
         , to_date
      into o_from_date
         , o_to_date
      from cst_woo_batch_time
     where file_id = i_file_id;
exception
    when no_data_found then
        null;
end get_batch_time;

function get_substr(
    i_string                in      com_api_type_pkg.t_text
  , i_position              in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_text
is
  l_subtr                   com_api_type_pkg.t_text    := null;
  l_delimiter               com_api_type_pkg.t_tag     := '|';
  l_deli_count              com_api_type_pkg.t_tiny_id := 0;
begin
    select length(i_string) - length(replace(i_string, l_delimiter, null))
      into l_deli_count
      from dual;

    case
      when i_position = 1 then
        select substr(i_string, 1, instr(i_string, l_delimiter, 1, 1) - 1)
          into l_subtr
          from dual;
      when i_position = l_deli_count + 1 then
        select substr(i_string, instr(i_string, l_delimiter, 1, i_position - 1) + 1
                     , length(i_string) - instr(i_string, l_delimiter, 1, i_position - 1))
          into l_subtr
          from dual;
      when (i_position > 1 and i_position <= l_deli_count + 1) then
        select substr(i_string, instr(i_string, l_delimiter, 1, i_position - 1) + 1
                     , instr(i_string, l_delimiter, 1, i_position)
                        - instr(i_string, l_delimiter, 1, i_position - 1) - 1)
          into l_subtr
          from dual;
      else
        l_subtr := null;
    end case;

    return l_subtr;
exception
    when others then
        null;
end get_substr;

function get_limit_sum_withdraw(
    i_object_id             in      com_api_type_pkg.t_long_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money
is
    l_debt_sum              com_api_type_pkg.t_money;
    l_auth_sum              com_api_type_pkg.t_money;
    l_result                com_api_type_pkg.t_money;
begin
    select nvl(sum(b.amount), 0)
      into l_debt_sum
      from crd_debt d
         , crd_debt_balance b
     where b.debt_id        = d.id
       and b.split_hash     = d.split_hash
       and b.split_hash     = i_split_hash
       and b.balance_type   in (
             acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT
           , acc_api_const_pkg.BALANCE_TYPE_OVERDUE
           , acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT
           )
       and d.oper_type      in (
             opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
           , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
           , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
           , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT
           )
       and decode(d.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, d.account_id, null) = i_object_id;

    select nvl(sum(end_sum), 0)
      into l_auth_sum
      from (
        select x.id
             , x.host_date
             , x.account_id
             , x.oper_amount - (b.balance - nvl(sum(e.amount * e.balance_impact), 0)) end_sum
            from acc_entry e
               , acc_balance b
               , (select o.oper_amount
                       , o.host_date
                       , o.oper_date
                       , p.account_id
                       , p.split_hash
                       , o.id
                    from opr_operation o
                       , aut_auth a
                       , opr_participant p
                   where decode(o.status, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, o.id, null) = a.id
                     and o.oper_type in (
                            opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                          , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                          , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                          , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT
                          )
                     and p.oper_id = o.id
                     and p.account_id = i_object_id
                     and p.split_hash = i_split_hash
              ) x
           where x.account_id   = e.account_id
             and x.split_hash   = e.split_hash
             and e.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
             and x.account_id   = b.account_id
             and b.balance_type = e.balance_type
             and x.split_hash   = b.split_hash
             and e.posting_date >= x.host_date
             and e.id(+)        >= com_api_id_pkg.get_from_id(x.host_date)
          group by x.host_date
             , x.account_id
             , x.oper_amount
             , b.balance
             , x.id
         order by x.id
       );

    l_result := l_debt_sum + l_auth_sum;
    return l_result;
end get_limit_sum_withdraw;

function get_latest_payment_dt(
    i_account_id            in      com_api_type_pkg.t_long_id
) return date
is
    l_post_dt   date;
begin
    select max(posting_date)
      into l_post_dt
      from crd_payment
     where account_id   = i_account_id
       and is_reversal  = 0;

    return l_post_dt;
end get_latest_payment_dt;

procedure set_batch_time (
    i_file_id               in      com_api_type_pkg.t_name
  , i_status                in      com_api_type_pkg.t_sign     default null
) is
    l_new_from_date         date;
    l_new_to_date           date;
    l_old_from_date         date;
    l_old_to_date           date;
    l_last_run              date;
    l_next_sttl_date        date;
    l_run_type              com_api_type_pkg.t_tiny_id;
begin

if i_status is null then
    update cst_woo_batch_time
       set run_begin    = sysdate
     where file_id      = i_file_id;
else
    l_next_sttl_date := trunc(sysdate) + 1;

    select from_date, to_date, run_type
      into l_old_from_date, l_old_to_date, l_run_type
      from cst_woo_batch_time
     where file_id = i_file_id;

    case i_status
        when 0 then --Failed
            l_new_from_date := l_old_from_date;
        when 1 then --Succeeded
            l_new_from_date := l_old_to_date + com_api_const_pkg.ONE_SECOND;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'WRONG_ATTRIBUTE_VALUE'
            );
    end case;

    case l_run_type
        when 0 then     -- File is run every hours
            l_new_to_date := sysdate + 1/24;
        when 1 then     -- File is run every day
            l_new_to_date := l_next_sttl_date - trunc(sysdate) + sysdate;
        when 2 then     -- File is run at the first day of month
            l_new_to_date := last_day(sysdate) + 1;
    end case;

    update cst_woo_batch_time
       set from_date    = l_new_from_date
         , to_date      = l_new_to_date
         , run_status   = i_status
         , run_end      = sysdate
     where file_id      = i_file_id;
end if;
exception
    when others then
        trc_log_pkg.debug(
            i_text       => 'Exception in cst_woo_com_pkg.set_batch_time: sqlerrm [#1]'
          , i_env_param1 => sqlerrm
        );
        raise;
end set_batch_time;

function get_fee_rate(
    i_fee_id                in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_rate
is
    l_rate                  com_api_type_pkg.t_rate;
begin
    --select percent_rate/100
    --  into l_rate
    --  from fcl_fee_tier
    -- where fee_id = i_fee_id;*/

    for rc in (
        select percent_rate/100 as rate
          from (
                select percent_rate
                     , count_lower
                     , nvl(sum_threshold, 0) sum_lower
                     , nvl(min(sum_threshold) over(order by sum_threshold range between 1 following and unbounded following) - 1, 999999999999999999.9999) sum_upper
                  from (
                        select percent_rate
                             , sum_threshold
                             , nvl(count_threshold, 0) count_lower
                             , nvl(min(count_threshold) over(order by count_threshold range between 1 following and unbounded following) - 1, 9999999999999999) count_upper
                          from fcl_fee_tier
                         where fee_id = i_fee_id
                       )
               )
         order by sum_lower, count_lower
    ) loop
        l_rate := rc.rate;
        exit;
    end loop;

    if l_rate is null then
        l_rate := 0;
    end if;

    return l_rate;
end get_fee_rate;

function get_cycle_date(
    i_cycle_type            in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id      default null
  , i_from_date             in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_to_date               in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) return date
is
    l_from_date             date;
    l_to_date               date;
begin
    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type   => i_cycle_type
      , i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , i_split_hash   => i_split_hash
      , i_add_counter  => com_api_type_pkg.FALSE
      , o_prev_date    => l_from_date
      , o_next_date    => l_to_date
    );

    if i_from_date = com_api_type_pkg.TRUE then
        return l_from_date;
    else
        return l_to_date;
    end if;
end;

function get_previous_mad_tad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id      default null
  , i_is_tad                in      com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_money
is
    l_mad        com_api_type_pkg.t_money;
    l_tad        com_api_type_pkg.t_money;
begin
    select min_amount_due
         , total_amount_due
      into l_mad
         , l_tad
      from (
            select min_amount_due
                 , total_amount_due
                 , row_number() over (order by serial_number desc) rn
              from crd_invoice
             where account_id = i_account_id
           )
     where rn = 2;

    if i_is_tad = com_api_type_pkg.TRUE then
        return nvl(l_tad, 0);
    else
        return nvl(l_mad, 0);
    end if;

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text  => 'No_data_found in cst_woo_com_pkg.get_previous_mad_tad, i_account_id = [#1], i_split_hash = [#2], i_is_tad = [#3] '
          , i_env_param1 => i_account_id
          , i_env_param2 => i_split_hash
          , i_env_param3 => i_is_tad
        );
        return 0;
end get_previous_mad_tad;

function get_previous_invoice(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_invoice_id            in      com_api_type_pkg.t_medium_id    default null
)  return com_api_type_pkg.t_medium_id
is
    l_invoice_id    com_api_type_pkg.t_medium_id;
begin
    select id
      into l_invoice_id
      from (
            select id
                 , row_number() over (order by serial_number desc) rn
              from crd_invoice
             where account_id               = i_account_id
               and nvl(i_invoice_id, id)    = id
           )
     where rn = 2;
    return l_invoice_id;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => 'No_data_found in cst_woo_com_pkg.get_previous_invoice, i_account_id = [#1], i_invoice_id = [#2]'
          , i_env_param1 => i_account_id
          , i_env_param2 => i_invoice_id
        );
        return 0;
end get_previous_invoice;

function get_element_id(
    i_element_name          in      com_api_type_pkg.t_name
  , i_appl_id               in      com_api_type_pkg.t_long_id
  , i_serial_number         in      com_api_type_pkg.t_tiny_id       default 1
  , i_language              in      com_api_type_pkg.t_dict_value    default com_api_const_pkg.LANGUAGE_ENGLISH
)return com_api_type_pkg.t_long_id
is
    l_app_data_id       com_api_type_pkg.t_long_id;
begin
    select a.id
      into l_app_data_id
      from app_data a
         , app_element_all_vw e
     where a.appl_id        = i_appl_id
       and e.id             = a.element_id
       and e.name           = i_element_name
       and a.serial_number  = i_serial_number
       and a.lang           = nvl(i_language, com_ui_user_env_pkg.get_user_lang);

       return l_app_data_id;
end get_element_id;

procedure reconcile_atm_trans(
    i_start_date            in      date
  , i_end_date              in      date
)is
    l_start_date date;
    l_end_date   date;
begin

    l_start_date := to_date(to_char(nvl(i_start_date, get_sysdate) - 1, 'dd/mm/yyyy')|| ' 18:00:00', 'dd/mm/yyyy HH24:MI:SS');
    l_end_date := to_date(to_char(nvl(i_end_date, get_sysdate), 'dd/mm/yyyy')|| ' 17:59:59', 'dd/mm/yyyy HH24:MI:SS');

    --Intial status to mark the records from CBS
    update cst_woo_import_f78 cbs
       set cbs.rcn_status = 1  -- initial status
     where to_date(cbs.approved_date, 'yyyymmdd') between l_start_date and l_end_date
       and cbs.rcn_status is null
       ;
    --Reconcile ATM transaction data between CBS and SV
    merge into cst_woo_import_f78 cbs
    using ( select opo.host_date
                 , opo.originator_refnum
                 , icn.card_number
                 , opo.is_reversal
                 , opo.oper_amount
                 , opo.terminal_number
                 , agt.agent_number
              from opr_operation           opo
                 , opr_participant         opp
                 , iss_card_instance       ici
                 , iss_card                ica
                 , iss_card_number         icn
                 , ost_agent               agt
                 , aut_auth                aut
                 , acc_account             aac
             where opo.id                  = opp.oper_id
               and opo.id                  = aut.id
               and ici.card_id             = ica.id
               and ica.card_hash           = opp.card_hash
               and icn.card_id             = ica.id
               and ici.agent_id            = agt.id
               and aac.id                  = opp.account_id
               and opo.oper_type           = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH   --'OPTP0001'
               and opo.terminal_type       = acq_api_const_pkg.TERMINAL_TYPE_ATM         --'TRMT0002'
               and opo.status_reason       = pmo_api_const_pkg.SUCCESSFUL_AUTHORIZATION  --'RESP0001'
               and opp.participant_type    = com_api_const_pkg.PARTICIPANT_ISSUER        --'PRTYISS'
               and opo.sttl_type           = opr_api_const_pkg.SETTLEMENT_USONUS         --'STTT0010'
               and aac.account_type        = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT       --'ACTP0130'
               and trunc(opo.host_date)    between l_start_date and l_end_date
               group by opo.host_date
                 , opo.originator_refnum
                 , icn.card_number
                 , opo.is_reversal
                 , opo.oper_amount
                 , opo.terminal_number
                 , agt.agent_number
          ) sv
       on (
            --to_date(cbs.approved_date||cbs.approved_time, 'yyyymmddhh24miss') = sv.host_date
            cbs.approved_date         = to_char(sv.host_date, 'yyyymmdd')
            and cbs.trans_num         = sv.originator_refnum
            and cbs.card_num          = sv.card_number
            and cbs.terminal_id       = sv.terminal_number
            and cbs.card_revenue_type = decode(sv.is_reversal, 0, '06', 1, '16')
            and cbs.import_date is not null
          )
     when matched then update
        set cbs.rcn_status = 3  -- transaction matched
          , cbs.sv_amount = sv.oper_amount
     when not matched then insert (
            cbs.seq_id
          , cbs.approved_date
          , cbs.trans_num
          , cbs.card_num
          , cbs.card_revenue_type
          , cbs.approved_amt
          , cbs.approved_time
          , cbs.terminal_id
          , cbs.terminal_agent_id
          , cbs.rcn_status
          ) values (
            '999999999'
          , to_char(sv.host_date, 'yyyymmdd')
          , sv.originator_refnum
          , sv.card_number
          , decode(sv.is_reversal, 0, '06', 1, '16')
          , sv.oper_amount
          , to_char(sv.host_date, 'hh24miss')
          , sv.terminal_number
          , sv.agent_number
          , 2
          );
     update cst_woo_import_f78 cbs
        set cbs.rcn_status   = 4  -- amount matched
          , cbs.sv_amount    = null
      where cbs.approved_amt = cbs.sv_amount
        and cbs.rcn_status   = 3
        ;
exception
when others then
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
end reconcile_atm_trans;

procedure update_file_header(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_raw_data              in      com_api_type_pkg.t_raw_data
)is
begin
    update prc_file_raw_data
       set raw_data = i_raw_data
     where session_file_id = i_sess_file_id
       and record_number = 1;
exception
when others then
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
end update_file_header;

function get_file_attribute_id(
    i_file_id               in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id
is
    l_attr_id               com_api_type_pkg.t_short_id;
begin
    select pfa.id
      into l_attr_id
      from prc_file_attribute   pfa
         , prc_container        pc
         , prc_file             pf
         , prc_process          pp
     where pfa.container_id     = pc.id
       and pfa.file_id          = pf.id
       and pf.process_id        = pp.id
       and pf.file_purpose      = prc_api_const_pkg.FILE_PURPOSE_OUT    --FLPSOUTG
       and pf.file_type         = opr_api_const_pkg.FILE_TYPE_UNLOADING --FLTP1710
       and pfa.name_format_id   = i_file_id
       ;
    return l_attr_id;
exception
when others then
    return null;
end get_file_attribute_id;

function get_interest_start_date(
     i_debt_id               in com_api_type_pkg.t_long_id
)return date
is
    l_start_date    date;
    l_amount        com_api_type_pkg.t_money;
begin

    --get the last day that interest is 0
    select max(balance_date)
      into l_start_date
      from crd_debt_interest
     where debt_id = i_debt_id
       and balance_type = crd_api_const_pkg.BALANCE_TYPE_INTEREST --'BLTP1003'
       and amount = 0
       ;

    if l_start_date is not null then
        --check if the next day has interest or not
        --if next day has interest means interest start date is next day
        begin
            select amount
              into l_amount
              from crd_debt_interest
             where debt_id = i_debt_id
               and balance_type = crd_api_const_pkg.BALANCE_TYPE_INTEREST --'BLTP1003'
               and trunc(balance_date) = trunc(l_start_date) + 1;
        exception
            when no_data_found then
                return l_start_date;
        end;

        return l_start_date + 1;
    end if;

    --remain this case, all interest amount > 0, means insterest start date is minunum of balance date
    if l_start_date is null then
        select min(balance_date)
          into l_start_date
          from crd_debt_interest
         where debt_id = i_debt_id
           and balance_type = crd_api_const_pkg.BALANCE_TYPE_INTEREST --'BLTP1003'
           ;
        return l_start_date;
    end if;

end get_interest_start_date;

function get_card_expire_period(
    i_account_number        in      com_api_type_pkg.t_account_number
)return com_api_type_pkg.t_tag
is
    l_expire_date     date;
begin
    select max(i.expir_date)
      into l_expire_date
      from iss_card_instance    i
         , acc_account          a
         , acc_account_object   o
     where 1 = 1
       and i.card_id            = o.object_id
       and a.id                 = o.account_id
       and o.entity_type        = 'ENTTCARD'
       and a.account_number     = i_account_number
       ;

    case
        when sysdate <= l_expire_date
            then return '107';
        when sysdate > l_expire_date and extract(year from sysdate) = extract(year from l_expire_date)
            then return '108';
        when sysdate > l_expire_date and extract(year from sysdate) > extract(year from l_expire_date)
            then return '109';
        else    return null;
    end case;
end;

function get_agent_number(
    i_customer_id           in      com_api_type_pkg.t_medium_id
)return com_api_type_pkg.t_name
is
    l_agent_number         com_api_type_pkg.t_name;
begin
    select agent_number
      into l_agent_number
      from prd_customer c
         , prd_contract d
         , ost_agent    a
     where c.id     = i_customer_id
       and d.id     = c.contract_id
       and a.id     = d.agent_id
       and rownum   = 1;

    return l_agent_number;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => 'No_data_found in cst_woo_com_pkg.get_agent_number, i_customer_id = [#1]'
          , i_env_param1 => i_customer_id
        );
        return null;
end get_agent_number;

function get_customer_address(
    i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_language              in      com_api_type_pkg.t_dict_value    default null
)return com_api_type_pkg.t_full_desc
is
    l_address            com_api_type_pkg.t_full_desc;
begin

    with address_order as
    (
        select 1 ord , com_api_const_pkg.ADDRESS_TYPE_HOME address_type from dual
        union all
        select 2, com_api_const_pkg.ADDRESS_TYPE_BUSINESS  from dual
    )
    select com_api_address_pkg.get_address_string(
                   i_address_id => tmp.addr_id
           )
      into l_address
      from (
            select distinct first_value(cao.address_id)
                            over (order by o.ord)  addr_id
              from com_address_object   cao
                 , com_address          ca
                 , address_order        o
             where 1=1
               and cao.object_id    = i_customer_id
               and cao.entity_type  = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
               and cao.address_id   = ca.id
               and cao.address_type = o.address_type(+)
             )tmp;
     return l_address;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => 'No_data_found in cst_woo_com_pkg.get_customer_address, i_customer_id = [#1]'
          , i_env_param1 => i_customer_id
        );
        return null;
end get_customer_address;

procedure reconcile_offline_fees(
    i_file_name     in      com_api_type_pkg.t_name
)is
begin
    if i_file_name is null then
        com_api_error_pkg.raise_error(
            i_error      => 'PARAM_VALUE_IS_NULL'
        );
    else
        merge into cst_woo_import_f138 sv
            using (  select cif_num
                            , branch_code
                            , wdr_acct_num
                            , dep_amount
                            , brief_content
                       from cst_woo_import_f138
                      where err_code = '00000000'
                        and file_name = i_file_name
                  ) cbs
               on (     sv.cif_num          = cbs.cif_num
                    and sv.branch_code      = cbs.branch_code
                    and sv.wdr_acct_num     = cbs.wdr_acct_num
                    and sv.dep_amount       = cbs.dep_amount
                    and substr(sv.brief_content, instr(sv.brief_content, ':') + 1, 16) =
                        substr(cbs.brief_content, instr(cbs.brief_content, ':') + 1, 16)
                    and sv.err_code <> '00000000'
                    and trunc(sv.import_date) > trunc(sysdate) - 30
                    and sv.file_name <> i_file_name
                  )
            when matched then update
                set sv.rcn_status = 1;  -- Received successful response from CBS

        --If failed records are still not received successful response from CBS then update status to 0
        update cst_woo_import_f138
           set rcn_status = 0
         where rcn_status is null
           and err_code <> '00000000';

    end if;
end reconcile_offline_fees;

procedure start_batch_process (
    i_file_id       in     com_api_type_pkg.t_short_id
  , i_start_date    in out date
  , o_from_date        out date
) is

begin
    i_start_date := nvl(i_start_date, get_sysdate);
    begin
        select decode(nvl(run_status, cst_woo_const_pkg.RUN_STATUS_FAIL),
                      cst_woo_const_pkg.RUN_STATUS_FAIL,
                      nvl(from_date, i_start_date - 1),
                      nvl(to_date + com_api_const_pkg.ONE_SECOND, i_start_date - 1))
          into o_from_date
          from cst_woo_batch_time
         where file_id = i_file_id;

        update cst_woo_batch_time
           set run_begin = i_start_date,
               run_end = null,
               run_status = cst_woo_const_pkg.RUN_STATUS_FAIL,
               from_date = o_from_date,
               to_date = i_start_date - com_api_const_pkg.ONE_SECOND
         where file_id = i_file_id;

    exception when no_data_found then
        o_from_date := i_start_date - 1;
        insert into cst_woo_batch_time(
            file_id,
            from_date,
            to_date,
            run_type,
            run_status,
            run_begin,
            run_end
        )
        values(
            i_file_id,
            o_from_date,
            i_start_date - com_api_const_pkg.ONE_SECOND,
            null,
            cst_woo_const_pkg.RUN_STATUS_FAIL,
            i_start_date,
            null
        );
    end;

end start_batch_process;

procedure stop_batch_process (
    i_file_id       in     com_api_type_pkg.t_short_id
  , i_stop_date     in     date
  , i_status        in     com_api_type_pkg.t_boolean
) is
    l_stop_date    date := nvl(i_stop_date, get_sysdate);
begin
    update cst_woo_batch_time
       set run_end = l_stop_date,
           run_status = i_status
     where file_id = i_file_id;
end stop_batch_process;

function get_invoice_project_interest(
    i_invoice_id    in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_money
is
    l_account_id              com_api_type_pkg.t_account_id;
    l_invoice_date            date;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_interest_amount         com_api_type_pkg.t_money := 0;
    l_account_number          com_api_type_pkg.t_account_number;
    l_overdue_balance         com_api_type_pkg.t_money := 0;
    l_overdue_intr_balance    com_api_type_pkg.t_money := 0;
    l_overdraft_balance       com_api_type_pkg.t_money := 0;
    l_expense_amount          com_api_type_pkg.t_money := 0;
    l_due_date                date;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_invoice_id              com_api_type_pkg.t_medium_id;
    l_till_id                 com_api_type_pkg.t_long_id;
    l_proj_intr_overdue       com_api_type_pkg.t_money := 0;
    l_proj_intr_last_month    com_api_type_pkg.t_money := 0;
    l_proj_intr_current       com_api_type_pkg.t_money := 0;
    l_prev_invoice            crd_api_type_pkg.t_invoice_rec;
    l_overdraft_last_month    com_api_type_pkg.t_money := 0;
    l_fee_interest_last_month com_api_type_pkg.t_money := 0;
    l_remaining_last_month    com_api_type_pkg.t_money := 0;
    l_advance_payment         com_api_type_pkg.t_money := 0;
    l_total_payment           com_api_type_pkg.t_money := 0;
begin
    l_invoice_id    := i_invoice_id;

    -- Get invoice and account information
    begin
        select i.account_id
             , i.invoice_date
             , a.inst_id
             , nvl(i.interest_amount, 0)
             , a.account_number
             , nvl(i.overdue_balance, 0)
             , nvl(i.overdue_intr_balance, 0)
             , nvl(i.overdraft_balance, 0)
             , nvl(i.expense_amount, 0)
             , i.due_date
             , a.split_hash
          into l_account_id
             , l_invoice_date
             , l_inst_id
             , l_interest_amount
             , l_account_number
             , l_overdue_balance
             , l_overdue_intr_balance
             , l_overdraft_balance
             , l_expense_amount
             , l_due_date
             , l_split_hash
          from crd_invoice i
             , acc_account a
         where a.id = i.account_id
           and i.id = l_invoice_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error       => 'INVOICE_NOT_FOUND'
              , i_env_param1  => l_invoice_id
            );
    end;

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
             , (
                select a.id
                     , lag(a.id) over (order by a.invoice_date, a.id) lag_id
                  from crd_invoice_vw a
                 where a.account_id = l_account_id
               ) i2
         where i1.id = i2.lag_id
           and i2.id = l_invoice_id;

        select nvl(overdraft_balance, 0)
             , nvl(fee_amount, 0) + nvl(interest_amount, 0)
          into l_overdraft_last_month
             , l_fee_interest_last_month
          from crd_invoice_vw
         where id = l_prev_invoice.id;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Previous invoice not found'
            );
            l_overdraft_last_month := 0;
            l_fee_interest_last_month := 0;
    end;

    -- Get total payments amount
    select nvl(sum(p.amount), 0)
      into l_total_payment
      from crd_invoice_payment i
         , crd_payment p
     where i.invoice_id = l_invoice_id
       and p.id = i.pay_id
       and i.split_hash = l_split_hash
       and p.split_hash = l_split_hash
       and not exists
           (select 1
              from opr_operation po
             where po.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
               and po.id = p.oper_id);

    -- Get advance payment:
    if l_overdue_balance + l_overdue_intr_balance > 0 then
        l_advance_payment := 0;
        l_remaining_last_month := nvl(l_prev_invoice.total_amount_due, 0) - l_overdue_balance - l_overdue_intr_balance;
    else
        l_advance_payment := greatest(l_total_payment - nvl(l_prev_invoice.total_amount_due, 0), 0);
        l_remaining_last_month := greatest(nvl(l_prev_invoice.total_amount_due, 0) - l_total_payment);
    end if;

    -- Calculate project interest (imaginary interest that can be charged for period from billing date up to due date):
    l_till_id := com_api_id_pkg.get_till_id(l_invoice_date);
    -- 1. Project interest for overdue:
    if l_overdue_balance = 0 then
        l_proj_intr_overdue := 0;
    else
        select nvl(
                   sum(cst_woo_stmt_api_report_pkg.get_project_interest(
                           i_debt_id           => d.id
                         , i_invoice_id        => l_invoice_id
                         , i_split_hash        => l_split_hash
                         , i_end_date          => l_due_date
                         , i_include_overdraft => com_api_type_pkg.FALSE
                         , i_include_overdue   => com_api_type_pkg.TRUE
                         , i_round             => 0
                       )
                   )
                   , 0
                   )
          into l_proj_intr_overdue
          from crd_debt d
         where d.account_id = l_account_id
           and d.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE
           and d.id < l_till_id
           and not exists (
                            select 1
                              from dpp_payment_plan dpp
                             where dpp.oper_id = d.oper_id
                               and dpp.status <> dpp_api_const_pkg.DPP_OPERATION_CANCELED -- 'DOST0300'
                          );
    end if;

    -- 2. Project interest for last month overdraft:
    if l_remaining_last_month = 0 then
        l_proj_intr_last_month := 0;
    else
        select nvl(
                   sum(cst_woo_stmt_api_report_pkg.get_project_interest(
                           i_debt_id           => d.id
                         , i_invoice_id        => l_invoice_id
                         , i_split_hash        => l_split_hash
                         , i_end_date          => l_due_date
                         , i_include_overdraft => com_api_type_pkg.TRUE
                         , i_include_overdue   => com_api_type_pkg.FALSE
                         , i_round             => 0
                       )
                   )
               , 0
               )
          into l_proj_intr_last_month
          from crd_debt d
         where d.account_id = l_account_id
           and d.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE
           --and d.aging_period = 0
           and d.id < l_till_id
           and d.id not in (
                            select cid.debt_id
                              from crd_invoice_debt cid
                             where cid.invoice_id = l_invoice_id
                               and cid.is_new = com_api_type_pkg.TRUE
                           )
           and not exists (
                            select 1
                              from dpp_payment_plan dpp
                             where dpp.oper_id = d.oper_id
                               and dpp.status <> dpp_api_const_pkg.DPP_OPERATION_CANCELED -- 'DOST0300'
                          );
    end if;

    -- 3. Project interest for current invoice:
    select nvl(
               sum(cst_woo_stmt_api_report_pkg.get_project_interest(
                       i_debt_id           => d.id
                     , i_invoice_id        => l_invoice_id
                     , i_split_hash        => l_split_hash
                     , i_end_date          => l_due_date
                     , i_include_overdraft => com_api_type_pkg.TRUE
                     , i_include_overdue   => com_api_type_pkg.FALSE
                     , i_round             => 0
                   )
               )
               , 0
           )
      into l_proj_intr_current
      from crd_debt d
     where d.account_id = l_account_id
       and d.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE
       and d.id < l_till_id
       and d.id in (
                    select cid.debt_id
                      from crd_invoice_debt cid
                     where cid.invoice_id = l_invoice_id
                       and cid.is_new = com_api_type_pkg.TRUE
                   )
       and not exists (
                        select 1
                          from dpp_payment_plan dpp
                         where dpp.oper_id = d.oper_id
                           and dpp.status <> dpp_api_const_pkg.DPP_OPERATION_CANCELED -- 'DOST0300'
                      );

    trc_log_pkg.debug (
        i_text       => 'Get projected interest of invoice [#1], l_proj_intr_overdue = [#2], l_proj_intr_last_month = [#3], l_proj_intr_current = [#4]'
      , i_env_param1 => i_invoice_id
      , i_env_param2 => l_proj_intr_overdue
      , i_env_param3 => l_proj_intr_last_month
      , i_env_param4 => l_proj_intr_current
    );

    return l_proj_intr_overdue + l_proj_intr_last_month + l_proj_intr_current;

end get_invoice_project_interest;

function get_customer_city_code(
    i_customer_id   in      com_api_type_pkg.t_medium_id
  , i_lang          in      com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_dict_value
is
    l_city_code_cbs         com_api_type_pkg.t_dict_value;
    l_city_code_cic         com_api_type_pkg.t_dict_value;
    l_lang                  com_api_type_pkg.t_dict_value;
begin

    l_lang := nvl(i_lang, com_api_const_pkg.LANGUAGE_ENGLISH);

    with address_order as
    (
        select 1 ord , com_api_const_pkg.ADDRESS_TYPE_HOME address_type from dual
        union all
        select 2, com_api_const_pkg.ADDRESS_TYPE_BUSINESS  from dual
    )

    select distinct first_value(ca.city) over (order by o.ord) as city_code_cbs
      into l_city_code_cbs
      from com_address_object cao
         , com_address ca
         , address_order o
     where cao.object_id = i_customer_id
       and cao.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
       and cao.address_id = ca.id
       and cao.address_type = o.address_type(+)
       and ca.lang = l_lang;

    select to_char(element_number, '09') as city_code_cic
      into l_city_code_cic
      from com_array_element
     where array_id = cst_woo_const_pkg.WOORI_CITY_CODE  -- -50000001
       and element_value = l_city_code_cbs;

     return l_city_code_cic;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text  => 'no_data_found in cst_woo_com_pkg.get_customer_city_code, i_customer_id = [#1], i_lang=[#2]'
          , i_env_param1 => i_customer_id
          , i_env_param2 => i_lang
        );
        return null;
end get_customer_city_code;

function get_interest_after_invoice(
    i_invoice_id  in com_api_type_pkg.t_medium_id
  , i_split_hash  in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money
is
    l_amount com_api_type_pkg.t_money;
begin
    select nvl(sum(round(cdi.interest_amount)), 0)
      into l_amount
      from crd_debt_interest cdi
         , crd_invoice i
     where cdi.debt_id in (
                           select cid.debt_id
                             from crd_invoice_debt cid
                            where cid.invoice_id = i_invoice_id
                              and cid.split_hash = i_split_hash
                          )
       and cdi.is_charged = com_api_type_pkg.TRUE
       and i.id = i_invoice_id
       and cdi.balance_date >= i.invoice_date
       and cdi.split_hash = i_split_hash;

    return l_amount;
end get_interest_after_invoice;

function get_daily_interest_by_debt(
    i_debt_id       in      com_api_type_pkg.t_medium_id
  , i_intr_type     in      com_api_type_pkg.t_tiny_id
  , i_info_type     in      com_api_type_pkg.t_tiny_id
  , i_end_date      in      date    default null
) return com_api_type_pkg.t_text
is
    l_debt_amount           com_api_type_pkg.t_money;
    l_interest_amount       com_api_type_pkg.t_money;
    l_intr_bal_amount       com_api_type_pkg.t_money;
    l_intr_start_date       date;
    l_intr_end_date         date;
    l_fee_id                com_api_type_pkg.t_long_id;
begin
    select distinct debt_amount
         , round(interest_amount)
         , intr_start_date
         , intr_end_date
         , intr_bal_amount
         , fee_id
      into l_debt_amount
         , l_interest_amount
         , l_intr_start_date
         , l_intr_end_date
         , l_intr_bal_amount
         , l_fee_id
      from (select dint.debt_id
                 , dint.balance_type
                 , dint.amount as debt_amount
                 , dint.interest_amount
                 , dint.fee_id
                 , dint.is_charged
                 , dint.split_hash
                 , d.account_id
                 , d.oper_id
                 , d.oper_type
                 , d.oper_date
                 , nvl(
                       (select max(eff_date) from crd_debt_payment where debt_id = i_debt_id and pay_amount > 0)
                     , first_value(dint.start_date) over (order by dint.start_date)
                   ) as intr_start_date
                 , first_value(dint.end_date) over (order by dint.end_date desc) as intr_end_date
                 , cdb.amount as intr_bal_amount
              from (select *
                      from (select debt_id
                                 , balance_type
                                 , balance_date start_date
                                 , lead(balance_date) over (partition by balance_type order by posting_order, balance_date, id) as end_date
                                 , amount
                                 , min_amount_due
                                 , interest_amount
                                 , fee_id
                                 , add_fee_id
                                 , is_charged
                                 , is_grace_enable
                                 , invoice_id
                                 , split_hash
                              from crd_debt_interest
                             where debt_id = i_debt_id)
                     where interest_amount > 0) dint
                 , crd_debt d
                 , crd_debt_balance cdb
             where 1 = 1
               and dint.debt_id = d.id
               and dint.debt_id = cdb.debt_id
               and cdb.amount > 0
               and cdb.balance_type = decode(i_intr_type
                                             , 1, crd_api_const_pkg.BALANCE_TYPE_INTEREST
                                             , 2, crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                                             )
          order by dint.start_date desc)
     where 1 = 1
       and trunc(nvl(i_end_date, get_sysdate)) between trunc(intr_start_date) and trunc(intr_end_date)
       and rownum = 1;

    case i_info_type
        when 1 then return to_char(l_intr_start_date, 'dd/mm/yyyy');
        when 2 then return to_char(l_intr_end_date, 'dd/mm/yyyy');
        when 3 then return l_debt_amount;
        when 4 then return round(l_interest_amount);
        when 5 then return l_intr_bal_amount;
        when 6 then return (l_intr_end_date - l_intr_start_date) * round(l_interest_amount);
        when 7 then return l_fee_id;
        else return null;
    end case;

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text  => 'No_data_found in cst_woo_com_pkg.get_daily_interest_by_debt, i_debt_id = [#1], i_intr_type = [#2], i_info_type = [#3], i_end_date = [#4]'
          , i_env_param1 => i_debt_id
          , i_env_param2 => i_intr_type
          , i_env_param3 => i_info_type
          , i_env_param4 => to_char(i_end_date, 'dd.mm.yyyy hh24.mi.ss')
        );
        return null;
end get_daily_interest_by_debt;

function get_dispute_amount(
    i_invoice_id            in  com_api_type_pkg.t_long_id
  , i_is_tad                in  com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_money
is
    l_tad_dispute_amt       com_api_type_pkg.t_money;
    l_mad_dispute_amt       com_api_type_pkg.t_money;
begin

   --Get dispute amount
    select nvl(sum(d.amount), 0)
      into l_tad_dispute_amt
      from crd_invoice_debt i
         , crd_debt d
     where i.debt_id = d.id
       and i.invoice_id = i_invoice_id
       and i.split_hash = d.split_hash
       and d.status = crd_api_const_pkg.DEBT_STATUS_SUSPENDED; -- 'DBTSSSPN'

    --MAD of dispute is 10% of TAD
    if l_tad_dispute_amt > 0 then
        l_mad_dispute_amt := l_tad_dispute_amt * 0.1;
    else
        l_mad_dispute_amt := 0;
    end if;

    if i_is_tad = com_api_type_pkg.TRUE then
        return l_tad_dispute_amt;
    else
        return l_mad_dispute_amt;
    end if;

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => 'No_data_found in cst_woo_com_pkg.get_dispute_amount, i_invoice_id = [#1], i_is_tad = [#2] '
          , i_env_param1 => i_invoice_id
          , i_env_param2 => i_is_tad
        );
        return 0;
end get_dispute_amount;

function get_prev_invoice(
    i_invoice_id    in      com_api_type_pkg.t_medium_id
) return crd_api_type_pkg.t_invoice_rec
is
    l_prev_invoice          crd_api_type_pkg.t_invoice_rec;
begin
-- Get previous invoice information
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
         , (
            select a.id
                 , lag(a.id) over (order by a.invoice_date, a.id) lag_id
              from crd_invoice_vw a
             where a.account_id = (select account_id from crd_invoice_vw where id = i_invoice_id)
           ) i2
     where i1.id = i2.lag_id
       and i2.id = i_invoice_id;

    return l_prev_invoice;
exception
    when no_data_found then
        trc_log_pkg.debug (
            i_text  => 'Previous invoice not found'
        );
        return null;
end get_prev_invoice;

function get_tad_by_invoice(
    i_invoice_id    in      com_api_type_pkg.t_medium_id
  , i_to_date       in      date    default null
) return com_api_type_pkg.t_money
is
    l_account_id            com_api_type_pkg.t_medium_id;
    l_total_amount_due      com_api_type_pkg.t_money;
    l_min_amount_due        com_api_type_pkg.t_money;
    l_invoice_date          date;
    l_grace_date            date;
    l_due_date              date;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_customer_type         com_api_type_pkg.t_dict_value;
    l_payment_amount        com_api_type_pkg.t_money := 0;
    l_overdue_amount        com_api_type_pkg.t_money := 0;
    l_dispute_amount        com_api_type_pkg.t_money := 0;
    l_sum_daily_interest    com_api_type_pkg.t_money := 0;
    l_prev_invoice          crd_api_type_pkg.t_invoice_rec;
    l_to_date               date;
begin

    l_to_date := nvl(i_to_date, get_sysdate);


    --get invoice information
    select account_id
         , total_amount_due
         , min_amount_due
         , invoice_date
         , due_date
         , grace_date
         , split_hash
      into l_account_id
         , l_total_amount_due
         , l_min_amount_due
         , l_invoice_date
         , l_due_date
         , l_grace_date
         , l_split_hash
      from crd_invoice
     where id = i_invoice_id
     ;

    --get customer type
    select p.entity_type
      into l_customer_type
      from acc_account a
         , prd_customer p
     where p.id = a.customer_id
       and a.id = l_account_id
       ;

    --get overdue amount of the account
    select nvl(sum(cdb.amount), 0)
      into l_overdue_amount
      from crd_debt cd
         , crd_debt_balance cdb
     where cd.id = cdb.debt_id
       and cd.account_id = l_account_id
       and cd.split_hash = cdb.split_hash
       and cd.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE     -- 'DBTSACTV'
       and cdb.balance_type in (acc_api_const_pkg.BALANCE_TYPE_OVERDUE             -- 'BLTP1004'
                                , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST  -- 'BLTP1005'
                                );

    --get payment amount after invoice date until current date
    select nvl(sum(dp.pay_amount), 0)
      into l_payment_amount
      from crd_debt d
         , crd_payment p
         , opr_operation o
         , crd_debt_payment dp
     where dp.pay_id  = p.id
       and dp.debt_id = d.id
       and p.oper_id  = o.id
       and d.split_hash = p.split_hash
       and d.split_hash = dp.split_hash
       and p.is_reversal = com_api_type_pkg.FALSE
       and o.oper_type != dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
       and d.account_id = l_account_id
       and o.oper_date  between l_invoice_date and l_to_date
       and not exists (
                        select 1
                          from opr_operation
                         where original_id = o.id
                           and is_reversal = com_api_type_pkg.TRUE
                      )
       and not exists (
                        select 1
                          from dpp_payment_plan
                         where oper_id = o.id
                      );

    --get dispute amount
    l_dispute_amount := get_dispute_amount(
                            i_invoice_id    => i_invoice_id
                          , i_is_tad        => com_api_type_pkg.TRUE
                        );



    --get sum of daily interest after invoice_date until current date
    select nvl(sum(intr.sum_intr_amount), 0)
      into l_sum_daily_interest
      from (select distinct debt_id
              from crd_invoice_debt
             where invoice_id = i_invoice_id
               and split_hash = l_split_hash
           ) inv_debt
         , (select sum(round(interest_amount)) as sum_intr_amount, debt_id
              from (
                    select balance_type as bal_type
                         , balance_date as start_date
                         --, lead(balance_date) over (partition by balance_type order by posting_order, balance_date, id) as end_date
                         , interest_amount as interest_amount
                         , invoice_id
                         , debt_id
                     from crd_debt_interest
                   )
             where interest_amount > 0
               and invoice_id is null
               and start_date between l_invoice_date and l_to_date
             group by debt_id
           ) intr
     where inv_debt.debt_id = intr.debt_id;



    trc_log_pkg.debug(
        i_text          => 'cst_woo_com_pkg.get_tad_by_invoice, l_customer_type = ' || l_customer_type
                    || ', l_overdue_amount = ' || l_overdue_amount
                    || ', l_payment_amount = ' || l_payment_amount
                    || ', l_dispute_amount = ' || l_dispute_amount
                    || ', l_total_amount_due = ' || l_total_amount_due
                    || ', l_sum_daily_interest = ' || l_sum_daily_interest
      , i_entity_type   => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
      , i_object_id     => i_invoice_id
    );

    if l_overdue_amount > 0 then

        l_prev_invoice := get_prev_invoice(i_invoice_id);

        case
            --Before due_date
            when l_to_date < l_due_date and l_payment_amount >= nvl(l_prev_invoice.min_amount_due, 0)
            then return 0;
            when l_to_date < l_due_date and l_payment_amount < nvl(l_prev_invoice.min_amount_due, 0)
            then return nvl(l_prev_invoice.min_amount_due, 0) + l_sum_daily_interest - l_payment_amount - l_dispute_amount;

            --Between due_date and grace_date
            when l_to_date between l_due_date and l_grace_date
            then return l_total_amount_due + l_sum_daily_interest - l_payment_amount - l_dispute_amount;

            --After grace_date
            --Individual customer, after 1st grace_date, TAD = MAD
            when l_to_date > l_grace_date and l_payment_amount >= l_min_amount_due
            then return 0;
            when l_to_date > l_grace_date and l_payment_amount < l_min_amount_due and l_customer_type = com_api_const_pkg.ENTITY_TYPE_PERSON -- 'ENTTPERS'
            then return l_total_amount_due + l_sum_daily_interest - l_payment_amount - l_dispute_amount;
            when l_to_date > l_grace_date and l_payment_amount < l_min_amount_due
            then return l_total_amount_due + l_sum_daily_interest - l_payment_amount - l_dispute_amount;

            else return 0;
        end case;
    end if;

    if l_overdue_amount = 0 then
        case
            --Before due_date
            when l_to_date < l_due_date
            then return 0;
            --Between due_date and grace_date
            when l_to_date between l_due_date and l_grace_date
            then return l_total_amount_due + l_sum_daily_interest - l_payment_amount - l_dispute_amount;

            --After grace_date
            when l_to_date > l_grace_date and l_payment_amount >= l_min_amount_due
            then return 0;
            when l_to_date > l_grace_date and l_payment_amount < l_min_amount_due
            then return l_total_amount_due + l_sum_daily_interest - l_payment_amount - l_dispute_amount;

            else return 0;
        end case;
    end if;

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => 'No_data_found in cst_woo_com_pkg.get_tad_by_invoice, i_invoice_id = [#1]'
          , i_env_param1 => i_invoice_id
        );
        return 0;
end get_tad_by_invoice;

function get_mad_by_invoice(
    i_invoice_id    in      com_api_type_pkg.t_medium_id
  , i_to_date       in      date    default null
) return com_api_type_pkg.t_money
is
    l_account_id            com_api_type_pkg.t_medium_id;
    l_total_amount_due      com_api_type_pkg.t_money;
    l_min_amount_due        com_api_type_pkg.t_money;
    l_invoice_date          date;
    l_grace_date            date;
    l_due_date              date;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_customer_type         com_api_type_pkg.t_dict_value;
    l_aging_period          com_api_type_pkg.t_tiny_id;
    l_payment_amount        com_api_type_pkg.t_money := 0;
    l_overdue_amount        com_api_type_pkg.t_money := 0;
    l_dispute_amount        com_api_type_pkg.t_money := 0;
    l_sum_daily_interest    com_api_type_pkg.t_money := 0;
    l_prev_invoice          crd_api_type_pkg.t_invoice_rec;
    l_to_date               date;
begin

    l_to_date := nvl(i_to_date, get_sysdate);

    --get invoice information
    select account_id
         , total_amount_due
         , min_amount_due
         , invoice_date
         , due_date
         , grace_date
         , aging_period
         , split_hash
      into l_account_id
         , l_total_amount_due
         , l_min_amount_due
         , l_invoice_date
         , l_due_date
         , l_grace_date
         , l_aging_period
         , l_split_hash
      from crd_invoice
     where id = i_invoice_id
     ;

    --get customer type
    select p.entity_type
      into l_customer_type
      from acc_account a
         , prd_customer p
     where p.id = a.customer_id
       and a.id = l_account_id
       ;

    --get overdue amount of the account
    select nvl(sum(cdb.amount), 0)
      into l_overdue_amount
      from crd_debt cd
         , crd_debt_balance cdb
     where cd.id = cdb.debt_id
       and cd.account_id = l_account_id
       and cd.split_hash = cdb.split_hash
       and cd.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE     -- 'DBTSACTV'
       and cdb.balance_type in (acc_api_const_pkg.BALANCE_TYPE_OVERDUE             -- 'BLTP1004'
                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST   -- 'BLTP1005'
                               );

    --get payment amount after invoice date until current date
    select nvl(sum(dp.pay_amount), 0)
      into l_payment_amount
      from crd_debt d
         , crd_payment p
         , opr_operation o
         , crd_debt_payment dp
     where dp.pay_id  = p.id
       and dp.debt_id = d.id
       and p.oper_id  = o.id
       and d.split_hash = p.split_hash
       and d.split_hash = dp.split_hash
       and p.is_reversal = com_api_type_pkg.FALSE
       and o.oper_type != dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
       and d.account_id = l_account_id
       and o.oper_date  between l_invoice_date and l_to_date
       and not exists (
                        select 1
                          from opr_operation
                         where original_id = o.id
                           and is_reversal = com_api_type_pkg.TRUE
                      )
       and not exists (
                        select 1
                          from dpp_payment_plan
                         where oper_id = o.id
                      );

    --get dispute amount
    l_dispute_amount := get_dispute_amount(
                            i_invoice_id    => i_invoice_id
                          , i_is_tad        => com_api_type_pkg.TRUE
                        );

    --For MAD, dispute amount is only 10%
    l_dispute_amount := l_dispute_amount * 0.1;

    --get sum of daily interest after invoice_date until current date
    select nvl(sum(intr.sum_intr_amount), 0)
      into l_sum_daily_interest
      from (select distinct debt_id
              from crd_invoice_debt
             where invoice_id = i_invoice_id
               and split_hash = l_split_hash
           ) inv_debt
         , (select sum(round(interest_amount)) as sum_intr_amount, debt_id
              from (
                    select balance_type as bal_type
                         , balance_date as start_date
                         --, lead(balance_date) over (partition by balance_type order by posting_order, balance_date, id) as end_date
                         , interest_amount as interest_amount
                         , invoice_id
                         , debt_id
                     from crd_debt_interest
                   )
             where interest_amount > 0
               and invoice_id is null
               and start_date between l_invoice_date and l_to_date
             group by debt_id
           ) intr
     where inv_debt.debt_id = intr.debt_id;

    trc_log_pkg.debug(
        i_text  => 'cst_woo_com_pkg.get_mad_by_invoice, l_customer_type = ' || l_customer_type
                    || ', l_overdue_amount = ' || l_overdue_amount
                    || ', l_payment_amount = ' || l_payment_amount
                    || ', l_dispute_amount = ' || l_dispute_amount
                    || ', l_min_amount_due = ' || l_min_amount_due
                    || ', l_sum_daily_interest = ' || l_sum_daily_interest
      , i_entity_type   => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
      , i_object_id     => i_invoice_id
    );

    if l_overdue_amount > 0 then

        l_prev_invoice := get_prev_invoice(i_invoice_id);

        case
            --Before due_date
            when l_to_date < l_due_date and l_payment_amount >= nvl(l_prev_invoice.min_amount_due, 0)
            then return 0;
            when l_to_date < l_due_date and l_payment_amount < nvl(l_prev_invoice.min_amount_due, 0)
            then return nvl(l_prev_invoice.min_amount_due, 0) + l_sum_daily_interest - l_payment_amount - l_dispute_amount;

            --Between due_date and grace_date
            when l_to_date between l_due_date and l_grace_date and l_payment_amount >= l_min_amount_due
            then return 0;
            when l_to_date between l_due_date and l_grace_date and l_payment_amount < l_min_amount_due
            then return l_min_amount_due + l_sum_daily_interest - l_payment_amount - l_dispute_amount;

            --After grace_date
            --Individual customer, after 3rd grace_date, MAD = TAD
            --Corporate customer, after 1st grace_date, MAD = TAD
            when l_to_date > l_grace_date and l_payment_amount >= l_min_amount_due
            then return 0;
            when l_to_date > l_grace_date and l_payment_amount < l_min_amount_due and
                 (
                  (l_aging_period >= 2 and l_customer_type = com_api_const_pkg.ENTITY_TYPE_PERSON)
                  or
                  l_customer_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                 )
            then return l_total_amount_due + l_sum_daily_interest - l_payment_amount - l_dispute_amount;
            when l_to_date > l_grace_date and l_payment_amount < l_min_amount_due
            then return l_min_amount_due + l_sum_daily_interest - l_payment_amount - l_dispute_amount;

            else return 0;
        end case;
    end if;

    if l_overdue_amount = 0 then
        case
            --Before due_date
            when l_to_date < l_due_date
            then return 0;
            --After due_date
            when l_to_date >= l_due_date and l_payment_amount >= l_min_amount_due
            then return 0;
            when l_to_date >= l_due_date and l_payment_amount < l_min_amount_due
            then return l_min_amount_due + l_sum_daily_interest - l_payment_amount - l_dispute_amount;

            else return 0;
        end case;
    end if;

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => 'No_data_found in cst_woo_com_pkg.get_mad_by_invoice, i_invoice_id = [#1]'
          , i_env_param1 => i_invoice_id
        );
        return 0;
end get_mad_by_invoice;

function get_overdue_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id      default null
) return date
is
    l_last_invoice_id               com_api_type_pkg.t_medium_id;
    l_aging_period                  com_api_type_pkg.t_tiny_id;
    l_last_overdue_date             date;
    l_overdue_amount                com_api_type_pkg.t_money;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, i_account_id);
    else    
        l_split_hash := i_split_hash;
    end if;
    
    l_last_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                            i_account_id    => i_account_id
                          , i_split_hash    => l_split_hash
                          , i_mask_error    => com_api_const_pkg.TRUE
                        );  

    select nvl(sum(b.amount), 0)
      into l_overdue_amount
      from crd_debt d
         , crd_debt_balance b
     where d.id = b.debt_id
       and d.is_new = com_api_const_pkg.FALSE   -- Debt was in invoice
       and decode(d.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, d.account_id, null) = i_account_id
       and b.balance_type in (
                               crd_api_const_pkg.BALANCE_TYPE_OVERDUE            --'BLTP1004'
                             , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST   --'BLTP1005'
                             )
       and d.split_hash = l_split_hash
       and b.split_hash = l_split_hash;

    select aging_period
         , overdue_date
      into l_aging_period
         , l_last_overdue_date
      from crd_invoice
     where id = l_last_invoice_id
       and split_hash = l_split_hash;

    if l_overdue_amount = 0 then 
        return get_sysdate;
    elsif l_overdue_amount > 0 and l_aging_period >= 0 then
        select max(overdue_date)
          into l_last_overdue_date
          from crd_invoice
         where id < l_last_invoice_id
           and split_hash = l_split_hash
           and account_id = i_account_id
           and aging_period = 0;
        return l_last_overdue_date;
    end if;
    
    return l_last_overdue_date;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => 'No_data_found in cst_woo_com_pkg.get_overdue_date, i_account_id = [#1]'
          , i_env_param1 => i_account_id
        );
        return null;
end get_overdue_date;

function check_invoice_has_only_fees (
    i_account_id    in  com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_invoice_has_only_fees: ';
    l_invoice_id                    com_api_type_pkg.t_medium_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_result                        com_api_type_pkg.t_tiny_id := com_api_const_pkg.TRUE;
    l_params                        com_api_type_pkg.t_param_tab;

begin

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_account_id [#1]'
      , i_env_param1 => i_account_id
    );

    l_split_hash := 
        com_api_hash_pkg.get_split_hash(
            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
        );

    l_invoice_id :=
        crd_invoice_pkg.get_last_invoice_id(
            i_account_id  => i_account_id
          , i_split_hash  => l_split_hash
          , i_mask_error  => com_api_const_pkg.FALSE
        );

    select count(1)
      into l_result
      from dual
     where not exists (
                   select 1
                     from crd_debt cd
                        , opr_operation oo
                    where cd.id in (
                                    select cid.debt_id 
                                      from crd_invoice_debt cid
                                     where cid.invoice_id = l_invoice_id
                                   )
                      and oo.id = cd.oper_id
                      and not (oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE -- 'OPTP0119'
                               and 
                               oo.oper_reason in (
                                                   crd_api_const_pkg.PENALTY_RATE_FEE_TYPE -- 'FETP1003'
                                                 , mcw_api_const_pkg.ANNUAL_CARD_FEE -- 'FETP0102'
                                                 )
                              )
                      and cd.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE -- 'DBTSACTV'
           );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Result: [#1]'
      , i_env_param1 => l_result
    );

    return l_result;

end check_invoice_has_only_fees;

end cst_woo_com_pkg;
/
