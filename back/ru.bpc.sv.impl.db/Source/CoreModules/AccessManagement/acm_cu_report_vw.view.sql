create or replace force view acm_cu_report_vw as
select a.role_id
     , c.name as role_name
     , get_user_id as user_id
     , a.object_id as rpt_id
     , get_text(
          i_table_name  => 'rpt_report'
        , i_column_name => 'label'
        , i_object_id   => a.object_id
        , i_lang        => d.lang
       ) as rpt_label
     , get_text(
          i_table_name  => 'rpt_report'
        , i_column_name => 'description'
        , i_object_id   => a.object_id
        , i_lang        => d.lang
       )  as rpt_description
     , d.lang
  from acm_role_object_vw a
     , (select i.role_id from acm_user_role_vw i where i.user_id = get_user_id
        union
        select child_role_id
          from acm_role_role_vw rr
        connect by prior parent_role_id =  child_role_id
        start with parent_role_id in (select i.role_id from acm_user_role_vw i where i.user_id = get_user_id )
       ) b   
     , acm_role_vw c
     , com_language_vw d
 where a.entity_type = 'ENTTREPT'
   and a.role_id     = b.role_id
   and a.role_id     = c.id
/

