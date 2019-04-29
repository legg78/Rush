create or replace force view acm_ui_privilege_vw
as
select a.id
     , a.name
     , get_text (i_table_name => 'acm_privilege'
               , i_column_name => 'label'
               , i_object_id => a.id
               , i_lang => b.lang
                ) as short_desc
     , get_text (i_table_name => 'acm_privilege'
               , i_column_name => 'description'
               , i_object_id => a.id
               , i_lang => b.lang
                ) as full_desc
     , b.lang
     , a.section_id
     , a.module_code
     , a.is_active
  from acm_privilege_vw a
     , com_language_vw b
 where a.is_active = get_true
/
