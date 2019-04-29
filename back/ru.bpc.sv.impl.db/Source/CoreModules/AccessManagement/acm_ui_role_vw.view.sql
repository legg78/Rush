create or replace force view acm_ui_role_vw
as
  select a.id
       , a.name
       , a.notif_scheme_id
       , get_text (i_table_name  => 'acm_role'
                 , i_column_name => 'name'
                 , i_object_id   => a.id
                 , i_lang        => b.lang
                  ) as short_desc
       , get_text (i_table_name  => 'acm_role'
                 , i_column_name => 'description'
                 , i_object_id   => a.id
                 , i_lang        => b.lang
                  ) as full_desc
       , b.lang
       , a.ext_name
  from   acm_role_vw a
       , com_language_vw b
  where
       a.inst_id in (get_user_sandbox, 9999)
/
