create or replace force view prc_ui_parameter_value_vw as
select a.id
     , x.container_id
     , c.id process_id
     , b.id param_id
     , b.param_name
     , get_text('prc_parameter', 'label', b.id, l.lang) param_label
     , get_text('prc_parameter', 'description', b.id, l.lang) param_desc
     , b.data_type
     , nvl(x.lov_ID, b.lov_id) as lov_id
     , x.display_order
     , x.is_format
     , nvl(a.param_value, x.default_value) param_value
     , get_number_value(b.data_type, nvl(a.param_value, x.default_value)) param_number_value
     , get_char_value  (b.data_type, nvl(a.param_value, x.default_value)) param_char_value
     , get_date_value  (b.data_type, nvl(a.param_value, x.default_value)) param_date_value
     , get_lov_value   (b.data_type, nvl(a.param_value, x.default_value), nvl(x.lov_id, b.lov_id)) param_lov_value
     , b.parent_id
     , l.lang
  from prc_parameter_value a
     , prc_parameter b
     , prc_process c
     , (
        select d.id container_id
             , e.process_id
             , e.param_id
             , e.display_order
             , e.is_format
             , e.default_value
             , e.lov_id
          from prc_container d
             , prc_process_parameter e
         where d.process_id = e.process_id
       ) x
     , com_language_vw l
 where x.container_id = a.container_id(+)
   and x.param_id     = a.param_id (+) 
   and x.process_id   = c.id
   and c.id           = x.process_id
   and b.id           = x.param_id
union
select distinct
       v.id
     , a.container_id
     , f.process_id
     , p.id param_id
     , p.param_name
     , p.label param_label
     , null param_desc
     , p.data_type
     , p.lov_id
     , p.display_order
     , 1 is_format
     , nvl(v.param_value, p.default_value) param_value
     , get_number_value(p.data_type, nvl(v.param_value, p.default_value)) param_number_value
     , get_char_value  (p.data_type, nvl(v.param_value, p.default_value)) param_char_value
     , get_date_value  (p.data_type, nvl(v.param_value, p.default_value)) param_date_value
     , get_lov_value   (p.data_type, nvl(v.param_value, p.default_value), p.lov_id) param_lov_value
     , to_number(null) as parent_id
     , l.lang
  from prc_file f
  join prc_ui_file_attribute_vw a on f.id           = a.file_id
  join rpt_ui_parameter_vw p      on a.report_id    = p.report_id 
  left join prc_parameter_value v on a.container_id = v.container_id and p.id = v.param_id 
  join com_language_vw l          on l.lang = p.lang 
 where f.file_nature  = 'FLNT0040'
/

