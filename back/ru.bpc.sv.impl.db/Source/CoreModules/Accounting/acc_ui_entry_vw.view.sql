create or replace force view acc_ui_entry_vw as
select
    e.id
    , e.macros_id
    , e.bunch_id
    , e.transaction_id
    , e.transaction_type
    , e.account_id
    , e.amount
    , e.currency
    , e.balance_type
    , e.balance_impact
    , e.balance
    , e.posting_date
    , e.posting_order
    , e.sttl_day
    , e.sttl_date
    , m.amount_purpose
    , m.macros_type_id
    , b.bunch_type_id
    , o.oper_date
    , o.merchant_number
    , o.merchant_name
    , o.merchant_street
    , o.merchant_city
    , o.merchant_country
    , o.msg_type
    , o.oper_type
    , m.entity_type
    , m.object_id
    , e.status
    , o.original_id
    , decode(e.balance_type
           , 'BLTP0002'
           , (
              select min(r.posting_date)
                from acc_entry r
               where r.id = e.ref_entry_id
             )
           , null
      ) as unhold_date
    , o.host_date
from
    acc_entry e
    , acc_macros m
    , acc_bunch b
    , opr_operation o
where
    e.macros_id = m.id
    and m.entity_type = 'ENTTOPER'
    and m.object_id = o.id
    and e.bunch_id = b.id(+)
/
