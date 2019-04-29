create or replace force view com_ui_array_element_vw as
select e.id
     , e.seqnum
     , e.array_id
     , e.element_value
     , e.element_number
     , t.data_type
     , t.lov_id
     , get_text ('com_array_element', 'label', e.id, l.lang) label
     , get_text ('com_array_element', 'description', e.id, l.lang) description
     , l.lang
     , get_number_value(t.data_type, e.element_value) element_number_value
     , get_char_value  (t.data_type, e.element_value) element_char_value
     , get_date_value  (t.data_type, e.element_value) element_date_value
     , get_lov_value   (t.data_type, e.element_value, t.lov_id) element_lov_value
     , t.scale_type
     , a.mod_id
     , e.numeric_value
  from com_array_element e
     , com_array a
     , com_array_type t
     , com_language_vw l
 where e.array_id = a.id
   and a.array_type_id = t.id
/