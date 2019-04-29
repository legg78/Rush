create or replace force view cln_ui_user_group_vw as
select g.inst_id
     , g.id group_id
     , g.creation_date
     , get_text(
           i_table_name  => 'ACM_GROUP'
         , i_column_name => 'NAME'
         , i_object_id   => g.id
         , i_lang        => l.lang
       ) as group_name
     , u.user_id
     , u.user_name
     
     , (select count(1) 
          from cln_case cc
         where status in ('CLST0000','CLST0001')
           and cc.user_id = u.user_id
       ) as unresolved_cases_count
     , (select count(1) 
          from cln_case cc
         where status in ('CLST0002')
           and cc.user_id = u.user_id
       ) as resolved_cases_count
     , l.lang 
  from acm_user_group ug
     , acm_group g
     , acm_ui_user_vw u
     , com_language_vw l
 where u.user_id = ug.user_id (+)
   and ug.group_id = g.id (+)
   and u.lang = l.lang
/
