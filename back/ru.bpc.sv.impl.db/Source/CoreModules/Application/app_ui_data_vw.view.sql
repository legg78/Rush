create or replace force view app_ui_data_vw as
select v.*
     , get_number_value(v.data_type, v.element_value) as element_number_value
     , get_char_value  (v.data_type, v.element_value) as element_char_value
     , get_date_value  (v.data_type, v.element_value) as element_date_value
     , get_lov_value   (v.data_type, v.element_value, v.lov_id) as element_lov_value
  from (
      select a.id
           , a.appl_id
           , a.element_id
           , a.parent_id
           , a.serial_number
           , case when e.name like '%CARD_NUMBER'
                  then iss_api_token_pkg.decode_card_number(i_card_number => a.element_value)
                  else a.element_value
             end as element_value
           , a.is_auto
           , a.lang
           , e.element_type
           , e.name
           , (select e2.name
                from app_element_all_vw e2
                   , app_data d2
               where d2.id         = a.parent_id
                 and d2.element_id = e2.id
             ) parent_element
           , e.data_type
           , e.min_length
           , e.max_length
           , e.min_value
           , e.max_value
           , e.lov_id
           , e.default_value
           , e.is_multilang
           , e.entity_type
           , e.edit_form
        from app_data a
           , app_element_all_vw e
       where a.element_id = e.id
  ) v
/

