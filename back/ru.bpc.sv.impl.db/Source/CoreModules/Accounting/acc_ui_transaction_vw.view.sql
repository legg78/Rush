create or replace force view acc_ui_transaction_vw as
with sttl as (
    select
        d.inst_id
      , d.sttl_day
      , d.sttl_date
      , d.open_timestamp as dt_start
      , nvl(lead(d.open_timestamp) over (order by sttl_day), date '9999-12-31') as dt_end
    from
        com_settlement_day d
),
e as (
    select
        id
      , macros_id
      , bunch_id
      , transaction_id
      , transaction_type
      , account_id
      , amount
      , currency
      , balance_type
      , balance_impact
      , sum(balance_impact * amount) over (partition by account_id, balance_type order by posting_date, posting_order nulls last, id rows between unbounded preceding and current row) as balance
      , posting_date
      , row_number() over (partition by account_id, balance_type order by posting_date, posting_order nulls last, id) as posting_order
      , sttl_day
      , sttl_date
      , status
    from (select
              id
            , macros_id
            , bunch_id
            , transaction_id
            , transaction_type
            , account_id
            , amount
            , currency
            , balance_type
            , balance_impact
            , posting_date
            , posting_order
            , sttl_day
            , sttl_date
            , status
          from
              acc_entry
          union all
          select
              eb.id
            , eb.macros_id
            , eb.bunch_id
            , eb.transaction_id
            , eb.transaction_type
            , eb.account_id
            , eb.amount
            , eb.currency
            , eb.balance_type
            , eb.balance_impact
            , eb.posting_date
            , null as posting_order
            , null sttl_day
            , null sttl_date
            , eb.status
          from
              acc_entry_buffer eb
            , acc_account a
--            , sttl s
          where
              a.id             = eb.account_id 
--              and
--              s.inst_id        = a.inst_id     and
--              eb.posting_date >= s.dt_start    and
--              eb.posting_date  < s.dt_end      and
              and eb.status        = 'BUSTBUFF')
)
select
    e.macros_id
    , m.entity_type
    , m.object_id
    , e.bunch_id
    , e.transaction_id
    , e.transaction_type
    , m.amount_purpose
    , min(decode(e.balance_impact, -1, e.id, null))             debit_entry_id
    , min(decode(e.balance_impact, -1, e.account_id, null))     debit_account_id
    , min(decode(e.balance_impact, -1, nvl(b.balance_number, a.account_number), null)) debit_account_number
    , min(decode(e.balance_impact, -1, a.account_type, null))   debit_account_type
    , min(decode(e.balance_impact, -1, e.balance_type, null))   debit_balance_type
    , min(decode(e.balance_impact, -1, e.amount, null))         debit_amount
    , min(decode(e.balance_impact, -1, e.currency, null))       debit_amount_currency
    , min(decode(e.balance_impact, -1, e.balance, null))        debit_balance
    , min(decode(e.balance_impact, -1, e.posting_date, null))   debit_posting_date
    , min(decode(e.balance_impact, -1, e.posting_order, null))  debit_posting_order
    , min(decode(e.balance_impact, -1, e.sttl_day, null))       debit_sttl_day
    , min(decode(e.balance_impact, -1, e.sttl_date, null))      debit_sttl_date
    , min(decode(e.balance_impact, -1, e.status, null))         debit_status
    , min(decode(e.balance_impact,  1, e.id, null))             credit_entry_id
    , min(decode(e.balance_impact,  1, e.account_id, null))     credit_account_id
    , min(decode(e.balance_impact,  1, nvl(b.balance_number, a.account_number), null))  credit_account_number
    , min(decode(e.balance_impact,  1, a.account_type, null))   credit_account_type
    , min(decode(e.balance_impact,  1, e.balance_type, null))   credit_balance_type
    , min(decode(e.balance_impact,  1, e.amount, null))         credit_amount
    , min(decode(e.balance_impact,  1, e.currency, null))       credit_amount_currency
    , min(decode(e.balance_impact,  1, e.balance, null))        credit_balance
    , min(decode(e.balance_impact,  1, e.posting_date, null))   credit_posting_date
    , min(decode(e.balance_impact,  1, e.posting_order, null))  credit_posting_order
    , min(decode(e.balance_impact,  1, e.sttl_day, null))       credit_sttl_day
    , min(decode(e.balance_impact,  1, e.sttl_date, null))      credit_sttl_date
    , min(decode(e.balance_impact,  1, e.status, null))         credit_status
from
    e
    , acc_account a
    , acc_balance b
    , acc_macros m
where
    e.account_id = a.id
    and a.id = b.account_id
    and e.balance_type = b.balance_type
    and e.macros_id = m.id 
group by
    e.macros_id
    , m.entity_type
    , m.object_id
    , e.bunch_id
    , e.transaction_id
    , e.transaction_type
    , m.amount_purpose
/
