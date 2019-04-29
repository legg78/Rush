create or replace force view opr_cu_oper_type_vw as
select n.id
     , n.seqnum
     , n.inst_id
     , n.entity_type
     , n.entity_object_type
     , n.oper_type
     , get_article_text(
           i_article     => n.oper_type
         , i_lang        => l.lang
       ) as oper_type_name
     , n.invoke_method
     , n.reason_lov_id
     , n.object_type
     , n.wizard_id
     , get_text(
           i_table_name  => 'opr_entity_oper_type'
         , i_column_name => 'name'
         , i_object_id   => n.id
         , i_lang        => l.lang
       ) as name
     , null maker_privilege_id
     , null maker_privilege_name
     , null maker_privilege_label
     , null checker_privilege_id
     , null checker_privilege_name
     , null checker_privilege_label
     , l.lang
  from opr_entity_oper_type n
     , acm_role_object ro
     , com_language_vw l
 where n.inst_id in (select i.inst_id from acm_cu_inst_vw i)
   and ro.role_id in (select r.role_id from acm_cu_role_vw r)
   and ro.entity_type = 'ENTT0096'
   and ro.object_id   = n.id
union all
select t.id
     , t.seqnum
     , t.inst_id
     , t.entity_type
     , t.entity_object_type
     , t.oper_type
     , get_article_text(
           i_article     => t.oper_type
         , i_lang        => l.lang
       ) as oper_type_name
     , t.invoke_method
     , t.reason_lov_id
     , t.object_type
     , t.wizard_id
     , get_text(
           i_table_name  => 'opr_entity_oper_type'
         , i_column_name => 'name'
         , i_object_id   => t.id
         , i_lang        => l.lang
       ) as name
     , w.maker_privilege_id
     , mp.name maker_privilege_name
     , get_text (i_table_name => 'acm_privilege'
               , i_column_name => 'label'
               , i_object_id => mp.id
               , i_lang => l.lang
                ) as maker_privilege_label
  
     , w.checker_privilege_id
     , cp.name checker_privilege_name
     , get_text (i_table_name => 'acm_privilege'
               , i_column_name => 'label'
               , i_object_id => cp.id
               , i_lang => l.lang
                ) as checker_privilege_label
     , l.lang
  from opr_entity_oper_type t
     , gui_wizard w 
     , acm_role_privilege p --privileges of user roles
     , acm_privilege mp
     , acm_privilege cp
     , com_language_vw l
 where t.wizard_id = w.id
   and p.priv_id = w.maker_privilege_id
   and p.role_id in (select r.role_id from acm_cu_role_vw r)
   and t.inst_id in (select i.inst_id from acm_cu_inst_vw i)
   and mp.id = w.maker_privilege_id
   and cp.id = w.maker_privilege_id
/



