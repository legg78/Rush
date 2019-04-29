create or replace force view acc_ui_entry_pending_vw as
select
    e.macros_id              
    , e.bunch_id
    , e.transaction_id         
    , e.transaction_type
    , e.account_id             
    , e.amount                 
    , e.currency               
    , e.balance_type           
    , e.balance_impact         
    , e.posting_date           
    , m.amount_purpose
    , m.macros_type_id
    , o.oper_date
    , o.merchant_name
    , o.merchant_street
    , o.merchant_city
    , o.merchant_country
    , o.msg_type
from
    acc_entry_buffer e
    , acc_macros m
    , acc_bunch b
    , opr_operation o
where
    e.status = 'BUSTPEND'
    and e.macros_id = m.id
    and m.entity_type = 'ENTTOPER'
    and m.object_id = o.id
    and e.bunch_id = b.id
/
