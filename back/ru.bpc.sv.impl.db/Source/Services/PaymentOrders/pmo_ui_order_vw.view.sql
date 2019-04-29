create or replace force view pmo_ui_order_vw as
select a.id
     , a.customer_id
     , a.entity_type
     , a.object_id
     , case when a.entity_type = 'ENTTACCT' then acc.account_number
            else null
       end object_number
     , a.purpose_id
     , a.template_id
     , a.amount
     , a.currency
     , a.event_date
     , a.status
     , a.inst_id
     , a.attempt_count
     , a.split_hash
     , get_text('pmo_service', 'label', b.service_id, c.lang)
       || ' - '
       || get_text('pmo_provider', 'label', b.provider_id, c.lang) purpose_label
     , c.lang
     , a.is_template
     , a.payment_order_number
     , a.expiration_date
     , a.resp_code
     , a.resp_amount
     , a.originator_refnum
  from pmo_order a
     , pmo_purpose_vw b
     , com_language_vw c
     , acc_account acc
 where a.inst_id in (select d.inst_id from acm_cu_inst_vw d)
   and b.id = a.purpose_id
   and a.object_id = acc.id(+)
/
