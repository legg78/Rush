create or replace force view pmo_api_template_data_vw as
select d.order_id as template_id
     , o.purpose_id
     , d.param_id
     , get_text('pmo_parameter', 'label', b.param_id, e.lang) as param_label
     , case 
           when b.is_editable = 1 then b.default_value
           when b.is_template_fixed = 1 then d.param_value
           else null
       end param_value_char
     , b.order_stage
     , b.display_order
     , b.is_editable
     , p.tag_id
     , p.data_type
     , e.lang
  from pmo_order_data d
     , pmo_purpose_parameter b
     , pmo_order o
     , pmo_parameter p
     , com_language_vw e
 where d.param_id     = b.param_id
   and d.order_id     = o.id
   and o.purpose_id   = b.purpose_id
   and p.id           = d.param_id
   and b.is_mandatory = 1
/
