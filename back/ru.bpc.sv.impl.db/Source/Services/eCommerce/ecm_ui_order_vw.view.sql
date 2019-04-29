create or replace force view ecm_ui_order_vw as
select
      e.id
    , e.merchant_id
    , m.merchant_number
    , e.order_number
    , e.order_details
    , e.customer_identifier
    , e.customer_name
    , e.split_hash
    , e.order_uuid
    , e.success_url
    , e.fail_url
    , o.amount
    , o.currency
    , o.event_date
    , o.purpose_id
    , o.status
    , o.customer_id
    , c.customer_number
    , c.inst_id
    , utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw('0000'||to_char(e.id, 'FM9999999999999999')))) xid
    , m.risk_indicator
from ecm_order e
   , pmo_order o
   , prd_customer c
   , acq_merchant m
where e.id = o.id
  and c.id(+) = o.customer_id
  and m.id(+) = e.merchant_id
/
