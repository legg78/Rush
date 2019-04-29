create or replace force view app_ui_structure_vw as
select a.id
     , a.appl_type
     , a.element_id
     , a.parent_element_id
     , a.min_count
     , a.max_count
     , nvl(a.default_value, e.default_value) default_value
     , a.is_visible
     , a.is_updatable
     , a.is_insertable
     , a.display_order
     , a.is_info
     , a.is_wizard
     , nvl(a.edit_form, e.edit_form) edit_form
     , a.is_parent_desc
     , e.element_type
     , e.name
     , (select x.name from app_element_all_vw x where x.id = a.parent_element_id) parent_name
     , e.data_type
     , e.min_length
     , e.max_length
     , e.min_value
     , e.max_value
     , nvl(a.lov_id, e.lov_id) lov_id
     , e.is_multilang
     , e.entity_type
     , l.lang
     , nvl(get_text('app_element', 'caption', e.id, l.lang), get_text('com_flexible_field', 'label', e.id, l.lang)) caption
     , (select count(1) from app_dependence d where d.struct_id = a.id and rownum = 1) is_dependence
     , (select count(1) from app_dependence d where d.depend_struct_id = a.id and rownum = 1) is_dependent
     , get_number_value(e.data_type, nvl(a.default_value, e.default_value)) default_number_value
     , get_char_value(e.data_type, nvl(a.default_value, e.default_value)) default_char_value
     , get_date_value(e.data_type, nvl(a.default_value, e.default_value)) default_date_value
     , get_lov_value(e.data_type, nvl(a.default_value, e.default_value), nvl(a.lov_id, e.lov_id)) default_lov_value
     , e.inst_id
  from app_structure a
     , app_element_all_vw e
     , com_language_vw l
 where a.element_id = e.id
/
