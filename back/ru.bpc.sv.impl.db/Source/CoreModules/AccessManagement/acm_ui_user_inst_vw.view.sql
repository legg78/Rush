create or replace force view acm_ui_user_inst_vw
as
  select a.user_id
       , a.inst_id
       , a.is_default
       , a.is_entirely
       , a.grant_type
       , get_text (i_table_name => 'ost_institution'
                 , i_column_name => 'name'
                 , i_object_id => a.inst_id
                 , i_lang => b.lang
                  ) short_desc
       , get_text (i_table_name => 'ost_institution'
                 , i_column_name => 'description'
                 , i_object_id => a.inst_id
                 , i_lang => b.lang
                  ) full_desc
       , b.lang
  from   acm_user_inst_mvw a
       , com_language_vw b
/
