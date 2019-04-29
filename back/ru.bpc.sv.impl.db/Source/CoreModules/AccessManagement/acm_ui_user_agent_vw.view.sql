create or replace force view acm_ui_user_agent_vw
as
  select a.user_id
       , a.agent_id
       , a.is_default
       , b.inst_id
       , b.agent_type
       , b.parent_id
       , a.grant_type
       , get_text (i_table_name  => 'ost_agent'
                 , i_column_name => 'name'
                 , i_object_id   => a.agent_id
                 , i_lang        => c.lang
                  ) as agent_short_desc
       , get_text (i_table_name  => 'ost_agent'
                 , i_column_name => 'description'
                 , i_object_id   => a.agent_id
                 , i_lang        => c.lang
                  ) as agent_full_desc
       , c.lang
  from   acm_user_agent_mvw a
       , ost_agent_vw b
       , com_language_vw c
  where  a.agent_id = b.id
/
