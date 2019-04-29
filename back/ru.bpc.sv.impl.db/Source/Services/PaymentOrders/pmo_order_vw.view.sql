create or replace force view pmo_order_vw as
select a.id
     , a.customer_id
     , a.entity_type
     , a.object_id
     , a.purpose_id
     , a.template_id
     , a.amount
     , a.currency
     , a.event_date
     , a.status
     , a.inst_id
     , a.attempt_count
     , a.split_hash
     , a.is_template
     , a.templ_status
     , a.is_prepared_order
     , a.dst_customer_id
     , a.in_purpose_id
     , a.payment_order_number
     , a.expiration_date
     , a.resp_code
     , a.resp_amount
     , a.originator_refnum
  from pmo_order a
/
