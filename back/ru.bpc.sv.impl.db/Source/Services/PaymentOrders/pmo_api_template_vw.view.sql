create or replace force view pmo_api_template_vw as
select b.purpose_id
     , b.id as template_id
     , get_text('pmo_order', 'label', b.id, c.lang) as template_label
     , b.customer_id
     , c.lang
  from pmo_purpose a
     , pmo_order b
     , com_language_vw c
 where a.id          = b.purpose_id
   and b.is_template = 1
/
