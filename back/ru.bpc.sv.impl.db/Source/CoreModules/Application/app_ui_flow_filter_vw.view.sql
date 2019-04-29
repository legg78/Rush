create or replace force view app_ui_flow_filter_vw as
   select a.id
        , a.seqnum
        , (select s.flow_id
             from app_flow_stage s
            where s.id = a.stage_id)
             flow_id
        , a.stage_id
        , a.struct_id
        , b.element_id
        , coalesce(c.data_type, f.data_type) data_type
        , coalesce(c.name, f.name) name
        , coalesce(c.lov_id, f.lov_id) lov_id
        , s.appl_status
        , get_article_text (i_article => s.appl_status, i_lang => 'LANGENG')
             status
        , a.min_count
        , a.max_count
        , a.is_visible
        , a.is_updatable
        , a.is_insertable
        , a.default_value
        , get_number_value (coalesce(c.data_type, f.data_type), a.default_value)
             default_number_value
        , get_char_value (coalesce(c.data_type, f.data_type), a.default_value) default_char_value
        , get_date_value (coalesce(c.data_type, f.data_type), a.default_value) default_date_value
        , get_lov_value  (coalesce(c.data_type, f.data_type), a.default_value, c.lov_id)
             default_lov_value
     from app_flow_filter a
        , app_structure b
        , app_element c
        , app_flow_stage s
        , com_flexible_field f
    where a.struct_id = b.id
      and c.id(+) = b.element_id
      and f.id(+) = b.element_id
      and s.id = a.stage_id
/

