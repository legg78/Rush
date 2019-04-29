create or replace force view pmo_api_parameter_vw as
select a.id purpose_id
     , b.param_id
     , c.param_name
     , get_text('pmo_parameter', 'label', b.param_id, d.lang) as param_label
     , b.order_stage
     , b.display_order
     , b.is_editable
     , b.is_template_fixed
     , b.is_mandatory
     , b.default_value
     , b.param_function
     , c.data_type
     , c.tag_id
     , d.lang
  from pmo_purpose a
     , pmo_purpose_parameter b
     , pmo_parameter c
     , com_language_vw d
 where a.id = b.purpose_id
   and b.param_id = c.id
/
